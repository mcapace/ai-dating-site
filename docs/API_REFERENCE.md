# API Reference

Service interfaces for Project Jules iOS app.

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [AuthService](#authservice)
3. [UserService](#userservice)
4. [JulesService](#julesservice)
5. [PreferenceLearningService](#preferencelearningservice)
6. [MatchingService](#matchingservice)
7. [External APIs](#external-apis)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                      SwiftUI Views                       │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                  Service Layer (Swift)                   │
│  ┌───────────┐ ┌───────────┐ ┌───────────────────────┐  │
│  │AuthService│ │UserService│ │    JulesService       │  │
│  └───────────┘ └───────────┘ └───────────────────────┘  │
│  ┌─────────────────────────┐ ┌───────────────────────┐  │
│  │PreferenceLearningService│ │   MatchingService     │  │
│  └─────────────────────────┘ └───────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                            │
            ┌───────────────┼───────────────┐
            ▼               ▼               ▼
    ┌───────────────┐ ┌───────────┐ ┌───────────────┐
    │   Supabase    │ │Claude API │ │  Twilio SMS   │
    │(PostgreSQL+   │ │(Anthropic)│ │   (Verify)    │
    │Auth+Storage)  │ │           │ │               │
    └───────────────┘ └───────────┘ └───────────────┘
```

### Service Singletons

All services use the singleton pattern for shared state:

```swift
AuthService.shared
UserService.shared
JulesService.shared
PreferenceLearningService.shared
MatchingService.shared
SupabaseManager.shared
```

---

## AuthService

Handles phone authentication via Supabase + Twilio Verify.

### Properties

```swift
class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool
    @Published var isLoading: Bool
}
```

### Methods

#### sendOTP

Sends SMS verification code to phone number.

```swift
func sendOTP(phone: String) async throws

// Usage
try await AuthService.shared.sendOTP(phone: "+15551234567")

// Throws
// - AuthError.invalidPhone
// - AuthError.rateLimited
// - AuthError.networkError
```

#### verifyOTP

Verifies the code and creates/signs in user.

```swift
func verifyOTP(phone: String, code: String) async throws -> User

// Usage
let user = try await AuthService.shared.verifyOTP(
    phone: "+15551234567",
    code: "123456"
)

// Returns: User object with id, phone, status, subscriptionTier
// Throws: AuthError.invalidCode, AuthError.expiredCode
```

#### signOut

Signs out current user.

```swift
func signOut() async throws

// Clears currentUser and isAuthenticated
```

#### refreshSession

Refreshes the auth session if needed.

```swift
func refreshSession() async throws

// Call on app launch to restore session
```

---

## UserService

Manages user profiles and preferences.

### Methods

#### createProfile

Creates initial user profile during onboarding.

```swift
func createProfile(
    userId: String,
    firstName: String,
    birthdate: Date,
    gender: Gender
) async throws -> UserProfile

// Usage
let profile = try await UserService.shared.createProfile(
    userId: user.id,
    firstName: "Sarah",
    birthdate: Date("1995-03-15"),
    gender: .woman
)
```

#### updateProfile

Updates existing profile fields.

```swift
func updateProfile(_ profile: UserProfile) async throws

// Usage
var profile = currentProfile
profile.bio = "Coffee enthusiast, amateur photographer"
try await UserService.shared.updateProfile(profile)
```

#### getProfile

Fetches profile for a user ID.

```swift
func getProfile(userId: String) async throws -> UserProfile

// For current user or match profiles
```

#### uploadPhoto

Uploads photo to Supabase Storage.

```swift
func uploadPhoto(
    userId: String,
    imageData: Data,
    position: Int
) async throws -> UserPhoto

// Returns: UserPhoto with url, position, isPrimary
```

#### deletePhoto

Removes a photo.

```swift
func deletePhoto(photoId: String) async throws
```

#### updatePreferences

Updates dating preferences.

```swift
func updatePreferences(_ preferences: UserPreferences) async throws

// Usage
var prefs = currentPreferences
prefs.ageMin = 25
prefs.ageMax = 35
try await UserService.shared.updatePreferences(prefs)
```

#### setNeighborhoods

Sets preferred dating neighborhoods.

```swift
func setNeighborhoods(
    userId: String,
    neighborhoodIds: [String]
) async throws

// Usage
try await UserService.shared.setNeighborhoods(
    userId: user.id,
    neighborhoodIds: ["west_village", "williamsburg", "dumbo"]
)
```

---

## JulesService

AI conversation engine powered by Claude.

### Properties

```swift
class JulesService: ObservableObject {
    @Published var currentConversation: JulesConversation?
    @Published var messages: [JulesMessage]
    @Published var isTyping: Bool
}
```

### Methods

#### startConversation

Begins a new conversation with context.

```swift
func startConversation(
    userId: String,
    context: ConversationContext
) async throws -> JulesConversation

// Contexts: .onboarding, .general, .matchPitch, .scheduling, .feedback
```

#### sendMessage

Sends user message and gets Jules response.

```swift
func sendMessage(
    _ content: String,
    conversationId: String
) async throws -> JulesMessage

// Usage
let response = try await JulesService.shared.sendMessage(
    "Tell me more about her",
    conversationId: conversation.id
)

// Returns: Jules's response message
// Updates: isTyping during processing
```

#### presentMatch

Has Jules present a match to the user.

```swift
func presentMatch(
    _ match: ScoredMatch,
    to userId: String,
    isExploratory: Bool
) async throws -> [JulesMessage]

// Returns: Array of messages (teaser, details, card)
// Jules builds anticipation with multiple messages
```

#### collectFeedback

Post-date feedback conversation.

```swift
func collectFeedback(
    introId: String,
    userId: String
) async throws -> JulesConversation

// Starts: "so?? how'd it go with [name]?"
```

### Context Building

Jules context includes learned preferences:

```swift
struct JulesContext {
    var userId: String
    var stage: JulesStage
    var profile: UserProfile?
    var preferences: UserPreferences?
    var tasteProfile: UserTasteProfile?
    var strongPatterns: [PreferencePattern]?
    var recentSignals: [MatchSignal]?
    var isExploratoryMatch: Bool?
    var exploratoryHypothesis: String?

    // Computed summary for prompts
    var learnedPreferenceSummary: String
}
```

---

## PreferenceLearningService

Tracks and learns from user behavior.

### Methods

#### recordMatchDecision

Records every yes/no/pass decision.

```swift
func recordMatchDecision(
    userId: String,
    matchUserId: String,
    action: MatchAction,
    matchProfile: UserProfile,
    matchPhotos: [UserPhoto],
    timeToDecide: Int?,
    askedJulesFirst: Bool,
    priorityPassUsed: Bool
) async throws

// Actions: .accepted, .declined, .expired, .superLiked
// timeToDecide: Seconds from presentation to decision
```

#### recordPostDateSignal

Records feedback after dates (weighted 2x).

```swift
func recordPostDateSignal(
    userId: String,
    matchUserId: String,
    wantSecondDate: Bool,
    feedbackTags: [String],
    originalProfile: UserProfile
) async throws

// feedbackTags: ["great_conversation", "no_chemistry", etc.]
```

#### getPreferencesForMatching

Returns comprehensive preference data.

```swift
func getPreferencesForMatching(
    userId: String
) async throws -> MatchingPreferences

// Returns combined stated + learned preferences
```

#### recordExploratoryOutcome

Updates exploratory match results.

```swift
func recordExploratoryOutcome(
    matchId: String,
    outcome: ExploratoryOutcome,
    userId: String
) async throws

// Outcomes: .accepted, .declined, .superLiked, .secondDate
// Updates exploratory_success_rate
```

### Data Models

#### MatchingPreferences

```swift
struct MatchingPreferences {
    var stated: UserPreferences        // What they say they want
    var learned: UserTasteProfile?     // What behavior shows
    var strongPatterns: [PreferencePattern]
    var recentSignals: [MatchSignal]
    var shouldTryExploratory: Bool

    // Computed
    var dealbreakers: [String]         // Hard no's
    var strongPositives: [String]      // Instant yes patterns

    // Score modifier based on learned preferences
    func scoreModifier(for profile: MatchProfileSnapshot) -> Double
}
```

#### PreferencePattern

```swift
struct PreferencePattern {
    var category: PreferenceCategory   // physical, demographics, etc.
    var attribute: String              // "occupation_type"
    var value: String                  // "creative"
    var yesCount: Int
    var noCount: Int
    var totalExposures: Int
    var acceptanceRate: Double         // 0.0 to 1.0
    var strength: PatternStrength      // emerging → strong
}
```

---

## MatchingService

Smart match generation using learned preferences.

### Methods

#### generateMatches

Generates daily personalized matches.

```swift
func generateMatches(
    for userId: String,
    limit: Int = 3
) async throws -> [ScoredMatch]

// Returns: Array of scored matches
// Includes exploratory match if appropriate
```

### Scoring Algorithm

```swift
struct MatchScores {
    var statedPreferenceScore: Double    // 0-1
    var learnedPreferenceModifier: Double // 0.1-2.0
    var lifestyleScore: Double           // 0-1
    var neighborhoodScore: Double        // 0-1
    var activityScore: Double            // 0-1
}

// Total = weighted sum * learnedPreferenceModifier
```

### Match Result

```swift
struct ScoredMatch {
    let profile: UserProfile
    let photos: [UserPhoto]
    let totalScore: Double
    let scores: MatchScores
    let reasons: MatchReasons
    let isExploratory: Bool
    let exploratoryHypothesis: String?
}

struct MatchReasons {
    var headline: String           // "Sarah, Product Designer"
    var sharedInterests: [String]
    var lifestyleAlignment: [String]
    var whyJulesThinks: String     // Jules's reasoning
}
```

---

## External APIs

### Supabase

Database, auth, and storage via `supabase-swift` SDK.

```swift
// Client access
let supabase = SupabaseManager.shared

// Database queries
let profiles: [UserProfile] = try await supabase
    .from(.profiles)
    .select()
    .eq("user_id", value: userId)
    .execute()
    .value

// Storage
let url = try await supabase
    .storage(.avatars)
    .upload(path: "user123/photo1.jpg", data: imageData)
```

### Claude API (Anthropic)

AI responses for Jules personality.

```swift
// Request
struct AnthropicRequest: Codable {
    let model: String           // "claude-3-sonnet-20240229"
    let maxTokens: Int
    let system: String          // Jules personality prompt
    let messages: [[String: String]]
}

// Response
struct AnthropicResponse: Codable {
    let content: [ContentBlock]

    struct ContentBlock: Codable {
        let type: String
        let text: String
    }
}

// Usage in JulesService
let response = try await AnthropicAPI.shared.sendMessage(
    messages: messageHistory,
    systemPrompt: buildSystemPrompt(context: context)
)
```

### Twilio Verify

SMS OTP verification (configured in Supabase).

Supabase handles Twilio integration automatically when phone auth is configured. The app just calls `supabase.auth.signInWithOTP(phone:)`.

---

## Error Handling

### Common Errors

```swift
enum SupabaseError: LocalizedError {
    case notAuthenticated
    case notFound
    case invalidData
    case networkError(Error)
    case serverError(String)
    case unknown
}

enum AuthError: LocalizedError {
    case invalidPhone
    case invalidCode
    case expiredCode
    case rateLimited
    case networkError
}

enum JulesError: LocalizedError {
    case noConversation
    case apiError(String)
    case contextBuildFailed
}
```

### Error Recovery

```swift
// Retry with exponential backoff
func withRetry<T>(
    maxAttempts: Int = 3,
    delay: TimeInterval = 1.0,
    operation: () async throws -> T
) async throws -> T {
    var lastError: Error?
    for attempt in 1...maxAttempts {
        do {
            return try await operation()
        } catch {
            lastError = error
            if attempt < maxAttempts {
                try await Task.sleep(nanoseconds: UInt64(delay * pow(2, Double(attempt - 1)) * 1_000_000_000))
            }
        }
    }
    throw lastError!
}
```

---

## Configuration

### Config.swift

```swift
enum Config {
    // Supabase
    static let supabaseURL = "https://xxx.supabase.co"
    static let supabaseAnonKey = "eyJ..."

    // Anthropic
    static let anthropicAPIKey = "sk-ant-..."
    static let anthropicModel = "claude-3-sonnet-20240229"

    // Twilio (configured in Supabase)
    static let twilioAccountSID = "AC..."
    static let twilioAuthToken = "..."
    static let twilioVerifyServiceSID = "VA..."
}
```

### Environment Variables

For production, use environment variables or secure storage instead of hardcoded values.

---

## Rate Limits

| API | Limit | Notes |
|-----|-------|-------|
| Supabase | 500 req/sec | Per project |
| Claude API | 60 req/min | Tier 1 |
| Twilio Verify | 5 OTP/phone/10min | Anti-fraud |

### Handling Rate Limits

```swift
// Check for rate limit response
if response.statusCode == 429 {
    let retryAfter = response.headers["Retry-After"]
    // Wait and retry
}
```
