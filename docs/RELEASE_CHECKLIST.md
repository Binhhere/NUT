# NUT Release Checklist

Use this before sharing an APK/AAB outside your own device.

## Current Safe Scope

- Local-first streak tracker.
- No login.
- No backend.
- No payment flow.
- Mock/in-memory feed only.
- English, Portuguese, and Japanese localization foundation.
- Android package id: `com.binhhere.nut`.

## Before Internal Test

- Run `flutter analyze`.
- Run `flutter test`.
- Run `flutter build apk --debug`.
- Install on at least one real Android phone.
- Test dark mode and light mode.
- Test English, Portuguese, and Japanese device locales.
- Test small phone layout and a wide/tablet layout.
- Confirm reset flow only resets after explicit confirmation.
- Confirm app label shows `NUT`.
- Confirm no obvious placeholder appears in core streak flow.

## Before Public Google Play

- Replace default launcher icon with NUT branding.
- Configure release signing outside git.
- Build an AAB with `flutter build appbundle --release`.
- Create privacy policy.
- Create terms/basic disclaimer.
- Complete Google Play Data safety form.
- Complete Google Play content rating.
- Review store copy carefully because the app touches sexual self-control behavior.
- Decide product positioning:
  - private streak tracker first, or
  - real community feed with moderation.
- If community feed is public, add moderation/reporting before launch.
- If paywall is visible as anything more than a placeholder, integrate real billing and restore purchases.

## Do Not Commit

- Keystores.
- `key.properties`.
- Local Android SDK paths.
- Build outputs.
- Tester data exports.

## Useful Commands

```powershell
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
flutter build appbundle --release
```
