// lib/shared/services/local_storage_service.dart
// Wrapper duy nhất cho shared_preferences.
// Mọi read/write đều đi qua đây — không file nào khác gọi thẳng SharedPreferences.
// Source: DB Architecture → "Local persistence"

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService._();

  static LocalStorageService? _instance;

  /// Singleton — khởi tạo 1 lần trong main.dart
  static LocalStorageService get instance {
    _instance ??= LocalStorageService._();
    return _instance!;
  }

  // ─────────────────────────────────────────────
  // KEYS
  // ─────────────────────────────────────────────

  static const kOnboardingDone = 'onboarding_complete'; // bool
  static const kUsername = 'username'; // String
  static const kReason = 'reason'; // String
  static const kStreakStart = 'streak_start_date'; // String ISO8601
  static const kLastRelapse = 'last_relapse_date'; // String ISO8601
  static const kLifetimeDays = 'lifetime_clean_days'; // int
  static const kRelapseCount = 'relapse_count'; // int
  static const kRelapseTriggers = 'relapse_triggers'; // String (JSON list)
  static const kRelapseTriggersHistory =
      'relapse_triggers_history'; // List<String>, mỗi entry là JSON {date, triggers}
  static const kNotifEnabled = 'notif_enabled'; // bool
  static const kLastCheckin = 'streak_last_checkin'; // String ISO8601
  static const kBestStreak = 'best_streak_days'; // int

  // Wave 3 — thêm kUserId, kAuthToken, v.v.

  // ─────────────────────────────────────────────
  // BOOL
  // ─────────────────────────────────────────────

  Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  // ─────────────────────────────────────────────
  // STRING
  // ─────────────────────────────────────────────

  Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // ─────────────────────────────────────────────
  // STRING LIST
  // ─────────────────────────────────────────────

  Future<void> setStringList(String key, List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, value);
  }

  Future<List<String>> getStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? const [];
  }

  // ─────────────────────────────────────────────
  // INT
  // ─────────────────────────────────────────────

  Future<void> setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  // ─────────────────────────────────────────────
  // REMOVE / CLEAR
  // ─────────────────────────────────────────────

  /// Xoá 1 key cụ thể
  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// Xoá toàn bộ — dùng khi sign out (Wave 3)
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ─────────────────────────────────────────────
  // CONVENIENCE HELPERS
  // Wrapper typed cho các key hay dùng — tránh string magic ở caller
  // ─────────────────────────────────────────────

  Future<bool> isOnboardingDone() async =>
      (await getBool(kOnboardingDone)) ?? false;

  Future<void> setOnboardingDone(bool value) => setBool(kOnboardingDone, value);

  Future<String?> getUsername() => getString(kUsername);

  Future<void> setUsername(String value) => setString(kUsername, value);

  Future<String?> getReason() => getString(kReason);

  Future<void> setReason(String value) => setString(kReason, value);

  Future<DateTime?> getStreakStart() async {
    final s = await getString(kStreakStart);
    return s != null ? DateTime.tryParse(s) : null;
  }

  Future<void> setStreakStart(DateTime dt) =>
      setString(kStreakStart, dt.toIso8601String());

  Future<DateTime?> getLastRelapse() async {
    final s = await getString(kLastRelapse);
    return s != null ? DateTime.tryParse(s) : null;
  }

  Future<void> setLastRelapse(DateTime dt) =>
      setString(kLastRelapse, dt.toIso8601String());

  Future<int> getLifetimeDays() async => (await getInt(kLifetimeDays)) ?? 0;

  Future<void> setLifetimeDays(int value) => setInt(kLifetimeDays, value);

  Future<int> getRelapseCount() async => (await getInt(kRelapseCount)) ?? 0;

  Future<void> setRelapseCount(int value) => setInt(kRelapseCount, value);

  Future<int> getBestStreak() async => (await getInt(kBestStreak)) ?? 0;

  Future<void> setBestStreak(int value) => setInt(kBestStreak, value);

  Future<String?> getRelapseTriggers() => getString(kRelapseTriggers);

  Future<void> setRelapseTriggers(String jsonList) =>
      setString(kRelapseTriggers, jsonList);

  Future<bool> isNotifEnabled() async =>
      (await getBool(kNotifEnabled)) ?? false;

  Future<void> setNotifEnabled(bool value) => setBool(kNotifEnabled, value);

  Future<DateTime?> getLastCheckin() async {
    final s = await getString(kLastCheckin);
    return s != null ? DateTime.tryParse(s) : null;
  }

  Future<void> setLastCheckin(DateTime dt) =>
      setString(kLastCheckin, dt.toIso8601String());

  /// Lưu 1 lần reset kèm trigger đã chọn vào lịch sử (append-only).
  /// entry dạng JSON string: {"date": ISO8601, "triggers": ["Stress", ...]}
  Future<void> appendRelapseTriggerEntry(String jsonEntry) async {
    final existing = await getStringList(kRelapseTriggersHistory);
    await setStringList(kRelapseTriggersHistory, [...existing, jsonEntry]);
  }

  Future<List<String>> getRelapseTriggerHistory() =>
      getStringList(kRelapseTriggersHistory);
}
