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
        1); // 1 because start date is today, Day 1 starts immediately
    expect(checkedIn.lifetimeCleanDays, 0);
  });

  test('newly started streak shows day one immediately', () {
    final now = DateTime(2026, 6, 14, 10);
    final streak = StreakModel(startDate: now, lifetimeCleanDays: 0);

    final days = streak.currentStreakDays(now);
    expect(days, 1,
        reason:
            'Current date $now, start date ${streak.startDate}, diff ${now.difference(streak.startDate!).inDays}');
    expect(streak.ripplePhaseAt(now), RipplePhase.breathing);
    expect(streak.breathingProgressAt(now), closeTo(1 / 3, 0.001));
  });

  test('after 3 calendar days streak starts piercing on day 4', () {
    final start = DateTime(2026, 6, 14, 10);
    final now = DateTime(2026, 6, 17, 15); // 3 days difference
    final streak = StreakModel(startDate: start, lifetimeCleanDays: 0);

    expect(streak.currentStreakDays(now), 4);
    expect(streak.ripplePhaseAt(now), RipplePhase.piercing);
    expect(streak.piercedRingCountAt(now), 1);
  });

  test('streak boundaries for breakthrough and sprout phase', () {
    final start = DateTime(2026, 6, 14, 10);

    final d20 = start.add(const Duration(days: 19));
    final s20 = StreakModel(startDate: start, lifetimeCleanDays: 0);
    expect(s20.currentStreakDays(d20), 20);
    expect(s20.ripplePhaseAt(d20), RipplePhase.piercing);
    expect(s20.piercedRingCountAt(d20), 17);

    final d21 = start.add(const Duration(days: 20));
    final s21 = StreakModel(startDate: start, lifetimeCleanDays: 0);
    expect(s21.currentStreakDays(d21), 21);
    expect(s21.ripplePhaseAt(d21), RipplePhase.breakthrough);

    final d22 = start.add(const Duration(days: 21));
    final s22 = StreakModel(startDate: start, lifetimeCleanDays: 0);
    expect(s22.currentStreakDays(d22), 22);
    expect(s22.ripplePhaseAt(d22), RipplePhase.pet);
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

    // Home shrine screen is identified by its key
    expect(find.byKey(const Key('homeShrineScreen')), findsOneWidget);
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
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // Step 2: Reason
    expect(find.text('Why are\nyou here?'), findsOneWidget);
    await tester.tap(find.text(l10n.onboardingReasonFocus));
    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // Step 3: Ready
    expect(find.text("You're ready."), findsOneWidget);
    expect(find.text(l10n.onboardingPrivacyConfirmTitle), findsOneWidget);
    await tester.tap(find.text('Start my streak'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(l10n.homeTitle), findsNothing);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.text('Start my streak'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // Shell — home shrine screen key
    expect(find.byKey(const Key('homeShrineScreen')), findsOneWidget);
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
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    final generatedContent = l10n.feedProgressContent(0);
    expect(find.text(generatedContent), findsNothing);

    await tester.tap(find.byTooltip(l10n.feedPostProgress));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(l10n.feedComposeTitle), findsOneWidget);
    expect(find.text(generatedContent), findsNothing);

    await tester.enterText(find.byType(TextField).last, 'Small win today');
    await tester.pump();
    await tester.tap(find.text(l10n.feedComposeSubmit));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Small win today'), findsOneWidget);
  });

  testWidgets('settings opens privacy and safety disclosure',
      (WidgetTester tester) async {
    await tester.pumpWidget(_testApp());

    await tester.tap(find.text(l10n.navProfile));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.ensureVisible(find.text(l10n.settingsPrivacySafety));
    await tester.pump();
    await tester.tap(find.text(l10n.settingsPrivacySafety));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(l10n.privacyTitle), findsOneWidget);
    expect(find.text(l10n.privacyLocalTitle), findsOneWidget);
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
