# Project Jules - Setup Guide

## Prerequisites

- Xcode 15.0+
- iOS 17.0+ deployment target
- Apple Developer Account
- Supabase account
- Anthropic API account
- Twilio account (for SMS verification)

## 1. Xcode Project Setup

### Create New Project
1. Open Xcode → File → New → Project
2. Select "iOS App"
3. Configure:
   - Product Name: `ProjectJules`
   - Team: Your developer team
   - Organization Identifier: `com.yourname`
   - Interface: SwiftUI
   - Language: Swift
   - Storage: None
   - Uncheck "Include Tests" for now

### Add Source Files
1. Delete the default `ContentView.swift`
2. Drag the following folders into your Xcode project:
   - `App/`
   - `Config/`
   - `DesignSystem/`
   - `Models/`
   - `Services/`
   - `Views/`
3. Select "Create groups" when prompted

### Add Swift Package Dependencies
Go to File → Add Package Dependencies and add:

```
https://github.com/supabase/supabase-swift
```
- Package: `Supabase`
- Add to target: `ProjectJules`

## 2. Font Setup

### Download Fonts
1. **Playfair Display**: https://fonts.google.com/specimen/Playfair+Display
   - Download: Regular (400), SemiBold (600)
2. **Inter**: https://fonts.google.com/specimen/Inter
   - Download: Regular (400), Medium (500), SemiBold (600)

### Add to Project
1. Create a `Fonts` folder in your project
2. Drag font files into the folder
3. Ensure "Add to target" is checked

### Update Info.plist
Add the following to your `Info.plist`:

```xml
<key>UIAppFonts</key>
<array>
    <string>PlayfairDisplay-Regular.ttf</string>
    <string>PlayfairDisplay-SemiBold.ttf</string>
    <string>Inter-Regular.ttf</string>
    <string>Inter-Medium.ttf</string>
    <string>Inter-SemiBold.ttf</string>
</array>
```

## 3. Supabase Setup

### Create Project
1. Go to https://supabase.com and create a new project
2. Note your project URL and anon key

### Run Database Schema
1. Go to SQL Editor in your Supabase dashboard
2. Copy contents of `Database/schema.sql`
3. Run the query

### Setup Storage Buckets
1. Go to Storage in your Supabase dashboard
2. Create bucket: `avatars` (public)
3. Create bucket: `voice-notes` (private)
4. Run `Database/storage-setup.sql` in SQL Editor

### Enable Phone Auth
1. Go to Authentication → Providers
2. Enable "Phone" provider
3. Configure Twilio:
   - Account SID
   - Auth Token
   - Message Service SID (or phone number)

### Get Credentials
Copy from Project Settings → API:
- Project URL → `Config.supabaseURL`
- `anon` public key → `Config.supabaseAnonKey`

## 4. Anthropic Setup

1. Go to https://console.anthropic.com
2. Create an API key
3. Copy to `Config.anthropicAPIKey`

## 5. Update Config.swift

Replace placeholders in `Config/Config.swift`:

```swift
static let supabaseURL = "https://xxxxx.supabase.co"
static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIs..."
static let anthropicAPIKey = "sk-ant-..."
```

## 6. Build & Run

1. Select your target device/simulator
2. Build: Cmd + B
3. Run: Cmd + R

## Project Structure

```
ProjectJules/
├── App/
│   └── ProjectJulesApp.swift          # App entry point
├── Config/
│   └── Config.swift                    # Configuration
├── Database/
│   ├── schema.sql                      # Database schema
│   └── storage-setup.sql               # Storage policies
├── DesignSystem/
│   ├── Colors.swift                    # Color palette
│   ├── Typography.swift                # Font styles
│   ├── Spacing.swift                   # Layout constants
│   └── Components/
│       ├── JulesButton.swift           # Button system
│       ├── JulesCard.swift             # Card components
│       ├── JulesChat.swift             # Chat UI
│       └── JulesInput.swift            # Form inputs
├── Models/
│   ├── User.swift                      # User models
│   ├── Match.swift                     # Match models
│   ├── Venue.swift                     # Venue models
│   └── JulesConversation.swift         # AI conversation
├── Services/
│   ├── SupabaseClient.swift            # Supabase setup
│   ├── AuthService.swift               # Authentication
│   ├── UserService.swift               # User data
│   └── JulesService.swift              # AI service
└── Views/
    ├── Main/
    │   ├── MainTabView.swift           # Tab navigation
    │   └── SplashView.swift            # Splash screen
    ├── Onboarding/
    │   ├── OnboardingFlowView.swift    # Flow container
    │   ├── WelcomeView.swift           # Welcome screen
    │   ├── PhoneInputView.swift        # Phone auth
    │   ├── BasicInfoView.swift         # Profile basics
    │   ├── LookingForView.swift        # Preferences
    │   ├── PhotosView.swift            # Photo upload
    │   ├── NeighborhoodsView.swift     # Location
    │   └── MeetJulesView.swift         # Jules intro
    ├── Match/
    │   └── MatchProfileView.swift      # Profile view
    ├── Intros/
    │   └── IntroDetailView.swift       # Intro detail
    └── Settings/
        ├── EditProfileView.swift        # Edit profile
        ├── EditPreferencesView.swift    # Edit prefs
        ├── EditNeighborhoodsView.swift  # Edit areas
        ├── SubscriptionView.swift       # Subscription
        └── SupportViews.swift           # Help screens
```

## Troubleshooting

### Fonts Not Loading
- Ensure fonts are added to target (check file inspector)
- Verify `UIAppFonts` in Info.plist matches exact filenames
- Clean build folder: Cmd + Shift + K

### Supabase Connection Issues
- Verify URL doesn't have trailing slash
- Check anon key is the public one (not service role)
- Ensure RLS policies are set up

### Build Errors
- Check Swift package resolved correctly
- Ensure iOS deployment target is 17.0+
- Clean derived data if needed

## Next Steps

After basic setup:
1. Add Lottie animations (placeholder views ready)
2. Implement StoreKit for subscriptions
3. Add push notifications
4. Create App Store assets
5. Set up analytics (optional)

## Support

For questions, contact support@projectjules.app

