# Add Environment Variables to Xcode Scheme

## Quick Steps:

1. **Open Edit Scheme**:
   - Press **⌘<** (Command + Less Than) OR
   - Product → Scheme → Edit Scheme...

2. **Select "Run"** in left sidebar (blue play icon)

3. **Click "Arguments" tab**

4. **Scroll to "Environment Variables" section**

5. **Click "+" and add these variables**:

### Required:
```
Name: ANTHROPIC_API_KEY
Value: [Your Anthropic API key from https://console.anthropic.com/]
```

### Optional (Supabase - already configured in code):
```
Name: SUPABASE_URL
Value: https://qkegftjmzgtlecjvuhnl.supabase.co

Name: SUPABASE_ANON_KEY  
Value: [Get from Supabase dashboard → Settings → API]
```

6. **Make sure checkbox is CHECKED ✅** for each variable

7. **Click "Close"**

8. **Build and Run (⌘R)**

## Verify:
- App should build without warnings
- API calls should work if keys are set correctly

