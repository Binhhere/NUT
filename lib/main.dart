import 'package:flutter/material.dart';

import 'app/nut_app.dart';
import 'features/feed/feed_service.dart';
import 'features/onboarding/onboarding_model.dart';
import 'features/onboarding/onboarding_service.dart';
import 'features/streak/streak_model.dart';
import 'features/streak/streak_service.dart';
import 'shared/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await NotificationService().init();

    final streakService = StreakService();
    final onboardingService = OnboardingService();

    final results = await Future.wait([
      streakService.loadStreak(),
      onboardingService.loadProfile(),
      AppTheme.load(), // load persisted theme — defaults to dark
    ]).timeout(const Duration(seconds: 5));

    runApp(
      NutApp(
        streakService: streakService,
        onboardingService: onboardingService,
        feedService: FeedService(),
        initialStreak: results[0] as StreakModel,
        initialOnboarding: results[1] as OnboardingProfile,
        initialTheme: results[2] as AppTheme,
      ),
    );
  } catch (e) {
    debugPrint('Startup initialization failed: $e');

    // Minimal fallback app to avoid being stuck on the native splash
    runApp(
      NutApp(
        streakService: StreakService(),
        onboardingService: OnboardingService(),
        feedService: FeedService(),
        initialStreak: StreakModel.empty,
        initialOnboarding: const OnboardingProfile(hasSeenOnboarding: false),
        initialTheme: AppTheme.dark,
      ),
    );
  }
}
