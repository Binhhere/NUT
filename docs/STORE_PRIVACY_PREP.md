# Store Privacy Preparation

Use this alongside `docs/RELEASE_CHECKLIST.md` before submitting to Apple App Store or Google Play.

## Current V1 Privacy Position

- Local-first streak tracker.
- No required account.
- No backend.
- No public community posting.
- No ads.
- No analytics SDK.
- No payment flow.
- No data sale or tracking.
- Optional local username/reason, reminders, App Lock, and backup import/export.

## In-App Disclosure And Consent

- Onboarding now requires an affirmative privacy/safety confirmation before the user can start.
- Settings includes a Privacy & Safety screen that explains local storage, optional permissions, sensitive subject matter, and future store-policy update requirements.
- Notification permission is requested only when the user enables reminders.
- Biometric/device-lock authentication is requested only when the user enables App Lock.

## Apple App Store

Prepare these before upload:

- Bundle ID: `com.binhhere.nut`.
- Display name: `NUT`.
- Apple Developer Team selected in Xcode.
- App Store Connect app record created with matching bundle ID.
- Privacy Policy URL added in App Store Connect.
- Privacy policy accessible in app through Settings > Privacy & Safety.
- App Privacy answers completed in App Store Connect.
- Age rating/content description reviewed because the app touches sexual self-control behavior.
- Screenshots and review notes prepared.
- TestFlight build verified on real iPhone.

Suggested App Privacy answer for current v1: no data collected by the developer, if no backend, analytics, ads, crash reporting, or external service is added before submission. Re-check every dependency and feature before using that answer.

## Google Play

Prepare these before upload:

- Package name: `com.binhhere.nut`.
- Privacy Policy URL added in Play Console.
- Data safety form completed.
- App access declaration: no account required.
- Ads declaration: no ads for current v1.
- Content rating questionnaire completed carefully.
- Target audience reviewed; do not position as a children-focused app.
- Sensitive subject matter reviewed in store listing copy.
- Internal testing completed on a real Android device.

Suggested Data safety answer for current v1: no data collected or shared by the developer, if no backend, analytics, ads, crash reporting, or external service is added before submission. Local-only on-device data should still be explained in the privacy policy and in-app disclosure.

## Do Not Submit Until Updated

Update policy, app privacy, and data safety answers before release if any of these are added:

- Supabase/auth/cloud sync.
- Public community feed.
- Moderation/reporting backend.
- Firebase analytics or crash reporting.
- RevenueCat or platform billing.
- Push notification server.
- Any advertising, attribution, or analytics SDK.
- Any collection of email, contact info, device IDs, diagnostics, or usage analytics.
