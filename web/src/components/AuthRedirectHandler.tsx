"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";

/**
 * Global authentication redirect watcher.
 * Catches password recovery hashes (#access_token=...&type=recovery)
 * that Supabase drops on the base Site URL (https://tkmingle.vercel.app/#...)
 * and immediately routes the user to /reset-password with the recovery credentials intact.
 */
export default function AuthRedirectHandler() {
  const router = useRouter();

  useEffect(() => {
    if (typeof window === "undefined") return;

    const pathname = window.location.pathname;
    const hash = window.location.hash;
    const search = window.location.search;

    // Only forward if not already on /reset-password
    if (pathname.includes("/reset-password")) return;

    // Detect recovery in hash (#access_token=...&type=recovery)
    if (hash && (hash.includes("type=recovery") || hash.includes("recovery"))) {
      router.replace(`/reset-password${hash}`);
      return;
    }

    // Detect recovery in search (?token_hash=...&type=recovery)
    if (search && search.includes("type=recovery")) {
      router.replace(`/reset-password${search}`);
      return;
    }
  }, [router]);

  return null;
}
