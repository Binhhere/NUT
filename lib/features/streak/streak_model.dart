class StreakModel {
  const StreakModel({
    required this.startDate,
    required this.lifetimeCleanDays,
  });

  final DateTime? startDate;
  final int lifetimeCleanDays;

  bool get hasStarted => startDate != null;

  Duration currentDuration([DateTime? now]) {
    if (startDate == null) return Duration.zero;

    final currentTime = now ?? DateTime.now();
    if (currentTime.isBefore(startDate!)) return Duration.zero;

    return currentTime.difference(startDate!);
  }

  int currentStreakDays([DateTime? now]) => currentDuration(now).inDays;

  StreakModel copyWith({
    DateTime? startDate,
    bool clearStartDate = false,
    int? lifetimeCleanDays,
  }) {
    return StreakModel(
      startDate: clearStartDate ? null : startDate ?? this.startDate,
      lifetimeCleanDays: lifetimeCleanDays ?? this.lifetimeCleanDays,
    );
  }
}
