"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { Coffee, Loader2 } from "lucide-react";

export default function TeaRedirectPage() {
  const router = useRouter();

  useEffect(() => {
    // Spill the Tea is strictly inside the authenticated student portal
    router.replace("/app/tea");
  }, [router]);

  return (
    <div className="min-h-screen bg-brand-navy flex flex-col items-center justify-center p-4 text-center">
      <div className="w-12 h-12 rounded-2xl bg-brand-purple/20 border border-brand-purple/40 flex items-center justify-center text-brand-lavender mb-4 shadow-lg">
        <Coffee className="w-6 h-6 animate-pulse" />
      </div>
      <h2 className="text-lg font-bold text-white mb-1">Spill the Tea ☕</h2>
      <p className="text-xs text-brand-muted mb-4 flex items-center gap-2">
        <Loader2 className="w-3.5 h-3.5 animate-spin text-brand-teal" />
        Redirecting to verified campus portal...
      </p>
    </div>
  );
}
