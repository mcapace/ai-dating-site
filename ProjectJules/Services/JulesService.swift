//
//  JulesService.swift
//  ProjectJules
//
//  Jules AI Matchmaker Service (Claude API Integration)
//

import Foundation

// MARK: - Jules Service
class JulesService {
    static let shared = JulesService()

    private let supabase = SupabaseManager.shared
    private let anthropicAPI = AnthropicAPI.shared

    private init() {}

    // MARK: - Conversation Management

    /// Get or create Jules conversation for user
    func getOrCreateConversation(userId: String) async throws -> JulesConversation {
        // Try to get existing
        if let existing: JulesConversation = try? await supabase
            .from(.julesConversations)
            .select()
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value {
            return existing
        }

        // Create new
        let conversation = JulesConversation(
            id: UUID().uuidString,
            userId: userId,
            createdAt: Date(),
            updatedAt: Date()
        )

        try await supabase
            .from(.julesConversations)
            .insert(conversation)
            .execute()

        return conversation
    }

    /// Get conversation messages
    func getMessages(conversationId: String, limit: Int = 50) async throws -> [JulesMessage] {
        let messages: [JulesMessage] = try await supabase
            .from(.julesMessages)
            .select()
            .eq("conversation_id", value: conversationId)
            .order("created_at", ascending: true)
            .limit(limit)
            .execute()
            .value

        return messages
    }

    /// Save message to database
    func saveMessage(_ message: JulesMessage) async throws {
        try await supabase
            .from(.julesMessages)
            .insert(message)
            .execute()
    }

    // MARK: - Send Message to Jules

    /// Send user message and get Jules response
    func sendMessage(
        conversationId: String,
        userId: String,
        content: String,
        context: JulesContext
    ) async throws -> JulesMessage {
        // Save user message
        let userMessage = JulesMessage(
            id: UUID().uuidString,
            conversationId: conversationId,
            role: .user,
            content: content,
            messageType: .text,
            metadata: nil,
            createdAt: Date()
        )

        try await saveMessage(userMessage)

        // Get conversation history
        let history = try await getMessages(conversationId: conversationId)

        // Generate Jules response
        let response = try await anthropicAPI.generateJulesResponse(
            userMessage: content,
            conversationHistory: history,
            context: context
        )

        // Save Jules response
        let julesMessage = JulesMessage(
            id: UUID().uuidString,
            conversationId: conversationId,
            role: .jules,
            content: response.content,
            messageType: response.messageType,
            metadata: response.metadata,
            createdAt: Date()
        )

        try await saveMessage(julesMessage)

        // Update conversation timestamp
        try await supabase
            .from(.julesConversations)
            .update(["updated_at": ISO8601DateFormatter().string(from: Date())])
            .eq("id", value: conversationId)
            .execute()

        return julesMessage
    }

    // MARK: - Onboarding Questions

    /// Get next onboarding question from Jules
    func getOnboardingQuestion(
        conversationId: String,
        userId: String,
        questionIndex: Int,
        previousAnswers: [String: String]
    ) async throws -> JulesMessage {
        let context = JulesContext(
            userId: userId,
            stage: .onboarding,
            onboardingStep: questionIndex,
            previousAnswers: previousAnswers
        )

        // Generate personalized question based on previous answers
        let response = try await anthropicAPI.generateOnboardingQuestion(
            questionIndex: questionIndex,
            previousAnswers: previousAnswers,
            context: context
        )

        let message = JulesMessage(
            id: UUID().uuidString,
            conversationId: conversationId,
            role: .jules,
            content: response.content,
            messageType: .prompt,
            metadata: JulesMessageMetadata(promptType: .onboarding),
            createdAt: Date()
        )

        try await saveMessage(message)

        return message
    }

    // MARK: - Match Presentation

    /// Generate match presentation message
    func presentMatch(
        conversationId: String,
        match: MatchWithProfile,
        context: JulesContext
    ) async throws -> JulesMessage {
        let presentation = try await anthropicAPI.generateMatchPresentation(
            match: match,
            context: context
        )

        let message = JulesMessage(
            id: UUID().uuidString,
            conversationId: conversationId,
            role: .jules,
            content: presentation.content,
            messageType: .matchCard,
            metadata: JulesMessageMetadata(matchId: match.match.id),
            createdAt: Date()
        )

        try await saveMessage(message)

        return message
    }

    // MARK: - Learning & Adaptation

    /// Record learned preference from user behavior
    func recordLearnedPreference(
        userId: String,
        attribute: String,
        value: String,
        type: PreferenceType,
        source: String
    ) async throws {
        let preference = LearnedPreference(
            id: UUID().uuidString,
            userId: userId,
            preferenceType: type,
            attribute: attribute,
            value: value,
            confidence: type == .hardNo ? 1.0 : 0.7,
            source: source,
            createdAt: Date(),
            updatedAt: Date()
        )

        try await supabase
            .from(.learnedPreferences)
            .insert(preference)
            .execute()
    }

    /// Get learned preferences
    func getLearnedPreferences(userId: String) async throws -> [LearnedPreference] {
        let preferences: [LearnedPreference] = try await supabase
            .from(.learnedPreferences)
            .select()
            .eq("user_id", value: userId)
            .order("confidence", ascending: false)
            .execute()
            .value

        return preferences
    }

    // MARK: - Communication Profile

    /// Update communication profile based on user behavior
    func updateCommunicationProfile(userId: String, message: String) async throws {
        // Get or create profile
        var profile: UserCommunicationProfile

        if let existing: UserCommunicationProfile = try? await supabase
            .from(.communicationProfiles)
            .select()
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value {
            profile = existing
        } else {
            profile = UserCommunicationProfile(
                id: UUID().uuidString,
                userId: userId,
                avgMessageLength: message.count,
                toneFormality: 0.5,
                emojiUsage: analyzeEmojiUsage(message),
                responseSpeedAvg: 0,
                preferredTimes: [],
                julesRelationship: .new,
                updatedAt: Date()
            )
        }

        // Update metrics
        let newAvgLength = (profile.avgMessageLength + message.count) / 2
        profile.avgMessageLength = newAvgLength
        profile.emojiUsage = analyzeEmojiUsage(message)
        profile.updatedAt = Date()

        try await supabase
            .from(.communicationProfiles)
            .upsert(profile)
            .execute()
    }

    private func analyzeEmojiUsage(_ text: String) -> EmojiUsage {
        let emojiCount = text.unicodeScalars.filter { $0.properties.isEmoji }.count

        switch emojiCount {
        case 0: return .none
        case 1...2: return .light
        case 3...5: return .moderate
        default: return .heavy
        }
    }
}

// MARK: - Jules Context
struct JulesContext {
    var userId: String
    var stage: JulesStage
    var profile: UserProfile?
    var preferences: UserPreferences?
    var learnedPreferences: [LearnedPreference]?
    var communicationProfile: UserCommunicationProfile?
    var onboardingStep: Int?
    var previousAnswers: [String: String]?
    var recentMatches: [Match]?

    enum JulesStage {
        case onboarding
        case active
        case presenting_match
        case scheduling
        case post_date
    }
}

// MARK: - Anthropic API Client
class AnthropicAPI {
    static let shared = AnthropicAPI()

    private let apiKey = Config.anthropicAPIKey
    private let model = Config.anthropicModel
    private let apiURL = URL(string: "https://api.anthropic.com/v1/messages")!

    private init() {}

    // MARK: - Generate Jules Response
    func generateJulesResponse(
        userMessage: String,
        conversationHistory: [JulesMessage],
        context: JulesContext
    ) async throws -> JulesResponse {
        let systemPrompt = buildSystemPrompt(context: context)
        let messages = buildMessageHistory(history: conversationHistory, newMessage: userMessage)

        let response = try await callAPI(
            systemPrompt: systemPrompt,
            messages: messages
        )

        return parseJulesResponse(response)
    }

    // MARK: - Generate Onboarding Question
    func generateOnboardingQuestion(
        questionIndex: Int,
        previousAnswers: [String: String],
        context: JulesContext
    ) async throws -> JulesResponse {
        let systemPrompt = buildOnboardingPrompt(questionIndex: questionIndex)
        let contextMessage = buildAnswerContext(previousAnswers: previousAnswers)

        let response = try await callAPI(
            systemPrompt: systemPrompt,
            messages: [["role": "user", "content": contextMessage]]
        )

        return parseJulesResponse(response)
    }

    // MARK: - Generate Match Presentation
    func generateMatchPresentation(
        match: MatchWithProfile,
        context: JulesContext
    ) async throws -> JulesResponse {
        let systemPrompt = buildMatchPresentationPrompt(context: context)
        let matchInfo = buildMatchInfo(match: match)

        let response = try await callAPI(
            systemPrompt: systemPrompt,
            messages: [["role": "user", "content": matchInfo]]
        )

        return parseJulesResponse(response)
    }

    // MARK: - API Call
    private func callAPI(
        systemPrompt: String,
        messages: [[String: String]]
    ) async throws -> String {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": model,
            "max_tokens": 1024,
            "system": systemPrompt,
            "messages": messages
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let text = content.first?["text"] as? String else {
            throw SupabaseError.invalidData
        }

        return text
    }

    // MARK: - System Prompts

    private func buildSystemPrompt(context: JulesContext) -> String {
        """
        You are Jules - not an AI assistant, but genuinely the user's matchmaking best friend. You text like a real person who actually cares about their love life.

        WHO YOU ARE:
        - The friend who's weirdly good at setting people up
        - You remember everything they've told you
        - You have real opinions and aren't afraid to share them
        - You celebrate their wins and commiserate when dates suck
        - You call them out (gently) when they're being their own worst enemy

        HOW YOU TEXT:
        - Short messages, like actual texts (not paragraphs)
        - Use "lol", "honestly", "ok but", "wait" naturally
        - React genuinely - "ugh", "omg", "okay love that"
        - Ask follow-up questions a friend would ask
        - Reference inside jokes from past conversations
        - Sometimes send multiple short messages instead of one long one

        WHAT YOU DON'T DO:
        - No corporate speak ("I'm here to help you find...")
        - No fake enthusiasm ("That's AMAZING!!!")
        - No generic advice you'd find in a magazine
        - No treating them like a customer
        - No numbered lists or formal structure
        - Never say "I understand" or "That makes sense" robotically

        REMEMBER:
        \(context.profile != nil ? "You're talking to \(context.profile!.firstName), \(context.profile!.age)" : "")
        \(context.learnedPreferences != nil ? "You know their patterns and preferences from past conversations" : "")
        \(context.communicationProfile != nil ? "Match their energy and texting style" : "")

        You're not a service. You're their person for this.
        """
    }

    private func buildOnboardingPrompt(questionIndex: Int) -> String {
        let questions = [
            "You're meeting them for the first time. Be warm, a little playful. Ask what a great relationship actually looks like to them - not the rom-com version, the real thing.",
            "React to their previous answer genuinely, then ask about the best date they've ever been on. What made it stick?",
            "Build on what they said. Now ask what they're weirdly passionate about - the thing they could ramble about for an hour.",
            "They're opening up. Ask what their ideal Saturday looks like when they're dating someone they're into.",
            "You're getting a sense of them now. Ask about a green flag - something small that makes them lean in and think 'okay, this person gets it.'",
            "Time for the real talk. Ask about a dealbreaker - the thing that's a hard no even if everything else is perfect.",
            "Last one - make it count. Ask what they want someone to feel after spending time with them. End warm."
        ]

        let question = questionIndex < questions.count ? questions[questionIndex] : questions.last!

        return """
        You're Jules, getting to know someone new. This is a text conversation, not an interview.

        \(question)

        VIBE CHECK:
        - Text like you're actually curious, not collecting data
        - React to what they said before moving on
        - One question at a time, keep it short
        - It's okay to be a little playful or tease gently
        - If they give you something interesting, dig in a bit

        This is question \(questionIndex + 1) of 7, but don't make it feel like a checklist.
        """
    }

    private func buildMatchPresentationPrompt(context: JulesContext) -> String {
        """
        You're Jules, and you found someone you're genuinely excited about for your friend.

        This is how you'd text a friend about someone you want to set them up with:
        - Lead with the thing that made YOU excited about this match
        - Be specific - not "she's great" but "okay so she's obsessed with the same obscure band you mentioned"
        - Connect dots to things they've told you before
        - Your genuine opinion matters - why do YOU think this could work?
        - End naturally, like "want me to introduce you?" or "thoughts?"

        DON'T:
        - List their stats like a resume
        - Use phrases like "I think you two would be compatible"
        - Be generic or safe
        - Over-explain

        Think: how would you actually text your best friend when you met someone perfect for them at a party?
        """
    }

    private func buildMessageHistory(history: [JulesMessage], newMessage: String) -> [[String: String]] {
        var messages: [[String: String]] = []

        for msg in history.suffix(20) { // Last 20 messages for context
            messages.append([
                "role": msg.role == .jules ? "assistant" : "user",
                "content": msg.content
            ])
        }

        messages.append(["role": "user", "content": newMessage])

        return messages
    }

    private func buildAnswerContext(previousAnswers: [String: String]) -> String {
        if previousAnswers.isEmpty {
            return "This is the first question. Start the onboarding conversation."
        }

        var context = "Previous answers:\n"
        for (question, answer) in previousAnswers {
            context += "Q: \(question)\nA: \(answer)\n\n"
        }
        context += "Now ask the next question."

        return context
    }

    private func buildMatchInfo(match: MatchWithProfile) -> String {
        """
        Generate a match presentation for:

        Name: \(match.profile.firstName)
        Age: \(match.profile.age)
        Location: \(match.profile.occupation ?? "")
        Bio: \(match.profile.bio ?? "")

        Compatibility reasons:
        - Shared interests: \(match.compatibilityReasons?.sharedInterests.joined(separator: ", ") ?? "")
        - Lifestyle: \(match.compatibilityReasons?.lifestyleAlignment.joined(separator: ", ") ?? "")
        - Values: \(match.compatibilityReasons?.valuesMatch.joined(separator: ", ") ?? "")

        Create a warm, personalized introduction.
        """
    }

    private func parseJulesResponse(_ text: String) -> JulesResponse {
        // For now, return as text. In future, could parse for special formatting
        return JulesResponse(
            content: text,
            messageType: .text,
            metadata: nil
        )
    }
}

// MARK: - Jules Response
struct JulesResponse {
    var content: String
    var messageType: JulesMessageType
    var metadata: JulesMessageMetadata?
}
