//
//  UserService.swift
//  ProjectJules
//
//  User profile and preferences management
//

import Foundation
import Supabase

@MainActor
class UserService: ObservableObject {
    private let supabase = SupabaseManager.shared
    
    // MARK: - Profile Management
    
    func createProfile(userId: UUID, profile: UserProfile) async throws -> UserProfile {
        let response: UserProfile = try await supabase.client
            .from("user_profiles")
            .insert(profile)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    func updateProfile(userId: UUID, profile: UserProfile) async throws -> UserProfile {
        let response: UserProfile = try await supabase.client
            .from("user_profiles")
            .update(profile)
            .eq("user_id", value: userId.uuidString)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    func getProfile(userId: UUID) async throws -> UserProfile? {
        let response: [UserProfile] = try await supabase.client
            .from("user_profiles")
            .select()
            .eq("user_id", value: userId.uuidString)
            .single()
            .execute()
            .value
        
        return response.first
    }
    
    // MARK: - Preferences
    
    func updatePreferences(userId: UUID, preferences: UserPreferences) async throws -> UserPreferences {
        let response: UserPreferences = try await supabase.client
            .from("user_preferences")
            .upsert(preferences)
            .eq("user_id", value: userId.uuidString)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    func getPreferences(userId: UUID) async throws -> UserPreferences? {
        let response: [UserPreferences] = try await supabase.client
            .from("user_preferences")
            .select()
            .eq("user_id", value: userId.uuidString)
            .single()
            .execute()
            .value
        
        return response.first
    }
    
    // MARK: - Photos
    
    func uploadPhoto(userId: UUID, imageData: Data, fileName: String) async throws -> UserPhoto {
        // Upload to storage
        let filePath = "\(userId.uuidString)/\(fileName)"
        try await supabase.client.storage
            .from("avatars")
            .upload(filePath, data: imageData)
        
        // Get public URL
        let url = try supabase.client.storage
            .from("avatars")
            .getPublicURL(path: filePath)
        
        // Create photo record
        let photo = UserPhoto(
            id: UUID(),
            userId: userId,
            url: url.absoluteString,
            storagePath: filePath,
            displayOrder: 0,
            isPrimary: false,
            createdAt: Date()
        )
        
        let response: UserPhoto = try await supabase.client
            .from("user_photos")
            .insert(photo)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    func getPhotos(userId: UUID) async throws -> [UserPhoto] {
        let response: [UserPhoto] = try await supabase.client
            .from("user_photos")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("display_order")
            .execute()
            .value
        
        return response
    }
    
    func deletePhoto(photoId: UUID) async throws {
        // Get photo to delete from storage
        let photo: UserPhoto = try await supabase.client
            .from("user_photos")
            .select()
            .eq("id", value: photoId.uuidString)
            .single()
            .execute()
            .value
        
        // Delete from storage
        try await supabase.client.storage
            .from("avatars")
            .remove(paths: [photo.storagePath])
        
        // Delete from database
        try await supabase.client
            .from("user_photos")
            .delete()
            .eq("id", value: photoId.uuidString)
            .execute()
    }
    
    // MARK: - Neighborhoods
    
    func getNeighborhoods(city: String) async throws -> [Neighborhood] {
        let response: [Neighborhood] = try await supabase.client
            .from("neighborhoods")
            .select()
            .eq("city", value: city)
            .execute()
            .value
        
        return response
    }
    
    func addNeighborhood(userId: UUID, neighborhoodId: UUID) async throws {
        let userNeighborhood = UserNeighborhood(
            id: UUID(),
            userId: userId,
            neighborhoodId: neighborhoodId,
            createdAt: Date()
        )
        
        try await supabase.client
            .from("user_neighborhoods")
            .insert(userNeighborhood)
            .execute()
    }
    
    func getUserNeighborhoods(userId: UUID) async throws -> [Neighborhood] {
        let response: [Neighborhood] = try await supabase.client
            .from("user_neighborhoods")
            .select("neighborhoods(*)")
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value
        
        // Parse nested response
        return response
    }
}

