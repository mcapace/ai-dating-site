# ✅ Scheme Created - Update API Keys

## What I Did

I've created a new Xcode scheme file at:
`ProjectJules.xcodeproj/xcshareddata/xcschemes/ProjectJules.xcscheme`

The scheme includes all 3 environment variables with placeholder values.

## 🔧 Next Step: Replace Placeholder Values

You have **two options** to update the API keys:

### Option 1: Edit in Xcode (Easiest - Recommended)

1. **Open Xcode** and open your `ProjectJules.xcodeproj`

2. **Edit Scheme:**
   - Press `⌘<` (Command + Less Than) OR
   - Product → Scheme → Edit Scheme...

3. **Select "Run"** in the left sidebar

4. **Click "Arguments" tab**

5. **Scroll to "Environment Variables"**

6. **You'll see 3 variables with placeholder values:**
   - `ANTHROPIC_API_KEY` = "YOUR_ANTHROPIC_API_KEY_HERE"
   - `SUPABASE_URL` = "YOUR_SUPABASE_URL_HERE"
   - `SUPABASE_ANON_KEY` = "YOUR_SUPABASE_ANON_KEY_HERE"

7. **Click on each value** and replace with your actual keys:
   - Replace `YOUR_ANTHROPIC_API_KEY_HERE` with your actual Anthropic API key
   - Replace `YOUR_SUPABASE_URL_HERE` with your Supabase URL (e.g., `https://xxxxx.supabase.co`)
   - Replace `YOUR_SUPABASE_ANON_KEY_HERE` with your Supabase anon key

8. **Make sure all checkboxes are CHECKED ✅**

9. **Click "Close"**

10. **Build & Run** (`⌘R`) to test

### Option 2: Edit Scheme File Directly

If you prefer to edit the file directly:

1. Open: `ProjectJules.xcodeproj/xcshareddata/xcschemes/ProjectJules.xcscheme`

2. Find these lines and replace the placeholder values:
   ```xml
   <EnvironmentVariable
      key = "ANTHROPIC_API_KEY"
      value = "YOUR_ANTHROPIC_API_KEY_HERE"  ← Replace this
      isEnabled = "YES">
   </EnvironmentVariable>
   <EnvironmentVariable
      key = "SUPABASE_URL"
      value = "YOUR_SUPABASE_URL_HERE"  ← Replace this
      isEnabled = "YES">
   </EnvironmentVariable>
   <EnvironmentVariable
      key = "SUPABASE_ANON_KEY"
      value = "YOUR_SUPABASE_ANON_KEY_HERE"  ← Replace this
      isEnabled = "YES">
   </EnvironmentVariable>
   ```

3. Save the file

4. Reopen Xcode if it's open

## ✅ Verification

After updating, verify in Xcode:
- Scheme → Edit Scheme → Run → Arguments → Environment Variables
- All 3 variables should show your actual values (not placeholders)
- All checkboxes should be checked ✅

## 📝 Your API Keys Reference

If you need to get your keys again:

1. **ANTHROPIC_API_KEY**
   - Get from: https://console.anthropic.com/
   - Format: `sk-ant-api03-...`

2. **SUPABASE_URL**
   - Get from: Supabase Dashboard → Settings → API
   - Format: `https://xxxxx.supabase.co`

3. **SUPABASE_ANON_KEY**
   - Get from: Supabase Dashboard → Settings → API
   - Format: `eyJhbGciOiJIUzI1NiIs...` (long JWT token)

The scheme is ready - just replace the placeholder values with your actual API keys!

