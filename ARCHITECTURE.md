# TKMingle — System Architecture

**Institution:** TKM College of Engineering (TKMCE), Kollam, Kerala  
**Ecosystem:** Unified Multi-Platform Campus Social Discovery  

---

## 🏗️ High-Level System Architecture

```
                       ┌────────────────────────────────────────┐
                       │          TKMCE Student Users           │
                       └───────────────────┬────────────────────┘
                                           │
                    ┌──────────────────────┴──────────────────────┐
                    │                                             │
         ┌──────────▼───────────┐                      ┌──────────▼───────────┐
         │     Next.js Web      │                      │    Flutter Mobile    │
         │   (Vercel Hosting)   │                      │    (Android / iOS)   │
         │                      │                      │                      │
         │ - Responsive Landing │                      │ - 26 Screen Flows    │
         │ - Web Portal (/app)  │                      │ - Sora Typography    │
         │ - @supabase/ssr      │                      │ - Riverpod 2.5 State │
         └──────────┬───────────┘                      └──────────┬───────────┘
                    │                                             │
                    │         HTTPS REST / Realtime WSS           │
                    └──────────────────────┬──────────────────────┘
                                           │
                       ┌───────────────────▼────────────────────┐
                       │            Supabase Cloud              │
                       │                                        │
                       │  - Auth (Student Email & OTP)          │
                       │  - PostgreSQL 15 Database (15+ Tables) │
                       │  - Realtime Engine (Live Chat Streams) │
                       │  - Storage (Avatars & Attachments)     │
                       │  - Edge Functions (Notifications)      │
                       │  - Row Level Security (RLS) Guardrails │
                       └────────────────────────────────────────┘
```

---

## 🗄️ Database Entity-Relationship Model

### Core Data Models

1. **`profiles`**: Primary student identity linked to `auth.users(id)`.
   - `department`: Restricts or filters across TKMCE departments.
   - `academic_year`: 1st to 4th Year, MCA, PG.
   - `interests` & `skills`: GIN-indexed array columns for high-speed sub-millisecond matching.
   - `verification_status`: `pending`, `verified`, `rejected`, `suspended`.
   - `discoverable`: Boolean toggle for student privacy.

2. **`connection_requests` & `connections`**:
   - Manages mutual consent handshake.
   - `connections` table maintains normalized pairs `(user_one < user_two)` to prevent duplicate symmetric rows.

3. **`conversations`, `conversation_members`, `messages`**:
   - Guarded strictly by RLS: only users enrolled in `conversation_members` can SELECT or INSERT into `messages`.
   - PostgreSQL trigger updates `conversations.last_message_at` and `last_message_preview` on every message insert.
   - Realtime publication stream enabled for live sub-second chat updates.

4. **`circles`, `circle_members`, `circle_posts`**:
   - Community clubs (IEEE, IEDC, Coding Club, RoboTKM, Arts Club).
   - Role-based moderation (`member`, `moderator`, `admin`, `lead`).

5. **`system_settings`**:
   - Centralized registration control (`registration_cap = 400`, scalable to 4,000).
   - Atomic validation trigger `check_registration_cap()`.

---

## 🔐 Security & Access Control Model

1. **No Frontend-Only Verification:** All access boundaries are enforced at the PostgreSQL database layer via Row Level Security (RLS).
2. **Privilege Escalation Protection:** Triggers prevent non-admin users from altering `verification_status` or `role`.
3. **Data Isolation:** Blocked or reported users are dynamically excluded from search results, discovery feeds, and message routing.
