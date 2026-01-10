//
//  SupabaseClient.swift
//  ProjectJules
//
//  Supabase Configuration & Client
//

import Foundation
import Supabase

// MARK: - Supabase Configuration
enum SupabaseConfig {
    static var url: URL {
        guard let url = URL(string: Config.supabaseURL) else {
            fatalError("Invalid Supabase URL: \(Config.supabaseURL). Please set SUPABASE_URL environment variable or update Config.swift")
        }
        return url
    }
    static var anonKey: String {
        Config.supabaseAnonKey
    }
}

// MARK: - Supabase Client Singleton
class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: SupabaseConfig.url,
            supabaseKey: SupabaseConfig.anonKey
        )
    }

    // MARK: - Database Tables
    enum Table: String {
        case users
        case profiles
        case photos
        case preferences
        case userNeighborhoods = "user_neighborhoods"
        case neighborhoods
        case cities
        case julesConversations = "jules_conversations"
        case julesMessages = "jules_messages"
        case learnedPreferences = "learned_preferences"
        case communicationProfiles = "communication_profiles"
        case matches
        case intros
        case sparkResponses = "spark_responses"
        case userAvailability = "user_availability"
        case venues
        case dateFeedback = "date_feedback"
        case sparkPrompts = "spark_prompts"
        case notifications
    }

    // MARK: - Storage Buckets
    enum Bucket: String {
        case avatars
        case voiceNotes = "voice-notes"
    }
}

// MARK: - Database Query Helpers
extension SupabaseManager {
    func from(_ table: Table) -> PostgrestQueryBuilder {
        client.from(table.rawValue)
    }

    func storage(_ bucket: Bucket) -> StorageFileApi {
        client.storage.from(bucket.rawValue)
    }
}

// MARK: - Error Handling
enum SupabaseError: LocalizedError {
    case notAuthenticated
    case notFound
    case invalidData
    case networkError(Error)
    case serverError(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in to continue"
        case .notFound:
            return "The requested data was not found"
        case .invalidData:
            return "Invalid data received"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
