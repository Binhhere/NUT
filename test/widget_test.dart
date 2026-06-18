import 'package:flutter/material.dart';
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

  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher
        .clearLocaleTestValue();
  });

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

  test('streak reset stores lifetime days, best streak, and reset count',
      () async {
    final startDate = DateTime.now().subtract(const Duration(days: 10));
    SharedPreferences.setMockInitialValues({
      'streak_start_date': startDate.toIso8601String(),
      'lifetime_clean_days': 4,
      'best_streak': 7,
      'relapse_count': 2,
    });
    final service = StreakService();
    final loaded = await service.loadStreak();

    final reset = await service.resetStreak(loaded);

    expect(reset.lifetimeCleanDays, greaterThanOrEqualTo(14));
    expect(reset.bestStreak, greaterThanOrEqualTo(10));
    expect(reset.relapseCount, 3);
    expect(reset.hasStarted, isTrue);
  });

  test('check-in starts a local streak when none exists', () async {
    SharedPreferences.setMockInitialValues({});
    final service = StreakService();
    final loaded = await service.loadStreak();

    final checkedIn = await service.checkIn(loaded);

    expect(checkedIn.hasStarted, isTrue);
    expect(checkedIn.isCheckedInToday, isTrue);
    expect(checkedIn.currentStreakDays(),
        0); // 0 because start date is today, difference is 0 days
    expect(checkedIn.lifetimeCleanDays, 0);
  });

  test('newly started streak shows day one immediately', () {
    final now = DateTime(2026, 6, 14, 10);
    final streak = StreakModel(startDate: now, lifetimeCleanDays: 0);

    expect(streak.currentStreakDays(now), 0);
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
        showSplash: false,
      ),
    );

    expect(find.text(l10n.homeTitle), findsOneWidget);
    expect(find.text(l10n.navHome), findsOneWidget);
    expect(find.text(l10n.navFeed), findsOneWidget);
    expect(find.text(l10n.navBadges), findsOneWidget);
    expect(find.text(l10n.navProfile), findsOneWidget);
  });

  testWidgets('first launch onboarding can be finished',
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
        showSplash: false,
      ),
    );

    // Step 1: Name
    expect(find.text('What should\nwe call you?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Binh');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 2: Reason
    expect(find.text('Why are\nyou here?'), findsOneWidget);
    await tester.tap(find.text(l10n.onboardingReasonFocus));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 3: Ready
    expect(find.text("You're ready."), findsOneWidget);
    await tester.tap(find.text('Start my streak'));
    await tester.pumpAndSettle();

    // Shell
    expect(find.text(l10n.homeTitle), findsOneWidget);
    expect(find.text(l10n.navHome), findsOneWidget);
  });

  testWidgets('Portuguese locale renders localized navigation',
      (WidgetTester tester) async {
    final pt = lookupAppLocalizations(const Locale('pt'));

    await tester.pumpWidget(_testApp(locale: const Locale('pt')));

    expect(find.text(pt.navHome), findsOneWidget);
    expect(find.text(pt.navFeed), findsOneWidget);
    expect(find.text(pt.navBadges), findsOneWidget);
    expect(find.text(pt.navProfile), findsOneWidget);
  });

  testWidgets('Japanese locale renders localized navigation',
      (WidgetTester tester) async {
    final ja = lookupAppLocalizations(const Locale('ja'));

    await tester.pumpWidget(_testApp(locale: const Locale('ja')));

    expect(find.text(ja.navHome), findsOneWidget);
    expect(find.text(ja.navFeed), findsOneWidget);
    expect(find.text(ja.navBadges), findsOneWidget);
    expect(find.text(ja.navProfile), findsOneWidget);
  });

  testWidgets('feed plus opens compose before creating a progress post',
      (WidgetTester tester) async {
    await tester.pumpWidget(_testApp());

    await tester.tap(find.text(l10n.navFeed));
    await tester.pumpAndSettle();

    final generatedContent = l10n.feedProgressContent(0);
    expect(find.text(generatedContent), findsNothing);

    await tester.tap(find.byTooltip(l10n.feedPostProgress));
    await tester.pumpAndSettle();

    expect(find.text(l10n.feedComposeTitle), findsOneWidget);
    expect(find.text(generatedContent), findsNothing);

    await tester.enterText(find.byType(TextField).last, 'Small win today');
    await tester.pump();
    await tester.tap(find.text(l10n.feedComposeSubmit));
    await tester.pumpAndSettle();

    expect(find.text('Small win today'), findsOneWidget);
  });
}

Widget _testApp({Locale? locale}) {
  return NutApp(
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
    locale: locale,
    showSplash: false,
  );
}
