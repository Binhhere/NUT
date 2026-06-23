# NUT Changelog

Track work sessions here so README/checklists do not become the only record.

## 2026-06-23 - Remove legacy pet path from Home shrine

- Removed the old pet companion and accessory progression from the Home shrine path.
- Deleted legacy ripple/pet visual widgets that were no longer referenced by Home.
- Kept the compatibility `RipplePhase.pet` enum value but treats Day 22+ as sprout phase in the shrine visual.
- Updated streak and widget tests to assert sprout phase behavior without pet accessories.
- Validation passed `flutter gen-l10n`, `flutter analyze`, and `flutter test`.

## 2026-06-22 - Ripple pet visual refactor

- Replaced the old one-sided ripple visual with seed, breathing, pierced-ring, breakthrough, and pet companion phases.
- Added the pet companion renderer with cumulative hat, glasses, drink, and chair accessories.
- Updated Home phase labels across English, Portuguese, and Japanese localization files.
- Updated streak phase tests to cover Day 4, Day 10, Day 20, Day 21, and pet accessory unlocks.
- Validation passed `flutter gen-l10n`, `flutter analyze`, `flutter test`, and `flutter build apk --release`.

## 2026-06-22 - Tactile interaction polish

- Added a shared press-feedback wrapper for short scale and opacity response on touch.
- Applied tactile feedback to primary/secondary/destructive buttons, stat cards, onboarding reason chips, theme chips, Feed compose entry, premium feature rows, and tab changes.
- Added haptic feedback only for selection-style interactions such as tabs, chips, toggles, checkbox confirmation, and premium/feed entry points.
- Validation passed `flutter analyze`, `flutter test`, and `flutter build apk --release`.

## 2026-06-21 - Store launch preparation

- Prepared Android internal testing guidance, store listing copy, store console answer drafts, and real-device QA checklist.
- Added iOS/App Store prep in release docs, including bundle ID, Face ID purpose string, and privacy review items.
- Added in-app privacy confirmation during onboarding and a Settings > Privacy & Safety disclosure screen.
- Documented current v1 privacy posture: local-first, no account, no backend, no ads, no analytics, no payment flow.
- Validation in this launch-prep pass passed `flutter gen-l10n`, `flutter analyze`, `flutter test`, `flutter build apk --debug`, `flutter build apk --release`, and `flutter build appbundle --release`.

## 2026-06-21 - UI polish pass

- Refined the dark visual system with deeper graphite surfaces, stronger muted text contrast, and subtle card depth.
- Balanced Ocean and Light palettes for stronger contrast, calmer surfaces, and clearer selected states.
- Improved onboarding reason chips and privacy confirmation states.
- Polished Home, Profile, Settings, and Privacy & Safety affordances with clearer icons and accessibility semantics.

## 2026-06-21 - Launch readiness cleanup

- Localized reachable Journal, Analytics, and App Lock screen copy across English, Portuguese, and Japanese.
- Added a publishable privacy policy document and replaced store/privacy contact placeholders with the current support email and public policy URL.
- Removed the empty legacy Android `com/example/nut_mvp` package folder.
- Generated a local Android upload keystore and `android/key.properties`; both are gitignored and must be backed up outside the repo.
- Validation passed `flutter gen-l10n`, `dart format`, `flutter analyze`, `flutter test -r compact`, `flutter build appbundle --release`, and `jarsigner -verify`.

## 2026-06-19 - Project organization pass

- Added a top-level `NUT/README.md` to explain the project layout.
- Added `nut_docs/README.md` as the documentation index.
- Added `nut_docs/01_domain/` and `nut_docs/06_quality_release/` placeholders.
- Moved root-level build/fix logs into `nut_docs/05_implementation/`.
- Removed an empty brace-named folder that was accidentally created under `nut_docs/`.
- Added this changelog and `docs/V1_LAUNCH_CHECKLIST.md`.
- No app code changes were intentionally made in this organization pass.

Validation observed during review:

- `flutter analyze` completed with 2 issues: one unused import and one override parameter naming lint.
- `flutter test` ran 9 tests; 7 passed and 2 timed out at `pumpAndSettle`.
