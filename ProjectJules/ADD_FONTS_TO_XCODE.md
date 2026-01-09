# How to Add Fonts to Xcode (If Assets Folder Not Visible)

The fonts are already downloaded at: `ProjectJules/Assets/Fonts/`

## Option 1: Regenerate Xcode Project (Recommended)

1. **Close Xcode completely** (⌘Q)

2. **Regenerate the project:**
   ```bash
   cd /Volumes/Data5TB/ai-dating-site/ProjectJules
   xcodegen generate
   ```

3. **Reopen Xcode:**
   - Open `ProjectJules.xcodeproj`
   - The Assets folder should now be visible

## Option 2: Manually Create Assets Folder in Xcode

If the Assets folder still doesn't appear after regenerating:

1. **Right-click on "ProjectJules"** (the blue project icon) in the navigator

2. **Select "New Group"** and name it **"Assets"**

3. **Right-click on the "Assets" group** and select **"New Group"** again, name it **"Fonts"**

4. **Add the font files:**
   - Right-click on the "Fonts" group
   - Select **"Add Files to 'ProjectJules'..."**
   - Navigate to: `ProjectJules/Assets/Fonts/`
   - Select all 5 font files:
     - `Inter-Medium.ttf`
     - `Inter-Regular.ttf`
     - `Inter-SemiBold.ttf`
     - `PlayfairDisplay-Regular.ttf`
     - `PlayfairDisplay-SemiBold.ttf`
   - **IMPORTANT:** Check:
     - ✅ "Copy items if needed" (if files aren't already there)
     - ✅ "Add to targets: ProjectJules" (very important!)
   - Click "Add"

5. **Verify fonts are registered in Info.plist:**
   - Click on `Info.plist` in the navigator
   - Look for "Fonts provided by application" (or "UIAppFonts")
   - It should list all 5 fonts
   - If not, add them manually:
     ```xml
     <key>UIAppFonts</key>
     <array>
         <string>PlayfairDisplay-Regular.ttf</string>
         <string>PlayfairDisplay-SemiBold.ttf</string>
         <string>Inter-Regular.ttf</string>
         <string>Inter-Medium.ttf</string>
         <string>Inter-SemiBold.ttf</string>
     </array>
     ```

## Option 3: Drag & Drop (Simplest)

1. **Open Finder** and navigate to:
   ```
   /Volumes/Data5TB/ai-dating-site/ProjectJules/Assets/Fonts/
   ```

2. **In Xcode:**
   - Make sure you can see the Project Navigator (left sidebar)
   - If Assets folder doesn't exist, create it (Option 2, steps 1-3)
   - **Drag the Fonts folder from Finder** into the Assets group in Xcode
   - **IMPORTANT:** When the dialog appears, check:
     - ✅ "Copy items if needed"
     - ✅ "Create groups" (not "Create folder references")
     - ✅ "Add to targets: ProjectJules"
   - Click "Finish"

## Verify Fonts Are Working

1. **Build the project** (⌘B)
2. **Run the app** (⌘R)
3. **Check the console** - there should be NO font loading warnings

## Font Files Location

All fonts are already downloaded here:
```
/Volumes/Data5TB/ai-dating-site/ProjectJules/Assets/Fonts/
```

Files:
- ✅ Inter-Medium.ttf (296KB)
- ✅ Inter-Regular.ttf (296KB)
- ✅ Inter-SemiBold.ttf (296KB)
- ✅ PlayfairDisplay-Regular.ttf (297KB)
- ✅ PlayfairDisplay-SemiBold.ttf (297KB)

## Troubleshooting

**Fonts still not showing up in Xcode?**
- Try restarting Xcode
- Check that files aren't hidden (View → Show Package Contents)
- Verify the font files exist in Finder

**Fonts in Info.plist but not working?**
- Make sure fonts are added to the target
- Check that file names in Info.plist match exactly (case-sensitive)
- Clean build folder (Shift+⌘+K) and rebuild

**Xcode says "font not found"?**
- Verify the font file name matches exactly what's in Info.plist
- Check that the font file is in the app bundle (Project → Build Phases → Copy Bundle Resources)

