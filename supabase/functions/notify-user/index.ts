// Supabase Edge Function: notify-user
// Dispatches push notifications to students via Google FCM v1 securely using Service Account credentials
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

/**
 * Mint Google OAuth2 access token via Web Crypto API (no external NPM modules needed)
 */
async function getGoogleAccessToken(serviceAccount: {
  client_email: string;
  private_key: string;
  project_id: string;
}): Promise<string> {
  const iat = Math.floor(Date.now() / 1000);
  const exp = iat + 3600;

  const header = { alg: "RS256", typ: "JWT" };
  const claimSet = {
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    exp,
    iat,
  };

  const encodeBase64Url = (str: string) =>
    btoa(str).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");

  const encodedHeader = encodeBase64Url(JSON.stringify(header));
  const encodedClaimSet = encodeBase64Url(JSON.stringify(claimSet));
  const unsignedToken = `${encodedHeader}.${encodedClaimSet}`;

  // Clean PEM private key
  const pemHeader = "-----BEGIN PRIVATE KEY-----";
  const pemFooter = "-----END PRIVATE KEY-----";
  const pemContents = serviceAccount.private_key
    .replace(pemHeader, "")
    .replace(pemFooter, "")
    .replace(/\\n/g, "")
    .replace(/\s+/g, "");

  const binaryDer = Uint8Array.from(atob(pemContents), (c) => c.charCodeAt(0));

  const key = await crypto.subtle.importKey(
    "pkcs8",
    binaryDer.buffer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsignedToken)
  );

  const encodedSignature = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");

  const jwt = `${unsignedToken}.${encodedSignature}`;

  // Exchange JWT for Access Token
  const tokenResp = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });

  const tokenData = await tokenResp.json();
  if (!tokenResp.ok) {
    throw new Error(`Failed to obtain Google access token: ${JSON.stringify(tokenData)}`);
  }

  return tokenData.access_token;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const bodyJson = await req.json();

    // Support both direct API invocation and Database Webhook payloads
    const isWebhook = Boolean(bodyJson.record);
    const userId = isWebhook ? bodyJson.record.user_id : bodyJson.userId;
    const title = isWebhook ? bodyJson.record.title : bodyJson.title;
    const body = isWebhook ? bodyJson.record.body : bodyJson.body;
    const type = isWebhook ? bodyJson.record.type : (bodyJson.type || "connection_request");
    const referenceId = isWebhook ? bodyJson.record.reference_id : (bodyJson.referenceId || null);

    if (!userId || !title || !body) {
      return new Response(JSON.stringify({ error: "Missing required fields" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 1. If not from a webhook, insert record into public.notifications
    if (!isWebhook) {
      await supabase.from("notifications").insert({
        user_id: userId,
        type,
        title,
        body,
        reference_id: referenceId,
        is_read: false,
      });
    }

    // 2. Query student's active device tokens from public.device_tokens
    const { data: tokens, error: tokensError } = await supabase
      .from("device_tokens")
      .select("device_token, platform")
      .eq("user_id", userId);

    if (tokensError) {
      console.error("Error querying device tokens:", tokensError);
    }

    // 3. Dispatch FCM v1 notifications if tokens exist and service account is configured
    let fcmDispatched = 0;
    const rawServiceAccount = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");

    if (tokens && tokens.length > 0 && rawServiceAccount) {
      try {
        let serviceAccount: any;
        try {
          serviceAccount = JSON.parse(rawServiceAccount);
        } catch {
          // In case it's base64 encoded
          serviceAccount = JSON.parse(atob(rawServiceAccount));
        }

        const accessToken = await getGoogleAccessToken(serviceAccount);
        const fcmEndpoint = `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`;

        for (const t of tokens) {
          if (!t.device_token) continue;
          try {
            const fcmRes = await fetch(fcmEndpoint, {
              method: "POST",
              headers: {
                Authorization: `Bearer ${accessToken}`,
                "Content-Type": "application/json",
              },
              body: JSON.stringify({
                message: {
                  token: t.device_token,
                  notification: {
                    title,
                    body,
                  },
                  data: {
                    type: String(type || ""),
                    reference_id: String(referenceId || ""),
                  },
                  android: {
                    priority: "high",
                    notification: {
                      channel_id: "tkmingle_alerts",
                      icon: "ic_launcher",
                      color: "#6C5CE7",
                      default_sound: true,
                      default_vibrate_timings: true,
                    },
                  },
                },
              }),
            });

            if (fcmRes.ok) {
              fcmDispatched++;
            } else {
              const errTxt = await fcmRes.text();
              console.warn(`FCM send failed for token: ${errTxt}`);
            }
          } catch (sendErr) {
            console.error("FCM dispatch error:", sendErr);
          }
        }
      } catch (authErr) {
        console.error("Google Auth or FCM error:", authErr);
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        tokensFound: tokens?.length || 0,
        fcmDispatched,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      }
    );
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});
