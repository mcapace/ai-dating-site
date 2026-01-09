-- Supabase Storage Bucket Setup
-- Run this in Supabase SQL Editor after creating the storage buckets in the dashboard

-- ============================================
-- STORAGE BUCKETS
-- Create these in Supabase Dashboard > Storage
-- ============================================

-- 1. Create bucket: "avatars" (for user profile photos)
-- 2. Create bucket: "voice-notes" (for spark exchange voice recordings)

-- ============================================
-- STORAGE POLICIES
-- ============================================

-- Avatars bucket policies
CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'avatars' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Anyone can view avatars"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'avatars');

CREATE POLICY "Users can update their own avatar"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'avatars' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can delete their own avatar"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'avatars' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- Voice notes bucket policies
CREATE POLICY "Users can upload their own voice notes"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'voice-notes' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can view voice notes in their matches"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'voice-notes' AND
    EXISTS (
        SELECT 1 FROM public.matches
        WHERE (matches.user1_id = auth.uid() OR matches.user2_id = auth.uid())
        AND (storage.foldername(name))[1] IN (
            SELECT id::text FROM public.users
            WHERE id IN (matches.user1_id, matches.user2_id)
        )
    )
);

CREATE POLICY "Users can delete their own voice notes"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'voice-notes' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- Note: File paths should follow the pattern: {user_id}/{filename}
-- Example avatars: 123e4567-e89b-12d3-a456-426614174000/avatar.jpg
-- Example voice notes: 123e4567-e89b-12d3-a456-426614174000/voice-note-123.m4a

