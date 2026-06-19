enum RipplePhase {
  /// Day 0: no active streak yet.
  seed,

  /// Day 1-6: early growth, one ripple arc per day.
  growing,

  /// Day 7: first breakthrough moment.
  breakthrough,

  /// Day 8-29: post-breakthrough climb.
  ascending,

  /// Day 30-89: stronger long-streak state.
  rising,

  /// Day 90+: stable orbit state.
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

  /// Counts streak days by calendar day, not elapsed 24-hour periods.
  ///
  /// - Same calendar day as [startDate] is Day 1.
  /// - The next calendar day is Day 2.
  /// - Six calendar days after [startDate] is Day 7.
  int currentStreakDays([DateTime? now]) {
    if (startDate == null) return 0;

    final currentDate = _dateOnly(now ?? DateTime.now());
    final start = _dateOnly(startDate!);
    final elapsedCalendarDays = currentDate.difference(start).inDays;

    if (elapsedCalendarDays < 0) return 0;
    return elapsedCalendarDays + 1;
  }

  bool get isCheckedInToday {
    if (lastCheckinDate == null) return false;

    final today = _dateOnly(DateTime.now());
    final lastCheckin = _dateOnly(lastCheckinDate!);
    return today == lastCheckin;
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

  RipplePhase ripplePhaseAt([DateTime? now]) {
    if (startDate == null) return RipplePhase.seed;

    final days = currentStreakDays(now);
    if (days < 7) return RipplePhase.growing;
    if (days == 7) return RipplePhase.breakthrough;
    if (days < 30) return RipplePhase.ascending;
    if (days < 90) return RipplePhase.rising;
    return RipplePhase.orbit;
  }

  RipplePhase get ripplePhase => ripplePhaseAt();

  int rippleCountAt([DateTime? now]) {
    final days = currentStreakDays(now);
    return days.clamp(0, 6);
  }

  int get rippleCount => rippleCountAt();

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

  static DateTime _dateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static const empty = StreakModel(
    startDate: null,
    lifetimeCleanDays: 0,
  );
}
