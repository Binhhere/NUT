import 'package:flutter/material.dart';

import 'app/nut_app.dart';
import 'features/feed/feed_service.dart';
import 'features/streak/streak_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Add Firebase only when login, notifications, or analytics are needed.
  final streakService = StreakService();
  final initialStreak = await streakService.loadStreak();

  runApp(
    NutApp(
      streakService: streakService,
      feedService: FeedService(),
      initialStreak: initialStreak,
    ),
  );
}
