//
//  User.swift
//  ProjectJules
//
//  Core Data Models: User & Profile
//

import Foundation

// MARK: - User
struct User: Codable, Identifiable, Equatable {
    let id: String
    var phone: String
    var email: String?
    var createdAt: Date
    var updatedAt: Date
    var lastActiveAt: Date?
    var status: UserStatus
    var subscriptionTier: SubscriptionTier
    var subscriptionExpiresAt: Date?

    var hasCompletedOnboarding: Bool {
        status == .active
    }

    var isPremium: Bool {
        subscriptionTier == .premium &&
        (subscriptionExpiresAt ?? Date.distantPast) > Date()
    }

    enum CodingKeys: String, CodingKey {
        case id
        case phone
        case email
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case lastActiveAt = "last_active_at"
        case status
        case subscriptionTier = "subscription_tier"
        case subscriptionExpiresAt = "subscription_expires_at"
    }
}

enum UserStatus: String, Codable {
    case onboarding
    case active
    case paused
    case banned
}

enum SubscriptionTier: String, Codable {
    case free
    case premium
    
    var displayName: String {
        switch self {
        case .free: return "Free"
        case .premium: return "Premium"
        }
    }
}

// MARK: - User Profile
struct UserProfile: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    var firstName: String
    var birthdate: Date
    var gender: Gender
    var heightInches: Int?
    var hasChildren: Bool?
    var wantsChildren: WantsChildren?
    var occupation: String?
    var education: String?
    var religion: String?
    var ethnicity: String?
    var bio: String?
    var createdAt: Date
    var updatedAt: Date

    var age: Int {
        Calendar.current.dateComponents([.year], from: birthdate, to: Date()).year ?? 0
    }

    var heightFormatted: String? {
        guard let inches = heightInches else { return nil }
        let feet = inches / 12
        let remainingInches = inches % 12
        return "\(feet)'\(remainingInches)\""
    }

    // Note: primaryPhotoURL should be fetched separately from photos table
    // This is a placeholder for UI convenience
    var primaryPhotoURL: String? { nil }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case firstName = "first_name"
        case birthdate
        case gender
        case heightInches = "height_inches"
        case hasChildren = "has_children"
        case wantsChildren = "wants_children"
        case occupation
        case education
        case religion
        case ethnicity
        case bio
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum Gender: String, Codable, CaseIterable {
    case man
    case woman
    case nonbinary

    var displayName: String {
        switch self {
        case .man: return "Man"
        case .woman: return "Woman"
        case .nonbinary: return "Non-binary"
        }
    }
}

enum WantsChildren: String, Codable, CaseIterable {
    case yes
    case no
    case someday
    case not_sure

    var displayName: String {
        switch self {
        case .yes: return "Yes"
        case .no: return "No"
        case .someday: return "Someday"
        case .not_sure: return "Not sure"
        }
    }

    var displayValue: String { displayName }
}

// MARK: - User Photos
struct UserPhoto: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    var url: String
    var position: Int
    var isPrimary: Bool
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case url
        case position
        case isPrimary = "is_primary"
        case createdAt = "created_at"
    }
}

// MARK: - User Preferences
struct UserPreferences: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    var genderPreference: [Gender]
    var ageMin: Int
    var ageMax: Int
    var heightMinInches: Int?
    var heightMaxInches: Int?
    var childrenPreference: ChildrenPreference
    var distanceMaxMiles: Int?
    var createdAt: Date
    var updatedAt: Date

    var ageRangeFormatted: String {
        "\(ageMin) - \(ageMax)"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case genderPreference = "gender_preference"
        case ageMin = "age_min"
        case ageMax = "age_max"
        case heightMinInches = "height_min_inches"
        case heightMaxInches = "height_max_inches"
        case childrenPreference = "children_preference"
        case distanceMaxMiles = "distance_max_miles"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum ChildrenPreference: String, Codable {
    case hasKidsOk = "has_kids_ok"
    case noKidsOnly = "no_kids_only"
    case noPreference = "no_pref"

    var displayName: String {
        switch self {
        case .hasKidsOk: return "Open to people with kids"
        case .noKidsOnly: return "Prefer no kids"
        case .noPreference: return "No preference"
        }
    }
}

// MARK: - User Neighborhoods
struct UserNeighborhood: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    let neighborhoodId: String
    var isWeekday: Bool
    var isWeekend: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case neighborhoodId = "neighborhood_id"
        case isWeekday = "is_weekday"
        case isWeekend = "is_weekend"
    }
}

// MARK: - Communication Profile (How Jules adapts)
struct UserCommunicationProfile: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    var avgMessageLength: Int
    var toneFormality: Double // 0 = casual, 1 = formal
    var emojiUsage: EmojiUsage
    var responseSpeedAvg: Int // seconds
    var preferredTimes: [String]
    var julesRelationship: JulesRelationshipStage
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case avgMessageLength = "avg_message_length"
        case toneFormality = "tone_formality"
        case emojiUsage = "emoji_usage"
        case responseSpeedAvg = "response_speed_avg"
        case preferredTimes = "preferred_times"
        case julesRelationship = "jules_relationship"
        case updatedAt = "updated_at"
    }
}

enum EmojiUsage: String, Codable {
    case none
    case light
    case moderate
    case heavy
}

enum JulesRelationshipStage: String, Codable {
    case new
    case developing
    case established
    case trusted

    var description: String {
        switch self {
        case .new: return "Just getting to know each other"
        case .developing: return "Building rapport"
        case .established: return "Good friends"
        case .trusted: return "Trusted advisor"
        }
    }
}

// MARK: - Learned Preferences (What Jules discovers)
struct LearnedPreference: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    var preferenceType: PreferenceType
    var attribute: String
    var value: String
    var confidence: Double
    var source: String
    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case preferenceType = "preference_type"
        case attribute
        case value
        case confidence
        case source
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum PreferenceType: String, Codable {
    case strongYes = "strong_yes"
    case softYes = "soft_yes"
    case softNo = "soft_no"
    case hardNo = "hard_no"
    case inferred
}

