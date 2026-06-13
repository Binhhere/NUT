// lib/app/constants.dart
// Tập trung toàn bộ string copy, milestone text, badge definitions, options.
// Không chứa màu sắc (→ theme.dart) hay spacing (→ NutSpacing).

class AppConstants {
  AppConstants._();

  // ─────────────────────────────────────────────
  // 1. STREAK MILESTONE MESSAGES
  // Source: Screen 05 · Home → "Supportive messages theo milestone range"
  // ─────────────────────────────────────────────

  static String streakMessage(int days) {
    if (days >= 365) return 'One year. This is who you are now.';
    if (days >= 90) return 'This is rare. Most people never get here.';
    if (days >= 30) {
      return 'A month of clarity. You\'re building something real.';
    }
    if (days >= 7) return 'One week down. Keep the momentum.';
    return 'Every day counts. Starting is the hardest part.';
  }

  // ─────────────────────────────────────────────
  // 2. RELAPSE TRIGGER OPTIONS
  // Source: Screen 06 · Relapse → "multi-select pills"
  // ─────────────────────────────────────────────

  static const List<String> relapseTriggers = [
    'Stress',
    'Boredom',
    'Late night',
    'Loneliness',
    'Triggered by content',
    'Other',
  ];

  // ─────────────────────────────────────────────
  // 3. ONBOARDING REASON OPTIONS
  // Source: Screen 02 · Onboarding → Bước 2
  // ─────────────────────────────────────────────

  static const List<String> onboardingReasons = [
    'Better focus',
    'More energy',
    'Build discipline',
    'Improve relationships',
    'Just trying it',
    'Prefer not to say',
  ];

  // ─────────────────────────────────────────────
  // 4. RELAPSE COPY RULES
  // Source: Screen 06 · Relapse + Design System → "Relapse screen"
  //
  // APPROVED words/phrases:
  //   "reset", "start again", "new chapter", "what you learned"
  //
  // FORBIDDEN — never use in any relapse-related copy:
  //   "failed", "lost", "weak", "start from zero", "back to day 0"
  // ─────────────────────────────────────────────

  // ─────────────────────────────────────────────
  // 5. PAYWALL COPY
  // Source: Screen 10 · Paywall
  // ─────────────────────────────────────────────

  static const String paywallTitle = 'NUT Premium';
  static const String paywallSubtext =
      'Tools for the long game. No ads. No noise.';
  static const String paywallTrialText = '7-day free trial · cancel anytime';
  static const String paywallAnnualPrice = '\$29.99/year';
  static const String paywallMonthlyPrice = '\$4.99/month';
  static const String paywallPerMonthEquiv = '\$2.50/month';
  static const String paywallSaveLabel = 'Save 50%';

  /// 5 tính năng premium — hiển thị dạng feature list trong Paywall screen
  static const List<String> paywallFeatures = [
    'Unlimited journal entries',
    'Relapse pattern analytics',
    'Custom reminder time',
    'Priority support',
    'Early access to new features',
  ];

  // ─────────────────────────────────────────────
  // 6. BADGE DEFINITIONS
  // Source: Screen 08 · Badges
  // Được dùng bởi BadgeModel.all — định nghĩa authoritative ở badge_model.dart,
  // constants này chỉ giữ copy/text để tránh trùng lặp.
  // ─────────────────────────────────────────────

  static const List<Map<String, dynamic>> badgeDefinitions = [
    {
      'id': 'first_week',
      'emoji': '🌱',
      'title': 'First Week',
      'requiredDays': 7,
      'description': 'Seven days of clarity. The hardest part is behind you.',
    },
    {
      'id': 'one_month',
      'emoji': '🔥',
      'title': 'One Month',
      'requiredDays': 30,
      'description': 'A full month. Your brain is already rewiring.',
    },
    {
      'id': 'ninety_days',
      'emoji': '⚡',
      'title': '90 Days',
      'requiredDays': 90,
      'description': 'This is rare. Most people never reach this.',
    },
    {
      'id': 'one_year',
      'emoji': '🏆',
      'title': 'One Year',
      'requiredDays': 365,
      'description': 'One year. This is who you are now.',
    },
  ];

  // ─────────────────────────────────────────────
  // 7. MISC COPY
  // ─────────────────────────────────────────────

  /// Placeholder daily quote — Wave 2 sẽ thay bằng 365 quotes
  static const String dailyQuotePlaceholder =
      '"The secret of getting ahead is getting started."';

  static const String dailyQuoteAuthorPlaceholder = '— Mark Twain';

  /// Ryan teaser — hiện khi showRyanTeaser = true, biến mất khi V2 launch
  static const String ryanTeaserText = 'Something\'s coming.';

  /// Feedback text hiện dưới streak counter ở Home
  static const String checkedInLabel = 'Checked in ✓';
  static const String checkInCta = 'Check in today';
}
