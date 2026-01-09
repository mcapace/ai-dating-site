#!/bin/bash

# Get Supabase project credentials
# This script fetches the API keys from your Supabase project

PROJECT_REF="qkegftjmzgtlecjvuhnl"
PROJECT_URL="https://${PROJECT_REF}.supabase.co"

echo "🔑 Getting Supabase Credentials..."
echo ""
echo "Project Reference: $PROJECT_REF"
echo "Project URL: $PROJECT_URL"
echo ""
echo "To get your API keys:"
echo "1. Go to: https://supabase.com/dashboard/project/$PROJECT_REF"
echo "2. Click Settings → API"
echo "3. Copy:"
echo "   - Project URL: $PROJECT_URL"
echo "   - anon public key: (shown in API settings)"
echo ""
echo "Or use the Supabase dashboard to get the keys automatically."
echo ""
echo "Once you have the keys, I can update Config.swift automatically!"
echo ""
echo "Alternatively, you can run:"
echo "  supabase projects api-keys --project-ref $PROJECT_REF"

