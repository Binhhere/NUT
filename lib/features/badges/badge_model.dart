// lib/features/badges/badge_model.dart
//
// BadgeModel — định nghĩa 1 badge milestone.
// emoji    : visual chính, match HTML v5 (🌱🔥⚡🏆)
// unlockDate: null = locked, non-null = ngày unlock (lưu khi streak đạt mốc)
//
// Wave 2: persist unlockDate vào SharedPreferences để hiện "Unlocked Jun 10".

class BadgeModel {
  const BadgeModel({
    required this.id,
    required this.emoji,
    required this.title,
    required this.requiredDays,
    required this.description,
    this.unlockDate,
  });

  final String id;
  final String emoji;
  final String title;
  final int requiredDays;
  final String description;

  /// Ngày badge được unlock. null = chưa unlock.
  /// Wave 2: đọc/ghi từ SharedPreferences key 'badge_unlock_$id'.
  final DateTime? unlockDate;

  bool isUnlocked(int currentDays) => currentDays >= requiredDays;

  BadgeModel copyWith({DateTime? unlockDate}) {
    return BadgeModel(
      id: id,
      emoji: emoji,
      title: title,
      requiredDays: requiredDays,
      description: description,
      unlockDate: unlockDate ?? this.unlockDate,
    );
  }
}
