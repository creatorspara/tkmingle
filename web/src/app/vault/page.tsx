"use client";

import React, { useState } from "react";
import Link from "next/link";
import {
  Shield,
  Download,
  Monitor,
  Smartphone,
  CheckCircle2,
  Lock,
  Cpu,
  FileCheck,
  HardDrive,
  Copy,
  Check,
  ArrowDownCircle,
} from "lucide-react";

export default function KromiumVaultPage() {
  const [downloadingPlatform, setDownloadingPlatform] = useState<string | null>(null);
  const [copiedSha, setCopiedSha] = useState<string | null>(null);

  const directDownloads = {
    pc: {
      filename: "EquipoKromium-Windows.exe",
      url: "/api/vault/download?platform=pc",
      directUrl: "https://github.com/creatorspara/equipo-kromium-vault/releases/latest/download/EquipoKromium-Windows.exe",
      platform: "Windows 10 / 11 (64-bit)",
      format: "Standalone Portable Executable (.exe)",
      size: "Portable Runner",
    },
    android: {
      filename: "EquipoKromium-Android.apk",
      url: "/api/vault/download?platform=android",
      directUrl: "https://github.com/creatorspara/equipo-kromium-vault/releases/latest/download/EquipoKromium-Android.apk",
      platform: "Android 7.0+ (ARM64 / x86_64)",
      format: "Mobile Container Package (.apk)",
      size: "Release Package",
    },
  };

  const triggerDownload = (platform: "pc" | "android") => {
    setDownloadingPlatform(platform);
    const item = directDownloads[platform];

    // Trigger instant browser download without page navigation
    const link = document.createElement("a");
    link.href = item.url;
    link.setAttribute("download", item.filename);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    setTimeout(() => {
      setDownloadingPlatform(null);
    }, 2500);
  };

  const copyToClipboard = (text: string, id: string) => {
    navigator.clipboard.writeText(text);
    setCopiedSha(id);
    setTimeout(() => setCopiedSha(null), 2000);
  };

  return (
    <div className="min-h-screen bg-[#0A0A0F] text-[#F5F5F7] font-sans antialiased selection:bg-[#6C4DFF] selection:text-white flex flex-col justify-between">
      {/* 1. MINIMAL BRAND NAVBAR */}
      <header className="border-b border-[#2A2640]/60 bg-[#0C0E1A]/80 backdrop-blur-md sticky top-0 z-40">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 h-16 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-[#6C4DFF]/20 border border-[#6C4DFF]/40 flex items-center justify-center text-[#50D6C2] shadow-inner">
              <Shield className="w-5 h-5" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="font-extrabold text-white text-base tracking-tight">
                  Equipo Kromium Vault
                </span>
                <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-[#6C4DFF]/25 border border-[#6C4DFF]/40 text-[#D1C4FF]">
                  v1.0.1 Stable
                </span>
              </div>
              <p className="text-[10px] text-[#9D9AA8] font-mono leading-none">
                Build &bull; Open &bull; Share
              </p>
            </div>
          </div>

          <div className="flex items-center gap-2 sm:gap-3">
            <button
              onClick={() => triggerDownload("pc")}
              className="px-3 sm:px-3.5 py-1.5 rounded-xl bg-white/10 hover:bg-white/15 border border-white/10 text-white font-medium text-xs flex items-center gap-1.5 transition-colors"
            >
              <Monitor className="w-3.5 h-3.5 text-[#50D6C2]" />
              <span className="hidden sm:inline">Download</span> PC
            </button>
            <button
              onClick={() => triggerDownload("android")}
              className="px-3 sm:px-3.5 py-1.5 rounded-xl bg-[#6C4DFF] hover:bg-[#6C4DFF]/90 text-white font-semibold text-xs flex items-center gap-1.5 transition-all shadow-md shadow-[#6C4DFF]/20"
            >
              <Smartphone className="w-3.5 h-3.5" />
              <span className="hidden sm:inline">Download</span> Android
            </button>
          </div>
        </div>
      </header>

      {/* 2. HERO & DIRECT DOWNLOADS */}
      <main className="flex-1 py-12 sm:py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 space-y-12">
          {/* Header Title */}
          <div className="text-center space-y-3 max-w-2xl mx-auto">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#6C4DFF]/15 border border-[#6C4DFF]/30 text-xs font-semibold text-[#D1C4FF]">
              <Lock className="w-3 h-3 text-[#50D6C2]" />
              <span>NIST SP 800-38D AES-256-GCM Container Security</span>
            </div>
            <h1 className="text-3xl sm:text-5xl font-extrabold text-white tracking-tight leading-tight">
              Direct File Security Downloads
            </h1>
            <p className="text-sm sm:text-base text-[#9D9AA8] leading-relaxed">
              Official zero-knowledge file encryption suite by Equipo Kromium. Select your platform below to instantly download the latest release binary.
            </p>
          </div>

          {/* Download Notification Banner when triggered */}
          {downloadingPlatform && (
            <div className="rounded-2xl border border-[#50D6C2]/40 bg-[#50D6C2]/10 p-4 text-center animate-fade-in">
              <div className="flex items-center justify-center gap-2 text-xs font-semibold text-[#50D6C2]">
                <ArrowDownCircle className="w-4 h-4 animate-bounce" />
                <span>
                  Direct download started for {downloadingPlatform === "pc" ? "Windows Standalone (.exe)" : "Android Package (.apk)"}! Check your downloads folder.
                </span>
              </div>
            </div>
          )}

          {/* PRIMARY DOWNLOAD CARDS */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* CARD 1: WINDOWS PC */}
            <div className="rounded-3xl bg-[#12121A] border border-[#2A2640] hover:border-[#6C4DFF]/50 p-6 sm:p-8 flex flex-col justify-between space-y-6 transition-all shadow-xl group">
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div className="w-12 h-12 rounded-2xl bg-[#6C4DFF]/15 border border-[#6C4DFF]/30 flex items-center justify-center text-[#50D6C2]">
                    <Monitor className="w-6 h-6" />
                  </div>
                  <span className="text-[11px] font-semibold text-emerald-400 bg-emerald-500/10 border border-emerald-500/20 px-2.5 py-1 rounded-full flex items-center gap-1">
                    <CheckCircle2 className="w-3 h-3" /> Standalone (.exe)
                  </span>
                </div>

                <div className="space-y-1">
                  <h2 className="text-xl sm:text-2xl font-bold text-white">
                    Download for PC
                  </h2>
                  <p className="text-xs text-[#9D9AA8] font-mono">
                    {directDownloads.pc.filename}
                  </p>
                </div>

                <p className="text-xs text-[#9D9AA8] leading-relaxed">
                  Portable single-file desktop runner with background worker encryption, zero dependencies, and automatic plaintext shredding.
                </p>

                <div className="space-y-2 pt-2 border-t border-white/5 text-xs text-[#9D9AA8]">
                  <div className="flex items-center justify-between">
                    <span>Target OS:</span>
                    <span className="text-white font-medium">{directDownloads.pc.platform}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span>Format:</span>
                    <span className="text-white font-medium">Portable Native Binary</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span>Installation:</span>
                    <span className="text-emerald-400 font-medium">None (Zero-Install)</span>
                  </div>
                </div>
              </div>

              <div className="pt-2 space-y-2">
                <button
                  onClick={() => triggerDownload("pc")}
                  className="w-full py-3.5 rounded-2xl bg-[#6C4DFF] hover:bg-[#6C4DFF]/90 text-white font-bold text-sm flex items-center justify-center gap-2 transition-all shadow-lg shadow-[#6C4DFF]/25 active:scale-[0.98]"
                >
                  <Download className="w-4 h-4" />
                  <span>Download for PC (.exe)</span>
                </button>
                <div className="text-center">
                  <a
                    href={directDownloads.pc.directUrl}
                    download={directDownloads.pc.filename}
                    className="text-[11px] text-[#9D9AA8] hover:text-[#D1C4FF] underline transition-colors"
                  >
                    Direct Asset Link
                  </a>
                </div>
              </div>
            </div>

            {/* CARD 2: ANDROID */}
            <div className="rounded-3xl bg-[#12121A] border border-[#2A2640] hover:border-[#50D6C2]/50 p-6 sm:p-8 flex flex-col justify-between space-y-6 transition-all shadow-xl group">
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div className="w-12 h-12 rounded-2xl bg-[#50D6C2]/15 border border-[#50D6C2]/30 flex items-center justify-center text-[#50D6C2]">
                    <Smartphone className="w-6 h-6" />
                  </div>
                  <span className="text-[11px] font-semibold text-emerald-400 bg-emerald-500/10 border border-emerald-500/20 px-2.5 py-1 rounded-full flex items-center gap-1">
                    <CheckCircle2 className="w-3 h-3" /> Android (.apk)
                  </span>
                </div>

                <div className="space-y-1">
                  <h2 className="text-xl sm:text-2xl font-bold text-white">
                    Download for Android
                  </h2>
                  <p className="text-xs text-[#9D9AA8] font-mono">
                    {directDownloads.android.filename}
                  </p>
                </div>

                <p className="text-xs text-[#9D9AA8] leading-relaxed">
                  Mobile encrypted file container built with Flutter. Encrypt and decrypt confidential archives directly on your mobile device.
                </p>

                <div className="space-y-2 pt-2 border-t border-white/5 text-xs text-[#9D9AA8]">
                  <div className="flex items-center justify-between">
                    <span>Target OS:</span>
                    <span className="text-white font-medium">{directDownloads.android.platform}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span>Format:</span>
                    <span className="text-white font-medium">Release Package (.apk)</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span>Permissions:</span>
                    <span className="text-emerald-400 font-medium">Offline Storage Only</span>
                  </div>
                </div>
              </div>

              <div className="pt-2 space-y-2">
                <button
                  onClick={() => triggerDownload("android")}
                  className="w-full py-3.5 rounded-2xl bg-[#50D6C2] hover:bg-[#50D6C2]/90 text-[#0A0A0F] font-bold text-sm flex items-center justify-center gap-2 transition-all shadow-lg shadow-[#50D6C2]/20 active:scale-[0.98]"
                >
                  <Download className="w-4 h-4" />
                  <span>Download for Android (.apk)</span>
                </button>
                <div className="text-center">
                  <a
                    href={directDownloads.android.directUrl}
                    download={directDownloads.android.filename}
                    className="text-[11px] text-[#9D9AA8] hover:text-[#50D6C2] underline transition-colors"
                  >
                    Direct Asset Link
                  </a>
                </div>
              </div>
            </div>
          </div>

          {/* 3. TECHNICAL SPECIFICATIONS (MINIMAL & ACCREDITED) */}
          <div className="rounded-3xl bg-[#12121A] border border-[#2A2640] p-6 sm:p-8 space-y-6">
            <div className="border-b border-white/10 pb-4">
              <h3 className="text-lg font-bold text-white flex items-center gap-2">
                <FileCheck className="w-5 h-5 text-[#50D6C2]" />
                Cryptographic Architecture &bull; .kromium Container
              </h3>
              <p className="text-xs text-[#9D9AA8] mt-1">
                Interoperable standard across Windows, Android, and Web clients.
              </p>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-4 text-xs">
              <div className="p-4 rounded-2xl bg-white/5 border border-white/5 space-y-1">
                <div className="text-[#9D9AA8] font-mono text-[10px]">Primary Cipher</div>
                <div className="font-bold text-white text-sm">AES-256-GCM</div>
                <p className="text-[11px] text-[#9D9AA8]">
                  NIST SP 800-38D authenticated encryption with 128-bit authentication tags.
                </p>
              </div>

              <div className="p-4 rounded-2xl bg-white/5 border border-white/5 space-y-1">
                <div className="text-[#9D9AA8] font-mono text-[10px]">Key Derivation</div>
                <div className="font-bold text-white text-sm">PBKDF2-SHA256</div>
                <p className="text-[11px] text-[#9D9AA8]">
                  600,000 iterations + 32-byte CSPRNG salt to defeat rainbow tables.
                </p>
              </div>

              <div className="p-4 rounded-2xl bg-white/5 border border-white/5 space-y-1">
                <div className="text-[#9D9AA8] font-mono text-[10px]">Integrity Check</div>
                <div className="font-bold text-white text-sm">Header AAD Protection</div>
                <p className="text-[11px] text-[#9D9AA8]">
                  Container headers, salt, and IV are cryptographically authenticated before release.
                </p>
              </div>

              <div className="p-4 rounded-2xl bg-white/5 border border-white/5 space-y-1">
                <div className="text-[#9D9AA8] font-mono text-[10px]">Privacy &amp; Security</div>
                <div className="font-bold text-white text-sm">Zero-Knowledge</div>
                <p className="text-[11px] text-[#9D9AA8]">
                  100% offline CPU execution. Zero telemetry, zero cloud key exchange.
                </p>
              </div>
            </div>
          </div>

          {/* 4. VERIFICATION COMMAND HELPER */}
          <div className="rounded-2xl bg-[#0D0E1A] border border-[#2A2640] p-4 sm:p-5 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
            <div className="space-y-1">
              <div className="text-xs font-bold text-white flex items-center gap-1.5">
                <HardDrive className="w-3.5 h-3.5 text-[#6C4DFF]" />
                Windows File Hash Verification (PowerShell)
              </div>
              <code className="text-[11px] text-[#D1C4FF] font-mono bg-black/40 px-2.5 py-1 rounded-lg block">
                Get-FileHash -Algorithm SHA256 .\EquipoKromium-Windows.exe
              </code>
            </div>

            <button
              onClick={() =>
                copyToClipboard(
                  "Get-FileHash -Algorithm SHA256 .\\EquipoKromium-Windows.exe",
                  "ps-hash"
                )
              }
              className="px-3 py-1.5 rounded-xl bg-white/10 hover:bg-white/15 border border-white/10 text-white font-medium text-xs flex items-center gap-1.5 transition-colors shrink-0"
            >
              {copiedSha === "ps-hash" ? (
                <>
                  <Check className="w-3.5 h-3.5 text-emerald-400" />
                  <span>Copied</span>
                </>
              ) : (
                <>
                  <Copy className="w-3.5 h-3.5" />
                  <span>Copy Command</span>
                </>
              )}
            </button>
          </div>
        </div>
      </main>

      {/* 5. MINIMAL BRAND FOOTER */}
      <footer className="border-t border-[#2A2640]/60 bg-[#0C0E1A] py-8 text-xs text-[#9D9AA8]">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-2">
            <Shield className="w-4 h-4 text-[#6C4DFF]" />
            <span className="text-white font-semibold">Equipo Kromium Vault</span>
            <span>&bull;</span>
            <span>Build &bull; Open &bull; Share</span>
          </div>

          <div className="flex items-center gap-4">
            <button
              onClick={() => triggerDownload("pc")}
              className="hover:text-white transition-colors"
            >
              Download for PC (.exe)
            </button>
            <span>&bull;</span>
            <button
              onClick={() => triggerDownload("android")}
              className="hover:text-white transition-colors"
            >
              Download for Android (.apk)
            </button>
            <span>&bull;</span>
            <Link href="/" className="hover:text-white transition-colors">
              TKMingle Portal
            </Link>
          </div>
        </div>
      </footer>
    </div>
  );
}
