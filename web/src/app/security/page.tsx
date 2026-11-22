"use client";

import React, { useState } from "react";
import Image from "next/image";
import Link from "next/link";
import {
  ShieldCheck,
  CheckCircle2,
  Download,
  ExternalLink,
  Copy,
  Check,
  Search,
  ArrowLeft,
  FileText,
  Hash,
  Terminal,
  Lock,
  Smartphone,
  Cpu,
  Layers,
  Sparkles,
  Info,
} from "lucide-react";
import { METADEFENDER_REPORT } from "@/lib/securityData";

export default function SecurityPage() {
  const [searchQuery, setSearchQuery] = useState("");
  const [copiedKey, setCopiedKey] = useState<string | null>(null);
  const [viewMode, setViewMode] = useState<"interactive" | "pdf">("interactive");

  const copyToClipboard = (text: string, key: string) => {
    navigator.clipboard.writeText(text);
    setCopiedKey(key);
    setTimeout(() => setCopiedKey(null), 2000);
  };

  const filteredEngines = METADEFENDER_REPORT.engines.filter((item) =>
    item.engine.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="min-h-screen bg-brand-navy text-brand-text flex flex-col selection:bg-brand-purple selection:text-white">
      {/* 1. NAVBAR */}
      <header className="sticky top-0 z-50 bg-brand-navy/90 backdrop-blur-md border-b border-brand-border/60">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-18 flex items-center justify-between">
          <Link href="/" className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-brand-navyCard border border-brand-border flex items-center justify-center p-1.5 shadow-sm">
              <Image
                src="/images/logo_compact.svg"
                alt="TKMingle"
                width={32}
                height={32}
                className="w-auto h-auto"
                priority
              />
            </div>
            <div className="flex flex-col">
              <span className="text-xl font-bold tracking-tight text-white flex items-center">
                TKM<span className="text-brand-purple">ingle</span>
              </span>
              <span className="text-[10px] text-brand-muted tracking-wider uppercase font-medium">
                Security &amp; Threat Verification
              </span>
            </div>
          </Link>

          <div className="flex items-center gap-3">
            <Link
              href="/"
              className="text-xs font-semibold text-brand-muted hover:text-white flex items-center gap-1.5 transition-colors"
            >
              <ArrowLeft className="w-4 h-4" />
              <span>Back to Home</span>
            </Link>

            <a
              href="https://github.com/creatorspara/tkmingle/releases/download/v1.0.7-k1/tkmmingle-k1-release.apk"
              download
              className="px-4 py-2 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white font-semibold text-xs flex items-center gap-2 transition-colors shadow-purple-glow"
            >
              <Download className="w-3.5 h-3.5" />
              <span>Download APK</span>
            </a>
          </div>
        </div>
      </header>

      {/* 2. HERO / BADGE SECTION */}
      <section className="relative pt-12 pb-14 border-b border-brand-border/60 bg-gradient-to-b from-[#0e142e] to-brand-navy">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-6">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-brand-teal/15 border border-brand-teal/30 text-xs font-semibold text-brand-teal">
            <ShieldCheck className="w-4 h-4 text-brand-teal" />
            <span>OPSWAT MetaDefender Verified Clean &bull; 0/21 Threats Detected</span>
          </div>

          <div className="max-w-3xl space-y-3">
            <h1 className="text-3xl sm:text-5xl font-extrabold tracking-tight text-white">
              Security &amp; Virus Analysis Report
            </h1>
            <p className="text-sm sm:text-base text-brand-muted leading-relaxed">
              Every TKMingle Android APK release is audited and scanned for malware, trojans, spyware, and unwanted software using OPSWAT MetaDefender multi-engine threat detection before public distribution.
            </p>
          </div>

          {/* Quick Metrics Bar */}
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 sm:gap-4 pt-2">
            <div className="p-4 rounded-xl bg-brand-navyCard/80 border border-brand-border">
              <span className="text-[11px] font-semibold uppercase tracking-wider text-brand-muted block">
                Analysis Verdict
              </span>
              <span className="text-lg font-bold text-brand-teal flex items-center gap-1.5 mt-0.5">
                <CheckCircle2 className="w-5 h-5 text-brand-teal" />
                0 / 21 Clean
              </span>
            </div>

            <div className="p-4 rounded-xl bg-brand-navyCard/80 border border-brand-border">
              <span className="text-[11px] font-semibold uppercase tracking-wider text-brand-muted block">
                Analyzed Artifact
              </span>
              <span className="text-xs font-bold text-white block mt-1 truncate" title={METADEFENDER_REPORT.fileName}>
                {METADEFENDER_REPORT.fileName}
              </span>
              <span className="text-[10px] text-brand-muted">v1.0.7-k1 &bull; {METADEFENDER_REPORT.fileSize}</span>
            </div>

            <div className="p-4 rounded-xl bg-brand-navyCard/80 border border-brand-border">
              <span className="text-[11px] font-semibold uppercase tracking-wider text-brand-muted block">
                Engines Tested
              </span>
              <span className="text-lg font-bold text-brand-lavender block mt-0.5">
                21 Enterprise Engines
              </span>
            </div>

            <div className="p-4 rounded-xl bg-brand-navyCard/80 border border-brand-border">
              <span className="text-[11px] font-semibold uppercase tracking-wider text-brand-muted block">
                Report Generated
              </span>
              <span className="text-xs font-bold text-white block mt-1">
                {METADEFENDER_REPORT.generatedDate}
              </span>
              <span className="text-[10px] text-brand-teal">Duration: {METADEFENDER_REPORT.scanDuration}</span>
            </div>
          </div>

          {/* Action Row */}
          <div className="pt-2 flex flex-wrap items-center gap-3">
            <a
              href="/tkmmingle-k1-release.apk.pdf"
              download="tkmmingle-k1-release.apk.pdf"
              className="px-5 py-3 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white font-semibold text-xs flex items-center gap-2 transition-colors shadow-purple-glow"
            >
              <Download className="w-4 h-4" />
              <span>Download Official MetaDefender Report (PDF)</span>
            </a>

            <a
              href="/tkmmingle-k1-release.apk.pdf"
              target="_blank"
              rel="noreferrer"
              className="px-5 py-3 rounded-tk-btn bg-brand-navyCard hover:bg-brand-navySecondary border border-brand-border text-white font-semibold text-xs flex items-center gap-2 transition-colors"
            >
              <ExternalLink className="w-4 h-4 text-brand-teal" />
              <span>Open PDF in New Tab</span>
            </a>

            <button
              onClick={() => setViewMode(viewMode === "interactive" ? "pdf" : "interactive")}
              className="px-4 py-3 rounded-tk-btn border border-brand-border/80 text-brand-muted hover:text-white font-medium text-xs flex items-center gap-1.5 transition-colors"
            >
              <FileText className="w-4 h-4 text-brand-lavender" />
              <span>Toggle {viewMode === "interactive" ? "Embedded PDF Viewer" : "Interactive Table"}</span>
            </button>
          </div>
        </div>
      </section>

      {/* 3. MAIN CONTENT: REPORT DETAILS & ENGINES */}
      <section className="py-12 border-b border-brand-border/60">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-10">
          {viewMode === "pdf" ? (
            /* Embedded PDF Mode */
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <div>
                  <h2 className="text-xl font-bold text-white">Official PDF Scan Report</h2>
                  <p className="text-xs text-brand-muted">
                    Raw certificate issued by OPSWAT MetaDefender Cloud on November 22, 2026.
                  </p>
                </div>
                <button
                  onClick={() => setViewMode("interactive")}
                  className="text-xs text-brand-teal hover:underline font-semibold"
                >
                  &larr; Switch to interactive table
                </button>
              </div>

              <div className="w-full h-[800px] rounded-2xl overflow-hidden border border-brand-border bg-black/60 shadow-2xl">
                <iframe
                  src="/tkmmingle-k1-release.apk.pdf#toolbar=1"
                  className="w-full h-full"
                  title="MetaDefender Virus Analysis PDF"
                />
              </div>
            </div>
          ) : (
            /* Interactive Breakdown Mode */
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
              {/* Left Column: 21 Engine Results */}
              <div className="lg:col-span-8 space-y-5">
                <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3">
                  <div>
                    <h2 className="text-xl font-bold text-white flex items-center gap-2">
                      <ShieldCheck className="w-5 h-5 text-brand-teal" />
                      Multiscan Engine Verdicts (21 Engines)
                    </h2>
                    <p className="text-xs text-brand-muted mt-0.5">
                      Commercial antivirus and anti-malware signatures verified clean.
                    </p>
                  </div>

                  <div className="relative w-full sm:w-64">
                    <Search className="w-4 h-4 text-brand-muted absolute left-3 top-2.5" />
                    <input
                      type="text"
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      placeholder="Filter engines..."
                      className="w-full bg-brand-navyCard border border-brand-border rounded-lg pl-9 pr-3 py-2 text-xs text-white placeholder-brand-muted focus:outline-none focus:border-brand-purple"
                    />
                  </div>
                </div>

                {/* Table of Engines */}
                <div className="rounded-2xl border border-brand-border/80 overflow-hidden bg-brand-navyCard/40">
                  <div className="grid grid-cols-12 px-4 py-3 bg-brand-navySecondary text-xs font-semibold text-brand-muted border-b border-brand-border uppercase tracking-wider">
                    <span className="col-span-6 sm:col-span-5">Security Engine</span>
                    <span className="col-span-3 sm:col-span-4">Verdict</span>
                    <span className="col-span-3 sm:col-span-3 text-right">Definition Date</span>
                  </div>

                  <div className="divide-y divide-brand-border/50">
                    {filteredEngines.map((item) => (
                      <div
                        key={item.engine}
                        className="grid grid-cols-12 px-4 py-3.5 items-center text-xs hover:bg-brand-navyCard transition-colors"
                      >
                        <div className="col-span-6 sm:col-span-5 font-semibold text-white flex items-center gap-2">
                          <span className="w-2 h-2 rounded-full bg-brand-teal" />
                          <span>{item.engine}</span>
                        </div>

                        <div className="col-span-3 sm:col-span-4">
                          {item.verdict === "Not Detected" ? (
                            <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-brand-teal/15 text-brand-teal text-[11px] font-semibold border border-brand-teal/30">
                              <Check className="w-3 h-3 text-brand-teal" />
                              Not Detected (Clean)
                            </span>
                          ) : (
                            <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-brand-navySecondary text-brand-muted text-[11px] font-medium border border-brand-border">
                              Not Supported
                            </span>
                          )}
                        </div>

                        <div className="col-span-3 sm:col-span-3 text-right font-mono text-[11px] text-brand-muted">
                          {item.definitionDate}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Scanned Certificate Preview Cards */}
                <div className="space-y-3 pt-4">
                  <h3 className="text-sm font-bold text-white flex items-center gap-2">
                    <FileText className="w-4 h-4 text-brand-purple" />
                    Scan Report Certificate Previews
                  </h3>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <div className="flex items-center justify-between text-xs text-brand-muted">
                        <span className="font-medium text-white">Page 1: Multi-Engine Breakdown</span>
                        <a href="/tkmmingle-k1-release.apk.pdf" target="_blank" className="text-brand-teal hover:underline text-[11px]">View full &rarr;</a>
                      </div>
                      <div className="rounded-xl overflow-hidden border border-brand-border bg-white shadow-md">
                        <Image
                          src={METADEFENDER_REPORT.previewImages.page1}
                          alt="MetaDefender Certificate Page 1"
                          width={600}
                          height={850}
                          className="w-full h-auto object-contain"
                        />
                      </div>
                    </div>

                    <div className="space-y-2">
                      <div className="flex items-center justify-between text-xs text-brand-muted">
                        <span className="font-medium text-white">Page 2: AI &amp; Threat Engines</span>
                        <a href="/tkmmingle-k1-release.apk.pdf" target="_blank" className="text-brand-teal hover:underline text-[11px]">View full &rarr;</a>
                      </div>
                      <div className="rounded-xl overflow-hidden border border-brand-border bg-white shadow-md">
                        <Image
                          src={METADEFENDER_REPORT.previewImages.page2}
                          alt="MetaDefender Certificate Page 2"
                          width={600}
                          height={850}
                          className="w-full h-auto object-contain"
                        />
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Right Column: Checksums, Verification, & Details */}
              <div className="lg:col-span-4 space-y-6">
                {/* File Details Box */}
                <div className="glass-panel rounded-2xl border border-brand-border/90 p-5 space-y-4 shadow-xl">
                  <h3 className="text-sm font-bold text-white flex items-center gap-2 border-b border-brand-border/60 pb-3">
                    <Lock className="w-4 h-4 text-brand-teal" />
                    Artifact Metadata
                  </h3>

                  <div className="space-y-3 text-xs">
                    <div>
                      <span className="text-brand-muted block text-[11px]">Artifact File Name</span>
                      <span className="font-semibold text-white font-mono">{METADEFENDER_REPORT.fileName}</span>
                    </div>

                    <div className="grid grid-cols-2 gap-2">
                      <div>
                        <span className="text-brand-muted block text-[11px]">File Size</span>
                        <span className="font-semibold text-white font-mono">{METADEFENDER_REPORT.fileSize}</span>
                      </div>
                      <div>
                        <span className="text-brand-muted block text-[11px]">File Format</span>
                        <span className="font-semibold text-white">Android APK</span>
                      </div>
                    </div>

                    <div>
                      <span className="text-brand-muted block text-[11px]">MetaDefender Data ID</span>
                      <code className="text-[11px] text-brand-lavender font-mono break-all bg-black/40 p-1.5 rounded block mt-0.5">
                        {METADEFENDER_REPORT.dataId}
                      </code>
                    </div>

                    <div>
                      <span className="text-brand-muted block text-[11px]">Upload Timestamp</span>
                      <span className="font-medium text-white text-[11px]">{METADEFENDER_REPORT.uploadTimestamp}</span>
                    </div>
                  </div>
                </div>

                {/* Hashes Box */}
                <div className="glass-panel rounded-2xl border border-brand-border/90 p-5 space-y-4 shadow-xl">
                  <h3 className="text-sm font-bold text-white flex items-center gap-2 border-b border-brand-border/60 pb-3">
                    <Hash className="w-4 h-4 text-brand-purple" />
                    Cryptographic Signatures
                  </h3>

                  {/* SHA-256 */}
                  <div className="space-y-1.5">
                    <div className="flex items-center justify-between">
                      <span className="text-xs font-semibold text-white">SHA-256 Checksum</span>
                      <button
                        onClick={() => copyToClipboard(METADEFENDER_REPORT.sha256, "sha256")}
                        className="inline-flex items-center gap-1 text-[11px] text-brand-teal hover:underline font-medium"
                      >
                        {copiedKey === "sha256" ? <Check className="w-3 h-3" /> : <Copy className="w-3 h-3" />}
                        <span>{copiedKey === "sha256" ? "Copied" : "Copy"}</span>
                      </button>
                    </div>
                    <div className="p-2.5 rounded-lg bg-black/40 border border-brand-border/60 text-[11px] font-mono text-brand-lavender break-all select-all">
                      {METADEFENDER_REPORT.sha256}
                    </div>
                  </div>

                  {/* SHA-1 */}
                  <div className="space-y-1.5">
                    <div className="flex items-center justify-between">
                      <span className="text-xs font-semibold text-brand-muted">SHA-1</span>
                      <button
                        onClick={() => copyToClipboard(METADEFENDER_REPORT.sha1, "sha1")}
                        className="inline-flex items-center gap-1 text-[11px] text-brand-teal hover:underline font-medium"
                      >
                        {copiedKey === "sha1" ? <Check className="w-3 h-3" /> : <Copy className="w-3 h-3" />}
                        <span>{copiedKey === "sha1" ? "Copied" : "Copy"}</span>
                      </button>
                    </div>
                    <div className="p-2 rounded-lg bg-black/40 border border-brand-border/60 text-[11px] font-mono text-brand-muted break-all select-all">
                      {METADEFENDER_REPORT.sha1}
                    </div>
                  </div>

                  {/* MD5 */}
                  <div className="space-y-1.5">
                    <div className="flex items-center justify-between">
                      <span className="text-xs font-semibold text-brand-muted">MD5</span>
                      <button
                        onClick={() => copyToClipboard(METADEFENDER_REPORT.md5, "md5")}
                        className="inline-flex items-center gap-1 text-[11px] text-brand-teal hover:underline font-medium"
                      >
                        {copiedKey === "md5" ? <Check className="w-3 h-3" /> : <Copy className="w-3 h-3" />}
                        <span>{copiedKey === "md5" ? "Copied" : "Copy"}</span>
                      </button>
                    </div>
                    <div className="p-2 rounded-lg bg-black/40 border border-brand-border/60 text-[11px] font-mono text-brand-muted break-all select-all">
                      {METADEFENDER_REPORT.md5}
                    </div>
                  </div>
                </div>

                {/* Self-Verification Terminal Snippets */}
                <div className="glass-panel rounded-2xl border border-brand-border/90 p-5 space-y-3 shadow-xl">
                  <h3 className="text-sm font-bold text-white flex items-center gap-2">
                    <Terminal className="w-4 h-4 text-brand-teal" />
                    How to verify the APK hash
                  </h3>
                  <p className="text-xs text-brand-muted leading-relaxed">
                    Verify that your downloaded APK matches the audited checksum:
                  </p>

                  <div className="space-y-2 text-[11px] font-mono">
                    <div className="p-2.5 rounded-lg bg-black/50 border border-brand-border/50">
                      <span className="text-brand-teal font-semibold block mb-0.5">Windows PowerShell:</span>
                      <code className="text-white select-all">Get-FileHash tkmmingle-k1-release.apk</code>
                    </div>

                    <div className="p-2.5 rounded-lg bg-black/50 border border-brand-border/50">
                      <span className="text-brand-lavender font-semibold block mb-0.5">Linux / macOS Terminal:</span>
                      <code className="text-white select-all">shasum -a 256 tkmmingle-k1-release.apk</code>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>
      </section>

      {/* 4. WHY DIRECT DISTRIBUTION & SECURITY POLICY */}
      <section className="py-14 bg-brand-navySecondary/40 border-b border-brand-border/60">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-8">
          <div className="max-w-2xl space-y-2">
            <h2 className="text-2xl font-extrabold text-white">
              Why We Provide Multi-Engine Security Audits
            </h2>
            <p className="text-xs sm:text-sm text-brand-muted leading-relaxed">
              Transparent security practices designed for students and campus privacy.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="p-5 rounded-2xl bg-brand-navyCard border border-brand-border space-y-3">
              <div className="w-9 h-9 rounded-xl bg-brand-teal/20 text-brand-teal flex items-center justify-center">
                <ShieldCheck className="w-5 h-5" />
              </div>
              <h3 className="text-sm font-bold text-white">Addressing &ldquo;Unknown Apps&rdquo; Prompts</h3>
              <p className="text-xs text-brand-muted leading-relaxed">
                When installing APKs outside Google Play, Android displays standard security warnings. Providing audited MetaDefender certificates guarantees that the application package contains 0 malicious payloads.
              </p>
            </div>

            <div className="p-5 rounded-2xl bg-brand-navyCard border border-brand-border space-y-3">
              <div className="w-9 h-9 rounded-xl bg-brand-purple/20 text-brand-purple flex items-center justify-center">
                <Cpu className="w-5 h-5" />
              </div>
              <h3 className="text-sm font-bold text-white">Full Cryptographic Transparency</h3>
              <p className="text-xs text-brand-muted leading-relaxed">
                Every build has an immutable SHA-256 hash. By matching the hash on the MetaDefender scan with the hash displayed on our website and on your phone, you have mathematical proof of build integrity.
              </p>
            </div>

            <div className="p-5 rounded-2xl bg-brand-navyCard border border-brand-border space-y-3">
              <div className="w-9 h-9 rounded-xl bg-brand-lavender/20 text-brand-lavender flex items-center justify-center">
                <Layers className="w-5 h-5" />
              </div>
              <h3 className="text-sm font-bold text-white">Campus Privacy &amp; Open Source</h3>
              <p className="text-xs text-brand-muted leading-relaxed">
                TKMingle is built exclusively for TKMCE with mutual consent connections, PostgreSQL Row Level Security (RLS), and verified college email sign-in. Source code is openly auditable on GitHub.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* 5. FOOTER */}
      <footer className="bg-brand-navy pt-12 pb-10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-8">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div className="space-y-3 md:col-span-2">
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-8 rounded-lg bg-brand-navyCard border border-brand-border flex items-center justify-center p-1">
                  <Image
                    src="/images/logo_compact.svg"
                    alt="TKMingle"
                    width={24}
                    height={24}
                  />
                </div>
                <span className="text-lg font-bold tracking-tight text-white">
                  TKM<span className="text-brand-purple">ingle</span>
                </span>
              </div>
              <p className="text-xs text-brand-muted max-w-sm leading-relaxed">
                Campus social discovery platform for TKM College of Engineering, Kollam, Kerala. Built by Equipo Kromium.
              </p>
            </div>

            <div className="space-y-2">
              <h4 className="text-xs font-bold uppercase tracking-wider text-white">Security &amp; Downloads</h4>
              <ul className="space-y-1.5 text-xs text-brand-muted">
                <li>
                  <a
                    href="https://github.com/creatorspara/tkmingle/releases/download/v1.0.7-k1/tkmmingle-k1-release.apk"
                    download
                    className="text-brand-teal hover:underline flex items-center gap-1"
                  >
                    <Smartphone className="w-3 h-3" /> Android APK (v1.0.7-k1)
                  </a>
                </li>
                <li>
                  <a
                    href="/tkmmingle-k1-release.apk.pdf"
                    download="tkmmingle-k1-release.apk.pdf"
                    className="text-brand-lavender hover:underline flex items-center gap-1"
                  >
                    <FileText className="w-3 h-3" /> MetaDefender PDF Analysis
                  </a>
                </li>
                <li>
                  <Link href="/team" className="hover:text-white transition-colors">
                    Meet Equipo Kromium
                  </Link>
                </li>
              </ul>
            </div>

            <div className="space-y-2">
              <h4 className="text-xs font-bold uppercase tracking-wider text-white">Contact &amp; Support</h4>
              <ul className="space-y-1.5 text-xs text-brand-muted">
                <li><span className="text-brand-text">tkmmingle@gmail.com</span></li>
                <li><span className="text-brand-muted">TKMCE, Karicode, Kollam</span></li>
                <li><span className="text-brand-muted">Kerala 691005</span></li>
              </ul>
            </div>
          </div>

          <div className="pt-6 border-t border-brand-border/60 flex flex-col sm:flex-row items-center justify-between text-xs text-brand-muted gap-3">
            <p>&copy; 2026 TKMingle &bull; Equipo Kromium &bull; TKM College of Engineering.</p>
            <div className="flex items-center gap-5">
              <Link href="/" className="hover:text-white transition-colors">Home</Link>
              <Link href="/#download" className="hover:text-white transition-colors">Downloads</Link>
              <Link href="/#faq" className="hover:text-white transition-colors">FAQ</Link>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
