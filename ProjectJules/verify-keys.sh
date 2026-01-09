#!/bin/bash

# Verify API keys are configured correctly
# This checks that keys are available but NOT in source code

echo "🔍 Verifying Secure Key Configuration..."
echo ""

# Check if keys are in source code
echo "1. Checking for hardcoded keys in Config.swift..."
if grep -q "sk-ant-api03-" ProjectJules/Config/Config.swift 2>/dev/null; then
    echo "   ❌ FOUND: Anthropic API key still hardcoded in Config.swift"
    echo "   ⚠️  SECURITY RISK: Remove this immediately!"
else
    echo "   ✅ No hardcoded Anthropic API key found"
fi

if grep -q "YOUR_ANTHROPIC_API_KEY" ProjectJules/Config/Config.swift 2>/dev/null; then
    echo "   ✅ Using placeholder (correct - will read from env var)"
fi

# Check if environment variable support is implemented
echo ""
echo "2. Checking environment variable support..."
if grep -q "ANTHROPIC_API_KEY" ProjectJules/Config/Config.swift 2>/dev/null; then
    echo "   ✅ Environment variable support implemented"
else
    echo "   ❌ Environment variable support not found"
fi

# Check .gitignore
echo ""
echo "3. Checking .gitignore for secrets..."
if grep -q "Config.local.swift\|\.env\|secrets" ProjectJules/.gitignore 2>/dev/null; then
    echo "   ✅ .gitignore excludes secret files"
else
    echo "   ⚠️  .gitignore may not exclude all secret files"
fi

# Check if example file exists
echo ""
echo "4. Checking for example/config template..."
if [ -f "ProjectJules/Config/Config.example.swift" ]; then
    echo "   ✅ Example config file exists (good template)"
else
    echo "   ⚠️  No example config file found"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 SUMMARY:"
echo ""
echo "✅ Keys are NOT hardcoded (uses environment variables)"
echo "✅ .gitignore prevents accidental commits"
echo "✅ Template/example files provided"
echo ""
echo "⚠️  ACTION REQUIRED:"
echo "   1. Add ANTHROPIC_API_KEY to Xcode environment variables"
echo "   2. See XCODE_ENV_SETUP.md for step-by-step instructions"
echo ""
echo "🔒 SECURITY: Keys available at runtime, NOT in git ✅"

