# Real Device QA Checklist

Use this before sending NUT beyond internal testers.

## Devices

Minimum:

- One Android phone.
- One small-screen Android device or emulator.
- One larger Android device/tablet or emulator.

Later for iOS:

- One iPhone through TestFlight.
- One smaller iPhone size if available.

## Install

Android options:

- Internal test link from Google Play, preferred.
- Debug APK sideload for local QA.

For local APK install:

```powershell
flutter devices
flutter install -d <device-id> --debug
```

Or build and install manually:

```powershell
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

## Fresh Install Flow

- App launches without crash.
- Onboarding appears on first launch.
- Username field accepts text.
- User can skip optional fields.
- Privacy confirmation checkbox appears before start.
- Start button is disabled until privacy confirmation is checked.
- Starting completes onboarding and opens the main app.

## Core Streak

- Start/check-in creates an active streak.
- First active day displays as Day 1.
- Hours/minutes display correctly enough for current day.
- Returning to app keeps streak state.
- Reset entry point uses supportive copy.
- Reset requires explicit confirmation.
- Cancel reset keeps the streak.
- Confirm reset increments reset count and preserves lifetime/best stats.

## Navigation And Screens

- Home is readable.
- Feed opens.
- Feed `+` opens compose before posting.
- Badges screen is readable.
- Profile stats are readable on mobile.
- Settings opens from Profile.
- Settings > Privacy & Safety opens and is readable.
- Paywall/premium copy reads as planned/coming soon, not purchasable.

## Locale Checks

Test device locale or app locale where possible:

- English.
- Portuguese.
- Japanese.

For each:

- Bottom navigation labels fit.
- Onboarding text fits.
- Settings labels fit.
- Privacy & Safety text fits.
- No obvious mojibake or missing string keys.

## Layout Checks

Check:

- Small phone portrait.
- Normal phone portrait.
- Wide/tablet layout.
- Text does not overlap.
- Buttons are tappable.
- Bottom navigation is not clipped.
- Keyboard does not hide onboarding text field badly.

## Permissions

- Notification permission appears only when enabling reminders.
- App Lock asks for biometrics/device lock only when enabling App Lock.
- Denying optional permissions does not break core streak tracking.
- Backup export/import flows do not crash if cancelled.

## Store Screenshot Candidates

Capture only polished screens:

- Home active streak.
- Reset confirmation.
- Badges.
- Feed compose.
- Profile.
- Privacy & Safety.

Avoid showing:

- Debug/developer-only controls.
- Empty placeholder states that look unfinished.
- Any copy implying medical treatment or guaranteed outcomes.

## Pass/Fail Log

Record:

- Device model.
- OS version.
- App build version.
- Install source.
- Tester name.
- Pass/fail.
- Screenshot/video for each bug.
