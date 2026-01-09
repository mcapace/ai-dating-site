#!/bin/bash

# Fix Supabase Package Resolution Issue
# This script clears all caches and forces Xcode to resolve packages

echo "🧹 Fixing Supabase package resolution..."
echo ""

# 1. Clear DerivedData
echo "1. Clearing Xcode DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
echo "   ✅ DerivedData cleared"

# 2. Clear Swift Package Manager caches
echo ""
echo "2. Clearing Swift Package Manager caches..."
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/Library/org.swift.swiftpm
echo "   ✅ SwiftPM caches cleared"

# 3. Clear Xcode user data (optional but thorough)
echo ""
echo "3. Clearing Xcode module cache..."
rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache
echo "   ✅ Module cache cleared"

# 4. Verify Package.resolved exists
echo ""
echo "4. Verifying Package.resolved..."
if [ -f "ProjectJules.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved" ]; then
    echo "   ✅ Package.resolved exists"
    echo "   📦 Supabase package version:"
    grep -A2 "supabase-swift" ProjectJules.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved | grep "version" | head -1
else
    echo "   ⚠️  Package.resolved missing - will be created when packages are resolved"
fi

# 5. Verify project configuration
echo ""
echo "5. Verifying project configuration..."
if grep -q "supabase-swift" project.yml; then
    echo "   ✅ Supabase package configured in project.yml"
else
    echo "   ❌ Supabase package NOT configured in project.yml"
    exit 1
fi

echo ""
echo "✅ All caches cleared!"
echo ""
echo "📝 Next steps (must be done in Xcode):"
echo ""
echo "1. Close Xcode completely (⌘Q if it's open)"
echo "2. Reopen ProjectJules.xcodeproj"
echo "3. Wait for Xcode to index (may take a minute)"
echo "4. Go to: File → Packages → Resolve Package Versions"
echo "5. Wait for packages to download (may take 2-5 minutes)"
echo "6. If that doesn't work:"
echo "   - File → Packages → Reset Package Caches"
echo "   - Then: File → Packages → Resolve Package Versions again"
echo "7. Product → Clean Build Folder (Shift+⌘+K)"
echo "8. Product → Build (⌘B)"
echo ""
echo "⚠️  If packages still don't resolve, try:"
echo "   - Check internet connection"
echo "   - Try manually adding package:"
echo "     Project → Package Dependencies → + →"
echo "     URL: https://github.com/supabase/supabase-swift.git"
echo "     Version: Up to Next Major Version from 2.0.0"
echo "     Product: Supabase"

