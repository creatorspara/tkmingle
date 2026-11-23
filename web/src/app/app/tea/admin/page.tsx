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
} from "lucide-react";
import {
  fetchTeaReportsFromDb,
  updateReportStatusInDb,
  TeaReport,
} from "@/lib/teaData";

export default function TeaAdminReportsPage() {
  const [reports, setReports] = useState<TeaReport[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<"all" | "pending" | "resolved" | "dismissed">("pending");
  const [actionLoadingId, setActionLoadingId] = useState<string | null>(null);
  const [actionSuccessMsg, setActionSuccessMsg] = useState<string | null>(null);

  const loadReports = async () => {
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
    loadReports();
  }, []);

  const handleResolveAndDelete = async (report: TeaReport) => {
    const confirmDelete = window.confirm(
      `Are you sure you want to DELETE this post from TKMingle and mark the report as resolved?\n\nPost: "${report.post_snippet || report.post_id}"`
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
            <span className="text-xs font-semibold text-brand-lavender">Moderation Dashboard</span>
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
                          className="inline-flex items-center justify-center gap-1.5 px-3 py-2 rounded-xl bg-brand-navyCard hover:bg-brand-navySecondary border border-brand-border text-brand-muted hover:text-white text-xs font-semibold transition-colors disabled:opacity-50"
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
