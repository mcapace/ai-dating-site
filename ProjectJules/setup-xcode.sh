#!/bin/bash

# Xcode Project Setup Script for Project Jules
# This script helps prepare the project structure for Xcode

set -e

PROJECT_NAME="ProjectJules"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Setting up Project Jules for Xcode..."
echo ""

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed. Please install Xcode from the App Store."
    exit 1
fi

echo "✅ Xcode found: $(xcodebuild -version | head -n 1)"
echo ""

# Check project structure
echo "📁 Checking project structure..."

REQUIRED_DIRS=(
    "App"
    "DesignSystem"
    "Models"
    "Services"
    "Views"
    "Config"
    "Database"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$SCRIPT_DIR/$dir" ]; then
        echo "  ✅ $dir/"
    else
        echo "  ⚠️  $dir/ not found"
    fi
done

echo ""
echo "📝 Next steps:"
echo ""
echo "1. Open Xcode"
echo "2. File → New → Project"
echo "3. Select 'iOS App'"
echo "4. Configure:"
echo "   - Product Name: $PROJECT_NAME"
echo "   - Interface: SwiftUI"
echo "   - Language: Swift"
echo "5. Save in: $SCRIPT_DIR"
echo ""
echo "6. After creating the project:"
echo "   - File → Add Package Dependencies"
echo "   - Add: https://github.com/supabase/supabase-swift"
echo ""
echo "7. Drag all Swift files from these folders into Xcode:"
echo "   - App/"
echo "   - DesignSystem/"
echo "   - Models/"
echo "   - Services/"
echo "   - Views/"
echo "   - Config/"
echo ""
echo "8. Configure Config.swift with your API keys"
echo ""
echo "9. Add fonts to Assets/Fonts/ and update Info.plist"
echo ""
echo "📚 See SETUP.md for detailed instructions"
echo ""
echo "✨ Setup guide complete!"

