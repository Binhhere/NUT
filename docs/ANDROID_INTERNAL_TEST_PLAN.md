# Android Internal Test Plan

Use this as the next launch step for NUT. Android is the fastest path because this Windows machine can already build APK/AAB artifacts.

## Current Build Status

Last verified locally:

- `flutter gen-l10n`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`
- `flutter build apk --release`
- `flutter build appbundle --release`

The generated Play upload artifact is:

```text
build/app/outputs/bundle/release/app-release.aab
```

Do not upload this AAB until it is signed with a real upload key through `android/key.properties`.

## One-Time Account Tasks

These must be done by the developer account owner:

- Create or access the Google Play Console account.
- Create the NUT app entry with package name `com.binhhere.nut`.
- Enroll in Play App Signing.
- Add a public privacy policy URL.
- Complete App content sections before review:
  - Privacy policy
  - App access
  - Ads
  - Content rating
  - Target audience
  - Data safety

Google recommends internal testing before wider tracks and describes internal tests as a fast distribution path for invited testers.

## Generate Android Upload Key

Run this outside the repo. Keep the keystore and passwords private.

```powershell
New-Item -ItemType Directory -Force C:\Users\PC\Desktop\NUT\secrets
keytool -genkeypair `
  -v `
  -keystore C:\Users\PC\Desktop\NUT\secrets\nut-upload-keystore.jks `
  -storetype JKS `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000 `
  -alias nut-upload
```

Then create `android/key.properties` from `android/key.properties.example`:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=nut-upload
storeFile=C:/Users/PC/Desktop/NUT/secrets/nut-upload-keystore.jks
```

Rules:

- Do not commit `android/key.properties`.
- Do not commit `.jks` files.
- Save the passwords in a password manager.
- Back up the upload keystore somewhere private.

## Build Signed AAB

After `android/key.properties` exists:

```powershell
flutter clean
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter build appbundle --release
```

Upload:

```text
build/app/outputs/bundle/release/app-release.aab
```

## Play Console Internal Test Flow

1. Create the app in Play Console.
2. Complete required app setup sections enough for review.
3. Go to Testing > Internal testing.
4. Create or select a tester email list.
5. Create a new release.
6. Upload the signed AAB.
7. Add release notes from `docs/STORE_LISTING_COPY.md`.
8. Review warnings carefully.
9. Roll out to internal testing.
10. Send the opt-in link to testers.

## Internal Tester Minimum QA

Ask each tester to cover:

- Install from Play internal test link.
- Complete onboarding.
- Confirm privacy checkbox appears before start.
- Start streak and verify Day 1 appears immediately.
- Trigger reset flow and cancel once.
- Trigger reset flow and confirm once.
- Open Feed and confirm `+` opens compose before posting.
- Open Profile and Settings.
- Open Settings > Privacy & Safety.
- Toggle theme if available.
- Try English, Portuguese, and Japanese device locales if possible.
- Check small screen readability.
- Report screenshots for layout overflow, clipped text, or confusing copy.

## Current Blockers Before Public Release

- Real Android phone QA not completed.
- Privacy policy URL not hosted.
- Store listing copy not reviewed by owner.
- Release signing must be created locally and kept secret.
- Store forms must be completed in Play Console.
