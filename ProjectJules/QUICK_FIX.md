# Quick Fix Guide - Project Jules

## 🔧 Fix iOS 26.1 Error

### Option 1: Use Available Simulator (Easiest)
1. In Xcode, click the device selector (top toolbar, next to play button)
2. Select **iPhone 17 Pro** or **iPhone 17** (these should work)
3. The project is set to iOS 17.0, so any iOS 17+ simulator will work

### Option 2: Install iOS 26 SDK (If Needed)
1. **Xcode → Settings** (or Preferences)
2. Go to **Platforms** (or **Components**) tab
3. Find **iOS 26.1** and click **Download**
4. Wait for download to complete

**Note:** The project targets iOS 17.0, so you don't need iOS 26 SDK unless you want to test on that specific version.

## ✅ Step-by-Step Setup

### 1. Select Working Simulator
- Click device selector → Choose **iPhone 17 Pro** or **iPhone 17**
- These should work with iOS 17.0 deployment target

### 2. Set Up Signing
1. Click **ProjectJules** (blue project icon) in left navigator
2. Select **ProjectJules** target (under TARGETS)
3. Click **Signing & Capabilities** tab
4. Check ✅ **"Automatically manage signing"**
5. Select your **Team** from dropdown
   - If you don't have a team, you can use "Personal Team" (your Apple ID)
   - Xcode will create provisioning profile automatically

### 3. Add API Keys
1. In Xcode navigator, find **Config/Config.swift**
2. Double-click to open
3. Replace these values:

```swift
// Supabase (get from https://supabase.com/dashboard → Settings → API)
static let supabaseURL = "https://YOUR_PROJECT_ID.supabase.co"
static let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"

// Anthropic (get from https://console.anthropic.com/ → API Keys)
static let anthropicAPIKey = "YOUR_ANTHROPIC_API_KEY"
```

**How to get Supabase credentials:**
- Go to https://supabase.com/dashboard
- Select your project (or create one)
- Settings → API
- Copy "Project URL" → paste as `supabaseURL`
- Copy "anon public" key → paste as `supabaseAnonKey`

**How to get Anthropic API key:**
- Go to https://console.anthropic.com/
- Sign in → API Keys
- Create Key → Copy (starts with `sk-ant-...`)

### 4. Build Test
1. Press **⌘B** (or Product → Build)
2. Check for errors in the Issue Navigator (left sidebar)
3. Common issues:
   - **Font warnings**: OK for now, will work once fonts added
   - **API errors**: Normal until you add real keys
   - **Import errors**: Should resolve automatically

### 5. Set Up Database (Before Running App)

**In Supabase Dashboard:**

1. Go to **SQL Editor**
2. Open `ProjectJules/Database/schema.sql` in a text editor
3. Copy **entire contents** of the file
4. Paste into Supabase SQL Editor
5. Click **Run** (or press ⌘Enter)
6. Wait for "Success" message

**Create Storage Buckets:**

1. Go to **Storage** in Supabase dashboard
2. Click **New bucket**
3. Create bucket named: **`avatars`**
   - Make it **Public**
4. Create bucket named: **`voice-notes`**
   - Make it **Private**
5. Go back to **SQL Editor**
6. Open `ProjectJules/Database/storage-setup.sql`
7. Copy and paste → **Run**

**Verify Database:**
Run this in SQL Editor to check:
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

You should see: `users`, `user_profiles`, `user_preferences`, `matches`, `intros`, etc.

### 6. Run the App
1. Make sure simulator is selected
2. Press **⌘R** (or Product → Run)
3. App should launch on simulator
4. You'll see splash screen → onboarding flow

## 🐛 Troubleshooting

**"No such module 'Supabase'"**
- File → Packages → Resolve Package Versions
- Wait for packages to download

**Build Errors:**
- Product → Clean Build Folder (⇧⌘K)
- Then build again (⌘B)

**Simulator Won't Launch:**
- Xcode → Settings → Platforms
- Make sure iOS 17+ simulator is installed
- Or use a physical device

**API Connection Errors:**
- Normal until you add real API keys
- App will show errors but UI will work

## ✅ Checklist

- [ ] Simulator selected (iPhone 17 Pro or similar)
- [ ] Signing configured with team
- [ ] API keys added to Config.swift
- [ ] Build successful (⌘B)
- [ ] Database schema run in Supabase
- [ ] Storage buckets created
- [ ] App runs on simulator (⌘R)

## 🎯 You're Ready!

Once you complete these steps, the app should run. The UI will work immediately, and API features will work once you add credentials and set up the database.

