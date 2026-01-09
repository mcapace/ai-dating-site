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
<<<<<<< Updated upstream
=======

>>>>>>> Stashed changes
1. Open Xcode → File → New → Project
2. Select "iOS App"
3. Configure:
   - Product Name: `ProjectJules`
   - Team: Your developer team
   - Organization Identifier: `com.yourname`
<<<<<<< Updated upstream
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
=======
   - Bundle Identifier: `com.yourname.projectjules`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: None (we'll use Supabase)
4. Save the project in the `ProjectJules/` directory (at the root level, not inside `ios/`)

### Project Structure

After creating the project, organize your files into these groups in Xcode:

```
ProjectJules/
├── App/
│   └── ProjectJulesApp.swift
├── DesignSystem/
│   ├── Colors.swift
│   ├── Typography.swift
│   ├── Spacing.swift
│   ├── JulesButton.swift
│   ├── JulesCard.swift
│   ├── JulesInput.swift
│   └── JulesChat.swift
├── Models/
│   ├── User.swift
│   ├── Match.swift
│   ├── Venue.swift
│   └── JulesConversation.swift
├── Services/
│   ├── SupabaseClient.swift
│   ├── AuthService.swift
│   ├── UserService.swift
│   └── JulesService.swift
├── Views/
│   ├── Onboarding/
│   ├── Main/
│   ├── Match/
│   ├── Intros/
│   └── Settings/
├── Config/
│   └── Config.swift
├── Assets/
│   ├── Fonts/
│   ├── Lottie/
│   └── Images/
└── Resources/
    └── Info.plist
```

**To organize in Xcode:**
1. Right-click on the project in Navigator
2. Select "New Group" for each folder
3. Drag your Swift files into the appropriate groups
4. Ensure "Copy items if needed" is checked when adding files

## 2. Add Swift Package Dependencies

### Add Supabase Package

1. In Xcode, go to **File → Add Package Dependencies...**
2. Enter the URL: `https://github.com/supabase/supabase-swift`
3. Click "Add Package"
4. Select the `Supabase` product and add it to your `ProjectJules` target
5. Click "Add Package"

### Add Lottie (Optional, for animations)

1. Go to **File → Add Package Dependencies...**
2. Enter: `https://github.com/airbnb/lottie-spm`
3. Add the `Lottie` product to your target

## 3. Configure Info.plist

### Add Custom Fonts

1. Open `Info.plist` (or create one if using SwiftUI app lifecycle)
2. Add the following keys:
>>>>>>> Stashed changes

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

<<<<<<< Updated upstream
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
=======
### Add Privacy Descriptions

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Jules needs access to your photos to set up your profile.</string>
<key>NSCameraUsageDescription</key>
<string>Jules needs access to your camera to take profile photos.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Jules uses your location to find matches and suggest nearby venues.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Jules needs access to your microphone to record voice notes.</string>
```

## 4. Add Custom Fonts

### Download Fonts

1. **Playfair Display**: https://fonts.google.com/specimen/Playfair+Display
   - Download: Regular and SemiBold weights
2. **Inter**: https://fonts.google.com/specimen/Inter
   - Download: Regular, Medium, and SemiBold weights

### Add to Xcode

1. Create a group called "Fonts" in your Assets folder
2. Drag the `.ttf` font files into the Fonts group
3. Check "Copy items if needed"
4. Ensure the fonts are added to the `ProjectJules` target
5. Verify in `Info.plist` that all font names are listed

## 5. Configure API Credentials

1. Open `Config/Config.swift`
2. Replace the placeholder values:
   - `YOUR_PROJECT_ID` → Your Supabase project ID
   - `YOUR_SUPABASE_ANON_KEY` → Your Supabase anon key
   - `YOUR_ANTHROPIC_API_KEY` → Your Anthropic API key
   - Update Twilio credentials if using SMS

### Get Supabase Credentials

1. Go to your Supabase project dashboard
2. Navigate to Settings → API
3. Copy:
   - Project URL (e.g., `https://xxxxx.supabase.co`)
   - `anon` `public` key

### Get Anthropic API Key

1. Go to https://console.anthropic.com/
2. Navigate to API Keys
3. Create a new API key
4. Copy the key (starts with `sk-ant-...`)

## 6. Set Up Supabase Database

### Run Schema

1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Open `ProjectJules/Database/schema.sql`
4. Copy and paste the entire SQL into the editor
5. Click "Run" to execute

### Set Up Storage Buckets

1. Go to Storage in Supabase dashboard
2. Create two buckets:
   - **avatars** (public)
   - **voice-notes** (private)
3. Go back to SQL Editor
4. Run `ProjectJules/Database/storage-setup.sql`

### Verify Setup

Run this query to verify tables were created:

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

You should see: `users`, `user_profiles`, `user_preferences`, `matches`, `intros`, etc.

## 7. Build Settings

### Set Deployment Target

1. Select your project in Navigator
2. Select the `ProjectJules` target
3. Go to "General" tab
4. Set "Minimum Deployments" to **iOS 17.0**

### Configure Signing

1. Go to "Signing & Capabilities" tab
2. Select your development team
3. Xcode will automatically create a provisioning profile

## 8. Build and Run

1. Select a simulator (iPhone 15 Pro recommended)
2. Press **⌘R** to build and run
3. The app should launch on the simulator
>>>>>>> Stashed changes

## Troubleshooting

### Fonts Not Loading
<<<<<<< Updated upstream
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
=======

- Verify font files are in the project and added to target
- Check `Info.plist` has correct font names (case-sensitive)
- Clean build folder: **Product → Clean Build Folder (⇧⌘K)**
- Delete derived data if issues persist

### Supabase Connection Errors

- Verify `Config.swift` has correct URL and key
- Check Supabase project is active
- Verify network connectivity
- Check Supabase dashboard for API status

### Package Dependencies Issues

- Go to **File → Packages → Reset Package Caches**
- Then **File → Packages → Resolve Package Versions**
- Clean build folder and rebuild

### Build Errors

- Ensure all Swift files are added to the target
- Check for missing imports
- Verify deployment target matches package requirements
- Check Xcode version compatibility (15.0+)

### Database Errors

- Verify schema was run successfully
- Check RLS policies are enabled
- Verify user authentication is working
- Check Supabase logs for errors

## Next Steps

After setup is complete:

1. ✅ Test authentication flow
2. ✅ Verify Supabase connection
3. ✅ Test photo upload to storage
4. ✅ Test AI conversation with Claude
5. ✅ Add Lottie animations (see `Assets/Lottie/ANIMATION_SPECS.md`)

## Support

For issues or questions:
- Check Supabase documentation: https://supabase.com/docs
- Check Anthropic documentation: https://docs.anthropic.com
- Review SwiftUI documentation: https://developer.apple.com/documentation/swiftui

>>>>>>> Stashed changes
