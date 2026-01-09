# Project Jules - AI-Powered Dating App

An iOS dating app that uses AI (Claude) to facilitate meaningful connections through personalized introductions and curated date experiences.

## Project Structure

### iOS App (`ios/`)
- **App/**: Main app entry point and routing
- **DesignSystem/**: Reusable UI components (buttons, cards, inputs, chat)
- **Models/**: Data models (User, Match, Venue, Conversation)
- **Services/**: Business logic (Auth, User, Jules AI, Supabase)
- **Views/**: Screen components (Onboarding, Main, Match, Intros, Settings)

### Backend (`supabase/`)
- **schema.sql**: Database schema with tables, indexes, and RLS policies
- **storage-setup.sql**: Storage bucket configuration for user photos

## Quick Start

### Prerequisites
- Xcode 14.0+
- Supabase account
- Anthropic API key
- Twilio account (for SMS)

### Setup Steps

1. **Create Xcode Project**
   ```bash
   cd ios
   ./create-xcode-project.sh
   ```
   Then open Xcode and create a new iOS App project.

2. **Configure Environment**
   - Copy `Config.xcconfig.example` to `Config.xcconfig`
   - Add your API keys (Supabase, Anthropic, Twilio)

3. **Install Dependencies**
   - Using Swift Package Manager: Add Supabase and Lottie packages in Xcode
   - Or using CocoaPods: Copy `Podfile.example` to `Podfile` and run `pod install`

4. **Set Up Database**
   - Run `supabase/schema.sql` in Supabase SQL Editor
   - Run `supabase/storage-setup.sql` for photo storage

5. **Add Assets**
   - Download Playfair Display and Inter fonts
   - Add fonts to `Assets/Fonts/` and update `Info.plist`
   - Add Lottie animations to `Assets/Lottie/`

6. **Build & Run**
   - Open project in Xcode
   - Select development team
   - Build and run (⌘R)

## Detailed Setup

See [ios/SETUP.md](ios/SETUP.md) for comprehensive setup instructions.

## Features

- **AI-Powered Introductions**: Claude AI creates personalized introductions between matches
- **Spark Exchange**: Initial interest system (like, super like, pass)
- **Curated Dates**: AI-suggested venues and date planning
- **Learning System**: App learns from user interactions to improve matches
- **Neighborhood-Based**: Match with people in your preferred neighborhoods

## Tech Stack

- **Frontend**: SwiftUI (iOS 16+)
- **Backend**: Supabase (PostgreSQL + Auth + Storage)
- **AI**: Anthropic Claude API
- **SMS**: Twilio
- **Animations**: Lottie

## Development Status

✅ Core app structure complete (33 files, 10,306 lines)
🔄 Next: Xcode project setup, API configuration, database initialization

## License

[Add your license here]
