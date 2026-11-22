// TKMingle Lightweight PWA Service Worker
// Purpose: Standalone shell registration & static icon caching only.
// STRICT PRIVACY: Authenticated sessions, Supabase API calls, and dynamic routes are NEVER cached.

const CACHE_NAME = "tkmingle-shell-v1";
const STATIC_ASSETS = [
  "/manifest.webmanifest",
  "/favicon.ico",
  "/apple-touch-icon.png",
  "/icons/icon-192x192.png",
  "/icons/icon-512x512.png",
  "/images/logo_compact.svg",
];

// 1. Install & Cache Shell Assets
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(STATIC_ASSETS).catch((err) => {
        console.warn("[SW] Cache addAll notice:", err);
      });
    })
  );
  self.skipWaiting();
});

// 2. Activate & Purge Stale Caches
self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.map((key) => {
          if (key !== CACHE_NAME) {
            return caches.delete(key);
          }
        })
      );
    })
  );
  self.clients.claim();
});

// 3. Fetch Strategy: Network-First with strict bypass for auth & dynamic data
self.addEventListener("fetch", (event) => {
  const url = new URL(event.request.url);

  // STRICT BYPASS: Never intercept or cache Supabase, API, or WebSocket requests
  if (
    url.hostname.includes("supabase.co") ||
    url.pathname.startsWith("/api/") ||
    url.pathname.startsWith("/auth/") ||
    event.request.method !== "GET" ||
    event.request.headers.has("Authorization")
  ) {
    return; // Hand off directly to network
  }

  // Static shell assets: Cache-first fallback to network
  if (
    url.pathname.startsWith("/icons/") ||
    url.pathname.startsWith("/images/") ||
    url.pathname === "/favicon.ico" ||
    url.pathname === "/apple-touch-icon.png" ||
    url.pathname === "/manifest.webmanifest"
  ) {
    event.respondWith(
      caches.match(event.request).then((cached) => {
        return (
          cached ||
          fetch(event.request).then((response) => {
            if (response && response.status === 200) {
              const responseToCache = response.clone();
              caches.open(CACHE_NAME).then((cache) => {
                cache.put(event.request, responseToCache);
              });
            }
            return response;
          })
        );
      })
    );
    return;
  }

  // Navigation / Pages: Network-first to always guarantee fresh data and authentication
  if (event.request.mode === "navigate") {
    event.respondWith(
      fetch(event.request).catch(() => {
        return caches.match("/");
      })
    );
  }
});
