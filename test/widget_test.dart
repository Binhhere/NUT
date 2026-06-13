import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nut_mvp/app/nut_app.dart';
import 'package:nut_mvp/features/feed/feed_service.dart';
import 'package:nut_mvp/features/onboarding/onboarding_model.dart';
import 'package:nut_mvp/features/onboarding/onboarding_service.dart';
import 'package:nut_mvp/features/streak/streak_model.dart';
import 'package:nut_mvp/features/streak/streak_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  test('onboarding profile is saved locally', () async {
    SharedPreferences.setMockInitialValues({});
    final service = OnboardingService();

    await service.saveProfile(
      const OnboardingProfile(
        hasSeenOnboarding: true,
        username: 'Binh',
        reason: 'Focus',
      ),
    );

    final profile = await service.loadProfile();

    expect(profile.hasSeenOnboarding, isTrue);
    expect(profile.username, 'Binh');
    expect(profile.reason, 'Focus');
  });

  testWidgets('NUT shell renders the main tabs after onboarding',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      NutApp(
        streakService: StreakService(),
        onboardingService: OnboardingService(),
        feedService: FeedService(),
        initialStreak: const StreakModel(
          startDate: null,
          lifetimeCleanDays: 0,
        ),
        initialOnboarding: const OnboardingProfile(
          hasSeenOnboarding: true,
        ),
      ),
    );

    expect(find.text(l10n.appTitle), findsOneWidget);
    expect(find.text(l10n.navHome), findsOneWidget);
    expect(find.text(l10n.navFeed), findsOneWidget);
    expect(find.text(l10n.navBadges), findsOneWidget);
    expect(find.text(l10n.navProfile), findsOneWidget);
  });

  testWidgets('first launch onboarding can be skipped',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      NutApp(
        streakService: StreakService(),
        onboardingService: OnboardingService(),
        feedService: FeedService(),
        initialStreak: const StreakModel(
          startDate: null,
          lifetimeCleanDays: 0,
        ),
        initialOnboarding: const OnboardingProfile(
          hasSeenOnboarding: false,
        ),
      ),
    );

    expect(find.text(l10n.onboardingHeadline), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text(l10n.onboardingSkip),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(l10n.onboardingSkip));
    await tester.pumpAndSettle();

    expect(find.text(l10n.appTitle), findsOneWidget);
    expect(find.text(l10n.navHome), findsOneWidget);
  });
}
