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
- Review `docs/ANDROID_INTERNAL_TEST_PLAN.md`.
- Review `docs/REAL_DEVICE_QA_CHECKLIST.md`.
- Install on at least one real Android phone.
- Test dark mode and light mode.
- Test English, Portuguese, and Japanese device locales.
- Test small phone layout and a wide/tablet layout.
- Confirm reset flow only resets after explicit confirmation.
- Confirm app label shows `NUT`.
- Confirm no obvious placeholder appears in core streak flow.

## Before Public Google Play

- Review `docs/STORE_LISTING_COPY.md`.
- Review `docs/STORE_CONSOLE_ANSWERS.md`.
- Replace default launcher icon with NUT branding.
- Generate a real release keystore and create `android/key.properties`
  from `android/key.properties.example` (gradle now reads it automatically
  — see README "Build Android APK"). Confirm the built AAB is NOT signed
  with the debug fallback before uploading.
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
- Journal and Relapse analytics screens are reachable from the paywall
  feature list as locked previews — confirm copy still reads as "coming
  soon" and not as a working purchase before public release.

## Before Apple App Store

- Confirm iOS bundle ID is `com.binhhere.nut`.
- Select an Apple Developer Team in Xcode.
- Run `flutter build ipa --release` on macOS with Xcode.
- Upload through Xcode Organizer, Transporter, or CI on macOS.
- Create an App Store Connect app record with matching bundle ID.
- Add a public privacy policy URL in App Store Connect.
- Complete App Privacy answers in App Store Connect.
- Confirm Privacy & Safety is accessible inside the app.
- Confirm `NSFaceIDUsageDescription` copy matches the App Lock feature.
- Test on a real iPhone through TestFlight before public release.

## Store Privacy Prep

- Review `docs/PRIVACY_POLICY_DRAFT.md`.
- Review `docs/STORE_PRIVACY_PREP.md`.
- Review `docs/STORE_CONSOLE_ANSWERS.md`.
- Confirm contact and public URL placeholders are gone before public testing.
- Keep Apple App Privacy and Google Play Data safety answers in sync with the actual shipped build.

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
