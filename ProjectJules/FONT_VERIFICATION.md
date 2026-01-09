# Font Setup Verification Guide

## ✅ Current Status

The fonts are already:
- ✅ Downloaded to `Assets/Fonts/`
- ✅ Configured in `project.yml` as resources
- ✅ Listed in `Info.plist` under `UIAppFonts`
- ✅ Project regenerated with `xcodegen`

## 🔍 Verify Fonts in Xcode

### Step 1: Open Xcode Project
1. Open `ProjectJules.xcodeproj` in Xcode

### Step 2: Check Build Phases
1. In Xcode, click the **Project Navigator** (left sidebar)
2. Select the **ProjectJules** project (blue icon at top)
3. Select the **ProjectJules** target (under TARGETS)
4. Click the **Build Phases** tab
5. Expand **Copy Bundle Resources**
6. **Verify you see all 5 font files:**
   - `Inter-Medium.ttf`
   - `Inter-Regular.ttf`
   - `Inter-SemiBold.ttf`
   - `PlayfairDisplay-Regular.ttf`
   - `PlayfairDisplay-SemiBold.ttf`

### Step 3: If Fonts Are Missing from Build Phases

If the fonts are NOT in "Copy Bundle Resources", manually add them:

1. Click the **+** button at the bottom of "Copy Bundle Resources"
2. Click **Add Other...** → **Add Files...**
3. Navigate to `Assets/Fonts/`
4. Select all 5 font files:
   - Inter-Medium.ttf
   - Inter-Regular.ttf
   - Inter-SemiBold.ttf
   - PlayfairDisplay-Regular.ttf
   - PlayfairDisplay-SemiBold.ttf
5. Make sure **"Copy items if needed"** is checked
6. Make sure **"Create groups"** is selected (not "Create folder references")
7. Click **Add**

### Step 4: Verify Info.plist

1. In Xcode, find `Info.plist` in the Project Navigator
2. Open it
3. Look for **"Fonts provided by application"** or **"UIAppFonts"**
4. Verify all 5 fonts are listed:
   - PlayfairDisplay-Regular.ttf
   - PlayfairDisplay-SemiBold.ttf
   - Inter-Regular.ttf
   - Inter-Medium.ttf
   - Inter-SemiBold.ttf

## 🧪 Test Fonts in App

### Option 1: Check at Runtime
Add this to your app to see available fonts:

```swift
// Add this temporarily to viewDidLoad or onAppear
for family in UIFont.familyNames.sorted() {
    let fonts = UIFont.fontNames(forFamilyName: family)
    print("\(family): \(fonts)")
}
```

Look for:
- `PlayfairDisplay-Regular`
- `PlayfairDisplay-SemiBold`
- `Inter-Regular`
- `Inter-Medium`
- `Inter-SemiBold`

### Option 2: Visual Test
Run the app and check if custom fonts are rendering. The Typography system uses:
- **Headlines**: Playfair Display (SemiBold, Regular)
- **Body**: Inter (Regular, Medium, SemiBold)

## 🔧 Troubleshooting

### Fonts not showing?
1. **Clean Build Folder**: ⌘⇧K
2. **Delete Derived Data**: Xcode → Settings → Locations → Derived Data → Delete
3. **Rebuild**: ⌘B
4. **Run on device/simulator**: ⌘R

### Still not working?
1. Verify font file names match exactly (case-sensitive!)
2. Check Info.plist font names match file names exactly
3. Make sure fonts are added to "Copy Bundle Resources", not just file references

## 📝 Quick Fix Script

If you want to force-regenerate and verify:

```bash
cd /Volumes/Data5TB/ai-dating-site/ProjectJules
xcodegen generate
```

Then open Xcode and verify fonts are in Build Phases as described above.

