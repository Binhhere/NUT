import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_model.dart';

class OnboardingService {
  static const _hasSeenKey = 'onboarding_has_seen';
  static const _usernameKey = 'onboarding_username';
  static const _reasonKey = 'onboarding_reason';

  Future<OnboardingProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    return OnboardingProfile(
      hasSeenOnboarding: prefs.getBool(_hasSeenKey) ?? false,
      username: _readOptionalString(prefs, _usernameKey),
      reason: _readOptionalString(prefs, _reasonKey),
    );
  }

  Future<OnboardingProfile> saveProfile(OnboardingProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final username = profile.username?.trim();
    final reason = profile.reason?.trim();

    await prefs.setBool(_hasSeenKey, true);

    if (username == null || username.isEmpty) {
      await prefs.remove(_usernameKey);
    } else {
      await prefs.setString(_usernameKey, username);
    }

    if (reason == null || reason.isEmpty) {
      await prefs.remove(_reasonKey);
    } else {
      await prefs.setString(_reasonKey, reason);
    }

    return OnboardingProfile(
      hasSeenOnboarding: true,
      username: username == null || username.isEmpty ? null : username,
      reason: reason == null || reason.isEmpty ? null : reason,
    );
  }

  static String? _readOptionalString(SharedPreferences prefs, String key) {
    final value = prefs.getString(key)?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }
}
