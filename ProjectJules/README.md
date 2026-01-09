# Project Jules - iOS App

AI-powered dating app built with SwiftUI, Supabase, and Claude AI.

## Quick Start

1. **Open Xcode** and create a new iOS App project (see `XCODE_SETUP.md`)
2. **Add Swift Package Dependencies**:
   - Supabase: `https://github.com/supabase/supabase-swift`
   - Lottie: `https://github.com/airbnb/lottie-spm` (optional)
3. **Configure API Keys** in `Config/Config.swift`
4. **Set Up Database** by running `Database/schema.sql` in Supabase
5. **Add Custom Fonts** (Playfair Display & Inter)
6. **Build and Run** (⌘R)

## Project Structure

```
ProjectJules/
├── App/              # App entry point
├── DesignSystem/     # UI components
├── Models/           # Data models
├── Services/         # Business logic
├── Views/            # Screen components
├── Config/           # Configuration
├── Database/         # SQL schemas
└── Assets/           # Fonts, images, animations
```

## Documentation

- **SETUP.md** - Complete setup guide
- **XCODE_SETUP.md** - Xcode-specific setup steps
- **Database/schema.sql** - Database schema
- **Database/storage-setup.sql** - Storage bucket setup

## Requirements

- Xcode 15.0+
- iOS 17.0+
- Supabase account
- Anthropic API key

## Next Steps

After setting up the Xcode project:

1. Drag your Swift source files into the project
2. Organize files into the groups shown above
3. Configure `Config.swift` with your API keys
4. Run the database schema in Supabase
5. Add custom fonts
6. Test the build

For detailed instructions, see `SETUP.md`.

