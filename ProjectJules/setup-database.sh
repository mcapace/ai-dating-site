#!/bin/bash

# Automated Database Setup Script
# This runs the database schema in your Supabase project

PROJECT_REF="qkegftjmzgtlecjvuhnl"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🗄️  Setting up Project Jules Database..."
echo ""

# Wait for project to be ready
echo "⏳ Waiting for project to be fully provisioned..."
for i in {1..30}; do
    STATUS=$(supabase projects list --output json 2>/dev/null | jq -r ".[] | select(.id == \"$PROJECT_REF\") | .status" 2>/dev/null || echo "COMING_UP")
    if [ "$STATUS" = "ACTIVE_HEALTHY" ]; then
        echo "✅ Project is ready!"
        break
    fi
    echo "   Status: $STATUS (waiting...)"
    sleep 10
done

echo ""
echo "📝 Setting up database schema..."
echo ""
echo "Option 1: Use Supabase Dashboard (Recommended)"
echo "1. Go to: https://supabase.com/dashboard/project/$PROJECT_REF/sql/new"
echo "2. Copy the contents of Database/schema.sql"
echo "3. Paste and Run"
echo ""
echo "Option 2: Use Supabase CLI (if project is linked)"
echo "Run: supabase db push"
echo ""
echo "📋 To copy schema to clipboard, run:"
echo "   ./Database/copy-schema.sh"
echo ""
echo "🗂️  After schema is run, create storage buckets:"
echo "1. Go to: https://supabase.com/dashboard/project/$PROJECT_REF/storage/buckets"
echo "2. Create bucket: 'avatars' (Public: Yes)"
echo "3. Create bucket: 'voice-notes' (Public: No)"
echo "4. Then run: ./Database/copy-storage.sh"
echo ""

