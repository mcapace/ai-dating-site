# Your API Keys - Environment Variables for Xcode

## Found in Your Project:

### ✅ SUPABASE_URL
```
https://qkegftjmzgtlecjvuhnl.supabase.co
```
**Source:** Found in `ADD_ENV_VARS.md`

---

## Keys You Need to Get:

### ❌ ANTHROPIC_API_KEY (Required)
**Status:** Not found in codebase - you need to obtain this

**How to get it:**
1. Go to: https://console.anthropic.com/
2. Sign in or create account
3. Navigate to "API Keys" section
4. Click "Create Key" or copy existing key
5. Key format: `sk-ant-api03-...` (starts with `sk-ant-`)

**Add to Xcode as:**
```
Name: ANTHROPIC_API_KEY
Value: [paste your key here]
```

---

### ❌ SUPABASE_ANON_KEY (Required)
**Status:** Not found in codebase - you need to obtain this

**How to get it:**
1. Go to: https://app.supabase.com
2. Sign in and select your project (project ID: `qkegftjmzgtlecjvuhnl`)
3. Go to: **Settings** → **API**
4. Find the **"anon"** or **"public"** key (NOT the service_role key)
5. Copy the key - it's a long JWT token starting with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

**Add to Xcode as:**
```
Name: SUPABASE_ANON_KEY
Value: [paste your anon key here]
```

---

## Complete Environment Variables List for Xcode:

1. **ANTHROPIC_API_KEY**
   - Value: `[Get from https://console.anthropic.com/]`
   - ✅ Checkbox: Checked

2. **SUPABASE_URL**
   - Value: `https://qkegftjmzgtlecjvuhnl.supabase.co`
   - ✅ Checkbox: Checked

3. **SUPABASE_ANON_KEY**
   - Value: `[Get from Supabase Dashboard → Settings → API]`
   - ✅ Checkbox: Checked

---

## Quick Setup Instructions:

1. Open Xcode → Press `⌘<` (Edit Scheme)
2. Select **Run** → **Arguments** tab
3. Scroll to **Environment Variables**
4. Click **+** and add each variable above
5. **Make sure checkbox is CHECKED ✅** for each
6. Click **Close**
7. Build & Run: `⌘R`

---

## Notes:

- **ANTHROPIC_API_KEY** is REQUIRED - the app won't work without it
- **SUPABASE_ANON_KEY** is REQUIRED - database won't work without it
- **SUPABASE_URL** is already found in your project, just add it to environment variables
- These keys are stored locally in your Xcode project and won't be committed to git

