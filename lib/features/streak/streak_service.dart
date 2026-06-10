import 'package:shared_preferences/shared_preferences.dart';

import 'streak_model.dart';

class StreakService {
  static const _startDateKey = 'streak_start_date';
  static const _lifetimeCleanDaysKey = 'lifetime_clean_days';

  Future<StreakModel> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final startDateValue = prefs.getString(_startDateKey);

    return StreakModel(
      startDate:
          startDateValue == null ? null : DateTime.tryParse(startDateValue),
      lifetimeCleanDays: prefs.getInt(_lifetimeCleanDaysKey) ?? 0,
    );
  }

  Future<StreakModel> startStreak() async {
    final streak = StreakModel(
      startDate: DateTime.now(),
      lifetimeCleanDays: (await loadStreak()).lifetimeCleanDays,
    );

    await _save(streak);
    return streak;
  }

  Future<StreakModel> resetStreak(StreakModel current) async {
    final completedDays = current.currentStreakDays();
    final streak = StreakModel(
      startDate: DateTime.now(),
      lifetimeCleanDays: current.lifetimeCleanDays + completedDays,
    );

    await _save(streak);
    return streak;
  }

  Future<void> _save(StreakModel streak) async {
    final prefs = await SharedPreferences.getInstance();

    if (streak.startDate == null) {
      await prefs.remove(_startDateKey);
    } else {
      await prefs.setString(_startDateKey, streak.startDate!.toIso8601String());
    }

    await prefs.setInt(_lifetimeCleanDaysKey, streak.lifetimeCleanDays);
  }
}
