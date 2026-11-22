"use client";

import React, { useState } from "react";
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
} from "lucide-react";
import { MOCK_STUDENTS, MOCK_CIRCLES } from "@/lib/mockData";
import UserAvatar from "@/components/UserAvatar";

export default function LandingPage() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [openFaqIndex, setOpenFaqIndex] = useState<number | null>(0);

  // Contact Modal State
  const [contactModalOpen, setContactModalOpen] = useState(false);
  const [contactCategory, setContactCategory] = useState("Suggestions & Feedback");
  const [contactName, setContactName] = useState("");
  const [contactEmail, setContactEmail] = useState("");
  const [contactDept, setContactDept] = useState("Computer Science & Engineering");
  const [contactMessage, setContactMessage] = useState("");
  const [contactSubmitting, setContactSubmitting] = useState(false);
  const [contactSuccess, setContactSuccess] = useState(false);

  const handleContactSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!contactMessage.trim()) return;

    setContactSubmitting(true);
    // Simulate immediate clean submission to creator team inbox
    await new Promise((r) => setTimeout(r, 600));
    setContactSubmitting(false);
    setContactSuccess(true);
    setTimeout(() => {
      setContactSuccess(false);
      setContactModalOpen(false);
      setContactMessage("");
    }, 2200);
  };

  const faqs = [
    {
      q: "What is TKMingle?",
      a: "TKMingle is a student platform built exclusively for TKM College of Engineering (TKMCE), Kollam. It helps students discover peers from other departments based on shared interests, projects, and activities.",
    },
    {
      q: "Who can join TKMingle?",
      a: "Access is limited to students and members of TKM College of Engineering. Accounts are verified using institutional credentials.",
    },
    {
      q: "How do student connections work?",
      a: "Connections are based on mutual consent. You can send a connection request with a brief message. Direct 1:1 messaging opens only when both students accept.",
    },
    {
      q: "Can I control my profile visibility?",
      a: "Yes. You can turn campus discovery on or off at any time in Settings. When discovery is turned off, your profile does not appear in the student directory.",
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
          <Link href="/" className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-brand-navyCard border border-brand-border flex items-center justify-center p-1.5">
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
          <nav className="hidden md:flex items-center gap-7 text-sm font-medium text-brand-muted">
            <a href="#discover" className="hover:text-white transition-colors">
              Discover
            </a>
            <a href="#circles" className="hover:text-white transition-colors">
              Campus Circles
            </a>
            <a href="#connect" className="hover:text-white transition-colors">
              Connect & Chat
            </a>
            <a href="#faq" className="hover:text-white transition-colors">
              FAQ
            </a>
          </nav>

          {/* Action CTAs */}
          <div className="hidden md:flex items-center gap-3">
            <Link
              href="/login"
              className="px-4 py-2 text-sm font-semibold text-brand-text hover:text-white transition-colors"
            >
              Sign In
            </Link>
            <Link
              href="/register"
              className="px-4 py-2 text-sm font-semibold rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white transition-colors"
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
          <div className="md:hidden bg-brand-navySecondary border-b border-brand-border px-4 py-5 space-y-3">
            <a
              href="#discover"
              onClick={() => setMobileMenuOpen(false)}
              className="block text-sm font-medium text-brand-muted hover:text-white"
            >
              Discover
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
              Connect & Chat
            </a>
            <a
              href="#faq"
              onClick={() => setMobileMenuOpen(false)}
              className="block text-sm font-medium text-brand-muted hover:text-white"
            >
              FAQ
            </a>
            <div className="pt-3 border-t border-brand-border/60 flex flex-col gap-2">
              <Link
                href="/login"
                className="w-full text-center py-2 text-sm font-semibold rounded-tk-btn border border-brand-border text-white"
              >
                Sign In
              </Link>
              <Link
                href="/register"
                className="w-full text-center py-2 text-sm font-semibold rounded-tk-btn bg-brand-purple text-white"
              >
                Join TKMingle
              </Link>
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

              <div className="pt-2 flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-3">
                <Link
                  href="/register"
                  className="w-full sm:w-auto px-6 py-3 text-sm font-semibold rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white transition-colors flex items-center justify-center gap-2"
                >
                  Join TKMingle
                  <ArrowRight className="w-4 h-4" />
                </Link>
                <a
                  href="#discover"
                  className="w-full sm:w-auto px-6 py-3 text-sm font-semibold rounded-tk-btn bg-brand-navyCard hover:bg-brand-navySecondary border border-brand-border text-brand-text transition-colors flex items-center justify-center"
                >
                  Browse Campus Profiles
                </a>
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
              <div className="w-full max-w-sm glass-panel rounded-2xl p-5 border border-brand-border/80 space-y-4">
                <div className="flex items-center gap-3">
                  <UserAvatar
                    src={MOCK_STUDENTS[1].profile_image}
                    name="Sneha Varma"
                    size={56}
                    className="rounded-2xl border border-brand-purple/40"
                  />
                  <div>
                    <h3 className="font-bold text-base text-white flex items-center gap-1.5">
                      Sneha Varma
                      <CheckCircle2 className="w-4 h-4 text-brand-teal" />
                    </h3>
                    <p className="text-xs text-brand-muted">
                      Electronics &amp; Communication • 3rd Year
                    </p>
                    <span className="text-[10px] text-brand-teal font-medium">
                      Verified Student
                    </span>
                  </div>
                </div>

                <p className="text-xs text-brand-text/90 leading-relaxed">
                  Embedded systems explorer, coffee drinker, and casual badminton player. Always curious about creative web projects!
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
                    href="/register"
                    className="px-3 py-1.5 rounded-tk-btn bg-brand-purple text-white text-xs font-medium"
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
            {MOCK_STUDENTS.slice(0, 4).map((student) => (
              <div
                key={student.id}
                className="glass-panel rounded-tk-card p-5 flex flex-col justify-between space-y-4 border border-brand-border/70"
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
                    href="/register"
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
              href="/login"
              className="inline-flex items-center gap-1.5 text-xs font-semibold text-brand-lavender hover:text-white transition-colors"
            >
              Sign in to browse all students in directory
              <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          </div>
        </div>
      </section>

      {/* 4. CAMPUS CIRCLES SECTION */}
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
                className="glass-panel rounded-tk-card p-5 flex flex-col justify-between space-y-4 border border-brand-border/70"
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
                    href="/register"
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

      {/* 5. CONNECT AND CHAT SECTION */}
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
              <div className="glass-panel rounded-2xl border border-brand-border p-5 space-y-3 max-w-md mx-auto">
                <div className="flex items-center gap-3 pb-3 border-b border-brand-border/60">
                  <UserAvatar
                    src={MOCK_STUDENTS[1].profile_image}
                    name="Sneha Varma"
                    size={36}
                    isOnline={true}
                  />
                  <div>
                    <div className="font-bold text-xs text-white flex items-center gap-1.5">
                      Sneha Varma
                      <span className="w-2 h-2 rounded-full bg-brand-teal inline-block" />
                    </div>
                    <div className="text-[10px] text-brand-muted">Active • ECE 3rd Year</div>
                  </div>
                </div>

                <div className="space-y-2.5 py-1">
                  <div className="flex flex-col items-start">
                    <div className="bg-brand-navyCard border border-brand-border/80 px-3 py-2 rounded-xl text-xs text-brand-text max-w-[85%]">
                      Hey! Saw your project post in Coding Club.
                    </div>
                  </div>

                  <div className="flex flex-col items-end">
                    <div className="bg-brand-purple px-3 py-2 rounded-xl text-xs text-white max-w-[85%]">
                      Hey Sneha! Yes, looking for someone for the IoT hardware track.
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

      {/* 6. FAQ SECTION */}
      <section id="faq" className="py-16 bg-brand-navy border-b border-brand-border/50">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 space-y-6">
          <div className="text-center space-y-2">
            <h2 className="text-2xl sm:text-3xl font-extrabold text-white">
              Frequently Asked Questions
            </h2>
            <p className="text-xs text-brand-muted">
              Common questions about joining and using TKMingle.
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

      {/* 7. NEW BOTTOM COMMUNITY SECTION (Replaces Open Source / GitHub Promo) */}
      <section className="py-16 bg-brand-navySecondary/60 border-b border-brand-border/60">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center space-y-5">
          <h2 className="text-2xl sm:text-3xl font-extrabold text-white">
            Have an idea or want to get involved?
          </h2>

          <p className="text-sm text-brand-muted max-w-2xl mx-auto leading-relaxed">
            TKMingle is built for the TKMCE student community. Have suggestions, found an issue, or interested in contributing to the platform? Reach out to the creator team.
          </p>

          <div className="pt-2">
            <button
              onClick={() => setContactModalOpen(true)}
              className="px-6 py-2.5 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white text-xs font-semibold shadow-purple-glow transition-all"
            >
              Contact the Creator Team
            </button>
          </div>
        </div>
      </section>

      {/* 8. FOOTER */}
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
                Campus social discovery platform for TKM College of Engineering, Kollam, Kerala.
              </p>
            </div>

            <div className="space-y-2">
              <h4 className="text-xs font-bold uppercase tracking-wider text-white">Navigation</h4>
              <ul className="space-y-1.5 text-xs text-brand-muted">
                <li><a href="#discover" className="hover:text-white transition-colors">Discover Students</a></li>
                <li><a href="#circles" className="hover:text-white transition-colors">Campus Circles</a></li>
                <li><a href="#connect" className="hover:text-white transition-colors">Connect &amp; Chat</a></li>
                <li><Link href="/login" className="hover:text-white transition-colors">Student Login</Link></li>
                <li><Link href="/register" className="hover:text-white transition-colors">Join TKMingle</Link></li>
              </ul>
            </div>

            <div className="space-y-2">
              <h4 className="text-xs font-bold uppercase tracking-wider text-white">College</h4>
              <ul className="space-y-1.5 text-xs text-brand-muted">
                <li><span className="text-brand-text">TKMCE, Karicode, Kollam</span></li>
                <li><span className="text-brand-muted">Pin: 691005, Kerala</span></li>
                <li>
                  <button
                    onClick={() => setContactModalOpen(true)}
                    className="text-brand-lavender hover:text-white transition-colors"
                  >
                    Contact Creator Team
                  </button>
                </li>
              </ul>
            </div>
          </div>

          <div className="pt-6 border-t border-brand-border/60 flex flex-col sm:flex-row items-center justify-between text-xs text-brand-muted gap-3">
            <p>© 2026 TKMingle • TKM College of Engineering.</p>
            <div className="flex items-center gap-5">
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

      {/* CONTACT CREATOR TEAM MODAL */}
      {contactModalOpen && (
        <div className="fixed inset-0 z-50 bg-black/70 backdrop-blur-sm flex items-center justify-center p-4">
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
                Contact the Creator Team
              </h3>
              <p className="text-xs text-brand-muted">
                Send feedback, suggest ideas, report an issue, or ask about getting involved with TKMingle.
              </p>
            </div>

            {contactSuccess ? (
              <div className="py-8 text-center space-y-3">
                <div className="w-12 h-12 rounded-full bg-brand-teal/20 text-brand-teal mx-auto flex items-center justify-center">
                  <CheckCircle2 className="w-6 h-6" />
                </div>
                <h4 className="text-sm font-bold text-white">Thank you for reaching out!</h4>
                <p className="text-xs text-brand-muted">
                  Your message has been sent to the TKMingle creator team.
                </p>
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
                    <option value="Join the Creator Team">Interested in Contributing / Joining</option>
                  </select>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <div>
                    <label className="block text-[11px] font-semibold text-brand-muted uppercase tracking-wider mb-1">
                      Your Name
                    </label>
                    <input
                      type="text"
                      required
                      value={contactName}
                      onChange={(e) => setContactName(e.target.value)}
                      placeholder="e.g. Rahul M."
                      className="w-full px-3 py-2 rounded-tk-btn bg-brand-navy border border-brand-border text-xs text-white focus:outline-none focus:border-brand-purple"
                    />
                  </div>

                  <div>
                    <label className="block text-[11px] font-semibold text-brand-muted uppercase tracking-wider mb-1">
                      Campus Email
                    </label>
                    <input
                      type="email"
                      required
                      value={contactEmail}
                      onChange={(e) => setContactEmail(e.target.value)}
                      placeholder="name@tkmce.ac.in"
                      className="w-full px-3 py-2 rounded-tk-btn bg-brand-navy border border-brand-border text-xs text-white focus:outline-none focus:border-brand-purple"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-[11px] font-semibold text-brand-muted uppercase tracking-wider mb-1">
                    Department &amp; Year
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
                    Message
                  </label>
                  <textarea
                    rows={4}
                    required
                    value={contactMessage}
                    onChange={(e) => setContactMessage(e.target.value)}
                    placeholder="Describe your idea, issue, or how you would like to help..."
                    className="w-full p-3 rounded-tk-btn bg-brand-navy border border-brand-border text-xs text-white focus:outline-none focus:border-brand-purple"
                  />
                </div>

                <div className="pt-2 flex items-center justify-end gap-2">
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
                    className="px-5 py-2 rounded-tk-btn bg-brand-purple hover:bg-brand-purple/90 text-white text-xs font-semibold flex items-center gap-1.5"
                  >
                    <Send className="w-3.5 h-3.5" />
                    {contactSubmitting ? "Sending..." : "Submit Message"}
                  </button>
                </div>
              </form>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
