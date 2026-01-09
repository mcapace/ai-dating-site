//
//  User.swift
//  ProjectJules
//
//  User model and preferences
//

import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    let phone: String
    var status: UserStatus
    var subscriptionTier: SubscriptionTier
    var subscriptionExpiresAt: Date?
    let createdAt: Date
    var updatedAt: Date
    
    var profile: UserProfile?
    var preferences: UserPreferences?
    
    enum UserStatus: String, Codable {
        case onboarding
        case active
        case paused
        case banned
    }
    
    enum SubscriptionTier: String, Codable {
        case free
        case premium
    }
}

struct UserProfile: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    var firstName: String?
    var lastName: String?
    var dateOfBirth: Date?
    var bio: String?
    var gender: String?
    var occupation: String?
    var education: String?
    var heightInches: Int?
    let createdAt: Date
    var updatedAt: Date
    
    var fullName: String {
        [firstName, lastName].compactMap { $0 }.joined(separator: " ")
    }
    
    var age: Int? {
        guard let dob = dateOfBirth else { return nil }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dob, to: Date())
        return ageComponents.year
    }
}

struct UserPreferences: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    var ageMin: Int
    var ageMax: Int
    var maxDistance: Int // in miles
    var genderPreference: [String]
    var interests: [String]
    var dealBreakers: [String]
    let createdAt: Date
    var updatedAt: Date
}

struct UserPhoto: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let url: String
    let storagePath: String
    var displayOrder: Int
    var isPrimary: Bool
    let createdAt: Date
}

// Learning system for improving matches
struct UserLearning: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let interactionType: InteractionType
    let interactionData: [String: AnyCodable]
    let createdAt: Date
    
    enum InteractionType: String, Codable {
        case swipe
        case match
        case date
        case feedback
    }
}

// Helper for Codable with Any
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode AnyCodable")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "Cannot encode AnyCodable"))
        }
    }
}

