# Font Files Missing - Setup Required

## Problem
The font configuration in `Typography.swift` and `Info.plist` is set up, but the actual font files (.ttf) are missing from your project.

## Fonts Needed
You need to download and add these font files to your Xcode project:

### Playfair Display (Serif)
1. **PlayfairDisplay-Regular.ttf**
   - Download from: https://fonts.google.com/specimen/Playfair+Display
   - Select Regular (400 weight)
   
2. **PlayfairDisplay-SemiBold.ttf**
   - Same page, select SemiBold (600 weight)

### Inter (Sans-serif)
1. **Inter-Regular.ttf**
   - Download from: https://fonts.google.com/specimen/Inter
   - Select Regular (400 weight)

2. **Inter-Medium.ttf**
   - Same page, select Medium (500 weight)

3. **Inter-SemiBold.ttf**
   - Same page, select SemiBold (600 weight)

## Steps to Add Fonts

1. **Download the fonts** from Google Fonts links above

2. **Create a Fonts folder** in your Xcode project:
   - Right-click on ProjectJules in the navigator
   - New Group → Name it "Fonts"

3. **Add font files**:
   - Drag the downloaded .ttf files into the Fonts folder
   - **IMPORTANT**: In the dialog that appears, make sure:
     - ✅ "Copy items if needed" is checked
     - ✅ "Add to targets: ProjectJules" is checked
     - Click "Finish"

4. **Verify Info.plist** (already configured, but double-check):
   - The fonts should be listed in `UIAppFonts` array
   - Current entries:
     - `PlayfairDisplay-Regular.ttf`
     - `PlayfairDisplay-SemiBold.ttf`
     - `Inter-Regular.ttf`
     - `Inter-Medium.ttf`
     - `Inter-SemiBold.ttf`

5. **Verify file names match exactly**:
   - The filenames in your project must match exactly what's in Info.plist
   - Check for typos, spaces, or different casing

6. **Clean build folder**:
   - Product → Clean Build Folder (Shift + Cmd + K)
   - Product → Build (Cmd + B)

## Current Font Configuration

### Available Fonts (in Info.plist):
- ✅ PlayfairDisplay-Regular
- ✅ PlayfairDisplay-SemiBold
- ✅ Inter-Regular
- ✅ Inter-Medium
- ✅ Inter-SemiBold

### Typography.swift Usage:
- **Hero/Title1/Title2**: Using PlayfairDisplay-SemiBold (Medium weight not available)
- **Title3**: Using Inter-SemiBold
- **Body text**: Using Inter-Regular
- **Buttons**: Using Inter-SemiBold
- **Captions/Tags**: Using Inter-Medium

## Troubleshooting

### Fonts still not showing?
1. Check font files are in the project bundle:
   - Select a font file in Xcode
   - Check File Inspector (right panel)
   - Ensure "Target Membership" shows ProjectJules is checked

2. Verify font names in code match exactly:
   - Font names in `Typography.swift` must match the PostScript name
   - Check by opening the font file and looking at its properties

3. Clean derived data:
   - Xcode → Preferences → Locations
   - Click arrow next to Derived Data path
   - Delete the folder for your project
   - Rebuild

4. Restart Xcode if fonts still don't appear

## Alternative: Use System Fonts
If you can't get custom fonts working, the code has fallback system fonts that will be used automatically if custom fonts fail to load.

