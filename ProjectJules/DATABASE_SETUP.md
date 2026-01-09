# Database Setup Guide - Project Jules

## Quick Setup Steps

### 1. Run Database Schema

1. **Go to Supabase Dashboard**
   - https://supabase.com/dashboard
   - Select your project (or create one)

2. **Open SQL Editor**
   - Click **SQL Editor** in left sidebar
   - Click **New query**

3. **Copy and Paste Schema**
   - Open `ProjectJules/Database/schema.sql` in a text editor
   - Select all (⌘A) and copy (⌘C)
   - Paste into Supabase SQL Editor
   - Click **Run** (or press ⌘Enter)

4. **Verify Success**
   - You should see "Success. No rows returned"
   - If errors appear, check the error message

### 2. Create Storage Buckets

1. **Go to Storage**
   - Click **Storage** in left sidebar
   - Click **New bucket**

2. **Create `avatars` Bucket**
   - Name: `avatars`
   - Public bucket: ✅ **Yes** (check this)
   - Click **Create bucket**

3. **Create `voice-notes` Bucket**
   - Click **New bucket** again
   - Name: `voice-notes`
   - Public bucket: ❌ **No** (leave unchecked)
   - Click **Create bucket**

### 3. Set Up Storage Policies

1. **Go back to SQL Editor**
   - Click **SQL Editor** → **New query**

2. **Run Storage Setup**
   - Open `ProjectJules/Database/storage-setup.sql`
   - Copy entire contents
   - Paste into SQL Editor
   - Click **Run**

### 4. Verify Database Setup

Run this query in SQL Editor to verify tables were created:

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

**Expected tables:**
- `users`
- `user_profiles`
- `user_preferences`
- `user_photos`
- `neighborhoods`
- `user_neighborhoods`
- `venues`
- `matches`
- `intros`
- `spark_exchanges`
- `scheduled_dates`
- `date_feedback`
- `jules_conversations`
- `user_learning`

### 5. Test Database Connection

The app will automatically connect to Supabase when you:
1. Add your Supabase URL to `Config.swift`
2. Add your Supabase anon key to `Config.swift`
3. Run the app

## Troubleshooting

**"relation already exists" errors:**
- Some tables might already exist
- This is OK, the schema uses `CREATE TABLE IF NOT EXISTS` where possible
- You can ignore these warnings

**RLS Policy errors:**
- If policies fail to create, check that RLS is enabled
- Run: `ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;` for each table

**Storage bucket errors:**
- Make sure buckets are created in Storage dashboard first
- Then run the storage-setup.sql policies

## ✅ Checklist

- [ ] Database schema run successfully
- [ ] `avatars` bucket created (public)
- [ ] `voice-notes` bucket created (private)
- [ ] Storage policies run successfully
- [ ] Verified tables exist (12+ tables)
- [ ] Supabase URL and key added to Config.swift

## 🎯 You're Done!

Once the database is set up, your app can:
- Authenticate users
- Store profiles and photos
- Create matches
- Store conversations
- Manage dates and feedback

