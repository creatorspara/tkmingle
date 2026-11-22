-- ==============================================================================
-- TKMingle — Automated In-App Notifications for Connection Requests
-- Migration: 20261122000005_connection_request_notifications.sql
-- ==============================================================================

-- -----------------------------------------------------------------------------
-- 1. Table Grants & RLS for Notifications
-- -----------------------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE, DELETE ON public.notifications TO authenticated;

-- Ensure authenticated users can view, update, and delete their own notifications
DROP POLICY IF EXISTS "Notifications select" ON public.notifications;
DROP POLICY IF EXISTS "Notifications update" ON public.notifications;
DROP POLICY IF EXISTS "Notifications delete" ON public.notifications;

CREATE POLICY "Notifications select" ON public.notifications
    FOR SELECT TO authenticated
    USING (user_id = auth.uid());

CREATE POLICY "Notifications update" ON public.notifications
    FOR UPDATE TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "Notifications delete" ON public.notifications
    FOR DELETE TO authenticated
    USING (user_id = auth.uid());

-- -----------------------------------------------------------------------------
-- 2. Trigger Function: Automatically Notify Receiver on New Connection Request
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_connection_request()
RETURNS TRIGGER AS $$
DECLARE
    v_sender_name TEXT;
    v_sender_dept TEXT;
BEGIN
    IF NEW.status = 'pending' AND (TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND (OLD.status IS NULL OR OLD.status <> 'pending'))) THEN
        -- Fetch sender profile metadata
        SELECT full_name, department INTO v_sender_name, v_sender_dept
        FROM public.profiles
        WHERE id = NEW.sender_id;

        -- Create in-app notification row for the receiver
        INSERT INTO public.notifications (
            user_id,
            type,
            title,
            body,
            reference_id,
            is_read,
            created_at
        )
        VALUES (
            NEW.receiver_id,
            'connection_request',
            'New Connection Request!',
            COALESCE(v_sender_name, 'A student') || ' (' || COALESCE(v_sender_dept, 'TKMCE') || ') wants to connect with you.',
            NEW.sender_id::text,
            FALSE,
            NOW()
        );
    ELSIF NEW.status IN ('accepted', 'declined', 'cancelled') THEN
        -- When a request is resolved, automatically mark associated request notification as read
        UPDATE public.notifications
        SET is_read = TRUE
        WHERE user_id = NEW.receiver_id
          AND type = 'connection_request'
          AND reference_id = NEW.sender_id::text
          AND is_read = FALSE;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp;

DROP TRIGGER IF EXISTS trg_handle_connection_request_created ON public.connection_requests;
CREATE TRIGGER trg_handle_connection_request_created
    AFTER INSERT OR UPDATE OF status ON public.connection_requests
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_connection_request();

-- -----------------------------------------------------------------------------
-- 3. Enable Supabase Realtime Replication for Notifications
-- -----------------------------------------------------------------------------
ALTER TABLE public.notifications REPLICA IDENTITY FULL;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'notifications'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
    END IF;
EXCEPTION WHEN OTHERS THEN
    NULL;
END $$;
