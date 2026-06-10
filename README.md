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

## MVP Features

- Current streak counter in days, hours, and minutes
- Start/restart streak
- Compassionate relapse reset flow
- Lifetime clean days counter
- Milestone badges: 7, 30, 90, and 365 days
- Mock community feed with text posts
- Local "Post progress" action
- Profile screen with premium placeholder
- Paywall placeholder with planned premium features

## Project Structure

```text
lib/
  main.dart
  app/
    nut_app.dart
    theme.dart
  features/
    streak/
    feed/
    badges/
    profile/
    paywall/
  shared/
    widgets/
    utils/
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
git clone <repo-url>
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

For a release build later:

```powershell
flutter build apk --release
```

Release signing is not configured yet. Do not commit keystores or `key.properties`.

## Useful Checks

```powershell
flutter analyze
flutter test
```

Current status:

- `flutter analyze` passes
- `flutter test` passes
- Android APK build requires Android SDK to be installed/configured on the machine

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

## Next Product Steps

1. Add onboarding for username and first streak start.
2. Persist local feed progress posts.
3. Add local reminders/notifications.
4. Add a simple journal screen behind the premium placeholder.
5. Add analytics for relapse patterns, still keeping the tone compassionate.
6. Later, integrate Supabase for auth/community feed with moderation.
7. Later, integrate RevenueCat or native billing for premium.
8. Later, add Firebase only if crash reporting, analytics, or notifications are needed.
