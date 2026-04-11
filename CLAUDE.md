# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on default device
flutter test             # Run all tests
flutter analyze          # Lint
dart format lib/         # Format Dart files
dart fix --apply         # Auto-fix lint issues
```

## Architecture

**Moodiki** is a Flutter mental health platform connecting users with experts, mood tracking, AI chatbot, meditations, and community forums. It targets both regular users and mental health professionals (multi-role: User, Expert, Admin).

**Backend:** Supabase (PostgreSQL, Auth, Realtime). Credentials loaded from `.env` via `flutter_dotenv` — see `.env.example` for required keys (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `GEMINI_API_KEY`).

### Layer structure

```
views/          → Feature screens (auth, home, mood, chatbot, appointment, expert,
                  meditation, chat, news, profile, notification)
core/providers/ → ChangeNotifier providers (AuthProvider, MoodProvider,
                  ChatbotProvider, LocaleProvider)
services/       → Data layer that wraps Supabase and external APIs
models/         → Plain Dart data classes
shared/widgets/ → Reusable UI components
core/constants/ → AppColors, AppConstants, AppTheme
l10n/           → ARB localization files (EN + VI)
```

### State management

Provider pattern (`provider` package). Providers wrap services and expose computed/filtered state. Access via `context.read<XProvider>()` / `context.watch<XProvider>()`.

### Navigation

Plain `Navigator` push/pop — `go_router` is listed in pubspec but not in active use. Custom transitions use `PageRouteBuilder`.

### Services

- `supabase_service.dart` — core DB ops (users, moods, meditations, streaks)
- `ai_chatbot_service.dart` — Google Gemini streaming via `google_generative_ai`
- `appointment_service.dart` — expert booking
- `chat_service.dart` — Supabase Realtime messaging
- `momo_service.dart` — MoMo payment integration (HMAC-SHA256 signature via `crypto`)

### Localization

`intl` + ARB files. Access strings via the `context.l10n` extension. Run `flutter gen-l10n` after editing ARB files.

### Design system

`AppColors`, `AppConstants`, and `AppTheme` (Material 3, custom fonts via `google_fonts`) live in `lib/core/constants/`. The UI uses neumorphic-style card designs throughout.
