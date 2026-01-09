# Fix Xcode Cache Issues (Conflict Markers)

If Xcode is still showing conflict marker errors even though the files are clean, this is an Xcode cache issue.

## Quick Fix Steps

1. **Close Xcode completely** (⌘Q, not just close the window)

2. **Clean Derived Data:**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```

3. **Clean build folder in terminal:**
   ```bash
   cd /Volumes/Data5TB/ai-dating-site/ProjectJules
   rm -rf ~/Library/Developer/Xcode/DerivedData/ProjectJules-*
   ```

4. **Reopen Xcode:**
   - Open `ProjectJules.xcodeproj`
   - Product → Clean Build Folder (Shift+⌘+K)
   - Product → Build (⌘+B)

## Alternative: Reset Xcode Cache

If that doesn't work:

```bash
# Close Xcode first!
killall Xcode

# Remove derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Remove module cache
rm -rf ~/Library/Developer/Xcode/ModuleCache.noindex

# Remove archives (optional)
rm -rf ~/Library/Developer/Xcode/Archives

# Reopen Xcode
open ProjectJules.xcodeproj
```

## Verify Files Are Clean

The files should be clean. Run this to verify:

```bash
cd /Volumes/Data5TB/ai-dating-site/ProjectJules
grep -r "<<<<<<< Updated upstream" Models/ Views/ Services/ --include="*.swift" || echo "✅ No conflict markers found"
```

If this shows "No conflict markers found", the files are clean and the issue is Xcode's cache.

