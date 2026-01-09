//
//  UserService.swift
//  ProjectJules
//
//  User Profile & Preferences Service
//

import Foundation
import UIKit
import Supabase

// MARK: - User Service
class UserService {
    static let shared = UserService()

    private let supabase = SupabaseManager.shared

    private init() {}

    // MARK: - Profile Management

    /// Create user profile during onboarding
    func createProfile(
        userId: String,
        firstName: String,
        birthdate: Date,
        gender: Gender
    ) async throws -> UserProfile {
        let profile = UserProfile(
            id: UUID().uuidString,
            userId: userId,
            firstName: firstName,
            birthdate: birthdate,
            gender: gender,
            heightInches: nil,
            hasChildren: nil,
            wantsChildren: nil,
            occupation: nil,
            education: nil,
            religion: nil,
            ethnicity: nil,
            bio: nil,
            createdAt: Date(),
            updatedAt: Date()
        )

        try await supabase
            .from(.profiles)
            .insert(profile)
            .execute()

        return profile
    }

    /// Update user profile
    func updateProfile(_ profile: UserProfile) async throws {
        var updatedProfile = profile
        updatedProfile.updatedAt = Date()

        try await supabase
            .from(.profiles)
            .update(updatedProfile)
            .eq("id", value: profile.id)
            .execute()
    }

    /// Get user profile
    func getProfile(userId: String) async throws -> UserProfile {
        let profile: UserProfile = try await supabase
            .from(.profiles)
            .select()
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value

        return profile
    }

    // MARK: - Photos Management

    /// Upload photo and create record
    func uploadPhoto(userId: String, image: UIImage, position: Int) async throws -> UserPhoto {
        // Compress image
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw SupabaseError.invalidData
        }

        // Generate unique filename
        let filename = "\(userId)/\(UUID().uuidString).jpg"

        // Upload to storage
        try await supabase.storage(.avatars).upload(
            path: filename,
            file: imageData,
            options: FileOptions(contentType: "image/jpeg")
        )

        // Get public URL
        let publicURL = try supabase.storage(.avatars).getPublicURL(path: filename)

        // Create photo record
        let photo = UserPhoto(
            id: UUID().uuidString,
            userId: userId,
            url: publicURL.absoluteString,
            position: position,
            isPrimary: position == 0,
            createdAt: Date()
        )

        try await supabase
            .from(.photos)
            .insert(photo)
            .execute()

        return photo
    }

    /// Get user photos
    func getPhotos(userId: String) async throws -> [UserPhoto] {
        let photos: [UserPhoto] = try await supabase
            .from(.photos)
            .select()
            .eq("user_id", value: userId)
            .order("position")
            .execute()
            .value

        return photos
    }

    /// Delete photo
    func deletePhoto(_ photo: UserPhoto) async throws {
        // Delete from storage
        let filename = extractFilename(from: photo.url)
        try await supabase.storage(.avatars).remove(paths: [filename])

        // Delete record
        try await supabase
            .from(.photos)
            .delete()
            .eq("id", value: photo.id)
            .execute()
    }

    /// Reorder photos
    func reorderPhotos(_ photos: [UserPhoto]) async throws {
        for (index, photo) in photos.enumerated() {
            var updatedPhoto = photo
            updatedPhoto.position = index
            updatedPhoto.isPrimary = index == 0

            try await supabase
                .from(.photos)
                .update(updatedPhoto)
                .eq("id", value: photo.id)
                .execute()
        }
    }

    // MARK: - Preferences Management

    /// Create user preferences
    func createPreferences(
        userId: String,
        genderPreference: [Gender],
        ageMin: Int,
        ageMax: Int
    ) async throws -> UserPreferences {
        let preferences = UserPreferences(
            id: UUID().uuidString,
            userId: userId,
            genderPreference: genderPreference,
            ageMin: ageMin,
            ageMax: ageMax,
            heightMinInches: nil,
            heightMaxInches: nil,
            childrenPreference: .noPreference,
            distanceMaxMiles: 25,
            createdAt: Date(),
            updatedAt: Date()
        )

        try await supabase
            .from(.preferences)
            .insert(preferences)
            .execute()

        return preferences
    }

    /// Update preferences
    func updatePreferences(_ preferences: UserPreferences) async throws {
        var updated = preferences
        updated.updatedAt = Date()

        try await supabase
            .from(.preferences)
            .update(updated)
            .eq("id", value: preferences.id)
            .execute()
    }

    /// Get preferences
    func getPreferences(userId: String) async throws -> UserPreferences {
        let preferences: UserPreferences = try await supabase
            .from(.preferences)
            .select()
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value

        return preferences
    }

    // MARK: - Neighborhoods Management

    /// Set user neighborhoods
    func setNeighborhoods(userId: String, neighborhoodIds: [String]) async throws {
        // Delete existing
        try await supabase
            .from(.userNeighborhoods)
            .delete()
            .eq("user_id", value: userId)
            .execute()

        // Insert new
        let neighborhoods = neighborhoodIds.map { neighborhoodId in
            UserNeighborhood(
                id: UUID().uuidString,
                userId: userId,
                neighborhoodId: neighborhoodId,
                isWeekday: true,
                isWeekend: true
            )
        }

        if !neighborhoods.isEmpty {
            try await supabase
                .from(.userNeighborhoods)
                .insert(neighborhoods)
                .execute()
        }
    }

    /// Get user neighborhoods
    func getNeighborhoods(userId: String) async throws -> [UserNeighborhood] {
        let neighborhoods: [UserNeighborhood] = try await supabase
            .from(.userNeighborhoods)
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value

        return neighborhoods
    }

    // MARK: - Complete Onboarding

    /// Mark onboarding as complete
    func completeOnboarding(userId: String) async throws {
        try await supabase
            .from(.users)
            .update(["status": UserStatus.active.rawValue, "updated_at": ISO8601DateFormatter().string(from: Date())])
            .eq("id", value: userId)
            .execute()
    }

    // MARK: - Helpers

    private func extractFilename(from url: String) -> String {
        // Extract path after bucket name
        guard let urlComponents = URLComponents(string: url),
              let path = urlComponents.path.split(separator: "/").last else {
            return url
        }
        return String(path)
    }
}

// MARK: - Neighborhood Service
class NeighborhoodService {
    static let shared = NeighborhoodService()

    private let supabase = SupabaseManager.shared

    private init() {}

    /// Get all neighborhoods for a city
    func getNeighborhoods(cityId: String) async throws -> [Neighborhood] {
        let neighborhoods: [Neighborhood] = try await supabase
            .from(.neighborhoods)
            .select()
            .eq("city_id", value: cityId)
            .order("name")
            .execute()
            .value

        return neighborhoods
    }

    /// Get single neighborhood
    func getNeighborhood(id: String) async throws -> Neighborhood {
        let neighborhood: Neighborhood = try await supabase
            .from(.neighborhoods)
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value

        return neighborhood
    }

    /// Get all active cities
    func getCities() async throws -> [City] {
        let cities: [City] = try await supabase
            .from(.cities)
            .select()
            .eq("is_active", value: true)
            .execute()
            .value

        return cities
    }
}
