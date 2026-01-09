#!/bin/bash

# Project Jules Setup Checklist
# Run this to verify your setup

echo "🔍 Project Jules Setup Checklist"
echo "=================================="
echo ""

# Check Xcode
echo "1. Checking Xcode..."
if command -v xcodebuild &> /dev/null; then
    echo "   ✅ Xcode found: $(xcodebuild -version | head -n 1)"
else
    echo "   ❌ Xcode not found"
fi
echo ""

# Check available simulators
echo "2. Available iOS Simulators:"
xcrun simctl list devices available | grep -i "iphone" | head -5 | sed 's/^/   /'
echo ""

# Check project files
echo "3. Checking project files..."
if [ -f "Config/Config.swift" ]; then
    echo "   ✅ Config.swift exists"
    
    # Check if API keys are still placeholders
    if grep -q "YOUR_PROJECT_ID" Config/Config.swift; then
        echo "   ⚠️  API keys need to be configured"
    else
        echo "   ✅ API keys appear to be configured"
    fi
else
    echo "   ❌ Config.swift not found"
fi
echo ""

# Check database files
echo "4. Checking database files..."
if [ -f "Database/schema.sql" ]; then
    echo "   ✅ schema.sql exists"
    echo "   📝 Remember to run this in Supabase SQL Editor"
else
    echo "   ❌ schema.sql not found"
fi

if [ -f "Database/storage-setup.sql" ]; then
    echo "   ✅ storage-setup.sql exists"
else
    echo "   ❌ storage-setup.sql not found"
fi
echo ""

# Check Swift files
echo "5. Checking Swift source files..."
SWIFT_COUNT=$(find . -name "*.swift" -not -path "./.build/*" | wc -l | tr -d ' ')
echo "   ✅ Found $SWIFT_COUNT Swift files"
echo ""

echo "📋 Next Steps:"
echo "   1. In Xcode: Select iPhone 17 Pro simulator"
echo "   2. In Xcode: Configure signing (Project → Signing & Capabilities → Select Team)"
echo "   3. In Xcode: Add API keys to Config/Config.swift"
echo "   4. In Xcode: Build (⌘B) to check for errors"
echo "   5. In Supabase: Run Database/schema.sql in SQL Editor"
echo "   6. In Supabase: Create storage buckets (avatars, voice-notes)"
echo "   7. In Xcode: Run app (⌘R)"
echo ""
echo "📚 See QUICK_FIX.md for detailed instructions"

