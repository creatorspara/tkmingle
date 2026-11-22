"use client";

import { useEffect } from "react";

export default function PwaRegister() {
  useEffect(() => {
    if (
      typeof window !== "undefined" &&
      "serviceWorker" in navigator &&
      window.location.protocol === "https:" || window.location.hostname === "localhost"
    ) {
      window.addEventListener("load", () => {
        navigator.serviceWorker
          .register("/sw.js")
          .then((registration) => {
            // Service worker registered safely
            if (process.env.NODE_ENV === "development") {
              console.log("[PWA] Service Worker registered with scope:", registration.scope);
            }
          })
          .catch((error) => {
            console.warn("[PWA] Service Worker registration notice:", error);
          });
      });
    }
  }, []);

  return null;
}
