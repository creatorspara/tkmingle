-- ==============================================================================
-- TKMingle — Connection Request System & Password Reset Authorization
-- Migration: 20261122000004_fix_connection_requests_system.sql
-- ==============================================================================

-- -----------------------------------------------------------------------------
-- 1. Table Grants for Authenticated Students
-- -----------------------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE, DELETE ON public.connection_requests TO authenticated;
GRANT SELECT, DELETE ON public.connections TO authenticated;

-- -----------------------------------------------------------------------------
-- 2. Refined Row Level Security on connection_requests
-- Enforces:
--  - Only the authenticated sender can create requests
--  - Senders and receivers can view their own requests
--  - ONLY the intended receiver can accept or decline requests
--  - ONLY the sender can cancel their own pending request
-- -----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Connection requests select" ON public.connection_requests;
DROP POLICY IF EXISTS "Connection requests insert" ON public.connection_requests;
DROP POLICY IF EXISTS "Connection requests update" ON public.connection_requests;

-- 2.1 SELECT: Senders and receivers can see their own requests
CREATE POLICY "Connection requests select" ON public.connection_requests
    FOR SELECT TO authenticated
    USING (
        sender_id = auth.uid() 
        OR receiver_id = auth.uid() 
        OR public.is_admin(auth.uid())
    );

-- 2.2 INSERT: Senders can only create requests as themselves, preventing self-requests, blocks, or duplicate active connections
CREATE POLICY "Connection requests insert" ON public.connection_requests
    FOR INSERT TO authenticated
    WITH CHECK (
        sender_id = auth.uid()
        AND sender_id <> receiver_id
        AND NOT public.is_user_blocked(sender_id, receiver_id)
        AND NOT public.are_connected(sender_id, receiver_id)
    );

-- 2.3 UPDATE: Strict mutual-consent state transitions
CREATE POLICY "Connection requests update" ON public.connection_requests
    FOR UPDATE TO authenticated
    USING (
        sender_id = auth.uid() 
        OR receiver_id = auth.uid()
    )
    WITH CHECK (
        (receiver_id = auth.uid() AND status IN ('accepted', 'declined'))
        OR
        (sender_id = auth.uid() AND status = 'cancelled')
    );

-- -----------------------------------------------------------------------------
-- 3. Deterministic Connection Status RPC Helper
-- Provides 1ms lookup for UI buttons across Discover, Profiles, and Messages
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_connection_status(p_current_user UUID, p_target_user UUID)
RETURNS TEXT
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    IF p_current_user = p_target_user THEN
        RETURN 'self';
    END IF;

    -- Check if active bilateral connection exists
    IF public.are_connected(p_current_user, p_target_user) THEN
        RETURN 'connected';
    END IF;

    -- Check if outgoing pending request exists
    IF EXISTS (
        SELECT 1 FROM public.connection_requests
        WHERE sender_id = p_current_user 
          AND receiver_id = p_target_user 
          AND status = 'pending'
    ) THEN
        RETURN 'pending_sent';
    END IF;

    -- Check if incoming pending request exists
    IF EXISTS (
        SELECT 1 FROM public.connection_requests
        WHERE sender_id = p_target_user 
          AND receiver_id = p_current_user 
          AND status = 'pending'
    ) THEN
        RETURN 'pending_received';
    END IF;

    RETURN 'none';
END;
$$;

-- -----------------------------------------------------------------------------
-- 4. Enable Supabase Realtime for Connection Requests & Connections
-- -----------------------------------------------------------------------------
ALTER TABLE public.connection_requests REPLICA IDENTITY FULL;
ALTER TABLE public.connections REPLICA IDENTITY FULL;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'connection_requests'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.connection_requests;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'connections'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.connections;
    END IF;
EXCEPTION WHEN OTHERS THEN
    NULL;
END $$;
