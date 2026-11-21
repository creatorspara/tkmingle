"use client";

import React, { useState, Suspense } from "react";
import Image from "next/image";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { ArrowLeft, CheckCircle2, Loader2, MailCheck } from "lucide-react";

function VerifyEmailContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const email = searchParams.get("email") || "student@tkmce.ac.in";
  const [otp, setOtp] = useState("");
  const [loading, setLoading] = useState(false);
  const [verified, setVerified] = useState(false);

  const handleVerify = (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setTimeout(() => {
      setLoading(false);
      setVerified(true);
      setTimeout(() => {
        router.push("/app/discover");
      }, 1000);
    }, 700);
  };

  return (
    <div className="min-h-screen bg-brand-navy text-brand-text flex flex-col justify-center py-12 sm:px-6 lg:px-8 relative overflow-hidden">
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
            ) : (
              <MailCheck className="w-8 h-8 text-brand-lavender" />
            )}
          </div>

          <div className="space-y-2">
            <h2 className="text-xl font-bold text-white">
              {verified ? "Verification Successful!" : "Verify Student Email"}
            </h2>
            <p className="text-xs text-brand-muted leading-relaxed">
              We sent a 6-digit campus verification code to <span className="text-brand-lavender font-semibold">{email}</span>.
            </p>
          </div>

          {!verified ? (
            <form onSubmit={handleVerify} className="space-y-4">
              <div>
                <input
                  type="text"
                  required
                  maxLength={6}
                  value={otp}
                  onChange={(e) => setOtp(e.target.value)}
                  placeholder="e.g. 524189"
                  className="w-full text-center tracking-[0.5em] text-lg font-bold py-3 rounded-tk-btn bg-brand-navySecondary border border-brand-border text-white focus:outline-none focus:border-brand-purple"
                />
              </div>

              <button
                type="submit"
                disabled={loading}
                className="w-full py-3 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white font-semibold text-sm shadow-purple-glow flex items-center justify-center gap-2"
              >
                {loading ? <Loader2 className="w-4 h-4 animate-spin" /> : "Verify & Continue"}
              </button>

              <button
                type="button"
                onClick={() => setOtp("524189")}
                className="text-xs text-brand-teal hover:underline block mx-auto"
              >
                Auto-fill demo code (524189)
              </button>
            </form>
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
