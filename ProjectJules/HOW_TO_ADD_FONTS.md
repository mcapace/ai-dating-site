# How to Drag Fonts into Xcode - Step by Step

## Quick Steps (2 minutes)

### Step 1: Open Finder
1. Press **⌘ + Space** to open Spotlight
2. Type "Finder" and press Enter
3. Or click the Finder icon in your Dock

### Step 2: Navigate to Fonts Folder
1. In Finder, press **⌘ + Shift + G** (Go to Folder)
2. Paste this path:
   ```
   /Volumes/Data5TB/ai-dating-site/ProjectJules/Assets/Fonts
   ```
3. Press Enter

**OR** navigate manually:
- Click "Data5TB" in sidebar
- Go to: `ai-dating-site` → `ProjectJules` → `Assets` → `Fonts`

### Step 3: Select All Font Files
1. You should see 5 files:
   - Inter-Medium.ttf
   - Inter-Regular.ttf
   - Inter-SemiBold.ttf
   - PlayfairDisplay-Regular.ttf
   - PlayfairDisplay-SemiBold.ttf
2. Press **⌘ + A** to select all 5 files
3. All files should be highlighted/selected

### Step 4: Drag to Xcode
1. **Make sure Xcode is open** with ProjectJules.xcodeproj
2. **Click and hold** on one of the selected font files
3. **Drag** them to Xcode's Project Navigator (left sidebar)
4. **Drop** them into the `Assets` folder (or anywhere in the project tree)
   - You'll see a blue line showing where you're dropping

### Step 5: Configure in Dialog
When you drop, a dialog will appear:

1. **"Copy items if needed"** - ✅ Check this box
2. **"Add to targets"** - ✅ Check "ProjectJules"
3. Click **"Finish"** button

## Visual Guide

```
Finder Window                    Xcode Window
┌─────────────────┐            ┌─────────────────┐
│ Fonts Folder    │            │ ProjectJules     │
│                 │            │ ├── App         │
│ ✓ Inter-*.ttf   │  ────Drag──→ │ ├── Assets     │ ← Drop here
│ ✓ Playfair*.ttf │            │ ├── Config       │
│                 │            │ └── ...          │
└─────────────────┘            └─────────────────┘
```

## Alternative: Add Files Menu

If dragging doesn't work:

1. In **Xcode**, right-click on the **`Assets`** folder (or project root)
2. Select **"Add Files to 'ProjectJules'..."**
3. Navigate to the Fonts folder:
   - Click "Data5TB" in sidebar
   - Navigate: `ai-dating-site` → `ProjectJules` → `Assets` → `Fonts`
4. Select all 5 .ttf files (⌘A)
5. In the dialog:
   - ✅ Check "Copy items if needed"
   - ✅ Check "ProjectJules" under "Add to targets"
6. Click **"Add"**

## Verify It Worked

After adding:

1. In Xcode, you should see the font files appear in the Project Navigator
2. Click on any font file (e.g., `Inter-Regular.ttf`)
3. Look at the right sidebar (File Inspector - press ⌘⌥1 if not visible)
4. Under **"Target Membership"**, you should see:
   - ✅ **ProjectJules** (checked)

## Troubleshooting

**"I can't see the Assets folder in Xcode"**
- The Assets folder might be collapsed - click the triangle to expand
- Or drop the fonts anywhere in the project tree

**"The dialog doesn't show 'Copy items if needed'"**
- That's OK - just make sure "ProjectJules" target is checked
- Click "Finish"

**"Fonts don't appear after adding"**
- Make sure they're in the Project Navigator (left sidebar)
- Check Target Membership (right sidebar when font is selected)
- Clean build: Product → Clean Build Folder (⇧⌘K)
- Build again: Product → Build (⌘B)

## That's It!

Once the fonts are in Xcode and have the target checked, they'll work automatically. The app will use:
- **Playfair Display** for headlines
- **Inter** for body text

No code changes needed - just build and run! (⌘R)

