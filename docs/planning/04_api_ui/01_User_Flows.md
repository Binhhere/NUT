# NUT — User Flows (Version 1)

Last updated: June 2026

---

## Overview

Tài liệu này mô tả toàn bộ user flows của NUT V1.
Mỗi flow bao gồm: trigger, steps, decision points, và destination screens.

---

## Flow 1 · First Launch (New User)

**Trigger:** Lần đầu mở app. `onboarding_done` chưa tồn tại trong shared_preferences.

```
App open
  └── Splash (1.5s, fade out)
        └── Onboarding Step 1 — Name
              ├── [Continue] → Onboarding Step 2 — Reason
              └── [Skip] → Onboarding Step 2 — Reason
                    ├── [Continue] → Onboarding Step 3 — Ready
                    └── [Skip] → Onboarding Step 3 — Ready
                          └── [Start my streak] → Home
                                → set onboarding_done = true
                                → set streak_start_date = today
```

**Screens:** Splash → 02a Name → 02b Reason → 02c Ready → (02d Notifications) → Home

**Note:** Notification permission (02d) xuất hiện sau Ready trên Android 13+. Đây là OS permission dialog bọc trong màn custom. Nếu user nhấn "Not now" hoặc deny → vẫn vào Home bình thường.

---

## Flow 2 · Returning User

**Trigger:** Mở app lại. `onboarding_done = true`.

```
App open
  └── Splash (1.5s)
        ├── [Wave 1 — local MVP] → Home (luôn luôn)
        └── [Wave 3+ — Supabase] →
              ├── loggedIn = true → Home
              └── loggedIn = false → Login
```

---

## Flow 3 · Daily Check-in

**Trigger:** User mở app, chưa check-in hôm nay.

```
Home
  └── [Check in today] (gold button)
        └── Check-in Confirmation (05b)
              ├── Hiển thị streak day tăng lên
              ├── Milestone card nếu đạt ngưỡng (7/30/90/365)
              └── [Back to home] → Home
                    → streak_last_checkin = today
                    → cập nhật streak count
```

**Logic kiểm tra:**
```
if streak_last_checkin == yesterday → streak += 1 (consecutive)
if streak_last_checkin == today → already checked in (button disabled)
if streak_last_checkin < yesterday → streak = 1 (broken, reset tự động)
```

---

## Flow 4 · Relapse

**Trigger:** User nhấn "I relapsed" từ Home.

```
Home
  └── [I relapsed] (ghost button)
        └── Relapse Screen (06)
              ├── Hiển thị streak vừa kết thúc + lifetime stats
              ├── Optional: chọn trigger pills (Stress / Boredom / ...)
              │
              ├── [Keep going — don't reset] → Home (streak KHÔNG thay đổi)
              │
              └── [Reset my streak] → Confirmation Bottom Sheet
                    ├── [Go back] → Relapse Screen
                    └── [Yes, reset] →
                          → streak reset về 0
                          → streak_start_date = today
                          → relapse_count += 1
                          → lưu relapse trigger (nếu đã chọn)
                          → Home
```

**Confirmation Bottom Sheet content:**
- Title: "Reset your streak?"
- Body: "Your history stays. You're just starting a new chapter."
- Confirm CTA: "Yes, reset" (red)
- Cancel CTA: "Go back" (ghost)

**Copy rules — KHÔNG dùng:** "failed", "lost", "weak", "start from zero", "back to day 0"
**Copy được dùng:** "reset", "start again", "new chapter"

---

## Flow 5 · Auth — Sign Up (Wave 3)

**Trigger:** User chưa có tài khoản, nhấn "Create account" từ Login hoặc "New here?" link.

```
Login Screen
  └── [New here? Create account]
        └── Sign Up Screen (04)
              ├── Nhập email + password + confirm password
              ├── [Create account]
              │     ├── Success →
              │     │     ├── user chưa có local data → Onboarding
              │     │     └── user đã có local data → Home
              │     └── Error →
              │           └── Inline error messages (email taken, weak password, mismatch)
              └── [Already have one? Sign in] → Login Screen
```

---

## Flow 6 · Auth — Login (Wave 3)

**Trigger:** Returning user chưa đăng nhập (Wave 3+).

```
Splash
  └── Login Screen (03)
        ├── Nhập email + password
        ├── [Sign in]
        │     ├── Success → Home
        │     └── Error → Inline error ("Invalid credentials")
        ├── [Forgot password?] → Forgot Password Screen (04b)
        └── [New here? Create account] → Sign Up Screen
```

---

## Flow 7 · Forgot Password (Wave 3)

**Trigger:** Nhấn "Forgot password?" từ Login.

```
Login Screen
  └── [Forgot password?]
        └── Forgot Password Screen (04b)
              ├── Nhập email
              ├── [Send reset link]
              │     ├── Success → hiển thị inline confirmation toast
              │     │     └── "Check your inbox. Link expires in 15 minutes."
              │     └── Error → "No account with this email"
              └── [← Back to sign in] → Login Screen
```

**Note:** Available in Wave 3. Trong V1 local, màn này hiển thị badge "Available in Wave 3" và disable CTA.

---

## Flow 8 · Notification Permission (Android 13+)

**Trigger:** Sau khi Onboarding Step 3 (Ready) hoàn thành, trên Android 13+.

```
Onboarding Step 3 — Ready
  └── [Start my streak]
        └── Notification Permission Screen (02d)
              ├── [Allow notifications]
              │     └── OS permission dialog
              │           ├── Allow → set notif_enabled = true → Home
              │           └── Deny → Home (notif_enabled = false)
              └── [Not now] → Home (notif_enabled = false)
```

**Note:** Màn 02d là custom screen TRƯỚC khi trigger OS dialog. Mục đích: giải thích value trước để tăng tỉ lệ accept.

---

## Flow 9 · Feed — Compose Post

**Trigger:** Tap vào compose bar hoặc send icon từ Feed screen.

```
Feed Screen (07)
  └── [Compose bar] hoặc [send icon]
        └── Feed Compose Screen (07b)
              ├── Nhập text (tối đa 280 ký tự)
              ├── Optional: chọn "Tone" tag (Progress update / Rough day / ...)
              ├── Streak day tự động attach
              ├── [Post] (gold button top-right)
              │     ├── Wave 1: lưu local mock
              │     └── Wave 3: POST lên Supabase feed_posts
              │           └── Feed Screen (new post ở đầu)
              └── [✕ Cancel] → Feed Screen
```

---

## Flow 10 · Badge Detail

**Trigger:** Tap vào bất kỳ badge nào từ Badges screen.

```
Badges Screen (08)
  └── [Tap badge card]
        └── Badge Detail Screen (08b)
              ├── Hiển thị badge icon lớn, tên, mô tả, ngày unlock (nếu có)
              ├── [Share to Feed] (nếu unlocked)
              │     └── Feed Compose Screen, pre-filled với badge info
              └── [← Back] → Badges Screen
```

---

## Flow 11 · Streak History

**Trigger:** Tap vào stats từ Profile, hoặc từ Profile menu.

```
Profile Screen (09)
  └── [Streak history row] hoặc [stat card]
        └── Streak History Screen (09b)
              ├── Hiển thị tất cả streaks (current + all past)
              ├── Stats: total streaks / lifetime clean / best streak
              └── [← Back] → Profile Screen
```

---

## Flow 12 · Premium Upgrade — Paywall

**Trigger:** Tap vào bất kỳ premium feature nào, hoặc từ Profile "Upgrade to Premium".

```
Triggers có thể:
  Profile → [Upgrade to Premium]
  Home → Ryan companion teaser → tap
  Badges → Special badge với pill "Premium"
  Settings → Notification time → pill "Premium"

  └── Paywall Screen (10)
        ├── Annual plan pre-selected
        ├── [Monthly plan] → switch selection
        ├── [Start free trial] (purple button)
        │     ├── Wave 4 (RevenueCat): trigger purchase flow
        │     │     ├── Success → set premium = true → previous screen
        │     │     └── Cancel / Error → Paywall (stay)
        │     └── Wave 1 (local): disabled, hiển thị "Coming in Wave 4"
        └── [← Back] / [✕] → previous screen
```

---

## Flow 13 · Journal (Premium)

**Trigger:** Tap Journal từ nav hoặc dari Profile. Gated behind premium entitlement.

```
[Any nav entry to Journal]
  ├── isPremium = false → Paywall Screen
  └── isPremium = true →
        Journal Screen (11)
          ├── Entry hôm nay tồn tại → hiển thị editable
          ├── Entry hôm nay chưa có → text area placeholder
          ├── [Save] → lưu entry → refresh list
          ├── [Tap old entry] → Entry Detail
          │     └── [Delete] → confirmation → remove entry → Journal Screen
          └── [← Back] → previous screen
```

---

## Flow 14 · Relapse Analytics (Premium)

**Trigger:** Tap Analytics từ Profile. Gated behind premium entitlement.

```
[Navigate to Analytics]
  ├── isPremium = false → Paywall Screen
  └── isPremium = true →
        Analytics / Patterns Screen (12)
          ├── relapses < 3 → Empty state: "Not enough data yet."
          └── relapses >= 3 → full charts + stats
                └── [← Back] → Profile Screen
```

---

## Flow 15 · Settings — Notifications

**Trigger:** Từ Profile → "Notifications" hoặc Settings screen.

```
Profile Screen
  └── [Notifications] row
        └── Settings Screen (13)
              ├── Daily reminder toggle
              │     ├── ON → notification scheduled (8:00 AM fixed on free)
              │     └── OFF → cancel notification
              ├── Reminder time picker
              │     ├── isPremium = true → time picker available
              │     └── isPremium = false → locked, hiển thị pill "Premium" → tap → Paywall
              └── [← Back] → Profile Screen
```

---

## Flow 16 · Sign Out (Wave 3)

**Trigger:** Tap "Sign out" từ Profile screen.

```
Profile Screen
  └── [Sign out]
        └── Confirmation dialog
              ├── [Cancel] → Profile Screen
              └── [Sign out]
                    → clear Supabase session
                    → giữ local streak data (shared_preferences)
                    → Login Screen
```

---

## Navigation Structure (Tổng quan)

```
Bottom Navigation (4 tabs):
  Tab 1: Home (house icon)
  Tab 2: Feed (people icon)
  Tab 3: Badges (medal icon)
  Tab 4: Profile (user icon)

Screens KHÔNG có trong bottom nav (pushed):
  - Relapse (from Home CTA only)
  - Check-in Confirmation (from Home CTA only)
  - Feed Compose (from Feed)
  - Badge Detail (from Badges)
  - Streak History (from Profile)
  - Paywall (from multiple triggers)
  - Journal (from nav or Profile — premium)
  - Analytics (from Profile — premium)
  - Settings (from Profile)
  - Forgot Password (from Login)
  - Onboarding (first launch only)
```

---

## Deep Link Map (Wave 3+)

| Intent | Deep link | Destination |
|---|---|---|
| Open to check-in | `nut://checkin` | Home → auto-trigger check-in |
| Open to journal | `nut://journal` | Journal (or Paywall) |
| Streak milestone notification | `nut://home` | Home |
| Reset reminder | `nut://home` | Home |

---

## Error States (All Flows)

| Tình huống | Behavior |
|---|---|
| No internet (Wave 3+) | Toast: "You're offline. Your streak is safe." Data writes queued. |
| Supabase load failed | Inline: "Couldn't load. Pull down to retry." |
| Auth error | Inline: "Something went wrong. Try again." |
| Purchase failed | Toast: "Purchase didn't go through. Try again." |
| Already checked in today | "Check in" button = disabled, label: "Checked in ✓" |
