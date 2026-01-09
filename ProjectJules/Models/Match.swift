//
//  Match.swift
//  ProjectJules
//
//  Core Data Models: Matches & Intros
//

import Foundation

// MARK: - Match (Presented to user by Jules)
struct Match: Codable, Identifiable, Equatable {
    let id: String
    let userId: String          // Who is being shown this match
    let matchUserId: String     // The potential match
    var status: MatchStatus
    var compatibilityScore: Double
    var compatibilityReasons: CompatibilityReasons?
    var presentedAt: Date
    var respondedAt: Date?
    var declineReason: String?
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case matchUserId = "match_user_id"
        case status
        case compatibilityScore = "compatibility_score"
        case compatibilityReasons = "compatibility_reasons"
        case presentedAt = "presented_at"
        case respondedAt = "responded_at"
        case declineReason = "decline_reason"
        case createdAt = "created_at"
    }
}

enum MatchStatus: String, Codable {
    case pending
    case accepted
    case declined
    case expired
}

struct CompatibilityReasons: Codable, Equatable {
    var sharedInterests: [String]
    var lifestyleAlignment: [String]
    var valuesMatch: [String]
    var julesNotes: String  // Jules's personalized explanation

    enum CodingKeys: String, CodingKey {
        case sharedInterests = "shared_interests"
        case lifestyleAlignment = "lifestyle_alignment"
        case valuesMatch = "values_match"
        case julesNotes = "jules_notes"
    }
}

// MARK: - Intro (Mutual match - both said yes)
struct Intro: Codable, Identifiable, Equatable {
    let id: String
    let user1Id: String
    let user2Id: String
    var status: IntroStatus
    var matchedAt: Date
    var sparkCompletedAt: Date?
    var scheduledAt: Date?
    var dateAt: Date?
    var venueId: String?
    var cancelledBy: String?
    var cancelledReason: String?
    var createdAt: Date
    var updatedAt: Date

    // Computed helpers
    var isActive: Bool {
        switch status {
        case .sparkExchange, .scheduling, .scheduled:
            return true
        case .completed, .cancelled:
            return false
        }
    }

    var chatUnlockTime: Date? {
        guard let dateAt = dateAt else { return nil }
        return Calendar.current.date(byAdding: .hour, value: -2, to: dateAt)
    }

    var isChatUnlocked: Bool {
        guard let unlockTime = chatUnlockTime else { return false }
        return Date() >= unlockTime
    }

    enum CodingKeys: String, CodingKey {
        case id
        case user1Id = "user_1_id"
        case user2Id = "user_2_id"
        case status
        case matchedAt = "matched_at"
        case sparkCompletedAt = "spark_completed_at"
        case scheduledAt = "scheduled_at"
        case dateAt = "date_at"
        case venueId = "venue_id"
        case cancelledBy = "cancelled_by"
        case cancelledReason = "cancelled_reason"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum IntroStatus: String, Codable {
    case sparkExchange = "spark_exchange"
    case scheduling
    case scheduled
    case completed
    case cancelled

    var displayName: String {
        switch self {
        case .sparkExchange: return "Spark Exchange"
        case .scheduling: return "Finding a time..."
        case .scheduled: return "Date scheduled"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }

    var icon: String {
        switch self {
        case .sparkExchange: return "sparkles"
        case .scheduling: return "calendar"
        case .scheduled: return "calendar.badge.checkmark"
        case .completed: return "checkmark.circle"
        case .cancelled: return "xmark.circle"
        }
    }
}

// MARK: - Spark Exchange
struct SparkExchange: Codable, Identifiable, Equatable {
    let id: String
    let introId: String
    var prompt1: String
    var prompt2: String
    var user1Answer1: String?
    var user1Answer2: String?
    var user2Answer1: String?
    var user2Answer2: String?
    var user1VoiceUrl: String?
    var user2VoiceUrl: String?
    var user1CompletedAt: Date?
    var user2CompletedAt: Date?
    var expiresAt: Date
    var createdAt: Date

    var isComplete: Bool {
        user1CompletedAt != nil && user2CompletedAt != nil
    }

    var isExpired: Bool {
        Date() > expiresAt
    }

    func userHasCompleted(userId: String, user1Id: String) -> Bool {
        if userId == user1Id {
            return user1CompletedAt != nil
        } else {
            return user2CompletedAt != nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case introId = "intro_id"
        case prompt1 = "prompt_1"
        case prompt2 = "prompt_2"
        case user1Answer1 = "user_1_answer_1"
        case user1Answer2 = "user_1_answer_2"
        case user2Answer1 = "user_2_answer_1"
        case user2Answer2 = "user_2_answer_2"
        case user1VoiceUrl = "user_1_voice_url"
        case user2VoiceUrl = "user_2_voice_url"
        case user1CompletedAt = "user_1_completed_at"
        case user2CompletedAt = "user_2_completed_at"
        case expiresAt = "expires_at"
        case createdAt = "created_at"
    }
}

// MARK: - Intro Message (Pre-date chat)
struct IntroMessage: Codable, Identifiable, Equatable {
    let id: String
    let introId: String
    let senderId: String
    var content: String
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case introId = "intro_id"
        case senderId = "sender_id"
        case content
        case createdAt = "created_at"
    }
}

// MARK: - User Availability
struct UserAvailability: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    let introId: String
    var date: Date
    var timeSlot: String  // e.g., "19:30"
    var createdAt: Date

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date)
    }

    var formattedTime: String {
        // Convert "19:30" to "7:30 PM"
        let components = timeSlot.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return timeSlot
        }

        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
        return String(format: "%d:%02d %@", displayHour, minute, period)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case introId = "intro_id"
        case date
        case timeSlot = "time_slot"
        case createdAt = "created_at"
    }
}

// MARK: - Date Feedback
struct DateFeedback: Codable, Identifiable, Equatable {
    let id: String
    let introId: String
    let userId: String
    var rating: DateRating
    var wantSecondDate: Bool
    var feedbackTags: [String]
    var feedbackText: String?
    var venueRating: Int?
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case introId = "intro_id"
        case userId = "user_id"
        case rating
        case wantSecondDate = "want_second_date"
        case feedbackTags = "feedback_tags"
        case feedbackText = "feedback_text"
        case venueRating = "venue_rating"
        case createdAt = "created_at"
    }
}

enum DateRating: String, Codable, CaseIterable {
    case amazing
    case good
    case fine
    case notGreat = "not_great"

    var displayName: String {
        switch self {
        case .amazing: return "Amazing - want to see them again"
        case .good: return "Good - open to another"
        case .fine: return "Fine, but no spark"
        case .notGreat: return "Not great"
        }
    }

    var emoji: String {
        switch self {
        case .amazing: return "🔥"
        case .good: return "😊"
        case .fine: return "😐"
        case .notGreat: return "😕"
        }
    }
}

// MARK: - Extended Match Info (For display)
struct MatchWithProfile {
    let match: Match
    let profile: UserProfile
    let photos: [UserPhoto]
    let compatibilityReasons: CompatibilityReasons?

    var primaryPhoto: UserPhoto? {
        photos.first(where: { $0.isPrimary }) ?? photos.first
    }

    var displayTags: [String] {
        var tags: [String] = []

        if let height = profile.heightFormatted {
            tags.append(height)
        }

        if let hasChildren = profile.hasChildren {
            tags.append(hasChildren ? "Has kids" : "No kids")
        }

        if let occupation = profile.occupation {
            tags.append(occupation)
        }

        return tags
    }
}

// MARK: - Intro with Users (For display)
struct IntroWithUsers {
    let intro: Intro
    let otherUser: UserProfile
    let otherUserPhotos: [UserPhoto]
    let sparkExchange: SparkExchange?
    let venue: Venue?

    var displayName: String {
        otherUser.firstName
    }

    var primaryPhoto: UserPhoto? {
        otherUserPhotos.first(where: { $0.isPrimary }) ?? otherUserPhotos.first
    }

    var statusMessage: String {
        switch intro.status {
        case .sparkExchange:
            if let spark = sparkExchange, spark.isComplete {
                return "Spark Exchange complete!"
            }
            return "Spark Exchange in progress..."
        case .scheduling:
            return "Finding a time that works..."
        case .scheduled:
            if let dateAt = intro.dateAt {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE, MMM d 'at' h:mm a"
                return "Date: \(formatter.string(from: dateAt))"
            }
            return "Date scheduled"
        case .completed:
            return "Date completed"
        case .cancelled:
            return "Cancelled"
        }
    }
}
