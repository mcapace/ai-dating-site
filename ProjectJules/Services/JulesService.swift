//
//  JulesService.swift
//  ProjectJules
//
//  Claude AI integration service
//

import Foundation

@MainActor
class JulesService: ObservableObject {
    private let apiKey = Config.anthropicAPIKey
    private let model = Config.anthropicModel
    private let baseURL = "https://api.anthropic.com/v1/messages"
    
    // MARK: - Generate Introduction
    
    func generateIntroduction(user1: UserProfile, user2: UserProfile, context: [String: Any] = [:]) async throws -> String {
        let systemPrompt = """
        You are Jules, a warm and thoughtful dating app assistant. Your role is to create personalized introductions between two people who might be a good match.
        
        Guidelines:
        - Be genuine and warm, not overly enthusiastic
        - Highlight 2-3 specific commonalities or complementary traits
        - Keep it concise (2-3 sentences)
        - Use a friendly, conversational tone
        - Focus on what makes them potentially compatible
        """
        
        let userPrompt = """
        Create an introduction for:
        
        Person 1: \(user1.fullName)
        - Bio: \(user1.bio ?? "No bio")
        - Interests: \(context["user1_interests"] as? [String] ?? [])
        
        Person 2: \(user2.fullName)
        - Bio: \(user2.bio ?? "No bio")
        - Interests: \(context["user2_interests"] as? [String] ?? [])
        
        Common interests: \(context["common_interests"] as? [String] ?? [])
        
        Write a brief, warm introduction that helps them connect.
        """
        
        return try await callClaude(system: systemPrompt, user: userPrompt)
    }
    
    // MARK: - Onboarding Conversation
    
    func continueOnboardingConversation(messages: [ConversationMessage], userInput: String) async throws -> String {
        let systemPrompt = """
        You are Jules, a helpful dating app assistant guiding a new user through onboarding.
        Be warm, encouraging, and ask thoughtful questions to understand what they're looking for.
        Keep responses concise and conversational.
        """
        
        let conversationHistory = messages.map { msg in
            "\(msg.role.rawValue): \(msg.content)"
        }.joined(separator: "\n")
        
        let userPrompt = """
        \(conversationHistory)
        
        user: \(userInput)
        assistant:
        """
        
        return try await callClaude(system: systemPrompt, user: userPrompt)
    }
    
    // MARK: - Date Planning
    
    func suggestDatePlan(match: Match, preferences: [String: Any]) async throws -> String {
        let systemPrompt = """
        You are Jules, helping plan a first date. Suggest creative, low-pressure activities that allow for good conversation.
        Consider both people's interests and suggest 2-3 options with brief explanations.
        """
        
        let userPrompt = """
        Suggest a first date plan for two people who matched.
        Preferences: \(preferences)
        
        Provide 2-3 date ideas with brief explanations.
        """
        
        return try await callClaude(system: systemPrompt, user: userPrompt)
    }
    
    // MARK: - API Call
    
    private func callClaude(system: String, user: String) async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw NSError(domain: "JulesService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("anthropic-version", forHTTPHeaderField: "2023-06-01")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ClaudeRequest(
            model: model,
            maxTokens: 1024,
            messages: [
                ClaudeRequest.ClaudeMessage(role: "user", content: user)
            ],
            system: system
        )
        
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "JulesService", code: -1, userInfo: [NSLocalizedDescriptionKey: "API request failed"])
        }
        
        let claudeResponse = try JSONDecoder().decode(ClaudeResponse.self, from: data)
        
        return claudeResponse.content.first?.text ?? "I'm sorry, I couldn't generate a response."
    }
}

