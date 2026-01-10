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

CREATE POLICY "Avatar images are publicly accessible"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatars');

-- Voice notes bucket policies
CREATE POLICY "Users can upload their own voice notes"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'voice-notes' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can delete their own voice notes"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'voice-notes' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- Voice notes visible to users in same intro
CREATE POLICY "Voice notes accessible to intro participants"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'voice-notes' AND
    EXISTS (
        SELECT 1 FROM public.intros
        WHERE (user1_id = auth.uid() OR user2_id = auth.uid())
        AND (
            (storage.foldername(name))[1] = user1_id::text OR
            (storage.foldername(name))[1] = user2_id::text
        )
    )
);

