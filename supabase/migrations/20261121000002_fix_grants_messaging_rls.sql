-- ==============================================================================
-- TKMingle — Database Fix: Grants, Messaging RLS & Realtime Publication
-- Version: 20261121000002
--
-- Fixes:
-- 1. Table permission error 42501 for authenticated & anon roles by granting explicit table privileges.
-- 2. Infinite recursion in conversation_members RLS policy by introducing a SECURITY DEFINER helper.
-- 3. Enables Supabase Realtime publication on messages, conversations, and conversation_members.
-- 4. Introduces atomic get_or_create_conversation RPC function with blocking protection.
-- 5. Hardens messages RLS to verify participant membership, sender_id authenticity, and blocking.
-- ==============================================================================

-- -----------------------------------------------------------------------------
-- 1. Explicit Schema & Table Grants
-- -----------------------------------------------------------------------------
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL ROUTINES IN SCHEMA public TO authenticated;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON ROUTINES TO authenticated;

-- -----------------------------------------------------------------------------
-- 2. Non-Recursive Conversation Membership Helper (SECURITY DEFINER)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.is_conversation_participant(p_conv_id UUID, p_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.conversation_members
        WHERE conversation_id = p_conv_id AND user_id = p_user_id
    );
$$;

GRANT EXECUTE ON FUNCTION public.is_conversation_participant(UUID, UUID) TO authenticated;

-- -----------------------------------------------------------------------------
-- 3. Atomic RPC Function: Get or Create 1-on-1 Conversation
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_or_create_conversation(p_other_user_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_my_id UUID := auth.uid();
    v_conv_id UUID;
BEGIN
    IF v_my_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    IF v_my_id = p_other_user_id THEN
        RAISE EXCEPTION 'Cannot start a conversation with yourself';
    END IF;

    -- Enforce block protection
    IF public.is_user_blocked(v_my_id, p_other_user_id) THEN
        RAISE EXCEPTION 'Cannot message this student due to campus safety blocks';
    END IF;

    -- Look for existing bilateral conversation (non-group)
    SELECT cm1.conversation_id INTO v_conv_id
    FROM public.conversation_members cm1
    JOIN public.conversation_members cm2 ON cm1.conversation_id = cm2.conversation_id
    JOIN public.conversations c ON c.id = cm1.conversation_id
    WHERE cm1.user_id = v_my_id 
      AND cm2.user_id = p_other_user_id 
      AND c.is_group = FALSE
    LIMIT 1;

    IF v_conv_id IS NOT NULL THEN
        RETURN v_conv_id;
    END IF;

    -- Create new conversation record
    INSERT INTO public.conversations (is_group, title, last_message_preview, last_message_at)
    VALUES (FALSE, NULL, 'Started conversation', NOW())
    RETURNING id INTO v_conv_id;

    -- Insert participant memberships
    INSERT INTO public.conversation_members (conversation_id, user_id, joined_at, last_read_at)
    VALUES 
        (v_conv_id, v_my_id, NOW(), NOW()),
        (v_conv_id, p_other_user_id, NOW(), NOW() - INTERVAL '1 minute');

    RETURN v_conv_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_or_create_conversation(UUID) TO authenticated;

-- -----------------------------------------------------------------------------
-- 4. Corrected RLS Policies (Conversations, Members, Messages)
-- -----------------------------------------------------------------------------

-- Conversations Policies
DROP POLICY IF EXISTS "Conversations select" ON public.conversations;
CREATE POLICY "Conversations select" ON public.conversations
    FOR SELECT TO authenticated
    USING (
        public.is_conversation_participant(id, auth.uid())
        OR public.is_admin(auth.uid())
    );

DROP POLICY IF EXISTS "Conversations insert" ON public.conversations;
CREATE POLICY "Conversations insert" ON public.conversations
    FOR INSERT TO authenticated
    WITH CHECK (true);

-- Conversation Members Policies (Resolves Infinite Recursion)
DROP POLICY IF EXISTS "Conversation members select" ON public.conversation_members;
CREATE POLICY "Conversation members select" ON public.conversation_members
    FOR SELECT TO authenticated
    USING (
        user_id = auth.uid()
        OR public.is_conversation_participant(conversation_id, auth.uid())
        OR public.is_admin(auth.uid())
    );

DROP POLICY IF EXISTS "Conversation members insert" ON public.conversation_members;
CREATE POLICY "Conversation members insert" ON public.conversation_members
    FOR INSERT TO authenticated
    WITH CHECK (
        user_id = auth.uid()
        OR public.is_conversation_participant(conversation_id, auth.uid())
        OR public.is_admin(auth.uid())
    );

DROP POLICY IF EXISTS "Conversation members update" ON public.conversation_members;
CREATE POLICY "Conversation members update" ON public.conversation_members
    FOR UPDATE TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- Messages Policies
DROP POLICY IF EXISTS "Messages select" ON public.messages;
CREATE POLICY "Messages select" ON public.messages
    FOR SELECT TO authenticated
    USING (
        public.is_conversation_participant(conversation_id, auth.uid())
    );

DROP POLICY IF EXISTS "Messages insert" ON public.messages;
CREATE POLICY "Messages insert" ON public.messages
    FOR INSERT TO authenticated
    WITH CHECK (
        sender_id = auth.uid()
        AND public.is_conversation_participant(conversation_id, auth.uid())
        AND NOT EXISTS (
            SELECT 1 FROM public.conversation_members cm
            WHERE cm.conversation_id = messages.conversation_id
              AND cm.user_id <> auth.uid()
              AND public.is_user_blocked(auth.uid(), cm.user_id)
        )
    );

-- -----------------------------------------------------------------------------
-- 5. Enable Supabase Realtime Publication
-- -----------------------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'messages'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'conversations'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.conversations;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'conversation_members'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.conversation_members;
    END IF;
END $$;

ALTER TABLE public.messages REPLICA IDENTITY FULL;
ALTER TABLE public.conversations REPLICA IDENTITY FULL;
ALTER TABLE public.conversation_members REPLICA IDENTITY FULL;
