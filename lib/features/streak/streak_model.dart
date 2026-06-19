// lib/features/streak/streak_model.dart

enum RipplePhase {
  /// Ngày 0 — chưa bắt đầu. Chỉ có điểm sáng, không ripple.
  seed,

  /// Ngày 1–6 — mỗi ngày 1 ripple arc mới. Tăng dần.
  growing,

  /// Đúng ngày 7 — animation breakthrough: tâm vỡ, nghiêng 3D, bay lên.
  breakthrough,

  /// Ngày 8–29 — field nhìn từ góc xiên 3D, điểm sáng đang dâng.
  ascending,

  /// Ngày 30–89 — second breakthrough. Ripple nhỏ dần phía dưới.
  rising,

  /// Ngày 90+ — điểm sáng cao, ripple decay thành ánh sáng.
  orbit,
}

class StreakModel {
  const StreakModel({
    required this.startDate,
    required this.lifetimeCleanDays,
    this.relapseCount = 0,
    this.bestStreak = 0,
    this.lastCheckinDate,
  });

  final DateTime? startDate;
  final int lifetimeCleanDays;
  final int relapseCount;
  final int bestStreak;
  final DateTime? lastCheckinDate;

  bool get hasStarted => startDate != null;

  Duration currentDuration([DateTime? now]) {
    if (startDate == null) return Duration.zero;
    final current = now ?? DateTime.now();
    if (current.isBefore(startDate!)) return Duration.zero;
    return current.difference(startDate!);
  }

  // ─────────────────────────────────────────────
  // currentStreakDays — đếm số ngày calendar đã qua kể từ startDate.
  //
  // Timeline spec (Local-first V1):
  //   same calendar day as startDate => Day 1
  //   next calendar day              => Day 2
  //   after 6 calendar days          => Day 7
  // ─────────────────────────────────────────────
  int currentStreakDays([DateTime? now]) {
    if (!hasStarted) return 0;
    final today = _dateOnly(now ?? DateTime.now());
    final start = _dateOnly(startDate!);
    final diff = today.difference(start).inDays;
    return (diff < 0 ? 0 : diff) + 1;
  }

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  bool get isCheckedInToday {
    if (lastCheckinDate == null) return false;
    final now = DateTime.now();
    return lastCheckinDate!.year == now.year &&
        lastCheckinDate!.month == now.month &&
        lastCheckinDate!.day == now.day;
  }

  int get effectiveBestStreak {
    final current = currentStreakDays();
    return current > bestStreak ? current : bestStreak;
  }

  int get nextMilestone {
    final days = currentStreakDays();
    const milestones = [7, 30, 90, 365];
    for (final milestone in milestones) {
      if (days < milestone) return milestone;
    }
    return 365;
  }

  int get daysToNextMilestone {
    final remaining = nextMilestone - currentStreakDays();
    return remaining < 0 ? 0 : remaining;
  }

  double get nextMilestoneProgress {
    final milestone = nextMilestone;
    if (milestone == 0) return 1.0;
    return (currentStreakDays() / milestone).clamp(0.0, 1.0);
  }

  // ─────────────────────────────────────────────
  // RIPPLE PHASE
  // Nguồn sự thật cho RippleField và BreakthroughAnimation.
  // Session 2 sẽ dùng getter này để quyết định render path.
  // ─────────────────────────────────────────────

  RipplePhase ripplePhaseAt([DateTime? now]) {
    final days = currentStreakDays(now);
    if (!hasStarted) return RipplePhase.seed;
    if (days < 7) return RipplePhase.growing;
    if (days == 7) return RipplePhase.breakthrough;
    if (days < 30) return RipplePhase.ascending;
    if (days < 90) return RipplePhase.rising;
    return RipplePhase.orbit;
  }

  RipplePhase get ripplePhase => ripplePhaseAt();

  /// Số ripple arc cần vẽ trong phase growing (Day 1–6).
  /// Trong các phase khác, RippleField tự tính theo phase.
  int rippleCountAt([DateTime? now]) {
    final days = currentStreakDays(now);
    return days.clamp(0, 6);
  }

  int get rippleCount => rippleCountAt();

  /// Progress nội tại trong growing phase [0.0–1.0].
  /// Dùng để animate opacity của ripple mới nhất (chưa "settled").
  double growingPhaseProgressAt([DateTime? now]) {
    final days = currentStreakDays(now);
    if (days == 0) return 0.0;
    return (days / 7.0).clamp(0.0, 1.0);
  }

  double get growingPhaseProgress => growingPhaseProgressAt();

  StreakModel copyWith({
    DateTime? startDate,
    bool clearStartDate = false,
    int? lifetimeCleanDays,
    int? relapseCount,
    int? bestStreak,
    DateTime? lastCheckinDate,
    bool clearLastCheckin = false,
  }) {
    return StreakModel(
      startDate: clearStartDate ? null : startDate ?? this.startDate,
      lifetimeCleanDays: lifetimeCleanDays ?? this.lifetimeCleanDays,
      relapseCount: relapseCount ?? this.relapseCount,
      bestStreak: bestStreak ?? this.bestStreak,
      lastCheckinDate:
          clearLastCheckin ? null : lastCheckinDate ?? this.lastCheckinDate,
    );
  }

  static const empty = StreakModel(
    startDate: null,
    lifetimeCleanDays: 0,
  );
}
