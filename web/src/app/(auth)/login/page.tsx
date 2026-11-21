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

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setErrorMsg(null);

    try {
      if (isLiveSupabaseConfigured()) {
        const { error } = await supabase.auth.signInWithPassword({
          email: email.trim(),
          password,
        });
        if (error) throw error;
      } else {
        // Mock session mode
        await new Promise((r) => setTimeout(r, 600));
      }
      router.push("/app/discover");
    } catch (err: unknown) {
      setErrorMsg(err instanceof Error ? err.message : "Failed to sign in");
    } finally {
      setLoading(false);
    }
  };

  const handleQuickDemoLogin = (demoEmail: string) => {
    setEmail(demoEmail);
    setPassword("tkmce2026");
    setLoading(true);
    setTimeout(() => {
      router.push("/app/discover");
    }, 500);
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
                  placeholder="student@tkmce.ac.in"
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

          {/* Quick Demo Switcher */}
          <div className="pt-4 border-t border-brand-border/60 space-y-2">
            <span className="text-[11px] font-semibold text-brand-muted uppercase tracking-wider block text-center">
              Quick Demo Access
            </span>
            <div className="grid grid-cols-2 gap-2 text-xs">
              <button
                type="button"
                onClick={() => handleQuickDemoLogin("arjun.k@tkmce.ac.in")}
                className="p-2 rounded-lg bg-brand-navyCard border border-brand-border hover:border-brand-purple text-left transition-colors"
              >
                <div className="font-semibold text-white">Arjun K.</div>
                <div className="text-[10px] text-brand-muted">CSE • 3rd Year</div>
              </button>
              <button
                type="button"
                onClick={() => handleQuickDemoLogin("sneha.varma@tkmce.ac.in")}
                className="p-2 rounded-lg bg-brand-navyCard border border-brand-border hover:border-brand-teal text-left transition-colors"
              >
                <div className="font-semibold text-white">Sneha V.</div>
                <div className="text-[10px] text-brand-muted">ECE • 3rd Year</div>
              </button>
            </div>
          </div>

          <div className="text-center text-xs text-brand-muted pt-2">
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
