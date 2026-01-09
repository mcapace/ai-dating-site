# Security Fix: Remove API Key from Git History

## ⚠️ Security Issue

GitHub push protection detected an API key in commit `2dd3761`. The Anthropic API key was accidentally committed to git history.

## ✅ Immediate Fix Applied

1. **Removed API key from `Config.swift`** - Replaced with placeholder
2. **Added security warning** - Comment in code about never committing keys

## 🔧 Complete Fix Required

### Option 1: Use BFG Repo-Cleaner (Recommended)
```bash
# Install BFG (if not installed)
brew install bfg

# Clone fresh copy (BFG needs a bare repo)
cd /tmp
git clone --mirror https://github.com/mcapace/ai-dating-site.git

# Remove the API key from all history
cd ai-dating-site.git
bfg --replace-text /path/to/replacements.txt

# Create replacements.txt with:
# YOUR_ANTHROPIC_API_KEY_HERE==>YOUR_ANTHROPIC_API_KEY

# Force push cleaned history
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push --force
```

### Option 2: Use git filter-branch
```bash
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch ProjectJules/Config/Config.swift" \
  --prune-empty --tag-name-filter cat -- --all

# Edit Config.swift manually after
# Then force push
git push --force --all
```

### Option 3: Allow Secret (NOT Recommended)
If you must allow the secret:
- Visit: https://github.com/mcapace/ai-dating-site/security/secret-scanning/unblock-secret/382XOOpZNoI6ZRQT2ojhNHsBd98
- ⚠️ **Warning**: This still leaves the key in git history, which is insecure

## 🔐 Best Practice: Use Environment Variables

### Update Config.swift to use environment variables:

```swift
enum Config {
    // MARK: - Anthropic (Claude AI)
    static let anthropicAPIKey: String = {
        // First try environment variable
        if let key = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] {
            return key
        }
        // Fallback to placeholder (shouldn't happen in production)
        return "YOUR_ANTHROPIC_API_KEY"
    }()
    
    static let anthropicModel = "claude-sonnet-4-20250514"
}
```

### Then set environment variable:
- **Xcode Scheme**: Edit Scheme → Run → Arguments → Environment Variables
- Add: `ANTHROPIC_API_KEY` = `your-actual-key`
- **CI/CD**: Set as secret in your CI system

## 📋 Current Status

- ✅ API key removed from current `Config.swift`
- ✅ Placeholder added with warning
- ⚠️ API key still in commit history (commit `2dd3761`)
- ⚠️ Need to clean git history or allow secret

## 🚨 Important

1. **Rotate the API key**: The exposed key should be revoked and regenerated in Anthropic console
2. **Clean git history**: Remove from all commits (see options above)
3. **Use environment variables**: Never commit real API keys
4. **Add to .gitignore**: If using local config files

## ✅ After Cleanup

1. Revoke old API key in Anthropic console
2. Generate new API key
3. Set as environment variable (not in code)
4. Clean git history
5. Force push cleaned history

