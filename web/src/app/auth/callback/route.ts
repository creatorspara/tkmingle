import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@supabase/supabase-js";
import { getCanonicalSiteUrl } from "@/lib/authConfig";

/**
 * Supabase Auth Callback Route Handler
 * Exchanges verification codes / token hashes and securely redirects
 * to the canonical production domain (https://tkmingle.vercel.app).
 */
export async function GET(request: NextRequest) {
  const requestUrl = new URL(request.url);
  const code = requestUrl.searchParams.get("code");
  const token_hash = requestUrl.searchParams.get("token_hash");
  const type = requestUrl.searchParams.get("type");
  const next = requestUrl.searchParams.get("next") || (type === "recovery" ? "/reset-password" : "/app/discover");
  const error = requestUrl.searchParams.get("error");
  const error_description = requestUrl.searchParams.get("error_description");

  const canonicalBase = getCanonicalSiteUrl();

  // If Supabase returned an error during verification
  if (error || error_description) {
    const errorUrl = new URL("/login", canonicalBase);
    errorUrl.searchParams.set("error", error_description || error || "Verification failed");
    return NextResponse.redirect(errorUrl);
  }

  // Handle PKCE code exchange or token_hash verification
  if (code || (token_hash && type)) {
    const supabaseUrl =
      process.env.NEXT_PUBLIC_SUPABASE_URL || "https://mwwjuibehscukzueykjc.supabase.co";
    const supabaseAnonKey =
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "sb_publishable_04veCw-az3gqv23ZD_tUbA_8MKS_lzS";

    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      auth: { persistSession: false },
    });

    try {
      if (code) {
        await supabase.auth.exchangeCodeForSession(code);
      } else if (token_hash && type) {
        await supabase.auth.verifyOtp({
          token_hash,
          type: type as any,
        });
      }
    } catch (err) {
      console.error("Auth callback verification error:", err);
    }
  }

  // Safe redirect path anchored strictly to the canonical domain
  const safeNext = next.startsWith("/") ? next : `/${next}`;
  const redirectUrl = new URL(safeNext, canonicalBase);

  // Preserve non-auth parameters (such as verified=true, email, etc.)
  requestUrl.searchParams.forEach((value, key) => {
    if (!["code", "token_hash", "type", "next"].includes(key)) {
      redirectUrl.searchParams.set(key, value);
    }
  });

  return NextResponse.redirect(redirectUrl);
}
