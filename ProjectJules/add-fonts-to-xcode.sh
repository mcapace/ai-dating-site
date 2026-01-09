#!/bin/bash

# Helper script to add fonts to Xcode project
# This provides instructions and can verify font setup

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FONT_DIR="$PROJECT_DIR/Assets/Fonts"

echo "🔤 Adding Fonts to Xcode Project"
echo "================================"
echo ""

# Check if fonts exist
if [ ! -d "$FONT_DIR" ]; then
    echo "❌ Fonts directory not found!"
    echo "   Run: ./download-fonts.sh first"
    exit 1
fi

FONT_COUNT=$(ls -1 "$FONT_DIR"/*.ttf 2>/dev/null | wc -l | tr -d ' ')

if [ "$FONT_COUNT" -eq 0 ]; then
    echo "❌ No font files found in Assets/Fonts/"
    echo "   Run: ./download-fonts.sh first"
    exit 1
fi

echo "✅ Found $FONT_COUNT font files:"
ls -1 "$FONT_DIR"/*.ttf | sed 's/^/   - /'
echo ""

echo "📝 To add fonts to Xcode project:"
echo ""
echo "Method 1: Drag and Drop (Easiest)"
echo "   1. Open ProjectJules.xcodeproj in Xcode"
echo "   2. In Finder, navigate to: $FONT_DIR"
echo "   3. Select all .ttf files (⌘A)"
echo "   4. Drag them into Xcode's Assets folder (in Project Navigator)"
echo "   5. In the dialog:"
echo "      ✅ Check 'Copy items if needed'"
echo "      ✅ Select 'ProjectJules' target"
echo "      ✅ Click 'Finish'"
echo ""

echo "Method 2: Add Files Menu"
echo "   1. In Xcode, right-click 'Assets' folder"
echo "   2. Select 'Add Files to \"ProjectJules\"...'"
echo "   3. Navigate to: $FONT_DIR"
echo "   4. Select all .ttf files"
echo "   5. Check 'Copy items if needed'"
echo "   6. Ensure 'ProjectJules' target is selected"
echo "   7. Click 'Add'"
echo ""

echo "✅ Verification:"
echo "   - Fonts are already listed in Info.plist"
echo "   - Once added to Xcode, they'll work immediately"
echo "   - No code changes needed!"
echo ""

echo "🔍 To verify fonts are working:"
echo "   1. Build and run the app (⌘R)"
echo "   2. Check if custom fonts appear in the UI"
echo "   3. If not, verify fonts are in target:"
echo "      - Select a font file in Xcode"
echo "      - Check 'Target Membership' → 'ProjectJules' should be checked"
echo ""

