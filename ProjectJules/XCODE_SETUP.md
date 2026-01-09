# Xcode Project Setup - Quick Reference

This guide helps you set up the Xcode project for Project Jules using Swift Package Manager.

## Step-by-Step Xcode Setup

### 1. Create Xcode Project

1. Open **Xcode**
2. **File → New → Project**
3. Select **iOS → App**
4. Configure:
   - **Product Name**: `ProjectJules`
   - **Team**: Select your Apple Developer team
   - **Organization Identifier**: `com.yourname` (or your domain)
   - **Bundle Identifier**: `com.yourname.projectjules`
   - **Interface**: **SwiftUI**
   - **Language**: **Swift**
   - **Storage**: None
5. **Save location**: Choose the `ProjectJules/` directory (root level)

### 2. Add Swift Package Dependencies

#### Add Supabase

1. **File → Add Package Dependencies...**
2. Paste: `https://github.com/supabase/supabase-swift`
3. Click **Add Package**
4. Select **Supabase** product
5. Add to **ProjectJules** target
6. Click **Add Package**

#### Add Lottie (Optional)

1. **File → Add Package Dependencies...**
2. Paste: `https://github.com/airbnb/lottie-spm`
3. Add **Lottie** product to target

### 3. Organize Project Structure

In Xcode Navigator, create groups (folders) and organize files:

```
ProjectJules (project root)
├── App
│   └── ProjectJulesApp.swift
├── DesignSystem
│   ├── Colors.swift
│   ├── Typography.swift
│   ├── Spacing.swift
│   ├── JulesButton.swift
│   ├── JulesCard.swift
│   ├── JulesInput.swift
│   └── JulesChat.swift
├── Models
│   ├── User.swift
│   ├── Match.swift
│   ├── Venue.swift
│   └── JulesConversation.swift
├── Services
│   ├── SupabaseClient.swift
│   ├── AuthService.swift
│   ├── UserService.swift
│   └── JulesService.swift
├── Views
│   ├── Onboarding
│   ├── Main
│   ├── Match
│   ├── Intros
│   └── Settings
├── Config
│   └── Config.swift
└── Assets
    ├── Fonts
    ├── Lottie
    └── Images
```

**To create groups:**
- Right-click project → **New Group**
- Drag files into groups
- Ensure files are added to **ProjectJules** target

### 4. Configure Build Settings

1. Select **ProjectJules** project in Navigator
2. Select **ProjectJules** target
3. **General** tab:
   - **Minimum Deployments**: iOS 17.0
4. **Signing & Capabilities**:
   - Select your **Team**
   - Xcode auto-generates provisioning profile

### 5. Add Info.plist Entries

If using SwiftUI app lifecycle, you may need to add Info.plist:

1. **File → New → File → Property List**
2. Name: `Info.plist`
3. Add to target
4. Add keys (see SETUP.md for full list):
   - `UIAppFonts` (array of font names)
   - Privacy descriptions

### 6. Configure Config.swift

1. Open `Config/Config.swift`
2. Replace placeholders with your actual credentials:
   - Supabase URL and key
   - Anthropic API key
   - Twilio credentials (if using)

### 7. Verify Package Dependencies

1. **File → Packages → Resolve Package Versions**
2. Wait for packages to download
3. Check Navigator for **Package Dependencies** section
4. Verify **Supabase** appears

### 8. Build and Test

1. Select simulator (e.g., iPhone 15 Pro)
2. **Product → Build** (⌘B) to check for errors
3. **Product → Run** (⌘R) to launch app

## Common Issues

### Packages Not Resolving

- **File → Packages → Reset Package Caches**
- **File → Packages → Resolve Package Versions**
- Clean build folder: **Product → Clean Build Folder** (⇧⌘K)

### Missing Imports

Ensure your Swift files import:
```swift
import SwiftUI
import Supabase  // If using Supabase
import Lottie    // If using Lottie
```

### Build Errors

- Check all files are added to target
- Verify deployment target (iOS 17.0+)
- Ensure Xcode 15.0+ is installed

## Next Steps

After Xcode project is set up:

1. ✅ Add your Swift source files to appropriate groups
2. ✅ Configure `Config.swift` with API keys
3. ✅ Set up Supabase database (run `Database/schema.sql`)
4. ✅ Add custom fonts
5. ✅ Test build and run

See `SETUP.md` for complete setup instructions.

