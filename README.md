# TKMingle — Campus Social Discovery Platform

> *"Your campus. Your people. Your connections."*

[![TKMCE](https://img.shields.io/badge/TKMCE-Kollam%2C%20Kerala-8875FF?style=flat-square)](https://tkmce.ac.in)
[![Next.js](https://img.shields.io/badge/Next.js-14.2%20App%20Router-0A1026?style=flat-square&logo=next.js)](https://nextjs.org)
[![Flutter](https://img.shields.io/badge/Flutter-3.24-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL%20%2B%20RLS-3ECF8E?style=flat-square&logo=supabase)](https://supabase.com)
[![Vercel](https://img.shields.io/badge/Vercel-Deployment%20Ready-000000?style=flat-square&logo=vercel)](https://vercel.com)

---

## 🏛️ What is TKMingle?

**TKMingle** is a private, campus-exclusive social discovery platform engineered specifically for the student and academic community of **TKM College of Engineering (TKMCE), Kollam, Kerala, India**.

Traditional campus life often leaves students isolated within their own academic branch. A 3rd-year Computer Science student might never interact with talented innovators in Mechanical, Electrical, Civil, Chemical, or Architecture. TKMingle breaks down departmental silos by connecting students based on **mutual passions, technical projects, creative arts, and shared interests**.

TKMingle is **not** a conventional college management app or a superficial dating app — it is a focused collegiate ecosystem that facilitates:
1. **Cross-Departmental Discovery** — Discover peers with complementary skills across all 8+ TKMCE departments.
2. **Mutual-Consent Connections** — Direct 1:1 messaging is enabled only after both students accept a connection request.
3. **Campus Circles** — Participate in discussions across IEEE TKMCE, IEDC, TKM Coding Club (FOSS), RoboTKM, and Arts & Cultural societies.
4. **Verified Student Privacy** — Strict institutional email OTP or campus ID verification. Enforced by PostgreSQL Row Level Security (RLS).
5. **Initial Pioneer Cohort** — Configured for an initial cap of 400 students with seamless horizontal scaling to the full campus body of 4,000+ students.

---

## 🎨 Official Brand Identity

The TKMingle brand visual identity honors the distinctive architectural heritage of TKM College of Engineering (its traditional domes, pointed arches, and symmetrical facade) merged with interconnected silhouettes symbolizing campus fellowship.

- **Deep Navy:** `#0A1026` (Primary Background)
- **Secondary Background:** `#141A32`
- **Card Background:** `#191E35`
- **TKM Purple / Electric Violet:** `#8875FF` (Primary Accent)
- **Lavender:** `#B9A9FF` (Secondary Accent)
- **Accent Teal:** `#50D6C2` (Highlights & Verification)
- **Primary Text:** `#F6F5FF`
- **Muted Text:** `#A5A9BC`
- **Border:** `#303451`
- **Typography:** **Sora** (Bold, SemiBold, Medium, Regular)

---

## 📦 Monorepo Architecture

```
/
├── mobile/               # Native Flutter Mobile Application (Android & iOS)
│   ├── lib/              # 26 screens, Riverpod state, clean Repository Pattern
│   ├── android/          # Android build configuration, adaptive mipmaps, minSdk 23
│   ├── assets/           # Scalable vector assets (logo_primary.svg, splash, app_icon)
│   └── test/             # Comprehensive core engine test suite (100% passing)
│
├── web/                  # Official Next.js 14+ Responsive Website
│   ├── src/app/          # App Router: Landing Page + Authenticated Web Portal
│   │   ├── (auth)/       # /login, /register, /verify-email, /forgot-password
│   │   └── app/          # /discover, /circles, /messages, /profile, /settings
│   ├── public/           # Static brand SVGs and mockups
│   └── tailwind.config.ts# Centralized TKMingle brand color tokens and Sora font
│
├── supabase/             # Unified PostgreSQL Backend Architecture
│   ├── migrations/       # 15+ normalized tables, indexes, triggers, and RLS policies
│   ├── functions/        # Edge functions (notify-user, verify-student)
│   ├── seed.sql          # Realistic synthetic seed data for TKMCE departments & clubs
│   └── config.toml       # Supabase CLI local development configuration
│
├── shared/               # Shared brand assets, vectors, and design tokens
├── vercel.json           # Vercel deployment configuration
├── PROJECT_STATUS.md     # Ongoing phase and release tracker
└── .env.example          # Environment variable template
```

---

## 🚀 Quick Start Guide

### 1. Prerequisites
- **Node.js** v18+ & **npm**
- **Flutter SDK** v3.24+ & **Java JDK 17**
- **Supabase CLI** (optional for local database emulator)

### 2. Environment Configuration
Copy `.env.example` to `web/.env.local`:
```bash
cp .env.example web/.env.local
```
Fill in your Supabase project credentials:
```ini
NEXT_PUBLIC_SUPABASE_URL="https://your-project.supabase.co"
NEXT_PUBLIC_SUPABASE_ANON_KEY="your-anon-key"
SUPABASE_SERVICE_ROLE_KEY="your-service-role-key" # Server-only
NEXT_PUBLIC_SITE_URL="https://tkmingle.vercel.app"
```

### 3. Running the Next.js Web Portal
```bash
cd web
npm install
npm run dev
```
Open [http://localhost:3000](http://localhost:3000) to view the landing page and authenticated web portal.

### 4. Running the Flutter Mobile Application
```bash
cd mobile
flutter pub get
flutter test
flutter run
```

---

## 🔒 Security & Row Level Security (RLS)

TKMingle implements Row Level Security on every user table in PostgreSQL:
- **Profiles:** Only discoverable, non-suspended profiles are queryable. Private details and verification statuses cannot be self-elevated.
- **Messages:** Guarded by conversation membership. Neither outsiders nor blocked users can read messages.
- **Connections:** Bilateral consent required. No unsolicited message channels can be opened.
- **Registration Cap:** PostgreSQL trigger `check_registration_cap()` validates global capacity atomically before student profile insertion, preventing race conditions.

---

## 🤝 Contributing & Community

TKMingle is built by students, for students. Please see [CONTRIBUTING.md](file:///V:/Tkm%20Conenct/CONTRIBUTING.md) for contribution guidelines, coding standards, and branch policies.

---

## 📄 License
This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
