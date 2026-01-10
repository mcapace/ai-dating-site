# Restore Environment Variables in Xcode Scheme

## What Happened?

When I regenerated your Xcode project with XcodeGen (to add the fonts), it created a new scheme file, which overwrote your manually configured environment variables.

## Why This Happened

XcodeGen regenerates the entire Xcode project from `project.yml`, including schemes. Environment variables are typically stored in user-specific scheme files (`xcuserdata`), which get reset when the project is regenerated.

## ✅ Solution: Re-add Environment Variables in Xcode

**Environment variables can't be automatically restored because they contain sensitive API keys and should be stored in your local user-specific files (not committed to git).**

Here's how to add them back:

### Quick Steps:

1. **Open Xcode** and open your `ProjectJules.xcodeproj`

2. **Edit Scheme:**
   - Press `⌘<` (Command + Less Than) OR
   - Product → Scheme → Edit Scheme...

3. **Select "Run"** in the left sidebar (blue play icon)

4. **Click the "Arguments" tab**

5. **Scroll to "Environment Variables" section**

6. **Click the "+" button** and add each variable:

   #### Required Variables:

   ```
   Name: ANTHROPIC_API_KEY
   Value: [Your Anthropic API key - paste it here]
   ✅ Check the checkbox
   ```

   ```
   Name: SUPABASE_URL
   Value: [Your Supabase URL - e.g., https://xxxxx.supabase.co]
   ✅ Check the checkbox
   ```

   ```
   Name: SUPABASE_ANON_KEY
   Value: [Your Supabase anon key - paste it here]
   ✅ Check the checkbox
   ```

7. **Make sure the checkbox is CHECKED ✅** for each variable

8. **Click "Close"**

9. **Build & Run** (`⌘R`) to test

## Prevent This in the Future

**Option 1: Don't regenerate with XcodeGen** (Recommended)
- Only regenerate when you intentionally want to update project structure
- Environment variables will persist in user-specific files

**Option 2: Use .xcconfig files** (For non-sensitive values)
- Create `.xcconfig` files for non-sensitive configuration
- But API keys should still use environment variables in schemes

**Option 3: Document your variables**
- Keep a local note (not in git) of what variables you need
- I've created this file to help you remember

## Your Variables Reference

Based on your code, you need these 3 environment variables:

1. **ANTHROPIC_API_KEY** - Required
   - Get from: https://console.anthropic.com/
   - Format: `sk-ant-api03-...`

2. **SUPABASE_URL** - Optional (can use Config.swift fallback)
   - Your Supabase project URL
   - Format: `https://xxxxx.supabase.co`

3. **SUPABASE_ANON_KEY** - Optional (can use Config.swift fallback)
   - Get from: Supabase Dashboard → Settings → API
   - Format: `eyJhbGciOiJIUzI1NiIs...`

## Important Notes

- ✅ Environment variables in schemes are stored in `xcuserdata/` (not committed to git)
- ✅ They're safe to keep local - they won't be shared
- ⚠️ Regenerating with XcodeGen will reset them - you'll need to re-add them
- ✅ If you have the values saved elsewhere, this is just a quick re-entry

## Alternative: Use Config.swift Instead

If you prefer not to use environment variables, you can hardcode them directly in `Config.swift`:
- Open `ProjectJules/Config/Config.swift`
- Replace the placeholder values with your actual keys
- ⚠️ Don't commit sensitive keys to git if you do this

The code is already set up to use environment variables first, then fall back to Config.swift values.

