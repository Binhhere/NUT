import 'package:flutter/material.dart';

import 'app/nut_app.dart';
import 'features/feed/feed_service.dart';
import 'features/onboarding/onboarding_service.dart';
import 'features/streak/streak_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Add Firebase only when login, notifications, or analytics are needed.
  final streakService = StreakService();
  final onboardingService = OnboardingService();
  final initialStreak = await streakService.loadStreak();
  final initialOnboarding = await onboardingService.loadProfile();

  runApp(
    NutApp(
      streakService: streakService,
      onboardingService: onboardingService,
      feedService: FeedService(),
      initialStreak: initialStreak,
      initialOnboarding: initialOnboarding,
    ),
  );
}
