"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import {
  Shield,
  Flag,
  Trash2,
  CheckCircle,
  XCircle,
  RefreshCw,
  ArrowLeft,
  AlertTriangle,
  Clock,
  User,
  Coffee,
  Check,
  ExternalLink,
  Lock,
  ShieldAlert,
  KeyRound,
} from "lucide-react";
import {
  fetchTeaReportsFromDb,
  updateReportStatusInDb,
  TeaReport,
} from "@/lib/teaData";
import { useCurrentUser } from "@/lib/useUser";

const AUTHORIZED_ADMIN_EMAILS = [
  "tkmmingle@gmail.com",
  "vaishnavvfisc@gmail.com",
  "vaishnavceh@gmail.com",
  "test@tkmce.ac.in",
];

// Fallback emergency admin passcode for the site owner
const MASTER_ADMIN_PASSCODE = "tkmadmin2026";

export default function TeaAdminReportsPage() {
  const { user, profile, loading: userLoading } = useCurrentUser();
  const [reports, setReports] = useState<TeaReport[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<"all" | "pending" | "resolved" | "dismissed">("pending");
  const [actionLoadingId, setActionLoadingId] = useState<string | null>(null);
  const [actionSuccessMsg, setActionSuccessMsg] = useState<string | null>(null);

  // Passcode unlock state
  const [inputPasscode, setInputPasscode] = useState("");
  const [passcodeUnlocked, setPasscodeUnlocked] = useState(false);
  const [passcodeError, setPasscodeError] = useState(false);

  // Determine if the current user is an authorized admin
  const isEmailAdmin = Boolean(
    user?.email && AUTHORIZED_ADMIN_EMAILS.includes(user.email.toLowerCase())
  );
  const isRoleAdmin = profile?.role === "admin";
  const isAuthorized = passcodeUnlocked || isEmailAdmin || isRoleAdmin;

  const loadReports = async () => {
    if (!isAuthorized) return;
    setLoading(true);
    try {
      const data = await fetchTeaReportsFromDb();
      setReports(data);
    } catch (err) {
      console.error("Failed to load reports:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (isAuthorized) {
      loadReports();
    }
  }, [isAuthorized]);

  const handlePasscodeSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (inputPasscode.trim() === MASTER_ADMIN_PASSCODE) {
      setPasscodeUnlocked(true);
      setPasscodeError(false);
    } else {
      setPasscodeError(true);
    }
  };

  const handleResolveAndDelete = async (report: TeaReport) => {
    if (!isAuthorized) {
      alert("Unauthorized: Administrator permissions required.");
      return;
    }

    const confirmDelete = window.confirm(
      `⚠️ CRITICAL ADMIN ACTION:\n\nAre you sure you want to permanently DELETE this post from TKMingle campus feed and mark this report as resolved?\n\nAuthor: ${report.author_alias || "Anonymous"}\nSnippet: "${report.post_snippet || report.post_id}"`
    );
    if (!confirmDelete) return;

    setActionLoadingId(report.id);
    try {
      await updateReportStatusInDb(report.id, "resolved", report.post_id);
      setReports((prev) =>
        prev.map((r) => (r.id === report.id ? { ...r, status: "resolved" } : r))
      );
      setActionSuccessMsg("Violating post deleted from campus feed & report marked resolved!");
      setTimeout(() => setActionSuccessMsg(null), 3000);
    } catch (err) {
      alert("Failed to delete post or resolve report: " + err);
    } finally {
      setActionLoadingId(null);
    }
  };

  const handleDismiss = async (reportId: string) => {
    if (!isAuthorized) {
      alert("Unauthorized: Administrator permissions required.");
      return;
    }

    setActionLoadingId(reportId);
    try {
      await updateReportStatusInDb(reportId, "dismissed");
      setReports((prev) =>
        prev.map((r) => (r.id === reportId ? { ...r, status: "dismissed" } : r))
      );
      setActionSuccessMsg("Report dismissed as non-violating.");
      setTimeout(() => setActionSuccessMsg(null), 3000);
    } catch (err) {
      alert("Failed to dismiss report: " + err);
    } finally {
      setActionLoadingId(null);
    }
  };

  // 1. Loading User State
  if (userLoading) {
    return (
      <div className="min-h-[70vh] flex flex-col items-center justify-center p-6 space-y-3">
        <RefreshCw className="w-8 h-8 animate-spin text-brand-purple" />
        <p className="text-xs text-brand-muted">Verifying administrator credentials...</p>
      </div>
    );
  }

  // 2. Unauthenticated State
  if (!user) {
    return (
      <div className="min-h-[75vh] flex flex-col items-center justify-center p-6 max-w-md mx-auto text-center space-y-4">
        <div className="w-16 h-16 rounded-2xl bg-red-500/10 border border-red-500/30 flex items-center justify-center text-red-400">
          <Lock className="w-8 h-8" />
        </div>
        <h1 className="text-xl font-bold text-white">Authentication Required</h1>
        <p className="text-xs text-brand-muted">
          You must be logged in as a verified campus administrator to access the moderation console.
        </p>
        <Link
          href="/login"
          className="px-6 py-2.5 rounded-xl bg-brand-purple hover:bg-brand-purple/90 text-white text-xs font-semibold shadow-purple-glow transition-all"
        >
          Sign In to TKMingle
        </Link>
      </div>
    );
  }

  // 3. Unauthorized State (403 Forbidden with Passcode Override)
  if (!isAuthorized) {
    return (
      <div className="min-h-[75vh] flex flex-col items-center justify-center p-6 max-w-lg mx-auto space-y-6">
        <div className="w-full glass-panel border border-red-500/30 rounded-3xl p-8 text-center space-y-5 shadow-2xl">
          <div className="w-16 h-16 rounded-2xl bg-red-500/15 border border-red-500/30 flex items-center justify-center text-red-400 mx-auto shadow-lg">
            <ShieldAlert className="w-8 h-8" />
          </div>

          <div className="space-y-1.5">
            <h1 className="text-xl sm:text-2xl font-black text-white tracking-tight">
              Access Restricted
            </h1>
            <p className="text-xs text-brand-muted max-w-sm mx-auto leading-relaxed">
              This moderation dashboard is strictly restricted to designated TKMCE campus administrators. Your student account does not have moderation authority.
            </p>
          </div>

          <div className="p-3 rounded-xl bg-brand-navySecondary/60 border border-brand-border/60 text-xs text-brand-muted flex items-center justify-center gap-2">
            <span>Signed in as:</span>
            <strong className="text-white font-mono">{user.email}</strong>
            <span className="px-2 py-0.5 rounded-full bg-white/10 text-[10px] uppercase font-bold text-brand-lavender">
              {profile?.role || "student"}
            </span>
          </div>

          {/* Admin Passcode Override */}
          <div className="pt-2 border-t border-brand-border/60 text-left space-y-3">
            <div className="flex items-center gap-1.5 text-xs text-brand-muted">
              <KeyRound className="w-3.5 h-3.5 text-brand-purple" />
              <span>Are you a campus admin on a new device? Enter Admin Key:</span>
            </div>
            <form onSubmit={handlePasscodeSubmit} className="flex gap-2">
              <input
                type="password"
                placeholder="Enter Admin Passcode..."
                value={inputPasscode}
                onChange={(e) => {
                  setInputPasscode(e.target.value);
                  setPasscodeError(false);
                }}
                className="flex-1 px-3 py-2 rounded-xl bg-brand-navyCard border border-brand-border text-xs text-white focus:outline-none focus:border-brand-purple"
              />
              <button
                type="submit"
                className="px-4 py-2 rounded-xl bg-brand-purple hover:bg-brand-purple/90 text-white text-xs font-semibold transition-all"
              >
                Unlock
              </button>
            </form>
            {passcodeError && (
              <p className="text-[11px] text-red-400 font-medium">Invalid administrator passcode.</p>
            )}
          </div>

          <div className="pt-2">
            <Link
              href="/app/tea"
              className="inline-flex items-center gap-1.5 text-xs text-brand-muted hover:text-white transition-colors"
            >
              <ArrowLeft className="w-3.5 h-3.5" />
              <span>Return to Spill the Tea</span>
            </Link>
          </div>
        </div>
      </div>
    );
  }

  // 4. Authorized Admin Moderation View
  const filteredReports = reports.filter((r) => {
    if (filter === "all") return true;
    return r.status === filter;
  });

  const pendingCount = reports.filter((r) => r.status === "pending").length;
  const resolvedCount = reports.filter((r) => r.status === "resolved").length;
  const dismissedCount = reports.filter((r) => r.status === "dismissed").length;

  return (
    <div className="p-4 sm:p-6 lg:p-8 max-w-6xl mx-auto space-y-6">
      {/* 1. Header with Breadcrumb */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-brand-border/60">
        <div>
          <div className="flex items-center gap-2 mb-2">
            <Link
              href="/app/tea"
              className="inline-flex items-center gap-1 text-xs text-brand-muted hover:text-white transition-colors"
            >
              <ArrowLeft className="w-3.5 h-3.5" />
              <span>Back to Spill the Tea</span>
            </Link>
            <span className="text-brand-muted/40">&bull;</span>
            <span className="text-xs font-semibold text-brand-lavender">Admin Moderation Console</span>
            <span className="px-2 py-0.5 rounded-full bg-emerald-500/20 text-emerald-400 border border-emerald-500/40 text-[10px] font-bold uppercase tracking-wider">
              Verified Admin
            </span>
          </div>

          <h1 className="text-2xl sm:text-3xl font-extrabold text-white tracking-tight flex items-center gap-2.5">
            <Shield className="w-7 h-7 text-brand-purple" />
            <span>Spill the Tea Moderation</span>
          </h1>
          <p className="text-xs sm:text-sm text-brand-muted mt-1">
            Review user-flagged confessions, quotes, and rumors reported from Web and APK mobile clients.
          </p>
        </div>

        <div className="flex items-center gap-2 self-start sm:self-auto">
          <button
            onClick={loadReports}
            disabled={loading}
            className="inline-flex items-center gap-1.5 px-4 py-2.5 rounded-xl bg-brand-navyCard hover:bg-brand-navySecondary border border-brand-border text-xs font-semibold text-white transition-colors disabled:opacity-50"
          >
            <RefreshCw className={`w-3.5 h-3.5 ${loading ? "animate-spin" : ""}`} />
            <span>Refresh</span>
          </button>
        </div>
      </div>

      {/* 2. Success Alert */}
      {actionSuccessMsg && (
        <div className="p-3.5 rounded-xl bg-emerald-500/15 border border-emerald-500/30 text-emerald-300 text-xs font-semibold flex items-center gap-2 animate-fade-in">
          <Check className="w-4 h-4 text-emerald-400 flex-shrink-0" />
          <span>{actionSuccessMsg}</span>
        </div>
      )}

      {/* 3. Summary Stats */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <div className="glass-panel p-4 rounded-xl border border-brand-border/70 space-y-1">
          <span className="text-[11px] font-medium text-brand-muted">Total Reports</span>
          <p className="text-2xl font-bold text-white">{reports.length}</p>
        </div>
        <div className="glass-panel p-4 rounded-xl border border-amber-500/30 bg-amber-500/5 space-y-1">
          <span className="text-[11px] font-medium text-amber-400 flex items-center gap-1">
            <AlertTriangle className="w-3 h-3" /> Pending Review
          </span>
          <p className="text-2xl font-bold text-amber-300">{pendingCount}</p>
        </div>
        <div className="glass-panel p-4 rounded-xl border border-emerald-500/30 bg-emerald-500/5 space-y-1">
          <span className="text-[11px] font-medium text-emerald-400 flex items-center gap-1">
            <CheckCircle className="w-3 h-3" /> Posts Actioned
          </span>
          <p className="text-2xl font-bold text-emerald-300">{resolvedCount}</p>
        </div>
        <div className="glass-panel p-4 rounded-xl border border-brand-border/70 space-y-1">
          <span className="text-[11px] font-medium text-brand-muted flex items-center gap-1">
            <XCircle className="w-3 h-3" /> Dismissed
          </span>
          <p className="text-2xl font-bold text-brand-muted">{dismissedCount}</p>
        </div>
      </div>

      {/* 4. Filter Tabs */}
      <div className="flex items-center gap-2 border-b border-brand-border/60 pb-2">
        <button
          onClick={() => setFilter("pending")}
          className={`px-3.5 py-1.5 rounded-lg text-xs font-semibold transition-all flex items-center gap-1.5 ${
            filter === "pending"
              ? "bg-amber-500/20 text-amber-300 border border-amber-500/40"
              : "text-brand-muted hover:text-white hover:bg-brand-navyCard"
          }`}
        >
          <span>⚠️ Pending ({pendingCount})</span>
        </button>
        <button
          onClick={() => setFilter("all")}
          className={`px-3.5 py-1.5 rounded-lg text-xs font-semibold transition-all ${
            filter === "all"
              ? "bg-brand-purple text-white"
              : "text-brand-muted hover:text-white hover:bg-brand-navyCard"
          }`}
        >
          All ({reports.length})
        </button>
        <button
          onClick={() => setFilter("resolved")}
          className={`px-3.5 py-1.5 rounded-lg text-xs font-semibold transition-all flex items-center gap-1.5 ${
            filter === "resolved"
              ? "bg-emerald-500/20 text-emerald-300 border border-emerald-500/40"
              : "text-brand-muted hover:text-white hover:bg-brand-navyCard"
          }`}
        >
          <span>✓ Resolved ({resolvedCount})</span>
        </button>
        <button
          onClick={() => setFilter("dismissed")}
          className={`px-3.5 py-1.5 rounded-lg text-xs font-semibold transition-all ${
            filter === "dismissed"
              ? "bg-brand-navySecondary text-white border border-brand-border"
              : "text-brand-muted hover:text-white hover:bg-brand-navyCard"
          }`}
        >
          Dismissed ({dismissedCount})
        </button>
      </div>

      {/* 5. Reports Feed */}
      {loading ? (
        <div className="p-12 text-center text-xs text-brand-muted flex flex-col items-center justify-center gap-2">
          <RefreshCw className="w-5 h-5 animate-spin text-brand-purple" />
          <span>Loading reported tea scoops...</span>
        </div>
      ) : filteredReports.length === 0 ? (
        <div className="glass-panel p-12 text-center rounded-2xl border border-brand-border/70 space-y-3">
          <div className="w-12 h-12 rounded-full bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center mx-auto text-emerald-400">
            <CheckCircle className="w-6 h-6" />
          </div>
          <h3 className="text-base font-bold text-white">No reports in this category</h3>
          <p className="text-xs text-brand-muted max-w-sm mx-auto">
            {filter === "pending"
              ? "Great news! There are currently no pending reports requiring campus moderation."
              : "No reports found for the selected filter."}
          </p>
        </div>
      ) : (
        <div className="space-y-4">
          {filteredReports.map((report) => {
            const isPending = report.status === "pending";
            const isResolved = report.status === "resolved";
            const isDismissed = report.status === "dismissed";
            const isLoading = actionLoadingId === report.id;

            return (
              <div
                key={report.id}
                className={`glass-panel p-5 rounded-2xl border transition-all ${
                  isPending
                    ? "border-amber-500/30 bg-amber-500/[0.02]"
                    : "border-brand-border/70"
                }`}
              >
                <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-4">
                  {/* Left Column: Report Info */}
                  <div className="space-y-2.5 flex-1">
                    <div className="flex flex-wrap items-center gap-2">
                      {/* Status Badge */}
                      {isPending && (
                        <span className="px-2.5 py-0.5 rounded-full bg-amber-500/20 border border-amber-500/40 text-amber-300 text-[10px] font-bold uppercase tracking-wider">
                          Pending Moderation
                        </span>
                      )}
                      {isResolved && (
                        <span className="px-2.5 py-0.5 rounded-full bg-emerald-500/20 border border-emerald-500/40 text-emerald-300 text-[10px] font-bold uppercase tracking-wider">
                          Resolved &bull; Post Removed
                        </span>
                      )}
                      {isDismissed && (
                        <span className="px-2.5 py-0.5 rounded-full bg-brand-navyCard border border-brand-border text-brand-muted text-[10px] font-semibold uppercase tracking-wider">
                          Dismissed
                        </span>
                      )}

                      {/* Reason Badge */}
                      <span className="px-2.5 py-0.5 rounded-full bg-red-500/15 border border-red-500/30 text-red-300 text-[11px] font-semibold flex items-center gap-1">
                        <Flag className="w-3 h-3 text-red-400" />
                        <span>{report.reason}</span>
                      </span>

                      <span className="text-[11px] text-brand-muted">
                        Reported by <strong className="text-brand-text">{report.reporter_name || "TKM Student"}</strong>
                      </span>
                    </div>

                    {/* Reported Post Snippet */}
                    <div className="p-3.5 rounded-xl bg-brand-navySecondary/60 border border-brand-border/60 space-y-1.5">
                      <div className="flex items-center justify-between text-[11px]">
                        <span className="text-brand-lavender font-semibold flex items-center gap-1">
                          <Coffee className="w-3 h-3" />
                          <span>Author: {report.author_alias || "Anonymous Student"}</span>
                        </span>
                        <span className="font-mono text-brand-muted text-[10px]">
                          ID: {report.post_id}
                        </span>
                      </div>
                      <p className="text-xs text-brand-text whitespace-pre-line leading-relaxed">
                        {report.post_snippet || "(No text preview recorded)"}
                      </p>
                    </div>

                    {/* Reporter's Optional Details */}
                    {report.details && (
                      <div className="text-xs text-brand-muted bg-brand-navyCard/40 p-2.5 rounded-lg border border-brand-border/40">
                        <strong className="text-brand-text font-semibold">Reporter&apos;s Note: </strong>
                        <span>&ldquo;{report.details}&rdquo;</span>
                      </div>
                    )}
                  </div>

                  {/* Right Column: Moderation Actions */}
                  <div className="flex sm:flex-col items-center sm:items-end gap-2 flex-shrink-0 pt-2 sm:pt-0">
                    {isPending ? (
                      <>
                        <button
                          onClick={() => handleResolveAndDelete(report)}
                          disabled={isLoading}
                          className="inline-flex items-center justify-center gap-1.5 px-3.5 py-2 rounded-xl bg-red-600 hover:bg-red-500 text-white text-xs font-semibold transition-all shadow-sm disabled:opacity-50"
                          title="Delete violating post from tea feed and mark report resolved"
                        >
                          <Trash2 className="w-3.5 h-3.5" />
                          <span>Delete Post</span>
                        </button>
                        <button
                          onClick={() => handleDismiss(report.id)}
                          disabled={isLoading}
                          className="inline-flex items-center justify-center gap-1.5 px-3.5 py-2 rounded-xl bg-brand-navyCard hover:bg-brand-navySecondary border border-brand-border text-brand-muted hover:text-white text-xs font-semibold transition-colors disabled:opacity-50"
                          title="Dismiss report as non-violating"
                        >
                          <XCircle className="w-3.5 h-3.5" />
                          <span>Dismiss</span>
                        </button>
                      </>
                    ) : (
                      <span className="text-[11px] text-brand-muted italic">
                        No further action needed
                      </span>
                    )}
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
