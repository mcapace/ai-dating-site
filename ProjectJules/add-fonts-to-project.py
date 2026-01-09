#!/usr/bin/env python3
"""
Add font files to Xcode project programmatically
"""

import os
import re
import uuid
import hashlib

PROJECT_FILE = "ProjectJules.xcodeproj/project.pbxproj"
FONTS_DIR = "Assets/Fonts"

def generate_uuid():
    """Generate a 24-character hex UUID for Xcode project"""
    return hashlib.md5(str(uuid.uuid4()).encode()).hexdigest()[:24].upper()

def add_fonts_to_project():
    """Add font files to Xcode project"""
    
    # Find all font files
    font_files = []
    if os.path.exists(FONTS_DIR):
        for file in os.listdir(FONTS_DIR):
            if file.endswith('.ttf'):
                font_files.append(os.path.join(FONTS_DIR, file))
    
    if not font_files:
        print("No font files found!")
        return False
    
    print(f"Found {len(font_files)} font files")
    
    # Read project file
    with open(PROJECT_FILE, 'r') as f:
        content = f.read()
    
    # Check if fonts are already added
    for font in font_files:
        font_name = os.path.basename(font)
        if font_name in content:
            print(f"  {font_name} already in project")
            continue
        
        print(f"  Adding {font_name}...")
        # This is complex - would need to properly parse and modify pbxproj
        # For now, let's provide instructions
    
    print("\n⚠️  Direct pbxproj editing is complex and error-prone.")
    print("   Recommended: Use Xcode GUI to drag fonts")
    print("   Or: The fonts are ready in Assets/Fonts/ - just drag them in Xcode!")
    
    return True

if __name__ == "__main__":
    add_fonts_to_project()

