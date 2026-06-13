import 'package:flutter/material.dart';

import '../features/badges/badges_screen.dart';
import '../features/feed/feed_screen.dart';
import '../features/feed/feed_service.dart';
import '../features/onboarding/onboarding_model.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/onboarding_service.dart';
import '../features/paywall/paywall_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/streak/home_screen.dart';
import '../features/streak/relapse_screen.dart';
import '../features/streak/streak_model.dart';
import '../features/streak/streak_service.dart';
import '../l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'theme.dart';

class NutApp extends StatelessWidget {
  const NutApp({
    super.key,
    required this.streakService,
    required this.onboardingService,
    required this.feedService,
    required this.initialStreak,
    required this.initialOnboarding,
  });

  final StreakService streakService;
  final OnboardingService onboardingService;
  final FeedService feedService;
  final StreakModel initialStreak;
  final OnboardingProfile initialOnboarding;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: NutTheme.light(),
      darkTheme: NutTheme.dark(),
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [
        Locale('en'),
        Locale('pt'),
        Locale('ja'),
      ],
      home: _NutRoot(
        streakService: streakService,
        onboardingService: onboardingService,
        feedService: feedService,
        initialStreak: initialStreak,
        initialOnboarding: initialOnboarding,
      ),
    );
  }
}

class _NutRoot extends StatefulWidget {
  const _NutRoot({
    required this.streakService,
    required this.onboardingService,
    required this.feedService,
    required this.initialStreak,
    required this.initialOnboarding,
  });

  final StreakService streakService;
  final OnboardingService onboardingService;
  final FeedService feedService;
  final StreakModel initialStreak;
  final OnboardingProfile initialOnboarding;

  @override
  State<_NutRoot> createState() => _NutRootState();
}

class _NutRootState extends State<_NutRoot> {
  late OnboardingProfile _onboarding = widget.initialOnboarding;

  Future<void> _finishOnboarding(OnboardingProfile profile) async {
    final savedProfile = await widget.onboardingService.saveProfile(profile);
    if (mounted) setState(() => _onboarding = savedProfile);
  }

  @override
  Widget build(BuildContext context) {
    if (!_onboarding.hasSeenOnboarding) {
      return OnboardingScreen(onComplete: _finishOnboarding);
    }

    return _NutShell(
      streakService: widget.streakService,
      feedService: widget.feedService,
      initialStreak: widget.initialStreak,
      onboarding: _onboarding,
    );
  }
}

class _NutShell extends StatefulWidget {
  const _NutShell({
    required this.streakService,
    required this.feedService,
    required this.initialStreak,
    required this.onboarding,
  });

  final StreakService streakService;
  final FeedService feedService;
  final StreakModel initialStreak;
  final OnboardingProfile onboarding;

  @override
  State<_NutShell> createState() => _NutShellState();
}

class _NutShellState extends State<_NutShell> {
  late StreakModel _streak;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _streak = widget.initialStreak;
  }

  Future<void> _checkIn() async {
    final streak = await widget.streakService.checkIn(_streak);
    setState(() => _streak = streak);
  }

  Future<void> _openRelapseFlow(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RelapseScreen(
          streak: _streak,
          onConfirmReset: () async {
            final streak = await widget.streakService.resetStreak(_streak);
            if (mounted) setState(() => _streak = streak);
          },
        ),
      ),
    );
  }

  void _openPaywall(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const PaywallScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pages = [
      HomeScreen(
        streak: _streak,
        reason: widget.onboarding.reason,
        onStartStreak: _checkIn,
        onResetStreak: () => _openRelapseFlow(context),
      ),
      FeedScreen(
        feedService: widget.feedService,
        streak: _streak,
        username: widget.onboarding.username,
      ),
      BadgesScreen(streak: _streak),
      ProfileScreen(
        streak: _streak,
        username: widget.onboarding.username,
        reason: widget.onboarding.reason,
        onOpenPaywall: () => _openPaywall(context),
      ),
    ];

    final destinations = [
      _NutDestination(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: l10n.navHome,
      ),
      _NutDestination(
        icon: Icons.forum_outlined,
        selectedIcon: Icons.forum,
        label: l10n.navFeed,
      ),
      _NutDestination(
        icon: Icons.workspace_premium_outlined,
        selectedIcon: Icons.workspace_premium,
        label: l10n.navBadges,
      ),
      _NutDestination(
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        label: l10n.navProfile,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= NutBreakpoints.medium;
        final body = SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
        );

        if (useRail) {
          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (index) {
                      setState(() => _selectedIndex = index);
                    },
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      for (final destination in destinations)
                        NavigationRailDestination(
                          icon: Icon(destination.icon),
                          selectedIcon: Icon(destination.selectedIcon),
                          label: Text(destination.label),
                        ),
                    ],
                  ),
                ),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            destinations: [
              for (final destination in destinations)
                NavigationDestination(
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(destination.selectedIcon),
                  label: destination.label,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _NutDestination {
  const _NutDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
