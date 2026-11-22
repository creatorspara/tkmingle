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
  Sparkles,
  ArrowRight,
  ArrowLeft,
  CheckCircle2,
  Mail,
  Send,
  Github,
  Globe,
  ExternalLink,
  Heart,
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
    await new Promise((r) => setTimeout(r, 600));
    setSubmitting(false);
    setSubmitted(true);
    setTimeout(() => {
      setSubmitted(false);
      setContactMessage("");
      setContactName("");
      setContactEmail("");
    }, 3000);
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

  const brandColors = [
    { name: "Primary Violet", hex: "#6C4DFF", bg: "bg-[#6C4DFF]", text: "text-white" },
    { name: "Accent Purple", hex: "#A78BFA", bg: "bg-[#A78BFA]", text: "text-black" },
    { name: "Lavender Tint", hex: "#D1C4FF", bg: "bg-[#D1C4FF]", text: "text-black" },
    { name: "Obsidian Dark", hex: "#0A0A0F", bg: "bg-[#0A0A0F] border border-white/20", text: "text-white" },
    { name: "Pure Off-White", hex: "#F5F5F7", bg: "bg-[#F5F5F7]", text: "text-black" },
  ];

  return (
    <div className="min-h-screen bg-[#0A0A0F] text-[#F5F5F7] flex flex-col selection:bg-[#6C4DFF] selection:text-white font-sans">
      {/* 1. STICKY HEADER */}
      <header className="sticky top-0 z-50 bg-[#0A0A0F]/90 backdrop-blur-md border-b border-[#1C1C28]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-18 flex items-center justify-between">
          <div className="flex items-center gap-4">
            <Link
              href="/"
              className="inline-flex items-center gap-1.5 text-xs font-semibold text-gray-400 hover:text-white transition-colors py-1.5 px-3 rounded-lg hover:bg-white/5"
            >
              <ArrowLeft className="w-4 h-4" />
              <span>Back to TKMingle</span>
            </Link>
            <div className="h-4 w-px bg-white/20 hidden sm:block" />
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-lg bg-[#6C4DFF]/10 border border-[#6C4DFF]/30 flex items-center justify-center p-1">
                <Image
                  src="/images/kromium/kromium_app_icon.png"
                  alt="Equipo Kromium"
                  width={24}
                  height={24}
                  className="rounded"
                />
              </div>
              <span className="font-bold text-base text-white tracking-tight">
                Equipo <span className="text-[#A78BFA]">Kromium</span>
              </span>
            </div>
          </div>

          <nav className="hidden md:flex items-center gap-6 text-xs font-medium text-gray-400">
            <a href="#mission" className="hover:text-white transition-colors">Mission</a>
            <a href="#principles" className="hover:text-white transition-colors">Principles</a>
            <a href="#projects" className="hover:text-white transition-colors">Flagship Projects</a>
            <a href="#palette" className="hover:text-white transition-colors">Brand Identity</a>
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
      <section className="relative pt-16 pb-20 md:pt-24 md:pb-32 overflow-hidden border-b border-[#1C1C28]">
        {/* Glow ambient effects */}
        <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[350px] bg-[#6C4DFF]/15 blur-[120px] rounded-full pointer-events-none" />

        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 text-center space-y-8 relative z-10">
          {/* Brand Pill */}
          <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-white/5 border border-white/10 text-xs font-medium text-[#A78BFA]">
            <Sparkles className="w-3.5 h-3.5 text-[#6C4DFF]" />
            <span>Open Source Developer Collective • TKM College of Engineering</span>
          </div>

          {/* Main Title Lockup */}
          <div className="space-y-4">
            <h1 className="text-4xl sm:text-6xl md:text-7xl font-extrabold tracking-tight text-white leading-tight">
              Build <span className="text-[#6C4DFF]">·</span> Open <span className="text-[#A78BFA]">·</span> Share
            </h1>
            <p className="text-lg sm:text-xl text-gray-400 max-w-2xl mx-auto font-normal leading-relaxed">
              Equipo Kromium is a student-led developer collective dedicated to building, maintaining, and contributing to open-source software for a stronger, more open tech community.
            </p>
          </div>

          {/* Sub-quote */}
          <div className="inline-block py-1.5 px-4 rounded-xl bg-white/5 border border-white/10 text-xs text-[#D1C4FF] font-medium tracking-wide">
            Built by students. Open to everyone.
          </div>

          {/* Action CTAs */}
          <div className="pt-2 flex flex-col sm:flex-row items-center justify-center gap-3.5">
            <a
              href="#projects"
              className="w-full sm:w-auto px-6 py-3 rounded-xl bg-[#6C4DFF] hover:bg-[#6C4DFF]/90 text-white font-semibold text-xs transition-all shadow-lg shadow-[#6C4DFF]/30 flex items-center justify-center gap-2"
            >
              Explore Flagship Projects
              <ArrowRight className="w-4 h-4" />
            </a>
            <a
              href="#join"
              className="w-full sm:w-auto px-6 py-3 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 text-white font-semibold text-xs transition-colors flex items-center justify-center gap-2"
            >
              Join the Collective
            </a>
          </div>

          {/* Banner Graphic Preview */}
          <div className="pt-10 max-w-4xl mx-auto">
            <div className="rounded-2xl border border-white/15 overflow-hidden shadow-2xl shadow-[#6C4DFF]/10 relative group">
              <Image
                src="/images/kromium/kromium_hero_banner.png"
                alt="Equipo Kromium Platform"
                width={1200}
                height={550}
                className="w-full h-auto object-cover"
                priority
              />
              <div className="absolute inset-0 bg-gradient-to-t from-[#0A0A0F] via-transparent to-transparent opacity-40 pointer-events-none" />
            </div>
          </div>
        </div>
      </section>

      {/* 3. MISSION & STORY SECTION */}
      <section id="mission" className="py-20 bg-[#0E0E17] border-b border-[#1C1C28]">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 md:grid-cols-12 gap-12 items-center">
            <div className="md:col-span-6 space-y-5">
              <div className="text-xs font-bold uppercase tracking-widest text-[#A78BFA]">
                Our Mission &amp; Story
              </div>
              <h2 className="text-2xl sm:text-4xl font-extrabold text-white leading-tight">
                Technology should be accessible, collaborative, and built for everyone.
              </h2>
              <p className="text-sm text-gray-400 leading-relaxed">
                Our collective brings together curious minds, software developers, UI/UX designers, and hardware creators from across TKM College of Engineering to turn bold ideas into practical, open software solutions.
              </p>
              <p className="text-sm text-gray-400 leading-relaxed">
                From experimenting with new technologies to developing production-grade applications, we learn by building, grow by collaborating, and give back by sharing our work openly with the world.
              </p>
            </div>

            <div className="md:col-span-6">
              <div className="rounded-2xl bg-[#141422] border border-white/10 p-6 space-y-5 shadow-xl">
                <div className="flex items-center gap-3 pb-4 border-b border-white/10">
                  <div className="w-10 h-10 rounded-xl bg-[#6C4DFF]/20 flex items-center justify-center text-[#A78BFA]">
                    <Code2 className="w-5 h-5" />
                  </div>
                  <div>
                    <h3 className="font-bold text-sm text-white">Open Source DNA</h3>
                    <p className="text-xs text-gray-400">Everything we engineer is built in the open</p>
                  </div>
                </div>

                <div className="space-y-3 text-xs text-gray-300">
                  <div className="flex items-center gap-2.5">
                    <CheckCircle2 className="w-4 h-4 text-[#A78BFA] flex-shrink-0" />
                    <span>Cross-departmental student developer community</span>
                  </div>
                  <div className="flex items-center gap-2.5">
                    <CheckCircle2 className="w-4 h-4 text-[#A78BFA] flex-shrink-0" />
                    <span>Real-world production engineering &amp; clean architectures</span>
                  </div>
                  <div className="flex items-center gap-2.5">
                    <CheckCircle2 className="w-4 h-4 text-[#A78BFA] flex-shrink-0" />
                    <span>Peer code reviews, design tokens &amp; security standards</span>
                  </div>
                  <div className="flex items-center gap-2.5">
                    <CheckCircle2 className="w-4 h-4 text-[#A78BFA] flex-shrink-0" />
                    <span>No commercial paywalls — built for student empowerment</span>
                  </div>
                </div>

                <div className="pt-2">
                  <div className="p-3.5 rounded-xl bg-white/5 border border-white/5 text-[11px] text-gray-400 flex items-center justify-between">
                    <span>Base of Operations</span>
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
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 space-y-12">
          <div className="text-center max-w-2xl mx-auto space-y-3">
            <div className="text-xs font-bold uppercase tracking-widest text-[#A78BFA]">
              Guiding Philosophy
            </div>
            <h2 className="text-2xl sm:text-4xl font-extrabold text-white">
              Our Core Principles
            </h2>
            <p className="text-sm text-gray-400">
              The foundational values that guide every line of code, project decision, and collaboration at Equipo Kromium.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {principles.map((p) => {
              const Icon = p.icon;
              return (
                <div
                  key={p.num}
                  className="rounded-2xl bg-[#12121E] border border-white/10 p-6 space-y-4 hover:border-[#6C4DFF]/50 transition-colors flex flex-col justify-between"
                >
                  <div className="space-y-3">
                    <div className="flex items-center justify-between">
                      <div className="w-10 h-10 rounded-xl bg-[#6C4DFF]/15 text-[#A78BFA] flex items-center justify-center">
                        <Icon className="w-5 h-5" />
                      </div>
                      <span className="text-xs font-bold font-mono text-gray-500">{p.num}</span>
                    </div>
                    <h3 className="font-bold text-base text-white">{p.title}</h3>
                    <p className="text-xs text-gray-400 leading-relaxed">{p.desc}</p>
                  </div>
                </div>
              );
            })}

            {/* Sixth honorary card */}
            <div className="rounded-2xl bg-gradient-to-br from-[#1C1335] to-[#12121E] border border-[#6C4DFF]/40 p-6 space-y-4 flex flex-col justify-between">
              <div className="space-y-3">
                <div className="w-10 h-10 rounded-xl bg-[#6C4DFF] text-white flex items-center justify-center shadow-lg shadow-[#6C4DFF]/30">
                  <Heart className="w-5 h-5" />
                </div>
                <h3 className="font-bold text-base text-white">Community Driven.</h3>
                <p className="text-xs text-[#D1C4FF] leading-relaxed">
                  We believe students build the most exciting tech when empowered with real autonomy, great tools, and an inclusive culture.
                </p>
              </div>
              <div className="text-[11px] font-semibold text-white/80">
                Team Kromium • 2026
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 5. FLAGSHIP PROJECT: TKMINGLE */}
      <section id="projects" className="py-20 bg-[#0E0E17] border-b border-[#1C1C28]">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 space-y-10">
          <div className="text-center max-w-2xl mx-auto space-y-3">
            <div className="text-xs font-bold uppercase tracking-widest text-[#A78BFA]">
              Flagship Project
            </div>
            <h2 className="text-2xl sm:text-4xl font-extrabold text-white">
              TKMingle Platform
            </h2>
            <p className="text-sm text-gray-400">
              Our campus-wide social discovery ecosystem connecting thousands of students across all engineering branches.
            </p>
          </div>

          <div className="rounded-3xl bg-gradient-to-br from-[#161626] to-[#0F0F1A] border border-white/15 p-6 sm:p-10 shadow-2xl space-y-8">
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
              <div className="lg:col-span-7 space-y-4">
                <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#6C4DFF]/20 border border-[#6C4DFF]/40 text-xs font-medium text-[#D1C4FF]">
                  <span>Flagship Production Release • v1.0.0 (k1)</span>
                </div>
                <h3 className="text-2xl sm:text-3xl font-extrabold text-white">
                  TKMingle — Campus Social Discovery
                </h3>
                <p className="text-xs sm:text-sm text-gray-300 leading-relaxed">
                  TKMingle breaks down department silos at TKM College of Engineering. Built from scratch with Flutter for Android/iOS, Next.js 14 for the web, Supabase for authentication and PostgreSQL data storage, and Brevo SMTP for secure email verification.
                </p>

                <div className="pt-2 flex flex-wrap gap-2 text-xs">
                  <span className="px-2.5 py-1 rounded-lg bg-white/5 border border-white/10 text-gray-300">Flutter 3.24</span>
                  <span className="px-2.5 py-1 rounded-lg bg-white/5 border border-white/10 text-gray-300">Next.js 14 App Router</span>
                  <span className="px-2.5 py-1 rounded-lg bg-white/5 border border-white/10 text-gray-300">Supabase Auth &amp; RLS</span>
                  <span className="px-2.5 py-1 rounded-lg bg-white/5 border border-white/10 text-gray-300">PostgreSQL</span>
                  <span className="px-2.5 py-1 rounded-lg bg-white/5 border border-white/10 text-gray-300">Tailwind CSS</span>
                </div>

                <div className="pt-4 flex flex-wrap items-center gap-3">
                  <Link
                    href="/"
                    className="px-5 py-2.5 rounded-xl bg-[#6C4DFF] hover:bg-[#6C4DFF]/90 text-white font-semibold text-xs flex items-center gap-1.5 transition-all shadow-lg shadow-[#6C4DFF]/20"
                  >
                    Open TKMingle Web
                    <ArrowRight className="w-3.5 h-3.5" />
                  </Link>
                  <a
                    href="https://github.com/creatorspara/tkmingle/releases/tag/v1.0.0-k1"
                    target="_blank"
                    rel="noreferrer"
                    className="px-5 py-2.5 rounded-xl bg-white/10 hover:bg-white/15 border border-white/15 text-white font-semibold text-xs flex items-center gap-1.5 transition-colors"
                  >
                    Download APK (k1)
                    <ExternalLink className="w-3.5 h-3.5" />
                  </a>
                </div>
              </div>

              <div className="lg:col-span-5 flex justify-center">
                <div className="rounded-2xl border border-white/10 overflow-hidden shadow-2xl bg-black/40 p-2 max-w-sm w-full">
                  <Image
                    src="/images/kromium/kromium_social_card.png"
                    alt="Equipo Kromium Social Card"
                    width={500}
                    height={350}
                    className="w-full h-auto rounded-xl object-cover"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 6. BRAND PALETTE & IDENTITY */}
      <section id="palette" className="py-20 bg-[#0A0A0F] border-b border-[#1C1C28]">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 space-y-10">
          <div className="text-center max-w-2xl mx-auto space-y-3">
            <div className="text-xs font-bold uppercase tracking-widest text-[#A78BFA]">
              Visual Identity
            </div>
            <h2 className="text-2xl sm:text-4xl font-extrabold text-white">
              Color Palette &amp; Typography
            </h2>
            <p className="text-sm text-gray-400">
              A design system inspired by code, community, and open innovation.
            </p>
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-5 gap-3.5">
            {brandColors.map((c) => (
              <div
                key={c.hex}
                className="rounded-2xl bg-[#141422] border border-white/10 p-3.5 space-y-3 text-center"
              >
                <div className={`w-full h-18 rounded-xl ${c.bg} flex items-center justify-center font-bold text-xs ${c.text} shadow-inner`}>
                  {c.hex}
                </div>
                <div>
                  <div className="font-semibold text-xs text-white truncate">{c.name}</div>
                  <div className="text-[10px] text-gray-400 font-mono mt-0.5">{c.hex}</div>
                </div>
              </div>
            ))}
          </div>

          <div className="p-6 rounded-2xl bg-[#12121E] border border-white/10 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-white/5 border border-white/10 flex items-center justify-center font-bold text-base text-white">
                Aa
              </div>
              <div>
                <span className="font-bold text-white block">Official Typeface: Sora</span>
                <span className="text-gray-400">Modern · Clean · Highly Legible at All Scales</span>
              </div>
            </div>
            <div className="text-gray-400 font-mono text-[11px]">
              0 1 2 3 4 5 6 7 8 9 • A B C D E F G
            </div>
          </div>
        </div>
      </section>

      {/* 7. GET INVOLVED / COLLABORATE SECTION */}
      <section id="join" className="py-20 bg-[#0E0E17]">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 space-y-8">
          <div className="text-center space-y-3">
            <div className="text-xs font-bold uppercase tracking-widest text-[#A78BFA]">
              Connect With Us
            </div>
            <h2 className="text-2xl sm:text-4xl font-extrabold text-white">
              Collaborate With Equipo Kromium
            </h2>
            <p className="text-sm text-gray-400">
              Have an open-source project idea, want to contribute to TKMingle, or join the collective? Reach out directly.
            </p>
          </div>

          <div className="rounded-2xl bg-[#141422] border border-white/10 p-6 sm:p-8 shadow-2xl">
            {submitted ? (
              <div className="py-10 text-center space-y-3">
                <div className="w-12 h-12 rounded-full bg-[#6C4DFF]/20 text-[#A78BFA] mx-auto flex items-center justify-center">
                  <CheckCircle2 className="w-6 h-6" />
                </div>
                <h4 className="text-base font-bold text-white">Thank you for connecting!</h4>
                <p className="text-xs text-gray-400 max-w-sm mx-auto">
                  Your message has been delivered to Equipo Kromium. We will get back to your campus email soon.
                </p>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="space-y-4">
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-[11px] font-semibold text-gray-400 uppercase tracking-wider mb-1">
                      Your Name
                    </label>
                    <input
                      type="text"
                      required
                      value={contactName}
                      onChange={(e) => setContactName(e.target.value)}
                      placeholder="e.g. Vaishnav V."
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
                      placeholder="your.name@tkmce.ac.in"
                      className="w-full px-3.5 py-2.5 rounded-xl bg-[#0A0A0F] border border-white/10 text-xs text-white focus:outline-none focus:border-[#6C4DFF]"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-[11px] font-semibold text-gray-400 uppercase tracking-wider mb-1">
                    Your Primary Area
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
                    <option value="General Community">Curious Student / General Feedback</option>
                  </select>
                </div>

                <div>
                  <label className="block text-[11px] font-semibold text-gray-400 uppercase tracking-wider mb-1">
                    Message / What do you want to build?
                  </label>
                  <textarea
                    rows={4}
                    required
                    value={contactMessage}
                    onChange={(e) => setContactMessage(e.target.value)}
                    placeholder="Tell us what you're passionate about, your ideas, or how you'd like to collaborate..."
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
                    {submitting ? "Sending..." : "Submit to Equipo Kromium"}
                  </button>
                </div>
              </form>
            )}
          </div>
        </div>
      </section>

      {/* 8. FOOTER */}
      <footer className="bg-[#0A0A0F] py-10 border-t border-[#1C1C28]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col sm:flex-row items-center justify-between text-xs text-gray-400 gap-4">
          <div className="flex items-center gap-2.5">
            <Image
              src="/images/kromium/kromium_app_icon.png"
              alt="Kromium"
              width={20}
              height={20}
              className="rounded"
            />
            <span className="font-bold text-white">Equipo Kromium</span>
            <span>• Build · Open · Share</span>
          </div>

          <div className="flex items-center gap-6">
            <Link href="/" className="hover:text-white transition-colors">TKMingle Home</Link>
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
