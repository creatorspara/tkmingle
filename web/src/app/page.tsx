"use client";

import React, { useState, useEffect } from "react";
import Image from "next/image";
import Link from "next/link";
import {
  Compass,
  Users2,
  MessageSquare,
  Sparkles,
  ChevronDown,
  ArrowRight,
  Menu,
  X,
  CheckCircle2,
  Lock,
  GraduationCap,
  Send,
  HelpCircle,
  Mail,
  AlertCircle,
  LogIn,
  Download,
  Smartphone,
  ShieldCheck,
  Copy,
  Check,
  ExternalLink,
  Layers,
  Cpu,
  Code2,
  Apple,
  Share,
  PlusSquare,
  Info,
  Globe,
} from "lucide-react";
import { MOCK_CIRCLES } from "@/lib/mockData";
import UserAvatar from "@/components/UserAvatar";
import { supabase, isLiveSupabaseConfigured } from "@/lib/supabaseClient";

interface DisplayStudent {
  id: string;
  full_name: string;
  username: string;
  department: string;
  academic_year: string;
  bio: string;
  profile_image: string;
  interests: string[];
  availability: string;
}

interface AppRelease {
  version_name: string;
  version_code: number;
  download_url: string;
  changelog: string;
  sha256_checksum: string;
  published_at: string;
}

const DEFAULT_RELEASE: AppRelease = {
  version_name: "v1.0.7-k1",
  version_code: 11,
  download_url: "https://github.com/creatorspara/tkmingle/releases/download/v1.0.7-k1/tkmmingle-k1-release.apk",
  changelog: "Push notification recipient isolation, account mismatch suppression, and active chat in-conversation silence.",
  sha256_checksum: "57E805E9C59E4F3D2EA8FAB706E78B7D5507BC7BA7C82EA75B10D860B26DA4A8",
  published_at: "2026-11-22T10:41:26.073Z",
};

const DEFAULT_STUDENTS: DisplayStudent[] = [
  {
    id: "std-1",
    full_name: "Devika S.",
    username: "devika_s",
    department: "Robotics & AI",
    academic_year: "3rd Year",
    bio: "Embedded systems & AI robotics explorer. Working on autonomous quadcopters and creative web projects across campus!",
    profile_image: "preset:tk_avatar_03",
    interests: ["Robotics", "IoT", "UI/UX Design", "AI/ML", "Badminton"],
    availability: "Free weekends & evenings",
  },
  {
    id: "std-2",
    full_name: "Aditya S.",
    username: "aditya_s",
    department: "Computer Science & Engineering",
    academic_year: "3rd Year",
    bio: "Flutter fanatic & hackathon enthusiast. Looking to meet designers and hardware folks across TKM departments!",
    profile_image: "preset:tk_avatar_02",
    interests: ["Mobile Dev", "AI/ML", "Hackathons", "Anime", "Football"],
    availability: "Free after 4:30 PM (Library/Amphi)",
  },
  {
    id: "std-3",
    full_name: "Nandana R.",
    username: "nandana_arch",
    department: "Architecture",
    academic_year: "2nd Year",
    bio: "Fascinated by Kerala heritage architecture & sustainable urban design. Looking for people who appreciate art and photography.",
    profile_image: "preset:tk_avatar_09",
    interests: ["Architecture", "Photography", "Sketching", "Graphic Design"],
    availability: "Architecture Block studio hours",
  },
  {
    id: "std-4",
    full_name: "Fahad Rahman",
    username: "fahad_r",
    department: "Mechanical Engineering",
    academic_year: "4th Year",
    bio: "Formula Student racing chassis lead. Passionate about rapid prototyping, 3D printing, and electric mobility.",
    profile_image: "preset:tk_avatar_04",
    interests: ["Automotive", "3D Printing", "EVs", "SolidWorks"],
    availability: "Near Mech Workshop after 5 PM",
  },
];

export default function LandingPage() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [openFaqIndex, setOpenFaqIndex] = useState<number | null>(0);
  const [sessionUser, setSessionUser] = useState<any>(null);
  const [students, setStudents] = useState<DisplayStudent[]>(DEFAULT_STUDENTS);

  // Dynamic Latest Release State (Auto-updates with new builds)
  const [latestRelease, setLatestRelease] = useState<AppRelease>(DEFAULT_RELEASE);
  const [copiedHash, setCopiedHash] = useState(false);
  const [copiedPwaUrl, setCopiedPwaUrl] = useState(false);
  const [activePlatformTab, setActivePlatformTab] = useState<"android" | "ios">("android");

  // Contact Modal State
  const [contactModalOpen, setContactModalOpen] = useState(false);
  const [contactCategory, setContactCategory] = useState("Suggestions & Feedback");
  const [contactName, setContactName] = useState("");
  const [contactEmail, setContactEmail] = useState("");
  const [contactDept, setContactDept] = useState("Computer Science & Engineering");
  const [contactMessage, setContactMessage] = useState("");
  const [contactSubmitting, setContactSubmitting] = useState(false);
  const [contactSuccess, setContactSuccess] = useState(false);
  const [contactMailto, setContactMailto] = useState("");

  // Check auth session, fetch active student profiles, and query latest release dynamically
  useEffect(() => {
    // 1. Auth session listener
    if (isLiveSupabaseConfigured()) {
      supabase.auth.getSession().then(({ data }) => {
        if (data?.session?.user) {
          setSessionUser(data.session.user);
        }
      });

      const { data: authListener } = supabase.auth.onAuthStateChange((_event, session) => {
        setSessionUser(session?.user ?? null);
      });

      // 2. Fetch live discoverable profiles
      const loadLiveProfiles = async () => {
        try {
          const { data, error } = await supabase
            .from("profiles")
            .select("id, full_name, username, department, academic_year, bio, profile_image, avatar_id, interests, availability")
            .eq("discoverable", true)
            .not("full_name", "is", null)
            .order("created_at", { ascending: false })
            .limit(4);

          if (!error && data && data.length > 0) {
            const liveProfiles: DisplayStudent[] = data.map((p: any) => ({
              id: p.id,
              full_name: p.full_name || "TKMCE Student",
              username: p.username || "student",
              department: p.department || "Engineering",
              academic_year: p.academic_year || "Student",
              bio: p.bio || "Student at TKM College of Engineering.",
              profile_image: p.profile_image || (p.avatar_id ? `preset:${p.avatar_id}` : "preset:tk_avatar_01"),
              interests: Array.isArray(p.interests) && p.interests.length > 0 ? p.interests : ["Campus", "Engineering", "Technology"],
              availability: p.availability || "Available on campus",
            }));
            setStudents(liveProfiles);
          }
        } catch {
          // Keep default clean profiles
        }
      };
      loadLiveProfiles();

      // 3. Dynamic Auto-Updating Release Fetch (Always selects highest version_code)
      const fetchLatestRelease = async () => {
        try {
          const { data, error } = await supabase
            .from("app_releases")
            .select("version_name, version_code, download_url, changelog, sha256_checksum, published_at")
            .eq("platform", "android")
            .order("version_code", { ascending: false })
            .limit(1)
            .maybeSingle();

          if (!error && data && data.download_url) {
            setLatestRelease({
              version_name: data.version_name,
              version_code: data.version_code,
              download_url: data.download_url,
              changelog: data.changelog || DEFAULT_RELEASE.changelog,
              sha256_checksum: data.sha256_checksum || DEFAULT_RELEASE.sha256_checksum,
              published_at: data.published_at || DEFAULT_RELEASE.published_at,
            });
            return;
          }

          // Fallback to GitHub Releases API if Supabase query yields nothing
          const ghRes = await fetch("https://api.github.com/repos/creatorspara/tkmingle/releases/latest");
          if (ghRes.ok) {
            const ghData = await ghRes.json();
            const apkAsset = ghData.assets?.find((a: any) => a.name.endsWith(".apk"));
            if (apkAsset) {
              setLatestRelease((prev) => ({
                ...prev,
                version_name: ghData.tag_name || prev.version_name,
                download_url: apkAsset.browser_download_url,
                changelog: ghData.body || prev.changelog,
              }));
            }
          }
        } catch (e) {
          console.warn("Release sync notification:", e);
        }
      };
      fetchLatestRelease();

      return () => {
        authListener?.subscription.unsubscribe();
      };
    }
  }, []);

  const copyChecksum = () => {
    if (latestRelease.sha256_checksum) {
      navigator.clipboard.writeText(latestRelease.sha256_checksum);
      setCopiedHash(true);
      setTimeout(() => setCopiedHash(false), 2200);
    }
  };

  const copyPwaLink = () => {
    navigator.clipboard.writeText("https://tkmingle.vercel.app");
    setCopiedPwaUrl(true);
    setTimeout(() => setCopiedPwaUrl(false), 2200);
  };

  const handleContactSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!contactMessage.trim()) return;

    setContactSubmitting(true);
    try {
      const res = await fetch("/api/contact", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name: contactName.trim() || "Anonymous Student",
          email: contactEmail.trim() || "anonymous@tkmce.ac.in",
          department: contactDept.trim() || "TKMCE Campus",
          category: contactCategory,
          message: contactMessage.trim(),
          source: "landing_modal",
        }),
      });
      const data = await res.json();
      if (data?.mailtoUrl) {
        setContactMailto(data.mailtoUrl);
      }
    } catch (err) {
      console.error("Contact inquiry dispatch notice:", err);
    } finally {
      setContactSubmitting(false);
      setContactSuccess(true);
      setTimeout(() => {
        setContactSuccess(false);
        setContactModalOpen(false);
        setContactMessage("");
        setContactName("");
        setContactEmail("");
      }, 3800);
    }
  };

  const faqs = [
    {
      q: "What is TKMingle?",
      a: "TKMingle is a student platform built exclusively for TKM College of Engineering (TKMCE), Kollam. It helps students discover peers from other departments based on shared interests, projects, and activities.",
    },
    {
      q: "How do I install TKMingle on Android?",
      a: `Download the universal APK file (${latestRelease.version_name}) directly from the download section. Once downloaded, tap the file. When Android prompts 'Install unknown apps', enable 'Allow from this source', then tap Install. The app queries Supabase on launch and provides 1-tap in-app updates for future releases.`,
    },
    {
      q: "How do I install TKMingle on an iPhone (iOS)?",
      a: "Open https://tkmingle.vercel.app in Safari on your iPhone, tap the Share button (square with arrow at the bottom), and select 'Add to Home Screen'. TKMingle will install directly to your home screen and open in standalone app mode without browser bars.",
    },
    {
      q: "Why isn't TKMingle on Google Play or the Apple App Store?",
      a: "Our distribution strategy relies on direct Android APK releases via GitHub and iOS Progressive Web Apps (PWA) via Safari. This allows us to deliver TKMingle freely and immediately to all students without recurring commercial membership fees ($99/year Apple Developer Program, Play Console fees) or bureaucratic store approval delays.",
    },
    {
      q: "Who can join TKMingle?",
      a: "Access is limited to verified students and community members of TKM College of Engineering. Accounts are authenticated using institutional credentials.",
    },
    {
      q: "How do student connections work?",
      a: "Connections are based on mutual consent. You can send a connection request with a brief note. Direct 1:1 messaging opens only after both students accept. Pending requests can be resent or cancelled at any time.",
    },
    {
      q: "Can I control my profile visibility?",
      a: "Yes. You can turn campus discovery on or off at any time in Settings. When discovery is turned off, your profile does not appear in the student directory.",
    },
    {
      q: "What are Campus Circles?",
      a: "Circles are campus communities for clubs, technical teams, sports, and interests where students post updates, announce workshops, and organize activities.",
    },
  ];

  return (
    <div className="min-h-screen bg-brand-navy text-brand-text flex flex-col selection:bg-brand-purple selection:text-white">
      {/* 1. NAVBAR */}
      <header className="sticky top-0 z-50 bg-brand-navy/90 backdrop-blur-md border-b border-brand-border/60">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-18 flex items-center justify-between">
          {/* Brand Logo */}
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
                TKMCE Kollam
              </span>
            </div>
          </Link>

          {/* Desktop Navigation */}
          <nav className="hidden lg:flex items-center gap-7 text-sm font-medium text-brand-muted">
            <a href="#discover" className="hover:text-white transition-colors">
              Discover
            </a>
            <a href="#download" className="hover:text-white transition-colors flex items-center gap-1.5 text-brand-teal font-semibold">
              <Download className="w-3.5 h-3.5" />
              Get App (Android &amp; iOS)
            </a>
            <a href="#circles" className="hover:text-white transition-colors">
              Campus Circles
            </a>
            <a href="#connect" className="hover:text-white transition-colors">
              Connect &amp; Chat
            </a>
            <a href="#kromium" className="hover:text-white transition-colors flex items-center gap-1 text-brand-lavender font-semibold">
              Equipo Kromium
            </a>
            <a href="#faq" className="hover:text-white transition-colors">
              FAQ
            </a>
          </nav>

          {/* Action CTAs */}
          <div className="hidden md:flex items-center gap-3">
            {/* Direct download CTA in header */}
            <a
              href="#download"
              className="px-3.5 py-2 text-xs font-semibold rounded-tk-btn bg-brand-navyCard hover:bg-brand-navySecondary border border-brand-border text-brand-teal transition-colors flex items-center gap-1.5"
              title="Install for Android & iOS"
            >
              <Smartphone className="w-3.5 h-3.5" />
              <span>Get TKMingle</span>
            </a>

            {sessionUser ? (
              <Link
                href="/app/discover"
                className="px-4 py-2 text-sm font-semibold rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white transition-colors flex items-center gap-2 shadow-purple-glow"
              >
                Open Campus Portal
                <ArrowRight className="w-4 h-4" />
              </Link>
            ) : (
              <>
                <Link
                  href="/login"
                  className="px-3.5 py-2 text-sm font-semibold text-brand-text hover:text-white transition-colors"
                >
                  Sign In
                </Link>
                <Link
                  href="/register"
                  className="px-4 py-2 text-sm font-semibold rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white transition-colors"
                >
                  Join TKMingle
                </Link>
              </>
            )}
          </div>

          {/* Mobile menu toggle */}
          <button
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className="lg:hidden p-2 text-brand-muted hover:text-white"
            aria-label="Toggle navigation menu"
          >
            {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
          </button>
        </div>

        {/* Mobile menu dropdown */}
        {mobileMenuOpen && (
          <div className="lg:hidden bg-brand-navySecondary border-b border-brand-border px-4 py-5 space-y-3">
            <a
              href="#discover"
              onClick={() => setMobileMenuOpen(false)}
              className="block text-sm font-medium text-brand-muted hover:text-white"
            >
              Discover Students
            </a>
            <a
              href="#download"
              onClick={() => setMobileMenuOpen(false)}
              className="block text-sm font-semibold text-brand-teal hover:text-white flex items-center gap-2"
            >
              <Smartphone className="w-4 h-4" /> Get App (Android APK &amp; iOS PWA)
            </a>
            <a
              href="#circles"
              onClick={() => setMobileMenuOpen(false)}
              className="block text-sm font-medium text-brand-muted hover:text-white"
            >
              Campus Circles
            </a>
            <a
              href="#connect"
              onClick={() => setMobileMenuOpen(false)}
              className="block text-sm font-medium text-brand-muted hover:text-white"
            >
              Connect &amp; Chat
            </a>
            <a
              href="#kromium"
              onClick={() => setMobileMenuOpen(false)}
              className="block text-sm font-semibold text-brand-lavender hover:text-white"
            >
              Equipo Kromium
            </a>
            <a
              href="#faq"
              onClick={() => setMobileMenuOpen(false)}
              className="block text-sm font-medium text-brand-muted hover:text-white"
            >
              FAQ
            </a>
            <div className="pt-3 border-t border-brand-border/60 flex flex-col gap-2">
              <a
                href={latestRelease.download_url}
                download
                onClick={() => setMobileMenuOpen(false)}
                className="w-full text-center py-2.5 text-xs font-semibold rounded-tk-btn bg-brand-navyCard border border-brand-border text-brand-teal flex items-center justify-center gap-2"
              >
                <Download className="w-4 h-4" />
                Direct Download APK ({latestRelease.version_name})
              </a>

              {sessionUser ? (
                <Link
                  href="/app/discover"
                  onClick={() => setMobileMenuOpen(false)}
                  className="w-full text-center py-2.5 text-sm font-semibold rounded-tk-btn bg-brand-purple text-white flex items-center justify-center gap-2"
                >
                  Open Campus Portal
                  <ArrowRight className="w-4 h-4" />
                </Link>
              ) : (
                <>
                  <Link
                    href="/login"
                    onClick={() => setMobileMenuOpen(false)}
                    className="w-full text-center py-2 text-sm font-semibold rounded-tk-btn border border-brand-border text-white"
                  >
                    Sign In
                  </Link>
                  <Link
                    href="/register"
                    onClick={() => setMobileMenuOpen(false)}
                    className="w-full text-center py-2 text-sm font-semibold rounded-tk-btn bg-brand-purple text-white"
                  >
                    Join TKMingle
                  </Link>
                </>
              )}
            </div>
          </div>
        )}
      </header>

      {/* 2. HERO SECTION */}
      <section className="relative pt-12 pb-16 md:pt-20 md:pb-24 border-b border-brand-border/60 overflow-hidden">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-10 items-center">
            {/* Left Content */}
            <div className="lg:col-span-7 text-center lg:text-left space-y-5">
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-brand-navyCard border border-brand-border text-xs font-medium text-brand-teal">
                <Sparkles className="w-3.5 h-3.5" />
                <span>Student Community • TKMCE Kollam</span>
              </div>

              <h1 className="text-3xl sm:text-5xl font-extrabold tracking-tight leading-tight text-white">
                Your campus is bigger than your branch.
              </h1>

              <p className="text-base sm:text-lg text-brand-muted max-w-xl leading-relaxed">
                Meet students from other engineering departments, find partners for hackathons and projects, join campus circles, and connect across TKMCE.
              </p>

              {/* Primary Action Buttons */}
              <div className="pt-2 flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-3">
                {/* Android APK Button */}
                <a
                  href={latestRelease.download_url}
                  download
                  className="w-full sm:w-auto px-5 py-3 text-sm font-bold rounded-tk-btn bg-gradient-to-r from-brand-purple to-purple-600 hover:opacity-95 text-white transition-all flex items-center justify-center gap-2 shadow-purple-glow"
                >
                  <Download className="w-4 h-4" />
                  <span>Download APK (Android)</span>
                </a>

                {/* iOS Safari Web App CTA */}
                <a
                  href="#download"
                  onClick={() => setActivePlatformTab("ios")}
                  className="w-full sm:w-auto px-5 py-3 text-sm font-semibold rounded-tk-btn bg-brand-navyCard hover:bg-brand-navySecondary border border-brand-border text-white transition-colors flex items-center justify-center gap-2"
                >
                  <Apple className="w-4 h-4 text-brand-lavender" />
                  <span>iOS Safari PWA</span>
                </a>

                {sessionUser ? (
                  <Link
                    href="/app/discover"
                    className="w-full sm:w-auto px-5 py-3 text-sm font-semibold rounded-tk-btn border border-brand-border/60 hover:border-brand-purple text-brand-text transition-colors flex items-center justify-center gap-2"
                  >
                    Enter Portal
                    <ArrowRight className="w-4 h-4" />
                  </Link>
                ) : (
                  <Link
                    href="/login"
                    className="w-full sm:w-auto px-4 py-3 text-sm font-semibold text-brand-muted hover:text-white transition-colors flex items-center justify-center gap-1"
                  >
                    Sign In &rarr;
                  </Link>
                )}
              </div>

              {/* Live Version Tag & Checksum Preview */}
              <div className="pt-1 flex flex-wrap items-center justify-center lg:justify-start gap-3 text-xs text-brand-muted">
                <span className="inline-flex items-center gap-1 text-[11px] text-brand-teal font-medium">
                  <span className="w-2 h-2 rounded-full bg-brand-teal animate-pulse" />
                  Latest APK {latestRelease.version_name} (Build {latestRelease.version_code})
                </span>
                <span className="text-brand-border">|</span>
                <span className="text-[11px] text-brand-muted">
                  iOS: Safari Add to Home Screen PWA
                </span>
              </div>

              {/* Department representation */}
              <div className="pt-4 flex flex-wrap items-center justify-center lg:justify-start gap-2 text-xs text-brand-muted">
                <span className="font-semibold text-white">Branches:</span>
                <span>CSE</span>
                <span>•</span>
                <span>ECE</span>
                <span>•</span>
                <span>Mech</span>
                <span>•</span>
                <span>Civil</span>
                <span>•</span>
                <span>EEE</span>
                <span>•</span>
                <span>Chemical</span>
                <span>•</span>
                <span>Arch</span>
                <span>•</span>
                <span>MCA</span>
              </div>
            </div>

            {/* Right Student Card Preview */}
            <div className="lg:col-span-5 flex justify-center">
              <div className="w-full max-w-sm glass-panel rounded-2xl p-5 border border-brand-border/80 space-y-4 shadow-xl">
                <div className="flex items-center gap-3">
                  <UserAvatar
                    src="preset:tk_avatar_03"
                    name="Devika S."
                    size={56}
                    className="rounded-2xl border border-brand-purple/40"
                  />
                  <div>
                    <h3 className="font-bold text-base text-white flex items-center gap-1.5">
                      Devika S.
                      <CheckCircle2 className="w-4 h-4 text-brand-teal" />
                    </h3>
                    <p className="text-xs text-brand-muted">
                      Robotics &amp; AI • 3rd Year
                    </p>
                    <span className="text-[10px] text-brand-teal font-medium">
                      Verified Student
                    </span>
                  </div>
                </div>

                <p className="text-xs text-brand-text/90 leading-relaxed">
                  Embedded systems &amp; AI robotics explorer. Working on autonomous quadcopters and creative web projects across campus!
                </p>

                <div className="flex flex-wrap gap-1.5 pt-1">
                  <span className="text-[10px] px-2 py-0.5 rounded-md bg-brand-navySecondary border border-brand-border text-brand-lavender font-medium">
                    Robotics
                  </span>
                  <span className="text-[10px] px-2 py-0.5 rounded-md bg-brand-navySecondary border border-brand-border text-brand-lavender font-medium">
                    IoT
                  </span>
                  <span className="text-[10px] px-2 py-0.5 rounded-md bg-brand-navySecondary border border-brand-border text-brand-lavender font-medium">
                    UI/UX
                  </span>
                </div>

                <div className="pt-2 border-t border-brand-border/60 flex items-center justify-between text-xs">
                  <span className="text-brand-muted text-[11px]">Free weekends &amp; evenings</span>
                  <Link
                    href={sessionUser ? "/app/discover" : "/register"}
                    className="px-3 py-1.5 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white text-xs font-medium transition-colors"
                  >
                    Connect
                  </Link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 3. RELEASE STRATEGY & INSTALLATION GUIDANCE (ANDROID APK & IOS PWA) */}
      <section id="download" className="py-20 bg-[#090C15] border-b border-brand-border/60 relative overflow-hidden">
        {/* Glow backdrop accent */}
        <div className="absolute top-0 right-1/4 w-96 h-96 bg-brand-purple/10 rounded-full blur-3xl pointer-events-none" />
        <div className="absolute bottom-0 left-1/4 w-96 h-96 bg-brand-teal/5 rounded-full blur-3xl pointer-events-none" />

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 space-y-12">
          {/* Section Header */}
          <div className="text-center max-w-2xl mx-auto space-y-3">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-brand-navyCard border border-brand-border text-xs font-semibold text-brand-teal">
              <Smartphone className="w-3.5 h-3.5 text-brand-teal" />
              <span>Release Strategy • Android APK &amp; iOS PWA</span>
            </div>
            <h2 className="text-2xl sm:text-4xl font-extrabold text-white tracking-tight">
              Get TKMingle on Android &amp; iOS
            </h2>
            <p className="text-sm text-brand-muted leading-relaxed">
              Direct campus distribution built by students for students — free, open, and without commercial store paywalls.
            </p>
          </div>

          {/* Release Strategy Context Card */}
          <div className="max-w-4xl mx-auto p-5 rounded-2xl bg-brand-navySecondary/60 border border-brand-border/80 text-xs text-brand-muted leading-relaxed flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
            <div className="flex items-start gap-3">
              <Info className="w-5 h-5 text-brand-lavender flex-shrink-0 mt-0.5" />
              <div>
                <span className="font-bold text-white block mb-0.5">Why this release strategy?</span>
                <span>
                  To deliver TKMingle to all TKMCE students freely and immediately without waiting for commercial app store memberships ($99/year Apple Developer Program, Play Console fees) or bureaucratic store approval delays. Direct APK + Safari PWA gives our student engineering team the freedom to ship updates in real time. Official store releases will be evaluated later.
                </span>
              </div>
            </div>
          </div>

          {/* Platform Switcher Tabs */}
          <div className="flex justify-center">
            <div className="inline-flex p-1 rounded-xl bg-brand-navySecondary border border-brand-border/80">
              <button
                onClick={() => setActivePlatformTab("android")}
                className={`px-5 py-2 rounded-lg text-xs font-bold transition-all flex items-center gap-2 ${
                  activePlatformTab === "android"
                    ? "bg-brand-purple text-white shadow-purple-glow"
                    : "text-brand-muted hover:text-white"
                }`}
              >
                <Smartphone className="w-4 h-4" />
                <span>Android (Universal APK)</span>
              </button>
              <button
                onClick={() => setActivePlatformTab("ios")}
                className={`px-5 py-2 rounded-lg text-xs font-bold transition-all flex items-center gap-2 ${
                  activePlatformTab === "ios"
                    ? "bg-brand-purple text-white shadow-purple-glow"
                    : "text-brand-muted hover:text-white"
                }`}
              >
                <Apple className="w-4 h-4" />
                <span>iOS (Safari Web App)</span>
              </button>
            </div>
          </div>

          {/* Platform Setup Content */}
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-stretch">
            {/* ANDROID SETUP */}
            {activePlatformTab === "android" ? (
              <>
                {/* Android Primary Action Card */}
                <div className="lg:col-span-7 glass-panel rounded-2xl border border-brand-border/90 p-6 sm:p-8 space-y-6 flex flex-col justify-between shadow-2xl relative">
                  <div className="space-y-5">
                    {/* Status Banner */}
                    <div className="flex flex-wrap items-center justify-between gap-3 pb-4 border-b border-brand-border/60">
                      <div className="flex items-center gap-3">
                        <div className="w-12 h-12 rounded-xl bg-brand-purple/15 border border-brand-purple/40 flex items-center justify-center text-brand-lavender">
                          <Smartphone className="w-6 h-6 text-brand-purple" />
                        </div>
                        <div>
                          <div className="flex items-center gap-2">
                            <span className="font-extrabold text-lg text-white">
                              Android Universal APK
                            </span>
                            <span className="px-2.5 py-0.5 rounded-full bg-brand-purple/20 text-brand-lavender text-xs font-bold border border-brand-purple/40">
                              {latestRelease.version_name}
                            </span>
                          </div>
                          <span className="text-xs text-brand-muted">
                            Build Code {latestRelease.version_code} • Free Direct Download
                          </span>
                        </div>
                      </div>

                      <div className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md bg-brand-teal/10 border border-brand-teal/30 text-brand-teal text-[11px] font-medium">
                        <span className="w-2 h-2 rounded-full bg-brand-teal animate-pulse" />
                        Latest Active Build
                      </div>
                    </div>

                    <p className="text-xs text-brand-text/90 leading-relaxed">
                      Distributed directly via GitHub Releases. The app connects to Supabase on launch to verify version status and provides 1-tap in-app downloads when new builds are published.
                    </p>

                    {/* Primary Download Button */}
                    <div className="space-y-2 pt-1">
                      <a
                        href={latestRelease.download_url}
                        download
                        className="w-full py-4 px-6 rounded-xl bg-gradient-to-r from-brand-purple via-purple-600 to-indigo-600 hover:opacity-95 text-white font-bold text-base flex items-center justify-center gap-3 shadow-lg shadow-purple-900/40 transition-all hover:scale-[1.01]"
                      >
                        <Download className="w-5 h-5" />
                        <span>Download APK ({latestRelease.version_name})</span>
                      </a>
                      <p className="text-[11px] text-center text-brand-muted">
                        Universal APK (~61 MB) • Android 8.0 to Android 15
                      </p>
                    </div>

                    {/* Release Notes */}
                    <div className="space-y-2 pt-2">
                      <span className="text-[11px] font-bold text-white uppercase tracking-wider block">
                        Release Highlights:
                      </span>
                      <div className="p-3.5 rounded-xl bg-brand-navyCard border border-brand-border text-xs text-brand-text/90 leading-relaxed font-mono">
                        {latestRelease.changelog}
                      </div>
                    </div>

                    {/* SHA-256 Checksum */}
                    <div className="space-y-1.5 pt-2">
                      <div className="flex items-center justify-between text-xs">
                        <span className="text-[11px] font-semibold text-brand-muted uppercase tracking-wider">
                          SHA-256 Checksum
                        </span>
                        <button
                          onClick={copyChecksum}
                          className="inline-flex items-center gap-1 text-[11px] text-brand-teal hover:underline font-medium"
                        >
                          {copiedHash ? (
                            <>
                              <Check className="w-3 h-3" />
                              <span>Copied!</span>
                            </>
                          ) : (
                            <>
                              <Copy className="w-3 h-3" />
                              <span>Copy Hash</span>
                            </>
                          )}
                        </button>
                      </div>
                      <div className="p-2.5 rounded-lg bg-black/40 border border-brand-border/60 text-[11px] font-mono text-brand-lavender break-all select-all">
                        {latestRelease.sha256_checksum}
                      </div>
                    </div>
                  </div>

                  <div className="pt-4 border-t border-brand-border/60 flex items-center justify-between text-xs text-brand-muted">
                    <span>Direct GitHub CDN Delivery</span>
                    <a
                      href="https://github.com/creatorspara/tkmingle/releases"
                      target="_blank"
                      rel="noreferrer"
                      className="text-brand-lavender hover:text-white transition-colors flex items-center gap-1 font-medium"
                    >
                      GitHub Releases <ExternalLink className="w-3 h-3" />
                    </a>
                  </div>
                </div>

                {/* Android Installation Instructions Card */}
                <div className="lg:col-span-5 glass-panel rounded-2xl border border-brand-border/80 p-6 sm:p-8 space-y-6 flex flex-col justify-between shadow-lg">
                  <div className="space-y-4">
                    <h3 className="text-base font-bold text-white flex items-center gap-2">
                      <ShieldCheck className="w-5 h-5 text-brand-teal" />
                      Android Installation Guide
                    </h3>
                    <p className="text-xs text-brand-muted leading-relaxed">
                      Follow these 4 simple steps to install the APK file on your Android device:
                    </p>

                    <div className="space-y-3.5 pt-1">
                      <div className="flex items-start gap-3">
                        <div className="w-6 h-6 rounded-full bg-brand-purple/20 text-brand-purple flex items-center justify-center text-xs font-bold flex-shrink-0 mt-0.5">
                          1
                        </div>
                        <div>
                          <h4 className="text-xs font-bold text-white">Download APK</h4>
                          <p className="text-xs text-brand-muted leading-relaxed">
                            Tap the download button to save <code className="text-brand-lavender bg-black/30 px-1 py-0.5 rounded">tkmmingle-k1-release.apk</code> to your phone.
                          </p>
                        </div>
                      </div>

                      <div className="flex items-start gap-3">
                        <div className="w-6 h-6 rounded-full bg-brand-purple/20 text-brand-purple flex items-center justify-center text-xs font-bold flex-shrink-0 mt-0.5">
                          2
                        </div>
                        <div>
                          <h4 className="text-xs font-bold text-white">Open the Downloaded File</h4>
                          <p className="text-xs text-brand-muted leading-relaxed">
                            Open your browser&apos;s Downloads list or tap the download complete notification.
                          </p>
                        </div>
                      </div>

                      <div className="flex items-start gap-3">
                        <div className="w-6 h-6 rounded-full bg-brand-teal/20 text-brand-teal flex items-center justify-center text-xs font-bold flex-shrink-0 mt-0.5">
                          3
                        </div>
                        <div>
                          <h4 className="text-xs font-bold text-white">Allow Unknown Sources Prompt</h4>
                          <p className="text-xs text-brand-muted leading-relaxed">
                            When Android shows &quot;For your security, your phone is not allowed to install unknown apps from this source&quot;, tap <strong>Settings</strong> and toggle <strong>Allow from this source</strong>.
                          </p>
                        </div>
                      </div>

                      <div className="flex items-start gap-3">
                        <div className="w-6 h-6 rounded-full bg-brand-lavender/20 text-brand-lavender flex items-center justify-center text-xs font-bold flex-shrink-0 mt-0.5">
                          4
                        </div>
                        <div>
                          <h4 className="text-xs font-bold text-white">Install and Open</h4>
                          <p className="text-xs text-brand-muted leading-relaxed">
                            Tap <strong>Install</strong>. Once completed, open TKMingle and sign in with your TKMCE institutional credentials.
                          </p>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div className="p-3.5 rounded-xl bg-brand-navySecondary border border-brand-border/60 text-xs text-brand-muted">
                    <strong className="text-white block mb-1">Single Latest Release Policy:</strong>
                    Older APK versions are automatically retired to protect student privacy and ensure real-time messaging sync.
                  </div>
                </div>
              </>
            ) : (
              <>
                {/* IOS PWA SETUP */}
                <div className="lg:col-span-7 glass-panel rounded-2xl border border-brand-border/90 p-6 sm:p-8 space-y-6 flex flex-col justify-between shadow-2xl relative">
                  <div className="space-y-5">
                    {/* Status Banner */}
                    <div className="flex flex-wrap items-center justify-between gap-3 pb-4 border-b border-brand-border/60">
                      <div className="flex items-center gap-3">
                        <div className="w-12 h-12 rounded-xl bg-brand-purple/15 border border-brand-purple/40 flex items-center justify-center text-brand-lavender">
                          <Apple className="w-6 h-6 text-brand-lavender" />
                        </div>
                        <div>
                          <div className="flex items-center gap-2">
                            <span className="font-extrabold text-lg text-white">
                              iOS Safari Web App (PWA)
                            </span>
                            <span className="px-2.5 py-0.5 rounded-full bg-brand-teal/20 text-brand-teal text-xs font-bold border border-brand-teal/40">
                              Standalone
                            </span>
                          </div>
                          <span className="text-xs text-brand-muted">
                            iOS 14.0+ • iPhone &amp; iPad • Add to Home Screen
                          </span>
                        </div>
                      </div>

                      <div className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md bg-brand-lavender/10 border border-brand-lavender/30 text-brand-lavender text-[11px] font-medium">
                        Instant Access
                      </div>
                    </div>

                    <p className="text-xs text-brand-text/90 leading-relaxed">
                      Install TKMingle directly to your iPhone or iPad home screen via Safari. Runs in full-screen standalone mode without URL bars, delivering an authentic app experience without requiring Apple&apos;s $99/year developer membership or App Store publishing.
                    </p>

                    {/* Quick Access CTA Buttons */}
                    <div className="space-y-2.5 pt-1">
                      <div className="flex flex-col sm:flex-row gap-3">
                        <Link
                          href="/login"
                          className="flex-1 py-3.5 px-5 rounded-xl bg-gradient-to-r from-brand-purple to-purple-600 hover:opacity-95 text-white font-bold text-sm flex items-center justify-center gap-2.5 shadow-purple-glow transition-all"
                        >
                          <Globe className="w-4 h-4" />
                          <span>Open Web Portal in Safari</span>
                        </Link>
                        <button
                          onClick={copyPwaLink}
                          className="py-3.5 px-5 rounded-xl bg-brand-navyCard hover:bg-brand-navySecondary border border-brand-border text-white text-xs font-semibold flex items-center justify-center gap-2 transition-colors"
                        >
                          {copiedPwaUrl ? <Check className="w-4 h-4 text-brand-teal" /> : <Copy className="w-4 h-4 text-brand-muted" />}
                          <span>{copiedPwaUrl ? "URL Copied!" : "Copy Safari URL"}</span>
                        </button>
                      </div>
                      <p className="text-[11px] text-center text-brand-muted">
                        Official URL: <code className="text-brand-lavender">https://tkmingle.vercel.app</code>
                      </p>
                    </div>

                    {/* PWA Capabilities */}
                    <div className="space-y-2 pt-2">
                      <span className="text-[11px] font-bold text-white uppercase tracking-wider block">
                        PWA Capabilities on iOS:
                      </span>
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs text-brand-muted">
                        <div className="p-3 rounded-xl bg-brand-navyCard border border-brand-border">
                          <strong className="text-white block mb-0.5">Standalone Viewport</strong>
                          <span>Hides Safari navigation bars and toolbars for full-screen focus.</span>
                        </div>
                        <div className="p-3 rounded-xl bg-brand-navyCard border border-brand-border">
                          <strong className="text-white block mb-0.5">Home Screen Icon</strong>
                          <span>High-resolution Apple Touch Icon branded for iOS Home Screen.</span>
                        </div>
                        <div className="p-3 rounded-xl bg-brand-navyCard border border-brand-border">
                          <strong className="text-white block mb-0.5">Realtime Messaging</strong>
                          <span>Live Supabase WebSockets for cross-branch chat and notifications.</span>
                        </div>
                        <div className="p-3 rounded-xl bg-brand-navyCard border border-brand-border">
                          <strong className="text-white block mb-0.5">Instant Updates</strong>
                          <span>Zero update delays. Always loads the latest web platform build.</span>
                        </div>
                      </div>
                    </div>

                    {/* Honest Transparency Disclaimer */}
                    <div className="p-3.5 rounded-xl bg-brand-navySecondary/80 border border-brand-border/60 text-xs text-brand-muted flex items-start gap-2.5">
                      <Info className="w-4 h-4 text-brand-lavender flex-shrink-0 mt-0.5" />
                      <span>
                        <strong className="text-white">Note:</strong> TKMingle on iOS runs as an installable Progressive Web App (PWA) using Apple WebKit. It is not an App Store listing.
                      </span>
                    </div>
                  </div>

                  <div className="pt-4 border-t border-brand-border/60 flex items-center justify-between text-xs text-brand-muted">
                    <span>Configured Manifest: <code>/manifest.webmanifest</code></span>
                    <span className="text-brand-teal font-medium">Standalone Enabled</span>
                  </div>
                </div>

                {/* iOS Installation Instructions Card */}
                <div className="lg:col-span-5 glass-panel rounded-2xl border border-brand-border/80 p-6 sm:p-8 space-y-6 flex flex-col justify-between shadow-lg">
                  <div className="space-y-4">
                    <h3 className="text-base font-bold text-white flex items-center gap-2">
                      <Apple className="w-5 h-5 text-brand-lavender" />
                      iOS Safari Installation Guide
                    </h3>
                    <p className="text-xs text-brand-muted leading-relaxed">
                      Follow these 5 steps to add TKMingle to your iPhone home screen:
                    </p>

                    <div className="space-y-3.5 pt-1">
                      <div className="flex items-start gap-3">
                        <div className="w-6 h-6 rounded-full bg-brand-purple/20 text-brand-purple flex items-center justify-center text-xs font-bold flex-shrink-0 mt-0.5">
                          1
                        </div>
                        <div>
                          <h4 className="text-xs font-bold text-white">Open in Safari</h4>
                          <p className="text-xs text-brand-muted leading-relaxed">
                            Open <code className="text-brand-lavender bg-black/30 px-1 py-0.5 rounded">https://tkmingle.vercel.app</code> in <strong>Safari</strong> (Chrome/Firefox on iOS do not support Add to Home Screen).
                          </p>
                        </div>
                      </div>

                      <div className="flex items-start gap-3">
                        <div className="w-6 h-6 rounded-full bg-brand-purple/20 text-brand-purple flex items-center justify-center text-xs font-bold flex-shrink-0 mt-0.5">
                          2
                        </div>
                        <div>
                          <h4 className="text-xs font-bold text-white">Tap the Share Button</h4>
                          <p className="text-xs text-brand-muted leading-relaxed">
                            Tap the <strong>Share</strong> button (the square icon with an upward-pointing arrow) in Safari&apos;s bottom toolbar.
                          </p>
                        </div>
                      </div>

                      <div className="flex items-start gap-3">
                        <div className="w-6 h-6 rounded-full bg-brand-teal/20 text-brand-teal flex items-center justify-center text-xs font-bold flex-shrink-0 mt-0.5">
                          3
                        </div>
                        <div>
                          <h4 className="text-xs font-bold text-white">Select &quot;Add to Home Screen&quot;</h4>
                          <p className="text-xs text-brand-muted leading-relaxed">
                            Scroll down the action list and select <strong>Add to Home Screen</strong>.
                          </p>
                        </div>
                      </div>

                      <div className="flex items-start gap-3">
                        <div className="w-6 h-6 rounded-full bg-brand-lavender/20 text-brand-lavender flex items-center justify-center text-xs font-bold flex-shrink-0 mt-0.5">
                          4
                        </div>
                        <div>
                          <h4 className="text-xs font-bold text-white">Confirm Add</h4>
                          <p className="text-xs text-brand-muted leading-relaxed">
                            Ensure the name displays as <strong>TKMingle</strong>, then tap <strong>Add</strong> in the top-right corner.
                          </p>
                        </div>
                      </div>

                      <div className="flex items-start gap-3">
                        <div className="w-6 h-6 rounded-full bg-brand-teal/20 text-brand-teal flex items-center justify-center text-xs font-bold flex-shrink-0 mt-0.5">
                          5
                        </div>
                        <div>
                          <h4 className="text-xs font-bold text-white">Open from Home Screen</h4>
                          <p className="text-xs text-brand-muted leading-relaxed">
                            Tap the TKMingle app icon on your home screen. It will launch in full-screen standalone mode.
                          </p>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div className="p-3.5 rounded-xl bg-brand-navySecondary border border-brand-border/60 text-xs text-brand-muted">
                    <strong className="text-white block mb-1">Campus Verification:</strong>
                    Log in with your college email. Sessions persist securely in your device&apos;s encrypted browser storage.
                  </div>
                </div>
              </>
            )}
          </div>
        </div>
      </section>

      {/* 4. DISCOVER PEOPLE SECTION */}
      <section id="discover" className="py-16 bg-brand-navySecondary/40 border-b border-brand-border/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-10">
          <div className="text-center max-w-2xl mx-auto space-y-3">
            <h2 className="text-2xl sm:text-3xl font-extrabold text-white">
              Connect across departments
            </h2>
            <p className="text-sm text-brand-muted">
              Discover students with shared technical and creative interests across all TKMCE branches.
            </p>
          </div>

          {/* Student Profile Cards */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5">
            {students.map((student) => (
              <div
                key={student.id}
                className="glass-panel rounded-tk-card p-5 flex flex-col justify-between space-y-4 border border-brand-border/70 hover:border-brand-purple/50 transition-colors"
              >
                <div className="space-y-3">
                  <div className="flex items-center gap-3">
                    <UserAvatar
                      src={student.profile_image}
                      name={student.full_name}
                      size={48}
                      className="rounded-xl border border-brand-border"
                    />
                    <div className="min-w-0 flex-1">
                      <h3 className="font-bold text-sm text-white truncate flex items-center gap-1.5">
                        {student.full_name}
                        <CheckCircle2 className="w-3.5 h-3.5 text-brand-teal flex-shrink-0" />
                      </h3>
                      <p className="text-xs text-brand-muted truncate">{student.department}</p>
                      <span className="text-[10px] text-brand-lavender font-medium">
                        {student.academic_year}
                      </span>
                    </div>
                  </div>

                  <p className="text-xs text-brand-text/90 line-clamp-3 leading-relaxed">
                    {student.bio}
                  </p>

                  <div className="flex flex-wrap gap-1.5 pt-1">
                    {student.interests.slice(0, 3).map((interest) => (
                      <span
                        key={interest}
                        className="text-[10px] px-2 py-0.5 rounded-md bg-brand-navySecondary border border-brand-border text-brand-lavender font-medium"
                      >
                        {interest}
                      </span>
                    ))}
                  </div>
                </div>

                <div className="pt-2 border-t border-brand-border/40">
                  <div className="text-[11px] text-brand-muted flex items-center gap-1.5 mb-2.5">
                    <GraduationCap className="w-3.5 h-3.5 text-brand-teal" />
                    <span className="truncate">{student.availability}</span>
                  </div>
                  <Link
                    href={sessionUser ? "/app/discover" : "/register"}
                    className="w-full py-1.5 rounded-tk-btn bg-brand-navyCard hover:bg-brand-purple border border-brand-border hover:border-brand-purple text-xs font-medium text-white transition-colors flex items-center justify-center gap-1.5"
                  >
                    <Users2 className="w-3.5 h-3.5" />
                    Connect
                  </Link>
                </div>
              </div>
            ))}
          </div>

          <div className="text-center pt-2">
            <Link
              href={sessionUser ? "/app/discover" : "/login"}
              className="inline-flex items-center gap-1.5 text-xs font-semibold text-brand-lavender hover:text-white transition-colors"
            >
              {sessionUser
                ? "Browse all students in campus directory"
                : "Sign in to browse all students in directory"}
              <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          </div>
        </div>
      </section>

      {/* 5. CAMPUS CIRCLES SECTION */}
      <section id="circles" className="py-16 bg-brand-navy border-b border-brand-border/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-10">
          <div className="text-center max-w-2xl mx-auto space-y-3">
            <h2 className="text-2xl sm:text-3xl font-extrabold text-white">
              Campus Circles
            </h2>
            <p className="text-sm text-brand-muted">
              Student-run circles for clubs, technical teams, and campus initiatives.
            </p>
          </div>

          {/* Circles Grid */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
            {MOCK_CIRCLES.slice(0, 3).map((circle) => (
              <div
                key={circle.id}
                className="glass-panel rounded-tk-card p-5 flex flex-col justify-between space-y-4 border border-brand-border/70 hover:border-brand-purple/40 transition-colors"
              >
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <div className="w-10 h-10 rounded-xl bg-brand-purple/15 text-brand-lavender flex items-center justify-center font-bold text-base border border-brand-purple/30">
                      {circle.name.charAt(0)}
                    </div>
                    <span className="text-xs px-2 py-0.5 rounded-full bg-brand-navyCard border border-brand-border text-brand-teal font-medium">
                      {circle.category}
                    </span>
                  </div>
                  <div>
                    <h3 className="font-bold text-base text-white">{circle.name}</h3>
                    <p className="text-xs text-brand-muted mt-1 leading-relaxed">
                      {circle.description}
                    </p>
                  </div>
                </div>

                <div className="pt-3 border-t border-brand-border/60 flex items-center justify-between text-xs">
                  <span className="text-brand-muted font-medium">
                    {circle.member_count} Members
                  </span>
                  <Link
                    href={sessionUser ? "/app/circles" : "/register"}
                    className="text-brand-teal hover:underline font-medium flex items-center gap-1"
                  >
                    View Circle <ArrowRight className="w-3 h-3" />
                  </Link>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* 6. CONNECT AND CHAT SECTION */}
      <section id="connect" className="py-16 bg-brand-navySecondary/40 border-b border-brand-border/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-10 items-center">
            <div className="lg:col-span-6 space-y-5">
              <h2 className="text-2xl sm:text-3xl font-extrabold text-white">
                Mutual consent communication
              </h2>
              <p className="text-sm text-brand-muted leading-relaxed">
                Direct messaging is enabled only after both students accept a connection request. No unsolicited messages or contact sharing without your permission.
              </p>

              <div className="space-y-3 pt-1">
                <div className="flex items-start gap-3">
                  <div className="w-7 h-7 rounded-lg bg-brand-purple/20 text-brand-purple flex items-center justify-center flex-shrink-0 mt-0.5">
                    <CheckCircle2 className="w-4 h-4" />
                  </div>
                  <div>
                    <h4 className="text-xs font-semibold text-white">Mutual Approval</h4>
                    <p className="text-xs text-brand-muted">Both students must accept before direct chat opens.</p>
                  </div>
                </div>

                <div className="flex items-start gap-3">
                  <div className="w-7 h-7 rounded-lg bg-brand-teal/20 text-brand-teal flex items-center justify-center flex-shrink-0 mt-0.5">
                    <Lock className="w-4 h-4" />
                  </div>
                  <div>
                    <h4 className="text-xs font-semibold text-white">Private &amp; Direct</h4>
                    <p className="text-xs text-brand-muted">Only the two participants can view conversations.</p>
                  </div>
                </div>

                <div className="flex items-start gap-3">
                  <div className="w-7 h-7 rounded-lg bg-brand-lavender/20 text-brand-lavender flex items-center justify-center flex-shrink-0 mt-0.5">
                    <Users2 className="w-4 h-4" />
                  </div>
                  <div>
                    <h4 className="text-xs font-semibold text-white">Instant Block &amp; Report</h4>
                    <p className="text-xs text-brand-muted">Control your contacts and manage privacy at any time.</p>
                  </div>
                </div>
              </div>
            </div>

            {/* Chat Mockup Card */}
            <div className="lg:col-span-6">
              <div className="glass-panel rounded-2xl border border-brand-border p-5 space-y-3 max-w-md mx-auto shadow-2xl">
                <div className="flex items-center gap-3 pb-3 border-b border-brand-border/60">
                  <UserAvatar
                    src="preset:tk_avatar_03"
                    name="Devika S."
                    size={36}
                    isOnline={true}
                  />
                  <div>
                    <div className="font-bold text-xs text-white flex items-center gap-1.5">
                      Devika S.
                      <span className="w-2 h-2 rounded-full bg-brand-teal inline-block" />
                    </div>
                    <div className="text-[10px] text-brand-muted">Active • Robotics &amp; AI 3rd Year</div>
                  </div>
                </div>

                <div className="space-y-2.5 py-1">
                  <div className="flex flex-col items-start">
                    <div className="bg-brand-navyCard border border-brand-border/80 px-3 py-2 rounded-xl text-xs text-brand-text max-w-[85%]">
                      Hey! Saw your project post in Robotics &amp; AI Club.
                    </div>
                  </div>

                  <div className="flex flex-col items-end">
                    <div className="bg-brand-purple px-3 py-2 rounded-xl text-xs text-white max-w-[85%]">
                      Hey Devika! Yes, looking for someone for the IoT hardware and autonomous navigation track.
                    </div>
                  </div>

                  <div className="flex flex-col items-start">
                    <div className="bg-brand-navyCard border border-brand-border/80 px-3 py-2 rounded-xl text-xs text-brand-text max-w-[85%]">
                      Count me in! Let&apos;s meet near the Nescafe corner after 4:30.
                    </div>
                  </div>
                </div>

                <div className="pt-2 flex items-center gap-2">
                  <div className="flex-1 py-1.5 px-3 rounded-tk-btn bg-brand-navyCard border border-brand-border text-xs text-brand-muted">
                    Type a message...
                  </div>
                  <button className="p-1.5 rounded-tk-btn bg-brand-purple text-white">
                    <ArrowRight className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 7. EQUIPO KROMIUM BRAND INTEGRATION SECTION */}
      <section id="kromium" className="py-20 bg-gradient-to-b from-[#090C15] to-brand-navy border-b border-brand-border/60 relative overflow-hidden">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-12">
          {/* Section Header */}
          <div className="text-center max-w-2xl mx-auto space-y-3">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#1C1C28] border border-white/10 text-xs font-semibold text-brand-lavender">
              <Code2 className="w-3.5 h-3.5 text-brand-purple" />
              <span>Engineering &amp; Product Collective • TKMCE</span>
            </div>
            <h2 className="text-2xl sm:text-4xl font-extrabold text-white tracking-tight">
              Designed &amp; Engineered by Equipo Kromium
            </h2>
            <p className="text-sm text-brand-muted leading-relaxed">
              Equipo Kromium is an engineering and design collective born inside TKM College of Engineering, dedicated to crafting open-source, high-performance software for the student community.
            </p>
          </div>

          {/* Kromium Hero Visual Banner */}
          <div className="rounded-2xl border border-white/10 overflow-hidden shadow-2xl relative bg-[#0D0E1A]">
            <Image
              src="/images/kromium/kromium_hero_banner_2x.png"
              alt="Equipo Kromium - Build Open Share"
              width={1600}
              height={500}
              className="w-full h-auto object-cover"
              priority
            />
          </div>

          {/* Kromium Core Pillars */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="glass-panel rounded-2xl border border-white/10 p-6 space-y-3">
              <div className="w-10 h-10 rounded-xl bg-brand-purple/20 border border-brand-purple/40 flex items-center justify-center text-brand-lavender">
                <Code2 className="w-5 h-5" />
              </div>
              <h3 className="text-base font-bold text-white">Open-Source First</h3>
              <p className="text-xs text-brand-muted leading-relaxed">
                Full transparency with public repositories, clean modular architecture, and continuous community contributions.
              </p>
            </div>

            <div className="glass-panel rounded-2xl border border-white/10 p-6 space-y-3">
              <div className="w-10 h-10 rounded-xl bg-brand-teal/20 border border-brand-teal/40 flex items-center justify-center text-brand-teal">
                <Cpu className="w-5 h-5" />
              </div>
              <h3 className="text-base font-bold text-white">High-Performance Stack</h3>
              <p className="text-xs text-brand-muted leading-relaxed">
                Native Flutter mobile application, Next.js 14 Web Portal, Supabase Postgres, and Edge Functions.
              </p>
            </div>

            <div className="glass-panel rounded-2xl border border-white/10 p-6 space-y-3">
              <div className="w-10 h-10 rounded-xl bg-brand-lavender/20 border border-brand-lavender/40 flex items-center justify-center text-brand-lavender">
                <ShieldCheck className="w-5 h-5" />
              </div>
              <h3 className="text-base font-bold text-white">Campus Privacy by Design</h3>
              <p className="text-xs text-brand-muted leading-relaxed">
                Zero unsolicited spam, end-to-end access rules, and verified TKMCE institutional authentication.
              </p>
            </div>
          </div>

          {/* Action CTAs */}
          <div className="text-center pt-2 flex flex-wrap items-center justify-center gap-4">
            <Link
              href="/team"
              className="px-6 py-3 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white font-semibold text-xs flex items-center gap-2 shadow-purple-glow transition-all"
            >
              Meet Equipo Kromium <ArrowRight className="w-3.5 h-3.5" />
            </Link>
            <button
              onClick={() => {
                setContactCategory("Collaborate with Kromium");
                setContactModalOpen(true);
              }}
              className="px-6 py-3 rounded-tk-btn bg-brand-navyCard hover:bg-brand-navySecondary border border-brand-border text-white font-semibold text-xs transition-all"
            >
              Collaborate with Us
            </button>
            <a
              href="https://github.com/creatorspara/tkmingle"
              target="_blank"
              rel="noreferrer"
              className="px-5 py-3 rounded-tk-btn border border-brand-border/70 hover:border-white/30 text-brand-muted hover:text-white font-semibold text-xs flex items-center gap-1.5 transition-colors"
            >
              GitHub Repository <ExternalLink className="w-3 h-3" />
            </a>
          </div>
        </div>
      </section>

      {/* 8. FAQ SECTION */}
      <section id="faq" className="py-16 bg-brand-navy border-b border-brand-border/50">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 space-y-6">
          <div className="text-center space-y-2">
            <h2 className="text-2xl sm:text-3xl font-extrabold text-white">
              Frequently Asked Questions
            </h2>
            <p className="text-xs text-brand-muted">
              Common questions about joining, installing, and using TKMingle.
            </p>
          </div>

          <div className="space-y-3 pt-2">
            {faqs.map((faq, index) => {
              const isOpen = openFaqIndex === index;
              return (
                <div
                  key={faq.q}
                  className="glass-panel rounded-xl border border-brand-border overflow-hidden"
                >
                  <button
                    onClick={() => setOpenFaqIndex(isOpen ? null : index)}
                    className="w-full p-4 text-left flex items-center justify-between font-semibold text-white hover:text-brand-lavender text-xs sm:text-sm transition-colors"
                  >
                    <span>{faq.q}</span>
                    <ChevronDown
                      className={`w-4 h-4 text-brand-muted transition-transform duration-200 ${
                        isOpen ? "rotate-180 text-brand-purple" : ""
                      }`}
                    />
                  </button>
                  {isOpen && (
                    <div className="px-4 pb-4 text-xs text-brand-muted leading-relaxed border-t border-brand-border/40 pt-2.5">
                      {faq.a}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* 9. BOTTOM COMMUNITY / COLLABORATE SECTION */}
      <section className="py-16 bg-brand-navySecondary/60 border-b border-brand-border/60">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center space-y-5">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-brand-navyCard border border-brand-border text-xs font-semibold text-brand-lavender">
            <Sparkles className="w-3.5 h-3.5 text-brand-purple" />
            <span>Community Collaboration</span>
          </div>

          <h2 className="text-2xl sm:text-3xl font-extrabold text-white">
            Have an idea or want to collaborate with Team Kromium?
          </h2>

          <p className="text-sm text-brand-muted max-w-2xl mx-auto leading-relaxed">
            TKMingle is built for the TKMCE student community. Have suggestions, found an issue, or want to contribute code or design? You can write to us anonymously or with your campus handle.
          </p>

          <div className="pt-2 flex flex-wrap items-center justify-center gap-3">
            <button
              onClick={() => {
                setContactCategory("Collaborate with Kromium");
                setContactModalOpen(true);
              }}
              className="px-6 py-2.5 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white text-xs font-semibold shadow-purple-glow transition-all"
            >
              Contact Team Kromium
            </button>
            <a
              href="mailto:tkmmingle@gmail.com?subject=TKMingle%20Community%20Inquiry"
              className="px-6 py-2.5 rounded-tk-btn bg-brand-navyCard hover:bg-brand-navySecondary border border-brand-border text-white text-xs font-semibold transition-all flex items-center gap-1.5"
            >
              <Mail className="w-3.5 h-3.5 text-brand-purple" />
              Email tkmmingle@gmail.com
            </a>
          </div>
        </div>
      </section>

      {/* 10. FOOTER */}
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
                Campus social discovery platform for TKM College of Engineering, Kollam, Kerala. Designed &amp; Engineered with passion by Equipo Kromium.
              </p>
            </div>

            <div className="space-y-2">
              <h4 className="text-xs font-bold uppercase tracking-wider text-white">Platform &amp; Apps</h4>
              <ul className="space-y-1.5 text-xs text-brand-muted">
                <li><a href="#download" onClick={() => setActivePlatformTab("android")} className="text-brand-teal hover:underline flex items-center gap-1"><Smartphone className="w-3 h-3" /> Android APK ({latestRelease.version_name})</a></li>
                <li><a href="#download" onClick={() => setActivePlatformTab("ios")} className="text-brand-lavender hover:underline flex items-center gap-1"><Apple className="w-3 h-3" /> iOS Safari Web App</a></li>
                <li><a href="#discover" className="hover:text-white transition-colors">Discover Students</a></li>
                <li><a href="#circles" className="hover:text-white transition-colors">Campus Circles</a></li>
                <li><a href="#connect" className="hover:text-white transition-colors">Connect &amp; Chat</a></li>
                <li>
                  <Link href={sessionUser ? "/app/discover" : "/login"} className="hover:text-white transition-colors">
                    {sessionUser ? "Campus Portal" : "Student Login"}
                  </Link>
                </li>
              </ul>
            </div>

            <div className="space-y-2">
              <h4 className="text-xs font-bold uppercase tracking-wider text-white">Equipo Kromium</h4>
              <ul className="space-y-1.5 text-xs text-brand-muted">
                <li>
                  <Link
                    href="/team"
                    className="text-brand-lavender hover:text-white transition-colors font-medium flex items-center gap-1"
                  >
                    Meet the Team <ArrowRight className="w-3 h-3 text-brand-purple" />
                  </Link>
                </li>
                <li><span className="text-brand-muted">tkmmingle@gmail.com</span></li>
                <li><span className="text-brand-text">TKMCE, Karicode, Kollam</span></li>
                <li><span className="text-brand-muted">Kerala 691005</span></li>
              </ul>
            </div>
          </div>

          <div className="pt-6 border-t border-brand-border/60 flex flex-col sm:flex-row items-center justify-between text-xs text-brand-muted gap-3">
            <p>&copy; 2026 TKMingle &bull; Designed &amp; Engineered by Equipo Kromium &bull; TKM College of Engineering.</p>
            <div className="flex items-center gap-5">
              <a href="#download" className="hover:text-white transition-colors">Get App</a>
              <a href="#faq" className="hover:text-white transition-colors">FAQ</a>
              <button
                onClick={() => setContactModalOpen(true)}
                className="hover:text-white transition-colors"
              >
                Feedback
              </button>
            </div>
          </div>
        </div>
      </footer>

      {/* 11. ANONYMOUS CONTACT & COLLABORATE MODAL */}
      {contactModalOpen && (
        <div className="fixed inset-0 z-50 bg-black/75 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-brand-navySecondary border border-brand-border rounded-2xl max-w-lg w-full p-6 space-y-4 relative shadow-2xl animate-in fade-in zoom-in-95 duration-150">
            <button
              onClick={() => {
                if (!contactSubmitting) {
                  setContactModalOpen(false);
                  setContactSuccess(false);
                }
              }}
              className="absolute top-4 right-4 p-1.5 text-brand-muted hover:text-white rounded-lg hover:bg-brand-navyCard"
              aria-label="Close modal"
            >
              <X className="w-5 h-5" />
            </button>

            <div className="space-y-1">
              <h3 className="text-lg font-bold text-white flex items-center gap-2">
                <Mail className="w-5 h-5 text-brand-purple" />
                Contact Team Kromium
              </h3>
              <p className="text-xs text-brand-muted">
                Your message is safely forwarded to <span className="text-brand-teal font-medium">tkmmingle@gmail.com</span>. You may submit anonymously or with your details.
              </p>
            </div>

            {contactSuccess ? (
              <div className="py-8 text-center space-y-3">
                <div className="w-12 h-12 rounded-full bg-brand-teal/20 text-brand-teal mx-auto flex items-center justify-center">
                  <CheckCircle2 className="w-6 h-6" />
                </div>
                <h4 className="text-base font-bold text-white">Message Dispatched!</h4>
                <p className="text-xs text-brand-muted max-w-sm mx-auto">
                  Your inquiry has been forwarded directly to <span className="text-brand-lavender font-semibold">tkmmingle@gmail.com</span> and recorded in the team database.
                </p>
                <div className="pt-2 flex flex-col items-center gap-2">
                  <a
                    href={contactMailto || "mailto:tkmmingle@gmail.com"}
                    className="text-xs text-brand-teal hover:underline flex items-center gap-1 font-medium"
                  >
                    <Mail className="w-3.5 h-3.5" />
                    Open in your email client &rarr;
                  </a>
                </div>
              </div>
            ) : (
              <form onSubmit={handleContactSubmit} className="space-y-3 pt-1">
                <div>
                  <label className="block text-[11px] font-semibold text-brand-muted uppercase tracking-wider mb-1">
                    Topic
                  </label>
                  <select
                    value={contactCategory}
                    onChange={(e) => setContactCategory(e.target.value)}
                    className="w-full px-3 py-2 rounded-tk-btn bg-brand-navy border border-brand-border text-xs text-white focus:outline-none focus:border-brand-purple"
                  >
                    <option value="Suggestions & Feedback">Suggestions &amp; Ideas</option>
                    <option value="Feature Request">Feature Request</option>
                    <option value="Report an Issue">Report an Issue / Bug</option>
                    <option value="Collaborate with Kromium">Collaborate with Equipo Kromium</option>
                  </select>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <div>
                    <label className="block text-[11px] font-semibold text-brand-muted uppercase tracking-wider mb-1">
                      Your Name <span className="text-brand-muted font-normal lowercase">(optional / anonymous)</span>
                    </label>
                    <input
                      type="text"
                      value={contactName}
                      onChange={(e) => setContactName(e.target.value)}
                      placeholder="Anonymous Student (or enter name)"
                      className="w-full px-3 py-2 rounded-tk-btn bg-brand-navy border border-brand-border text-xs text-white focus:outline-none focus:border-brand-purple"
                    />
                  </div>

                  <div>
                    <label className="block text-[11px] font-semibold text-brand-muted uppercase tracking-wider mb-1">
                      Email Address <span className="text-brand-muted font-normal lowercase">(optional)</span>
                    </label>
                    <input
                      type="email"
                      value={contactEmail}
                      onChange={(e) => setContactEmail(e.target.value)}
                      placeholder="name@tkmce.ac.in (or contact email)"
                      className="w-full px-3 py-2 rounded-tk-btn bg-brand-navy border border-brand-border text-xs text-white focus:outline-none focus:border-brand-purple"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-[11px] font-semibold text-brand-muted uppercase tracking-wider mb-1">
                    Department &amp; Year <span className="text-brand-muted font-normal lowercase">(optional)</span>
                  </label>
                  <input
                    type="text"
                    value={contactDept}
                    onChange={(e) => setContactDept(e.target.value)}
                    placeholder="e.g. Mechanical Engineering, 3rd Year"
                    className="w-full px-3 py-2 rounded-tk-btn bg-brand-navy border border-brand-border text-xs text-white focus:outline-none focus:border-brand-purple"
                  />
                </div>

                <div>
                  <label className="block text-[11px] font-semibold text-brand-muted uppercase tracking-wider mb-1">
                    Message <span className="text-brand-purple font-semibold">*</span>
                  </label>
                  <textarea
                    rows={4}
                    required
                    value={contactMessage}
                    onChange={(e) => setContactMessage(e.target.value)}
                    placeholder="Describe your idea, bug report, or how you would like to collaborate with Equipo Kromium..."
                    className="w-full p-3 rounded-tk-btn bg-brand-navy border border-brand-border text-xs text-white focus:outline-none focus:border-brand-purple"
                  />
                </div>

                <div className="pt-2 flex items-center justify-between">
                  <span className="text-[10px] text-brand-muted">
                    Forwarded to <code className="text-brand-lavender">tkmmingle@gmail.com</code>
                  </span>
                  <div className="flex items-center gap-2">
                    <button
                      type="button"
                      onClick={() => setContactModalOpen(false)}
                      className="px-4 py-2 rounded-tk-btn border border-brand-border text-xs text-brand-muted hover:text-white"
                    >
                      Cancel
                    </button>
                    <button
                      type="submit"
                      disabled={contactSubmitting}
                      className="px-5 py-2 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white text-xs font-semibold flex items-center gap-1.5 shadow-purple-glow"
                    >
                      <Send className="w-3.5 h-3.5" />
                      {contactSubmitting ? "Sending..." : "Submit Message"}
                    </button>
                  </div>
                </div>
              </form>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
