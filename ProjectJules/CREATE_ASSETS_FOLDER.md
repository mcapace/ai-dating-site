# Create Assets Folder in Xcode

## Quick Method (30 seconds)

Since the Assets folder might not appear automatically, here's how to create it:

### Step 1: Create the Folder
1. In Xcode's left sidebar, **right-click** on **"ProjectJules"** (the blue project icon at the top)
2. Select **"New Group"**
3. Type: **"Assets"**
4. Press **Enter**

### Step 2: Add Fonts
1. The **Assets** folder should now appear in your project
2. **Drag the 5 font files** from Finder into the **Assets** folder
3. In the dialog:
   - ✅ Check **"Copy items if needed"**
   - ✅ Check **"ProjectJules"** under "Add to targets"
   - Click **"Finish"**

## Alternative: Just Drag to Project Root

You don't actually need an Assets folder! You can:

1. **Drag the 5 font files** directly to **"ProjectJules"** (the blue icon)
2. They'll work fine anywhere in the project
3. The important part is that they're added to the target

## After Adding Fonts

1. Click on any font file in Xcode
2. Check the right sidebar (File Inspector - ⌘⌥1)
3. Under **"Target Membership"**, ensure **"ProjectJules"** is checked ✅

That's it! The fonts will work regardless of which folder they're in.

