#!/bin/bash

# Run database schema using Supabase API
# This uses the Supabase REST API to execute SQL

PROJECT_REF="qkegftjmzgtlecjvuhnl"
SCHEMA_FILE="Database/schema.sql"
SERVICE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFrZWdmdGptemd0bGVjanZ1aG5sIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2Nzk5MjMwNSwiZXhwIjoyMDgzNTY4MzA1fQ.-V9m8vBYvPnWJ9wUq2DOytqIx8UCkuZhLRSTiU28Awk"

echo "🗄️  Running database schema..."
echo ""

# Read the schema file
if [ ! -f "$SCHEMA_FILE" ]; then
    echo "❌ Schema file not found: $SCHEMA_FILE"
    exit 1
fi

SCHEMA_SQL=$(cat "$SCHEMA_FILE")

# Use Supabase REST API to execute SQL
echo "📝 Executing schema via Supabase API..."
echo ""

RESPONSE=$(curl -s -X POST \
  "https://${PROJECT_REF}.supabase.co/rest/v1/rpc/exec_sql" \
  -H "apikey: ${SERVICE_KEY}" \
  -H "Authorization: Bearer ${SERVICE_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"query\": $(echo "$SCHEMA_SQL" | jq -Rs .)}" 2>&1)

# Actually, let's use psql if available, or provide instructions
if command -v psql &> /dev/null; then
    echo "✅ psql found, attempting direct connection..."
    echo "   (This requires the database password)"
else
    echo "⚠️  psql not found"
    echo ""
    echo "📋 To run the schema, use one of these methods:"
    echo ""
    echo "Method 1: Supabase Dashboard (Easiest)"
    echo "1. Go to: https://supabase.com/dashboard/project/${PROJECT_REF}/sql/new"
    echo "2. Paste the contents of Database/schema.sql"
    echo "3. Click Run"
    echo ""
    echo "Method 2: Using Supabase CLI with psql"
    echo "   Install PostgreSQL client tools, then connect directly"
    echo ""
    echo "The schema SQL is ready in: Database/schema.sql"
fi

