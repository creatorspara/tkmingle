"use client";

import React, { useState, useEffect, Suspense } from "react";
import Image from "next/image";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { ArrowLeft, CheckCircle2, Loader2, MailCheck, AlertCircle, RefreshCw, Send } from "lucide-react";
import { supabase, isLiveSupabaseConfigured } from "@/lib/supabaseClient";

function VerifyEmailContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const emailParam = searchParams.get("email");
  const [email, setEmail] = useState(emailParam || "");
  const [otp, setOtp] = useState("");
  const [loading, setLoading] = useState(false);
  const [checkingAuth, setCheckingAuth] = useState(true);
  const [verified, setVerified] = useState(false);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [resendStatus, setResendStatus] = useState<string | null>(null);
  const [isResending, setIsResending] = useState(false);

  useEffect(() => {
    let mounted = true;

    async function checkVerificationState() {
      if (!isLiveSupabaseConfigured()) {
        if (mounted) setCheckingAuth(false);
        return;
      }

      try {
        const { data: { user } } = await supabase.auth.getUser();
        if (user) {
          if (!email && user.email) {
            setEmail(user.email);
          }
          if (user.email_confirmed_at) {
            if (mounted) {
              setVerified(true);
              setCheckingAuth(false);
              setTimeout(() => {
                router.push("/app/discover");
              }, 1200);
              return;
            }
          }
        }
      } catch (e) {
        console.warn("Auth state check note:", e);
      } finally {
        if (mounted) setCheckingAuth(false);
      }
    }

    checkVerificationState();

    // Listen for auth state changes (e.g. user clicked verification link in email)
    const { data: listener } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        if (!mounted) return;
        if (session?.user?.email_confirmed_at || event === "SIGNED_IN") {
          setVerified(true);
          setTimeout(() => {
            router.push("/app/discover");
          }, 1200);
        }
      }
    );

    return () => {
      mounted = false;
      listener?.subscription.unsubscribe();
    };
  }, [email, router]);

  const handleVerifyOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!otp.trim() || otp.trim().length !== 6) {
      setErrorMsg("Please enter the 6-digit verification code sent to your email.");
      return;
    }

    setLoading(true);
    setErrorMsg(null);

    try {
      if (isLiveSupabaseConfigured()) {
        const { data, error } = await supabase.auth.verifyOtp({
          email: email.trim(),
          token: otp.trim(),
          type: "signup",
        });

        if (error) {
          // Also try email verification type
          const secondAttempt = await supabase.auth.verifyOtp({
            email: email.trim(),
            token: otp.trim(),
            type: "email",
          });
          if (secondAttempt.error) throw secondAttempt.error;
        }

        setVerified(true);
        setTimeout(() => {
          router.push("/app/discover");
        }, 1200);
      } else {
        throw new Error("Supabase is not configured.");
      }
    } catch (err: unknown) {
      setErrorMsg(err instanceof Error ? err.message : "Verification failed. Check your code and try again.");
    } finally {
      setLoading(false);
    }
  };

  const handleManualCheck = async () => {
    setLoading(true);
    setErrorMsg(null);
    try {
      if (isLiveSupabaseConfigured()) {
        const { data: { user }, error } = await supabase.auth.getUser();
        if (user && user.email_confirmed_at) {
          setVerified(true);
          setTimeout(() => router.push("/app/discover"), 1000);
          return;
        }
      }
      setErrorMsg("Email not verified yet. Please click the link in your confirmation email or enter your code.");
    } catch (err) {
      setErrorMsg("Could not check verification status.");
    } finally {
      setLoading(false);
    }
  };

  const handleResend = async () => {
    if (!email) {
      setErrorMsg("Please specify your email address to resend verification.");
      return;
    }
    setIsResending(true);
    setErrorMsg(null);
    setResendStatus(null);

    try {
      if (isLiveSupabaseConfigured()) {
        const siteUrl = typeof window !== "undefined" ? window.location.origin : "https://tkmingle.vercel.app";
        const { error } = await supabase.auth.resend({
          type: "signup",
          email: email.trim(),
          options: {
            emailRedirectTo: `${siteUrl}/verify-email`,
          },
        });
        if (error) throw error;
        setResendStatus("A new verification email has been sent. Please check your inbox and spam folder.");
      } else {
        setResendStatus("Verification email simulated (mock mode).");
      }
    } catch (err: unknown) {
      setErrorMsg(err instanceof Error ? err.message : "Failed to resend verification email");
    } finally {
      setIsResending(false);
    }
  };

  return (
    <div className="min-h-screen bg-brand-navy text-brand-text flex flex-col justify-center py-12 sm:px-6 lg:px-8 relative overflow-hidden">
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[300px] bg-brand-purple/15 blur-[100px] rounded-full pointer-events-none" />

      <div className="sm:mx-auto sm:w-full sm:max-w-md relative z-10 px-4">
        <Link
          href="/login"
          className="inline-flex items-center gap-1.5 text-xs text-brand-muted hover:text-white mb-6 transition-colors"
        >
          <ArrowLeft className="w-3.5 h-3.5" /> Back to Login
        </Link>

        <div className="glass-panel rounded-tk-card p-6 sm:p-8 border border-brand-border/80 shadow-2xl text-center space-y-6">
          <div className="w-16 h-16 rounded-2xl bg-brand-purple/20 text-brand-purple mx-auto flex items-center justify-center">
            {verified ? (
              <CheckCircle2 className="w-8 h-8 text-brand-teal" />
            ) : checkingAuth ? (
              <Loader2 className="w-8 h-8 text-brand-purple animate-spin" />
            ) : (
              <MailCheck className="w-8 h-8 text-brand-lavender" />
            )}
          </div>

          <div className="space-y-2">
            <h2 className="text-xl font-bold text-white">
              {verified ? "Email Confirmed!" : "Verify Campus Email"}
            </h2>
            <p className="text-xs text-brand-muted leading-relaxed">
              {verified ? (
                "Your student account is now verified. Redirecting to TKMingle..."
              ) : (
                <>
                  We sent a confirmation link &amp; code to{" "}
                  <span className="text-brand-lavender font-semibold">{email || "your college email"}</span>.
                  Click the link in your email to instantly verify, or enter the 6-digit code below.
                </>
              )}
            </p>
          </div>

          {errorMsg && (
            <div className="p-3 rounded-lg bg-brand-error/15 border border-brand-error/30 text-xs text-brand-error flex items-center gap-2 text-left">
              <AlertCircle className="w-4 h-4 flex-shrink-0" />
              <span>{errorMsg}</span>
            </div>
          )}

          {resendStatus && (
            <div className="p-3 rounded-lg bg-brand-teal/15 border border-brand-teal/30 text-xs text-brand-teal flex items-center gap-2 text-left">
              <CheckCircle2 className="w-4 h-4 flex-shrink-0" />
              <span>{resendStatus}</span>
            </div>
          )}

          {!verified ? (
            <div className="space-y-4">
              <form onSubmit={handleVerifyOtp} className="space-y-4">
                <div>
                  <label className="block text-[11px] font-semibold text-brand-muted uppercase tracking-wider mb-2 text-left">
                    Enter 6-Digit Code (if received)
                  </label>
                  <input
                    type="text"
                    maxLength={6}
                    value={otp}
                    onChange={(e) => setOtp(e.target.value.replace(/\D/g, ""))}
                    placeholder="123456"
                    className="w-full text-center tracking-[0.5em] text-lg font-bold py-3 rounded-tk-btn bg-brand-navySecondary border border-brand-border text-white focus:outline-none focus:border-brand-purple"
                  />
                </div>

                <button
                  type="submit"
                  disabled={loading || otp.length !== 6}
                  className="w-full py-3 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 disabled:opacity-50 text-white font-semibold text-sm shadow-purple-glow flex items-center justify-center gap-2 transition-all"
                >
                  {loading ? <Loader2 className="w-4 h-4 animate-spin" /> : "Verify Code"}
                </button>
              </form>

              <div className="relative py-2">
                <div className="absolute inset-0 flex items-center">
                  <div className="w-full border-t border-brand-border/60" />
                </div>
                <div className="relative flex justify-center text-[10px] uppercase">
                  <span className="bg-brand-navyCard px-2 text-brand-muted">or</span>
                </div>
              </div>

              <button
                type="button"
                onClick={handleManualCheck}
                disabled={loading}
                className="w-full py-2.5 rounded-tk-btn bg-brand-navySecondary hover:bg-brand-navyCard border border-brand-border text-xs text-white font-medium flex items-center justify-center gap-2 transition-colors"
              >
                <RefreshCw className={`w-3.5 h-3.5 ${loading ? "animate-spin" : ""}`} />
                I clicked the email link — Check Status
              </button>

              <button
                type="button"
                onClick={handleResend}
                disabled={isResending}
                className="text-xs text-brand-lavender hover:text-white inline-flex items-center gap-1.5 transition-colors"
              >
                <Send className="w-3 h-3" />
                {isResending ? "Resending..." : "Resend Confirmation Email"}
              </button>
            </div>
          ) : (
            <div className="text-xs text-brand-teal animate-pulse">
              Redirecting to campus discovery portal...
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default function VerifyEmailPage() {
  return (
    <Suspense fallback={<div className="min-h-screen bg-brand-navy flex items-center justify-center text-white text-xs">Loading...</div>}>
      <VerifyEmailContent />
    </Suspense>
  );
}
