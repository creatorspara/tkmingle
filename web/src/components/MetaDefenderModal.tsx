"use client";

import React, { useState, useEffect } from "react";
import Image from "next/image";
import {
  ShieldCheck,
  X,
  FileCheck,
  Download,
  ExternalLink,
  Copy,
  Check,
  Search,
  CheckCircle2,
  AlertCircle,
  FileText,
  Clock,
  HardDrive,
  Hash,
  Terminal,
} from "lucide-react";
import { METADEFENDER_REPORT } from "@/lib/securityData";

interface MetaDefenderModalProps {
  isOpen: boolean;
  onClose: () => void;
  downloadUrl?: string;
  versionName?: string;
}

export default function MetaDefenderModal({
  isOpen,
  onClose,
  downloadUrl = "https://github.com/creatorspara/tkmingle/releases/download/v2.0.0/tkmingle-v2-release.apk",
  versionName = "v2.0.0",
}: MetaDefenderModalProps) {
  const [activeTab, setActiveTab] = useState<"engines" | "hashes" | "preview">("engines");
  const [searchQuery, setSearchQuery] = useState("");
  const [copiedKey, setCopiedKey] = useState<string | null>(null);

  // Close on ESC
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    if (isOpen) {
      window.addEventListener("keydown", handleKeyDown);
      document.body.style.overflow = "hidden";
    }
    return () => {
      window.removeEventListener("keydown", handleKeyDown);
      document.body.style.overflow = "";
    };
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  const copyToClipboard = (text: string, key: string) => {
    navigator.clipboard.writeText(text);
    setCopiedKey(key);
    setTimeout(() => setCopiedKey(null), 2000);
  };

  const filteredEngines = METADEFENDER_REPORT.engines.filter((item) =>
    item.engine.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-md flex items-center justify-center p-3 sm:p-5 animate-in fade-in duration-150">
      <div
        className="bg-brand-navySecondary border border-brand-border/90 rounded-2xl max-w-3xl w-full max-h-[90vh] flex flex-col shadow-2xl relative overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Modal Top Header */}
        <div className="px-5 py-4 border-b border-brand-border/70 flex items-center justify-between bg-brand-navy/60">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-brand-teal/15 border border-brand-teal/30 flex items-center justify-center text-brand-teal">
              <ShieldCheck className="w-5 h-5" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h3 className="text-base font-bold text-white tracking-tight">
                  OPSWAT MetaDefender Analysis
                </h3>
                <span className="px-2 py-0.5 rounded-full bg-brand-teal/20 text-brand-teal text-[11px] font-semibold border border-brand-teal/30">
                  0/21 Clean
                </span>
              </div>
              <p className="text-xs text-brand-muted">
                Official Multi-Engine Threat Verification &bull; {METADEFENDER_REPORT.fileName}
              </p>
            </div>
          </div>

          <button
            onClick={onClose}
            className="p-1.5 text-brand-muted hover:text-white rounded-lg hover:bg-brand-navyCard transition-colors"
            aria-label="Close modal"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Status Callout Bar */}
        <div className="px-5 py-3 bg-brand-teal/10 border-b border-brand-teal/20 flex flex-wrap items-center justify-between gap-3 text-xs">
          <div className="flex items-center gap-2 text-brand-teal font-medium">
            <CheckCircle2 className="w-4 h-4 text-brand-teal flex-shrink-0" />
            <span>No threats, malware, spyware, or adware detected across 21 enterprise security engines.</span>
          </div>
          <div className="flex items-center gap-3 text-brand-muted text-[11px]">
            <span>Data ID: <code className="text-brand-lavender font-mono">{METADEFENDER_REPORT.dataId.slice(0, 16)}...</code></span>
            <span>Scan Time: <span className="text-white font-mono">{METADEFENDER_REPORT.scanDuration}</span></span>
          </div>
        </div>

        {/* Tab Switcher */}
        <div className="px-5 pt-3 pb-1 border-b border-brand-border/50 flex gap-2">
          <button
            onClick={() => setActiveTab("engines")}
            className={`px-3.5 py-1.5 text-xs font-semibold rounded-lg transition-all ${
              activeTab === "engines"
                ? "bg-brand-purple text-white shadow-sm"
                : "text-brand-muted hover:text-white hover:bg-brand-navyCard"
            }`}
          >
            21 Engines ({METADEFENDER_REPORT.cleanEngines} Clean)
          </button>
          <button
            onClick={() => setActiveTab("hashes")}
            className={`px-3.5 py-1.5 text-xs font-semibold rounded-lg transition-all ${
              activeTab === "hashes"
                ? "bg-brand-purple text-white shadow-sm"
                : "text-brand-muted hover:text-white hover:bg-brand-navyCard"
            }`}
          >
            Checksums &amp; Hashes
          </button>
          <button
            onClick={() => setActiveTab("preview")}
            className={`px-3.5 py-1.5 text-xs font-semibold rounded-lg transition-all ${
              activeTab === "preview"
                ? "bg-brand-purple text-white shadow-sm"
                : "text-brand-muted hover:text-white hover:bg-brand-navyCard"
            }`}
          >
            Official PDF Preview
          </button>
        </div>

        {/* Scrollable Body */}
        <div className="p-5 overflow-y-auto space-y-4 flex-1">
          {activeTab === "engines" && (
            <div className="space-y-4">
              {/* Search & Engine Summary */}
              <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3">
                <div className="relative flex-1">
                  <Search className="w-4 h-4 text-brand-muted absolute left-3 top-2.5" />
                  <input
                    type="text"
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    placeholder="Filter engines (Bitdefender, Sophos, ESET, Trellix...)"
                    className="w-full bg-brand-navyCard border border-brand-border rounded-lg pl-9 pr-3 py-2 text-xs text-white placeholder-brand-muted focus:outline-none focus:border-brand-purple"
                  />
                </div>
                <div className="text-xs text-brand-muted flex items-center gap-2">
                  <span className="w-2.5 h-2.5 rounded-full bg-brand-teal" />
                  <span>19 Engines Clean</span>
                  <span className="w-2.5 h-2.5 rounded-full bg-brand-border ml-2" />
                  <span>2 Non-analyzing format</span>
                </div>
              </div>

              {/* Engine Grid */}
              <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-2.5">
                {filteredEngines.map((item) => (
                  <div
                    key={item.engine}
                    className="p-3 rounded-xl bg-brand-navyCard border border-brand-border/70 flex items-center justify-between gap-2 hover:border-brand-border transition-colors"
                  >
                    <div className="min-w-0">
                      <span className="text-xs font-semibold text-white block truncate">
                        {item.engine}
                      </span>
                      <span className="text-[10px] text-brand-muted">
                        Def: {item.definitionDate}
                      </span>
                    </div>

                    {item.verdict === "Not Detected" ? (
                      <span className="inline-flex items-center gap-1 text-[11px] font-semibold text-brand-teal bg-brand-teal/10 px-2 py-0.5 rounded-md border border-brand-teal/20 flex-shrink-0">
                        <Check className="w-3 h-3" />
                        Clean
                      </span>
                    ) : (
                      <span className="inline-flex items-center gap-1 text-[11px] font-medium text-brand-muted bg-brand-navySecondary px-2 py-0.5 rounded-md border border-brand-border flex-shrink-0">
                        N/A
                      </span>
                    )}
                  </div>
                ))}
              </div>

              {filteredEngines.length === 0 && (
                <div className="text-center py-8 text-xs text-brand-muted">
                  No security engines match &ldquo;{searchQuery}&rdquo;.
                </div>
              )}
            </div>
          )}

          {activeTab === "hashes" && (
            <div className="space-y-4">
              <p className="text-xs text-brand-muted leading-relaxed">
                Cryptographic checksums uniquely identify the exact build artifact verified by MetaDefender.
                You can compute the hash of your downloaded APK to verify it has not been modified or tampered with.
              </p>

              {/* Hashes List */}
              <div className="space-y-3">
                {/* SHA-256 */}
                <div className="p-3.5 rounded-xl bg-brand-navyCard border border-brand-border space-y-1.5">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold text-white flex items-center gap-1.5">
                      <Hash className="w-3.5 h-3.5 text-brand-teal" />
                      SHA-256 (Primary Checksum)
                    </span>
                    <button
                      onClick={() => copyToClipboard(METADEFENDER_REPORT.sha256, "sha256")}
                      className="inline-flex items-center gap-1 text-xs text-brand-teal hover:underline font-medium"
                    >
                      {copiedKey === "sha256" ? <Check className="w-3 h-3" /> : <Copy className="w-3 h-3" />}
                      <span>{copiedKey === "sha256" ? "Copied" : "Copy"}</span>
                    </button>
                  </div>
                  <div className="p-2.5 rounded-lg bg-black/40 border border-brand-border/60 text-xs font-mono text-brand-lavender break-all select-all">
                    {METADEFENDER_REPORT.sha256}
                  </div>
                </div>

                {/* SHA-1 */}
                <div className="p-3 rounded-xl bg-brand-navyCard border border-brand-border space-y-1.5">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold text-white flex items-center gap-1.5">
                      <Hash className="w-3.5 h-3.5 text-brand-muted" />
                      SHA-1 Checksum
                    </span>
                    <button
                      onClick={() => copyToClipboard(METADEFENDER_REPORT.sha1, "sha1")}
                      className="inline-flex items-center gap-1 text-xs text-brand-teal hover:underline font-medium"
                    >
                      {copiedKey === "sha1" ? <Check className="w-3 h-3" /> : <Copy className="w-3 h-3" />}
                      <span>{copiedKey === "sha1" ? "Copied" : "Copy"}</span>
                    </button>
                  </div>
                  <div className="p-2.5 rounded-lg bg-black/40 border border-brand-border/60 text-xs font-mono text-brand-muted break-all select-all">
                    {METADEFENDER_REPORT.sha1}
                  </div>
                </div>

                {/* MD5 */}
                <div className="p-3 rounded-xl bg-brand-navyCard border border-brand-border space-y-1.5">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold text-white flex items-center gap-1.5">
                      <Hash className="w-3.5 h-3.5 text-brand-muted" />
                      MD5 Checksum
                    </span>
                    <button
                      onClick={() => copyToClipboard(METADEFENDER_REPORT.md5, "md5")}
                      className="inline-flex items-center gap-1 text-xs text-brand-teal hover:underline font-medium"
                    >
                      {copiedKey === "md5" ? <Check className="w-3 h-3" /> : <Copy className="w-3 h-3" />}
                      <span>{copiedKey === "md5" ? "Copied" : "Copy"}</span>
                    </button>
                  </div>
                  <div className="p-2.5 rounded-lg bg-black/40 border border-brand-border/60 text-xs font-mono text-brand-muted break-all select-all">
                    {METADEFENDER_REPORT.md5}
                  </div>
                </div>
              </div>

              {/* Verification snippet */}
              <div className="p-3.5 rounded-xl bg-brand-navyCard/60 border border-brand-border/80 space-y-2">
                <span className="text-xs font-semibold text-white flex items-center gap-1.5">
                  <Terminal className="w-3.5 h-3.5 text-brand-purple" />
                  How to verify on your computer:
                </span>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-2 text-[11px] font-mono text-brand-muted">
                  <div className="p-2 rounded bg-black/40 border border-brand-border/50">
                    <span className="text-brand-lavender font-semibold block mb-0.5">Windows PowerShell:</span>
                    <code>Get-FileHash tkmmingle-k1-release.apk</code>
                  </div>
                  <div className="p-2 rounded bg-black/40 border border-brand-border/50">
                    <span className="text-brand-lavender font-semibold block mb-0.5">macOS / Linux:</span>
                    <code>shasum -a 256 tkmmingle-k1-release.apk</code>
                  </div>
                </div>
              </div>
            </div>
          )}

          {activeTab === "preview" && (
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <span className="text-xs font-semibold text-white">
                  Official Scan Certificate (2 Pages)
                </span>
                <a
                  href={METADEFENDER_REPORT.pdfUrl}
                  target="_blank"
                  rel="noreferrer"
                  className="text-xs font-medium text-brand-teal hover:underline flex items-center gap-1"
                >
                  <ExternalLink className="w-3.5 h-3.5" />
                  Open PDF in New Window
                </a>
              </div>

              {/* Side-by-side or stacked preview pages */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <div className="flex items-center justify-between text-[11px] text-brand-muted">
                    <span>Page 1: Multi-Engine Summary</span>
                    <span>MetaDefender</span>
                  </div>
                  <div className="rounded-xl overflow-hidden border border-brand-border shadow-md bg-white">
                    <Image
                      src={METADEFENDER_REPORT.previewImages.page1}
                      alt="MetaDefender Analysis Page 1"
                      width={600}
                      height={850}
                      className="w-full h-auto object-contain"
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <div className="flex items-center justify-between text-[11px] text-brand-muted">
                    <span>Page 2: Engine Verdicts &amp; Signature</span>
                    <span>MetaDefender</span>
                  </div>
                  <div className="rounded-xl overflow-hidden border border-brand-border shadow-md bg-white">
                    <Image
                      src={METADEFENDER_REPORT.previewImages.page2}
                      alt="MetaDefender Analysis Page 2"
                      width={600}
                      height={850}
                      className="w-full h-auto object-contain"
                    />
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Modal Bottom Action Footer */}
        <div className="px-5 py-4 border-t border-brand-border/70 bg-brand-navy/80 flex flex-col sm:flex-row items-center justify-between gap-3">
          <div className="flex items-center gap-2 text-xs text-brand-muted">
            <ShieldCheck className="w-4 h-4 text-brand-teal" />
            <span>OPSWAT MetaDefender Cloud &bull; Scanned Nov 22, 2026</span>
          </div>

          <div className="flex items-center gap-2.5 w-full sm:w-auto justify-end">
            <a
              href={METADEFENDER_REPORT.pdfUrl}
              download="tkmmingle-k1-release.apk.pdf"
              className="px-4 py-2 text-xs font-semibold rounded-tk-btn bg-brand-navyCard hover:bg-brand-navySecondary border border-brand-border text-white flex items-center gap-2 transition-colors"
            >
              <Download className="w-3.5 h-3.5 text-brand-teal" />
              <span>Download PDF ({METADEFENDER_REPORT.fileSize})</span>
            </a>

            <a
              href={downloadUrl}
              download
              className="px-4 py-2 text-xs font-semibold rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white flex items-center gap-2 transition-colors shadow-purple-glow"
            >
              <Download className="w-3.5 h-3.5" />
              <span>Download APK ({versionName})</span>
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}
