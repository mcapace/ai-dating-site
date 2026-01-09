# Secure Key Management Setup

## 🔐 Security Best Practices

**NEVER commit real API keys to git!** This guide shows you how to use keys securely while keeping your app functional.

## ✅ Current Setup

The app now uses environment variables for secure key management:
- ✅ Checks environment variables first
- ✅ Falls back to Info.plist (if configured securely)
- ✅ Fails gracefully if keys aren't set (in DEBUG mode)
- ✅ No keys committed to git

## 🚀 Method 1: Environment Variables (Recommended)

### For Xcode Development

1. **Open Xcode** → Open `ProjectJules.xcodeproj`

2. **Edit Scheme**:
   - Product → Scheme → Edit Scheme... (or ⌘<)
   - Select **Run** in left sidebar
   - Click **Arguments** tab
   - Under **Environment Variables**, click **+** and add:

   ```
   Name: ANTHROPIC_API_KEY
   Value: YOUR_ANTHROPIC_API_KEY_HERE
   ```

   Also add (optional but recommended):
   ```
   SUPABASE_URL = https://qkegftjmzgtlecjvuhnl.supabase.co
   SUPABASE_ANON_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   TWILIO_ACCOUNT_SID = your_twilio_sid
   TWILIO_AUTH_TOKEN = your_twilio_token
   TWILIO_PHONE_NUMBER = +1234567890
   ```

3. **Click Close**

4. **Build and Run** - Keys will be available at runtime

### For CI/CD (GitHub Actions, etc.)

Add secrets in your CI system:
```yaml
env:
  ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
  SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
  SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
```

### For Production Builds

Use Xcode Cloud or CI/CD to set environment variables, or see Method 2 below.

## 🔧 Method 2: Info.plist (Alternative)

If you can't use environment variables, you can add keys to Info.plist (but gitignore them):

1. **Create `Info-Secrets.plist`** (gitignored):
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>AnthropicAPIKey</key>
       <string>YOUR_ANTHROPIC_API_KEY_HERE</string>
   </dict>
   </plist>
   ```

2. **Merge with main Info.plist** in build script, or reference directly in code

**Better approach**: Use environment variables (Method 1) - they're more secure and flexible.

## 📋 Setup Steps Summary

### 1. Set Environment Variables in Xcode

```
Product → Scheme → Edit Scheme → Run → Arguments → Environment Variables
```

Add:
- `ANTHROPIC_API_KEY` = your actual key
- `SUPABASE_URL` = your Supabase URL (optional, already in code)
- `SUPABASE_ANON_KEY` = your Supabase key (optional, already in code)

### 2. Verify Setup

Run the app and check logs:
- If key is set: App runs normally
- If key is missing: Error message shows in DEBUG mode

### 3. For Team Members

Each developer:
1. Clones the repo (no keys in git ✅)
2. Sets environment variables in their Xcode scheme
3. Runs the app

### 4. For Production

Use CI/CD environment variables or:
- Xcode Cloud → Environment variables
- Fastlane → Environment variables
- Manual: Set in build settings

## ✅ Security Checklist

- ✅ No keys in git (using environment variables)
- ✅ Config.swift reads from environment variables
- ✅ Falls back safely if keys aren't set
- ✅ .gitignore excludes any local config files
- ✅ Example config file provided (no real keys)
- ✅ Validation function checks if keys are set

## 🔄 Current Keys Status

### Already in Config.swift (Public Keys - OK):
- ✅ `supabaseURL` - Public (okay to commit)
- ✅ `supabaseAnonKey` - Public (okay to commit, but env var preferred)

### Must Use Environment Variables:
- ⚠️ `anthropicAPIKey` - **MUST** be set via `ANTHROPIC_API_KEY` env var
- ⚠️ `twilioAccountSID` - Set via `TWILIO_ACCOUNT_SID` env var
- ⚠️ `twilioAuthToken` - Set via `TWILIO_AUTH_TOKEN` env var

## 🎯 Quick Start

1. **Open Xcode**
2. **Edit Scheme** (⌘<)
3. **Add Environment Variable**: `ANTHROPIC_API_KEY` = your key
4. **Run app** (⌘R)
5. **Verify**: Check console for validation message

## 📝 Notes

- Keys are only available at runtime (not in source code)
- Each developer sets their own keys in Xcode
- Production builds get keys from CI/CD environment
- No keys ever committed to git ✅

## 🚨 If You See This Error

```
⚠️ Warning: Anthropic API key not set. Set ANTHROPIC_API_KEY environment variable...
```

**Solution**: Add `ANTHROPIC_API_KEY` to your Xcode scheme environment variables (see Method 1 above).

