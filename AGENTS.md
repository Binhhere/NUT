# NUT Agent Guide

## Project Snapshot

- Flutter MVP for a private, local-first streak tracker.
- Android package id: `com.binhhere.nut`.
- Supported locales: English (`en`), Portuguese (`pt`), and Japanese (`ja`).
- Current v1 scope is local-first: no required login, no backend, no real payment flow, and mock/local feed only.
- Dark visual identity is intentional for the MVP.

## Source Of Truth

- `README.md` explains setup, run, build, and current product status.
- `docs/V1_LAUNCH_CHECKLIST.md` is the v1.0 scope boundary.
- `docs/RELEASE_CHECKLIST.md` tracks Play Store and external-sharing readiness.
- `docs/CHANGELOG.md` should be updated at the end of meaningful work sessions.

## Common Commands

Run these before relying on a change:

```powershell
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
```

For Android build checks:

```powershell
flutter build apk --debug
flutter build apk --release
flutter build appbundle --release
```

## Development Rules

- Keep v1 work inside `docs/V1_LAUNCH_CHECKLIST.md` unless the checklist is deliberately updated.
- Do not add Supabase, Firebase, RevenueCat, real billing, or a public community backend unless explicitly requested.
- Feed posting must be compose-first: the user writes and confirms before a post is created.
- User-facing streak semantics: once a streak is active, the first active day displays as day 1.
- When editing localization copy, update all three ARB files in `lib/l10n/`.
- Run `flutter gen-l10n` after changing ARB files.
- Do not commit keystores, `android/key.properties`, local SDK paths, `.dart_tool/`, or `build/`.

## Release Notes

- Release signing reads `android/key.properties` when present.
- If signing config is missing, Android release builds may fall back to the debug keystore for local convenience.
- Never upload an AAB signed with the debug fallback to Google Play.
- Before public release, create a privacy policy, complete Play Data safety/content rating, and review store copy because the app touches sexual self-control behavior.
