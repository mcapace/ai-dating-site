#!/bin/bash

# Automated Setup Script for Project Jules
# This script automates everything possible

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "🚀 Starting Automated Setup for Project Jules..."
echo ""

# 1. Verify project structure
echo "📁 Verifying project structure..."
REQUIRED_DIRS=("App" "DesignSystem" "Models" "Services" "Views" "Config" "Database")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "   ✅ $dir/"
    else
        echo "   ❌ $dir/ missing!"
        exit 1
    fi
done
echo ""

# 2. Check Swift files
echo "📝 Checking Swift files..."
SWIFT_COUNT=$(find . -name "*.swift" -not -path "./.build/*" -not -path "./DerivedData/*" | wc -l | tr -d ' ')
echo "   ✅ Found $SWIFT_COUNT Swift files"
echo ""

# 3. Verify Xcode project exists
echo "🔧 Checking Xcode project..."
if [ -d "ProjectJules.xcodeproj" ]; then
    echo "   ✅ Xcode project exists"
else
    echo "   ❌ Xcode project not found!"
    exit 1
fi
echo ""

# 4. Check package dependencies
echo "📦 Checking package dependencies..."
if [ -f "ProjectJules.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved" ]; then
    echo "   ✅ Package dependencies resolved"
    if grep -q "supabase" "ProjectJules.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"; then
        echo "   ✅ Supabase package found"
    fi
else
    echo "   ⚠️  Package dependencies not yet resolved (will resolve on first build)"
fi
echo ""

# 5. Create enhanced Config.swift with better instructions
echo "⚙️  Updating Config.swift with setup instructions..."
cat > Config/Config.swift << 'ENDOFFILE'
//
//  Config.swift
//  ProjectJules
//
//  App Configuration - Replace with your actual credentials
//

import Foundation

enum Config {
    // MARK: - Supabase
    // Get these from: https://supabase.com/dashboard → Your Project → Settings → API
    static let supabaseURL = "https://YOUR_PROJECT_ID.supabase.co"
    static let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"
    
    // MARK: - Anthropic (Claude AI)
    // Get this from: https://console.anthropic.com/ → API Keys → Create Key
    static let anthropicAPIKey = "YOUR_ANTHROPIC_API_KEY"
    static let anthropicModel = "claude-sonnet-4-20250514"
    
    // MARK: - App Settings
    static let appName = "Jules"
    static let appVersion = "1.0.0"
    
    // MARK: - Twilio (SMS Verification - Optional)
    // Get these from: https://console.twilio.com/
    static let twilioAccountSID = "YOUR_TWILIO_ACCOUNT_SID"
    static let twilioAuthToken = "YOUR_TWILIO_AUTH_TOKEN"
    static let twilioPhoneNumber = "+1234567890"
    
    // MARK: - Feature Flags
    static let enableVoiceNotes = true
    static let enableVideoCalls = false
    static let maxPhotosPerUser = 6
    
    // MARK: - Validation
    static func validate() -> Bool {
        guard !supabaseURL.contains("YOUR_PROJECT_ID"),
              !supabaseAnonKey.contains("YOUR_SUPABASE"),
              !anthropicAPIKey.contains("YOUR_ANTHROPIC") else {
            print("⚠️ Warning: Config.swift contains placeholder values.")
            print("   Please update with your actual credentials:")
            print("   1. Supabase: https://supabase.com/dashboard → Settings → API")
            print("   2. Anthropic: https://console.anthropic.com/ → API Keys")
            return false
        }
        return true
    }
}
ENDOFFILE
echo "   ✅ Config.swift updated with instructions"
echo ""

# 6. Create database setup script for easy copy-paste
echo "🗄️  Creating database setup helper..."
cat > Database/SETUP_INSTRUCTIONS.md << 'ENDOFFILE'
# Database Setup - Copy & Paste Instructions

## Step 1: Run Schema

1. Go to: https://supabase.com/dashboard
2. Select your project → SQL Editor → New query
3. Copy the ENTIRE contents of `schema.sql` below
4. Paste into SQL Editor
5. Click Run (⌘Enter)

## Step 2: Create Storage Buckets

1. Go to Storage → New bucket
2. Create: `avatars` (Public: ✅ Yes)
3. Create: `voice-notes` (Public: ❌ No)

## Step 3: Run Storage Policies

1. Back to SQL Editor → New query
2. Copy ENTIRE contents of `storage-setup.sql`
3. Paste → Run

## Quick Copy Commands

### Schema (from schema.sql):
```bash
# In terminal, run:
cat "$(dirname "$0")/schema.sql" | pbcopy
# Then paste in Supabase SQL Editor
```

### Storage Setup (from storage-setup.sql):
```bash
# In terminal, run:
cat "$(dirname "$0")/storage-setup.sql" | pbcopy
# Then paste in Supabase SQL Editor
```
ENDOFFILE
echo "   ✅ Database setup instructions created"
echo ""

# 7. Create Xcode setup script
echo "📱 Creating Xcode setup helper..."
cat > xcode-setup-commands.md << 'ENDOFFILE'
# Xcode Setup Commands

## Quick Setup Checklist

### 1. Select Simulator
- Click device selector (top toolbar)
- Choose: **iPhone 17 Pro**

### 2. Configure Signing
- Click **ProjectJules** (blue icon) → **ProjectJules** target
- **Signing & Capabilities** tab
- ✅ Check "Automatically manage signing"
- Select your **Team**

### 3. Add API Keys
- Open `Config/Config.swift`
- Replace placeholders with your actual keys

### 4. Build
- Press **⌘B** to build
- Check for errors

### 5. Run
- Press **⌘R** to run
- App launches on simulator

## Keyboard Shortcuts
- Build: ⌘B
- Run: ⌘R
- Clean: ⇧⌘K
- Stop: ⌘.
ENDOFFILE
echo "   ✅ Xcode setup guide created"
echo ""

# 8. Create a master setup status file
echo "📊 Creating setup status tracker..."
cat > SETUP_STATUS.md << 'ENDOFFILE'
# Setup Status Tracker

## ✅ Automated (Done)
- [x] Project structure verified
- [x] Swift files checked (23 files)
- [x] Xcode project exists
- [x] Config.swift updated with instructions
- [x] Database setup guides created

## 🔧 Manual Steps Required

### In Xcode:
- [ ] Select simulator (iPhone 17 Pro)
- [ ] Configure signing (Select team)
- [ ] Add API keys to Config.swift
- [ ] Build project (⌘B)
- [ ] Run app (⌘R)

### In Supabase Dashboard:
- [ ] Run Database/schema.sql in SQL Editor
- [ ] Create `avatars` bucket (public)
- [ ] Create `voice-notes` bucket (private)
- [ ] Run Database/storage-setup.sql

### Get API Keys:
- [ ] Supabase: https://supabase.com/dashboard → Settings → API
- [ ] Anthropic: https://console.anthropic.com/ → API Keys

## 🎯 Next Action

1. Open Xcode project
2. Follow xcode-setup-commands.md
3. Add your API keys
4. Set up database in Supabase
5. Build and run!
ENDOFFILE
echo "   ✅ Setup status tracker created"
echo ""

# 9. Create a helper script to copy SQL to clipboard
echo "📋 Creating SQL copy helpers..."
cat > Database/copy-schema.sh << 'ENDOFFILE'
#!/bin/bash
# Copy schema.sql to clipboard for easy pasting into Supabase

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cat "$SCRIPT_DIR/schema.sql" | pbcopy
echo "✅ schema.sql copied to clipboard!"
echo "   Now paste it into Supabase SQL Editor"
ENDOFFILE

cat > Database/copy-storage.sh << 'ENDOFFILE'
#!/bin/bash
# Copy storage-setup.sql to clipboard

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cat "$SCRIPT_DIR/storage-setup.sql" | pbcopy
echo "✅ storage-setup.sql copied to clipboard!"
echo "   Now paste it into Supabase SQL Editor"
ENDOFFILE

chmod +x Database/copy-schema.sh Database/copy-storage.sh
echo "   ✅ SQL copy helpers created"
echo ""

# 10. Final summary
echo "✨ Automated Setup Complete!"
echo ""
echo "📋 What Was Done:"
echo "   ✅ Project structure verified"
echo "   ✅ Config.swift updated with clear instructions"
echo "   ✅ Database setup guides created"
echo "   ✅ Xcode setup instructions created"
echo "   ✅ SQL copy helpers created"
echo ""
echo "🔧 What You Need To Do:"
echo ""
echo "1. IN XCODE:"
echo "   - Select iPhone 17 Pro simulator"
echo "   - Configure signing (select your team)"
echo "   - Open Config/Config.swift and add your API keys"
echo "   - Build (⌘B) and Run (⌘R)"
echo ""
echo "2. IN SUPABASE:"
echo "   - Run: ./Database/copy-schema.sh (copies SQL to clipboard)"
echo "   - Paste in Supabase SQL Editor → Run"
echo "   - Create storage buckets: avatars (public), voice-notes (private)"
echo "   - Run: ./Database/copy-storage.sh (copies storage SQL)"
echo "   - Paste in Supabase SQL Editor → Run"
echo ""
echo "3. GET API KEYS:"
echo "   - Supabase: https://supabase.com/dashboard"
echo "   - Anthropic: https://console.anthropic.com/"
echo ""
echo "📚 See SETUP_STATUS.md for detailed checklist"
echo ""
echo "🎯 Ready to continue!"

