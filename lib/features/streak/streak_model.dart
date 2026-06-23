/// Visual phase of the Home shrine system.
enum RipplePhase {
  /// Day 0: no active streak yet — just a dim seed.
  seed,

  /// Day 1-3: seed breathing, growing larger with each check-in.
  /// No rings yet.
  breathing,

  /// Day 4-20: seed is surrounded by 18 concentric rings and pierces
  /// one new ring per day in a zigzag path. Pierced rings decay
  /// (crumble) over time rather than vanishing instantly.
  piercing,

  /// Day 21, played once: the shell opens and the core emits a calm pulse.
  breakthrough,

  /// Day 22+: sprout phase.
  /// Kept as `pet` to avoid a risky enum rename cascade.
  pet,
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
    const milestones = [21, 100, 200, 365];

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

  /// Total ring layers surrounding the seed during the piercing phase.
  static const int totalRingLayers = 18;

  /// Day the piercing phase starts (rings appear, first ring pierced).
  static const int piercingStartDay = 4;

  /// Day the breakthrough happens (seed becomes the pet).
  static const int breakthroughDay = 21;

  RipplePhase ripplePhaseAt([DateTime? now]) {
    if (startDate == null) return RipplePhase.seed;

    final days = currentStreakDays(now);
    if (days < piercingStartDay) return RipplePhase.breathing;
    if (days < breakthroughDay) return RipplePhase.piercing;
    if (days == breakthroughDay) return RipplePhase.breakthrough;
    return RipplePhase.pet;
  }

  RipplePhase get ripplePhase => ripplePhaseAt();

  /// How many of the 18 rings have been pierced so far (0-18).
  /// Day 4 pierces ring #1, day 21 pierces ring #18.
  int piercedRingCountAt([DateTime? now]) {
    final days = currentStreakDays(now);
    if (days < piercingStartDay) return 0;
    final pierced = days - piercingStartDay + 1;
    return pierced.clamp(0, totalRingLayers);
  }

  int get piercedRingCount => piercedRingCountAt();

  /// Decay (crumble) amount applied uniformly to every pierced ring,
  /// based on days elapsed since the piercing phase began.
  /// 0% at day 4, ~20% at day 10, ~80% at day 20, 100% at day 21.
  double ringDecayProgressAt([DateTime? now]) {
    final days = currentStreakDays(now);
    if (days < piercingStartDay) return 0.0;

    // Piecewise-linear through the two anchor points the person
    // specified (day 10 -> 0.20, day 20 -> 0.80), clamped to [0, 1].
    const d1 = 10.0, p1 = 0.20;
    const d2 = 20.0, p2 = 0.80;
    final d = days.toDouble();

    double progress;
    if (d <= d1) {
      progress = (d - piercingStartDay) / (d1 - piercingStartDay) * p1;
    } else if (d <= d2) {
      progress = p1 + (d - d1) / (d2 - d1) * (p2 - p1);
    } else {
      progress = p2 + (d - d2) / (breakthroughDay - d2) * (1.0 - p2);
    }

    return progress.clamp(0.0, 1.0);
  }

  double get ringDecayProgress => ringDecayProgressAt();

  /// Breathing-phase growth, 0.0 (day 0) to 1.0 (day 3, about to pierce).
  double breathingProgressAt([DateTime? now]) {
    final days = currentStreakDays(now);
    if (days == 0) return 0.0;
    return (days / (piercingStartDay - 1)).clamp(0.0, 1.0);
  }

  double get breathingProgress => breathingProgressAt();

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
