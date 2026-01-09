//
//  Match.swift
//  ProjectJules
//
//  Match, intro, and spark exchange models
//

import Foundation

struct Match: Identifiable, Codable {
    let id: UUID
    let user1Id: UUID
    let user2Id: UUID
    var status: MatchStatus
    var matchedAt: Date?
    let createdAt: Date
    
    var userName: String { "Match User" } // Placeholder
    var bio: String? { nil } // Placeholder
    
    enum MatchStatus: String, Codable {
        case pending
        case matched
        case declined
        case expired
    }
    
    static let preview = Match(
        id: UUID(),
        user1Id: UUID(),
        user2Id: UUID(),
        status: .pending,
        createdAt: Date()
    )
}

struct Intro: Identifiable, Codable {
    let id: UUID
    let matchId: UUID
    let julesMessage: String
    let createdAt: Date
    
    static let preview = Intro(
        id: UUID(),
        matchId: UUID(),
        julesMessage: "I think you two would really hit it off! You both love art, coffee, and have a great sense of humor.",
        createdAt: Date()
    )
}

struct SparkExchange: Identifiable, Codable {
    let id: UUID
    let matchId: UUID
    let fromUserId: UUID
    let toUserId: UUID
    let sparkType: SparkType
    let createdAt: Date
    
    enum SparkType: String, Codable {
        case like
        case superLike = "super_like"
        case pass
    }
}

struct ScheduledDate: Identifiable, Codable {
    let id: UUID
    let matchId: UUID
    var venueId: UUID?
    let scheduledDate: Date
    var status: DateStatus
    var user1Confirmed: Bool
    var user2Confirmed: Bool
    let createdAt: Date
    var updatedAt: Date
    
    var venue: Venue?
    
    enum DateStatus: String, Codable {
        case pending
        case confirmed
        case cancelled
        case completed
    }
}

struct DateFeedback: Identifiable, Codable {
    let id: UUID
    let scheduledDateId: UUID
    let userId: UUID
    var rating: Int?
    var feedbackText: String?
    var wouldMeetAgain: Bool?
    let createdAt: Date
}

