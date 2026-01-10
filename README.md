# Project Jules

**AI-powered dating app for NYC** - Competing with Amata through superior UX and smarter matching.

## What is Jules?

Jules is not a dating app with an AI feature. Jules IS the matchmaker - a warm, witty best friend who lives in your phone and is weirdly good at setting people up.

### Key Differentiators from Amata

| Feature | Amata | Jules |
|---------|-------|-------|
| AI Personality | Generic chatbot | Best friend who texts like a real person |
| Matching | Basic preferences | Learns from behavior over time |
| Communication | Corporate tone | "ok so I might have found someone" |
| Learning | Static | Every yes/no teaches Jules something |
| Exploration | Only stated preferences | Tests outside your type sometimes |

## Core Philosophy

**No browsing. No swiping.** Jules recommends matches based on:
1. What you tell Jules you want
2. What your behavior shows you actually respond to
3. Occasional exploratory matches to expand your horizons

## Tech Stack

- **iOS App**: Swift/SwiftUI with MVVM architecture
- **Backend**: Supabase (PostgreSQL + Auth + Realtime + Storage)
- **AI**: Claude API (Anthropic) for Jules personality
- **SMS**: Twilio Verify for phone OTP authentication
- **Payments**: StoreKit for subscriptions

## Documentation

| Document | Description |
|----------|-------------|
| [User Flows](docs/USER_FLOWS.md) | Complete user journey diagrams |
| [Database Schema](docs/DATABASE_SCHEMA.md) | Full PostgreSQL schema |
| [UX Guidelines](docs/UX_GUIDELINES.md) | Design system & Jules personality |
| [API Reference](docs/API_REFERENCE.md) | Service interfaces |
| [Cursor Instructions](CURSOR_INSTRUCTIONS.md) | Implementation guide for AI coding |

## Project Structure

```
ProjectJules/
├── App/
│   └── ProjectJulesApp.swift       # App entry point
├── Config/
│   └── Config.swift                # API keys & environment
├── Models/
│   ├── User.swift                  # User, Profile, Preferences, Learning models
│   ├── Match.swift                 # Match, Intro, SparkExchange models
│   ├── Venue.swift                 # Venue & date location models
│   └── JulesConversation.swift     # Chat & message models
├── Services/
│   ├── SupabaseClient.swift        # Database client
│   ├── AuthService.swift           # Phone auth with Twilio
│   ├── UserService.swift           # Profile management
│   ├── JulesService.swift          # AI conversation engine
│   ├── PreferenceLearningService.swift  # Behavioral learning
│   └── MatchingService.swift       # Smart match generation
├── Views/
│   ├── Onboarding/                 # Sign up & Jules intro
│   ├── Main/                       # Tab navigation
│   ├── Jules/                      # Chat interface
│   ├── Match/                      # Match presentation
│   ├── Intros/                     # Active matches
│   └── Settings/                   # Profile & preferences
└── Design/
    ├── Colors.swift                # Color palette
    ├── Typography.swift            # Font system
    └── Components/                 # Reusable UI components
```

## Pricing Tiers

| Tier | Monthly | Per Date | Tokens/Month | Features |
|------|---------|----------|--------------|----------|
| **Explorer** | Free | $15 | 0 | Basic matching, Spark Exchange |
| **Member** | $29 | $8 | 1 Priority Pass | Voice notes, venue preferences |
| **Unlimited** | $79 | $0 | 3 Priority Passes | All features, premium venues |

## Getting Started

### Prerequisites
- Xcode 15+
- iOS 17+ deployment target
- Supabase account
- Anthropic API key
- Twilio account (for SMS)

### Setup

1. Clone the repository
2. Copy `Config.swift.example` to `Config.swift`
3. Add your API keys:
   ```swift
   enum Config {
       static let supabaseURL = "your-supabase-url"
       static let supabaseAnonKey = "your-anon-key"
       static let anthropicAPIKey = "your-anthropic-key"
       static let twilioAccountSID = "your-twilio-sid"
       static let twilioAuthToken = "your-twilio-token"
   }
   ```
4. Run the database migrations in Supabase
5. Build and run in Xcode

## Key Features

### Jules AI Personality
- Texts like a real best friend, not a chatbot
- Uses "lol", "honestly", "ok but" naturally
- Has opinions and shares them
- Remembers everything
- Calls out self-sabotage gently

### Preference Learning
- Tracks every yes/no decision
- Measures decision speed (quick yes = strong interest)
- Identifies dealbreakers (< 10% acceptance)
- Identifies super attractions (> 90% acceptance)
- Post-date feedback weighted 2x

### Smart Matching
- Combines stated + learned preferences
- Neighborhood overlap scoring
- Activity level matching
- Exploratory matches to break patterns

### Priority Pass
- Signal strong interest
- Recipient sees "Someone used their Priority Pass on you"
- Can gift to friends (referral mechanic)

## License

Proprietary - All rights reserved
