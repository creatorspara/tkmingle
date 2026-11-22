/**
 * TKMingle Authentication & Canonical Domain Configuration
 * Official canonical production domain: https://tkmingle.vercel.app
 */

export const CANONICAL_SITE_URL = "https://tkmingle.vercel.app";
export const LEGACY_SITE_URL = "https://tkmingle-creatorspara.vercel.app";

/**
 * Returns the canonical base URL for all authentication redirects
 * (email confirmation, password recovery, login callbacks).
 *
 * Evaluation rules:
 * 1. Explicitly configured NEXT_PUBLIC_SITE_URL (canonical production domain: https://tkmingle.vercel.app)
 * 2. Localhost development environments (allows testing on http://localhost:3000)
 * 3. Fallback: strictly defaults to CANONICAL_SITE_URL (https://tkmingle.vercel.app)
 *
 * NOTE: We deliberately avoid automatically falling back to NEXT_PUBLIC_VERCEL_URL
 * or window.location.origin in production, preventing verification emails from pointing
 * to legacy preview or deployment-specific domains (e.g. tkmingle-creatorspara.vercel.app).
 */
export function getCanonicalSiteUrl(): string {
  // 1. Explicitly defined environment variable
  const envUrl = process.env.NEXT_PUBLIC_SITE_URL;
  if (envUrl && typeof envUrl === "string" && envUrl.trim() !== "") {
    return envUrl.trim().replace(/\/+$/, "");
  }

  // 2. Local development fallback (strictly localhost / 127.0.0.1)
  if (typeof window !== "undefined") {
    const hostname = window.location.hostname;
    if (hostname === "localhost" || hostname === "127.0.0.1") {
      return window.location.origin;
    }
  }

  // 3. Official production domain fallback
  return CANONICAL_SITE_URL;
}

/**
 * Resolves an absolute redirect URL against the canonical site domain.
 * @param path - Target relative path (e.g. '/verify-email', '/auth/callback')
 * @returns Fully qualified absolute URL (e.g. 'https://tkmingle.vercel.app/verify-email')
 */
export function getAuthRedirectUrl(path: string = "/verify-email"): string {
  const base = getCanonicalSiteUrl();
  const cleanPath = path.startsWith("/") ? path : `/${path}`;
  return `${base}${cleanPath}`;
}
