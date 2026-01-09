# Quick Setup: Add API Keys to Xcode (2 minutes)

## 🚀 Step-by-Step Instructions

### 1. Open Your Project in Xcode
- Open `ProjectJules.xcodeproj`

### 2. Edit Scheme
- Press **⌘<** (Command + Less Than) OR
- **Product** → **Scheme** → **Edit Scheme...**

### 3. Select Run → Arguments Tab
- Click **Run** in left sidebar (blue play icon)
- Click **Arguments** tab at top
- Scroll down to **Environment Variables** section

### 4. Add Your API Keys
Click the **+** button and add these one by one:

#### Required: Anthropic API Key
```
Name: ANTHROPIC_API_KEY
Value: YOUR_ANTHROPIC_API_KEY_HERE
```

#### Optional: Supabase (already in code, but you can override)
```
Name: SUPABASE_URL
Value: https://qkegftjmzgtlecjvuhnl.supabase.co

Name: SUPABASE_ANON_KEY  
Value: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFrZWdmdGptemd0bGVjanZ1aG5sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc5OTIzMDUsImV4cCI6MjA4MzU2ODMwNX0.Qu6y2JcsZWwLM5q_35JrGLzdrbSjhsxDsP8WKCNmiXA
```

#### Optional: Twilio (if using SMS)
```
Name: TWILIO_ACCOUNT_SID
Value: YOUR_TWILIO_ACCOUNT_SID

Name: TWILIO_AUTH_TOKEN
Value: YOUR_TWILIO_AUTH_TOKEN

Name: TWILIO_PHONE_NUMBER
Value: +1234567890
```

### 5. Save and Run
- Click **Close** button
- Press **⌘R** to run
- App will now use your API keys securely! ✅

## ✅ Verification

When you run the app, check the console:
- ✅ If keys are set: App runs normally
- ⚠️ If keys missing: Warning message shows how to fix

## 🔒 Security Benefits

- ✅ Keys never committed to git
- ✅ Each developer sets their own keys
- ✅ Keys only available at runtime
- ✅ No secrets in source code

## 📝 For Team Members

Each person:
1. Clones repo (gets code without keys)
2. Adds `ANTHROPIC_API_KEY` to their Xcode scheme
3. Runs app (keys available at runtime)

**No keys shared via git!** ✅

