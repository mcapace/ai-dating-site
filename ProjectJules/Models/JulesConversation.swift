//
//  JulesConversation.swift
//  ProjectJules
//
//  AI conversation models
//

import Foundation

struct JulesConversation: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let conversationType: ConversationType
    var context: [String: AnyCodable]?
    var messages: [ConversationMessage]
    let createdAt: Date
    var updatedAt: Date
    
    enum ConversationType: String, Codable {
        case onboarding
        case matchIntro = "match_intro"
        case datePlanning = "date_planning"
        case feedback
    }
}

struct ConversationMessage: Identifiable, Codable {
    let id: UUID
    let role: MessageRole
    let content: String
    let timestamp: Date
    
    enum MessageRole: String, Codable {
        case user
        case assistant
        case system
    }
}

// Request/Response models for Claude API
struct ClaudeRequest: Codable {
    let model: String
    let maxTokens: Int
    let messages: [ClaudeMessage]
    let system: String?
    
    struct ClaudeMessage: Codable {
        let role: String
        let content: String
    }
}

struct ClaudeResponse: Codable {
    let id: String
    let type: String
    let role: String
    let content: [ContentBlock]
    let model: String
    let stopReason: String?
    let stopSequence: String?
    let usage: Usage
    
    struct ContentBlock: Codable {
        let type: String
        let text: String
    }
    
    struct Usage: Codable {
        let inputTokens: Int
        let outputTokens: Int
    }
}

