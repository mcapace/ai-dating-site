# API Keys for Xcode Environment Variables

## Instructions to Add Environment Variables in Xcode

1. **Open Xcode Scheme Editor**:
   - Press `⌘<` (Command + Less Than) OR
   - Product → Scheme → Edit Scheme...

2. **Select "Run"** in the left sidebar (blue play icon)

3. **Click the "Arguments" tab**

4. **Scroll to "Environment Variables" section**

5. **Click the "+" button** to add each variable below

6. **Make sure the checkbox is CHECKED ✅** for each variable

7. **Click "Close"**

---

## Required Environment Variables

### 1. ANTHROPIC_API_KEY (REQUIRED)
```
Name: ANTHROPIC_API_KEY
Value: [Your Anthropic API key]
```

**How to get it:**
1. Go to https://console.anthropic.com/
2. Sign in or create an account
3. Navigate to API Keys section
4. Create a new API key or copy an existing one
5. Paste the key (starts with `sk-ant-...`)

---

### 2. SUPABASE_URL (Optional - if not set, uses default from Config.swift)
```
Name: SUPABASE_URL
Value: https://qkegftjmzgtlecjvuhnl.supabase.co
```

**Note:** Based on your `ADD_ENV_VARS.md`, this appears to be your Supabase project URL.

---

### 3. SUPABASE_ANON_KEY (Optional - if not set, uses default from Config.swift)
```
Name: SUPABASE_ANON_KEY
Value: [Your Supabase anon/public key]
```

**How to get it:**
1. Go to your Supabase dashboard: https://app.supabase.com
2. Select your project
3. Go to Settings → API
4. Copy the "anon" or "public" key (NOT the service_role key)
5. It will look like: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

---

## Quick Copy-Paste Summary

If you want to add all at once:

| Variable Name | Value Source |
|--------------|--------------|
| `ANTHROPIC_API_KEY` | https://console.anthropic.com/ |
| `SUPABASE_URL` | `https://qkegftjmzgtlecjvuhnl.supabase.co` (or your project URL) |
| `SUPABASE_ANON_KEY` | Supabase Dashboard → Settings → API → anon key |

---

## Verification

After adding the environment variables:

1. **Build the project**: `⌘B`
2. **Run the project**: `⌘R`
3. **Check for errors**: The app should build without warnings related to missing API keys
4. **Test API calls**: Try using features that require API access (e.g., chatting with Jules)

---

## Fallback Behavior

If environment variables are not set, the app will use the default values from `Config.swift`:
- `ANTHROPIC_API_KEY` → Falls back to `"YOUR_ANTHROPIC_API_KEY"` (will not work)
- `SUPABASE_URL` → Falls back to `"https://YOUR_PROJECT_ID.supabase.co"` (will not work)
- `SUPABASE_ANON_KEY` → Falls back to `"YOUR_SUPABASE_ANON_KEY"` (will not work)

**Important:** You must set at least `ANTHROPIC_API_KEY` for the app to function properly. Supabase keys can also be set directly in `Config.swift` if you prefer not to use environment variables.

---

## Security Note

- Environment variables in Xcode schemes are stored in your local project settings (in `xcuserdata`)
- They are NOT committed to git by default (`.gitignore` should exclude `xcuserdata/`)
- For production builds, consider using Xcode Build Configurations or CI/CD environment variables
- Never commit API keys to version control

