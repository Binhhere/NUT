# NUT

NUT is a Flutter MVP for a NoFap streak tracker with a lightweight, text-first community feed.

The current build is intentionally local-first:

- No backend
- No login
- No Firebase
- No Supabase
- No RevenueCat
- Streak data is stored on-device with `shared_preferences`
- Feed posts are mock/in-memory data
- Android application ID: `com.binhhere.nut`
- Supported locales: English (`en`), Portuguese (`pt`), Japanese (`ja`)
- Dark theme is forced by default for the MVP visual identity

## MVP Features

- Current streak counter in days, hours, and minutes
- First-launch onboarding for username and reason
- Daily check-in/start streak
- Compassionate relapse reflection and reset confirmation flow
- Lifetime clean days counter
- Best streak and reset count tracking
- Milestone badges: 7, 30, 90, and 365 days
- Mock community feed with text posts
- Local "Post progress" action
- Profile screen with premium placeholder
- Paywall placeholder with planned premium features
- Responsive content constraints for phones, tablets, and wider layouts

## Project Structure

```text
lib/
  main.dart
  app/
    nut_app.dart
    theme.dart
    constants.dart
  features/
    onboarding/
    streak/
    feed/
    badges/
    profile/
    paywall/
  shared/
    widgets/
    services/
    models/
```

## Requirements

Install these before running the app on a new machine:

1. Flutter SDK
   - This project was created and checked with Flutter `3.24.5` and Dart `3.5.4`.
   - Newer stable Flutter versions should work, but run `flutter doctor` after setup.

2. Android Studio
   - Install Android Studio.
   - During setup, install:
     - Android SDK
     - Android SDK Platform
     - Android SDK Command-line Tools
     - Android SDK Build-Tools
     - Android Emulator, if you want to run an emulator
   - **Quick Emulator Setup:**
     - Open **Tools** > **Device Manager**.
     - Click **Create Virtual Device**.
     - Select **Pixel 9** > **Next**.
     - Select **API level 35 (Android 15)** > **Download** (if missing) > **Next**.

3. Android SDK path
   - If Flutter cannot find the SDK, set it manually:

```powershell
flutter config --android-sdk "C:\Users\<you>\AppData\Local\Android\Sdk"
```

4. Windows Developer Mode
   - On Windows, Flutter plugins may require symlink support.
   - Enable it in Settings > System > For developers > Developer Mode.

## Clone and Run

```powershell
git clone https://github.com/Binhhere/NUT.git
cd NUT
flutter doctor
flutter pub get
flutter run
```

To run specifically on an Android device or emulator:

```powershell
flutter devices
flutter run -d <device-id>
```

## Build Android APK

```powershell
flutter build apk --debug
```

For a release build:

```powershell
flutter build apk --release
flutter build appbundle --release
```

Release signing now reads `android/key.properties` if present (copy from
`android/key.properties.example` and fill in your real keystore details).
If `key.properties` is missing, the release build automatically falls back
to the debug keystore so `flutter run --release` keeps working on a fresh
machine — but an AAB built that way must never be uploaded to Google Play.
Do not commit keystores or `key.properties`; both are gitignored.

## Useful Checks

```powershell
flutter analyze
flutter test
flutter gen-l10n
```

Run `flutter gen-l10n` after pulling changes that touch `lib/l10n/*.arb`,
then `flutter analyze` and `flutter test` before relying on this list —
localization keys and generated code can drift from `lib/l10n/*.arb`
if a screen is edited without updating all three locale files.

## Generate Project Tree

Use the helper script when you need a clean project structure for planning,
handoff, or AI context:

```powershell
python tools/gen_tree_flutter.py --root . --depth 6 --out nut_tree.txt
```

For a smaller app-only view that hides platform folders:

```powershell
python tools/gen_tree_flutter.py --root . --depth 6 --app-only --out nut_tree.txt
```

Generated `*_tree.txt` files are ignored by git.

## What Should Be Committed

Commit source and project configuration:

- `lib/`
- `test/`
- `android/`, except local/generated files ignored by `.gitignore`
- `ios/`, except local/generated files ignored by `.gitignore`
- `pubspec.yaml`
- `pubspec.lock`
- `analysis_options.yaml`
- `.metadata`
- `.gitignore`
- `README.md`

Do not commit:

- `.dart_tool/`
- `build/`
- `.idea/`
- `.vscode/`
- `android/local.properties`
- generated iOS/macOS Flutter environment files
- signing keys, keystores, or `key.properties`

## Internal Test Readiness

This app is suitable for local Android testing and small internal tester builds.
Before a public Google Play release, complete `docs/RELEASE_CHECKLIST.md`.

## Project History & Current Status

- `docs/CHANGELOG.md` — session-by-session dev log: what changed, why,
  and what is still open. Update this at the end of every working
  session, not just when something feels finished.
- `docs/V1_LAUNCH_CHECKLIST.md` — the hard scope boundary for v1.0,
  with real checkboxes. If something isn't on that list, it does not
  belong in v1.0, no matter how good an idea it seems mid-session.
- `docs/RELEASE_CHECKLIST.md` — Play Store submission specifics
  (signing, store listing, content rating). Use alongside
  `V1_LAUNCH_CHECKLIST.md`, not instead of it — one tracks code
  readiness, the other tracks store readiness.

## Next Product Steps

1. Persist local feed progress posts if the feed remains local during early testing.
2. Add a real app icon and Android adaptive icon.
3. Configure release signing outside git.
4. Add privacy policy and store listing copy.
5. Decide whether public MVP is private tracker first or includes real moderated community.
6. Later, integrate Supabase for auth/community feed with moderation.
7. Later, integrate RevenueCat or native billing for premium.
8. Later, add Firebase only if crash reporting, analytics, or notifications are needed.
