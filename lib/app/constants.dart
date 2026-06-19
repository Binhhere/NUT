// lib/app/constants.dart
//
// Chỉ chứa logic/data KHÔNG phải UI string:
//   - Streak milestone message logic (dynamic, không dịch được bằng ARB)
//   - Numeric constants
//   - Dev/debug flags
//
// KHÔNG còn:
//   - relapseTriggers   → dùng l10n.relapseTrigger* trong RelapseScreen
//   - onboardingReasons → dùng l10n.onboardingReason* trong OnboardingScreen
//   - paywallFeatures   → dùng l10n.paywallFeature* trong PaywallScreen
//   - badgeDefinitions  → define trực tiếp trong BadgesScreen với l10n titles
//
// Lý do: những list trên đã có bản dịch trong app_en.arb / app_pt.arb / app_ja.arb.
// Giữ chúng ở đây nghĩa là luôn hardcode tiếng Anh, bỏ qua localization.

class AppConstants {
  AppConstants._();

  // ─────────────────────────────────────────────
  // STREAK MILESTONE MESSAGES
  // Logic động theo số ngày — không thể express bằng ARB plural rules
  // vì có 5 ranges khác nhau. Wave 3: chuyển vào ARB nếu cần dịch.
  // Source: Screen 05 · Home
  // ─────────────────────────────────────────────

  static String streakMessage(int days) {
    if (days >= 365) return 'One year. This is who you are now.';
    if (days >= 90) return 'This is rare. Most people never get here.';
    if (days >= 30)
      return 'A month of clarity. You\'re building something real.';
    if (days >= 7) return 'One week down. Keep the momentum.';
    return 'Every day counts. Starting is the hardest part.';
  }

  // ─────────────────────────────────────────────
  // PAYWALL PRICING (numeric / non-translatable)
  // Giá tiền không qua ARB — thay đổi theo region ở Wave 3 (RevenueCat).
  // Source: Screen 10 · Paywall
  // ─────────────────────────────────────────────

  static const String paywallAnnualPrice = r'$29.99/year';
  static const String paywallMonthlyPrice = r'$4.99/month';
  static const String paywallPerMonthEquiv = r'$2.50/month';
  static const String paywallSaveLabel = 'Save 50%';
  static const String paywallTrialText = '7-day free trial · cancel anytime';

  // ─────────────────────────────────────────────
  // DAILY QUOTE PLACEHOLDER
  // Wave 2: thay bằng danh sách 365 quotes từ asset JSON.
  // ─────────────────────────────────────────────

  static const String dailyQuotePlaceholder =
      '"The secret of getting ahead is getting started."';
  static const String dailyQuoteAuthorPlaceholder = '— Mark Twain';

  // ─────────────────────────────────────────────
  // MISC
  // ─────────────────────────────────────────────

  /// Ryan teaser visible cho đến Wave 2 launch
  static const String ryanTeaserText = "Something's coming.";
}
