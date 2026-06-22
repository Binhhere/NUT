# NUT — Implementation Roadmap

## Version 1

---

### Phase 1 — Local MVP (current, no phone needed)
**Goal:** App runs correctly on device. All screens functional with local data.

Tasks:
- Flutter project created ✅
- Visual design system applied ✅
- MVP skeleton: streak, feed, badges, profile, paywall ✅
- Onboarding + shared_preferences ✅
- i18n foundation (l10n.yaml, app_en.arb) ✅
- flutter analyze pass ✅
- flutter test pass ✅

**Next:** Connect phone via USB → flutter run → verify UI on real device.

---

### Phase 2 — Device testing
**Goal:** App runs on real Android device. UI verified on real screen.

Tasks:
- Buy USB-A to Type-C cable (Ugreen or Anker)
- Enable USB debugging on phone
- flutter run on device
- Note all UI issues on real screen (spacing, font size, color)
- Fix issues found

---

### Phase 3 — Supabase backend
**Goal:** Real auth and data. No more mock data.

Tasks:
- Create Supabase project
- Set up tables: users, streaks, feed_posts, badges, journal_entries
- Enable RLS policies
- Integrate supabase_flutter
- Auth: email sign up / login
- Streak: read/write from Supabase
- Feed: real posts, real reactions
- Badges: calculated from real streak data

---

### Phase 4 — RevenueCat + paywall
**Goal:** Real subscription. Real money.

Tasks:
- Create RevenueCat project
- Connect Google Play billing
- Set up products: monthly $4.99, annual $29.99
- Integrate purchases_flutter
- Gate premium features behind entitlement check
- Test purchase on sandbox

---

### Phase 5 — Firebase Analytics
**Goal:** Know what users do in the app.

Tasks:
- Add Firebase to project (google-services.json)
- Track key events:
  - app_open
  - streak_reset
  - milestone_unlocked
  - feed_post_created
  - paywall_viewed
  - purchase_completed

---

### Phase 6 — Notifications + Widget
**Goal:** Daily re-engagement.

Tasks:
- flutter_local_notifications: morning reminder
- Home screen widget showing streak count
- Notification permission request on onboarding

---

### Phase 7 — Polish + Store listing
**Goal:** Ready to submit.

Tasks:
- Fix all UI issues from real device testing
- App icon (NUT wordmark — person standing in U with ^ above)
- Store screenshots (Hook → Problem → Solution → Social proof → CTA)
- Store title: "NUT - NoFap Streak Tracker"
- Store description with keywords: nofap, streak tracker, no nut november, self improvement
- Privacy policy page (required by Google Play)
- Submit to Google Play ($25 one-time fee)

---

### Phase 8 — Distribution
**Goal:** First real users.

Tasks:
- Create TikTok account for NUT
- Create Instagram account for NUT
- Seed community feed with 50+ fake posts (cold start strategy)
- Post first 10 videos: "Day X of NoFap" format
- Copy style from accounts already performing in this niche
- Monitor installs, D1 retention, conversion to premium

---

## Version 2

### Phase 1 — Ryan asset creation
**Goal:** Full sprite set ready for implementation.

Tasks:
- Draw Ryan (male) and Ryana (female) base character
- Draw all states: reading, studying, napping, exercising, writing, looking_up, comforting_hug, waving_goodbye, waving_hello
- Draw 2–3 background scenes: desk/study, living room, park
- Export as PNG with transparent background for character layer
- Export backgrounds as flat PNG

### Phase 2 — Dialog system
**Goal:** JSON-driven dialog engine in Flutter.

Tasks:
- Design dialog JSON schema
- Write script for all Ryan interactions (morning letter, tap response, relapse responses, departure letter, return)
- Write 365 daily quotes for morning letters
- Implement Flutter dialog widget: background + character layer + speech bubble + 3 choice buttons
- Rule engine: state machine reading streak data → selecting correct Ryan state + dialog

### Phase 3 — Companion integration
**Goal:** Ryan appears in app alongside existing streak features.

Tasks:
- Replace or augment home screen with Ryan scene
- Morning open: letter flow
- Default state: Ryan busy animation cycle (slow, subtle)
- Tap 5x: Ryan looks up, responds, returns
- Relapse flow: rule-based Ryan response
- Ryan departure + 21-day return flow

### Phase 4 — Environment system
**Goal:** User builds Ryan's world.

Tasks:
- User can create environments: home, work, gym, park, hospital
- Ryan appears in matching background when user is "at" that location
- Simple location selection, no GPS required

### Phase 5 — Goal / task system
**Goal:** User sets personal goals, Ryan reacts.

Tasks:
- Goal creation: task name + deadline in days
- Progress check-in
- Success: Ryan celebration
- Failure: Ryan compassionate response
