"use client";

import React, { useState } from "react";
import Image from "next/image";
import Link from "next/link";
import {
  Code2,
  GitBranch,
  Users2,
  Box,
  Terminal,
  Share2,
  ArrowRight,
  ArrowLeft,
  CheckCircle2,
  Send,
  Github,
  ExternalLink,
  Heart,
  Layers,
  Sparkles,
} from "lucide-react";

export default function EquipoKromiumPage() {
  const [contactName, setContactName] = useState("");
  const [contactEmail, setContactEmail] = useState("");
  const [contactRole, setContactRole] = useState("Developer / Engineer");
  const [contactMessage, setContactMessage] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!contactMessage.trim()) return;

    setSubmitting(true);
    try {
      await fetch("/api/contact", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name: contactName.trim() || "Anonymous Student",
          email: contactEmail.trim() || "anonymous@tkmce.ac.in",
          department: contactRole,
          category: "Collaborate with Kromium",
          message: contactMessage.trim(),
          source: "team_page",
        }),
      });
    } catch (err) {
      console.error("Collaborate submit error:", err);
    } finally {
      setSubmitting(false);
      setSubmitted(true);
      setTimeout(() => {
        setSubmitted(false);
        setContactMessage("");
        setContactName("");
        setContactEmail("");
      }, 3500);
    }
  };

  const principles = [
    {
      num: "01",
      title: "Open-source first.",
      desc: "Transparent engineering, publicly accessible codebases, and collaborative development that benefits the wider developer community.",
      icon: GitBranch,
    },
    {
      num: "02",
      title: "Build things that matter.",
      desc: "Focused on crafting practical software solutions that solve real-world problems for students, campus life, and society.",
      icon: Box,
    },
    {
      num: "03",
      title: "Learn through collaboration.",
      desc: "We learn by building and grow together. Junior and senior developers pair up to experiment with cutting-edge technologies.",
      icon: Users2,
    },
    {
      num: "04",
      title: "Share knowledge and innovation.",
      desc: "Giving back through open documentation, architecture specs, workshops, and open-source contributions.",
      icon: Share2,
    },
    {
      num: "05",
      title: "Technology without boundaries.",
      desc: "Built by students, open to everyone. Cross-branch collaboration connecting engineers, designers, and creators.",
      icon: Terminal,
    },
  ];

  return (
    <div className="min-h-screen bg-[#0A0A0F] text-[#F5F5F7] flex flex-col selection:bg-[#6C4DFF] selection:text-white font-sans">
      {/* 1. NAVIGATION BAR */}
      <header className="sticky top-0 z-50 bg-[#0A0A0F]/90 backdrop-blur-md border-b border-[#1C1C28]">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
          <div className="flex items-center gap-4">
            <Link
              href="/"
              className="inline-flex items-center gap-1.5 text-xs font-semibold text-gray-400 hover:text-white transition-colors py-1.5 px-3 rounded-lg hover:bg-white/5"
            >
              <ArrowLeft className="w-4 h-4" />
              <span>Back to TKMingle</span>
            </Link>
            <div className="h-4 w-px bg-white/15 hidden sm:block" />
            <div className="flex items-center gap-2.5">
              <div className="w-7 h-7 rounded-lg bg-[#6C4DFF]/15 border border-[#6C4DFF]/30 flex items-center justify-center p-1">
                <Image
                  src="/images/kromium/kromium_symbol_purple.png"
                  alt="Equipo Kromium"
                  width={20}
                  height={20}
                  className="object-contain"
                />
              </div>
              <span className="font-bold text-sm sm:text-base text-white tracking-tight">
                Equipo <span className="text-[#A78BFA]">Kromium</span>
              </span>
            </div>
          </div>

          <nav className="hidden md:flex items-center gap-6 text-xs font-medium text-gray-400">
            <a href="#mission" className="hover:text-white transition-colors">Mission</a>
            <a href="#principles" className="hover:text-white transition-colors">Principles</a>
            <a href="#projects" className="hover:text-white transition-colors">Projects</a>
            <a href="#join" className="hover:text-white transition-colors">Join Us</a>
          </nav>

          <div className="flex items-center gap-3">
            <a
              href="https://github.com/creatorspara/tkmingle"
              target="_blank"
              rel="noreferrer"
              className="inline-flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-lg border border-white/10 hover:border-white/30 text-gray-300 hover:text-white transition-colors"
            >
              <Github className="w-3.5 h-3.5" />
              <span>GitHub</span>
            </a>
            <a
              href="#join"
              className="px-3.5 py-1.5 text-xs font-semibold rounded-lg bg-[#6C4DFF] hover:bg-[#6C4DFF]/90 text-white shadow-lg shadow-[#6C4DFF]/25 transition-all"
            >
              Collaborate
            </a>
          </div>
        </div>
      </header>

      {/* 2. HERO SECTION */}
      <section className="relative pt-20 pb-20 md:pt-28 md:pb-28 border-b border-[#1C1C28]">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center space-y-6">
          <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-white/5 border border-white/10 text-xs font-medium text-[#A78BFA]">
            <Sparkles className="w-3.5 h-3.5 text-[#6C4DFF]" />
            <span>Student-Led Developer Collective • TKMCE</span>
          </div>

          <div className="space-y-3">
            <h1 className="text-4xl sm:text-6xl md:text-7xl font-extrabold tracking-tight text-white leading-tight">
              Build <span className="text-[#6C4DFF]">·</span> Open <span className="text-[#A78BFA]">·</span> Share
            </h1>
            <p className="text-base sm:text-xl text-gray-400 max-w-2xl mx-auto font-normal leading-relaxed">
              Equipo Kromium is a collective of student developers, designers, and creators building real-world open-source software for everyone.
            </p>
          </div>

          <div className="inline-block py-1 px-3.5 rounded-lg bg-white/5 border border-white/10 text-xs text-[#D1C4FF] font-medium">
            Built by students. Open to everyone.
          </div>

          <div className="pt-4 flex flex-col sm:flex-row items-center justify-center gap-3">
            <a
              href="#projects"
              className="w-full sm:w-auto px-6 py-3 rounded-xl bg-[#6C4DFF] hover:bg-[#6C4DFF]/90 text-white font-semibold text-xs transition-all shadow-lg shadow-[#6C4DFF]/30 flex items-center justify-center gap-2"
            >
              Explore What We Build
              <ArrowRight className="w-4 h-4" />
            </a>
            <a
              href="#join"
              className="w-full sm:w-auto px-6 py-3 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 text-white font-semibold text-xs transition-colors flex items-center justify-center gap-2"
            >
              Join the Team
            </a>
          </div>
        </div>
      </section>

      {/* 3. MISSION SECTION */}
      <section id="mission" className="py-20 bg-[#0E0E17] border-b border-[#1C1C28]">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 md:grid-cols-12 gap-10 items-center">
            <div className="md:col-span-7 space-y-4">
              <div className="text-xs font-bold uppercase tracking-widest text-[#A78BFA]">
                Who We Are
              </div>
              <h2 className="text-2xl sm:text-4xl font-extrabold text-white leading-tight">
                Technology should be accessible, collaborative, and built for everyone.
              </h2>
              <p className="text-sm text-gray-400 leading-relaxed">
                Our team brings together curious minds, developers, and creators from across TKM College of Engineering to turn ideas into practical software solutions.
              </p>
              <p className="text-sm text-gray-400 leading-relaxed">
                From experimenting with new technologies to developing real-world applications, we learn by building, grow by collaborating, and give back by sharing our work with the open-source community.
              </p>
            </div>

            <div className="md:col-span-5">
              <div className="rounded-2xl bg-[#141422] border border-white/10 p-6 space-y-4 shadow-xl">
                <div className="flex items-center gap-3 pb-3 border-b border-white/10">
                  <div className="w-10 h-10 rounded-xl bg-[#6C4DFF]/20 flex items-center justify-center text-[#A78BFA]">
                    <Code2 className="w-5 h-5" />
                  </div>
                  <div>
                    <h3 className="font-bold text-sm text-white">Open Source First</h3>
                    <p className="text-xs text-gray-400">Everything we build is in the open</p>
                  </div>
                </div>

                <div className="space-y-2.5 text-xs text-gray-300">
                  <div className="flex items-center gap-2.5">
                    <CheckCircle2 className="w-4 h-4 text-[#A78BFA] flex-shrink-0" />
                    <span>Real-world engineering &amp; clean architectures</span>
                  </div>
                  <div className="flex items-center gap-2.5">
                    <CheckCircle2 className="w-4 h-4 text-[#A78BFA] flex-shrink-0" />
                    <span>Cross-departmental student developer pairing</span>
                  </div>
                  <div className="flex items-center gap-2.5">
                    <CheckCircle2 className="w-4 h-4 text-[#A78BFA] flex-shrink-0" />
                    <span>Peer reviews, testing &amp; privacy standards</span>
                  </div>
                  <div className="flex items-center gap-2.5">
                    <CheckCircle2 className="w-4 h-4 text-[#A78BFA] flex-shrink-0" />
                    <span>100% free and open for student empowerment</span>
                  </div>
                </div>

                <div className="pt-2 border-t border-white/5">
                  <div className="text-[11px] text-gray-400 flex items-center justify-between">
                    <span>Base</span>
                    <span className="font-semibold text-white">TKM College of Engineering, Kollam</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 4. OUR PRINCIPLES */}
      <section id="principles" className="py-20 bg-[#0A0A0F] border-b border-[#1C1C28]">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 space-y-12">
          <div className="text-center max-w-2xl mx-auto space-y-2">
            <div className="text-xs font-bold uppercase tracking-widest text-[#A78BFA]">
              Our Foundation
            </div>
            <h2 className="text-2xl sm:text-4xl font-extrabold text-white">
              Our Principles
            </h2>
            <p className="text-sm text-gray-400">
              The values that drive how we build software and collaborate.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
            {principles.map((p) => {
              const Icon = p.icon;
              return (
                <div
                  key={p.num}
                  className="rounded-2xl bg-[#12121E] border border-white/10 p-6 space-y-4 hover:border-[#6C4DFF]/40 transition-colors flex flex-col justify-between"
                >
                  <div className="space-y-3">
                    <div className="flex items-center justify-between">
                      <div className="w-9 h-9 rounded-xl bg-[#6C4DFF]/15 text-[#A78BFA] flex items-center justify-center">
                        <Icon className="w-4 h-4" />
                      </div>
                      <span className="text-xs font-bold font-mono text-gray-500">{p.num}</span>
                    </div>
                    <h3 className="font-bold text-sm sm:text-base text-white">{p.title}</h3>
                    <p className="text-xs text-gray-400 leading-relaxed">{p.desc}</p>
                  </div>
                </div>
              );
            })}

            {/* Sixth Card */}
            <div className="rounded-2xl bg-[#141424] border border-[#6C4DFF]/30 p-6 space-y-4 flex flex-col justify-between">
              <div className="space-y-3">
                <div className="w-9 h-9 rounded-xl bg-[#6C4DFF] text-white flex items-center justify-center shadow-lg shadow-[#6C4DFF]/25">
                  <Heart className="w-4 h-4" />
                </div>
                <h3 className="font-bold text-sm sm:text-base text-white">Community Driven.</h3>
                <p className="text-xs text-[#D1C4FF] leading-relaxed">
                  Students build the most impactful technology when given autonomy, great tools, and a collaborative environment.
                </p>
              </div>
              <div className="text-[11px] font-semibold text-white/70">
                Equipo Kromium • 2026
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 5. FLAGSHIP PROJECT: TKMINGLE */}
      <section id="projects" className="py-20 bg-[#0E0E17] border-b border-[#1C1C28]">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 space-y-10">
          <div className="text-center max-w-2xl mx-auto space-y-2">
            <div className="text-xs font-bold uppercase tracking-widest text-[#A78BFA]">
              Featured Work
            </div>
            <h2 className="text-2xl sm:text-4xl font-extrabold text-white">
              TKMingle Platform
            </h2>
            <p className="text-sm text-gray-400">
              Our campus-wide social discovery ecosystem connecting students across all engineering branches.
            </p>
          </div>

          <div className="rounded-3xl bg-[#141422] border border-white/10 p-6 sm:p-10 shadow-2xl">
            <div className="space-y-6">
              <div className="flex flex-wrap items-center justify-between gap-3 pb-6 border-b border-white/10">
                <div className="space-y-1">
                  <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#6C4DFF]/20 border border-[#6C4DFF]/40 text-xs font-medium text-[#D1C4FF]">
                    <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
                    <span>v1.0.1-k1 Production Release</span>
                  </div>
                  <h3 className="text-2xl font-extrabold text-white">
                    TKMingle
                  </h3>
                </div>

                <div className="flex items-center gap-3">
                  <Link
                    href="/"
                    className="px-4 py-2 rounded-xl bg-[#6C4DFF] hover:bg-[#6C4DFF]/90 text-white font-semibold text-xs flex items-center gap-1.5 transition-all shadow-lg shadow-[#6C4DFF]/20"
                  >
                    Open Web App
                    <ArrowRight className="w-3.5 h-3.5" />
                  </Link>
                  <a
                    href="https://github.com/creatorspara/tkmingle/releases/tag/v1.0.1-k1"
                    target="_blank"
                    rel="noreferrer"
                    className="px-4 py-2 rounded-xl bg-white/10 hover:bg-white/15 border border-white/10 text-white font-semibold text-xs flex items-center gap-1.5 transition-colors"
                  >
                    Download APK
                    <ExternalLink className="w-3.5 h-3.5" />
                  </a>
                </div>
              </div>

              <p className="text-xs sm:text-sm text-gray-300 leading-relaxed max-w-3xl">
                TKMingle breaks down department silos at TKM College of Engineering. Built from scratch with Flutter for Android and iOS, Next.js for the responsive web, Supabase for authentication and PostgreSQL data storage, and Brevo SMTP for secure campus email verification.
              </p>

              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 pt-2 text-xs">
                <div className="p-3 rounded-xl bg-white/5 border border-white/5">
                  <div className="text-gray-400 text-[10px] font-mono">Mobile App</div>
                  <div className="font-semibold text-white mt-1">Flutter Native</div>
                </div>
                <div className="p-3 rounded-xl bg-white/5 border border-white/5">
                  <div className="text-gray-400 text-[10px] font-mono">Web Application</div>
                  <div className="font-semibold text-white mt-1">Next.js 14</div>
                </div>
                <div className="p-3 rounded-xl bg-white/5 border border-white/5">
                  <div className="text-gray-400 text-[10px] font-mono">Database &amp; Auth</div>
                  <div className="font-semibold text-white mt-1">Supabase PostgreSQL</div>
                </div>
                <div className="p-3 rounded-xl bg-white/5 border border-white/5">
                  <div className="text-gray-400 text-[10px] font-mono">Campus Scope</div>
                  <div className="font-semibold text-white mt-1">9 Departments</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 6. GET INVOLVED / COLLABORATE SECTION */}
      <section id="join" className="py-20 bg-[#0A0A0F]">
        <div className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 space-y-8">
          <div className="text-center space-y-2">
            <div className="text-xs font-bold uppercase tracking-widest text-[#A78BFA]">
              Get Involved
            </div>
            <h2 className="text-2xl sm:text-4xl font-extrabold text-white">
              Collaborate With Us
            </h2>
            <p className="text-sm text-gray-400">
              Want to build, contribute to open-source, or share an idea? Reach out to Equipo Kromium.
            </p>
          </div>

          <div className="rounded-2xl bg-[#141422] border border-white/10 p-6 sm:p-8 shadow-2xl">
            {submitted ? (
              <div className="py-8 text-center space-y-3">
                <div className="w-12 h-12 rounded-full bg-[#6C4DFF]/20 text-[#A78BFA] mx-auto flex items-center justify-center">
                  <CheckCircle2 className="w-6 h-6" />
                </div>
                <h4 className="text-base font-bold text-white">Message Dispatched to Team Kromium</h4>
                <p className="text-xs text-gray-400 max-w-sm mx-auto">
                  Your message has been safely delivered to <span className="text-[#A78BFA] font-medium">tkmmingle@gmail.com</span>. We&apos;ll review it and get in touch with you!
                </p>
                <div className="pt-2">
                  <a
                    href="mailto:tkmmingle@gmail.com?subject=Collaborate%20with%20Equipo%20Kromium"
                    className="inline-flex items-center gap-1.5 text-xs text-[#A78BFA] hover:text-white underline"
                  >
                    Open directly in your mail app &rarr;
                  </a>
                </div>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="space-y-4">
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-[11px] font-semibold text-gray-400 uppercase tracking-wider mb-1">
                      Your Name <span className="text-gray-500 font-normal lowercase">(optional / anonymous)</span>
                    </label>
                    <input
                      type="text"
                      value={contactName}
                      onChange={(e) => setContactName(e.target.value)}
                      placeholder="Anonymous Student (or enter your name)"
                      className="w-full px-3.5 py-2.5 rounded-xl bg-[#0A0A0F] border border-white/10 text-xs text-white focus:outline-none focus:border-[#6C4DFF]"
                    />
                  </div>
                  <div>
                    <label className="block text-[11px] font-semibold text-gray-400 uppercase tracking-wider mb-1">
                      Email Address
                    </label>
                    <input
                      type="email"
                      required
                      value={contactEmail}
                      onChange={(e) => setContactEmail(e.target.value)}
                      placeholder="your.email@tkmce.ac.in"
                      className="w-full px-3.5 py-2.5 rounded-xl bg-[#0A0A0F] border border-white/10 text-xs text-white focus:outline-none focus:border-[#6C4DFF]"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-[11px] font-semibold text-gray-400 uppercase tracking-wider mb-1">
                    Your Focus Area
                  </label>
                  <select
                    value={contactRole}
                    onChange={(e) => setContactRole(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl bg-[#0A0A0F] border border-white/10 text-xs text-white focus:outline-none focus:border-[#6C4DFF]"
                  >
                    <option value="Developer / Engineer">Mobile &amp; Web Developer (Flutter / React / Node)</option>
                    <option value="UI/UX Designer">UI / UX / Graphic Designer</option>
                    <option value="Hardware / Embedded">Hardware &amp; IoT Enthusiast</option>
                    <option value="Project Collaborator">Student Project Collaborator</option>
                    <option value="General Community">General Feedback / Community</option>
                  </select>
                </div>

                <div>
                  <label className="block text-[11px] font-semibold text-gray-400 uppercase tracking-wider mb-1">
                    Message
                  </label>
                  <textarea
                    rows={4}
                    required
                    value={contactMessage}
                    onChange={(e) => setContactMessage(e.target.value)}
                    placeholder="Tell us what you'd like to build or collaborate on..."
                    className="w-full p-3.5 rounded-xl bg-[#0A0A0F] border border-white/10 text-xs text-white focus:outline-none focus:border-[#6C4DFF]"
                  />
                </div>

                <div className="pt-2 flex justify-end">
                  <button
                    type="submit"
                    disabled={submitting}
                    className="px-6 py-2.5 rounded-xl bg-[#6C4DFF] hover:bg-[#6C4DFF]/90 text-white font-semibold text-xs flex items-center gap-2 shadow-lg shadow-[#6C4DFF]/25 transition-all"
                  >
                    <Send className="w-3.5 h-3.5" />
                    {submitting ? "Sending..." : "Send Message"}
                  </button>
                </div>
              </form>
            )}
          </div>
        </div>
      </section>

      {/* 7. FOOTER */}
      <footer className="bg-[#0A0A0F] py-8 border-t border-[#1C1C28]">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col sm:flex-row items-center justify-between text-xs text-gray-400 gap-4">
          <div className="flex items-center gap-2.5">
            <Image
              src="/images/kromium/kromium_symbol_purple.png"
              alt="Kromium"
              width={18}
              height={18}
              className="object-contain"
            />
            <span className="font-bold text-white">Equipo Kromium</span>
            <span>• Build · Open · Share</span>
          </div>

          <div className="flex items-center gap-6">
            <Link href="/" className="hover:text-white transition-colors">TKMingle Home</Link>
            <Link href="/security" className="hover:text-white transition-colors">Security Audit</Link>
            <a
              href="https://github.com/creatorspara/tkmingle"
              target="_blank"
              rel="noreferrer"
              className="hover:text-white transition-colors"
            >
              GitHub
            </a>
          </div>

          <div className="text-[11px] text-gray-500">
            &copy; 2026 Equipo Kromium • TKM College of Engineering
          </div>
        </div>
      </footer>
    </div>
  );
}
