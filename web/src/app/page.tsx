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
  FileText,
  Coffee,
  Quote,
  EyeOff,
  Shuffle,
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
  version_name: "v2.0.0",
  version_code: 13,
  download_url: "https://github.com/creatorspara/tkmingle/releases/download/v2.0.0/tkmingle-v2-release.apk",
  changelog: "V2 Major Release: Spill the Tea campus whispers with 10 Malayalam pop culture icons, instant real-time chat sync, and performance enhancements.",
  sha256_checksum: "505CB75982A00B8FDEF2639D7E5BEA60AD1D9ECF9AE530E16B942F000E201504",
  published_at: "2026-11-22T23:08:14.325Z",
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
  const [allStudentsPool, setAllStudentsPool] = useState<DisplayStudent[]>(DEFAULT_STUDENTS);
  const [heroStudent, setHeroStudent] = useState<DisplayStudent>(DEFAULT_STUDENTS[0]);

  // Fisher-Yates random sampling function to ensure rich variety
  const pickRandomSample = (pool: DisplayStudent[]) => {
    if (!pool || pool.length === 0) return;
    const shuffled = [...pool];
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    setStudents(shuffled.slice(0, 4));
    setHeroStudent(shuffled[0]);
  };

  // Dynamic Latest Release State (Auto-updates with new builds)
  const [latestRelease, setLatestRelease] = useState<AppRelease>(DEFAULT_RELEASE);

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

  useEffect(() => {
    if (isLiveSupabaseConfigured()) {
      supabase.auth.getSession().then(({ data }) => {
        if (data?.session?.user) {
          setSessionUser(data.session.user);
        }
      });

      const { data: authListener } = supabase.auth.onAuthStateChange((_event, session) => {
        setSessionUser(session?.user ?? null);
      });

      // Fetch live discoverable profiles with full variety and connection suppression
      const loadLiveProfiles = async () => {
        try {
          const { data: authData } = await supabase.auth.getSession();
          const currentUserId = authData?.session?.user?.id;
          const connectedSet = new Set<string>();

          // Exclude already connected users if visitor is logged in
          if (currentUserId) {
            const { data: conns } = await supabase
              .from("connections")
              .select("user_one, user_two")
              .or(`user_one.eq.${currentUserId},user_two.eq.${currentUserId}`);
            if (conns) {
              conns.forEach((c: any) => {
                if (c.user_one && c.user_one !== currentUserId) connectedSet.add(c.user_one);
                if (c.user_two && c.user_two !== currentUserId) connectedSet.add(c.user_two);
              });
            }
          }

          const { data, error } = await supabase
            .from("profiles")
            .select("id, full_name, username, department, academic_year, bio, profile_image, avatar_id, interests, availability")
            .eq("discoverable", true)
            .not("full_name", "is", null)
            .limit(100);

          if (!error && data && data.length > 0) {
            const liveProfiles: DisplayStudent[] = data
              .filter((p: any) => {
                // Filter out self
                if (currentUserId && p.id === currentUserId) return false;
                // Filter out already established connections
                if (connectedSet.has(p.id)) return false;
                // Filter out test/audit bot records
                const lowerName = (p.full_name || "").toLowerCase();
                if (lowerName.includes("audit") || lowerName.startsWith("test account")) return false;
                return true;
              })
              .map((p: any) => ({
                id: p.id,
                full_name: p.full_name || "TKMCE Student",
                username: p.username || "student",
                department: p.department || "Engineering",
                academic_year: p.academic_year || "Student",
                bio: p.bio || `Student at TKM College of Engineering (${p.department || "TKMCE"}).`,
                profile_image: p.profile_image || (p.avatar_id ? `preset:${p.avatar_id}` : "preset:tk_avatar_01"),
                interests: Array.isArray(p.interests) && p.interests.length > 0 ? p.interests : ["Campus", "Engineering", "Technology"],
                availability: p.availability || "Available on campus",
              }));

            if (liveProfiles.length > 0) {
              setAllStudentsPool(liveProfiles);
              pickRandomSample(liveProfiles);
            }
          }
        } catch {
          // Keep default clean profiles
        }
      };
      loadLiveProfiles();

      // Fetch latest release dynamically from Supabase (or fallback to GitHub)
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
          console.warn("Release sync notice:", e);
        }
      };
      fetchLatestRelease();

      return () => {
        authListener?.subscription.unsubscribe();
      };
    }
  }, []);

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
      console.error("Contact inquiry notice:", err);
    } finally {
      setContactSubmitting(false);
      setContactSuccess(true);
      setTimeout(() => {
        setContactSuccess(false);
        setContactModalOpen(false);
        setContactMessage("");
        setContactName("");
        setContactEmail("");
      }, 3500);
    }
  };

  const faqs = [
    {
      q: "What is TKMingle?",
      a: "TKMingle is a student platform built for TKM College of Engineering (TKMCE), Kollam. It helps students connect across different departments based on shared interests, projects, and campus activities.",
    },
    {
      q: "How do I install TKMingle on Android?",
      a: `Download the APK (${latestRelease.version_name}) directly from the download section. Once downloaded, open the file. If Android prompts 'Install unknown apps', enable 'Allow from this source', then tap Install. Future updates are detected automatically when opening the app.`,
    },
    {
      q: "Is the Android APK safe? Has it been scanned for viruses or malware?",
      a: `Yes, 100%. Every APK release undergoes automated multi-engine malware analysis by OPSWAT MetaDefender across 21 enterprise antivirus engines (including Bitdefender, Sophos, ESET, SentinelOne, Trellix, ClamAV, AhnLab, Avira, and Quick Heal). The latest scan of tkmingle-v2-release.apk detected 0 threats (100% clean). You can inspect the engine verdicts or download the official MetaDefender Analysis Report PDF directly on our download section or Security Hub.`,
    },
    {
      q: "How do I install TKMingle on an iPhone (iOS)?",
      a: "Open https://tkmingle.vercel.app in Safari on your iPhone, tap the Share button (square with arrow at the bottom), and choose 'Add to Home Screen'. TKMingle will install directly to your home screen and run in full-screen standalone mode without browser bars.",
    },
    {
      q: "Why isn't TKMingle on Google Play or the Apple App Store?",
      a: "We distribute directly via GitHub Releases and Safari PWA to keep TKMingle completely free for students and avoid commercial developer fees ($99/year Apple Developer Program). Direct distribution also lets our student developer team fix bugs and deploy updates immediately. Store releases will be considered later.",
    },
    {
      q: "Who can join TKMingle?",
      a: "Access is limited to students and members of TKM College of Engineering. Accounts are verified using institutional credentials.",
    },
    {
      q: "How do student connections work?",
      a: "Connections require mutual consent. You can send a request with a brief note. Direct 1:1 messaging opens only after both students accept. Pending requests can be resent or cancelled at any time.",
    },
    {
      q: "Can I control my profile visibility?",
      a: "Yes. You can turn campus discovery on or off at any time in Settings. When discovery is turned off, your profile is hidden from the campus directory.",
    },
    {
      q: "What are Campus Circles?",
      a: "Circles are campus communities for clubs, technical teams, sports, and interests where students post updates and organize activities.",
    },
  ];

  return (
    <div className="min-h-screen bg-brand-navy text-brand-text flex flex-col selection:bg-brand-purple selection:text-white">
      {/* 1. NAVBAR */}
      <header className="sticky top-0 z-50 bg-brand-navy/90 backdrop-blur-md border-b border-brand-border/60">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-18 flex items-center justify-between">
          {/* Brand Logo */}
          <Link href="/" className="flex items-center gap-3 flex-shrink-0">
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

          {/* Desktop Navigation - Clean, un-crammed layout */}
          <nav className="hidden lg:flex items-center gap-8 text-sm font-medium text-brand-muted">
            <a href="#discover" className="hover:text-white transition-colors">
              Discover
            </a>
            <a href="#circles" className="hover:text-white transition-colors">
              Campus Circles
            </a>
            <a href="#kromium" className="hover:text-white transition-colors flex items-center gap-1 text-brand-lavender font-medium">
              Equipo Kromium
            </a>
            <a href="#faq" className="hover:text-white transition-colors">
              FAQ
            </a>
          </nav>

          {/* Action CTAs */}
          <div className="hidden md:flex items-center gap-3">
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
                  className="px-4 py-2 text-sm font-semibold rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white transition-colors shadow-purple-glow"
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
              href="#circles"
              onClick={() => setMobileMenuOpen(false)}
              className="block text-sm font-medium text-brand-muted hover:text-white"
            >
              Campus Circles
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
                Download Android APK ({latestRelease.version_name})
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
      <section className="relative pt-12 pb-16 md:pt-20 md:pb-24 border-b border-brand-border/60">
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

              {/* Action Buttons */}
              <div className="pt-2 flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-3">
                <a
                  href={latestRelease.download_url}
                  download
                  className="w-full sm:w-auto px-5 py-3 text-sm font-bold rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white transition-colors flex items-center justify-center gap-2 shadow-purple-glow"
                >
                  <Download className="w-4 h-4" />
                  <span>Download APK (Android)</span>
                </a>

                {sessionUser ? (
                  <Link
                    href="/app/discover"
                    className="w-full sm:w-auto px-5 py-3 text-sm font-semibold rounded-tk-btn bg-brand-navyCard hover:bg-brand-navySecondary border border-brand-border text-white transition-colors flex items-center justify-center gap-2"
                  >
                    <span>Open Campus Portal</span>
                    <ArrowRight className="w-4 h-4 text-brand-lavender" />
                  </Link>
                ) : (
                  <>
                    <Link
                      href="/register"
                      className="w-full sm:w-auto px-5 py-3 text-sm font-semibold rounded-tk-btn bg-brand-navyCard hover:bg-brand-navySecondary border border-brand-border text-white transition-colors flex items-center justify-center gap-2"
                    >
                      <Sparkles className="w-4 h-4 text-brand-lavender" />
                      <span>Join Campus Network</span>
                    </Link>
                    <Link
                      href="/login"
                      className="w-full sm:w-auto px-4 py-3 text-sm font-semibold text-brand-muted hover:text-white transition-colors flex items-center justify-center gap-1"
                    >
                      Sign In &rarr;
                    </Link>
                  </>
                )}
              </div>

              {/* Version & Platform Summary */}
              <div className="pt-1 flex flex-wrap items-center justify-center lg:justify-start gap-3 text-xs text-brand-muted">
                <span className="inline-flex items-center gap-1.5 text-[11px] text-brand-teal font-medium">
                  <span className="w-2 h-2 rounded-full bg-brand-teal" />
                  Android APK {latestRelease.version_name}
                </span>
                <span className="text-brand-border">|</span>
                <span className="text-[11px] text-brand-muted">
                  iOS &amp; Desktop: Safari / Chrome Web App (PWA)
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
                    src={heroStudent.profile_image}
                    name={heroStudent.full_name}
                    size={56}
                    className="rounded-2xl border border-brand-purple/40"
                  />
                  <div>
                    <h3 className="font-bold text-base text-white flex items-center gap-1.5">
                      {heroStudent.full_name}
                      <CheckCircle2 className="w-4 h-4 text-brand-teal" />
                    </h3>
                    <p className="text-xs text-brand-muted">
                      {heroStudent.department} • {heroStudent.academic_year}
                    </p>
                    <span className="text-[10px] text-brand-teal font-medium">
                      Verified Student
                    </span>
                  </div>
                </div>

                <p className="text-xs text-brand-text/90 leading-relaxed line-clamp-3">
                  {heroStudent.bio}
                </p>

                <div className="flex flex-wrap gap-1.5 pt-1">
                  {heroStudent.interests.slice(0, 3).map((interest) => (
                    <span
                      key={interest}
                      className="text-[10px] px-2 py-0.5 rounded-md bg-brand-navySecondary border border-brand-border text-brand-lavender font-medium"
                    >
                      {interest}
                    </span>
                  ))}
                </div>

                <div className="pt-2 border-t border-brand-border/60 flex items-center justify-between text-xs">
                  <span className="text-brand-muted text-[11px] truncate max-w-[170px]">{heroStudent.availability}</span>
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

      {/* 3. DISCOVER PEOPLE SECTION */}
      <section id="discover" className="py-16 bg-brand-navySecondary/40 border-b border-brand-border/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-10">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
            <div className="space-y-1 text-center sm:text-left">
              <h2 className="text-2xl sm:text-3xl font-extrabold text-white">
                Connect across departments
              </h2>
              <p className="text-sm text-brand-muted">
                Discover students with shared technical and creative interests across all TKMCE branches.
              </p>
            </div>
            <button
              onClick={() => pickRandomSample(allStudentsPool)}
              className="inline-flex items-center justify-center gap-2 px-4 py-2 rounded-tk-btn bg-brand-purple/20 hover:bg-brand-purple/30 border border-brand-purple/40 text-brand-lavender hover:text-white text-xs font-semibold transition-all self-center sm:self-auto shadow-sm"
              title="Shuffle student suggestions"
            >
              <Shuffle className="w-3.5 h-3.5 text-brand-purple" />
              <span>Shuffle Suggestions</span>
            </button>
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
          <div className="text-center max-w-2xl mx-auto space-y-2">
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

      {/* 5. EQUIPO KROMIUM SECTION */}
      <section id="kromium" className="py-16 bg-[#090C15] border-b border-brand-border/60">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-10">
          <div className="text-center max-w-2xl mx-auto space-y-2">
            <h2 className="text-2xl sm:text-3xl font-extrabold text-white tracking-tight">
              Built by Equipo Kromium
            </h2>
            <p className="text-sm text-brand-muted">
              Student developer collective at TKM College of Engineering building open-source software for campus life.
            </p>
          </div>

          {/* Kromium Banner */}
          <div className="rounded-2xl border border-white/10 overflow-hidden shadow-xl bg-[#0D0E1A]">
            <Image
              src="/images/kromium/kromium_hero_banner_2x.png"
              alt="Equipo Kromium"
              width={1600}
              height={500}
              className="w-full h-auto object-cover"
              priority
            />
          </div>

          {/* Pillars */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
            <div className="glass-panel rounded-xl border border-white/10 p-5 space-y-2">
              <div className="w-8 h-8 rounded-lg bg-brand-purple/20 flex items-center justify-center text-brand-lavender">
                <Code2 className="w-4 h-4" />
              </div>
              <h3 className="text-sm font-bold text-white">Open Source</h3>
              <p className="text-xs text-brand-muted">
                Public GitHub repository with transparent code and architecture for students to inspect and contribute.
              </p>
            </div>

            <div className="glass-panel rounded-xl border border-white/10 p-5 space-y-2">
              <div className="w-8 h-8 rounded-lg bg-brand-teal/20 flex items-center justify-center text-brand-teal">
                <Cpu className="w-4 h-4" />
              </div>
              <h3 className="text-sm font-bold text-white">Modern Stack</h3>
              <p className="text-xs text-brand-muted">
                Built with Flutter for the Android client, Next.js for the web portal, and Supabase for authentication and database.
              </p>
            </div>

            <div className="glass-panel rounded-xl border border-white/10 p-5 space-y-2">
              <div className="w-8 h-8 rounded-lg bg-brand-lavender/20 flex items-center justify-center text-brand-lavender">
                <ShieldCheck className="w-4 h-4" />
              </div>
              <h3 className="text-sm font-bold text-white">Student Privacy</h3>
              <p className="text-xs text-brand-muted">
                Strict institutional email requirement, mutual consent messaging, and customizable profile visibility.
              </p>
            </div>
          </div>

          <div className="text-center pt-2 flex flex-wrap items-center justify-center gap-3">
            <Link
              href="/team"
              className="px-5 py-2.5 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white font-semibold text-xs flex items-center gap-2 transition-colors"
            >
              Meet the Team <ArrowRight className="w-3.5 h-3.5" />
            </Link>
            <button
              onClick={() => {
                setContactCategory("Collaborate with Kromium");
                setContactModalOpen(true);
              }}
              className="px-5 py-2.5 rounded-tk-btn bg-brand-navyCard hover:bg-brand-navySecondary border border-brand-border text-white font-semibold text-xs transition-colors"
            >
              Collaborate
            </button>
            <a
              href="https://github.com/creatorspara/tkmingle"
              target="_blank"
              rel="noreferrer"
              className="px-4 py-2.5 rounded-tk-btn border border-brand-border/70 text-brand-muted hover:text-white font-medium text-xs flex items-center gap-1.5 transition-colors"
            >
              GitHub <ExternalLink className="w-3 h-3" />
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

      {/* 9. BOTTOM COMMUNITY SECTION */}
      <section className="py-16 bg-brand-navySecondary/60 border-b border-brand-border/60">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center space-y-4">
          <h2 className="text-2xl sm:text-3xl font-extrabold text-white">
            Have questions or feedback?
          </h2>
          <p className="text-sm text-brand-muted max-w-xl mx-auto">
            Got an idea, found a bug, or want to contribute? Reach out to our student team directly.
          </p>

          <div className="pt-2 flex flex-wrap items-center justify-center gap-3">
            <button
              onClick={() => {
                setContactCategory("Suggestions & Feedback");
                setContactModalOpen(true);
              }}
              className="px-5 py-2.5 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white text-xs font-semibold shadow-purple-glow transition-all"
            >
              Send Message
            </button>
            <a
              href="mailto:tkmmingle@gmail.com?subject=TKMingle%20Inquiry"
              className="px-5 py-2.5 rounded-tk-btn bg-brand-navyCard hover:bg-brand-navySecondary border border-brand-border text-white text-xs font-semibold transition-all flex items-center gap-1.5"
            >
              <Mail className="w-3.5 h-3.5 text-brand-purple" />
              tkmmingle@gmail.com
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
                Campus social discovery platform for TKM College of Engineering, Kollam, Kerala. Built by Equipo Kromium.
              </p>
            </div>

            <div className="space-y-2">
              <h4 className="text-xs font-bold uppercase tracking-wider text-white">Platform &amp; Trust</h4>
              <ul className="space-y-1.5 text-xs text-brand-muted">
                <li><a href={latestRelease.download_url} download className="text-brand-teal hover:underline flex items-center gap-1"><Smartphone className="w-3 h-3" /> Android APK ({latestRelease.version_name})</a></li>
                <li>
                  <Link href="/security" className="text-brand-teal hover:underline flex items-center gap-1">
                    <ShieldCheck className="w-3 h-3" /> Security &amp; Virus Analysis (0/21)
                  </Link>
                </li>
                <li>
                  <a href="/tkmmingle-k1-release.apk.pdf" target="_blank" rel="noreferrer" className="text-brand-lavender hover:underline flex items-center gap-1">
                    <FileText className="w-3 h-3" /> MetaDefender Scan Report (PDF)
                  </a>
                </li>
                <li><a href="#discover" className="hover:text-white transition-colors">Discover Students</a></li>
                <li><a href="#circles" className="hover:text-white transition-colors">Campus Circles</a></li>
                <li><a href="#kromium" className="hover:text-white transition-colors">Equipo Kromium</a></li>
                <li><a href="#faq" className="hover:text-white transition-colors">FAQ</a></li>
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
            <p>&copy; 2026 TKMingle &bull; Equipo Kromium &bull; TKM College of Engineering.</p>
            <div className="flex items-center gap-5">
              <a href={latestRelease.download_url} download className="hover:text-white transition-colors">Download APK</a>
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

      {/* 11. CONTACT MODAL */}
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
                Messages are forwarded to <span className="text-brand-teal font-medium">tkmmingle@gmail.com</span>. Submissions can be anonymous.
              </p>
            </div>

            {contactSuccess ? (
              <div className="py-8 text-center space-y-3">
                <div className="w-12 h-12 rounded-full bg-brand-teal/20 text-brand-teal mx-auto flex items-center justify-center">
                  <CheckCircle2 className="w-6 h-6" />
                </div>
                <h4 className="text-base font-bold text-white">Message Sent</h4>
                <p className="text-xs text-brand-muted max-w-sm mx-auto">
                  Your message has been sent to <span className="text-brand-lavender font-semibold">tkmmingle@gmail.com</span>.
                </p>
                <div className="pt-2 flex flex-col items-center gap-2">
                  <a
                    href={contactMailto || "mailto:tkmmingle@gmail.com"}
                    className="text-xs text-brand-teal hover:underline flex items-center gap-1 font-medium"
                  >
                    <Mail className="w-3.5 h-3.5" />
                    Open in email client &rarr;
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
                      placeholder="Anonymous Student"
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
                      placeholder="name@tkmce.ac.in"
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
                    placeholder="Write your note here..."
                    className="w-full p-3 rounded-tk-btn bg-brand-navy border border-brand-border text-xs text-white focus:outline-none focus:border-brand-purple"
                  />
                </div>

                <div className="pt-2 flex items-center justify-between">
                  <span className="text-[10px] text-brand-muted">
                    Sent to <code className="text-brand-lavender">tkmmingle@gmail.com</code>
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
