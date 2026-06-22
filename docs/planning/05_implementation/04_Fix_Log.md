# NUT MVP — Fix Log
> Ghi lại toàn bộ thay đổi từ audit session. 5 fix chính + các thay đổi kéo theo.

---

## FIX 1 · `android/app/build.gradle` — Java compatibility
**Vấn đề:** `VERSION_1_8` deprecated với Gradle 8.7 + Java 21. Build sẽ warn hoặc fail trên CI/CD mới.

**File thay đổi:** `android/app/build.gradle`

| Trước | Sau |
|---|---|
| `sourceCompatibility = JavaVersion.VERSION_1_8` | `sourceCompatibility = JavaVersion.VERSION_17` |
| `targetCompatibility = JavaVersion.VERSION_1_8` | `targetCompatibility = JavaVersion.VERSION_17` |
| `jvmTarget = JavaVersion.VERSION_1_8` | `jvmTarget = "17"` |

**Lý do dùng String `"17"` cho Kotlin:** `kotlinOptions.jvmTarget` nhận String, không nhận enum `JavaVersion`. Dùng enum ở đây sẽ compile thành `"VERSION_17"` thay vì `"17"` — sai format.

---

## FIX 2 · `lib/shared/widgets/section_header.dart` — Tách 2 widget
**Vấn đề:** Một widget `SectionHeader` (24sp) đang được dùng cho cả 2 mục đích:
- Screen-level title (đúng — "Protect today.")
- In-screen section labels (sai — "Your progress", "This week" → bị quá to)

**File thay đổi:** `lib/shared/widgets/section_header.dart`

**Giữ nguyên:** `SectionHeader` — 24sp, w600, dùng ở đầu screen.

**Thêm mới:** `SmallSectionLabel`
- Font: 10sp, w500, uppercase, letter-spacing 0.13em
- Match HTML class `.sh { font-size:10px; font-weight:500; color:var(--txtm); letter-spacing:.13em; text-transform:uppercase }`
- Có optional `trailing` widget (ví dụ: "See all" button bên phải)
- Màu: `palette.textSecondary` (muted, không phải textPrimary)

---

## FIX 3 · `lib/app/theme.dart` — Sync color tokens với HTML
**Vấn đề:** 4 dark mode tokens sáng hơn HTML ~10–15%, gây khác biệt visual khi so sánh với thiết kế.

**File thay đổi:** `lib/app/theme.dart` — chỉ class `NutColors`, không đụng vào `NutPalette.light`

| Token | Trước | Sau | HTML var |
|---|---|---|---|
| `background` | `#0D0D0D` | `#060606` | `--bg` |
| `surface` | `#161616` | `#111111` | `--surface` |
| `card` | `#1E1E1E` | `#1A1A1A` | `--card` |
| `accentBg` | `#2A1F0A` | `#1E1609` | `--gold-bg` |

**Không đổi:** light palette, tất cả các token khác, toàn bộ `NutTheme._build()`.

**Không cần sửa screen nào khác** vì toàn bộ app dùng `palette.*` — không có hex hardcode rải rác.

---

## FIX 4 · `lib/shared/widgets/stat_card.dart` — Đổi layout ngang → dọc
**Vấn đề:** Widget dùng layout ngang (icon circle + value/label). HTML dùng layout dọc (label → số lớn → sublabel).

**File thay đổi:** `lib/shared/widgets/stat_card.dart`

**Params cũ bị xóa:**
- `icon` (IconData?) — icon circle không có trong HTML
- `accentColor` (Color?) — đổi tên

**Params mới:**
- `sublabel` (String?) — dòng muted nhỏ dưới số (ví dụ: "days clean", "days")
- `valueColor` (Color?) — màu cho số, default `accentGold`
- `onTap` (VoidCallback?) — để tap navigate (ví dụ: stat card → streak history)

**Layout mới (match HTML home screen):**
```
LABEL          ← 10sp, uppercase, muted, letterSpacing 0.06em
184            ← 26sp, JetBrains Mono w500, valueColor
days clean     ← 11sp, muted (nếu có sublabel)
```

---

## FIX 5 · `lib/shared/widgets/nut_pill.dart` — Thêm border
**Vấn đề:** `NutPill` không có border, trông flat hơn HTML. HTML `.pg` có `border: 0.5px solid rgba(245,166,35,0.25)`.

**File thay đổi:** `lib/shared/widgets/nut_pill.dart`

**Thay đổi:**
- Thêm `border: Border.all(color: fg.withOpacity(0.25), width: 0.5)` — tự động tính từ foregroundColor
- Thêm param `borderColor` (Color?) để override nếu cần
- Đồng bộ padding: `symmetric(horizontal: 10, vertical: 4)` (trước là `12/7`)
- Font: 11sp, w500, letterSpacing 0.02em (match HTML `.pill`)
- Icon size: 13px (trước là 14px)

---

## CÁC SỬA THÊM TRONG `home_screen.dart`

### A. Fix compile error từ StatCard params cũ
`home_screen.dart` gọi `StatCard(icon: ..., accentColor: ...)` — đây là params đã bị xóa ở Fix 4.

**Đã sửa:**
```dart
// Trước
StatCard(
  label: l10n.lifetimeCleanDays,
  value: widget.streak.lifetimeCleanDays.toString(),
  icon: Icons.favorite_outline,       // ← xóa
  accentColor: palette.success,       // ← đổi tên
),

// Sau
StatCard(
  label: l10n.lifetimeCleanDays,
  value: widget.streak.lifetimeCleanDays.toString(),
  sublabel: 'days clean',             // ← thêm
  valueColor: palette.success,        // ← đổi tên
),
```

```dart
// Trước
StatCard(
  label: l10n.homeBestStreak,
  value: widget.streak.effectiveBestStreak.toString(),
  icon: Icons.emoji_events_outlined,  // ← xóa
),

// Sau
StatCard(
  label: l10n.homeBestStreak,
  value: widget.streak.effectiveBestStreak.toString(),
  sublabel: 'days',                   // ← thêm
),
```

### B. Đổi SectionHeader → SmallSectionLabel cho section labels nhỏ
Từ Fix 2: các section labels trong screen phải dùng `SmallSectionLabel`, không phải `SectionHeader`.

**Đã đổi 4 chỗ:**
```dart
// Trước
SectionHeader(title: l10n.homeProgressTitle)
SectionHeader(title: l10n.homeThisWeekTitle)   // trong _WeekCard
SectionHeader(title: l10n.homeNextMilestone)   // trong _MilestoneCard
SectionHeader(title: l10n.homeQuoteTitle)      // trong _QuoteCard

// Sau
SmallSectionLabel(title: l10n.homeProgressTitle)
SmallSectionLabel(title: l10n.homeThisWeekTitle)
SmallSectionLabel(title: l10n.homeNextMilestone)
SmallSectionLabel(title: l10n.homeQuoteTitle)
```

**Giữ nguyên:** `SectionHeader(title: l10n.homeTitle, subtitle: ...)` ở đầu screen — đây là screen-level title, đúng dùng SectionHeader.

### C. _WeekCard — bỏ Column wrapper thừa
Trước: `Column → [Text title, SizedBox, Row days]`. Sau khi title được move ra ngoài thành `SmallSectionLabel`, `_WeekCard` chỉ cần chứa `Row` ngày trong `NutCard`, bỏ `Column` và `Text` title bên trong.

### D. _QuoteCard — bỏ NutPill title thừa
`_QuoteCard` trước render `NutPill(label: homeQuoteTitle)` rồi mới đến quote text. Title đã được move ra ngoài thành `SmallSectionLabel` — bỏ `NutPill` bên trong, chỉ giữ quote text với `fontStyle: italic`.

### E. _RyanTeaserCard — đổi Column → Row layout
Trước dùng `Column` với `NutPill` và `Text` xếp dọc. HTML layout là ngang: [moon emoji | title + subtitle | V2 pill]. Đã đổi thành `Row` với emoji trong `Container` 38px circle, `Expanded` column chứa title/body, `NutPill("V2")` bên phải.

---

## TÓM TẮT FILE ĐÃ THAY ĐỔI

| File | Loại thay đổi |
|---|---|
| `android/app/build.gradle` | Fix 1 — Java 17 |
| `lib/shared/widgets/section_header.dart` | Fix 2 — thêm SmallSectionLabel |
| `lib/app/theme.dart` | Fix 3 — 4 color tokens |
| `lib/shared/widgets/stat_card.dart` | Fix 4 — layout dọc, params mới |
| `lib/shared/widgets/nut_pill.dart` | Fix 5 — border + spacing |
| `lib/features/streak/home_screen.dart` | Sửa kèm — A B C D E |

**Tổng:** 6 file, không có file nào mới được tạo.

---

## KHÔNG THAY ĐỔI

- `NutPalette.light` — light theme không có trong audit, giữ nguyên
- `NutTheme._build()` — không đụng vào
- Tất cả screens khác ngoài `home_screen.dart`
- Tất cả test files
- `pubspec.yaml`, `pubspec.lock`
- Tất cả i18n files (`en.arb`, `pt.arb`, `ja.arb`)
