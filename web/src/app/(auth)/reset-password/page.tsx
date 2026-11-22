"use client";

import React, { useState, useEffect } from "react";
import Image from "next/image";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { ArrowLeft, Lock, Loader2, CheckCircle2, AlertCircle, Eye, EyeOff } from "lucide-react";
import { supabase, isLiveSupabaseConfigured } from "@/lib/supabaseClient";

export default function ResetPasswordPage() {
  const router = useRouter();
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [verifyingSession, setVerifyingSession] = useState(true);
  const [hasValidSession, setHasValidSession] = useState(false);
  const [success, setSuccess] = useState(false);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  useEffect(() => {
    let isSubscribed = true;

    async function checkRecoverySession() {
      if (!isLiveSupabaseConfigured()) {
        if (isSubscribed) {
          setHasValidSession(true);
          setVerifyingSession(false);
        }
        return;
      }

      // 1. Process URL query parameters (token_hash or code)
      if (typeof window !== "undefined") {
        const searchParams = new URLSearchParams(window.location.search);
        const token_hash = searchParams.get("token_hash");
        const type = searchParams.get("type");
        const code = searchParams.get("code");

        if (token_hash) {
          try {
            const { data, error } = await supabase.auth.verifyOtp({
              token_hash,
              type: (type as any) || "recovery",
            });
            if (!error && data?.session) {
              if (isSubscribed) {
                setHasValidSession(true);
                setVerifyingSession(false);
              }
              return;
            }
          } catch (err) {
            console.warn("token_hash verification notice:", err);
          }
        }

        if (code) {
          try {
            const { data, error } = await supabase.auth.exchangeCodeForSession(code);
            if (!error && data?.session) {
              if (isSubscribed) {
                setHasValidSession(true);
                setVerifyingSession(false);
              }
              return;
            }
          } catch (err) {
            console.warn("code exchange notice:", err);
          }
        }
      }

      // 2. Check current session
      const { data } = await supabase.auth.getSession();
      if (data?.session) {
        if (isSubscribed) {
          setHasValidSession(true);
          setVerifyingSession(false);
        }
        return;
      }

      // 3. Listen for auth state change (e.g. PASSWORD_RECOVERY event from URL hash)
      const {
        data: { subscription },
      } = supabase.auth.onAuthStateChange((event, session) => {
        if (event === "PASSWORD_RECOVERY" || session) {
          if (isSubscribed) {
            setHasValidSession(true);
          }
        }
        if (isSubscribed) {
          setVerifyingSession(false);
        }
      });

      // 4. Timeout fallback in case no hash or code was supplied
      const timer = setTimeout(() => {
        if (isSubscribed) {
          setVerifyingSession(false);
        }
      }, 2500);

      return () => {
        subscription.unsubscribe();
        clearTimeout(timer);
      };
    }

    checkRecoverySession();

    return () => {
      isSubscribed = false;
    };
  }, []);

  const handleResetPassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMsg(null);

    if (password.length < 6) {
      setErrorMsg("Password must be at least 6 characters long.");
      return;
    }

    if (password !== confirmPassword) {
      setErrorMsg("Passwords do not match. Please re-enter.");
      return;
    }

    setLoading(true);

    try {
      if (isLiveSupabaseConfigured()) {
        const { error } = await supabase.auth.updateUser({
          password: password,
        });
        if (error) throw error;
      } else {
        await new Promise((r) => setTimeout(r, 600));
      }
      setSuccess(true);
    } catch (err: unknown) {
      setErrorMsg(err instanceof Error ? err.message : "Failed to update password. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-brand-navy text-brand-text flex flex-col justify-center py-12 sm:px-6 lg:px-8 relative overflow-hidden">
      {/* Background glow */}
      <div className="absolute top-1/3 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[300px] bg-brand-purple/15 blur-[100px] rounded-full pointer-events-none" />

      <div className="sm:mx-auto sm:w-full sm:max-w-md relative z-10 px-4">
        {/* Back to login */}
        <Link
          href="/login"
          className="inline-flex items-center gap-1.5 text-xs text-brand-muted hover:text-white mb-6 transition-colors"
        >
          <ArrowLeft className="w-3.5 h-3.5" /> Back to Sign In
        </Link>

        {/* Brand Header */}
        <div className="text-center space-y-2">
          <div className="inline-flex items-center justify-center w-14 h-14 rounded-2xl bg-brand-navyCard border border-brand-border p-2 shadow-purple-glow">
            <Image src="/images/logo_compact.svg" alt="TKMingle" width={40} height={40} />
          </div>
          <h2 className="text-2xl font-bold tracking-tight text-white">Create New Password</h2>
          <p className="text-xs text-brand-muted">
            Enter and confirm your new password to secure your account.
          </p>
        </div>

        {/* Form Container */}
        <div className="mt-8 glass-panel rounded-tk-card p-6 sm:p-8 border border-brand-border/80 shadow-2xl space-y-6">
          {verifyingSession ? (
            <div className="py-12 flex flex-col items-center justify-center text-white">
              <Loader2 className="w-8 h-8 animate-spin text-brand-purple mb-2" />
              <p className="text-xs text-brand-muted">Verifying recovery credentials...</p>
            </div>
          ) : !hasValidSession && !success ? (
            <div className="text-center space-y-4 py-4">
              <div className="p-3 rounded-xl bg-brand-error/15 border border-brand-error/30 text-xs text-brand-error flex items-center gap-2 text-left">
                <AlertCircle className="w-5 h-5 flex-shrink-0" />
                <span>
                  Recovery link has expired or is invalid. Please request a new password reset email.
                </span>
              </div>
              <Link
                href="/forgot-password"
                className="inline-block w-full py-2.5 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white font-semibold text-xs transition-colors"
              >
                Request New Reset Link
              </Link>
            </div>
          ) : success ? (
            <div className="text-center space-y-4 py-4">
              <CheckCircle2 className="w-12 h-12 text-brand-teal mx-auto" />
              <div className="text-lg font-bold text-white">Password Updated Successfully</div>
              <p className="text-xs text-brand-muted">
                Your password has been changed. You can now sign in with your new credentials.
              </p>
              <button
                onClick={() => router.push("/login")}
                className="w-full py-3 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white font-semibold text-sm shadow-purple-glow transition-all"
              >
                Proceed to Sign In
              </button>
            </div>
          ) : (
            <form onSubmit={handleResetPassword} className="space-y-4">
              {errorMsg && (
                <div className="p-3 rounded-lg bg-brand-error/15 border border-brand-error/30 text-xs text-brand-error flex items-center gap-2">
                  <AlertCircle className="w-4 h-4 flex-shrink-0" />
                  <span>{errorMsg}</span>
                </div>
              )}

              <div>
                <label className="block text-xs font-semibold text-brand-muted uppercase tracking-wider mb-1.5">
                  New Password
                </label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-brand-muted">
                    <Lock className="w-4 h-4" />
                  </div>
                  <input
                    type={showPassword ? "text" : "password"}
                    required
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="At least 6 characters"
                    className="w-full pl-10 pr-10 py-2.5 rounded-tk-btn bg-brand-navySecondary border border-brand-border text-sm text-white focus:outline-none focus:border-brand-purple transition-all"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute inset-y-0 right-0 pr-3 flex items-center text-brand-muted hover:text-white"
                  >
                    {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-brand-muted uppercase tracking-wider mb-1.5">
                  Confirm New Password
                </label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-brand-muted">
                    <Lock className="w-4 h-4" />
                  </div>
                  <input
                    type={showPassword ? "text" : "password"}
                    required
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    placeholder="Re-enter your new password"
                    className="w-full pl-10 pr-3.5 py-2.5 rounded-tk-btn bg-brand-navySecondary border border-brand-border text-sm text-white focus:outline-none focus:border-brand-purple transition-all"
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
                    <Loader2 className="w-4 h-4 animate-spin" /> Saving Password...
                  </>
                ) : (
                  "Update Password"
                )}
              </button>
            </form>
          )}
        </div>
      </div>
    </div>
  );
}
