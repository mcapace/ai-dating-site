# Manual Fix for "Missing package product 'Supabase'"

If the automated fixes don't work, follow these manual steps:

## Method 1: Force Package Resolution (Recommended)

1. **Close Xcode completely** (⌘Q)

2. **Run the fix script:**
   ```bash
   cd /Volumes/Data5TB/ai-dating-site/ProjectJules
   ./fix-packages.sh
   ```

3. **Reopen Xcode** and open `ProjectJules.xcodeproj`

4. **Resolve packages:**
   - File → Packages → Resolve Package Versions
   - Wait 2-5 minutes for packages to download

5. **Build:** Product → Build (⌘B)

## Method 2: Manual Package Re-add

If Method 1 doesn't work:

1. **Remove the existing package:**
   - In Xcode: Project Navigator → Select project (blue icon)
   - Go to "Package Dependencies" tab
   - Select "supabase-swift"
   - Click the "-" button to remove

2. **Re-add the package:**
   - Click "+" button in Package Dependencies
   - Enter URL: `https://github.com/supabase/supabase-swift.git`
   - Select: "Up to Next Major Version" from "2.0.0"
   - Click "Add Package"
   - **Important:** Make sure "Supabase" product is checked (scroll down if needed!)
   - Click "Add Package"

3. **Wait for resolution** (may take a few minutes)

4. **Build:** Product → Build (⌘B)

## Method 3: Check Package Product Name

Sometimes the product name might be different. Try checking what products are available:

1. In Package Dependencies, click on the supabase-swift package
2. Check if the product is named "Supabase" (with capital S)
3. If it's different, update `project.yml` to match

## Verification

After any method, verify the package is working:

1. Check that `import Supabase` works in your Swift files
2. Check that `SupabaseClient` compiles without errors
3. Build should succeed (⌘B)

## Still Not Working?

If none of the above work:

1. Check Xcode version (should be 15.0+)
2. Check internet connection
3. Try with a fresh clone of the repo
4. Check if GitHub is accessible: `curl https://github.com/supabase/supabase-swift`
