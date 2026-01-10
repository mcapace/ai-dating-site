//
//  User.swift
//  ProjectJules
//
//  Core Data Models: User & Profile
//

import Foundation

// MARK: - User
struct User: Codable, Identifiable, Equatable {
    let id: String
    var phone: String
    var email: String?
    var createdAt: Date
    var updatedAt: Date
    var lastActiveAt: Date?
    var status: UserStatus
    var subscriptionTier: SubscriptionTier
    var subscriptionExpiresAt: Date?

    var hasCompletedOnboarding: Bool {
        status == .active
    }

    var isPremium: Bool {
        subscriptionTier == .premium &&
        (subscriptionExpiresAt ?? Date.distantPast) > Date()
    }

    enum CodingKeys: String, CodingKey {
        case id
        case phone
        case email
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case lastActiveAt = "last_active_at"
        case status
        case subscriptionTier = "subscription_tier"
        case subscriptionExpiresAt = "subscription_expires_at"
    }
}

enum UserStatus: String, Codable {
    case onboarding
    case active
    case paused
    case banned
}

enum SubscriptionTier: String, Codable {
    case free
    case premium
}

// MARK: - User Profile
struct UserProfile: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    var firstName: String
    var birthdate: Date
    var gender: Gender
    var heightInches: Int?
    var hasChildren: Bool?
    var wantsChildren: WantsChildren?
    var occupation: String?
    var education: String?
    var religion: String?
    var ethnicity: String?
    var bio: String?
    var createdAt: Date
    var updatedAt: Date

    var age: Int {
        Calendar.current.dateComponents([.year], from: birthdate, to: Date()).year ?? 0
    }

    var heightFormatted: String? {
        guard let inches = heightInches else { return nil }
        let feet = inches / 12
        let remainingInches = inches % 12
        return "\(feet)'\(remainingInches)\""
    }

    // Note: primaryPhotoURL should be fetched separately from photos table
    // This is a placeholder for UI convenience
    var primaryPhotoURL: String? { nil }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case firstName = "first_name"
        case birthdate
        case gender
        case heightInches = "height_inches"
        case hasChildren = "has_children"
        case wantsChildren = "wants_children"
        case occupation
        case education
        case religion
        case ethnicity
        case bio
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum Gender: String, Codable, CaseIterable {
    case man
    case woman
    case nonbinary

    var displayName: String {
        switch self {
        case .man: return "Man"
        case .woman: return "Woman"
        case .nonbinary: return "Non-binary"
        }
    }
}

enum WantsChildren: String, Codable, CaseIterable {
    case yes
    case no
    case someday
    case not_sure

    var displayName: String {
        switch self {
        case .yes: return "Yes"
        case .no: return "No"
        case .someday: return "Someday"
        case .not_sure: return "Not sure"
        }
    }

    var displayValue: String { displayName }
}

// MARK: - User Photos
struct UserPhoto: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    var url: String
    var position: Int
    var isPrimary: Bool
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case url
        case position
        case isPrimary = "is_primary"
        case createdAt = "created_at"
    }
}

// MARK: - User Preferences
struct UserPreferences: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    var genderPreference: [Gender]
    var ageMin: Int
    var ageMax: Int
    var heightMinInches: Int?
    var heightMaxInches: Int?
    var childrenPreference: ChildrenPreference
    var distanceMaxMiles: Int?
    var createdAt: Date
    var updatedAt: Date

    var ageRangeFormatted: String {
        "\(ageMin) - \(ageMax)"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case genderPreference = "gender_preference"
        case ageMin = "age_min"
        case ageMax = "age_max"
        case heightMinInches = "height_min_inches"
        case heightMaxInches = "height_max_inches"
        case childrenPreference = "children_preference"
        case distanceMaxMiles = "distance_max_miles"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum ChildrenPreference: String, Codable {
    case hasKidsOk = "has_kids_ok"
    case noKidsOnly = "no_kids_only"
    case noPreference = "no_pref"

    var displayName: String {
        switch self {
        case .hasKidsOk: return "Open to people with kids"
        case .noKidsOnly: return "Prefer no kids"
        case .noPreference: return "No preference"
        }
    }
}

// MARK: - User Neighborhoods
struct UserNeighborhood: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    let neighborhoodId: String
    var isWeekday: Bool
    var isWeekend: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case neighborhoodId = "neighborhood_id"
        case isWeekday = "is_weekday"
        case isWeekend = "is_weekend"
    }
}

// MARK: - Communication Profile (How Jules adapts)
struct UserCommunicationProfile: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    var avgMessageLength: Int
    var toneFormality: Double // 0 = casual, 1 = formal
    var emojiUsage: EmojiUsage
    var responseSpeedAvg: Int // seconds
    var preferredTimes: [String]
    var julesRelationship: JulesRelationshipStage
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case avgMessageLength = "avg_message_length"
        case toneFormality = "tone_formality"
        case emojiUsage = "emoji_usage"
        case responseSpeedAvg = "response_speed_avg"
        case preferredTimes = "preferred_times"
        case julesRelationship = "jules_relationship"
        case updatedAt = "updated_at"
    }
}

enum EmojiUsage: String, Codable {
    case none
    case light
    case moderate
    case heavy
}

enum JulesRelationshipStage: String, Codable {
    case new
    case developing
    case established
    case trusted

    var description: String {
        switch self {
        case .new: return "Just getting to know each other"
        case .developing: return "Building rapport"
        case .established: return "Good friends"
        case .trusted: return "Trusted advisor"
        }
    }
}

// MARK: - Learned Preferences (What Jules discovers)
struct LearnedPreference: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    var preferenceType: PreferenceType
    var attribute: String
    var value: String
    var confidence: Double
    var source: String
    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case preferenceType = "preference_type"
        case attribute
        case value
        case confidence
        case source
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum PreferenceType: String, Codable {
    case strongYes = "strong_yes"
    case softYes = "soft_yes"
    case softNo = "soft_no"
    case hardNo = "hard_no"
    case inferred
}

// MARK: - Match Signal (Every yes/no teaches Jules something)
struct MatchSignal: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    let matchUserId: String
    var action: MatchAction
    var matchProfile: MatchProfileSnapshot  // Snapshot of profile at time of decision
    var timeToDecide: Int?  // Seconds - quick yes = strong interest
    var askedJulesFirst: Bool  // Did they ask "tell me more"?
    var priorityPassUsed: Bool
    var source: SignalSource
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case matchUserId = "match_user_id"
        case action
        case matchProfile = "match_profile"
        case timeToDecide = "time_to_decide"
        case askedJulesFirst = "asked_jules_first"
        case priorityPassUsed = "priority_pass_used"
        case source
        case createdAt = "created_at"
    }
}

enum MatchAction: String, Codable {
    case accepted           // Said yes
    case declined           // Said no/pass
    case expired            // Let it expire (passive no)
    case superLiked         // Used priority pass
    case secondDate         // Wanted another date after meeting
    case noSecondDate       // Met but didn't want more
}

enum SignalSource: String, Codable {
    case matchPresentation  // Initial match shown by Jules
    case sparkExchange      // After Spark Exchange
    case postDate           // After actual date
    case conversation       // From chat with Jules
}

// MARK: - Profile Snapshot (What the match looked like when user decided)
struct MatchProfileSnapshot: Codable, Equatable {
    var age: Int
    var gender: Gender
    var heightInches: Int?
    var occupation: String?
    var education: String?
    var ethnicity: String?
    var hasChildren: Bool?
    var wantsChildren: WantsChildren?
    var religion: String?
    var neighborhoods: [String]
    var photoStyles: [PhotoStyle]  // What their photos conveyed
    var bioKeywords: [String]      // Key themes from bio
    var interests: [String]

    enum CodingKeys: String, CodingKey {
        case age
        case gender
        case heightInches = "height_inches"
        case occupation
        case education
        case ethnicity
        case hasChildren = "has_children"
        case wantsChildren = "wants_children"
        case religion
        case neighborhoods
        case photoStyles = "photo_styles"
        case bioKeywords = "bio_keywords"
        case interests
    }
}

enum PhotoStyle: String, Codable, CaseIterable {
    case outdoorsy
    case urban
    case artistic
    case sporty
    case casual
    case dressy
    case adventurous
    case homebody
    case social
    case intimate
}

// MARK: - Preference Pattern (What Jules has learned from signals)
struct PreferencePattern: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    var category: PreferenceCategory
    var attribute: String           // e.g., "occupation", "height_range", "ethnicity"
    var value: String               // e.g., "creative_fields", "5'8-6'2", "asian"
    var yesCount: Int               // Times user said yes to this
    var noCount: Int                // Times user said no to this
    var totalExposures: Int         // Total times shown
    var acceptanceRate: Double      // yesCount / totalExposures
    var strength: PatternStrength   // How confident Jules is
    var lastUpdated: Date
    var notes: String?              // Jules's observations

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case category
        case attribute
        case value
        case yesCount = "yes_count"
        case noCount = "no_count"
        case totalExposures = "total_exposures"
        case acceptanceRate = "acceptance_rate"
        case strength
        case lastUpdated = "last_updated"
        case notes
    }
}

enum PreferenceCategory: String, Codable, CaseIterable {
    case physical           // Height, body type, style
    case demographics       // Age, ethnicity, religion
    case lifestyle          // Kids, career type, education
    case personality        // Interests, communication style
    case logistics          // Neighborhoods, availability
}

enum PatternStrength: String, Codable {
    case emerging           // < 5 data points
    case developing         // 5-15 data points
    case established        // 15-30 data points
    case strong             // 30+ data points, clear pattern
}

// MARK: - User Taste Profile (Comprehensive understanding)
struct UserTasteProfile: Codable, Identifiable, Equatable {
    let id: String
    let userId: String

    // Physical preferences (learned from behavior)
    var heightPreference: HeightPreference?
    var bodyTypePatterns: [String: Double]      // bodyType -> acceptance rate
    var stylePreferences: [PhotoStyle: Double]  // style -> acceptance rate

    // Demographic patterns
    var agePatternMin: Int?
    var agePatternMax: Int?
    var ethnicityPatterns: [String: Double]
    var religionPatterns: [String: Double]

    // Lifestyle patterns
    var occupationPatterns: [String: Double]    // e.g., "creative": 0.8, "finance": 0.3
    var educationPatterns: [String: Double]
    var kidsPreferenceObserved: ChildrenPreference?

    // Personality/interest patterns
    var interestAffinities: [String: Double]    // Which interests correlate with yes
    var bioKeywordAffinities: [String: Double]  // What words in bios work

    // Meta patterns
    var decidesQuicklyOn: [String]              // Attributes where they decide fast
    var needsTimeOn: [String]                   // Attributes where they deliberate
    var dealbreakers: [String]                  // Hard no patterns
    var superAttractions: [String]              // Instant yes patterns

    // Exploration tracking
    var lastExploratoryMatch: Date?             // When did we try something different?
    var exploratorySuccessRate: Double          // How often do "outside type" matches work?

    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case heightPreference = "height_preference"
        case bodyTypePatterns = "body_type_patterns"
        case stylePreferences = "style_preferences"
        case agePatternMin = "age_pattern_min"
        case agePatternMax = "age_pattern_max"
        case ethnicityPatterns = "ethnicity_patterns"
        case religionPatterns = "religion_patterns"
        case occupationPatterns = "occupation_patterns"
        case educationPatterns = "education_patterns"
        case kidsPreferenceObserved = "kids_preference_observed"
        case interestAffinities = "interest_affinities"
        case bioKeywordAffinities = "bio_keyword_affinities"
        case decidesQuicklyOn = "decides_quickly_on"
        case needsTimeOn = "needs_time_on"
        case dealbreakers
        case superAttractions = "super_attractions"
        case lastExploratoryMatch = "last_exploratory_match"
        case exploratorySuccessRate = "exploratory_success_rate"
        case updatedAt = "updated_at"
    }
}

struct HeightPreference: Codable, Equatable {
    var minInches: Int?
    var maxInches: Int?
    var idealRangeMin: Int?
    var idealRangeMax: Int?
    var flexibility: Double  // 0-1, how strict they are
}

// MARK: - Exploratory Match Flag
struct ExploratoryMatch: Codable, Identifiable, Equatable {
    let id: String
    let matchId: String
    var hypothesis: String          // "Testing if they like creative types"
    var differingAttributes: [String]  // What's different from their pattern
    var outcome: ExploratoryOutcome?
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case matchId = "match_id"
        case hypothesis
        case differingAttributes = "differing_attributes"
        case outcome
        case createdAt = "created_at"
    }
}

enum ExploratoryOutcome: String, Codable {
    case accepted           // They said yes - update patterns!
    case declined           // Confirmed existing pattern
    case superLiked         // Major pattern update needed
    case secondDate         // Strong signal to expand type
}
