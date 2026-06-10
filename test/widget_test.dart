import 'package:flutter_test/flutter_test.dart';
import 'package:nut_mvp/app/nut_app.dart';
import 'package:nut_mvp/features/feed/feed_service.dart';
import 'package:nut_mvp/features/streak/streak_model.dart';
import 'package:nut_mvp/features/streak/streak_service.dart';

void main() {
  testWidgets('NUT shell renders the main tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      NutApp(
        streakService: StreakService(),
        feedService: FeedService(),
        initialStreak: const StreakModel(
          startDate: null,
          lifetimeCleanDays: 0,
        ),
      ),
    );

    expect(find.text('NUT'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Badges'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
