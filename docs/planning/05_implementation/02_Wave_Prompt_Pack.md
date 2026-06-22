# NUT — Codex Wave Prompts

## How to use
Copy each wave prompt and send to Codex/Claude Code when ready for that phase.
Always run gen_tree_flutter.py first and paste the tree at the top of the prompt.

---

## Wave 2 — Device testing fixes
Send after first flutter run on real device.

```
Here is the current project tree:
[PASTE nut_tree.txt HERE]

I just ran the NUT Flutter app on a real Android device for the first time.
Fix the following issues I found: [LIST ISSUES HERE]

Rules:
- Do not change architecture
- Do not add new features
- Only fix visual/layout issues on real device
- Keep flutter analyze and flutter test passing
```

---

## Wave 3 — Supabase integration

```
Here is the current project tree:
[PASTE nut_tree.txt HERE]

Integrate Supabase into the NUT Flutter app.

Supabase project URL: [YOUR URL]
Supabase anon key: [YOUR KEY]

Tasks:
1. Initialize Supabase in main.dart
2. Implement email auth: sign up, login, logout
3. Replace local streak mock with Supabase reads/writes
   - start_date, is_active, relapse_count, lifetime_clean_days
4. Replace local feed mock with Supabase feed_posts table
5. Write badges to Supabase when milestone is reached
6. Keep shared_preferences for onboarding data (username, reason)
7. Handle loading states and error states gracefully
8. Keep flutter analyze and flutter test passing

Database schema is in docs/03_system_design/03_Database_Architecture.md

Do not integrate RevenueCat or Firebase yet.
```

---

## Wave 4 — RevenueCat

```
Here is the current project tree:
[PASTE nut_tree.txt HERE]

Integrate RevenueCat into the NUT Flutter app.

RevenueCat API key (Android): [YOUR KEY]

Tasks:
1. Initialize RevenueCat in main.dart
2. Implement purchase flow for:
   - Monthly: $4.99/month (product id: nut_premium_monthly)
   - Annual: $29.99/year (product id: nut_premium_annual)
3. Check entitlement on app start
4. Gate these features behind premium entitlement:
   - Journal screen
   - Relapse analytics
   - Advanced stats
   - Custom notification time
   - Home screen widget
5. Paywall screen: show both plans, anchor annual prominently
   Show savings: "$29.99/year = $2.50/month"
6. Restore purchases button
7. Keep flutter analyze and flutter test passing

Do not add Firebase yet.
```

---

## Wave 5 — Firebase Analytics

```
Here is the current project tree:
[PASTE nut_tree.txt HERE]

Add Firebase Analytics to the NUT Flutter app.

google-services.json is already placed in android/app/

Tasks:
1. Add firebase_core and firebase_analytics packages
2. Initialize Firebase in main.dart
3. Track these events:
   - app_open
   - onboarding_complete (with reason parameter)
   - streak_reset (with streak_days parameter)
   - milestone_unlocked (with badge_type parameter)
   - feed_post_created
   - paywall_viewed
   - purchase_started (with plan parameter)
   - purchase_completed (with plan parameter)
4. Keep flutter analyze and flutter test passing
```

---

## Wave 6 — Notifications and widget

```
Here is the current project tree:
[PASTE nut_tree.txt HERE]

Add local notifications and home screen widget to NUT Flutter app.

Tasks:
1. flutter_local_notifications:
   - Request permission on onboarding
   - Schedule daily morning notification at 8:00 AM
   - Copy: "Good morning. Your streak is waiting." or similar calm copy
   - Allow user to customize time (premium feature)
2. Home screen widget (home_widget package):
   - Show current streak day count
   - Update when app opens
   - Simple design: streak number in gold on dark background
3. Keep flutter analyze and flutter test passing
```

---

## Wave 7 — Polish and store prep

```
Here is the current project tree:
[PASTE nut_tree.txt HERE]

Prepare NUT Flutter app for Google Play submission.

Tasks:
1. App icon: [I will provide the icon PNG]
2. Splash screen: dark background, NUT logo centered
3. Final flutter analyze — zero warnings
4. Final flutter test — all pass
5. Build release APK:
   flutter build apk --release
6. Review all screen copy for:
   - No shame language
   - Compassionate relapse copy
   - Clean English grammar
7. List all strings that need translation for future i18n

Do not submit to store — only prepare the build.
```

---

## Wave V2.1 — Ryan dialog system

```
Here is the current project tree:
[PASTE nut_tree.txt HERE]

Build the Ryan companion dialog system for NUT Version 2.

Ryan asset sprites are in assets/ryan/ as PNG files:
- ryan_reading.png
- ryan_studying.png
- ryan_napping.png
- ryan_exercising.png
- ryan_looking_up.png
- ryan_comforting.png
- ryan_goodbye.png
- ryan_return.png

Background scenes are in assets/backgrounds/ as PNG files:
- bg_study_desk.png
- bg_living_room.png
- bg_park.png

Dialog scripts are in assets/dialog/ryan_scripts.json

Tasks:
1. Create RyanScene widget:
   - Background layer (PNG)
   - Character layer (PNG, centered or offset)
   - Speech bubble overlay
   - 3 choice buttons at bottom: Yes / No / [text input]
2. Implement rule engine (RyanStateService):
   - Read current streak data
   - Select correct sprite and dialog based on rules in 01_MVP_Scope.md
3. Morning letter screen:
   - Full screen warm beige background
   - Letter/envelope open animation (simple)
   - Daily quote text
4. Home screen: show Ryan scene as background, streak counter overlaid
5. Tap 5x detection on Ryan character
6. Keep flutter analyze and flutter test passing
```
