# Next Steps - Project Jules

## ✅ Immediate Actions (Do These Now)

### 1. Wait for Package Resolution
- In Xcode, look at the bottom status bar
- Wait for "Resolving Package Graph" to complete
- The Supabase package should download automatically
- If it doesn't resolve: **File → Packages → Resolve Package Versions**

### 2. Try a Test Build
- Press **⌘B** (or Product → Build)
- This will show any immediate compilation errors
- Fix any import or syntax issues if they appear

### 3. Configure Signing
- Click on **ProjectJules** (blue project icon) in Navigator
- Select **ProjectJules** target
- Go to **Signing & Capabilities** tab
- Check **"Automatically manage signing"**
- Select your **Team** from dropdown
- Xcode will create a provisioning profile automatically

### 4. Select a Simulator
- At the top toolbar, click the device selector
- Choose **iPhone 15 Pro** (or any iOS 17+ simulator)

## 🔧 Configuration (Before Running)

### 5. Configure API Keys (Required)
Open `Config/Config.swift` and replace:

```swift
// Replace these:
static let supabaseURL = "https://YOUR_PROJECT_ID.supabase.co"
static let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"
static let anthropicAPIKey = "YOUR_ANTHROPIC_API_KEY"
```

**To get Supabase credentials:**
1. Go to https://supabase.com/dashboard
2. Select your project (or create one)
3. Settings → API
4. Copy "Project URL" and "anon public" key

**To get Anthropic API key:**
1. Go to https://console.anthropic.com/
2. API Keys → Create Key
3. Copy the key (starts with `sk-ant-...`)

### 6. Add Fonts (Optional for now, but needed for full UI)
- Download fonts:
  - Playfair Display: https://fonts.google.com/specimen/Playfair+Display
  - Inter: https://fonts.google.com/specimen/Inter
- In Xcode, right-click **Assets** folder → **Add Files to "ProjectJules"...**
- Select font files → Check "Copy items if needed" → Add
- Fonts are already listed in Info.plist, so they'll work once added

## 🚀 Test Run

### 7. Build and Run
- Press **⌘R** (or Product → Run)
- The app should launch on the simulator
- You should see the splash screen, then onboarding flow

## 🗄️ Database Setup (When Ready)

### 8. Set Up Supabase Database
1. Go to Supabase dashboard → SQL Editor
2. Open `ProjectJules/Database/schema.sql`
3. Copy entire contents → Paste in SQL Editor → Run
4. Go to Storage → Create buckets:
   - `avatars` (public)
   - `voice-notes` (private)
5. Run `ProjectJules/Database/storage-setup.sql` in SQL Editor

## 📝 Quick Checklist

- [ ] Package dependencies resolved (Supabase)
- [ ] Test build successful (⌘B)
- [ ] Signing configured with your team
- [ ] Simulator selected (iOS 17+)
- [ ] API keys added to Config.swift
- [ ] Fonts added (optional)
- [ ] App runs on simulator (⌘R)
- [ ] Database schema run in Supabase (when ready)

## 🐛 Common First-Time Issues

**Build Errors:**
- Make sure all Swift files are in the project (they should be)
- Check that Supabase package resolved
- Clean build: **Product → Clean Build Folder (⇧⌘K)**

**Missing Imports:**
- All files should have `import SwiftUI`
- Services should have `import Supabase`

**Font Warnings:**
- These are OK for now - fonts will work once you add the font files
- The app will use system fonts as fallback

**API Errors:**
- Normal until you add real API keys
- The app won't connect to Supabase/Claude until configured

## ✨ You're Ready!

Once you complete steps 1-4, you can build and run the app. The UI will work, but API features need the credentials from step 5.

