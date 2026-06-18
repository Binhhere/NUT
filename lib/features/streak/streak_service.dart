import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';

import 'streak_model.dart';

class StreakService {
  static const _startDateKey = 'streak_start_date';
  static const _lifetimeCleanDaysKey = 'lifetime_clean_days';
  static const _relapseCountKey = 'relapse_count';
  static const _bestStreakKey = 'best_streak';
  static const _lastCheckinKey = 'streak_last_checkin';

  Future<StreakModel> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final startDateValue = prefs.getString(_startDateKey);

    return StreakModel(
      startDate:
          startDateValue == null ? null : DateTime.tryParse(startDateValue),
      lifetimeCleanDays: prefs.getInt(_lifetimeCleanDaysKey) ?? 0,
      relapseCount: prefs.getInt(_relapseCountKey) ?? 0,
      bestStreak: prefs.getInt(_bestStreakKey) ?? 0,
      lastCheckinDate: _parseDate(prefs.getString(_lastCheckinKey)),
    );
  }

  Future<StreakModel> startStreak() async {
    final current = await loadStreak();
    final now = DateTime.now();
    final streak = current.copyWith(
      startDate: now,
      lastCheckinDate: now,
    );

    await _save(streak);
    return streak;
  }

  Future<StreakModel> checkIn(StreakModel current) async {
    final now = DateTime.now();
    final streak = current.copyWith(
      startDate: current.startDate ?? now,
      lastCheckinDate: now,
    );

    await _save(streak);
    return streak;
  }

  Future<StreakModel> resetStreak(StreakModel current) async {
    final completedDays = current.currentStreakDays();
    final bestStreak =
        completedDays > current.bestStreak ? completedDays : current.bestStreak;
    final streak = StreakModel(
      startDate: DateTime.now(),
      lifetimeCleanDays: current.lifetimeCleanDays + completedDays,
      relapseCount: current.relapseCount + 1,
      bestStreak: bestStreak,
      lastCheckinDate: DateTime.now(),
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
    await prefs.setInt(_relapseCountKey, streak.relapseCount);
    await prefs.setInt(_bestStreakKey, streak.effectiveBestStreak);

    if (streak.lastCheckinDate == null) {
      await prefs.remove(_lastCheckinKey);
    } else {
      await prefs.setString(
        _lastCheckinKey,
        streak.lastCheckinDate!.toIso8601String(),
      );
    }

    // Sync with Home Widget
    try {
      await HomeWidget.saveWidgetData<int>(
          'streak_count', streak.currentStreakDays());
      await HomeWidget.updateWidget(
        androidName: 'StreakWidgetProvider',
      );
    } catch (e) {
      // Ignore widget update errors
    }
  }

  DateTime? _parseDate(String? value) {
    if (value == null) return null;
    return DateTime.tryParse(value);
  }
}
