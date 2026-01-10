# Project Jules - Implementation Instructions for Cursor

## Overview
AI-powered dating app competing with Amata in NYC. No browsing - all matches come from Jules AI.

## Core UX Philosophy: Jules = Your Best Friend

**Jules is NOT a chatbot or AI assistant.** Jules is your matchmaking best friend who happens to live in your phone.

### How Jules Texts
```
❌ "I'm here to help you find meaningful connections!"
✅ "ok so I might have found someone"

❌ "Based on your preferences, I've identified a compatible match."
✅ "wait. this girl literally mentioned the same obscure band you're obsessed with"

❌ "How was your date? I'd love to hear your feedback!"
✅ "so?? how'd it go with Maya??"

❌ "I understand that can be frustrating."
✅ "ugh that's annoying"
```

### Jules Personality Traits
- Uses "lol", "honestly", "ok but", "wait" naturally
- Sends multiple short texts instead of paragraphs
- Has real opinions and shares them
- Remembers everything and references past convos
- Celebrates wins, commiserates on bad dates
- Gently calls out self-sabotage
- Never sounds like a customer service rep

## Architecture
- **Frontend**: Swift/SwiftUI iOS app
- **Backend**: Supabase (PostgreSQL + Auth + Storage)
- **AI**: Claude API (Anthropic) for Jules matchmaker
- **SMS**: Twilio Verify for phone OTP

## Current Status
✅ Project structure complete
✅ Models defined (User, Match, Venue, JulesConversation)
✅ Services created (Supabase, Auth, User, Jules)
✅ Views scaffolded (Onboarding, Main, Match, Settings)
✅ Database schema ready
✅ Twilio SMS integration configured

## Pricing Model

### Three Tiers
```swift
enum SubscriptionTier: String, Codable {
    case explorer  // Free, $15/date, 0 tokens
    case member    // $29/mo, $8/date, 1 token/mo
    case unlimited // $79/mo, $0/date, 3 tokens/mo
}
```

### Date Credits System
- Explorer users pay per date
- Member users get reduced rates
- Unlimited users have no per-date cost

## Priority Pass Implementation

### Add to User.swift
```swift
struct UserTokens: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    var priorityPasses: Int
    var dateCredits: Int
    var lastRefreshed: Date
    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case priorityPasses = "priority_passes"
        case dateCredits = "date_credits"
        case lastRefreshed = "last_refreshed"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

### Add to SupabaseClient.swift Table enum
```swift
case userTokens = "user_tokens"
case priorityPassUsage = "priority_pass_usage"
```

### Database Migration (add to schema.sql)
```sql
-- User tokens/credits
CREATE TABLE user_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    priority_passes INT DEFAULT 0,
    date_credits INT DEFAULT 0,
    last_refreshed TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Priority pass usage tracking
CREATE TABLE priority_pass_usage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    to_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    used_at TIMESTAMPTZ DEFAULT NOW(),
    resulted_in_match BOOLEAN DEFAULT FALSE
);

-- RLS policies
ALTER TABLE user_tokens ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own tokens" ON user_tokens
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own tokens" ON user_tokens
    FOR UPDATE USING (auth.uid() = user_id);

ALTER TABLE priority_pass_usage ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own pass usage" ON priority_pass_usage
    FOR SELECT USING (auth.uid() = from_user_id OR auth.uid() = to_user_id);
```

## Match Delivery System

### Daily Match Generation (Backend/Edge Function)
Jules should run a daily matching algorithm:

1. **Scoring Factors**:
   - Stated preferences alignment (age, gender, children)
   - Learned preferences from feedback
   - Neighborhood overlap
   - Communication style compatibility
   - Activity level matching

2. **Match Limits by Tier**:
   - Explorer: 1 match/day
   - Member: 2 matches/day
   - Unlimited: 3 matches/day

3. **Priority Pass Boost**:
   - Users who received Priority Passes appear first
   - Jules mentions "Someone used their Priority Pass on you"

### Add to Match.swift
```swift
struct MatchQueue: Codable, Identifiable {
    let id: String
    let userId: String
    let matchUserId: String
    var status: MatchQueueStatus
    var priorityPassUsed: Bool
    var presentedAt: Date?
    var respondedAt: Date?
    var response: MatchResponse?
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case matchUserId = "match_user_id"
        case status
        case priorityPassUsed = "priority_pass_used"
        case presentedAt = "presented_at"
        case respondedAt = "responded_at"
        case response
        case createdAt = "created_at"
    }
}

enum MatchQueueStatus: String, Codable {
    case pending      // In queue, not yet shown
    case presented    // Shown to user, awaiting response
    case accepted     // User said yes
    case passed       // User said no
    case expired      // Timed out
}

enum MatchResponse: String, Codable {
    case interested
    case pass
    case askJules  // User wants more info from Jules
}
```

## Voice Notes in Spark Exchange

### Add to SparkExchange model
```swift
struct SparkResponse: Codable, Identifiable, Equatable {
    let id: String
    let matchId: String
    let userId: String
    var promptId: String
    var textResponse: String?
    var voiceNoteURL: String?  // NEW: Optional voice note
    var voiceNoteDuration: Int? // NEW: Duration in seconds
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case matchId = "match_id"
        case userId = "user_id"
        case promptId = "prompt_id"
        case textResponse = "text_response"
        case voiceNoteURL = "voice_note_url"
        case voiceNoteDuration = "voice_note_duration"
        case createdAt = "created_at"
    }
}
```

### Voice Note Limits
- Explorer: Text only
- Member: 30-second voice notes
- Unlimited: 60-second voice notes

## Venue Swap Feature

Allow users to suggest alternative venues:

### Add to Match.swift or create Venue.swift additions
```swift
struct VenueSwapRequest: Codable, Identifiable {
    let id: String
    let matchId: String
    let requestedById: String
    var originalVenueId: String
    var suggestedVenueId: String
    var reason: String?
    var status: SwapStatus
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case matchId = "match_id"
        case requestedById = "requested_by_id"
        case originalVenueId = "original_venue_id"
        case suggestedVenueId = "suggested_venue_id"
        case reason
        case status
        case createdAt = "created_at"
    }
}

enum SwapStatus: String, Codable {
    case pending
    case accepted
    case declined
    case expired
}
```

## Jules AI Enhancement

### Update JulesService.swift buildSystemPrompt
The system prompt should include:
1. User's learned preferences from past feedback
2. Communication style adaptation
3. Priority Pass awareness
4. Subscription tier context

### Key Jules Behaviors
- **For Priority Pass matches**: "Someone used their Priority Pass on you - they're really interested!"
- **For recurring patterns**: "I've noticed you tend to connect with people who..."
- **Post-date feedback**: "How did it go with [name]? Your feedback helps me find better matches"

## StoreKit Integration (TODO)

### Create PurchaseService.swift
```swift
import StoreKit

class PurchaseService: ObservableObject {
    static let shared = PurchaseService()

    @Published var products: [Product] = []
    @Published var purchasedSubscription: Product?

    // Product IDs
    enum ProductID: String {
        case memberMonthly = "com.projectjules.member.monthly"
        case unlimitedMonthly = "com.projectjules.unlimited.monthly"
        case dateCredit = "com.projectjules.datecredit"
        case priorityPass = "com.projectjules.prioritypass"
    }

    func loadProducts() async {
        // Load from App Store Connect
    }

    func purchase(_ product: Product) async throws {
        // Handle purchase
    }

    func refreshSubscriptionStatus() async {
        // Check entitlements
    }
}
```

## Push Notifications

### Notification Types
1. **New Match**: "Jules found someone for you!"
2. **Priority Pass Received**: "Someone used their Priority Pass on you 💫"
3. **Spark Response**: "[Name] responded to your Spark"
4. **Date Confirmed**: "Your date with [Name] is confirmed for [date]"
5. **Date Reminder**: "Your date with [Name] is tomorrow at [time]"

## Next Implementation Steps

1. **Add UserTokens model and service**
2. **Create MatchQueue system**
3. **Implement Priority Pass logic**
4. **Add voice note recording/playback**
5. **Build venue swap UI**
6. **Integrate StoreKit for purchases**
7. **Set up push notifications**

## Testing Checklist
- [ ] Phone OTP flow works end-to-end
- [ ] Profile creation saves to Supabase
- [ ] Photo upload works
- [ ] Jules conversation persists
- [ ] Match presentation displays correctly
- [ ] Spark exchange timer works
- [ ] Voice notes record and play (Member+)
- [ ] Priority Pass deduction works
- [ ] Date credits charge correctly
- [ ] Subscription status reflects correctly
