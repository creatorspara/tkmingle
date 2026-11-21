"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import {
  ShieldCheck,
  Eye,
  LogOut,
  CheckCircle2,
} from "lucide-react";
import { useCurrentUser } from "@/lib/useUser";

export default function SettingsPage() {
  const router = useRouter();
  const { user, profile, logout } = useCurrentUser();
  const [discoverable, setDiscoverable] = useState(true);
  const [savedMsg, setSavedMsg] = useState(false);

  const handleToggleDiscoverable = () => {
    setDiscoverable(!discoverable);
    setSavedMsg(true);
    setTimeout(() => setSavedMsg(false), 2000);
  };

  const handleLogout = async () => {
    await logout();
  };

  const isVerified = profile?.verification_status === "verified" || !!user?.email_confirmed_at;

  return (
    <div className="p-4 sm:p-6 lg:p-8 max-w-4xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-extrabold text-white">Account &amp; Privacy Settings</h1>
        <p className="text-xs text-brand-muted">
          Manage how your student profile appears to the TKMCE campus
        </p>
      </div>

      {savedMsg && (
        <div className="p-3 rounded-xl bg-brand-teal/15 border border-brand-teal/40 text-xs text-brand-teal flex items-center gap-2">
          <CheckCircle2 className="w-4 h-4" />
          Settings updated successfully.
        </div>
      )}

      {/* Discoverability Settings */}
      <div className="glass-panel rounded-2xl p-6 border border-brand-border/80 space-y-5">
        <h2 className="text-sm font-bold text-white uppercase tracking-wider flex items-center gap-2">
          <Eye className="w-4 h-4 text-brand-purple" />
          Discovery Preferences
        </h2>

        <div className="flex items-center justify-between py-2 border-b border-brand-border/40">
          <div>
            <div className="text-xs font-semibold text-white">
              Campus Discoverability
            </div>
            <div className="text-[11px] text-brand-muted">
              Allow verified TKMCE students to discover your profile based on shared interests.
            </div>
          </div>
          <button
            onClick={handleToggleDiscoverable}
            className={`w-12 h-6 flex items-center rounded-full p-1 transition-colors ${
              discoverable ? "bg-brand-purple" : "bg-brand-navyCard border border-brand-border"
            }`}
            aria-label="Toggle discoverability"
          >
            <div
              className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform ${
                discoverable ? "translate-x-6" : "translate-x-0"
              }`}
            />
          </button>
        </div>

        <div className="flex items-center justify-between py-2">
          <div>
            <div className="text-xs font-semibold text-white">
              Student Verification Status
            </div>
            <div className="text-[11px] text-brand-muted">
              {isVerified
                ? "Your student account is verified with your institutional campus credentials."
                : "Verification pending. Confirm your college email address to complete verification."}
            </div>
          </div>
          <span className={`text-xs px-2.5 py-1 rounded-full font-semibold ${
            isVerified ? "bg-brand-teal/15 text-brand-teal" : "bg-brand-warning/15 text-brand-warning"
          }`}>
            {isVerified ? "Verified" : "Pending"}
          </span>
        </div>
      </div>

      {/* Safety & Moderation Controls */}
      <div className="glass-panel rounded-2xl p-6 border border-brand-border/80 space-y-4">
        <h2 className="text-sm font-bold text-white uppercase tracking-wider flex items-center gap-2">
          <ShieldCheck className="w-4 h-4 text-brand-teal" />
          Safety &amp; Blocking
        </h2>
        <p className="text-xs text-brand-muted">
          Blocked students cannot send connection requests, view your profile, or chat with you.
        </p>
        <div className="p-3 rounded-xl bg-brand-navyCard border border-brand-border/60 text-xs text-brand-muted">
          No blocked students currently.
        </div>
      </div>

      {/* Sign Out */}
      <div className="pt-2">
        <button
          onClick={handleLogout}
          className="px-5 py-2.5 rounded-tk-btn bg-brand-error/15 border border-brand-error/40 text-brand-error hover:bg-brand-error hover:text-white text-xs font-semibold transition-colors flex items-center gap-2"
        >
          <LogOut className="w-4 h-4" /> Sign Out of TKMingle
        </button>
      </div>
    </div>
  );
}
