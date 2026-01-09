#!/bin/bash

# Script to help set up Xcode project structure for Project Jules
# Note: This creates the directory structure. You'll still need to create the .xcodeproj in Xcode.

set -e

PROJECT_NAME="ProjectJules"
PROJECT_DIR="ios/${PROJECT_NAME}"

echo "Creating Xcode project structure for ${PROJECT_NAME}..."

# Create main directories
mkdir -p "${PROJECT_DIR}/App"
mkdir -p "${PROJECT_DIR}/DesignSystem"
mkdir -p "${PROJECT_DIR}/Models"
mkdir -p "${PROJECT_DIR}/Services"
mkdir -p "${PROJECT_DIR}/Views/Onboarding"
mkdir -p "${PROJECT_DIR}/Views/Main"
mkdir -p "${PROJECT_DIR}/Views/Match"
mkdir -p "${PROJECT_DIR}/Views/Intros"
mkdir -p "${PROJECT_DIR}/Views/Settings"
mkdir -p "${PROJECT_DIR}/Assets/Fonts"
mkdir -p "${PROJECT_DIR}/Assets/Lottie"
mkdir -p "${PROJECT_DIR}/Assets/Images"
mkdir -p "${PROJECT_DIR}/Resources"

# Create .gitkeep files to preserve empty directories
find "${PROJECT_DIR}" -type d -exec touch {}/.gitkeep \;

echo "✅ Directory structure created!"
echo ""
echo "Next steps:"
echo "1. Open Xcode"
echo "2. Create a new iOS App project named '${PROJECT_NAME}'"
echo "3. Save it in the 'ios/' directory"
echo "4. Move your Swift files into the appropriate directories"
echo "5. Add fonts to Assets/Fonts/"
echo "6. Add Lottie animations to Assets/Lottie/"
echo "7. Configure Config.xcconfig with your API keys"

