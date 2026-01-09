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
    // TODO: Move these to environment variables or secure config
    static let url = URL(string: "YOUR_SUPABASE_URL")!
    static let anonKey = "YOUR_SUPABASE_ANON_KEY"
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
        case userProfiles = "user_profiles"
        case userPhotos = "user_photos"
        case userPreferences = "user_preferences"
        case userNeighborhoods = "user_neighborhoods"
        case neighborhoods
        case cities
        case julesConversations = "jules_conversations"
        case julesMessages = "jules_messages"
        case julesLearnedPreferences = "jules_learned_preferences"
        case userCommunicationProfiles = "user_communication_profiles"
        case matches
        case intros
        case sparkExchanges = "spark_exchanges"
        case introMessages = "intro_messages"
        case userAvailability = "user_availability"
        case venues
        case dateFeedback = "date_feedback"
        case sparkPrompts = "spark_prompts"
        case notifications
    }

    // MARK: - Storage Buckets
    enum Bucket: String {
        case photos = "user-photos"
        case voiceNotes = "voice-notes"
    }
}

// MARK: - Database Query Helpers
extension SupabaseManager {

    func from(_ table: Table) -> PostgrestQueryBuilder {
        client.database.from(table.rawValue)
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
