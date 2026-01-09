# How to Access "Edit Scheme" in Xcode

## 🎯 Quick Methods (3 Ways)

### Method 1: Keyboard Shortcut (Fastest)
1. Make sure Xcode has focus (click on Xcode window)
2. Press: **⌘<** (Command + Less Than key)
   - The **<** key is usually next to the **M** key on most keyboards
   - On some keyboards, it might be **⌘,** (Command + Comma) - but that's Settings
   - The correct shortcut is **⌘<** which opens Edit Scheme

### Method 2: Menu Bar (Easiest to Remember)
1. Click **Product** in the menu bar at the top
2. Click **Scheme** → **Edit Scheme...**
   - If you see "Manage Schemes..." first, click it, then select your scheme and click "Edit"
   - Or directly: Product → Scheme → Edit Scheme...

### Method 3: Toolbar (Visual)
1. Look at the toolbar near the top of Xcode
2. Next to the **Stop/Run** buttons, you'll see a dropdown showing your scheme (e.g., "ProjectJules" or "iPhone 15 Pro")
3. **Right-click** on that scheme name
4. Select **Edit Scheme...**

## 📸 Visual Guide

```
Xcode Window Layout:
┌─────────────────────────────────────────────────────────┐
│ [File] [Edit] [View] [Find] [Navigate] [Editor] [Product] │ ← Menu Bar
├─────────────────────────────────────────────────────────┤
│  [▶️]  [⏹️]  ProjectJules  >  iPhone 15 Pro  >  Any...  │ ← Toolbar (Method 3)
├─────────────────────────────────────────────────────────┤
│ Project Navigator (Left Sidebar)                        │
│                                                          │
│ 📁 ProjectJules (blue icon)                             │
│   📁 App                                                │
│   📁 DesignSystem                                       │
│   ...                                                   │
└─────────────────────────────────────────────────────────┘
```

## 🔍 Step-by-Step: Method 2 (Menu Bar) - Recommended

### Step 1: Open Xcode
- Make sure `ProjectJules.xcodeproj` is open

### Step 2: Click Product Menu
- At the very top of your screen, click **"Product"**
- It's in the menu bar (next to Navigate, Editor, etc.)

### Step 3: Find Scheme Submenu
- In the Product menu, hover over **"Scheme"**
- A submenu will appear

### Step 4: Click Edit Scheme
- Click **"Edit Scheme..."** (it might just say "Edit Scheme")

## 📋 Once You're in Edit Scheme

After clicking Edit Scheme, you'll see a dialog with:

### Left Sidebar:
- **Run** ← Click this one!
- Test
- Profile
- Analyze
- Archive

### Top Tabs:
- Info
- Options
- **Arguments** ← Click this tab!
- Diagnostics

### In Arguments Tab:
- **Environment Variables** section (expand it)
- Click the **+** button
- Add: `ANTHROPIC_API_KEY` = `your-key-here`

## 🎯 Quick Path Summary

**Fastest**: Press **⌘<** (Command + Less Than)

**Menu Path**: 
```
Product → Scheme → Edit Scheme... → Run (left) → Arguments (tab) → Environment Variables
```

**Toolbar**: 
```
Right-click scheme name in toolbar → Edit Scheme... → Run → Arguments → Environment Variables
```

## ⚠️ Troubleshooting

### "I don't see Product menu"
- Make sure Xcode window has focus (click on Xcode)
- Make sure you're not in a different app

### "I see Product but no Scheme"
- You might be in Xcode 14 or earlier
- Try: **Product** → **Scheme** → **Manage Schemes...**
- Then select "ProjectJules" and click "Edit"

### "Keyboard shortcut doesn't work"
- Make sure Xcode window is active (clicked on)
- Try Method 2 (Menu Bar) instead
- Some keyboard layouts use different keys

### "I'm in Xcode but can't find it"
1. Click anywhere in the Xcode window (to give it focus)
2. Look at the very top menu bar (not Xcode's toolbar, but macOS menu bar)
3. You should see: **File Edit View Find Navigate Editor Product** etc.
4. Click **Product** → **Scheme** → **Edit Scheme...**

## 📝 After Opening Edit Scheme

Once the "Edit Scheme" dialog opens:

1. **Left sidebar**: Make sure **"Run"** is selected (it usually is by default)
2. **Top tabs**: Click **"Arguments"** tab
3. **Scroll down** to find **"Environment Variables"** section
4. **Click the +** button (bottom left of Environment Variables section)
5. **Add**:
   - Name: `ANTHROPIC_API_KEY`
   - Value: `YOUR_ANTHROPIC_API_KEY_HERE`
6. **Click Close** button
7. **Run app** (⌘R) - Keys are now available!

## 🎯 Visual Checklist

- [ ] Xcode is open with ProjectJules project
- [ ] Clicked "Product" in menu bar (top of screen)
- [ ] Hovered over "Scheme"
- [ ] Clicked "Edit Scheme..."
- [ ] Selected "Run" in left sidebar (should be selected by default)
- [ ] Clicked "Arguments" tab at top
- [ ] Found "Environment Variables" section
- [ ] Clicked + button
- [ ] Added ANTHROPIC_API_KEY with your key value
- [ ] Clicked "Close"
- [ ] Built and ran app (⌘R)

---

**Need more help?** See `XCODE_ENV_SETUP.md` for detailed screenshots guide.

