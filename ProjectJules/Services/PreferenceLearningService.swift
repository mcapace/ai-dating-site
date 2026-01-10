//
//  PreferenceLearningService.swift
//  ProjectJules
//
//  Jules learns from every user decision to personalize matching
//

import Foundation

// MARK: - Preference Learning Service
class PreferenceLearningService {
    static let shared = PreferenceLearningService()

    private let supabase = SupabaseManager.shared

    private init() {}

    // MARK: - Record Match Decision

    /// Called every time a user makes a decision on a match
    func recordMatchDecision(
        userId: String,
        matchUserId: String,
        action: MatchAction,
        matchProfile: UserProfile,
        matchPhotos: [UserPhoto],
        timeToDecide: Int?,
        askedJulesFirst: Bool,
        priorityPassUsed: Bool
    ) async throws {
        // Create profile snapshot
        let snapshot = createProfileSnapshot(
            profile: matchProfile,
            photos: matchPhotos
        )

        // Record the signal
        let signal = MatchSignal(
            id: UUID().uuidString,
            userId: userId,
            matchUserId: matchUserId,
            action: action,
            matchProfile: snapshot,
            timeToDecide: timeToDecide,
            askedJulesFirst: askedJulesFirst,
            priorityPassUsed: priorityPassUsed,
            source: .matchPresentation,
            createdAt: Date()
        )

        try await supabase
            .from(.matchSignals)
            .insert(signal)
            .execute()

        // Update preference patterns based on this decision
        try await updatePatterns(userId: userId, signal: signal)

        // Update taste profile
        try await updateTasteProfile(userId: userId)
    }

    // MARK: - Record Post-Date Feedback

    /// Called after a date to learn from real-world outcomes
    func recordPostDateSignal(
        userId: String,
        matchUserId: String,
        wantSecondDate: Bool,
        feedbackTags: [String],
        originalProfile: UserProfile
    ) async throws {
        let signal = MatchSignal(
            id: UUID().uuidString,
            userId: userId,
            matchUserId: matchUserId,
            action: wantSecondDate ? .secondDate : .noSecondDate,
            matchProfile: createProfileSnapshot(profile: originalProfile, photos: []),
            timeToDecide: nil,
            askedJulesFirst: false,
            priorityPassUsed: false,
            source: .postDate,
            createdAt: Date()
        )

        try await supabase
            .from(.matchSignals)
            .insert(signal)
            .execute()

        // Post-date signals are weighted more heavily
        try await updatePatterns(userId: userId, signal: signal, weight: 2.0)
        try await updateTasteProfile(userId: userId)
    }

    // MARK: - Create Profile Snapshot

    private func createProfileSnapshot(profile: UserProfile, photos: [UserPhoto]) -> MatchProfileSnapshot {
        // Analyze photos for style tags
        let photoStyles = analyzePhotoStyles(photos)

        // Extract keywords from bio
        let bioKeywords = extractBioKeywords(profile.bio)

        return MatchProfileSnapshot(
            age: profile.age,
            gender: profile.gender,
            heightInches: profile.heightInches,
            occupation: profile.occupation,
            education: profile.education,
            ethnicity: profile.ethnicity,
            hasChildren: profile.hasChildren,
            wantsChildren: profile.wantsChildren,
            religion: profile.religion,
            neighborhoods: [], // Would be populated from user_neighborhoods
            photoStyles: photoStyles,
            bioKeywords: bioKeywords,
            interests: [] // Would be populated from interests table
        )
    }

    // MARK: - Update Preference Patterns

    private func updatePatterns(userId: String, signal: MatchSignal, weight: Double = 1.0) async throws {
        let isPositive = [.accepted, .superLiked, .secondDate].contains(signal.action)
        let snapshot = signal.matchProfile

        // Update each attribute pattern
        var patternsToUpdate: [(PreferenceCategory, String, String)] = []

        // Physical attributes
        if let height = snapshot.heightInches {
            let heightRange = categorizeHeight(height)
            patternsToUpdate.append((.physical, "height_range", heightRange))
        }

        for style in snapshot.photoStyles {
            patternsToUpdate.append((.physical, "photo_style", style.rawValue))
        }

        // Demographics
        patternsToUpdate.append((.demographics, "age_range", categorizeAge(snapshot.age)))
        patternsToUpdate.append((.demographics, "gender", snapshot.gender.rawValue))

        if let ethnicity = snapshot.ethnicity {
            patternsToUpdate.append((.demographics, "ethnicity", ethnicity))
        }

        if let religion = snapshot.religion {
            patternsToUpdate.append((.demographics, "religion", religion))
        }

        // Lifestyle
        if let occupation = snapshot.occupation {
            let occupationType = categorizeOccupation(occupation)
            patternsToUpdate.append((.lifestyle, "occupation_type", occupationType))
        }

        if let education = snapshot.education {
            patternsToUpdate.append((.lifestyle, "education", education))
        }

        if let hasChildren = snapshot.hasChildren {
            patternsToUpdate.append((.lifestyle, "has_children", hasChildren ? "yes" : "no"))
        }

        // Personality/Interests
        for keyword in snapshot.bioKeywords {
            patternsToUpdate.append((.personality, "bio_keyword", keyword))
        }

        for interest in snapshot.interests {
            patternsToUpdate.append((.personality, "interest", interest))
        }

        // Update each pattern in database
        for (category, attribute, value) in patternsToUpdate {
            try await updateSinglePattern(
                userId: userId,
                category: category,
                attribute: attribute,
                value: value,
                isPositive: isPositive,
                weight: weight
            )
        }
    }

    private func updateSinglePattern(
        userId: String,
        category: PreferenceCategory,
        attribute: String,
        value: String,
        isPositive: Bool,
        weight: Double
    ) async throws {
        // Try to get existing pattern
        let existing: PreferencePattern? = try? await supabase
            .from(.preferencePatterns)
            .select()
            .eq("user_id", value: userId)
            .eq("attribute", value: attribute)
            .eq("value", value: value)
            .single()
            .execute()
            .value

        if var pattern = existing {
            // Update existing pattern
            pattern.totalExposures += 1
            if isPositive {
                pattern.yesCount += Int(weight)
            } else {
                pattern.noCount += Int(weight)
            }
            pattern.acceptanceRate = Double(pattern.yesCount) / Double(pattern.totalExposures)
            pattern.strength = calculatePatternStrength(pattern.totalExposures)
            pattern.lastUpdated = Date()

            try await supabase
                .from(.preferencePatterns)
                .update(pattern)
                .eq("id", value: pattern.id)
                .execute()
        } else {
            // Create new pattern
            let pattern = PreferencePattern(
                id: UUID().uuidString,
                userId: userId,
                category: category,
                attribute: attribute,
                value: value,
                yesCount: isPositive ? Int(weight) : 0,
                noCount: isPositive ? 0 : Int(weight),
                totalExposures: 1,
                acceptanceRate: isPositive ? 1.0 : 0.0,
                strength: .emerging,
                lastUpdated: Date(),
                notes: nil
            )

            try await supabase
                .from(.preferencePatterns)
                .insert(pattern)
                .execute()
        }
    }

    // MARK: - Update Taste Profile

    private func updateTasteProfile(userId: String) async throws {
        // Get all patterns for this user
        let patterns: [PreferencePattern] = try await supabase
            .from(.preferencePatterns)
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value

        // Get existing taste profile or create new
        var profile: UserTasteProfile
        if let existing: UserTasteProfile = try? await supabase
            .from(.tasteProfiles)
            .select()
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value {
            profile = existing
        } else {
            profile = createEmptyTasteProfile(userId: userId)
        }

        // Update profile based on patterns
        profile = aggregatePatterns(patterns, into: profile)
        profile.updatedAt = Date()

        try await supabase
            .from(.tasteProfiles)
            .upsert(profile)
            .execute()
    }

    private func aggregatePatterns(_ patterns: [PreferencePattern], into profile: UserTasteProfile) -> UserTasteProfile {
        var updated = profile

        // Group patterns by category and attribute
        var ethnicityRates: [String: Double] = [:]
        var occupationRates: [String: Double] = [:]
        var interestRates: [String: Double] = [:]
        var dealbreakers: [String] = []
        var superAttractions: [String] = []

        for pattern in patterns {
            // Only consider patterns with enough data
            guard pattern.strength != .emerging else { continue }

            // Identify dealbreakers (< 10% acceptance with enough data)
            if pattern.acceptanceRate < 0.1 && pattern.totalExposures >= 5 {
                dealbreakers.append("\(pattern.attribute):\(pattern.value)")
            }

            // Identify super attractions (> 90% acceptance with enough data)
            if pattern.acceptanceRate > 0.9 && pattern.totalExposures >= 5 {
                superAttractions.append("\(pattern.attribute):\(pattern.value)")
            }

            // Build category-specific maps
            switch pattern.attribute {
            case "ethnicity":
                ethnicityRates[pattern.value] = pattern.acceptanceRate
            case "occupation_type":
                occupationRates[pattern.value] = pattern.acceptanceRate
            case "interest":
                interestRates[pattern.value] = pattern.acceptanceRate
            default:
                break
            }
        }

        updated.ethnicityPatterns = ethnicityRates
        updated.occupationPatterns = occupationRates
        updated.interestAffinities = interestRates
        updated.dealbreakers = dealbreakers
        updated.superAttractions = superAttractions

        return updated
    }

    private func createEmptyTasteProfile(userId: String) -> UserTasteProfile {
        return UserTasteProfile(
            id: UUID().uuidString,
            userId: userId,
            heightPreference: nil,
            bodyTypePatterns: [:],
            stylePreferences: [:],
            agePatternMin: nil,
            agePatternMax: nil,
            ethnicityPatterns: [:],
            religionPatterns: [:],
            occupationPatterns: [:],
            educationPatterns: [:],
            kidsPreferenceObserved: nil,
            interestAffinities: [:],
            bioKeywordAffinities: [:],
            decidesQuicklyOn: [],
            needsTimeOn: [],
            dealbreakers: [],
            superAttractions: [],
            lastExploratoryMatch: nil,
            exploratorySuccessRate: 0.0,
            updatedAt: Date()
        )
    }

    // MARK: - Get User Preferences for Matching

    /// Returns comprehensive preference data for matching algorithm
    func getPreferencesForMatching(userId: String) async throws -> MatchingPreferences {
        // Get taste profile
        let tasteProfile: UserTasteProfile? = try? await supabase
            .from(.tasteProfiles)
            .select()
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value

        // Get stated preferences
        let statedPrefs: UserPreferences = try await supabase
            .from(.preferences)
            .select()
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value

        // Get strong patterns
        let strongPatterns: [PreferencePattern] = try await supabase
            .from(.preferencePatterns)
            .select()
            .eq("user_id", value: userId)
            .gte("total_exposures", value: 5)
            .order("acceptance_rate", ascending: false)
            .execute()
            .value

        // Get recent signals to understand current state
        let recentSignals: [MatchSignal] = try await supabase
            .from(.matchSignals)
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .limit(20)
            .execute()
            .value

        return MatchingPreferences(
            stated: statedPrefs,
            learned: tasteProfile,
            strongPatterns: strongPatterns,
            recentSignals: recentSignals,
            shouldTryExploratory: shouldSuggestExploratory(tasteProfile: tasteProfile, recentSignals: recentSignals)
        )
    }

    // MARK: - Exploratory Match Logic

    /// Decides if we should try showing someone outside their usual type
    private func shouldSuggestExploratory(tasteProfile: UserTasteProfile?, recentSignals: [MatchSignal]) -> Bool {
        guard let profile = tasteProfile else { return false }

        // Don't do exploratory if they've had one recently
        if let lastExploratory = profile.lastExploratoryMatch {
            let daysSince = Calendar.current.dateComponents([.day], from: lastExploratory, to: Date()).day ?? 0
            if daysSince < 3 { return false }
        }

        // Check if they've been saying no a lot (might be stuck in a pattern)
        let recentNos = recentSignals.filter { [.declined, .expired, .noSecondDate].contains($0.action) }.count
        let recentYes = recentSignals.filter { [.accepted, .superLiked, .secondDate].contains($0.action) }.count

        // If mostly nos recently, try something different
        if recentNos > 0 && recentYes == 0 && recentSignals.count >= 5 {
            return true
        }

        // Good exploratory success rate? Do more
        if profile.exploratorySuccessRate > 0.3 {
            return true
        }

        // 20% chance otherwise to keep things fresh
        return Double.random(in: 0...1) < 0.2
    }

    /// Record outcome of an exploratory match
    func recordExploratoryOutcome(matchId: String, outcome: ExploratoryOutcome, userId: String) async throws {
        // Update the exploratory match record
        try await supabase
            .from(.exploratoryMatches)
            .update(["outcome": outcome.rawValue])
            .eq("match_id", value: matchId)
            .execute()

        // Update taste profile's exploratory success rate
        let allExploratory: [ExploratoryMatch] = try await supabase
            .from(.exploratoryMatches)
            .select()
            .eq("user_id", value: userId)
            .not("outcome", operator: .is, value: "null")
            .execute()
            .value

        let successes = allExploratory.filter { [.accepted, .superLiked, .secondDate].contains($0.outcome) }.count
        let newRate = Double(successes) / Double(max(allExploratory.count, 1))

        try await supabase
            .from(.tasteProfiles)
            .update(["exploratory_success_rate": newRate, "last_exploratory_match": ISO8601DateFormatter().string(from: Date())])
            .eq("user_id", value: userId)
            .execute()
    }

    // MARK: - Helper Functions

    private func categorizeHeight(_ inches: Int) -> String {
        switch inches {
        case ..<64: return "under_5_4"
        case 64..<67: return "5_4_to_5_6"
        case 67..<70: return "5_7_to_5_9"
        case 70..<73: return "5_10_to_6_0"
        case 73..<76: return "6_1_to_6_3"
        default: return "over_6_3"
        }
    }

    private func categorizeAge(_ age: Int) -> String {
        switch age {
        case ..<25: return "under_25"
        case 25..<30: return "25_to_29"
        case 30..<35: return "30_to_34"
        case 35..<40: return "35_to_39"
        case 40..<45: return "40_to_44"
        default: return "45_plus"
        }
    }

    private func categorizeOccupation(_ occupation: String) -> String {
        let lower = occupation.lowercased()

        if lower.contains("creative") || lower.contains("artist") || lower.contains("designer") || lower.contains("writer") || lower.contains("musician") {
            return "creative"
        }
        if lower.contains("tech") || lower.contains("engineer") || lower.contains("developer") || lower.contains("software") {
            return "tech"
        }
        if lower.contains("finance") || lower.contains("banker") || lower.contains("analyst") || lower.contains("trader") {
            return "finance"
        }
        if lower.contains("doctor") || lower.contains("nurse") || lower.contains("therapist") || lower.contains("medical") {
            return "healthcare"
        }
        if lower.contains("teacher") || lower.contains("professor") || lower.contains("educator") {
            return "education"
        }
        if lower.contains("lawyer") || lower.contains("attorney") || lower.contains("legal") {
            return "legal"
        }
        if lower.contains("entrepreneur") || lower.contains("founder") || lower.contains("ceo") {
            return "entrepreneur"
        }

        return "other"
    }

    private func analyzePhotoStyles(_ photos: [UserPhoto]) -> [PhotoStyle] {
        // In production, this would use ML/vision API to analyze photos
        // For now, return empty - would be populated by background job
        return []
    }

    private func extractBioKeywords(_ bio: String?) -> [String] {
        guard let bio = bio else { return [] }

        // Simple keyword extraction - in production would use NLP
        let keywords = [
            "travel", "adventure", "foodie", "coffee", "fitness", "yoga",
            "hiking", "reading", "music", "art", "dogs", "cats", "cooking",
            "wine", "outdoors", "movies", "sports", "family", "career",
            "creative", "ambitious", "funny", "kind", "spontaneous"
        ]

        return keywords.filter { bio.lowercased().contains($0) }
    }

    private func calculatePatternStrength(_ exposures: Int) -> PatternStrength {
        switch exposures {
        case ..<5: return .emerging
        case 5..<15: return .developing
        case 15..<30: return .established
        default: return .strong
        }
    }
}

// MARK: - Matching Preferences (Combined stated + learned)
struct MatchingPreferences {
    var stated: UserPreferences
    var learned: UserTasteProfile?
    var strongPatterns: [PreferencePattern]
    var recentSignals: [MatchSignal]
    var shouldTryExploratory: Bool

    /// Get dealbreakers - hard nos from both stated and learned
    var dealbreakers: [String] {
        var result: [String] = []

        // From learned patterns
        if let learned = learned {
            result.append(contentsOf: learned.dealbreakers)
        }

        // From stated preferences
        if stated.childrenPreference == .noKidsOnly {
            result.append("has_children:yes")
        }

        return result
    }

    /// Get strong preferences that should boost scores
    var strongPositives: [String] {
        var result: [String] = []

        if let learned = learned {
            result.append(contentsOf: learned.superAttractions)
        }

        return result
    }

    /// Calculate match score modifier based on learned preferences
    func scoreModifier(for profile: MatchProfileSnapshot) -> Double {
        var modifier = 1.0

        guard let learned = learned else { return modifier }

        // Check occupation pattern
        if let occupation = profile.occupation {
            let occupationType = categorizeOccupation(occupation)
            if let rate = learned.occupationPatterns[occupationType] {
                modifier *= (0.5 + rate)  // 0.5 to 1.5x
            }
        }

        // Check ethnicity pattern (if user has shown preferences)
        if let ethnicity = profile.ethnicity, !learned.ethnicityPatterns.isEmpty {
            if let rate = learned.ethnicityPatterns[ethnicity] {
                modifier *= (0.5 + rate)
            }
        }

        // Check for dealbreakers
        for dealbreaker in learned.dealbreakers {
            let parts = dealbreaker.split(separator: ":")
            if parts.count == 2 {
                let attr = String(parts[0])
                let val = String(parts[1])

                switch attr {
                case "ethnicity" where profile.ethnicity == val:
                    modifier *= 0.1  // Major penalty
                case "occupation_type" where profile.occupation?.lowercased().contains(val) == true:
                    modifier *= 0.1
                case "has_children" where val == "yes" && profile.hasChildren == true:
                    modifier *= 0.1
                default:
                    break
                }
            }
        }

        // Check for super attractions
        for attraction in learned.superAttractions {
            let parts = attraction.split(separator: ":")
            if parts.count == 2 {
                let attr = String(parts[0])
                let val = String(parts[1])

                switch attr {
                case "occupation_type" where profile.occupation?.lowercased().contains(val) == true:
                    modifier *= 1.5  // Major boost
                case "interest" where profile.interests.contains(val):
                    modifier *= 1.3
                default:
                    break
                }
            }
        }

        return min(max(modifier, 0.1), 2.0)  // Clamp between 0.1 and 2.0
    }

    private func categorizeOccupation(_ occupation: String) -> String {
        let lower = occupation.lowercased()
        if lower.contains("creative") || lower.contains("artist") { return "creative" }
        if lower.contains("tech") || lower.contains("engineer") { return "tech" }
        if lower.contains("finance") { return "finance" }
        return "other"
    }
}
