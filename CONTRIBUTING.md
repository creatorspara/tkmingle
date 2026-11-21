# Contributing to TKMingle

Welcome to the TKMingle open-source project! We are thrilled you want to help make student connections across TKM College of Engineering even more rewarding, secure, and inclusive.

---

## 🎯 Community Guidelines

1. **Campus-First:** Keep all features focused on the student and academic life of TKMCE.
2. **Privacy by Default:** Respect student anonymity, opt-in discoverability, and mutual consent.
3. **No Commercial Trackers:** Avoid injecting third-party trackers, advertisements, or proprietary monetization SDKs.
4. **Inclusive Communication:** Respect fellow contributors regardless of department, year, or background.

---

## 🛠️ Development Workflow

### Monorepo Structure
- **Mobile (`/mobile`):** Flutter 3.24+ app using Riverpod state management and Repository Pattern.
- **Web (`/web`):** Next.js 14+ App Router, Tailwind CSS, Lucide icons, Sora typography.
- **Backend (`/supabase`):** PostgreSQL schema, RLS policies, migrations, and Edge functions.

### Git Conventions
- Create feature branches from `main`:
  `git checkout -b feature/circle-poll-system`
  `git checkout -b fix/mobile-chat-scroll`
- Use conventional commit messages:
  `feat: add cross-department project search filter`
  `fix: prevent duplicate connection requests in backend`
  `docs: update Supabase migration guide`

### Pull Request Process
1. Ensure `flutter test` passes with zero failures.
2. Ensure `flutter analyze` reports zero errors.
3. Ensure Next.js builds cleanly with `npm run build` in `/web`.
4. Submit your pull request with a clear description and screenshot if UI changes are included.
