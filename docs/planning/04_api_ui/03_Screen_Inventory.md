# NUT — Screen Inventory & Flow (Version 1)

Last updated: June 2026

---

## Overview

Version 1 có tổng cộng **14 screens** chia làm 4 nhóm:

| Nhóm | Screens | Ghi chú |
|---|---|---|
| Onboarding & Auth | 4 | Chỉ xuất hiện lần đầu hoặc khi chưa login |
| Core (free) | 5 | Toàn bộ user truy cập được |
| Premium | 3 | Gated behind RevenueCat entitlement |
| System | 2 | Settings + universal empty states |

---

## Nhóm 1 — Onboarding & Auth

### Screen 01 · Splash
**File:** `lib/features/splash/splash_screen.dart`
**Trigger:** App khởi động, trước khi check auth state
**Duration:** ~1.5 giây, sau đó router tự navigate

**Content:**
- Logo NUT centered trên nền #0D0D0D
- Không có text, không có loading spinner
- Fade out → navigate to Onboarding (first launch) hoặc Home (returning user)

**Logic:**
```
if (firstLaunch) → Onboarding
else if (notLoggedIn) → Login       ← Wave 3 (Supabase)
else → Home
```

---

### Screen 02 · Onboarding
**File:** `lib/features/onboarding/onboarding_screen.dart`
**Trigger:** First launch only. Sau khi complete, set `onboarding_done = true` trong shared_preferences.

**Flow — 3 bước, không forced:**

**Bước 1 — Username**
- Headline: "What should we call you?"
- Input field, placeholder: "Your name or a nickname"
- Subtext: "Only you can see this."
- CTA: "Continue" | Skip link nhỏ phía dưới

**Bước 2 — Reason**
- Headline: "Why are you here?"
- Subtext: "No wrong answers. This is just for you."
- Multi-select pills:
  - Better focus
  - More energy
  - Build discipline
  - Improve relationships
  - Just trying it
  - Prefer not to say
- CTA: "Continue" | Skip

**Bước 3 — Ready**
- Headline: "You're ready."
- Body: "Your streak starts now. Come back tomorrow."
- Streak counter hiển thị "0" bằng gold — ngay từ màn này
- CTA: "Start" (primary gold button)
- Không có skip ở bước này

**Data saved:** `username`, `reasons[]`, `streak_start_date`, `onboarding_done = true`

---

### Screen 03 · Login
**File:** `lib/features/auth/login_screen.dart`
**Trigger:** Wave 3 — khi Supabase được integrate. Trong V1 local MVP, screen này chưa active.

**Content:**
- Logo nhỏ ở top
- Headline: "Welcome back."
- Email input
- Password input
- CTA: "Sign in"
- Link: "Forgot password?" → Screen 04
- Link nhỏ dưới cùng: "New here? Create account"

**Note:** Không dùng social login (Google/Apple) ở V1 — giữ đơn giản, tránh phụ thuộc OAuth config.

---

### Screen 04 · Sign Up
**File:** `lib/features/auth/signup_screen.dart`
**Trigger:** Wave 3

**Content:**
- Headline: "Create your account."
- Email input
- Password input
- Confirm password input
- CTA: "Create account"
- Fine print: "By continuing you agree to our Terms and Privacy Policy."
- Link: "Already have an account? Sign in"

**Note:** Sau khi sign up thành công → go to Onboarding nếu chưa có local data, hoặc Home nếu đã có.

---

## Nhóm 2 — Core (Free)

### Screen 05 · Home
**File:** `lib/features/streak/home_screen.dart`
**Tab:** Home (tab 1)

**Layout từ trên xuống:**
1. Status bar
2. **Hero — Streak counter**
   - Eyebrow: "CURRENT STREAK" (muted, uppercase, small)
   - Number: 72sp+, JetBrains Mono weight 300, gold
   - Label: "days clean"
   - Message: calm supportive copy, rotates theo milestone (xem bên dưới)
3. **Primary CTA:** "Check in today" (gold button)
4. **Secondary CTA:** "I relapsed" (ghost button) → navigate to Relapse screen
5. Section: "Your progress" — 2 stat cards (Lifetime clean / Best streak)
6. Section: "Next milestone" — card với progress bar
7. Section: "Today" — Daily quote card
8. Ryan teaser card (purple, subtle) — disappears khi V2 launch

**Supportive messages theo milestone range:**
| Streak range | Message |
|---|---|
| 0–6 days | "Every day counts. Starting is the hardest part." |
| 7–29 days | "One week down. Keep the momentum." |
| 30–89 days | "A month of clarity. You're building something real." |
| 90–364 days | "This is rare. Most people never get here." |
| 365+ days | "One year. This is who you are now." |

---

### Screen 06 · Relapse
**File:** `lib/features/streak/relapse_screen.dart`
**Trigger:** Tap "I relapsed" từ Home. Không accessible từ nav.

**Layout:**
1. Eyebrow: small red dot + "Reset" label — red dùng làm semantic cue nhỏ, KHÔNG làm full red screen
2. **Title:** "This does not erase your effort."
3. **Body:** "Take a breath. Start again with what you learned."
4. **Streak recap card** — hiển thị streak vừa kết thúc + lifetime clean days
5. Section: "What happened? (optional)" — multi-select pills
   - Stress / Boredom / Late night / Loneliness / Triggered by content / Other
   - Data này feed vào Relapse Analytics (premium)
6. **Actions:**
   - Primary gold: "Keep going — don't reset" (to, nổi)
   - Destructive ghost: "Reset my streak" (nhỏ hơn, red border)
7. Footer text nhỏ: reassurance copy

**Copy rules — KHÔNG dùng:**
- "failed", "lost", "weak", "start from zero", "back to day 0"

**Copy được dùng:**
- "reset", "start again", "new chapter", "what you learned"

**Logic:**
```
"Keep going" → back to Home, streak unchanged
"Reset my streak" → confirmation bottom sheet → confirm → reset streak → Home
```

**Confirmation bottom sheet (trước khi reset):**
- Title: "Reset your streak?"
- Body: "Your history stays. You're just starting a new chapter."
- Confirm: "Yes, reset" (red)
- Cancel: "Go back" (ghost)

---

### Screen 07 · Feed
**File:** `lib/features/feed/feed_screen.dart`
**Tab:** Feed (tab 2)

**Layout:**
1. Header: "Community" + member count pill
2. Compose bar (avatar + placeholder "Share your progress…" + send icon)
3. Feed cards — mỗi card gồm:
   - Avatar + username + timestamp
   - Streak day pill (gold nếu milestone, muted nếu bình thường, green nếu 365+)
   - Content text
   - Reaction row: ❤️ count + 💬 count + share icon

**Compose screen** (modal hoặc separate screen):
- Full-screen text input
- Streak day tự động attach
- Character count
- Post button

**Empty state:**
- Illustration đơn giản (vài lines SVG)
- Copy: "No posts yet. Be the first to share."
- CTA: "Share your progress"

**Feed content rules:**
- Text-first, không có image upload (Google Play policy risk)
- Không có comment thread ở V1 — chỉ reactions
- Không có report/moderation UI ở V1

---

### Screen 08 · Badges
**File:** `lib/features/badges/badges_screen.dart`
**Tab:** Badges (tab 3)

**Layout:**
1. Header: "Milestones" + "X of Y unlocked"
2. Section: "Streak milestones" — 2-column grid
   - 7 days 🌱 / 30 days 🔥 / 90 days ⚡ / 365 days 🏆
   - Unlocked: green border, green number, checkmark
   - Locked: dimmed (opacity 0.45), shows days remaining
3. Section: "Special badges" — 2-column grid
   - 7 Journals (premium pill) / Night owl / Comeback kid / etc.

**Badge detail** (tap → bottom sheet):
- Badge icon lớn
- Tên badge
- Mô tả ngắn
- Ngày unlock (nếu đã unlock)
- Share button (chia sẻ lên Feed)

---

### Screen 09 · Profile
**File:** `lib/features/profile/profile_screen.dart`
**Tab:** Profile (tab 4)

**Layout:**
1. Avatar placeholder (initials) + username + join date
2. Stats row: Current streak / Lifetime clean / Total relapses
3. Section: "Reason" — hiển thị reason từ onboarding (editable)
4. Section: "Account"
   - Edit username
   - Notification settings → Settings screen
   - Premium status (nếu free: "Upgrade to Premium" CTA)
5. Section: "App"
   - Privacy Policy (opens webview/browser)
   - Terms of Service
   - Rate the app (opens store)
   - App version
6. Sign out (Wave 3)

---

## Nhóm 3 — Premium (gated)

### Screen 10 · Paywall
**File:** `lib/features/paywall/paywall_screen.dart`
**Trigger:** Tap vào bất kỳ premium feature nào, hoặc từ Profile

**Layout:**
1. Icon ✦ trong purple rounded square
2. Title: "NUT Premium"
3. Subtext: "Tools for the long game. No ads. No noise."
4. **Plan cards** — Annual pre-selected:
   - Annual: $29.99/year → hiển thị $2.50/month + "Save 50%" green pill
   - Monthly: $4.99/month
5. "7-day free trial · cancel anytime"
6. Feature list (5 items, purple dots)
7. CTA: "Start free trial" (purple button)
8. Fine print: price after trial + Restore purchases + Terms + Privacy

**Rules:**
- Annual LUÔN được pre-select
- Không dùng countdown timer giả tạo
- Không dùng "Limited offer" nếu không có thật
- Purple chỉ xuất hiện ở screen này

---

### Screen 11 · Journal
**File:** `lib/features/journal/journal_screen.dart`
**Gated:** Premium only

**Layout:**
1. Header: "Journal" + date hôm nay
2. Nếu đã có entry hôm nay: hiển thị entry, editable
3. Nếu chưa có: text area với placeholder "What's on your mind today?"
4. Save button
5. List các entry cũ (date + excerpt)

**Entry detail screen:**
- Full text
- Date
- Streak day tại thời điểm đó
- Delete option

---

### Screen 12 · Relapse Analytics
**File:** `lib/features/analytics/relapse_analytics_screen.dart`
**Gated:** Premium only

**Layout:**
1. Header: "Patterns"
2. Subtext: "Understanding your triggers helps you break them."
3. Card: "Most common trigger" — top reason từ relapse reflection data
4. Chart: Relapses by day of week (bar chart, 7 bars)
5. Chart: Relapses by time of day (morning/afternoon/evening/night)
6. Card: Average streak length (so sánh với global average nếu có data)
7. Empty state nếu < 3 relapses: "Not enough data yet. Check back later."

**Note:** Data source là reflection pills từ Relapse screen. Nếu user không chọn pills, analytics sẽ có ít data — đây là incentive tự nhiên để điền reflection.

---

## Nhóm 4 — System

### Screen 13 · Settings
**File:** `lib/features/settings/settings_screen.dart`
**Trigger:** Từ Profile screen

**Content:**
1. Notification toggle + time picker (premium: custom time; free: fixed 8:00 AM)
2. Theme (V1: dark only)
3. Data & Privacy
   - Export my data (Wave 3+)
   - Delete account (Wave 3+)
4. About: version, licenses

---

### Screen 14 · Onboarding Empty / Error states
**File:** trong từng feature screen

**Empty states cần có:**
| Screen | Empty state copy |
|---|---|
| Feed | "No posts yet. Be the first to share." |
| Badges | "Your first milestone is 7 days away." |
| Journal | "Your first entry starts here." |
| Analytics | "Come back after a few more check-ins." |

**Error states cần có:**
| Tình huống | Copy |
|---|---|
| No internet (Wave 3+) | "You're offline. Your streak is safe." |
| Load failed | "Couldn't load. Pull down to retry." |
| Auth error | "Something went wrong. Try again." |

---

## Navigation flow tổng quan

```
App open
  │
  ├─ First launch ──→ Splash ──→ Onboarding (3 steps) ──→ Home
  │
  └─ Returning ─────→ Splash ──→ Home
                                   │
                          ┌────────┼────────┬────────┐
                        Feed    Badges   Profile  [Relapse modal]
                                              │
                                         Settings
                                         Paywall
                                         Journal (premium)
                                         Analytics (premium)
```

---

## V1 → V2 portability

Những assets/data từ V1 dùng thẳng sang V2 không cần làm lại:

| Asset | V1 usage | V2 usage |
|---|---|---|
| 365 daily quotes | Quote card trên Home | Ryan morning letter |
| Relapse reflection data | Analytics chart | Ryan response logic (trigger-based) |
| Milestone badge data | Badges screen | Ryan reaction events |
| Streak history | Stats | Ryan departure/return rule engine |
| Username | Profile display | Ryan calls user by name |
| Reason from onboarding | Profile display | Ryan references user's "why" |

> Đầu tư viết 365 quotes ngay từ V1 — đây là content tốn công nhất và dùng được lâu nhất.
