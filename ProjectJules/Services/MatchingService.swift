//
//  MatchingService.swift
//  ProjectJules
//
//  Smart matching using learned preferences + occasional exploration
//

import Foundation

// MARK: - Matching Service
class MatchingService {
    static let shared = MatchingService()

    private let supabase = SupabaseManager.shared
    private let learningService = PreferenceLearningService.shared

    private init() {}

    // MARK: - Generate Daily Matches

    /// Generate personalized matches for a user
    func generateMatches(
        for userId: String,
        limit: Int = 3
    ) async throws -> [ScoredMatch] {
        // Get user's comprehensive preferences (stated + learned)
        let preferences = try await learningService.getPreferencesForMatching(userId: userId)

        // Get user's profile for compatibility
        let userProfile: UserProfile = try await supabase
            .from(.profiles)
            .select()
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value

        // Get candidates (exclude already matched, same gender, etc.)
        let candidates = try await getCandidates(userId: userId, preferences: preferences)

        // Score each candidate
        var scoredMatches: [ScoredMatch] = []

        for candidate in candidates {
            let score = await calculateMatchScore(
                candidate: candidate,
                userProfile: userProfile,
                preferences: preferences
            )
            scoredMatches.append(score)
        }

        // Sort by score, but maybe inject one exploratory match
        scoredMatches.sort { $0.totalScore > $1.totalScore }

        var finalMatches = Array(scoredMatches.prefix(limit))

        // Maybe replace one with an exploratory match
        if preferences.shouldTryExploratory && finalMatches.count >= 2 {
            if let exploratory = try await findExploratoryMatch(
                userId: userId,
                preferences: preferences,
                excludeIds: finalMatches.map { $0.profile.userId }
            ) {
                // Replace the lowest-scored match with exploratory
                finalMatches[finalMatches.count - 1] = exploratory
            }
        }

        return finalMatches
    }

    // MARK: - Get Candidates

    private func getCandidates(userId: String, preferences: MatchingPreferences) async throws -> [CandidateProfile] {
        // Get user's gender preference
        let genders = preferences.stated.genderPreference.map { $0.rawValue }

        // Get users they've already been shown
        let alreadyShown: [Match] = try await supabase
            .from(.matches)
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value

        let excludeIds = alreadyShown.map { $0.matchUserId } + [userId]

        // Query potential matches
        // Note: In production, this would be more sophisticated with geographic filtering etc.
        let profiles: [UserProfile] = try await supabase
            .from(.profiles)
            .select()
            .in("gender", values: genders)
            .execute()
            .value

        // Filter and enrich with photos
        var candidates: [CandidateProfile] = []

        for profile in profiles {
            guard !excludeIds.contains(profile.userId) else { continue }

            // Check age bounds
            let age = profile.age
            if age < preferences.stated.ageMin || age > preferences.stated.ageMax {
                continue
            }

            // Get photos
            let photos: [UserPhoto] = try await supabase
                .from(.photos)
                .select()
                .eq("user_id", value: profile.userId)
                .order("position")
                .execute()
                .value

            // Skip users without photos
            guard !photos.isEmpty else { continue }

            candidates.append(CandidateProfile(profile: profile, photos: photos))
        }

        return candidates
    }

    // MARK: - Calculate Match Score

    private func calculateMatchScore(
        candidate: CandidateProfile,
        userProfile: UserProfile,
        preferences: MatchingPreferences
    ) async -> ScoredMatch {
        var scores = MatchScores()

        // 1. Base compatibility (stated preferences)
        scores.statedPreferenceScore = calculateStatedScore(candidate: candidate, preferences: preferences)

        // 2. Learned preference modifier
        let snapshot = createSnapshot(from: candidate)
        scores.learnedPreferenceModifier = preferences.scoreModifier(for: snapshot)

        // 3. Lifestyle compatibility
        scores.lifestyleScore = calculateLifestyleScore(candidate: candidate, userProfile: userProfile)

        // 4. Neighborhood overlap (important for NYC dating)
        scores.neighborhoodScore = await calculateNeighborhoodScore(
            candidateId: candidate.profile.userId,
            userId: userProfile.userId
        )

        // 5. Activity level matching
        scores.activityScore = await calculateActivityScore(candidateId: candidate.profile.userId)

        // Calculate total
        let total = (
            scores.statedPreferenceScore * 0.25 +
            scores.lifestyleScore * 0.20 +
            scores.neighborhoodScore * 0.15 +
            scores.activityScore * 0.10
        ) * scores.learnedPreferenceModifier

        // Generate why this match could work
        let reasons = generateMatchReasons(candidate: candidate, userProfile: userProfile, preferences: preferences)

        return ScoredMatch(
            profile: candidate.profile,
            photos: candidate.photos,
            totalScore: total,
            scores: scores,
            reasons: reasons,
            isExploratory: false,
            exploratoryHypothesis: nil
        )
    }

    private func calculateStatedScore(candidate: CandidateProfile, preferences: MatchingPreferences) -> Double {
        var score = 1.0

        // Age preference (already filtered, but score proximity to ideal range)
        let age = candidate.profile.age
        let midAge = (preferences.stated.ageMin + preferences.stated.ageMax) / 2
        let ageDiff = abs(age - midAge)
        score *= max(0.5, 1.0 - Double(ageDiff) / 20.0)

        // Height preference if stated
        if let prefMin = preferences.stated.heightMinInches,
           let prefMax = preferences.stated.heightMaxInches,
           let height = candidate.profile.heightInches {
            if height >= prefMin && height <= prefMax {
                score *= 1.2  // Bonus for matching height pref
            } else {
                let diff = min(abs(height - prefMin), abs(height - prefMax))
                score *= max(0.5, 1.0 - Double(diff) / 10.0)
            }
        }

        // Children preference
        if preferences.stated.childrenPreference == .noKidsOnly && candidate.profile.hasChildren == true {
            score *= 0.1  // Almost a dealbreaker
        }

        return min(score, 1.0)
    }

    private func calculateLifestyleScore(candidate: CandidateProfile, userProfile: UserProfile) -> Double {
        var score = 0.5  // Start neutral

        // Education level matching
        if candidate.profile.education != nil && userProfile.education != nil {
            score += 0.2
        }

        // Kids alignment
        if let candWants = candidate.profile.wantsChildren,
           let userWants = userProfile.wantsChildren {
            if candWants == userWants {
                score += 0.3
            } else if (candWants == .someday && userWants == .yes) ||
                      (candWants == .yes && userWants == .someday) {
                score += 0.15  // Close enough
            }
        }

        return min(score, 1.0)
    }

    private func calculateNeighborhoodScore(candidateId: String, userId: String) async -> Double {
        do {
            let userHoods: [UserNeighborhood] = try await supabase
                .from(.userNeighborhoods)
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value

            let candHoods: [UserNeighborhood] = try await supabase
                .from(.userNeighborhoods)
                .select()
                .eq("user_id", value: candidateId)
                .execute()
                .value

            let userHoodIds = Set(userHoods.map { $0.neighborhoodId })
            let candHoodIds = Set(candHoods.map { $0.neighborhoodId })

            let overlap = userHoodIds.intersection(candHoodIds).count
            let total = userHoodIds.union(candHoodIds).count

            guard total > 0 else { return 0.5 }
            return Double(overlap) / Double(total)
        } catch {
            return 0.5
        }
    }

    private func calculateActivityScore(candidateId: String) async -> Double {
        // Score based on how active/responsive the candidate is
        do {
            let recentActivity: [MatchSignal] = try await supabase
                .from(.matchSignals)
                .select()
                .eq("user_id", value: candidateId)
                .order("created_at", ascending: false)
                .limit(10)
                .execute()
                .value

            // More recent activity = higher score
            if let mostRecent = recentActivity.first {
                let daysSince = Calendar.current.dateComponents([.day], from: mostRecent.createdAt, to: Date()).day ?? 30
                return max(0.3, 1.0 - Double(daysSince) / 30.0)
            }

            return 0.5
        } catch {
            return 0.5
        }
    }

    // MARK: - Exploratory Match

    private func findExploratoryMatch(
        userId: String,
        preferences: MatchingPreferences,
        excludeIds: [String]
    ) async throws -> ScoredMatch? {
        guard let learned = preferences.learned else { return nil }

        // Find someone outside their usual patterns
        let allProfiles: [UserProfile] = try await supabase
            .from(.profiles)
            .select()
            .in("gender", values: preferences.stated.genderPreference.map { $0.rawValue })
            .execute()
            .value

        for profile in allProfiles.shuffled() {
            guard !excludeIds.contains(profile.userId) && profile.userId != userId else { continue }

            // Check what's different about this person
            var differences: [String] = []
            var hypothesis = ""

            // Check occupation
            if let occupation = profile.occupation {
                let occType = categorizeOccupation(occupation)
                if let rate = learned.occupationPatterns[occType], rate < 0.4 {
                    differences.append("occupation_type:\(occType)")
                    hypothesis = "Testing if they connect with \(occType) professionals"
                }
            }

            // Check if they have enough differences to be exploratory
            if !differences.isEmpty {
                let photos: [UserPhoto] = try await supabase
                    .from(.photos)
                    .select()
                    .eq("user_id", value: profile.userId)
                    .order("position")
                    .execute()
                    .value

                guard !photos.isEmpty else { continue }

                // Record this as exploratory
                let exploratory = ExploratoryMatch(
                    id: UUID().uuidString,
                    matchId: "", // Will be set when match is created
                    hypothesis: hypothesis,
                    differingAttributes: differences,
                    outcome: nil,
                    createdAt: Date()
                )

                try await supabase
                    .from(.exploratoryMatches)
                    .insert(exploratory)
                    .execute()

                return ScoredMatch(
                    profile: profile,
                    photos: photos,
                    totalScore: 0.6,  // Moderate score for exploratory
                    scores: MatchScores(),
                    reasons: MatchReasons(
                        headline: "Someone a bit different",
                        sharedInterests: [],
                        lifestyleAlignment: ["Expanding your horizons"],
                        whyJulesThinks: hypothesis
                    ),
                    isExploratory: true,
                    exploratoryHypothesis: hypothesis
                )
            }
        }

        return nil
    }

    // MARK: - Generate Match Reasons

    private func generateMatchReasons(
        candidate: CandidateProfile,
        userProfile: UserProfile,
        preferences: MatchingPreferences
    ) -> MatchReasons {
        var sharedInterests: [String] = []
        var lifestyleAlignment: [String] = []
        var whyJulesThinks = ""

        // Check for strong positive patterns
        if let learned = preferences.learned {
            if let occupation = candidate.profile.occupation {
                let occType = categorizeOccupation(occupation)
                if let rate = learned.occupationPatterns[occType], rate > 0.7 {
                    whyJulesThinks = "You tend to connect with people in \(occType) fields"
                }
            }
        }

        // Kids alignment
        if let candWants = candidate.profile.wantsChildren,
           let userWants = userProfile.wantsChildren,
           candWants == userWants {
            lifestyleAlignment.append("Same page about kids")
        }

        // Build headline
        let headline: String
        if let occupation = candidate.profile.occupation {
            headline = "\(candidate.profile.firstName), \(occupation)"
        } else {
            headline = "\(candidate.profile.firstName), \(candidate.profile.age)"
        }

        return MatchReasons(
            headline: headline,
            sharedInterests: sharedInterests,
            lifestyleAlignment: lifestyleAlignment,
            whyJulesThinks: whyJulesThinks
        )
    }

    // MARK: - Helpers

    private func createSnapshot(from candidate: CandidateProfile) -> MatchProfileSnapshot {
        return MatchProfileSnapshot(
            age: candidate.profile.age,
            gender: candidate.profile.gender,
            heightInches: candidate.profile.heightInches,
            occupation: candidate.profile.occupation,
            education: candidate.profile.education,
            ethnicity: candidate.profile.ethnicity,
            hasChildren: candidate.profile.hasChildren,
            wantsChildren: candidate.profile.wantsChildren,
            religion: candidate.profile.religion,
            neighborhoods: [],
            photoStyles: [],
            bioKeywords: [],
            interests: []
        )
    }

    private func categorizeOccupation(_ occupation: String) -> String {
        let lower = occupation.lowercased()
        if lower.contains("creative") || lower.contains("artist") { return "creative" }
        if lower.contains("tech") || lower.contains("engineer") { return "tech" }
        if lower.contains("finance") { return "finance" }
        if lower.contains("doctor") || lower.contains("medical") { return "healthcare" }
        return "other"
    }
}

// MARK: - Supporting Types

struct CandidateProfile {
    let profile: UserProfile
    let photos: [UserPhoto]
}

struct ScoredMatch {
    let profile: UserProfile
    let photos: [UserPhoto]
    let totalScore: Double
    let scores: MatchScores
    let reasons: MatchReasons
    let isExploratory: Bool
    let exploratoryHypothesis: String?
}

struct MatchScores {
    var statedPreferenceScore: Double = 0.5
    var learnedPreferenceModifier: Double = 1.0
    var lifestyleScore: Double = 0.5
    var neighborhoodScore: Double = 0.5
    var activityScore: Double = 0.5
}

struct MatchReasons {
    var headline: String
    var sharedInterests: [String]
    var lifestyleAlignment: [String]
    var whyJulesThinks: String
}
