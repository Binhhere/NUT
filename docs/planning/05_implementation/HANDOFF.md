# NUT — Handoff / Current Status

Last updated: June 2026

## What is done

### Environment
- Flutter installed on Windows PC ✅
- Flutter project created: nut_app/ ✅
- VSCode set up ✅

### Code (via Codex Phase 1 prompt)
- Visual design system applied (dark theme, amber gold accent) ✅
- MVP skeleton screens: Home, Feed, Badges, Profile, Paywall ✅
- Streak counter with local persistence ✅
- Relapse reset with compassionate copy ✅
- Lifetime clean days calculation ✅
- Milestone badges (7/30/90/365) locked/unlocked ✅
- First-launch onboarding (username + reason) ✅
- shared_preferences for local storage ✅
- Community feed with mock data ✅
- Shared widgets: NutCard, NutButton, NutGhostButton, NutPill, NutStatCard ✅
- i18n foundation: l10n.yaml, app_en.arb ✅
- flutter analyze: pass ✅
- flutter test: pass ✅

## What is NOT done yet

- [ ] Connect USB cable → test on real Android device
- [ ] Supabase backend (Wave 3)
- [ ] RevenueCat subscription (Wave 4)
- [ ] Firebase Analytics (Wave 5)
- [ ] Local notifications (Wave 6)
- [ ] Home screen widget (Wave 6)
- [ ] App icon
- [ ] Google Play submission
- [ ] TikTok/Instagram channel creation
- [ ] Ryan/Ryana character (Version 2)

## Immediate next step
Buy USB-A to Type-C cable (Ugreen or Anker, ~100k VND).
Run: flutter run
See app on real device. Note issues. Fix issues.

## Key decisions made
- Android first, iOS later
- Flutter + Supabase + RevenueCat + Firebase
- $4.99/month or $29.99/year
- Free: streak + feed. Premium: journal + analytics + widget
- No shame language in relapse UX
- Feed is text-first, no raw image upload (Google Play policy)
- Community feed cold-start: seed with 50+ fake posts first 2 weeks
- App title for ASO: "NUT - NoFap Streak Tracker"

## Version 2 concept (DO NOT IMPLEMENT YET)
Ryan/Ryana — manga-style companion character.
4-koma style, static PNG sprites, JSON dialog scripts.
Rule-based emotional responses to streak data.
Philosophy: stillness, quiet space, anti-attention app.
See 00_project/01_MVP_Scope.md for full spec.

---

## Update — June 2026 (UI V5)

### nut_ui_v5.html
- Nâng cấp từ V2 lên V5
- Tất cả flow navigation được wire up thực tế (click được)
- `goto(id)` function: navigate giữa screens, tự sync tab + stab
- Bottom nav bars: click được, chuyển screen đúng tab
- Splash: auto-navigate → Onboarding sau 1.5s
- Relapse: confirmation bottom sheet (`showSheet()`) trước khi reset
- Flows hoàn chỉnh: Onboarding → Notif → Home → Checkin / Relapse / Feed / Badges / Profile → sub-screens

### 04_api_ui/01_User_Flows.md (MỚI)
- 16 flows đầy đủ được document
- Mỗi flow: trigger, steps, decision points, destination
- Bottom sheet spec cho Relapse confirmation
- Navigation structure tổng quan
- Deep link map (Wave 3+)
- Error states cho tất cả flows
