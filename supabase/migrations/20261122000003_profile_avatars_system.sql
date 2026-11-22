-- ==============================================================================
-- TKMingle v1.5 — Unified Profile Picture & Avatar Management System
-- Migration: 20261122000003_profile_avatars_system.sql
-- Final Production Safety Review: Fully Idempotent, Non-destructive
-- ==============================================================================

-- -----------------------------------------------------------------------------
-- 1. Profiles Table Extension & Robust Schema Constraints
-- -----------------------------------------------------------------------------

-- 1.1 Add avatar classification columns if not already present
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS avatar_type TEXT;

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS avatar_id TEXT;

-- 1.2 Guarantee default value is 'initial'
ALTER TABLE public.profiles
ALTER COLUMN avatar_type SET DEFAULT 'initial';

-- 1.3 Backfill any NULL avatar_type values prior to enforcing NOT NULL
UPDATE public.profiles
SET avatar_type = 'initial'
WHERE avatar_type IS NULL;

-- 1.4 Enforce NOT NULL on avatar_type
ALTER TABLE public.profiles
ALTER COLUMN avatar_type SET NOT NULL;

-- 1.5 Enforce CHECK constraint on avatar_type idempotently
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM pg_constraint 
        WHERE conname = 'profiles_avatar_type_check' 
          AND conrelid = 'public.profiles'::regclass
    ) THEN
        ALTER TABLE public.profiles
        ADD CONSTRAINT profiles_avatar_type_check
        CHECK (avatar_type IN ('upload', 'preset', 'initial'));
    END IF;
END $$;

-- -----------------------------------------------------------------------------
-- 2. Deterministic, Rerun-Safe Legacy Avatar Backfill
-- -----------------------------------------------------------------------------
-- Only updates rows that have not yet been categorized, OR legacy rows that were
-- assigned default 'initial' by ADD COLUMN but have a populated profile_image.
-- Crucial: This will NOT overwrite subsequent avatar selections on reruns!
UPDATE public.profiles
SET 
    avatar_type = CASE
        WHEN profile_image IS NOT NULL AND profile_image LIKE 'preset:%' THEN 'preset'
        WHEN profile_image IS NOT NULL AND TRIM(profile_image) <> '' THEN 'upload'
        ELSE 'initial'
    END,
    avatar_id = CASE
        WHEN profile_image IS NOT NULL AND profile_image LIKE 'preset:%' 
            THEN NULLIF(SUBSTRING(profile_image FROM 8), '')
        ELSE NULL
    END
    WHERE 
        avatar_type IS NULL 
        OR avatar_type = ''
        OR (avatar_type = 'initial' AND profile_image IS NOT NULL AND TRIM(profile_image) <> '');

-- -----------------------------------------------------------------------------
-- 3. Supabase Storage Bucket Configuration (profile-avatars)
-- Enforces 100 KB file limit and restricts MIME types strictly to WebP & JPEG
-- -----------------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'profile-avatars',
    'profile-avatars',
    true,
    102400, -- 100 KB maximum file size limit
    ARRAY['image/webp', 'image/jpeg']
)
ON CONFLICT (id) DO UPDATE SET
    public = true,
    file_size_limit = 102400,
    allowed_mime_types = ARRAY['image/webp', 'image/jpeg'];

-- -----------------------------------------------------------------------------
-- 4. Dynamic RLS Policy Cleanup & Re-creation for profile-avatars
-- Drops all previous/dashboard variants targeting profile-avatars so PostgreSQL's
-- permissive OR behavior cannot leave overly permissive legacy rules active.
-- Unrelated buckets and their policies are strictly preserved.
-- -----------------------------------------------------------------------------

DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN
        SELECT policyname
        FROM pg_policies
        WHERE schemaname = 'storage'
          AND tablename = 'objects'
          AND (
              -- Target policies referencing profile-avatars
              COALESCE(qual, '') LIKE '%profile-avatars%'
              OR COALESCE(with_check, '') LIKE '%profile-avatars%'
              OR LOWER(policyname) IN (
                  'anyone can view profile avatars',
                  'users can upload their own avatar',
                  'users can update their own avatar',
                  'users can delete their own avatar',
                  'public read access for profile avatars',
                  'authenticated users can upload own avatar',
                  'authenticated users can update own avatar',
                  'authenticated users can delete own avatar',
                  'allow authenticated users to upload avatar',
                  'allow authenticated users to update avatar',
                  'allow authenticated users to delete avatar',
                  'users can select own avatar objects',
                  'users can upload own avatar',
                  'users can update own avatar',
                  'users can delete own avatar'
              )
          )
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON storage.objects', pol.policyname);
    END LOOP;
END $$;

-- 4.1 Owner-Scoped SELECT: Authenticated user can read/list their own objects for upsert
-- Note: Public bucket serving (/storage/v1/object/public/...) bypasses table-level RLS,
-- allowing public avatar viewing globally without opening directory listing to anonymous scrapers.
CREATE POLICY "Users can select own avatar objects"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'profile-avatars'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- 4.2 Authenticated INSERT: User can only upload into their own user_id directory
CREATE POLICY "Users can upload own avatar"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'profile-avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- 4.3 Authenticated UPDATE: Requires both USING and WITH CHECK for seamless 'upsert: true'
CREATE POLICY "Users can update own avatar"
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

-- 4.4 Authenticated DELETE: User can only delete objects in their own directory
CREATE POLICY "Users can delete own avatar"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'profile-avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- -----------------------------------------------------------------------------
-- 5. Authentication Sync Trigger Update
-- Modifies existing public.handle_new_user() with explicit search_path
-- Crucial: ON CONFLICT DO UPDATE only touches verification_status, NEVER
-- overwriting existing user names, departments, years, roles, or avatars!
-- -----------------------------------------------------------------------------

-- Drop accidental draft function if created earlier
DROP FUNCTION IF EXISTS public.handle_new_user_profile();

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER 
SECURITY DEFINER
SET search_path = public, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    v_full_name TEXT;
    v_department TEXT;
    v_academic_year TEXT;
    v_username TEXT;
BEGIN
    v_full_name := COALESCE(NULLIF(TRIM(NEW.raw_user_meta_data->>'full_name'), ''), split_part(NEW.email, '@', 1));
    v_department := COALESCE(NULLIF(TRIM(NEW.raw_user_meta_data->>'department'), ''), 'General');
    v_academic_year := COALESCE(NULLIF(TRIM(NEW.raw_user_meta_data->>'academic_year'), ''), '1st Year');

    IF NEW.raw_user_meta_data->>'username' IS NOT NULL AND TRIM(NEW.raw_user_meta_data->>'username') <> '' THEN
        v_username := LOWER(TRIM(NEW.raw_user_meta_data->>'username'));
    ELSE
        v_username := LOWER(REGEXP_REPLACE(SPLIT_PART(NEW.email, '@', 1), '[^a-zA-Z0-9_]', '_', 'g')) || '_' || SUBSTR(NEW.id::text, 1, 4);
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
        v_full_name,
        v_username,
        NEW.email,
        v_department,
        v_academic_year,
        '',
        'initial',
        NULL,
        CASE WHEN NEW.email_confirmed_at IS NOT NULL THEN 'verified' ELSE 'pending' END,
        'email_otp',
        'student'
    ) ON CONFLICT (id) DO UPDATE SET
        verification_status = CASE 
            WHEN NEW.email_confirmed_at IS NOT NULL THEN 'verified' 
            ELSE public.profiles.verification_status 
        END,
        updated_at = NOW();

    RETURN NEW;
END;
$$;

-- Ensure the trigger on auth.users is present, accurately checked against auth.users
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM pg_trigger 
        WHERE tgname = 'on_auth_user_created' 
          AND tgrelid = 'auth.users'::regclass
    ) THEN
        CREATE TRIGGER on_auth_user_created
            AFTER INSERT OR UPDATE OF email_confirmed_at ON auth.users
            FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
    END IF;
END $$;
