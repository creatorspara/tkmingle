"use client";

import React, { useState, useEffect, useRef } from "react";
import { Shield, ExternalLink, X, Sparkles } from "lucide-react";

export default function NewProjectNotification() {
  const [visible, setVisible] = useState(false);
  const [isClosing, setIsClosing] = useState(false);
  const [isPaused, setIsPaused] = useState(false);
  const timerRef = useRef<NodeJS.Timeout | null>(null);
  const startTimeRef = useRef<number>(0);
  const remainingTimeRef = useRef<number>(5000);

  useEffect(() => {
    // Show after a brief delay for a fluid entrance
    const enterTimeout = setTimeout(() => {
      setVisible(true);
      startTimeRef.current = Date.now();
      timerRef.current = setTimeout(() => {
        dismiss();
      }, 5000);
    }, 450);

    return () => {
      clearTimeout(enterTimeout);
      if (timerRef.current) clearTimeout(timerRef.current);
    };
  }, []);

  const dismiss = () => {
    setIsClosing(true);
    setTimeout(() => {
      setVisible(false);
    }, 400);
  };

  const handleMouseEnter = () => {
    setIsPaused(true);
    if (timerRef.current) {
      clearTimeout(timerRef.current);
      timerRef.current = null;
      const elapsed = Date.now() - startTimeRef.current;
      remainingTimeRef.current = Math.max(1500, remainingTimeRef.current - elapsed);
    }
  };

  const handleMouseLeave = () => {
    setIsPaused(false);
    startTimeRef.current = Date.now();
    timerRef.current = setTimeout(() => {
      dismiss();
    }, remainingTimeRef.current);
  };

  if (!visible) return null;

  return (
    <aside
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
      data-paused={isPaused ? "true" : "false"}
      className={`fixed top-4 left-1/2 -translate-x-1/2 z-[100] max-w-xl w-[calc(100%-2rem)] transition-all duration-400 ease-out select-none ${
        isClosing
          ? "opacity-0 -translate-y-5 scale-95 pointer-events-none"
          : "opacity-100 translate-y-0 scale-100"
      }`}
      aria-label="New Project Announcement"
    >
      <div className="relative overflow-hidden rounded-2xl bg-[#0C0E1A]/95 border border-[#6C4DFF]/40 shadow-2xl shadow-[#6C4DFF]/25 backdrop-blur-xl p-3.5 sm:p-4 text-white">
        {/* Animated 5s progress bar indicating auto-fade timer */}
        <div
          className={`absolute bottom-0 left-0 h-[2.5px] bg-gradient-to-r from-[#6C4DFF] via-[#50D6C2] to-[#B9A9FF] w-full animate-shrink-5s ${
            isPaused ? "[animation-play-state:paused]" : ""
          }`}
        />

        <div className="flex items-center gap-3">
          {/* Vault Icon with Kromium glow */}
          <div className="w-9 h-9 sm:w-10 sm:h-10 rounded-xl bg-[#6C4DFF]/20 border border-[#6C4DFF]/40 flex items-center justify-center text-[#50D6C2] shrink-0 shadow-inner">
            <Shield className="w-5 h-5" />
          </div>

          {/* Project Details */}
          <div className="flex-1 min-w-0 pr-1">
            <div className="flex items-center gap-2 mb-0.5 flex-wrap">
              <span className="inline-flex items-center gap-1 text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-full bg-[#6C4DFF]/30 text-[#D1C4FF] border border-[#6C4DFF]/40">
                <Sparkles className="w-2.5 h-2.5 text-[#50D6C2]" /> New From Equipo Kromium
              </span>
              <span className="text-[11px] sm:text-xs font-bold text-white tracking-tight truncate">
                Equipo Kromium Vault (v2.0)
              </span>
            </div>
            <p className="text-[11px] text-gray-300 leading-snug line-clamp-1">
              Multi-platform NIST SP 800-38D AES-256-GCM file security ecosystem.
            </p>
          </div>

          {/* Action & Close Buttons */}
          <div className="flex items-center gap-2 shrink-0">
            <a
              href="https://github.com/creatorspara/equipo-kromium-vault"
              target="_blank"
              rel="noreferrer"
              className="px-3 py-1.5 rounded-xl bg-[#6C4DFF] hover:bg-[#6C4DFF]/90 text-white font-semibold text-xs flex items-center gap-1.5 transition-all shadow-md shadow-[#6C4DFF]/30 active:scale-95"
            >
              <span>View</span>
              <ExternalLink className="w-3 h-3" />
            </a>
            <button
              onClick={dismiss}
              aria-label="Close notification"
              className="p-1.5 rounded-lg text-gray-400 hover:text-white hover:bg-white/10 transition-colors"
            >
              <X className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>
    </aside>
  );
}
