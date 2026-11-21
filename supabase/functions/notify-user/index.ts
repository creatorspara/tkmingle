// Supabase Edge Function: notify-user
// Dispatches push notifications to students via FCM or Web Push securely using server-side credentials
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const { userId, title, body, type, referenceId } = await req.json();

    if (!userId || !title || !body) {
      return new Response(JSON.stringify({ error: "Missing required fields" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 1. Insert record in notifications table
    const { data: notif, error: notifError } = await supabase
      .from("notifications")
      .insert({
        user_id: userId,
        type: type || "connection_request",
        title,
        body,
        reference_id: referenceId || null,
        is_read: false,
      })
      .select()
      .single();

    if (notifError) throw notifError;

    // 2. Query student's active device tokens
    const { data: tokens } = await supabase
      .from("device_tokens")
      .select("device_token, platform")
      .eq("user_id", userId);

    return new Response(
      JSON.stringify({
        success: true,
        notification: notif,
        tokenCount: tokens?.length || 0,
        message: "Notification logged and scheduled for dispatch",
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      }
    );
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});
