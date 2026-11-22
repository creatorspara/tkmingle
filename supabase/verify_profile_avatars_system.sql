-- ==============================================================================
-- TKMingle v1.5 — Verification Script for Profile Picture & Avatar System
-- File: supabase/verify_profile_avatars_system.sql
-- Run this in Supabase SQL Editor after executing the migration.
-- ==============================================================================

-- -----------------------------------------------------------------------------
-- 1. Verify Profiles Table Columns & Constraints
-- -----------------------------------------------------------------------------
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'profiles'
  AND column_name IN ('profile_image', 'avatar_type', 'avatar_id')
ORDER BY column_name;

-- Verify CHECK constraint on profiles.avatar_type
SELECT 
    conname AS constraint_name,
    pg_get_constraintdef(c.oid) AS constraint_definition
FROM pg_constraint c
JOIN pg_class t ON c.conrelid = t.oid
JOIN pg_namespace n ON t.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND t.relname = 'profiles'
  AND c.conname = 'profiles_avatar_type_check';

-- -----------------------------------------------------------------------------
-- 2. Verify Storage Bucket Configuration
-- -----------------------------------------------------------------------------
SELECT 
    id, 
    name, 
    public, 
    file_size_limit, 
    allowed_mime_types
FROM storage.buckets
WHERE id = 'profile-avatars';

-- -----------------------------------------------------------------------------
-- 3. Verify Storage Objects RLS Policies
-- Must show exactly the 4 clean, owner-scoped policies without leftovers.
-- -----------------------------------------------------------------------------
SELECT 
    policyname, 
    cmd AS operation, 
    roles, 
    qual AS using_expression, 
    with_check AS with_check_expression
FROM pg_policies
WHERE schemaname = 'storage' 
  AND tablename = 'objects'
  AND (
      qual LIKE '%profile-avatars%' 
      OR with_check LIKE '%profile-avatars%'
      OR LOWER(policyname) LIKE '%avatar%'
  )
ORDER BY policyname;

-- -----------------------------------------------------------------------------
-- 4. Verify Auth Trigger and Synchronisation Function
-- -----------------------------------------------------------------------------
-- Check handle_new_user() function attributes (SECURITY DEFINER + search_path)
SELECT 
    p.proname AS function_name,
    pg_get_functiondef(p.oid) AS definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public' 
  AND p.proname = 'handle_new_user';

-- Check trigger on auth.users
SELECT 
    tgname AS trigger_name,
    tgenabled AS trigger_enabled,
    relname AS table_name,
    nspname AS schema_name
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE tgname = 'on_auth_user_created'
  AND n.nspname = 'auth'
  AND c.relname = 'users';

-- -----------------------------------------------------------------------------
-- 5. Diagnostic Summary of Profile Avatar Types in Production
-- -----------------------------------------------------------------------------
SELECT 
    COALESCE(avatar_type, 'NULL') AS avatar_type,
    COUNT(*) AS profile_count,
    COUNT(CASE WHEN profile_image IS NOT NULL AND profile_image <> '' THEN 1 END) AS has_profile_image,
    COUNT(CASE WHEN avatar_id IS NOT NULL AND avatar_id <> '' THEN 1 END) AS has_avatar_id
FROM public.profiles
GROUP BY avatar_type
ORDER BY profile_count DESC;
