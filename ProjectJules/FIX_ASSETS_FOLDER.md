# Fix: Assets Folder Not Showing in Xcode

## ✅ Problem Fixed

The Assets folder exists on disk but wasn't included in the Xcode project. I've updated `project.yml` to include it as a resource folder.

## 🔄 What Was Changed

Updated `project.yml` to include Assets as a folder resource instead of individual font files:

```yaml
resources:
  - path: Assets
    type: folder
```

This makes the entire Assets folder visible in Xcode's Project Navigator.

## ✅ Next Steps

### Option 1: Project Already Regenerated
The project was regenerated with `xcodegen generate`. If you've already opened Xcode:

1. **Close Xcode completely** (⌘Q)
2. **Reopen** `ProjectJules.xcodeproj`
3. **Verify**: You should now see the `Assets` folder in the Project Navigator (left sidebar)

### Option 2: If Assets Still Doesn't Show

If the Assets folder still doesn't appear after reopening:

1. **Right-click on ProjectJules** (blue icon at top of Project Navigator)
2. Select **Add Files to "ProjectJules"...**
3. Navigate to the ProjectJules directory in Finder
4. Select the **Assets** folder
5. **Important Options:**
   - ✅ **"Create folder references"** (for resources) OR **"Create groups"** (for organization)
   - ✅ **"Copy items if needed"** - Make sure this is checked
   - ✅ **"Add to targets: ProjectJules"** - Make sure this is checked
6. Click **Add**

### Option 3: Manual Addition in Finder

If you prefer to drag and drop:

1. **Open Finder** and navigate to `/Volumes/Data5TB/ai-dating-site/ProjectJules/`
2. **Open Xcode** with the project open
3. **Drag the Assets folder** from Finder into Xcode's Project Navigator
4. Drop it in the appropriate location (usually at the top level, same level as App, Views, etc.)
5. In the dialog that appears:
   - ✅ **"Copy items if needed"** - Check this
   - ✅ **"Create groups"** - Select this (for better organization)
   - ✅ **"Add to targets: ProjectJules"** - Check this
6. Click **Finish**

## 🔍 Verify Fonts Are Included

After Assets folder is visible:

1. **Expand Assets** in Project Navigator
2. **Expand Fonts** folder
3. **Verify you see all 5 fonts:**
   - Inter-Medium.ttf
   - Inter-Regular.ttf
   - Inter-SemiBold.ttf
   - PlayfairDisplay-Regular.ttf
   - PlayfairDisplay-SemiBold.ttf

4. **Check Build Phases:**
   - Select **ProjectJules** target
   - Click **Build Phases** tab
   - Expand **Copy Bundle Resources**
   - Verify all 5 fonts are listed

## ✅ Done!

Once Assets folder is visible and fonts are in Copy Bundle Resources, your fonts will be included in the app bundle!

