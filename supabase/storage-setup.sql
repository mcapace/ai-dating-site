-- Supabase Storage Setup for Project Jules
-- Run this in your Supabase SQL Editor after setting up the main schema

-- Create storage bucket for user photos
INSERT INTO storage.buckets (id, name, public)
VALUES ('user-photos', 'user-photos', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for user photos
-- Users can upload their own photos
CREATE POLICY "Users can upload own photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'user-photos' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- Users can view all photos (for matching)
CREATE POLICY "Anyone can view photos"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'user-photos');

-- Users can update their own photos
CREATE POLICY "Users can update own photos"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'user-photos' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- Users can delete their own photos
CREATE POLICY "Users can delete own photos"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'user-photos' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- Note: Photo paths should follow the pattern: {user_id}/{photo_id}.jpg
-- Example: 123e4567-e89b-12d3-a456-426614174000/photo1.jpg

