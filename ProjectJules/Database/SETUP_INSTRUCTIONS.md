# Database Setup - Copy & Paste Instructions

## Step 1: Run Schema

1. Go to: https://supabase.com/dashboard
2. Select your project → SQL Editor → New query
3. Copy the ENTIRE contents of `schema.sql` below
4. Paste into SQL Editor
5. Click Run (⌘Enter)

## Step 2: Create Storage Buckets

1. Go to Storage → New bucket
2. Create: `avatars` (Public: ✅ Yes)
3. Create: `voice-notes` (Public: ❌ No)

## Step 3: Run Storage Policies

1. Back to SQL Editor → New query
2. Copy ENTIRE contents of `storage-setup.sql`
3. Paste → Run

## Quick Copy Commands

### Schema (from schema.sql):
```bash
# In terminal, run:
cat "$(dirname "$0")/schema.sql" | pbcopy
# Then paste in Supabase SQL Editor
```

### Storage Setup (from storage-setup.sql):
```bash
# In terminal, run:
cat "$(dirname "$0")/storage-setup.sql" | pbcopy
# Then paste in Supabase SQL Editor
```
