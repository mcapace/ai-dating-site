# Project Jules iOS - Setup Instructions

## Prerequisites
- Xcode 14.0 or later
- CocoaPods (for dependencies) or Swift Package Manager
- Supabase account
- Anthropic API key
- Twilio account (for SMS)

## Step 1: Create Xcode Project

1. Open Xcode
2. Create a new project:
   - Choose "iOS" → "App"
   - Product Name: `ProjectJules`
   - Interface: SwiftUI
   - Language: Swift
   - Storage: None (we'll use Supabase)

3. Save the project in the `ios/` directory

## Step 2: Add Custom Fonts

1. Download fonts:
   - Playfair Display: https://fonts.google.com/specimen/Playfair+Display
   - Inter: https://fonts.google.com/specimen/Inter

2. Add fonts to Xcode:
   - Drag font files into the project navigator
   - Select "Copy items if needed"
   - Add to target: ProjectJules

3. Add to Info.plist:
   ```xml
   <key>UIAppFonts</key>
   <array>
       <string>PlayfairDisplay-Regular.ttf</string>
       <string>PlayfairDisplay-Bold.ttf</string>
       <string>Inter-Regular.ttf</string>
       <string>Inter-Medium.ttf</string>
       <string>Inter-SemiBold.ttf</string>
       <string>Inter-Bold.ttf</string>
   </array>
   ```

## Step 3: Configure Environment Variables

1. Create `Config.xcconfig` (see `Config.xcconfig.example`)
2. Add your API keys:
   - Supabase URL and anon key
   - Anthropic API key
   - Twilio credentials (if needed)

3. Add `Config.xcconfig` to your Xcode project
4. Add to Build Settings → Configurations → Debug/Release

## Step 4: Install Dependencies

### Using Swift Package Manager:

Add these packages in Xcode:
- `https://github.com/supabase/supabase-swift` (Supabase client)
- `https://github.com/airbnb/lottie-ios` (Lottie animations)

### Or using CocoaPods:

Create `Podfile`:
```ruby
platform :ios, '16.0'
use_frameworks!

target 'ProjectJules' do
  pod 'Supabase'
  pod 'lottie-ios'
end
```

Run `pod install`

## Step 5: Set Up Supabase Database

1. Run the SQL schema from `supabase/schema.sql`
2. Enable Row Level Security (RLS) policies
3. Set up Storage buckets for user photos
4. Configure Auth settings for phone authentication

## Step 6: Add Lottie Animations

1. Have designer create animations per specs
2. Add `.json` files to `Assets/Lottie/` folder
3. Reference in code using `LottieView`

## Step 7: Project Structure

Ensure your project follows this structure:
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
└── Assets/
    ├── Fonts/
    └── Lottie/
```

## Step 8: Build and Run

1. Select your development team in Signing & Capabilities
2. Choose a simulator or connected device
3. Build and run (⌘R)

## Troubleshooting

- **Fonts not loading**: Check Info.plist and ensure fonts are added to target
- **Supabase connection issues**: Verify URL and keys in Config.xcconfig
- **API errors**: Check API key permissions and rate limits
- **Build errors**: Ensure all dependencies are properly installed

