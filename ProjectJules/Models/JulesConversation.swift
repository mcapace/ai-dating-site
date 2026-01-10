//
//  JulesConversation.swift
//  ProjectJules
//
//  Core Data Models: Jules AI Conversation
//

import Foundation

// MARK: - Jules Conversation
struct JulesConversation: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Jules Message
struct JulesMessage: Codable, Identifiable, Equatable {
    let id: String
    let conversationId: String
    var role: MessageRole
    var content: String
    var messageType: JulesMessageType
    var metadata: JulesMessageMetadata?
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case conversationId = "conversation_id"
        case role
        case content
        case messageType = "message_type"
        case metadata
        case createdAt = "created_at"
    }
}

enum MessageRole: String, Codable {
    case jules
    case user
}

enum JulesMessageType: String, Codable {
    case text           // Regular text message
    case matchCard      // Presenting a match
    case prompt         // Asking a question (onboarding, feedback, etc.)
    case action         // Action required (schedule, complete spark, etc.)
    case celebration    // Mutual match, date confirmed, etc.
    case quickReplies   // Message with quick reply options
}

struct JulesMessageMetadata: Codable, Equatable {
    var matchId: String?
    var introId: String?
    var quickReplies: [String]?
    var promptType: PromptType?
    var celebrationType: CelebrationType?
    var actionType: ActionType?

    enum CodingKeys: String, CodingKey {
        case matchId = "match_id"
        case introId = "intro_id"
        case quickReplies = "quick_replies"
        case promptType = "prompt_type"
        case celebrationType = "celebration_type"
        case actionType = "action_type"
    }
}

enum PromptType: String, Codable {
    case onboarding
    case matchFeedback
    case dateFeedback
    case preference
    case general
}

enum CelebrationType: String, Codable {
    case mutualMatch = "mutual_match"
    case dateConfirmed = "date_confirmed"
    case sparkComplete = "spark_complete"
    case milestone
}

enum ActionType: String, Codable {
    case viewMatch = "view_match"
    case completeSparkExchange = "complete_spark"
    case selectAvailability = "select_availability"
    case provideFeedback = "provide_feedback"
}

// MARK: - Spark Prompt Library
struct SparkPrompt: Codable, Identifiable, Equatable {
    let id: String
    var text: String
    var category: SparkPromptCategory
    var isActive: Bool
    var timesUsed: Int
    var avgEngagement: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case category
        case isActive = "is_active"
        case timesUsed = "times_used"
        case avgEngagement = "avg_engagement"
    }
}

enum SparkPromptCategory: String, Codable, CaseIterable {
    case lifestyle
    case values
    case fun
    case deep

    var displayName: String {
        switch self {
        case .lifestyle: return "Lifestyle"
        case .values: return "Values"
        case .fun: return "Fun"
        case .deep: return "Deep"
        }
    }
}

// MARK: - Default Spark Prompts
struct DefaultSparkPrompts {
    static let all: [(text: String, category: SparkPromptCategory)] = [
        // Lifestyle
        ("My ideal Sunday morning looks like...", .lifestyle),
        ("The last thing I got really excited about was...", .lifestyle),
        ("My go-to comfort activity is...", .lifestyle),
        ("I'm at my happiest when...", .lifestyle),

        // Values
        ("The way to my heart is...", .values),
        ("Something I'm working on in myself is...", .values),
        ("I feel most alive when...", .values),
        ("A hill I'll die on is...", .values),

        // Fun
        ("I'm weirdly competitive about...", .fun),
        ("My most useless talent is...", .fun),
        ("The emoji that best represents me is...", .fun),
        ("My controversial opinion is...", .fun),

        // Deep
        ("Something most people don't know about me is...", .deep),
        ("I've been thinking a lot about...", .deep),
        ("A moment that changed me was...", .deep),
        ("What I'm looking for is someone who...", .deep),
    ]
}

// MARK: - Notification
struct JulesNotification: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    var type: NotificationType
    var title: String
    var body: String
    var data: NotificationData?
    var isRead: Bool
    var sentAt: Date
    var readAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case type
        case title
        case body
        case data
        case isRead = "is_read"
        case sentAt = "sent_at"
        case readAt = "read_at"
    }
}

enum NotificationType: String, Codable {
    case newMatch = "new_match"
    case mutualMatch = "mutual_match"
    case sparkReady = "spark_ready"
    case dateConfirmed = "date_confirmed"
    case chatUnlocked = "chat_unlocked"
    case dateReminder = "date_reminder"
    case feedbackRequest = "feedback_request"
    case julesMessage = "jules_message"
}

struct NotificationData: Codable, Equatable {
    var matchId: String?
    var introId: String?
    var conversationId: String?
    var deepLink: String?

    enum CodingKeys: String, CodingKey {
        case matchId = "match_id"
        case introId = "intro_id"
        case conversationId = "conversation_id"
        case deepLink = "deep_link"
    }
}

// MARK: - Jules Response Builder
/// Helper to construct Jules messages with proper formatting
struct JulesResponseBuilder {

    static func greeting(name: String) -> String {
        """
        Hey \(name)! I'm Jules, and I'm going to be your matchmaker.

        Think of me as the friend who's annoyingly good at knowing who you'd hit it off with.

        I've got the basics from your profile, but I want to go deeper. The more I know, the better matches I can find.

        Ready?
        """
    }

    static func matchIntro(name: String, age: Int, location: String, occupation: String) -> String {
        "I've got someone interesting. \(name), \(age), \(location)."
    }

    static func matchAccepted(name: String) -> String {
        """
        Nice. I'll pitch you to \(name) and let you know what she says.

        Fingers crossed 🤞
        """
    }

    static func matchDeclined() -> String {
        "Got it, not the one. Any particular reason, or just not feeling it?"
    }

    static func mutualMatch(name: String) -> String {
        """
        Well well well 👀

        \(name) said yes too.

        Before we sort out the when and where, let's do a quick Spark Exchange - you'll both answer a couple prompts so you're not walking in completely blind.
        """
    }

    static func sparkExchangeComplete(name: String) -> String {
        """
        I like you two already. Let's get you in the same room.

        What times work this week?
        """
    }

    static func dateConfirmed(name: String, date: String, time: String, venue: String, address: String) -> String {
        """
        Found a time that works for both of you.

        📅 \(date) at \(time)
        📍 \(venue)
        \(address)

        Chat with \(name) unlocks 2 hours before. Good luck - I've got a good feeling about this one 💫
        """
    }

    static func postDateCheckIn(name: String) -> String {
        """
        So... how'd it go with \(name)?

        Give me the download.
        """
    }

    static func goodDateResponse() -> String {
        "Love to hear it! I'll let them know you're interested in round two. Anything specific that made it click?"
    }

    static func notGreatDateResponse() -> String {
        """
        Hey, not every one's a home run. That's literally why first dates exist.

        Anything I should know for next time?
        """
    }
}

