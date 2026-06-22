# NUT — Build Guide: 36 Files, Theo Thứ Tự

> File này là prompt hướng dẫn chi tiết cho từng file cần viết.
> Đọc xong thì biết file đó cần làm gì, lấy thông tin ở đâu, viết như thế nào.
> Thứ tự = thứ tự phụ thuộc — làm tuần tự, đừng nhảy cóc.

---

## Nguồn tham khảo chính

| Ký hiệu | File |
|---|---|
| `[DS]` | `nut_docs/04_api_ui/02_Design_System.md` |
| `[SI]` | `nut_docs/04_api_ui/03_Screen_Inventory.md` |
| `[UF]` | `nut_docs/04_api_ui/01_User_Flows.md` |
| `[DB]` | `nut_docs/03_system_design/03_Database_Architecture.md` |
| `[HTML]` | `nut_docs/04_api_ui/nut_ui_v5.html` (hoặc bản copy ở root) |

---

---

# PHẦN 1 — FOUNDATION
> Không phụ thuộc file nào khác. Phải xong trước hết.

---

## 01 · `lib/app/constants.dart`
**Trạng thái:** Rỗng — cần viết mới hoàn toàn

**Mục đích:** Tập trung toàn bộ string copy, milestone text, quote placeholder — tách khỏi UI để sau này dễ dịch / thay nội dung mà không cần chạm vào widget.

**Nội dung cần có:**

### 1. Streak milestone messages
Lấy từ `[SI]` → Screen 05 · Home → bảng "Supportive messages theo milestone range":
```
0–6 days   → "Every day counts. Starting is the hardest part."
7–29 days  → "One week down. Keep the momentum."
30–89 days → "A month of clarity. You're building something real."
90–364 days → "This is rare. Most people never get here."
365+ days  → "One year. This is who you are now."
```
Viết thành static method `streakMessage(int days) → String`.

### 2. Relapse trigger options
Lấy từ `[SI]` → Screen 06 · Relapse → "multi-select pills":
```
Stress / Boredom / Late night / Loneliness / Triggered by content / Other
```
Viết thành `const List<String> relapseTriggers`.

### 3. Onboarding reason options
Lấy từ `[SI]` → Screen 02 · Onboarding → Bước 2:
```
Better focus / More energy / Build discipline / Improve relationships / Just trying it / Prefer not to say
```
Viết thành `const List<String> onboardingReasons`.

### 4. Relapse copy rules
Lấy từ `[SI]` → Screen 06 và `[DS]` → "Relapse screen":
- Approved: "reset", "start again", "new chapter", "what you learned"
- Forbidden: không đưa vào code — chỉ ghi comment để dev nhớ

### 5. Paywall copy
Lấy từ `[SI]` → Screen 10 · Paywall:
```
Title: "NUT Premium"
Subtext: "Tools for the long game. No ads. No noise."
Trial text: "7-day free trial · cancel anytime"
Annual price: "$29.99/year"
Monthly price: "$4.99/month"
Per month equiv: "$2.50/month"
Save label: "Save 50%"
Feature list: 5 items (lấy từ HTML → paywall section)
```

### 6. Badge definitions
Lấy từ `[SI]` → Screen 08 · Badges:
```
7 days   🌱 "First Week"
30 days  🔥 "One Month"
90 days  ⚡ "90 Days"
365 days 🏆 "One Year"
```
Viết thành `const List<Map>` hoặc để trong `badge_model.dart` — chọn 1 chỗ, không để 2 chỗ.

**Không cần:** màu sắc (đã có trong `theme.dart`), spacing (đã có trong `NutSpacing`).

---

## 02 · `lib/app/theme.dart`
**Trạng thái:** Đã có — chỉ cần review

**Việc cần làm:** Đọc `[DS]` → So sánh với file hiện tại. File hiện tại khá đầy đủ. Chỉ cần kiểm tra:
- `NutColors.background` = `#0D0D0D` ✓ (đã có)
- Có đủ `premiumBg` = `#13122A` chưa? (HTML dùng `#13122A`, theme.dart hiện có `#28244F` — cân nhắc điều chỉnh)
- Card border color: HTML dùng `rgba(255,255,255,0.065)` — hiện chưa có token này, có thể thêm `NutColors.border`

**Không cần viết lại** — file này đã tốt.

---

## 03 · `lib/shared/services/local_storage_service.dart`
**Trạng thái:** Rỗng — cần viết mới

**Mục đích:** Wrapper duy nhất cho `shared_preferences`. Mọi read/write đều đi qua đây, không có file nào khác gọi thẳng SharedPreferences.

**Keys cần có** (lấy từ `[DB]` → "Local persistence"):
```dart
static const kOnboardingDone = 'onboarding_complete';   // bool
static const kUsername       = 'username';               // String
static const kReason         = 'reason';                 // String
static const kStreakStart    = 'streak_start_date';      // String ISO8601
static const kLastRelapse    = 'last_relapse_date';      // String ISO8601
static const kLifetimeDays   = 'lifetime_clean_days';   // int
static const kRelapseCount   = 'relapse_count';          // int
static const kRelapseTriggers = 'relapse_triggers';      // String (JSON list)
static const kNotifEnabled   = 'notif_enabled';          // bool
static const kLastCheckin    = 'streak_last_checkin';    // String ISO8601
```

**Methods cần có:**
```dart
Future<void> setBool(String key, bool value)
Future<bool?> getBool(String key)
Future<void> setString(String key, String value)
Future<String?> getString(String key)
Future<void> setInt(String key, int value)
Future<int?> getInt(String key)
Future<void> remove(String key)
Future<void> clear()  // dùng khi sign out
```

**Lưu ý:** `streak_service.dart` hiện tại đang gọi SharedPreferences trực tiếp — sau này sẽ refactor để dùng service này. Chưa cần refactor ngay.

---

## 04 · `lib/shared/models/user_model.dart`
**Trạng thái:** Rỗng — cần viết mới

**Mục đích:** Model đơn giản đại diện cho user local (Wave 1). Wave 3 sẽ mở rộng thêm `id`, `email`.

**Fields** (lấy từ `[DB]` → table `users` và local persistence):
```dart
class UserModel {
  final String? username;
  final String? reason;
  final DateTime? createdAt;
  final bool onboardingDone;
}
```

**Methods:**
- `copyWith(...)` — standard
- `toJson()` / `fromJson()` — để sau khi sync Supabase (Wave 3)
- `displayName` getter — trả về username nếu có, fallback `"You"`

**Không cần:** auth fields (`email`, `password`) — để trong Wave 3.

---

## 05 · `lib/features/streak/streak_model.dart`
**Trạng thái:** Đã có — review nhẹ

**File hiện tại đã có:** `startDate`, `lifetimeCleanDays`, `currentDuration()`, `currentStreakDays()`, `copyWith()`.

**Cần thêm:**
- `relapseCount` field (lấy từ `[DB]` → table `streaks`)
- `bestStreak` field — để hiển thị "Best streak" stat card trong Home `[SI]` → Screen 05
- `lastCheckinDate` — để logic check "đã check-in hôm nay chưa" `[UF]` → Flow 3
- getter `isCheckedInToday` → `lastCheckinDate?.day == DateTime.now().day`
- getter `milestoneMessage` → gọi `AppConstants.streakMessage(days)`

---

## 06 · `lib/features/journal/journal_entry_model.dart`
**Trạng thái:** Rỗng — cần viết mới

**Fields** (lấy từ `[DB]` → table `journal_entries`):
```dart
class JournalEntry {
  final String id;        // UUID local
  final String content;
  final String? mood;     // optional
  final DateTime createdAt;
  final int streakDay;    // streak day tại thời điểm viết
}
```

**Methods:**
- `copyWith(...)`
- `toJson()` / `fromJson()` — Wave 3 Supabase sync
- `excerpt` getter — trả về 100 ký tự đầu + "..."

---

---

# PHẦN 2 — SHARED WIDGETS
> Phụ thuộc vào `theme.dart`. Cần xong trước khi làm screens.

---

## 07 · `lib/shared/widgets/nut_button.dart`
**Trạng thái:** Rỗng — nhưng `home_screen.dart` đang import `NutPrimaryButton`, `NutGhostButton` từ đây → file này CÓ THỂ đã tồn tại với nội dung, kiểm tra lại

**Nếu rỗng thật, cần viết:**

### NutPrimaryButton
- Background: `NutColors.accentGold`
- Text color: `NutColors.background` (dark)
- Full width (`double.infinity`)
- Height: 54px
- Radius: `NutRadius.button` (12px)
- Optional `icon` param — nếu có thì Row(icon + label)
- Loading state: hiện `CircularProgressIndicator` nhỏ khi `onPressed == null && isLoading == true`

### NutGhostButton
- Background: transparent
- Border: 1px `NutColors.textMuted`
- Full width
- Optional `foregroundColor` param — để Relapse screen dùng màu đỏ

### NutDestructiveButton
- Background: `NutColors.resetBg`
- Text/icon color: `NutColors.reset`
- Dùng cho "Reset my streak" trong confirmation sheet

**Tham khảo visual:** `[HTML]` → tìm `.btn-primary`, `.btn-ghost`, `.btn-destructive` trong CSS và các screen dùng chúng.

---

## 08 · `lib/shared/widgets/pill_chip.dart`
**Trạng thái:** Rỗng — cần viết mới

**Mục đích:** Pill multi-select dùng ở Onboarding (reason) và Relapse (trigger). Hiện tại Onboarding đang dùng `NutPill` inline — đây là version có interaction.

**Props:**
```dart
PillChip({
  required String label,
  required bool selected,
  required VoidCallback? onTap,
  Color? selectedBg,       // default: NutColors.accentBg
  Color? selectedFg,       // default: NutColors.accentGold
  Color? unselectedBg,     // default: NutColors.surface
  Color? unselectedFg,     // default: NutColors.textSecondary
  IconData? selectedIcon,  // default: Icons.check
})
```

**Visual:** Radius 999px (pill), padding 10px 16px, font 13sp weight 400. Tham khảo `[HTML]` → `.pill` class và `.pill.selected` state.

---

## 09 · `lib/shared/widgets/stat_card.dart`
**Trạng thái:** Đã có — không cần thay đổi. File tốt rồi.

---

## 10 · `lib/shared/widgets/section_header.dart`
**Trạng thái:** Đã có — không cần thay đổi.

---

## 11 · `lib/shared/widgets/badge_card.dart`
**Trạng thái:** Rỗng — cần viết mới

**Mục đích:** Card hiển thị 1 badge trong grid 2 cột ở Badges screen.

**Props:**
```dart
BadgeCard({
  required String emoji,
  required String title,
  required String description,
  required bool unlocked,
  int? daysRemaining,       // nếu locked, hiển thị "X days away"
  DateTime? unlockedAt,     // nếu unlocked, hiển thị ngày
  VoidCallback? onTap,
})
```

**Visual (lấy từ `[SI]` → Screen 08 và `[HTML]`):**
- Unlocked: border xanh lá (`NutColors.success`), opacity 100%, có checkmark góc trên phải
- Locked: opacity 0.45, không có border màu, hiện "X days away" thay vì ngày unlock
- Emoji lớn ở giữa trên
- Title + description bên dưới
- Tap → bottom sheet (xử lý ở `badges_screen.dart`, không phải ở đây)

---

## 12 · `lib/shared/widgets/bottom_nav.dart`
**Trạng thái:** Rỗng — cần viết mới

**Lưu ý quan trọng:** `nut_app.dart` hiện đang dùng Flutter's built-in `NavigationBar` widget trực tiếp. Có 2 lựa chọn:
1. Giữ nguyên `NavigationBar` trong `nut_app.dart` (đơn giản hơn)
2. Extract ra `bottom_nav.dart` để dễ custom sau (khuyến nghị)

**Nếu extract:**
```dart
BottomNav({
  required int selectedIndex,
  required ValueChanged<int> onChanged,
})
```

4 tabs theo thứ tự `[SI]` → Navigation: Home / Feed / Badges / Profile. Icon lấy từ `nut_app.dart` hiện tại.

**Visual:** Background `NutColors.surface`, selected icon/label màu `NutColors.accentGold`, indicator `NutColors.accentBg`. Đã config trong `theme.dart` → `navigationBarTheme`.

---

---

# PHẦN 3 — APP SHELL
> Routing và entry point. Phụ thuộc tất cả features.

---

## 13 · `lib/app/router.dart`
**Trạng thái:** Rỗng — cần viết mới

**Package:** `go_router` — kiểm tra `pubspec.yaml` xem đã có chưa, nếu chưa thì thêm.

**Routes cần define** (lấy từ `[UF]` → Navigation Structure):

```
/splash          → SplashScreen
/onboarding      → OnboardingScreen
/                → Shell (bottom nav)
  /home          → HomeScreen        (tab 0)
  /feed          → FeedScreen        (tab 1)
  /badges        → BadgesScreen      (tab 2)
  /profile       → ProfileScreen     (tab 3)
/relapse         → RelapseScreen     (push, no nav)
/feed/compose    → ComposeScreen     (push modal)
/badges/:id      → BadgeDetailSheet  (bottom sheet hoặc push)
/paywall         → PaywallScreen     (push)
/journal         → JournalScreen     (push, premium gated)
/analytics       → AnalyticsScreen   (push, premium gated)
/settings        → SettingsScreen    (push)
/auth/login      → LoginScreen       (Wave 3)
/auth/signup     → SignupScreen      (Wave 3)
```

**Logic redirect** (lấy từ `[UF]` → Flow 1 và Flow 2):
```dart
redirect: (context, state) {
  if (!onboardingDone && state.uri.path != '/onboarding') return '/onboarding';
  // Wave 3: thêm auth check ở đây
  return null;
}
```

**Shell route:** Dùng `ShellRoute` của go_router để giữ bottom nav persistent khi navigate giữa các tab.

---

## 14 · `lib/main.dart`
**Trạng thái:** Đã có — cần cập nhật nhẹ

**Hiện tại:** Khởi tạo `StreakService`, `OnboardingService`, `FeedService` rồi pass vào `NutApp`.

**Cần thêm:**
- Khởi tạo `LocalStorageService` (sau khi file đó xong)
- Sau khi có `router.dart`: bỏ logic routing trong `nut_app.dart`, pass router vào `MaterialApp.router`
- Comment rõ: `// Wave 3: init Supabase here` và `// Wave 4: init RevenueCat here`

**Không cần thay đổi nhiều** — file này ngắn và sạch rồi.

---

## 15 · `lib/app/nut_app.dart`
**Trạng thái:** Đã có — cần refactor khi router xong

**Hiện tại:** `nut_app.dart` đang chứa luôn `_NutRoot`, `_NutShell`, navigation logic, bottom nav. Khá coupled.

**Sau khi có `router.dart`:**
- `NutApp` chỉ còn: `MaterialApp.router(routerConfig: appRouter, theme: NutTheme.light())`
- `_NutRoot` và `_NutShell` move vào `router.dart` hoặc thành file riêng `lib/app/shell.dart`
- State management (streak, onboarding) move vào Provider/Riverpod hoặc InheritedWidget — quyết định pattern trước khi làm

**Ghi chú state management:** File hiện tại dùng `StatefulWidget` pass-down. Ổn cho MVP nhưng sẽ đau khi app lớn. Nên xem xét `provider` package (nhẹ, đơn giản) ngay từ bây giờ.

---

---

# PHẦN 4 — SCREENS (theo flow người dùng)

---

## 16 · `lib/features/splash/splash_screen.dart`
**Trạng thái:** Rỗng — cần viết mới

**Mô tả** `[SI]` → Screen 01:
- Logo NUT centered, nền `#0D0D0D`
- Không có text, không spinner
- Tự navigate sau 1.5 giây
- Fade out animation

**Logic navigate** (lấy từ `[UF]` → Flow 1 & 2):
```dart
await Future.delayed(const Duration(milliseconds: 1500));
if (onboardingDone) {
  context.go('/home');
} else {
  context.go('/onboarding');
}
// Wave 3: thêm check isLoggedIn → login nếu chưa
```

**Visual:** Logo là text "NUT" dùng font JetBrains Mono (hoặc monospace), uppercase, letter-spacing rộng — tham khảo `[HTML]` → `.wordmark` class. Fade animation dùng `AnimatedOpacity` hoặc `FadeTransition`.

---

## 17 · `lib/features/onboarding/onboarding_controller.dart`
**Trạng thái:** Rỗng — cần viết mới

**Mục đích:** Tách logic khỏi UI. `onboarding_screen.dart` hiện tại làm tất cả trong 1 StatefulWidget — khi thêm step mới sẽ phức tạp.

**Fields:**
```dart
class OnboardingController extends ChangeNotifier {
  int currentStep = 0;           // 0=name, 1=reason, 2=ready, (3=notif Android)
  String username = '';
  String? selectedReason;
  bool isSaving = false;
  
  void nextStep()
  void prevStep()
  void setUsername(String v)
  void setReason(String? v)
  Future<void> complete(Function(OnboardingProfile) onDone)
  Future<void> skip(Function(OnboardingProfile) onDone)
}
```

**Tham khảo step flow:** `[UF]` → Flow 1 (3 bước + optional notification bước 4 Android).

---

## 18 · `lib/features/onboarding/onboarding_screen.dart`
**Trạng thái:** Đã có — cần cải thiện

**Hiện tại:** 1 screen duy nhất với tất cả fields. Không có step-by-step flow.

**Cần đổi thành 3-step flow** theo `[SI]` → Screen 02:
- **Bước 1:** "What should we call you?" — text input username + skip
- **Bước 2:** "Why are you here?" — multi-select pills (lấy reasons từ `constants.dart`) + skip
- **Bước 3:** "You're ready." — hiện streak "0" màu gold, CTA "Start", không có skip

**Animation giữa steps:** `PageView` hoặc `AnimatedSwitcher` — không dùng Navigator push (không muốn back button giữa steps).

**Copy chính xác** lấy từ `[SI]` → Screen 02 từng bước.

**Lưu ý:** Bước 3 hiện streak = 0 bằng gold ngay từ màn này — tạo cảm giác streak đã bắt đầu.

---

## 19 · `lib/features/auth/login_screen.dart`
**Trạng thái:** Rỗng — Wave 3, tạo placeholder

**Nội dung tạm:** Scaffold với AppBar "Sign in" và body Text "Coming in Wave 3". Đừng viết form thật vì sẽ làm lại khi có Supabase.

**Lấy copy từ** `[SI]` → Screen 03 để comment vào file cho nhớ layout sau này.

---

## 20 · `lib/features/auth/signup_screen.dart`
**Trạng thái:** Rỗng — Wave 3, tạo placeholder

Tương tự login — placeholder + comment layout từ `[SI]` → Screen 04.

---

## 21 · `lib/features/streak/home_screen.dart`
**Trạng thái:** Đã có — cần bổ sung đáng kể

**Hiện tại thiếu so với spec `[SI]` → Screen 05:**

1. **Check-in logic:** Button "Check in today" — hiện tại có "Start streak" nhưng chưa có daily check-in. Cần:
   - Nếu `isCheckedInToday == true` → button disabled, label "Checked in ✓"
   - Nếu chưa check-in → button active → tap → tăng streak, lưu `lastCheckinDate`
   - Lấy logic từ `[UF]` → Flow 3

2. **Milestone message:** Hiện tại dùng reason-based message. Cần thêm milestone-based message từ `constants.dart` → `streakMessage(days)`

3. **"Your progress" section:** 2 stat cards — "Lifetime clean" (đã có) + "Best streak" (chưa có)

4. **"Next milestone" card:** Progress bar đến milestone kế tiếp (7/30/90/365). Tính `daysToNextMilestone`.

5. **"Today" section:** Daily quote card — placeholder text từ `constants.dart` trước, sau thêm 365 quotes.

6. **Ryan teaser card:** Card màu purple nhạt, text "Something's coming." — biến mất khi V2 launch. Tạm thời hardcode `showRyanTeaser = true`.

7. **"I relapsed" button:** Hiện navigate sai — `[UF]` → Flow 4: relapse screen KHÔNG reset streak ngay, chỉ hiện options. Sửa lại flow.

---

## 22 · `lib/features/streak/relapse_screen.dart`
**Trạng thái:** Đã có — cần sửa logic

**Vấn đề hiện tại:** `nut_app.dart` reset streak TRƯỚC khi navigate vào relapse screen — sai với spec. Streak chỉ được reset khi user confirm trong screen này.

**Đúng theo `[UF]` → Flow 4:**
```
"Keep going" → pop, streak KHÔNG thay đổi
"Reset my streak" → confirmation bottom sheet → confirm → reset → pop về Home
```

**Cần thêm:**
1. Trigger pills multi-select (6 options từ `constants.dart`) — optional, lưu vào `local_storage_service`
2. Confirmation bottom sheet (xem copy chính xác ở `[SI]` → Screen 06 → "Confirmation bottom sheet")
3. "Streak recap card" — hiển thị streak vừa kết thúc + lifetime clean days
4. Footer reassurance text nhỏ

**Copy rules** quan trọng từ `[SI]` → Screen 06: KHÔNG dùng "failed", "lost", "weak", "start from zero", "back to day 0".

---

## 23 · `lib/features/streak/streak_service.dart`
**Trạng thái:** Đã có — cần mở rộng

**Hiện tại có:** `loadStreak()`, `startStreak()`, `resetStreak()`.

**Cần thêm:**
- `checkIn()` → cập nhật `lastCheckinDate`, tăng streak nếu consecutive `[UF]` → Flow 3
- `saveRelapseTriggers(List<String> triggers)` → lưu vào localStorage
- `getBestStreak()` → tính best streak từ history
- Kiểm tra auto-reset: nếu `lastCheckinDate < yesterday` thì streak bị broken

**Lưu ý:** Sau khi có `local_storage_service.dart`, refactor để dùng service đó thay vì gọi SharedPreferences trực tiếp.

---

## 24 · `lib/features/feed/feed_post.dart`
**Trạng thái:** Đã có — thêm nhẹ

**Cần thêm:**
- `reactions` field — `Map<String, int>` (emoji → count) thay vì chỉ `reactionCount`
- `hasReacted` bool — để biết user hiện tại đã react chưa (local state)
- `toneTag` optional String — "Progress update / Rough day / ..." từ Compose screen `[UF]` → Flow 9

---

## 25 · `lib/features/feed/feed_service.dart`
**Trạng thái:** Đã có — cần xem nội dung thực tế

Chưa đọc được nội dung file này. Cần kiểm tra:
- Hiện đang mock data hay đọc từ đâu?
- Wave 1: trả về mock posts local
- Wave 3: POST lên Supabase `feed_posts` table `[DB]`

**Cần có methods:**
```dart
Future<List<FeedPost>> getPosts()
Future<FeedPost> createPost({required String content, required int streakDay, String? toneTag})
Future<void> reactToPost(String postId, String emoji)
```

---

## 26 · `lib/features/feed/feed_screen.dart`
**Trạng thái:** Đã có — cần bổ sung

**Cần thêm so với spec `[SI]` → Screen 07:**
1. Header: "Community" + member count pill (mock số hardcode Wave 1)
2. Compose bar ở top — avatar placeholder + "Share your progress…" text + send icon → navigate `/feed/compose`
3. Reaction row dưới mỗi post: ❤️ count + 💬 count (disabled Wave 1) + share icon
4. Empty state: illustration đơn giản + "No posts yet. Be the first to share." + CTA "Share your progress"
5. Streak day pill style: gold nếu milestone (7/30/90/365), green nếu 365+, muted nếu bình thường

---

## 27 · `lib/features/feed/compose_screen.dart`
**Trạng thái:** Rỗng — cần viết mới

**Layout theo `[UF]` → Flow 9 và `[SI]` → Screen 07:**
- Full-screen modal (push từ Feed)
- AppBar: "✕ Cancel" bên trái + "Post" button vàng bên phải
- Text area chiếm phần lớn màn hình, placeholder "Share your progress…"
- Character count hiện góc dưới phải (tối đa 280 ký tự — theo Twitter convention, phù hợp với text-first feed)
- Streak day badge tự động attach — hiện "Day X" nhỏ phía trên input
- Optional tone tag row (pills ngang): "Progress update / Rough day / Milestone / Question / Other"
- Post button disable khi text rỗng hoặc đang loading

---

## 28 · `lib/features/badges/badge_model.dart`
**Trạng thái:** Đã có — cần bổ sung

**Hiện tại có:** `title`, `requiredDays`, `description`, `isUnlocked(days)`.

**Cần thêm:**
- `emoji` field (🌱🔥⚡🏆)
- `id` field — string key unique để identify
- `unlockedAt` DateTime? — ngày unlock (lưu vào localStorage)
- `isPremium` bool — một số special badges gated (như "7 Journals")
- Static list `BadgeModel.all` — 4 streak badges + special badges từ `[SI]` → Screen 08

---

## 29 · `lib/features/badges/badges_screen.dart`
**Trạng thái:** Đã có — cần bổ sung đáng kể

**Layout theo `[SI]` → Screen 08:**
1. Header: "Milestones" + "X of Y unlocked" counter
2. Section "Streak milestones": 2-column grid, dùng `BadgeCard` widget
3. Section "Special badges": 2-column grid, một số có "Premium" pill
4. Tap badge → Bottom sheet detail (dùng `showModalBottomSheet`)

**Badge detail bottom sheet:**
- Badge icon/emoji lớn (64px+)
- Tên badge, mô tả
- Ngày unlock (nếu đã có) hoặc "X days away"
- "Share to Feed" button (nếu unlocked) → navigate `/feed/compose` pre-filled

**Unlock check:** So sánh `streak.currentStreakDays` với `badge.requiredDays` — đơn giản.

---

## 30 · `lib/features/profile/profile_screen.dart`
**Trạng thái:** Đã có — cần bổ sung

**Layout theo `[SI]` → Screen 09:**
1. Avatar placeholder (initials từ username, hoặc icon person nếu null) + username + join date
2. Stats row: 3 items — Current streak / Lifetime clean / Total relapses
3. Section "Reason": hiển thị reason từ onboarding, tap để edit (modal text input)
4. Section "Account":
   - Edit username → inline edit hoặc dialog
   - Notifications → navigate `/settings`
   - Premium status: nếu free → "Upgrade to Premium" CTA → `/paywall`
5. Section "App":
   - Privacy Policy → `url_launcher` mở browser
   - Terms of Service → tương tự
   - Rate the app → mở store (Wave 3)
   - App version → lấy từ `package_info_plus`
6. Sign out (Wave 3) — placeholder disabled

---

## 31 · `lib/features/settings/settings_screen.dart`
**Trạng thái:** Rỗng — cần viết mới

**Layout theo `[SI]` → Screen 13:**
1. Daily reminder toggle — lưu `notifEnabled` vào localStorage
2. Reminder time: free user = fixed 8:00 AM (locked), premium = time picker
   - Locked state: hiện "Premium" pill → tap → navigate `/paywall`
3. Theme section: Wave 1 chỉ có dark, hiện "Dark (default)" disabled
4. About section:
   - App version (dùng `package_info_plus`)
   - Open source licenses → `showLicensePage(context)`
5. Data & Privacy: "Export my data" và "Delete account" → Wave 3, hiện disabled với label "Coming soon"

**Notification local:** Dùng `flutter_local_notifications` — kiểm tra `pubspec.yaml`. Nếu chưa có, thêm vào. Logic: khi toggle ON → schedule daily notification lúc 8AM, khi OFF → cancel.

---

## 32 · `lib/features/paywall/paywall_screen.dart`
**Trạng thái:** Đã có — cần bổ sung đáng kể

**Layout đầy đủ theo `[SI]` → Screen 10 và `[DS]` → "Paywall screen":**
1. Icon ✦ trong purple rounded square (xem `[HTML]` → paywall section)
2. Title "NUT Premium", subtext từ `constants.dart`
3. Plan cards — 2 cards, Annual pre-selected:
   - Annual card: price lớn + "$2.50/month" nhỏ + "Save 50%" green pill
   - Monthly card: price only
   - Selected card có border `NutColors.premium`
4. Trial text: "7-day free trial · cancel anytime"
5. Feature list: 5 items với purple dot — lấy từ `[SI]` → Screen 10 hoặc `constants.dart`
6. CTA: "Start free trial" — purple background `NutColors.premium`
7. Fine print: 3 links nhỏ — "Restore purchases · Terms · Privacy"

**Wave 1:** CTA hiển thị "Coming soon" hoặc chỉ đóng screen. Chưa integrate RevenueCat.

**Rules không được vi phạm** từ `[DS]`: Không countdown timer giả, không "Limited offer" giả, purple chỉ ở màn này.

---

## 33 · `lib/features/journal/journal_service.dart`
**Trạng thái:** Rỗng — cần viết mới

**Wave 1:** Lưu local bằng `shared_preferences` (JSON list).

**Methods:**
```dart
Future<List<JournalEntry>> getEntries()
Future<JournalEntry> createEntry({required String content, String? mood, required int streakDay})
Future<JournalEntry> updateEntry(JournalEntry entry)
Future<void> deleteEntry(String id)
Future<JournalEntry?> getTodayEntry()  // check xem hôm nay đã viết chưa
```

**Storage key:** `'journal_entries'` → lưu JSON array.

**Wave 3:** Thêm Supabase sync — structure đã có trong `[DB]` → table `journal_entries`.

---

## 34 · `lib/features/journal/journal_screen.dart`
**Trạng thái:** Rỗng — cần viết mới (Premium gated)

**Gate check đầu tiên:** Nếu `isPremium == false` → navigate thay bằng `PaywallScreen`. Dùng `WillPopScope` hoặc check trong `router.dart`.

**Layout theo `[SI]` → Screen 11:**
1. Header: "Journal" + date hôm nay (format: "Monday, June 13")
2. Entry hôm nay:
   - Nếu có: hiển thị text, editable inline, Save button
   - Nếu chưa có: text area với placeholder "What's on your mind today?", Save button
3. List entries cũ dưới (date + excerpt 100 ký tự)
4. Tap entry cũ → Entry detail (push hoặc bottom sheet):
   - Full text
   - Date + streak day lúc viết
   - Delete button → confirmation dialog → xóa

**Empty state** `[SI]` → Screen 14: "Your first entry starts here."

---

## 35 · `lib/features/analytics/relapse_analytics_screen.dart`
**Trạng thái:** Rỗng — cần viết mới (Premium gated)

**Gate check:** Tương tự Journal.

**Layout theo `[SI]` → Screen 12:**
1. Header: "Patterns"
2. Subtext: "Understanding your triggers helps you break them."
3. **Empty state** nếu `relapseCount < 3`: "Not enough data yet. Check back later." — đừng show charts
4. Nếu đủ data:
   - Card "Most common trigger" — đếm relapse_triggers từ localStorage
   - Bar chart: Relapses by day of week (7 bars, Mon–Sun)
   - Grouped bar/segment: Relapses by time of day (morning/afternoon/evening/night)
   - Card: Average streak length

**Chart package:** `fl_chart` hoặc `syncfusion_flutter_charts` — kiểm tra `pubspec.yaml`. Nếu chưa có, dùng `fl_chart` (nhẹ hơn, free).

**Data source:** Relapse trigger data lưu trong localStorage từ Relapse screen. Parse và aggregate ở đây.

---

## 36 · `lib/shared/services/supabase_service.dart`
**Trạng thái:** Rỗng — Wave 3, chỉ cần scaffold

**Nội dung Wave 1:** Chỉ cần class rỗng với comment TODO rõ ràng:

```dart
// supabase_service.dart
// Wave 3 — Integrate khi có Supabase project
//
// Tables cần có (xem nut_docs/03_system_design/03_Database_Architecture.md):
//   users, streaks, feed_posts, badges, journal_entries
//
// RLS: all tables user-scoped except feed_posts (readable by all auth users)
//
// TODO Wave 3:
//   1. Add supabase_flutter to pubspec.yaml
//   2. Init in main.dart: await Supabase.initialize(url: ..., anonKey: ...)
//   3. Implement methods below
//
// Methods sẽ cần:
//   Future<void> signUp(email, password)
//   Future<void> signIn(email, password)
//   Future<void> signOut()
//   Future<void> syncStreak(StreakModel streak)
//   Future<void> syncJournalEntry(JournalEntry entry)
//   Future<List<FeedPost>> fetchFeedPosts()
//   Future<void> createFeedPost(FeedPost post)
//   Future<void> reactToPost(String postId, String emoji)
```

---

---

# CHECKLIST THEO WAVE

## Wave 1 — Local MVP (files cần XONG để app chạy)
- [ ] 01 · constants.dart
- [ ] 03 · local_storage_service.dart
- [ ] 04 · user_model.dart
- [ ] 05 · streak_model.dart (update)
- [ ] 07 · nut_button.dart
- [ ] 08 · pill_chip.dart
- [ ] 11 · badge_card.dart
- [ ] 12 · bottom_nav.dart
- [ ] 13 · router.dart
- [ ] 16 · splash_screen.dart
- [ ] 17 · onboarding_controller.dart
- [ ] 18 · onboarding_screen.dart (update)
- [ ] 21 · home_screen.dart (update)
- [ ] 22 · relapse_screen.dart (fix logic)
- [ ] 23 · streak_service.dart (update)
- [ ] 26 · feed_screen.dart (update)
- [ ] 27 · compose_screen.dart
- [ ] 28 · badge_model.dart (update)
- [ ] 29 · badges_screen.dart (update)
- [ ] 30 · profile_screen.dart (update)
- [ ] 31 · settings_screen.dart
- [ ] 32 · paywall_screen.dart (update)

## Wave 2 — Content & Polish
- [ ] 06 · journal_entry_model.dart
- [ ] 33 · journal_service.dart
- [ ] 34 · journal_screen.dart
- [ ] 35 · relapse_analytics_screen.dart

## Wave 3 — Backend
- [ ] 19 · login_screen.dart (thật)
- [ ] 20 · signup_screen.dart (thật)
- [ ] 36 · supabase_service.dart (thật)
- [ ] 14 · main.dart (thêm Supabase init)
- [ ] 15 · nut_app.dart (refactor sau khi có router)

---

## Ghi chú packages cần thêm vào pubspec.yaml

| Package | Dùng cho | Wave |
|---|---|---|
| `go_router` | Routing (router.dart) | 1 |
| `provider` | State management | 1 |
| `flutter_local_notifications` | Notification settings | 1 |
| `package_info_plus` | App version trong Profile/Settings | 1 |
| `url_launcher` | Privacy Policy, Terms links | 1 |
| `fl_chart` | Charts trong Analytics screen | 2 |
| `supabase_flutter` | Backend | 3 |
| `purchases_flutter` | RevenueCat — premium gating | 4 |

> `shared_preferences` đã có trong pubspec.yaml rồi — đừng thêm lại.
