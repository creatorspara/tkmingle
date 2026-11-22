const CACHE_NAME = "tkmingle-v1";
const STATIC_ASSETS = [
  "/manifest.webmanifest",
  "/favicon.ico",
  "/apple-touch-icon.png",
  "/icons/icon-192x192.png",
  "/icons/icon-512x512.png",
  "/images/logo_compact.svg",
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(STATIC_ASSETS).catch(() => {}))
  );
  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.map((k) => (k !== CACHE_NAME ? caches.delete(k) : null)))
    )
  );
  self.clients.claim();
});

self.addEventListener("fetch", (event) => {
  const url = new URL(event.request.url);

  // Do not cache API, auth, or Supabase requests
  if (
    url.hostname.includes("supabase.co") ||
    url.pathname.startsWith("/api/") ||
    url.pathname.startsWith("/auth/") ||
    event.request.method !== "GET"
  ) {
    return;
  }

  // Cache-first for static icons
  if (
    url.pathname.startsWith("/icons/") ||
    url.pathname === "/favicon.ico" ||
    url.pathname === "/apple-touch-icon.png" ||
    url.pathname === "/manifest.webmanifest"
  ) {
    event.respondWith(
      caches.match(event.request).then((cached) => cached || fetch(event.request))
    );
    return;
  }

  // Network-first for pages
  if (event.request.mode === "navigate") {
    event.respondWith(
      fetch(event.request).catch(() => caches.match("/"))
    );
  }
});
