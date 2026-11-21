// Supabase Edge Function: verify-student
// Allows designated college administrators or campus moderation to review and update student verification status
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

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing authorization token" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Verify calling user
    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: userError } = await supabase.auth.getUser(token);
    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Invalid caller auth" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Check if caller is admin
    const { data: adminRole } = await supabase
      .from("admin_roles")
      .select("role")
      .eq("user_id", user.id)
      .single();

    if (!adminRole) {
      return new Response(JSON.stringify({ error: "Unauthorized: Admin privileges required" }), {
        status: 403,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const { targetUserId, newStatus, reason } = await req.json();

    if (!targetUserId || !["verified", "rejected", "suspended", "pending"].includes(newStatus)) {
      return new Response(JSON.stringify({ error: "Invalid target user or status" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Update student verification status
    const { data: updatedProfile, error: updateError } = await supabase
      .from("profiles")
      .update({ verification_status: newStatus })
      .eq("id", targetUserId)
      .select()
      .single();

    if (updateError) throw updateError;

    // Send notification to student
    await supabase.from("notifications").insert({
      user_id: targetUserId,
      type: "verification_update",
      title: "Campus Verification Update",
      body: `Your TKMCE student verification status is now: ${newStatus.toUpperCase()}.${reason ? " Note: " + reason : ""}`,
      reference_id: targetUserId,
    });

    return new Response(
      JSON.stringify({
        success: true,
        profile: updatedProfile,
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
