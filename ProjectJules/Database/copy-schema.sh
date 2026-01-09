#!/bin/bash
# Copy schema.sql to clipboard for easy pasting into Supabase

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cat "$SCRIPT_DIR/schema.sql" | pbcopy
echo "✅ schema.sql copied to clipboard!"
echo "   Now paste it into Supabase SQL Editor"
