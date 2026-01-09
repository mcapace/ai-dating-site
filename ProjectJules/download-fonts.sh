#!/bin/bash

# Download and install fonts for Project Jules
# This script downloads Playfair Display and Inter fonts from Google Fonts

set -e

FONT_DIR="Assets/Fonts"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "📥 Downloading fonts for Project Jules..."
echo ""

# Create fonts directory
mkdir -p "$FONT_DIR"

# Download Playfair Display
echo "📥 Downloading Playfair Display..."
PLAYFAIR_URL="https://github.com/google/fonts/raw/main/ofl/playfairdisplay/PlayfairDisplay%5Bwght%5D.ttf"
curl -L -o "$FONT_DIR/PlayfairDisplay-Regular.ttf" "https://github.com/google/fonts/raw/main/ofl/playfairdisplay/static/PlayfairDisplay-Regular.ttf" 2>/dev/null
curl -L -o "$FONT_DIR/PlayfairDisplay-SemiBold.ttf" "https://github.com/google/fonts/raw/main/ofl/playfairdisplay/static/PlayfairDisplay-SemiBold.ttf" 2>/dev/null

if [ -f "$FONT_DIR/PlayfairDisplay-Regular.ttf" ]; then
    echo "   ✅ PlayfairDisplay-Regular.ttf downloaded"
else
    echo "   ⚠️  Failed to download PlayfairDisplay-Regular.ttf"
fi

if [ -f "$FONT_DIR/PlayfairDisplay-SemiBold.ttf" ]; then
    echo "   ✅ PlayfairDisplay-SemiBold.ttf downloaded"
else
    echo "   ⚠️  Failed to download PlayfairDisplay-SemiBold.ttf"
fi

# Download Inter
echo ""
echo "📥 Downloading Inter..."
curl -L -o "$FONT_DIR/Inter-Regular.ttf" "https://github.com/google/fonts/raw/main/ofl/inter/static/Inter-Regular.ttf" 2>/dev/null
curl -L -o "$FONT_DIR/Inter-Medium.ttf" "https://github.com/google/fonts/raw/main/ofl/inter/static/Inter-Medium.ttf" 2>/dev/null
curl -L -o "$FONT_DIR/Inter-SemiBold.ttf" "https://github.com/google/fonts/raw/main/ofl/inter/static/Inter-SemiBold.ttf" 2>/dev/null

if [ -f "$FONT_DIR/Inter-Regular.ttf" ]; then
    echo "   ✅ Inter-Regular.ttf downloaded"
else
    echo "   ⚠️  Failed to download Inter-Regular.ttf"
fi

if [ -f "$FONT_DIR/Inter-Medium.ttf" ]; then
    echo "   ✅ Inter-Medium.ttf downloaded"
else
    echo "   ⚠️  Failed to download Inter-Medium.ttf"
fi

if [ -f "$FONT_DIR/Inter-SemiBold.ttf" ]; then
    echo "   ✅ Inter-SemiBold.ttf downloaded"
else
    echo "   ⚠️  Failed to download Inter-SemiBold.ttf"
fi

echo ""
echo "📊 Font Download Summary:"
FONT_COUNT=$(ls -1 "$FONT_DIR"/*.ttf 2>/dev/null | wc -l | tr -d ' ')
echo "   ✅ $FONT_COUNT font files downloaded"

if [ "$FONT_COUNT" -ge 5 ]; then
    echo ""
    echo "✅ All fonts downloaded successfully!"
    echo ""
    echo "📝 Next steps in Xcode:"
    echo "   1. Open ProjectJules.xcodeproj"
    echo "   2. Right-click Assets folder → Add Files to 'ProjectJules'..."
    echo "   3. Select Assets/Fonts/ folder"
    echo "   4. Check 'Copy items if needed'"
    echo "   5. Ensure 'ProjectJules' target is selected"
    echo "   6. Click Add"
    echo ""
    echo "   Fonts are already listed in Info.plist, so they'll work immediately!"
else
    echo ""
    echo "⚠️  Some fonts failed to download. You can download them manually:"
    echo "   - Playfair Display: https://fonts.google.com/specimen/Playfair+Display"
    echo "   - Inter: https://fonts.google.com/specimen/Inter"
fi

