# Project Jules - iOS Dating App

AI-powered dating app built with SwiftUI, Supabase, and Claude AI.

## 📋 Tech Stack

### Frontend
- **Framework**: SwiftUI (iOS 17.0+)
- **Language**: Swift 5.9
- **Xcode**: 15.0+
- **Project Generator**: xcodegen
- **Package Manager**: Swift Package Manager (SPM)

### Backend
- **Database**: PostgreSQL (via Supabase)
- **Backend Platform**: Supabase
- **Authentication**: Supabase Auth (Phone/OTP via Twilio SMS)
- **Storage**: Supabase Storage (avatars, voice notes)
- **API**: Supabase REST API

### AI Integration
- **Provider**: Anthropic Claude API
- **Model**: `claude-sonnet-4-20250514`
- **Service**: `JulesService.swift` - AI-powered match introductions and date planning

### Design System
- **Fonts**: 
  - Playfair Display (SemiBold, Regular) - Headlines
  - Inter (Regular, Medium, SemiBold) - Body text
- **Colors**: Custom brand palette (julCream, julTerracotta, julSage, etc.)
- **Components**: Custom SwiftUI components (JulesButton, JulesCard, JulesInput, etc.)

## 🏗️ Architecture

### Pattern: MVVM (Model-View-ViewModel)
- **Models**: Data structures (`User.swift`, `Match.swift`, `Venue.swift`, etc.)
- **Views**: SwiftUI views (`Views/` directory)
- **ViewModels**: Observable classes for state management
- **Services**: Business logic layer (`Services/` directory)

### Project Structure
```
ProjectJules/
├── App/
│   └── ProjectJulesApp.swift       # Main app entry, routing
├── DesignSystem/
│   ├── Colors.swift                # Brand color palette
│   ├── Typography.swift            # Font system
│   ├── Spacing.swift               # Spacing scale, radii, shadows
│   ├── JulesButton.swift           # Button components
│   ├── JulesCard.swift             # Card components, FlowLayout
│   ├── JulesInput.swift            # Input components (text, phone, OTP)
│   └── JulesChat.swift             # Chat components
├── Models/
│   ├── User.swift                  # User, profile, preferences, photos
│   ├── Match.swift                 # Match, intro, spark exchange, dates
│   ├── Venue.swift                 # Venues, neighborhoods
│   └── JulesConversation.swift     # AI conversation models
├── Services/
│   ├── SupabaseClient.swift        # Supabase client singleton
│   ├── AuthService.swift           # Authentication (phone/OTP)
│   ├── UserService.swift           # User profile & preferences
│   └── JulesService.swift          # Claude AI integration
├── Views/
│   ├── Main/                       # Main app views
│   ├── Onboarding/                 # Onboarding flow
│   ├── Match/                      # Match views
│   ├── Intros/                     # Introduction views
│   └── Settings/                   # Settings views
├── Config/
│   └── Config.swift                # API keys & configuration
├── Assets/
│   └── Fonts/                      # Custom fonts
├── Database/
│   ├── schema.sql                  # Database schema
│   └── storage-setup.sql           # Storage policies
└── supabase/
    └── migrations/                 # Supabase migrations
```

## 🚀 Build Process

### Prerequisites
1. **Xcode 15.0+** installed
2. **xcodegen** installed: `brew install xcodegen`
3. **Apple Developer Account** (for signing)
4. **Supabase Account** - [Get credentials](https://supabase.com/dashboard)
5. **Anthropic API Key** - [Get key](https://console.anthropic.com/)

### Quick Start

#### 1. Clone & Setup
```bash
cd ProjectJules

# Generate Xcode project
xcodegen generate

# Open in Xcode
open ProjectJules.xcodeproj
```

#### 2. Configure API Keys
Edit `Config/Config.swift`:
```swift
static let supabaseURL = "https://YOUR_PROJECT.supabase.co"
static let supabaseAnonKey = "YOUR_ANON_KEY"
static let anthropicAPIKey = "YOUR_ANTHROPIC_KEY"
```

#### 3. Add Fonts to Xcode
1. Open Xcode
2. Right-click `ProjectJules` → "Add Files to 'ProjectJules'..."
3. Navigate to `Assets/Fonts/`
4. Select all 5 font files
5. Check "Copy items if needed" and "Create groups"
6. Verify in Build Phases → Copy Bundle Resources

#### 4. Setup Database
Run in Supabase SQL Editor:
- `Database/schema.sql` - Creates all tables, RLS policies, indexes
- `storage-setup.sql` - Creates storage buckets and policies

Or use migrations:
```bash
# If you have Supabase CLI set up
supabase db push
```

#### 5. Build & Run
1. Select development team in Xcode (Signing & Capabilities)
2. Select simulator (e.g., iPhone 15 Pro)
3. Build: ⌘B
4. Run: ⌘R

## 📦 Dependencies

### Swift Package Manager
- **Supabase Swift SDK** (`https://github.com/supabase/supabase-swift`) - Version 2.0.0+
  - Provides: Database client, Auth client, Storage client

### Custom Fonts (Included)
- PlayfairDisplay-Regular.ttf
- PlayfairDisplay-SemiBold.ttf
- Inter-Regular.ttf
- Inter-Medium.ttf
- Inter-SemiBold.ttf

## 🗄️ Database Schema

### Tables
- `users` - User accounts (extends Supabase auth.users)
- `user_profiles` - User profile information
- `user_preferences` - Dating preferences
- `user_photos` - Profile photos
- `matches` - Match records
- `intros` - AI-generated introductions
- `spark_exchanges` - Like/super like/pass interactions
- `scheduled_dates` - Date scheduling
- `date_feedback` - Post-date feedback
- `jules_conversations` - AI conversation history
- `user_learning` - Learning system for match improvement
- `neighborhoods` - Neighborhood data (NYC seeded)
- `user_neighborhoods` - User neighborhood preferences
- `venues` - Date venue information
- `spark_prompts` - AI prompts for spark exchange

### Storage Buckets
- `avatars` - User profile photos
- `voice-notes` - Voice recordings for spark exchange

### Security
- Row Level Security (RLS) enabled on all tables
- Policies ensure users can only access their own data
- Public read for neighborhoods and venues

## 🔧 Configuration

### Project Settings (`project.yml`)
- **Bundle ID**: `com.projectjules.ProjectJules`
- **Deployment Target**: iOS 17.0
- **Swift Version**: 5.9
- **Signing**: Automatic
- **Interface Orientations**: 
  - iPhone: Portrait, Landscape Left/Right
  - iPad: All orientations

### Info.plist
- **UIAppFonts**: All 5 custom fonts listed
- **UIApplicationSceneManifest**: Multiple scenes supported
- **Privacy Descriptions**: Camera, Photos, Location, Microphone

### Environment Variables
All in `Config/Config.swift`:
- Supabase URL and Anon Key
- Anthropic API Key
- Anthropic Model Name
- App settings

## ✅ Current Status

### Completed
- ✅ Complete iOS app structure (33+ Swift files)
- ✅ Design system with custom fonts
- ✅ Authentication flow (phone/OTP)
- ✅ User profile management
- ✅ Match discovery and viewing
- ✅ AI-powered introductions (Claude)
- ✅ Settings and preferences
- ✅ Database schema and migrations
- ✅ Storage bucket setup
- ✅ Xcode project generation (xcodegen)
- ✅ All deprecation warnings fixed
- ✅ Build succeeds without errors

### Configuration Needed
- [ ] Add Supabase credentials to `Config.swift`
- [ ] Add Anthropic API key to `Config.swift`
- [ ] Add fonts to Xcode Build Phases
- [ ] Run database schema in Supabase
- [ ] Create storage buckets in Supabase
- [ ] Select development team in Xcode
- [ ] Test authentication flow
- [ ] Test AI integration

### Known Issues
- None - All build errors resolved
- All deprecation warnings fixed

## 📚 Documentation

### Setup Guides
- **SETUP.md** - Complete step-by-step setup guide
- **README.md** - This file (overview & quick start)
- **IMPLEMENTATION_SUMMARY.md** - Detailed implementation notes

### Specific Guides
- **FIX_ASSETS_FOLDER.md** - How to add Assets folder in Xcode
- **ADD_FONTS_NOW.md** - Quick font setup guide
- **FONT_VERIFICATION.md** - Font verification steps
- **DATABASE_SETUP.md** - Database setup instructions
- **SUPABASE_SETUP_COMPLETE.md** - Supabase configuration details

### Troubleshooting
- **FIX_ALL_ERRORS.md** - Common errors and fixes
- **FIX_SIGNING_AND_PACKAGES.md** - Signing and package resolution
- **MANUAL_PACKAGE_FIX.md** - Package dependency issues

## 🔐 Security

### API Keys
- Store in `Config/Config.swift` (not committed to git with real keys)
- Template provided with placeholder values
- Never commit real API keys to version control

### Database Security
- Row Level Security (RLS) on all tables
- Service role key never exposed to client
- Anon key is public but RLS protects data

### Authentication
- Phone-based authentication with OTP
- Twilio SMS integration via Supabase
- Secure session management

## 🚧 Next Steps

1. **Configure Credentials**: Add real API keys to `Config.swift`
2. **Setup Database**: Run migrations in Supabase
3. **Add Fonts**: Manually add fonts to Xcode (see ADD_FONTS_NOW.md)
4. **Test Authentication**: Test phone/OTP flow
5. **Test AI**: Verify Claude API integration
6. **Add Lottie Animations**: Designer creates animations from specs
7. **Beta Testing**: Test with real users
8. **App Store Submission**: Prepare for release

## 🤝 Contributing

This is a private project. For questions or issues, refer to the documentation files or contact the development team.

## 📄 License

Private project - All rights reserved

## 📞 Support

For setup issues, see:
- `SETUP.md` for general setup
- `FIX_ALL_ERRORS.md` for error troubleshooting
- Individual guide files for specific topics

---

**Last Updated**: January 2025  
**Version**: 1.0.0  
**Build Status**: ✅ All builds passing  
**Xcode Version**: 15.0+  
**iOS Deployment Target**: 17.0
