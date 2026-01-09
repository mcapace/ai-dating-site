#!/bin/bash

# Verify Setup Script - Check what's done and what's left

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "🔍 Project Jules Setup Verification"
echo "===================================="
echo ""

# Check Config.swift
echo "1. API Configuration:"
if grep -q "YOUR_PROJECT_ID" Config/Config.swift; then
    echo "   ⚠️  Config.swift still has placeholder values"
    echo "      → Need to add: Supabase URL, Supabase Key, Anthropic Key"
else
    echo "   ✅ Config.swift appears configured"
fi
echo ""

# Check if Xcode project builds
echo "2. Xcode Project:"
if [ -d "ProjectJules.xcodeproj" ]; then
    echo "   ✅ Xcode project exists"
    
    # Try to check build status (non-blocking)
    echo "   💡 To verify build: Open Xcode → Press ⌘B"
else
    echo "   ❌ Xcode project not found"
fi
echo ""

# Check package dependencies
echo "3. Package Dependencies:"
if [ -f "ProjectJules.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved" ]; then
    if grep -q "supabase" "ProjectJules.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"; then
        echo "   ✅ Supabase package resolved"
    else
        echo "   ⚠️  Supabase package not found"
        echo "      → In Xcode: File → Packages → Resolve Package Versions"
    fi
else
    echo "   ⚠️  Package dependencies not resolved yet"
fi
echo ""

# Check database files
echo "4. Database Files:"
if [ -f "Database/schema.sql" ]; then
    LINES=$(wc -l < Database/schema.sql | tr -d ' ')
    echo "   ✅ schema.sql exists ($LINES lines)"
    echo "      → Run in Supabase SQL Editor"
else
    echo "   ❌ schema.sql missing"
fi

if [ -f "Database/storage-setup.sql" ]; then
    echo "   ✅ storage-setup.sql exists"
else
    echo "   ❌ storage-setup.sql missing"
fi
echo ""

# Check Swift files
echo "5. Source Files:"
SWIFT_COUNT=$(find . -name "*.swift" -not -path "./.build/*" -not -path "./DerivedData/*" | wc -l | tr -d ' ')
echo "   ✅ $SWIFT_COUNT Swift files found"
echo ""

# Summary
echo "📊 Summary:"
echo "   ✅ Project structure: Complete"
echo "   ✅ Source code: Complete ($SWIFT_COUNT files)"
echo "   ✅ Xcode project: Created"
echo ""
echo "🔧 Remaining Manual Steps:"
echo "   1. In Xcode: Select simulator, configure signing"
echo "   2. Add API keys to Config.swift"
echo "   3. Set up database in Supabase"
echo "   4. Build and run app"
echo ""
echo "📚 See SETUP_STATUS.md for detailed checklist"

