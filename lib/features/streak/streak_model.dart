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

  int currentStreakDays([DateTime? now]) => currentDuration(now).inDays;

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
    if (milestone == 0) return 1;
    return (currentStreakDays() / milestone).clamp(0, 1).toDouble();
  }

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
