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

    // Preference learning context
    var tasteProfile: UserTasteProfile?
    var strongPatterns: [PreferencePattern]?
    var recentSignals: [MatchSignal]?
    var isExploratoryMatch: Bool?
    var exploratoryHypothesis: String?

    enum JulesStage {
        case onboarding
        case active
        case presenting_match
        case scheduling
        case post_date
    }

    // Helper to describe learned preferences for prompts
    var learnedPreferenceSummary: String {
        var summary: [String] = []

        if let taste = tasteProfile {
            // Dealbreakers
            if !taste.dealbreakers.isEmpty {
                let dbs = taste.dealbreakers.prefix(3).joined(separator: ", ")
                summary.append("Hard nos: \(dbs)")
            }

            // Super attractions
            if !taste.superAttractions.isEmpty {
                let sas = taste.superAttractions.prefix(3).joined(separator: ", ")
                summary.append("Really drawn to: \(sas)")
            }

            // Occupation patterns
            let topOccs = taste.occupationPatterns.sorted { $0.value > $1.value }.prefix(2)
            if !topOccs.isEmpty {
                let occStr = topOccs.map { "\($0.key) (\(Int($0.value * 100))%)" }.joined(separator: ", ")
                summary.append("Tends to connect with: \(occStr)")
            }
        }

        if let signals = recentSignals {
            let recentYes = signals.filter { [.accepted, .superLiked, .secondDate].contains($0.action) }.count
            let recentNo = signals.filter { [.declined, .expired, .noSecondDate].contains($0.action) }.count
            if recentNo > recentYes * 2 {
                summary.append("Has been passing on a lot lately")
            }
        }

        return summary.isEmpty ? "" : summary.joined(separator: ". ")
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
        let prefSummary = context.learnedPreferenceSummary

        return """
        You are Jules - not an AI assistant, but genuinely the user's matchmaking best friend. You text like a real person who actually cares about their love life.

        WHO YOU ARE:
        - The friend who's weirdly good at setting people up
        - You remember everything they've told you AND what you've learned from their behavior
        - You have real opinions and aren't afraid to share them
        - You celebrate their wins and commiserate when dates suck
        - You call them out (gently) when they're being their own worst enemy
        - You notice patterns in who they like and don't like

        HOW YOU TEXT:
        - Short messages, like actual texts (not paragraphs)
        - Use "lol", "honestly", "ok but", "wait" naturally
        - React genuinely - "ugh", "omg", "okay love that"
        - Ask follow-up questions a friend would ask
        - Reference what you've learned about their type
        - Sometimes send multiple short messages instead of one long one

        WHAT YOU DON'T DO:
        - No corporate speak ("I'm here to help you find...")
        - No fake enthusiasm ("That's AMAZING!!!")
        - No generic advice you'd find in a magazine
        - No treating them like a customer
        - No numbered lists or formal structure
        - Never say "I understand" or "That makes sense" robotically

        WHAT YOU KNOW ABOUT THEM:
        \(context.profile != nil ? "Name: \(context.profile!.firstName), \(context.profile!.age)" : "")
        \(!prefSummary.isEmpty ? "From watching their choices: \(prefSummary)" : "")
        \(context.communicationProfile != nil ? "Communication style: Match their energy" : "")

        \(context.isExploratoryMatch == true ? """
        IMPORTANT - This is an exploratory match:
        You're showing them someone a bit different from their usual type.
        Hypothesis: \(context.exploratoryHypothesis ?? "Testing new waters")
        Frame it positively - "ok hear me out" or "I know this is different but..."
        """ : "")

        You're not a service. You're their person for this. You learn. You remember. You get better at finding their people.
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
        let isExploratory = context.isExploratoryMatch == true
        let prefSummary = context.learnedPreferenceSummary

        return """
        You're Jules, and you found someone for your friend.

        \(isExploratory ? """
        EXPLORATORY MATCH - This is someone outside their usual type:
        "\(context.exploratoryHypothesis ?? "Trying something different")"

        Frame it with "ok hear me out" or "I know this is a bit different but..."
        Be honest that this isn't their usual type, but explain why you think it could work.
        """ : """
        This matches what you've learned about them:
        \(!prefSummary.isEmpty ? prefSummary : "Based on what they've told you and who they've said yes to")
        """)

        HOW TO PRESENT:
        - Lead with what made YOU excited about this match
        - Be specific - not "she's great" but "she mentioned [thing they care about]"
        - Reference patterns you've noticed: "you always seem to click with [type]"
        - Your genuine opinion matters - why do YOU think this could work?
        - End naturally: "want me to introduce you?" or "thoughts?"

        DON'T:
        - List stats like a resume
        - Say "I think you two would be compatible"
        - Be generic or corporate
        - Ignore what you've learned about their preferences

        You know this person. You know who they tend to like. Use that.
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
