# NUT V1 Launch Checklist

This file is the v1.0 scope boundary. If a task is not here, it should wait
unless this checklist is deliberately updated.

## Scope Lock

- [x] Local-first streak tracker.
- [x] No required login.
- [x] No required backend.
- [x] No real payment flow in v1.
- [x] Mock/local feed only unless moderation is implemented.
- [x] Supported locales: English, Portuguese, Japanese.
- [ ] Public community launch decision documented.
- [ ] Premium placeholder copy verified as non-purchasable.

## App Readiness

- [ ] `flutter analyze` has no issues.
- [ ] `flutter test` passes.
- [ ] Debug APK builds.
- [ ] Release APK builds.
- [ ] Android app label shows `NUT`.
- [ ] Real Android phone test completed.
- [ ] Small phone layout checked.
- [ ] Wide/tablet layout checked.
- [ ] English locale checked.
- [ ] Portuguese locale checked.
- [ ] Japanese locale checked.

## Core Flows

- [ ] First-launch onboarding can be completed.
- [ ] Returning user opens directly into the app shell.
- [ ] Check-in starts a streak when none exists.
- [ ] First active day displays as day 1.
- [ ] Relapse flow requires explicit confirmation.
- [ ] Lifetime clean days, best streak, and reset count update correctly.
- [ ] Feed `+` opens compose before creating a post.
- [ ] Profile stats are readable on mobile.
- [ ] Settings screen renders all localized labels.

## Release Bridge

- [ ] `docs/RELEASE_CHECKLIST.md` reviewed before sharing outside personal testing.
- [ ] App icon and splash assets are final enough for internal testing.
- [ ] `android/key.properties` remains uncommitted.
- [ ] Privacy policy draft exists before public testing.
- [ ] Store listing copy reviewed for sensitive subject matter.

## Later, Not V1

- [ ] Supabase auth/community backend.
- [ ] Moderation/reporting for public feed.
- [ ] RevenueCat or native billing.
- [ ] Firebase analytics/crash reporting.
- [ ] Full companion character system.
