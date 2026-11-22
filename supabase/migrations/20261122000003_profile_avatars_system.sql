-- ==============================================================================
-- TKMingle v1.5 — Unified Profile Picture & Avatar Management System
-- Migration: 20261122000003_profile_avatars_system.sql
-- ==============================================================================

-- -----------------------------------------------------------------------------
-- 1. Profiles Table Extension
-- -----------------------------------------------------------------------------
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS avatar_type TEXT NOT NULL DEFAULT 'initial'
    CHECK (avatar_type IN ('upload', 'preset', 'initial')),
ADD COLUMN IF NOT EXISTS avatar_id TEXT;

-- Backfill legacy records to maintain seamless compatibility
UPDATE public.profiles
SET avatar_type = CASE
    WHEN profile_image IS NULL OR profile_image = '' THEN 'initial'
    WHEN profile_image LIKE 'preset:%' THEN 'preset'
    ELSE 'upload'
END
WHERE avatar_type IS NULL OR avatar_type = 'initial';

-- Populate avatar_id for existing presets if formatted as preset:id
UPDATE public.profiles
SET avatar_id = REPLACE(profile_image, 'preset:', '')
WHERE profile_image LIKE 'preset:%' AND (avatar_id IS NULL OR avatar_id = '');

-- -----------------------------------------------------------------------------
-- 2. Supabase Storage Bucket Configuration (profile-avatars)
-- Enforces 100 KB maximum object size and restricts MIME types
-- -----------------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'profile-avatars',
    'profile-avatars',
    true,
    102400, -- 100 KB maximum file size limit
    ARRAY['image/webp', 'image/jpeg', 'image/png']
)
ON CONFLICT (id) DO UPDATE SET
    public = true,
    file_size_limit = 102400,
    allowed_mime_types = ARRAY['image/webp', 'image/jpeg', 'image/png'];

-- -----------------------------------------------------------------------------
-- 3. Storage Row Level Security (RLS) Policies
-- Enforces stable path structure: profile-avatars/{user_id}/avatar.webp
-- Prevents cross-user modifications and unauthorized deletions
-- -----------------------------------------------------------------------------

-- Drop previous policies if re-running
DROP POLICY IF EXISTS "Public read access for profile avatars" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete own avatar" ON storage.objects;

-- 3.1. Public Read: Any student can view avatars in profile-avatars bucket
CREATE POLICY "Public read access for profile avatars"
ON storage.objects FOR SELECT
USING (bucket_id = 'profile-avatars');

-- 3.2. Authenticated Insert: User can only upload into their own user_id directory
CREATE POLICY "Authenticated users can upload own avatar"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'profile-avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- 3.3. Authenticated Update: User can only update objects in their own directory
CREATE POLICY "Authenticated users can update own avatar"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'profile-avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
)
WITH CHECK (
    bucket_id = 'profile-avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- 3.4. Authenticated Delete: User can only delete objects in their own directory
CREATE POLICY "Authenticated users can delete own avatar"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'profile-avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- -----------------------------------------------------------------------------
-- 4. Audit & Profile Trigger Update
-- Ensures new user profiles initialize with avatar_type = 'initial'
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_user_profile()
RETURNS TRIGGER AS $$
DECLARE
    target_username TEXT;
    target_name TEXT;
    user_dept TEXT;
    user_year TEXT;
    base_user TEXT;
BEGIN
    target_name := COALESCE(NULLIF(TRIM(NEW.raw_user_meta_data->>'full_name'), ''), 'TKM Student');
    user_dept := COALESCE(NULLIF(TRIM(NEW.raw_user_meta_data->>'department'), ''), 'General');
    user_year := COALESCE(NULLIF(TRIM(NEW.raw_user_meta_data->>'academic_year'), ''), '1st Year');

    IF NEW.raw_user_meta_data->>'username' IS NOT NULL AND TRIM(NEW.raw_user_meta_data->>'username') <> '' THEN
        target_username := LOWER(TRIM(NEW.raw_user_meta_data->>'username'));
    ELSE
        base_user := LOWER(REGEXP_REPLACE(SPLIT_PART(NEW.email, '@', 1), '[^a-zA-Z0-9_]', '_', 'g'));
        target_username := base_user || '_' || SUBSTRING(NEW.id::text, 1, 4);
    END IF;

    INSERT INTO public.profiles (
        id,
        full_name,
        username,
        email,
        department,
        academic_year,
        profile_image,
        avatar_type,
        avatar_id,
        verification_status,
        verification_method,
        role
    ) VALUES (
        NEW.id,
        target_name,
        target_username,
        NEW.email,
        user_dept,
        user_year,
        '',
        'initial',
        NULL,
        CASE WHEN NEW.email_confirmed_at IS NOT NULL THEN 'verified' ELSE 'pending' END,
        'email_otp',
        'student'
    )
    ON CONFLICT (id) DO UPDATE SET
        full_name = EXCLUDED.full_name,
        department = EXCLUDED.department,
        academic_year = EXCLUDED.academic_year,
        verification_status = CASE
            WHEN EXCLUDED.verification_status = 'verified' THEN 'verified'
            ELSE profiles.verification_status
        END,
        updated_at = NOW();

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
