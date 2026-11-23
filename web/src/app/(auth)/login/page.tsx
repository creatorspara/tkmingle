"use client";

import React, { useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { ArrowLeft, Lock, Mail, Loader2, Sparkles, CheckCircle2 } from "lucide-react";
import { supabase, isLiveSupabaseConfigured } from "@/lib/supabaseClient";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  // If already authenticated, redirect directly to portal so back navigation works cleanly
  React.useEffect(() => {
    if (isLiveSupabaseConfigured()) {
      supabase.auth.getSession().then(({ data }) => {
        if (data?.session?.user) {
          router.replace("/app/discover");
        }
      });
    }
  }, [router]);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setErrorMsg(null);

    try {
      if (isLiveSupabaseConfigured()) {
        const { error } = await supabase.auth.signInWithPassword({
          email: email.trim().toLowerCase(),
          password,
        });
        if (error) throw error;
      } else {
        await new Promise((r) => setTimeout(r, 600));
      }
      router.replace("/app/discover");
    } catch (err: unknown) {
      let msg = err instanceof Error ? err.message : "Failed to sign in";
      if (msg.includes("Invalid login credentials") || msg.includes("invalid_credentials")) {
        msg = "Invalid email or password. Please check your credentials or register if you do not have an account.";
      } else if (msg.toLowerCase().includes("email not confirmed")) {
        msg = "Your college email has not been confirmed yet. Please check your inbox for the verification link.";
      }
      setErrorMsg(msg);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-brand-navy text-brand-text flex flex-col justify-center py-12 sm:px-6 lg:px-8 relative overflow-hidden">
      {/* Background glow */}
      <div className="absolute top-1/3 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[300px] bg-brand-purple/15 blur-[100px] rounded-full pointer-events-none" />

      <div className="sm:mx-auto sm:w-full sm:max-w-md relative z-10 px-4">
        {/* Back link */}
        <Link
          href="/"
          className="inline-flex items-center gap-1.5 text-xs text-brand-muted hover:text-white mb-6 transition-colors"
        >
          <ArrowLeft className="w-3.5 h-3.5" /> Back to Home
        </Link>

        {/* Brand Header */}
        <div className="text-center space-y-2">
          <div className="inline-flex items-center justify-center w-14 h-14 rounded-2xl bg-brand-navyCard border border-brand-border p-2 shadow-purple-glow">
            <Image
              src="/images/logo_compact.svg"
              alt="TKMingle"
              width={40}
              height={40}
            />
          </div>
          <h2 className="text-2xl font-bold tracking-tight text-white">
            Welcome back to TKMingle
          </h2>
          <p className="text-xs text-brand-muted">
            Enter your student credentials to access campus discovery
          </p>
        </div>

        {/* Login Form Box */}
        <div className="mt-8 glass-panel rounded-tk-card p-6 sm:p-8 border border-brand-border/80 shadow-2xl space-y-6">
          {errorMsg && (
            <div className="p-3 rounded-lg bg-brand-error/15 border border-brand-error/30 text-xs text-brand-error">
              {errorMsg}
            </div>
          )}

          <form onSubmit={handleLogin} className="space-y-4">
            <div>
              <label className="block text-xs font-semibold text-brand-muted uppercase tracking-wider mb-1.5">
                Campus Email
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-brand-muted">
                  <Mail className="w-4 h-4" />
                </div>
                <input
                  type="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="student@gmail.com"
                  className="w-full pl-10 pr-3.5 py-2.5 rounded-tk-btn bg-brand-navySecondary border border-brand-border text-sm text-white focus:outline-none focus:border-brand-purple focus:ring-1 focus:ring-brand-purple transition-all"
                />
              </div>
            </div>

            <div>
              <div className="flex items-center justify-between mb-1.5">
                <label className="block text-xs font-semibold text-brand-muted uppercase tracking-wider">
                  Password
                </label>
                <Link
                  href="/forgot-password"
                  className="text-xs text-brand-lavender hover:text-white"
                >
                  Forgot password?
                </Link>
              </div>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-brand-muted">
                  <Lock className="w-4 h-4" />
                </div>
                <input
                  type="password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className="w-full pl-10 pr-3.5 py-2.5 rounded-tk-btn bg-brand-navySecondary border border-brand-border text-sm text-white focus:outline-none focus:border-brand-purple focus:ring-1 focus:ring-brand-purple transition-all"
                />
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white font-semibold text-sm shadow-purple-glow transition-all flex items-center justify-center gap-2"
            >
              {loading ? (
                <>
                  <Loader2 className="w-4 h-4 animate-spin" /> Signing In...
                </>
              ) : (
                "Sign In"
              )}
            </button>
          </form>

          {/* Quick Demo Test Accounts for Local / Wi-Fi Testing */}
          <div className="pt-2 border-t border-brand-border/60 space-y-2">
            <span className="text-[11px] font-semibold text-brand-teal uppercase tracking-wider block">
              ⚡ Local Wi-Fi Quick Test Accounts
            </span>
            <div className="grid grid-cols-2 gap-2 text-xs">
              <button
                type="button"
                onClick={() => {
                  setEmail("test@tkmce.ac.in");
                  setPassword("Password123!");
                }}
                className="p-2.5 rounded-xl bg-brand-navySecondary hover:bg-brand-navyCard border border-brand-border/80 text-left transition-colors group"
              >
                <span className="font-bold text-white block text-[11px] group-hover:text-brand-teal">Test User (CSE)</span>
                <span className="text-[10px] text-brand-muted block truncate font-mono">test@tkmce.ac.in</span>
              </button>
              <button
                type="button"
                onClick={() => {
                  setEmail("demo@tkmce.ac.in");
                  setPassword("Password123!");
                }}
                className="p-2.5 rounded-xl bg-brand-navySecondary hover:bg-brand-navyCard border border-brand-border/80 text-left transition-colors group"
              >
                <span className="font-bold text-white block text-[11px] group-hover:text-brand-lavender">Demo User (Mech)</span>
                <span className="text-[10px] text-brand-muted block truncate font-mono">demo@tkmce.ac.in</span>
              </button>
            </div>
            <p className="text-[10px] text-brand-muted text-center">
              Tap above to auto-fill &bull; Password: <code className="text-brand-lavender font-mono">Password123!</code>
            </p>
          </div>

          <div className="text-center text-xs text-brand-muted pt-1">
            New to TKMCE campus?{" "}
            <Link href="/register" className="font-semibold text-brand-lavender hover:text-white">
              Create an account
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
