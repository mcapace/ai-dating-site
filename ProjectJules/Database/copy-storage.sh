#!/bin/bash
# Copy storage-setup.sql to clipboard

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cat "$SCRIPT_DIR/storage-setup.sql" | pbcopy
echo "✅ storage-setup.sql copied to clipboard!"
echo "   Now paste it into Supabase SQL Editor"
