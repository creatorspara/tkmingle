-- ==============================================================================
-- TKMingle — Complete Database Schema & Migration
-- Institution: TKM College of Engineering (TKMCE), Kollam, Kerala
-- Description: Production PostgreSQL schema for campus social discovery platform.
-- Version: 20261121000001
-- ==============================================================================

-- 1. Enable Required Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==============================================================================
-- 2. SYSTEM SETTINGS & REGISTRATION CAP MANAGEMENT
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.system_settings (
    id TEXT PRIMARY KEY DEFAULT 'global',
    registration_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    registration_cap INTEGER NOT NULL DEFAULT 400,
    current_registered_count INTEGER NOT NULL DEFAULT 0,
    college_domain TEXT NOT NULL DEFAULT 'tkmce.ac.in',
    require_college_email BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Seed global settings row if not present
INSERT INTO public.system_settings (id, registration_enabled, registration_cap, current_registered_count, college_domain, require_college_email)
VALUES ('global', TRUE, 400, 0, 'tkmce.ac.in', FALSE)
ON CONFLICT (id) DO NOTHING;

-- ==============================================================================
-- 3. PROFILES TABLE (Linked to auth.users)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    department TEXT NOT NULL,
    academic_year TEXT NOT NULL,
    bio TEXT,
    profile_image TEXT,
    interests TEXT[] NOT NULL DEFAULT '{}',
    hobbies TEXT[] NOT NULL DEFAULT '{}',
    skills TEXT[] NOT NULL DEFAULT '{}',
    languages TEXT[] NOT NULL DEFAULT '{}',
    availability TEXT NOT NULL DEFAULT 'Available to mingle',
    discoverable BOOLEAN NOT NULL DEFAULT TRUE,
    verification_status TEXT NOT NULL DEFAULT 'pending' CHECK (verification_status IN ('pending', 'verified', 'rejected', 'suspended')),
    verification_method TEXT NOT NULL DEFAULT 'email_otp' CHECK (verification_method IN ('email_otp', 'id_card', 'manual_review')),
    id_card_image TEXT,
    role TEXT NOT NULL DEFAULT 'student' CHECK (role IN ('student', 'moderator', 'admin')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_profiles_department ON public.profiles(department);
CREATE INDEX IF NOT EXISTS idx_profiles_academic_year ON public.profiles(academic_year);
CREATE INDEX IF NOT EXISTS idx_profiles_discoverable ON public.profiles(discoverable);
CREATE INDEX IF NOT EXISTS idx_profiles_verification_status ON public.profiles(verification_status);
CREATE INDEX IF NOT EXISTS idx_profiles_interests ON public.profiles USING GIN(interests);
CREATE INDEX IF NOT EXISTS idx_profiles_skills ON public.profiles USING GIN(skills);

-- ==============================================================================
-- 4. REGISTRATION CAP & AUDIT TRIGGER
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.check_registration_cap()
RETURNS TRIGGER AS $$
DECLARE
    v_enabled BOOLEAN;
    v_cap INTEGER;
    v_count INTEGER;
BEGIN
    SELECT registration_enabled, registration_cap INTO v_enabled, v_cap
    FROM public.system_settings
    WHERE id = 'global';

    IF NOT v_enabled THEN
        RAISE EXCEPTION 'Registration is currently disabled by campus administration.';
    END IF;

    SELECT COUNT(*) INTO v_count FROM public.profiles;

    IF v_count >= v_cap THEN
        RAISE EXCEPTION 'Registration cohort limit of % students reached. Expansion pending approval.', v_cap;
    END IF;

    -- Update count in system settings
    UPDATE public.system_settings 
    SET current_registered_count = v_count + 1, updated_at = NOW() 
    WHERE id = 'global';

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_check_registration_cap ON public.profiles;
CREATE TRIGGER trg_check_registration_cap
    BEFORE INSERT ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.check_registration_cap();

-- Trigger to prevent regular users from elevating their own role or verification_status
CREATE OR REPLACE FUNCTION public.protect_profile_privileges()
RETURNS TRIGGER AS $$
BEGIN
    -- If current user is not service role or admin, disallow modifying role or verification_status directly
    IF current_user <> 'postgres' AND (current_setting('role', true) <> 'service_role') THEN
        IF OLD.verification_status IS DISTINCT FROM NEW.verification_status THEN
            -- Check if current user is an admin
            IF NOT EXISTS (SELECT 1 FROM public.admin_roles WHERE user_id = auth.uid() AND role IN ('admin', 'super_admin')) THEN
                NEW.verification_status := OLD.verification_status;
            END IF;
        END IF;

        IF OLD.role IS DISTINCT FROM NEW.role THEN
            IF NOT EXISTS (SELECT 1 FROM public.admin_roles WHERE user_id = auth.uid() AND role IN ('admin', 'super_admin')) THEN
                NEW.role := OLD.role;
            END IF;
        END IF;
    END IF;

    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_protect_profile_privileges ON public.profiles;
CREATE TRIGGER trg_protect_profile_privileges
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.protect_profile_privileges();

-- Trigger to automatically create and synchronize public.profiles whenever an auth.user is created
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    v_full_name TEXT;
    v_department TEXT;
    v_academic_year TEXT;
    v_username TEXT;
BEGIN
    v_full_name := COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1));
    v_department := COALESCE(NEW.raw_user_meta_data->>'department', 'General');
    v_academic_year := COALESCE(NEW.raw_user_meta_data->>'academic_year', '1st Year');
    v_username := lower(regexp_replace(split_part(NEW.email, '@', 1), '[^a-zA-Z0-9_]', '_', 'g')) || '_' || substr(NEW.id::text, 1, 4);

    INSERT INTO public.profiles (
        id,
        full_name,
        username,
        email,
        department,
        academic_year,
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
        CASE WHEN NEW.email_confirmed_at IS NOT NULL THEN 'verified' ELSE 'pending' END,
        'email_otp',
        'student'
    ) ON CONFLICT (id) DO UPDATE SET
        full_name = EXCLUDED.full_name,
        department = EXCLUDED.department,
        academic_year = EXCLUDED.academic_year,
        verification_status = CASE WHEN NEW.email_confirmed_at IS NOT NULL THEN 'verified' ELSE public.profiles.verification_status END,
        updated_at = NOW();

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT OR UPDATE OF email_confirmed_at ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ==============================================================================
-- 5. CONNECTIONS & CONNECTION REQUESTS
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.connection_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    receiver_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'cancelled')),
    message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT no_self_request CHECK (sender_id <> receiver_id)
);

CREATE INDEX IF NOT EXISTS idx_conn_requests_sender ON public.connection_requests(sender_id);
CREATE INDEX IF NOT EXISTS idx_conn_requests_receiver ON public.connection_requests(receiver_id);
CREATE INDEX IF NOT EXISTS idx_conn_requests_status ON public.connection_requests(status);
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_pending_request 
ON public.connection_requests(sender_id, receiver_id) 
WHERE status = 'pending';

CREATE TABLE IF NOT EXISTS public.connections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_one UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    user_two UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT ordered_connection_pair CHECK (user_one < user_two),
    CONSTRAINT unique_connection_pair UNIQUE (user_one, user_two)
);

CREATE INDEX IF NOT EXISTS idx_connections_user_one ON public.connections(user_one);
CREATE INDEX IF NOT EXISTS idx_connections_user_two ON public.connections(user_two);

-- Trigger to create bilateral connection when request is accepted
CREATE OR REPLACE FUNCTION public.handle_connection_accepted()
RETURNS TRIGGER AS $$
DECLARE
    v_u1 UUID;
    v_u2 UUID;
BEGIN
    IF NEW.status = 'accepted' AND OLD.status = 'pending' THEN
        IF NEW.sender_id < NEW.receiver_id THEN
            v_u1 := NEW.sender_id;
            v_u2 := NEW.receiver_id;
        ELSE
            v_u1 := NEW.receiver_id;
            v_u2 := NEW.sender_id;
        END IF;

        INSERT INTO public.connections (user_one, user_two)
        VALUES (v_u1, v_u2)
        ON CONFLICT (user_one, user_two) DO NOTHING;

        -- Create in-app notification for the sender
        INSERT INTO public.notifications (user_id, type, title, body, reference_id)
        SELECT 
            NEW.sender_id,
            'connection_accepted',
            'Connection Accepted!',
            p.full_name || ' accepted your campus connection request. Say hi!',
            NEW.receiver_id::text
        FROM public.profiles p
        WHERE p.id = NEW.receiver_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_handle_connection_accepted ON public.connection_requests;
CREATE TRIGGER trg_handle_connection_accepted
    AFTER UPDATE ON public.connection_requests
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_connection_accepted();

-- ==============================================================================
-- 6. CONVERSATIONS & REALTIME MESSAGING
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    is_group BOOLEAN NOT NULL DEFAULT FALSE,
    title TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_message_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_message_preview TEXT
);

CREATE INDEX IF NOT EXISTS idx_conversations_last_message_at ON public.conversations(last_message_at DESC);

CREATE TABLE IF NOT EXISTS public.conversation_members (
    conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_read_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (conversation_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_conv_members_user ON public.conversation_members(user_id);

CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    message_type TEXT NOT NULL DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'system')),
    attachment_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    read_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_messages_conversation ON public.messages(conversation_id, created_at ASC);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON public.messages(sender_id);

-- Trigger to update conversation last_message_at and preview
CREATE OR REPLACE FUNCTION public.update_conversation_on_message()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.conversations
    SET 
        last_message_at = NEW.created_at,
        last_message_preview = SUBSTRING(NEW.content FROM 1 FOR 100),
        updated_at = NOW()
    WHERE id = NEW.conversation_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_update_conversation_on_message ON public.messages;
CREATE TRIGGER trg_update_conversation_on_message
    AFTER INSERT ON public.messages
    FOR EACH ROW
    EXECUTE FUNCTION public.update_conversation_on_message();

-- Enable Supabase Realtime publication on messages
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'messages'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
    END IF;
EXCEPTION WHEN OTHERS THEN
    -- Fallback for environments where supabase_realtime publication is configured via UI
    NULL;
END $$;

-- ==============================================================================
-- 7. CIRCLES & COMMUNITY DISCUSSIONS
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.circles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL,
    icon TEXT,
    cover_image TEXT,
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    visibility TEXT NOT NULL DEFAULT 'public' CHECK (visibility IN ('public', 'private', 'restricted')),
    member_count INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_circles_category ON public.circles(category);
CREATE INDEX IF NOT EXISTS idx_circles_slug ON public.circles(slug);

CREATE TABLE IF NOT EXISTS public.circle_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    circle_id UUID NOT NULL REFERENCES public.circles(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('member', 'moderator', 'admin', 'lead')),
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_circle_membership UNIQUE (circle_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_circle_members_circle ON public.circle_members(circle_id);
CREATE INDEX IF NOT EXISTS idx_circle_members_user ON public.circle_members(user_id);

CREATE TABLE IF NOT EXISTS public.circle_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    circle_id UUID NOT NULL REFERENCES public.circles(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT,
    content TEXT NOT NULL,
    attachment_url TEXT,
    likes_count INTEGER NOT NULL DEFAULT 0,
    comments_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_circle_posts_circle ON public.circle_posts(circle_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_circle_posts_author ON public.circle_posts(author_id);

-- ==============================================================================
-- 8. NOTIFICATIONS & SAVED PROFILES
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('connection_request', 'connection_accepted', 'new_message', 'circle_invite', 'circle_post', 'admin_notice', 'verification_update')),
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    reference_id TEXT,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON public.notifications(user_id, is_read, created_at DESC);

CREATE TABLE IF NOT EXISTS public.saved_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    saved_user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_saved_profile UNIQUE (user_id, saved_user_id)
);

CREATE INDEX IF NOT EXISTS idx_saved_profiles_user ON public.saved_profiles(user_id);

-- ==============================================================================
-- 9. MODERATION, SAFETY, REPORTS & USER BLOCKS
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    reported_user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    message_id UUID REFERENCES public.messages(id) ON DELETE SET NULL,
    reason TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'investigating', 'resolved', 'dismissed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_reports_status ON public.reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_reported_user ON public.reports(reported_user_id);

CREATE TABLE IF NOT EXISTS public.user_blocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blocker_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    blocked_user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_block UNIQUE (blocker_id, blocked_user_id),
    CONSTRAINT no_self_block CHECK (blocker_id <> blocked_user_id)
);

CREATE INDEX IF NOT EXISTS idx_user_blocks_blocker ON public.user_blocks(blocker_id);
CREATE INDEX IF NOT EXISTS idx_user_blocks_blocked ON public.user_blocks(blocked_user_id);

-- ==============================================================================
-- 10. DEVICE TOKENS & ADMIN ROLES
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.device_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    device_token TEXT NOT NULL,
    platform TEXT NOT NULL CHECK (platform IN ('android', 'ios', 'web')),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_user_device_token UNIQUE (user_id, device_token)
);

CREATE INDEX IF NOT EXISTS idx_device_tokens_user ON public.device_tokens(user_id);

CREATE TABLE IF NOT EXISTS public.admin_roles (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('moderator', 'admin', 'super_admin')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==============================================================================
-- 11. HELPER FUNCTIONS FOR ROW LEVEL SECURITY (RLS)
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.is_admin(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.admin_roles 
        WHERE user_id = p_user_id AND role IN ('admin', 'super_admin')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION public.is_user_blocked(p_user_a UUID, p_user_b UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_blocks 
        WHERE (blocker_id = p_user_a AND blocked_user_id = p_user_b)
           OR (blocker_id = p_user_b AND blocked_user_id = p_user_a)
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION public.are_connected(p_user_a UUID, p_user_b UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.connections
        WHERE (user_one = LEAST(p_user_a, p_user_b) AND user_two = GREATEST(p_user_a, p_user_b))
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- ==============================================================================
-- 12. ROW LEVEL SECURITY (RLS) POLICIES ON ALL TABLES
-- ==============================================================================

-- Enable RLS across all tables
ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.connection_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversation_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.circles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.circle_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.circle_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_roles ENABLE ROW LEVEL SECURITY;

-- 12.1 SYSTEM SETTINGS POLICIES
CREATE POLICY "Public read settings" ON public.system_settings
    FOR SELECT TO public USING (true);

CREATE POLICY "Admin update settings" ON public.system_settings
    FOR ALL TO authenticated USING (public.is_admin(auth.uid()));

-- 12.2 PROFILES POLICIES
-- Anyone authenticated can view discoverable verified profiles, excluding blocked users and suspended accounts
CREATE POLICY "Profiles select policy" ON public.profiles
    FOR SELECT TO authenticated
    USING (
        id = auth.uid()
        OR (
            discoverable = TRUE 
            AND verification_status <> 'suspended'
            AND NOT public.is_user_blocked(auth.uid(), id)
        )
        OR public.is_admin(auth.uid())
    );

CREATE POLICY "Profiles insert own profile" ON public.profiles
    FOR INSERT TO authenticated
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Profiles update own profile" ON public.profiles
    FOR UPDATE TO authenticated
    USING (auth.uid() = id OR public.is_admin(auth.uid()))
    WITH CHECK (auth.uid() = id OR public.is_admin(auth.uid()));

-- 12.3 CONNECTION REQUESTS POLICIES
CREATE POLICY "Connection requests select" ON public.connection_requests
    FOR SELECT TO authenticated
    USING (sender_id = auth.uid() OR receiver_id = auth.uid() OR public.is_admin(auth.uid()));

CREATE POLICY "Connection requests insert" ON public.connection_requests
    FOR INSERT TO authenticated
    WITH CHECK (
        sender_id = auth.uid()
        AND NOT public.is_user_blocked(sender_id, receiver_id)
        AND NOT public.are_connected(sender_id, receiver_id)
    );

CREATE POLICY "Connection requests update" ON public.connection_requests
    FOR UPDATE TO authenticated
    USING (sender_id = auth.uid() OR receiver_id = auth.uid());

-- 12.4 CONNECTIONS POLICIES
CREATE POLICY "Connections select" ON public.connections
    FOR SELECT TO authenticated
    USING (user_one = auth.uid() OR user_two = auth.uid() OR public.is_admin(auth.uid()));

CREATE POLICY "Connections delete" ON public.connections
    FOR DELETE TO authenticated
    USING (user_one = auth.uid() OR user_two = auth.uid() OR public.is_admin(auth.uid()));

-- 12.5 CONVERSATIONS & MEMBERS POLICIES
CREATE POLICY "Conversations select" ON public.conversations
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.conversation_members 
            WHERE conversation_id = conversations.id AND user_id = auth.uid()
        )
        OR public.is_admin(auth.uid())
    );

CREATE POLICY "Conversations insert" ON public.conversations
    FOR INSERT TO authenticated
    WITH CHECK (true);

CREATE POLICY "Conversation members select" ON public.conversation_members
    FOR SELECT TO authenticated
    USING (
        conversation_id IN (
            SELECT cm.conversation_id FROM public.conversation_members cm WHERE cm.user_id = auth.uid()
        )
        OR public.is_admin(auth.uid())
    );

CREATE POLICY "Conversation members insert" ON public.conversation_members
    FOR INSERT TO authenticated
    WITH CHECK (user_id = auth.uid() OR public.is_admin(auth.uid()));

-- 12.6 MESSAGES POLICIES
CREATE POLICY "Messages select" ON public.messages
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.conversation_members
            WHERE conversation_id = messages.conversation_id AND user_id = auth.uid()
        )
    );

CREATE POLICY "Messages insert" ON public.messages
    FOR INSERT TO authenticated
    WITH CHECK (
        sender_id = auth.uid()
        AND EXISTS (
            SELECT 1 FROM public.conversation_members
            WHERE conversation_id = messages.conversation_id AND user_id = auth.uid()
        )
    );

-- 12.7 CIRCLES & COMMUNITY POLICIES
CREATE POLICY "Circles select" ON public.circles
    FOR SELECT TO authenticated
    USING (visibility = 'public' OR public.is_admin(auth.uid()) OR EXISTS (
        SELECT 1 FROM public.circle_members WHERE circle_id = circles.id AND user_id = auth.uid()
    ));

CREATE POLICY "Circles insert" ON public.circles
    FOR INSERT TO authenticated
    WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Circle members select" ON public.circle_members
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "Circle members insert" ON public.circle_members
    FOR INSERT TO authenticated
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "Circle members delete" ON public.circle_members
    FOR DELETE TO authenticated
    USING (user_id = auth.uid() OR public.is_admin(auth.uid()));

CREATE POLICY "Circle posts select" ON public.circle_posts
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "Circle posts insert" ON public.circle_posts
    FOR INSERT TO authenticated
    WITH CHECK (
        author_id = auth.uid()
        AND EXISTS (
            SELECT 1 FROM public.circle_members WHERE circle_id = circle_posts.circle_id AND user_id = auth.uid()
        )
    );

-- 12.8 NOTIFICATIONS POLICIES
CREATE POLICY "Notifications select" ON public.notifications
    FOR SELECT TO authenticated
    USING (user_id = auth.uid());

CREATE POLICY "Notifications update" ON public.notifications
    FOR UPDATE TO authenticated
    USING (user_id = auth.uid());

-- 12.9 SAVED PROFILES POLICIES
CREATE POLICY "Saved profiles all" ON public.saved_profiles
    FOR ALL TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- 12.10 REPORTS POLICIES
CREATE POLICY "Reports insert" ON public.reports
    FOR INSERT TO authenticated
    WITH CHECK (reporter_id = auth.uid());

CREATE POLICY "Reports select" ON public.reports
    FOR SELECT TO authenticated
    USING (reporter_id = auth.uid() OR public.is_admin(auth.uid()));

-- 12.11 USER BLOCKS POLICIES
CREATE POLICY "User blocks all" ON public.user_blocks
    FOR ALL TO authenticated
    USING (blocker_id = auth.uid())
    WITH CHECK (blocker_id = auth.uid());

-- 12.12 DEVICE TOKENS POLICIES
CREATE POLICY "Device tokens all" ON public.device_tokens
    FOR ALL TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- 12.13 ADMIN ROLES POLICIES
CREATE POLICY "Admin roles select" ON public.admin_roles
    FOR SELECT TO authenticated
    USING (true);

-- ==============================================================================
-- 13. MATCHING ALGORITHM FUNCTION (Shared Interests & Mutual Compatibility)
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.get_campus_discovery_matches(
    p_user_id UUID,
    p_department TEXT DEFAULT NULL,
    p_academic_year TEXT DEFAULT NULL,
    p_limit INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    full_name TEXT,
    username TEXT,
    department TEXT,
    academic_year TEXT,
    bio TEXT,
    profile_image TEXT,
    interests TEXT[],
    skills TEXT[],
    shared_interests_count BIGINT,
    connection_status TEXT
) AS $$
DECLARE
    v_user_interests TEXT[];
BEGIN
    SELECT COALESCE(interests, '{}') INTO v_user_interests
    FROM public.profiles
    WHERE public.profiles.id = p_user_id;

    RETURN QUERY
    SELECT 
        p.id,
        p.full_name,
        p.username,
        p.department,
        p.academic_year,
        p.bio,
        p.profile_image,
        p.interests,
        p.skills,
        (SELECT COUNT(*) FROM unnest(p.interests) i WHERE i = ANY(v_user_interests)) AS shared_interests_count,
        CASE
            WHEN public.are_connected(p_user_id, p.id) THEN 'connected'
            WHEN EXISTS (SELECT 1 FROM public.connection_requests cr WHERE cr.sender_id = p_user_id AND cr.receiver_id = p.id AND cr.status = 'pending') THEN 'request_sent'
            WHEN EXISTS (SELECT 1 FROM public.connection_requests cr WHERE cr.sender_id = p.id AND cr.receiver_id = p_user_id AND cr.status = 'pending') THEN 'request_received'
            ELSE 'none'
        END AS connection_status
    FROM public.profiles p
    WHERE p.id <> p_user_id
      AND p.discoverable = TRUE
      AND p.verification_status <> 'suspended'
      AND NOT public.is_user_blocked(p_user_id, p.id)
      AND (p_department IS NULL OR p.department = p_department)
      AND (p_academic_year IS NULL OR p.academic_year = p_academic_year)
    ORDER BY shared_interests_count DESC, p.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;
