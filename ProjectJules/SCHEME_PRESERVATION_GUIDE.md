# Scheme Preservation Guide

## ✅ Scheme Recreated

I've recreated your `ProjectJules` scheme with all environment variables at:
```
ProjectJules.xcodeproj/xcshareddata/xcschemes/ProjectJules.xcscheme
```

## 🔍 Why Does the Scheme Disappear?

When you manually add files in Xcode, sometimes Xcode regenerates or modifies the project file, which can:
- Reset scheme configurations
- Remove environment variables
- Change scheme settings

**However**, since the scheme is in `xcshareddata/xcschemes/`, it's a **shared scheme** and should persist better.

## ✅ How to See the Scheme in Xcode

1. **Close and reopen Xcode** (if it's open)
   - This ensures Xcode recognizes the scheme file

2. **Check the Scheme selector** (top toolbar in Xcode):
   - You should see "ProjectJules" next to the device selector
   - If not, click it and it should appear

3. **Verify Environment Variables:**
   - Press `⌘<` (Command + Less Than) OR Product → Scheme → Edit Scheme...
   - Select "Run" in left sidebar
   - Click "Arguments" tab
   - Scroll to "Environment Variables"
   - You should see all 3 variables with placeholder values

## 🔧 Update Your API Keys (IMPORTANT!)

The scheme has **placeholder values**. You need to replace them:

### Quick Method (In Xcode):

1. **Edit Scheme:** `⌘<` OR Product → Scheme → Edit Scheme...
2. **Select "Run"** → **"Arguments" tab**
3. **Find "Environment Variables"** section
4. **Replace these placeholder values:**
   - `ANTHROPIC_API_KEY` = `YOUR_ANTHROPIC_API_KEY_HERE` → Your actual key
   - `SUPABASE_URL` = `YOUR_SUPABASE_URL_HERE` → Your actual URL
   - `SUPABASE_ANON_KEY` = `YOUR_SUPABASE_ANON_KEY_HERE` → Your actual key
5. **Make sure all checkboxes are CHECKED ✅**
6. **Click "Close"**

## 🛡️ Preventing Future Issues

### Option 1: Always Edit Scheme in Xcode (Recommended)

When adding files manually:
- **After adding files**, check the scheme: `⌘<` → Run → Arguments
- **Verify environment variables** are still there
- **If missing**, re-add them (they're saved in the scheme file)

### Option 2: Use XcodeGen (Auto-Managed)

If you prefer automatic management:
- **Don't manually add files** in Xcode
- **Update `project.yml`** instead
- **Run `xcodegen generate`** to regenerate the project
- **Note:** This will regenerate the scheme from `project.yml`, so you'll need to re-add environment variables after each generation

### Option 3: Backup Scheme File

Before making major changes:
- **Copy the scheme file:**
  ```bash
  cp ProjectJules.xcodeproj/xcshareddata/xcschemes/ProjectJules.xcscheme \
     ProjectJules.xcodeproj/xcshareddata/xcschemes/ProjectJules.xcscheme.backup
  ```
- **If scheme is lost**, restore from backup:
  ```bash
  cp ProjectJules.xcodeproj/xcshareddata/xcschemes/ProjectJules.xcscheme.backup \
     ProjectJules.xcodeproj/xcshareddata/xcschemes/ProjectJules.xcscheme
  ```

## 🎯 Current Status

✅ Scheme file created at: `xcshareddata/xcschemes/ProjectJules.xcscheme`
✅ Environment variables included with placeholders
⚠️ **ACTION REQUIRED:** Replace placeholder API keys with your actual keys

## 📝 Quick Reference

- **Edit Scheme:** `⌘<` (Command + Less Than)
- **Scheme File Location:** `ProjectJules.xcodeproj/xcshareddata/xcschemes/ProjectJules.xcscheme`
- **Environment Variables:** Edit Scheme → Run → Arguments → Environment Variables

The scheme is ready - just update the API keys and you're good to go! 🚀

