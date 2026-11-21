"use client";

import React, { useState } from "react";
import Image from "next/image";
import Link from "next/link";
import {
  Compass,
  Users2,
  MessageSquare,
  ShieldCheck,
  Code2,
  Sparkles,
  ChevronDown,
  ArrowRight,
  Menu,
  X,
  CheckCircle2,
  Smartphone,
  Lock,
  Heart,
  Globe,
  GraduationCap,
} from "lucide-react";
import { MOCK_STUDENTS, MOCK_CIRCLES } from "@/lib/mockData";

export default function LandingPage() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [openFaqIndex, setOpenFaqIndex] = useState<number | null>(0);

  const faqs = [
    {
      q: "What is TKMingle?",
      a: "TKMingle is a private campus social discovery platform built exclusively for students of TKM College of Engineering (TKMCE), Kollam. It empowers students to connect with peers from different departments based on mutual interests, projects, and hobbies.",
    },
    {
      q: "Who can join?",
      a: "TKMingle is restricted strictly to verified students, researchers, and campus faculty of TKM College of Engineering. Registration is currently capped for our initial cohort of 400 students before expanding campus-wide.",
    },
    {
      q: "How does student verification work?",
      a: "During sign-up, students register with their student profile and can verify via institutional email OTP or campus ID verification. Only verified students can explore profiles and send connection requests.",
    },
    {
      q: "Is TKMingle free?",
      a: "Yes! TKMingle is 100% free, non-commercial, and open-source, built by the TKM student developer community.",
    },
    {
      q: "How do connections work?",
      a: "TKMingle enforces mutual consent. You can send a connection request with a short note. Direct 1:1 messaging is enabled only after both students accept the connection.",
    },
    {
      q: "Can I control who discovers me?",
      a: "Absolutely. You can toggle your discoverability status in Privacy Settings at any moment, customize who sees your contact handles, or pause discovery whenever you need focus time.",
    },
    {
      q: "Is the project open source?",
      a: "Yes! The mobile Flutter application, Next.js web portal, and Supabase backend architecture are completely open source for the TKM student developer ecosystem.",
    },
    {
      q: "Is there an Android/iOS application?",
      a: "Yes! TKMingle features a native-speed Flutter Android application (installable via APK) and iOS support, completely synchronized with this website through our unified Supabase backend.",
    },
  ];

  return (
    <div className="min-h-screen bg-brand-navy text-brand-text flex flex-col selection:bg-brand-purple selection:text-white">
      {/* 1. NAVBAR */}
      <header className="sticky top-0 z-50 bg-brand-navy/85 backdrop-blur-md border-b border-brand-border/60">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-20 flex items-center justify-between">
          {/* Brand Logo */}
          <Link href="/" className="flex items-center gap-3 group">
            <div className="relative w-11 h-11 rounded-xl bg-brand-navyCard border border-brand-border flex items-center justify-center p-1.5 transition-transform group-hover:scale-105 shadow-purple-glow">
              <Image
                src="/images/logo_compact.svg"
                alt="TKMingle Arch"
                width={36}
                height={36}
                className="w-auto h-auto"
                priority
              />
            </div>
            <div className="flex flex-col">
              <span className="text-xl font-bold tracking-tight text-white flex items-center gap-1.5">
                TKM<span className="text-brand-purple">ingle</span>
              </span>
              <span className="text-[10px] text-brand-muted tracking-wide uppercase font-medium">
                TKMCE Kollam
              </span>
            </div>
          </Link>

          {/* Desktop Nav Links */}
          <nav className="hidden md:flex items-center gap-8 text-sm font-medium text-brand-muted">
            <a href="#discover" className="hover:text-brand-text transition-colors">
              Discover
            </a>
            <a href="#circles" className="hover:text-brand-text transition-colors">
              Campus Circles
            </a>
            <a href="#connect" className="hover:text-brand-text transition-colors">
              Connect & Chat
            </a>
            <a href="#safety" className="hover:text-brand-text transition-colors">
              Safety
            </a>
            <a href="#opensource" className="hover:text-brand-text transition-colors">
              Open Source
            </a>
            <a href="#faq" className="hover:text-brand-text transition-colors">
              FAQ
            </a>
          </nav>

          {/* Action CTAs */}
          <div className="hidden md:flex items-center gap-4">
            <Link
              href="/login"
              className="px-4 py-2 text-sm font-semibold text-brand-text hover:text-white transition-colors"
            >
              Sign In
            </Link>
            <Link
              href="/register"
              className="px-5 py-2.5 text-sm font-semibold rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white shadow-purple-glow transition-all transform hover:-translate-y-0.5 active:translate-y-0"
            >
              Join TKMingle
            </Link>
          </div>

          {/* Mobile menu toggle */}
          <button
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className="md:hidden p-2 text-brand-muted hover:text-white"
            aria-label="Toggle navigation menu"
          >
            {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
          </button>
        </div>

        {/* Mobile menu dropdown */}
        {mobileMenuOpen && (
          <div className="md:hidden bg-brand-navySecondary border-b border-brand-border px-4 py-6 space-y-4">
            <a
              href="#discover"
              onClick={() => setMobileMenuOpen(false)}
              className="block text-base font-medium text-brand-muted hover:text-white"
            >
              Discover
            </a>
            <a
              href="#circles"
              onClick={() => setMobileMenuOpen(false)}
              className="block text-base font-medium text-brand-muted hover:text-white"
            >
              Campus Circles
            </a>
            <a
              href="#connect"
              onClick={() => setMobileMenuOpen(false)}
              className="block text-base font-medium text-brand-muted hover:text-white"
            >
              Connect & Chat
            </a>
            <a
              href="#safety"
              onClick={() => setMobileMenuOpen(false)}
              className="block text-base font-medium text-brand-muted hover:text-white"
            >
              Safety
            </a>
            <a
              href="#faq"
              onClick={() => setMobileMenuOpen(false)}
              className="block text-base font-medium text-brand-muted hover:text-white"
            >
              FAQ
            </a>
            <div className="pt-4 border-t border-brand-border/60 flex flex-col gap-3">
              <Link
                href="/login"
                className="w-full text-center py-2.5 text-sm font-semibold rounded-tk-btn border border-brand-border text-white"
              >
                Sign In
              </Link>
              <Link
                href="/register"
                className="w-full text-center py-2.5 text-sm font-semibold rounded-tk-btn bg-brand-purple text-white shadow-purple-glow"
              >
                Join TKMingle
              </Link>
            </div>
          </div>
        )}
      </header>

      {/* 2. HERO SECTION */}
      <section className="relative pt-12 pb-20 md:pt-20 md:pb-32 overflow-hidden">
        {/* Background ambient lighting */}
        <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[350px] bg-brand-purple/15 blur-[120px] rounded-full pointer-events-none" />
        <div className="absolute bottom-10 right-10 w-[400px] h-[300px] bg-brand-teal/10 blur-[100px] rounded-full pointer-events-none" />

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-8 items-center">
            {/* Left Content */}
            <div className="lg:col-span-7 text-center lg:text-left space-y-6">
              {/* College Verification Badge */}
              <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-brand-navyCard border border-brand-border/80 text-xs font-medium text-brand-lavender shadow-sm">
                <Sparkles className="w-3.5 h-3.5 text-brand-teal" />
                <span>Exclusively for TKM College of Engineering, Kollam</span>
              </div>

              {/* Main Headline */}
              <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold tracking-tight leading-[1.15] text-white">
                Your campus is bigger than{" "}
                <span className="gradient-text-purple">your circle.</span>
              </h1>

              {/* Supporting Text */}
              <p className="text-lg sm:text-xl text-brand-muted max-w-2xl font-normal leading-relaxed">
                Discover verified TKMCE students you have never met, explore common interests, join campus communities, and build meaningful college friendships across every department.
              </p>

              {/* Action Buttons */}
              <div className="pt-2 flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-4">
                <Link
                  href="/register"
                  className="w-full sm:w-auto px-8 py-4 text-base font-semibold rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white shadow-purple-glow transition-all transform hover:-translate-y-0.5 active:translate-y-0 flex items-center justify-center gap-2 group"
                >
                  Join TKMingle
                  <ArrowRight className="w-4 h-4 transition-transform group-hover:translate-x-1" />
                </Link>
                <a
                  href="#circles"
                  className="w-full sm:w-auto px-8 py-4 text-base font-semibold rounded-tk-btn bg-brand-navyCard hover:bg-brand-navySecondary border border-brand-border text-brand-text transition-colors flex items-center justify-center gap-2"
                >
                  Explore Communities
                </a>
              </div>

              {/* Trust & Metric Strip */}
              <div className="pt-6 grid grid-cols-3 gap-4 border-t border-brand-border/60 max-w-lg mx-auto lg:mx-0">
                <div>
                  <div className="text-2xl font-bold text-white">400</div>
                  <div className="text-xs text-brand-muted">Initial Cohort Cap</div>
                </div>
                <div>
                  <div className="text-2xl font-bold text-brand-teal">8+</div>
                  <div className="text-xs text-brand-muted">Departments</div>
                </div>
                <div>
                  <div className="text-2xl font-bold text-brand-lavender">100%</div>
                  <div className="text-xs text-brand-muted">Verified Students</div>
                </div>
              </div>
            </div>

            {/* Right Mockup Showcase */}
            <div className="lg:col-span-5 flex justify-center relative">
              <div className="relative w-full max-w-[340px] sm:max-w-[380px] rounded-[36px] p-3 bg-gradient-to-b from-brand-border via-brand-navyCard to-brand-navy shadow-2xl border border-brand-border/80">
                {/* Phone Speaker Notch */}
                <div className="absolute top-5 left-1/2 -translate-x-1/2 w-28 h-4 bg-brand-navy rounded-full z-20" />

                {/* Live App Screen Mockup Container */}
                <div className="relative rounded-[28px] overflow-hidden bg-brand-navySecondary border border-brand-border/60 aspect-[9/18.5] flex flex-col">
                  {/* Top Header of App */}
                  <div className="pt-7 pb-3 px-4 bg-brand-navy flex items-center justify-between border-b border-brand-border/40">
                    <div className="flex items-center gap-2">
                      <Image
                        src="/images/logo_compact.svg"
                        alt="TKMingle"
                        width={24}
                        height={24}
                      />
                      <span className="font-bold text-sm text-white">TKMingle</span>
                    </div>
                    <span className="text-[10px] px-2 py-0.5 rounded-full bg-brand-teal/15 text-brand-teal font-medium">
                      Verified
                    </span>
                  </div>

                  {/* App Screen Content Preview */}
                  <div className="p-4 flex-1 flex flex-col justify-between space-y-4 overflow-hidden bg-gradient-to-b from-brand-navySecondary to-brand-navy">
                    {/* Simulated Student Discovery Card */}
                    <div className="glass-panel rounded-2xl p-4 border border-brand-border/80 shadow-lg space-y-3">
                      <div className="flex items-center gap-3">
                        <div className="relative w-12 h-12 rounded-xl overflow-hidden border border-brand-purple/50">
                          <Image
                            src={MOCK_STUDENTS[1].profile_image}
                            alt="Sneha Varma"
                            fill
                            className="object-cover"
                          />
                        </div>
                        <div>
                          <div className="font-bold text-sm text-white flex items-center gap-1.5">
                            Sneha Varma
                            <CheckCircle2 className="w-3.5 h-3.5 text-brand-teal" />
                          </div>
                          <div className="text-xs text-brand-muted">
                            ECE • 3rd Year
                          </div>
                        </div>
                      </div>

                      <p className="text-xs text-brand-text/90 line-clamp-2">
                        Embedded systems explorer, avid coffee drinker, and casual badminton player.
                      </p>

                      <div className="flex flex-wrap gap-1.5 pt-1">
                        <span className="text-[10px] px-2 py-0.5 rounded-md bg-brand-purple/20 text-brand-lavender font-medium">
                          Robotics
                        </span>
                        <span className="text-[10px] px-2 py-0.5 rounded-md bg-brand-teal/15 text-brand-teal font-medium">
                          IoT
                        </span>
                        <span className="text-[10px] px-2 py-0.5 rounded-md bg-white/5 text-brand-muted font-medium">
                          UI/UX
                        </span>
                      </div>

                      <button className="w-full py-2 rounded-lg bg-brand-purple hover:bg-brand-purple/90 text-white text-xs font-semibold shadow-purple-glow flex items-center justify-center gap-1.5">
                        <Users2 className="w-3.5 h-3.5" />
                        Connect
                      </button>
                    </div>

                    {/* App Bottom Navigation Bar Mockup */}
                    <div className="py-2.5 px-6 rounded-2xl bg-brand-navyCard border border-brand-border flex justify-between items-center text-brand-muted">
                      <Compass className="w-4 h-4 text-brand-purple" />
                      <Users2 className="w-4 h-4" />
                      <MessageSquare className="w-4 h-4" />
                      <Smartphone className="w-4 h-4" />
                    </div>
                  </div>
                </div>

                {/* Floating Notification Pill */}
                <div className="absolute -bottom-4 -left-6 bg-brand-navyCard border border-brand-border/80 px-4 py-2.5 rounded-2xl shadow-xl flex items-center gap-3 animate-bounce">
                  <div className="w-8 h-8 rounded-full bg-brand-teal/20 text-brand-teal flex items-center justify-center">
                    <Heart className="w-4 h-4 fill-brand-teal" />
                  </div>
                  <div className="text-xs">
                    <div className="font-semibold text-white">Mutual Match!</div>
                    <div className="text-[10px] text-brand-muted">3 shared interests</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 3. DISCOVER PEOPLE SECTION */}
      <section id="discover" className="py-20 bg-brand-navySecondary/60 border-t border-brand-border/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-12">
          <div className="text-center max-w-3xl mx-auto space-y-4">
            <span className="text-xs font-bold uppercase tracking-wider text-brand-teal">
              Cross-Department Discovery
            </span>
            <h2 className="text-3xl sm:text-4xl font-extrabold text-white">
              Discover students outside your classroom.
            </h2>
            <p className="text-base sm:text-lg text-brand-muted">
              Most students spend four years only interacting with their own branch. TKMingle breaks departmental silos to connect CSE, Mech, Civil, ECE, EEE, Chem, and Arch students.
            </p>
          </div>

          {/* Student Profile Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {MOCK_STUDENTS.slice(0, 4).map((student) => (
              <div
                key={student.id}
                className="glass-panel glass-panel-hover rounded-tk-card p-5 flex flex-col justify-between space-y-4"
              >
                <div className="space-y-3">
                  <div className="flex items-center gap-3">
                    <div className="relative w-14 h-14 rounded-2xl overflow-hidden border border-brand-border">
                      <Image
                        src={student.profile_image}
                        alt={student.full_name}
                        fill
                        className="object-cover"
                      />
                    </div>
                    <div>
                      <h3 className="font-bold text-base text-white flex items-center gap-1.5">
                        {student.full_name}
                        <CheckCircle2 className="w-4 h-4 text-brand-teal flex-shrink-0" />
                      </h3>
                      <p className="text-xs text-brand-muted">{student.department}</p>
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
                        className="text-[10px] px-2 py-0.5 rounded-md bg-brand-navyCard border border-brand-border text-brand-lavender font-medium"
                      >
                        {interest}
                      </span>
                    ))}
                  </div>
                </div>

                <div className="pt-2 border-t border-brand-border/40">
                  <div className="text-[11px] text-brand-muted flex items-center gap-1.5 mb-3">
                    <GraduationCap className="w-3.5 h-3.5 text-brand-teal" />
                    <span className="truncate">{student.availability}</span>
                  </div>
                  <Link
                    href="/register"
                    className="w-full py-2 rounded-tk-btn bg-brand-purple/20 hover:bg-brand-purple border border-brand-purple/40 text-brand-lavender hover:text-white text-xs font-semibold transition-all flex items-center justify-center gap-1.5"
                  >
                    <Users2 className="w-3.5 h-3.5" />
                    Connect on TKMingle
                  </Link>
                </div>
              </div>
            ))}
          </div>

          <div className="text-center pt-4">
            <Link
              href="/app/discover"
              className="inline-flex items-center gap-2 text-sm font-semibold text-brand-lavender hover:text-white transition-colors"
            >
              Explore all campus profiles in web portal
              <ArrowRight className="w-4 h-4" />
            </Link>
          </div>
        </div>
      </section>

      {/* 4. CAMPUS CIRCLES SECTION */}
      <section id="circles" className="py-20 bg-brand-navy border-t border-brand-border/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-12">
          <div className="text-center max-w-3xl mx-auto space-y-4">
            <span className="text-xs font-bold uppercase tracking-wider text-brand-purple">
              Campus Communities
            </span>
            <h2 className="text-3xl sm:text-4xl font-extrabold text-white">
              Circles for every passion and club.
            </h2>
            <p className="text-base sm:text-lg text-brand-muted">
              Whether you are coding open-source software, racing solar cars, or jamming after hours, join student-led circles to coordinate projects and participate in discussions.
            </p>
          </div>

          {/* Circles Grid */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {MOCK_CIRCLES.slice(0, 3).map((circle) => (
              <div
                key={circle.id}
                className="glass-panel glass-panel-hover rounded-tk-card p-6 flex flex-col justify-between space-y-5"
              >
                <div className="space-y-4">
                  <div className="flex items-center justify-between">
                    <div className="w-12 h-12 rounded-2xl bg-brand-purple/15 text-brand-lavender flex items-center justify-center font-bold text-lg border border-brand-purple/30">
                      {circle.name.charAt(0)}
                    </div>
                    <span className="text-xs px-2.5 py-1 rounded-full bg-brand-navyCard border border-brand-border text-brand-teal font-medium">
                      {circle.category}
                    </span>
                  </div>
                  <div>
                    <h3 className="font-bold text-lg text-white">{circle.name}</h3>
                    <p className="text-xs text-brand-muted mt-1 leading-relaxed">
                      {circle.description}
                    </p>
                  </div>
                </div>

                <div className="pt-4 border-t border-brand-border/60 flex items-center justify-between text-xs">
                  <span className="text-brand-muted font-medium">
                    {circle.member_count} Members
                  </span>
                  <Link
                    href="/register"
                    className="text-brand-teal hover:text-white font-semibold flex items-center gap-1"
                  >
                    Join Circle <ArrowRight className="w-3.5 h-3.5" />
                  </Link>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* 5. CONNECT AND CHAT SECTION */}
      <section id="connect" className="py-20 bg-brand-navySecondary/60 border-t border-brand-border/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
            <div className="lg:col-span-6 space-y-6">
              <span className="text-xs font-bold uppercase tracking-wider text-brand-teal">
                Mutual Consent Communication
              </span>
              <h2 className="text-3xl sm:text-4xl font-extrabold text-white leading-tight">
                Connect intentionally. Chat with peace of mind.
              </h2>
              <p className="text-base sm:text-lg text-brand-muted leading-relaxed">
                No unsolicited DMs or spam. On TKMingle, private messaging is unlocked only when both students mutually accept a connection request.
              </p>

              <div className="space-y-4 pt-2">
                <div className="flex items-start gap-3">
                  <div className="w-8 h-8 rounded-lg bg-brand-purple/20 text-brand-purple flex items-center justify-center flex-shrink-0 mt-0.5">
                    <CheckCircle2 className="w-4 h-4" />
                  </div>
                  <div>
                    <h4 className="text-sm font-semibold text-white">Mutual Approval Required</h4>
                    <p className="text-xs text-brand-muted">Both parties must say yes before a chat room opens.</p>
                  </div>
                </div>

                <div className="flex items-start gap-3">
                  <div className="w-8 h-8 rounded-lg bg-brand-teal/20 text-brand-teal flex items-center justify-center flex-shrink-0 mt-0.5">
                    <Lock className="w-4 h-4" />
                  </div>
                  <div>
                    <h4 className="text-sm font-semibold text-white">Row Level Security Encrypted</h4>
                    <p className="text-xs text-brand-muted">Only members of the conversation can query or view message payloads.</p>
                  </div>
                </div>

                <div className="flex items-start gap-3">
                  <div className="w-8 h-8 rounded-lg bg-brand-lavender/20 text-brand-lavender flex items-center justify-center flex-shrink-0 mt-0.5">
                    <Sparkles className="w-4 h-4" />
                  </div>
                  <div>
                    <h4 className="text-sm font-semibold text-white">Real-Time Synchronization</h4>
                    <p className="text-xs text-brand-muted">Instant delivery across mobile and web via Supabase Realtime.</p>
                  </div>
                </div>
              </div>
            </div>

            {/* Chat Mockup Card */}
            <div className="lg:col-span-6">
              <div className="glass-panel rounded-2xl border border-brand-border p-6 shadow-2xl space-y-4 max-w-md mx-auto">
                {/* Chat Top Bar */}
                <div className="flex items-center gap-3 pb-3 border-b border-brand-border/60">
                  <div className="relative w-10 h-10 rounded-xl overflow-hidden border border-brand-purple/50">
                    <Image
                      src={MOCK_STUDENTS[1].profile_image}
                      alt="Sneha"
                      fill
                      className="object-cover"
                    />
                  </div>
                  <div>
                    <div className="font-bold text-sm text-white flex items-center gap-1.5">
                      Sneha Varma
                      <span className="w-2 h-2 rounded-full bg-brand-teal inline-block" />
                    </div>
                    <div className="text-[10px] text-brand-muted">Active now • TKMCE</div>
                  </div>
                </div>

                {/* Messages Feed */}
                <div className="space-y-3 py-2">
                  <div className="flex flex-col items-start">
                    <div className="bg-brand-navyCard border border-brand-border/80 px-3.5 py-2.5 rounded-2xl rounded-tl-sm text-xs text-brand-text max-w-[80%]">
                      Hey Arjun! Saw your post about HackTKM.
                    </div>
                    <span className="text-[9px] text-brand-muted px-1 mt-1">2:30 PM</span>
                  </div>

                  <div className="flex flex-col items-end">
                    <div className="bg-brand-purple px-3.5 py-2.5 rounded-2xl rounded-tr-sm text-xs text-white max-w-[80%] shadow-purple-glow">
                      Hey Sneha! Yes, looking for someone strong in IoT hardware for the smart campus track!
                    </div>
                    <span className="text-[9px] text-brand-lavender px-1 mt-1">2:35 PM • Read</span>
                  </div>

                  <div className="flex flex-col items-start">
                    <div className="bg-brand-navyCard border border-brand-border/80 px-3.5 py-2.5 rounded-2xl rounded-tl-sm text-xs text-brand-text max-w-[80%]">
                      Count me in! Let’s meet at the Amphi after 4:30.
                    </div>
                    <span className="text-[9px] text-brand-muted px-1 mt-1">2:40 PM</span>
                  </div>
                </div>

                {/* Input Field Placeholder */}
                <div className="pt-2 flex items-center gap-2">
                  <div className="flex-1 py-2 px-3 rounded-tk-btn bg-brand-navyCard border border-brand-border text-xs text-brand-muted">
                    Type a message...
                  </div>
                  <button className="p-2 rounded-tk-btn bg-brand-purple text-white shadow-purple-glow">
                    <ArrowRight className="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 6. YOUR CAMPUS PROFILE SECTION */}
      <section id="profile" className="py-20 bg-brand-navy border-t border-brand-border/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center space-y-12">
          <div className="max-w-3xl mx-auto space-y-4">
            <span className="text-xs font-bold uppercase tracking-wider text-brand-lavender">
              Express Yourself
            </span>
            <h2 className="text-3xl sm:text-4xl font-extrabold text-white">
              Your Campus Profile, Tailored to You.
            </h2>
            <p className="text-base sm:text-lg text-brand-muted">
              Add your tech stack, hobbies, availability, and languages so other students can discover what makes you unique.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 text-left">
            <div className="glass-panel rounded-tk-card p-6 space-y-3">
              <div className="w-10 h-10 rounded-xl bg-brand-purple/20 text-brand-purple flex items-center justify-center font-bold">
                1
              </div>
              <h3 className="font-bold text-lg text-white">Interests & Hobbies</h3>
              <p className="text-xs text-brand-muted leading-relaxed">
                Whether you love competitive coding, rock climbing, robotics, sketching, or anime, tag your genuine passions.
              </p>
            </div>

            <div className="glass-panel rounded-tk-card p-6 space-y-3">
              <div className="w-10 h-10 rounded-xl bg-brand-teal/20 text-brand-teal flex items-center justify-center font-bold">
                2
              </div>
              <h3 className="font-bold text-lg text-white">Availability Tags</h3>
              <p className="text-xs text-brand-muted leading-relaxed">
                Let peers know when you are free to hang out: &quot;Free after 4:30 PM at the Library quadrangle&quot; or &quot;Open for weekend hackathons&quot;.
              </p>
            </div>

            <div className="glass-panel rounded-tk-card p-6 space-y-3">
              <div className="w-10 h-10 rounded-xl bg-brand-lavender/20 text-brand-lavender flex items-center justify-center font-bold">
                3
              </div>
              <h3 className="font-bold text-lg text-white">Discoverability Controls</h3>
              <p className="text-xs text-brand-muted leading-relaxed">
                Keep your profile visible when you want to make friends, or turn off discovery with a single switch during exam seasons.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* 7. PRIVACY AND SAFETY SECTION */}
      <section id="safety" className="py-20 bg-brand-navySecondary/60 border-t border-brand-border/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-12">
          <div className="text-center max-w-3xl mx-auto space-y-4">
            <span className="text-xs font-bold uppercase tracking-wider text-brand-teal">
              Safety & Campus Trust
            </span>
            <h2 className="text-3xl sm:text-4xl font-extrabold text-white">
              A private, protected space for TKMCE.
            </h2>
            <p className="text-base sm:text-lg text-brand-muted">
              We take student privacy and safety seriously with campus-only verification and server-side safety checks.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <div className="glass-panel rounded-tk-card p-6 space-y-3">
              <ShieldCheck className="w-8 h-8 text-brand-teal" />
              <h4 className="font-bold text-base text-white">Student Verification</h4>
              <p className="text-xs text-brand-muted leading-relaxed">
                Every member is verified via institutional email OTP or campus ID inspection to guarantee an authentic student network.
              </p>
            </div>

            <div className="glass-panel rounded-tk-card p-6 space-y-3">
              <Lock className="w-8 h-8 text-brand-purple" />
              <h4 className="font-bold text-base text-white">Row Level Security</h4>
              <p className="text-xs text-brand-muted leading-relaxed">
                PostgreSQL Row Level Security policies enforce that only you and your mutual connections can read private information.
              </p>
            </div>

            <div className="glass-panel rounded-tk-card p-6 space-y-3">
              <Users2 className="w-8 h-8 text-brand-lavender" />
              <h4 className="font-bold text-base text-white">Instant Block</h4>
              <p className="text-xs text-brand-muted leading-relaxed">
                Block any user with a single tap. Blocked accounts can never discover you, send requests, or see your activity.
              </p>
            </div>

            <div className="glass-panel rounded-tk-card p-6 space-y-3">
              <Code2 className="w-8 h-8 text-brand-teal" />
              <h4 className="font-bold text-base text-white">Zero Third-Party Ads</h4>
              <p className="text-xs text-brand-muted leading-relaxed">
                No corporate tracking scripts, no commercial ad networks, and no selling student data. TKMingle is built for campus good.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* 8. OPEN SOURCE SECTION */}
      <section id="opensource" className="py-20 bg-brand-navy border-t border-brand-border/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="glass-panel rounded-3xl p-8 sm:p-12 border border-brand-purple/40 relative overflow-hidden text-center space-y-6 shadow-purple-glow">
            <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-brand-purple/20 text-brand-lavender text-xs font-semibold">
              <Code2 className="w-4 h-4 text-brand-teal" />
              <span>Free & Open Source Project</span>
            </div>

            <h2 className="text-3xl sm:text-4xl font-extrabold text-white max-w-2xl mx-auto">
              Built by TKM students, for the TKM student community.
            </h2>

            <p className="text-base text-brand-muted max-w-2xl mx-auto leading-relaxed">
              TKMingle is an open-source initiative designed to foster cross-departmental collaboration, student engineering excellence, and open peer review. Interested in contributing? Join our GitHub repository.
            </p>

            <div className="pt-2 flex flex-col sm:flex-row items-center justify-center gap-4">
              <a
                href="https://github.com/tkmce/tkmingle"
                target="_blank"
                rel="noreferrer"
                className="px-6 py-3 rounded-tk-btn bg-brand-navyCard hover:bg-brand-navySecondary border border-brand-border text-white text-sm font-semibold flex items-center gap-2 transition-colors"
              >
                <Globe className="w-4 h-4 text-brand-teal" />
                Explore on GitHub
              </a>
              <Link
                href="/register"
                className="px-6 py-3 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white text-sm font-semibold shadow-purple-glow transition-all"
              >
                Get Started
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* 9. FAQ SECTION */}
      <section id="faq" className="py-20 bg-brand-navySecondary/60 border-t border-brand-border/50">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 space-y-8">
          <div className="text-center space-y-4">
            <span className="text-xs font-bold uppercase tracking-wider text-brand-purple">
              Frequently Asked Questions
            </span>
            <h2 className="text-3xl sm:text-4xl font-extrabold text-white">
              Everything you need to know.
            </h2>
          </div>

          <div className="space-y-4">
            {faqs.map((faq, index) => {
              const isOpen = openFaqIndex === index;
              return (
                <div
                  key={faq.q}
                  className="glass-panel rounded-2xl border border-brand-border overflow-hidden transition-all"
                >
                  <button
                    onClick={() => setOpenFaqIndex(isOpen ? null : index)}
                    className="w-full p-5 text-left flex items-center justify-between font-semibold text-white hover:text-brand-lavender text-sm sm:text-base transition-colors"
                  >
                    <span>{faq.q}</span>
                    <ChevronDown
                      className={`w-5 h-5 text-brand-muted transition-transform duration-200 ${
                        isOpen ? "rotate-180 text-brand-purple" : ""
                      }`}
                    />
                  </button>
                  {isOpen && (
                    <div className="px-5 pb-5 text-xs sm:text-sm text-brand-muted leading-relaxed border-t border-brand-border/40 pt-3">
                      {faq.a}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* 10. FOOTER */}
      <footer className="bg-brand-navy border-t border-brand-border/80 pt-16 pb-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-12">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div className="space-y-4 md:col-span-2">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-brand-navyCard border border-brand-border flex items-center justify-center p-1.5">
                  <Image
                    src="/images/logo_compact.svg"
                    alt="TKMingle"
                    width={32}
                    height={32}
                  />
                </div>
                <span className="text-xl font-bold tracking-tight text-white">
                  TKM<span className="text-brand-purple">ingle</span>
                </span>
              </div>
              <p className="text-xs text-brand-muted max-w-sm leading-relaxed">
                Your campus. Your people. Your connections. The student social discovery network for TKM College of Engineering, Kollam, Kerala.
              </p>
              <div className="text-[11px] text-brand-lavender">
                Initial Registration Target: 400 Students • Campus Expansion: 4,000 Students
              </div>
            </div>

            <div className="space-y-3">
              <h4 className="text-xs font-bold uppercase tracking-wider text-white">Platform</h4>
              <ul className="space-y-2 text-xs text-brand-muted">
                <li><a href="#discover" className="hover:text-white transition-colors">Discover Students</a></li>
                <li><a href="#circles" className="hover:text-white transition-colors">Campus Circles</a></li>
                <li><a href="#connect" className="hover:text-white transition-colors">Connect & Chat</a></li>
                <li><Link href="/login" className="hover:text-white transition-colors">Web Portal Login</Link></li>
                <li><Link href="/register" className="hover:text-white transition-colors">Student Registration</Link></li>
              </ul>
            </div>

            <div className="space-y-3">
              <h4 className="text-xs font-bold uppercase tracking-wider text-white">College & Legal</h4>
              <ul className="space-y-2 text-xs text-brand-muted">
                <li><span className="text-brand-text">TKMCE, Kollam - 691005</span></li>
                <li><a href="#safety" className="hover:text-white transition-colors">Safety Guidelines</a></li>
                <li><a href="#opensource" className="hover:text-white transition-colors">Open Source Policy</a></li>
                <li><span className="text-brand-muted">Privacy Policy (Strict Campus RLS)</span></li>
              </ul>
            </div>
          </div>

          <div className="pt-8 border-t border-brand-border/60 flex flex-col sm:flex-row items-center justify-between text-xs text-brand-muted gap-4">
            <p>© 2026 TKMingle • TKM College of Engineering Student Community.</p>
            <div className="flex items-center gap-6">
              <span>All rights reserved</span>
              <a href="#faq" className="hover:text-white transition-colors">FAQ</a>
              <a href="https://github.com/tkmce/tkmingle" target="_blank" rel="noreferrer" className="hover:text-white transition-colors">GitHub</a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
