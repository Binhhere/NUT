import 'package:flutter/material.dart';

import 'app/nut_app.dart';
import 'features/feed/feed_service.dart';
import 'features/onboarding/onboarding_service.dart';
import 'features/streak/streak_service.dart';
import 'shared/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().init();

  final streakService = StreakService();
  final onboardingService = OnboardingService();

  final results = await Future.wait([
    streakService.loadStreak(),
    onboardingService.loadProfile(),
    AppTheme.load(), // load persisted theme — defaults to dark
  ]);

  runApp(
    NutApp(
      streakService: streakService,
      onboardingService: onboardingService,
      feedService: FeedService(),
      initialStreak: results[0] as dynamic,
      initialOnboarding: results[1] as dynamic,
      initialTheme: results[2] as AppTheme,
    ),
  );
}
