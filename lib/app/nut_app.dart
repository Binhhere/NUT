import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/badges/badges_screen.dart';
import '../features/feed/feed_screen.dart';
import '../features/feed/feed_service.dart';
import '../features/onboarding/onboarding_model.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/onboarding_service.dart';
import '../features/paywall/paywall_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/streak/home_screen.dart';
import '../features/streak/relapse_screen.dart';
import '../features/streak/streak_model.dart';
import '../features/streak/streak_service.dart';
import '../l10n/l10n.dart';
import '../shared/services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'theme.dart';

// ─────────────────────────────────────────────
// AppTheme enum — nguồn sự thật duy nhất cho theme selection
// ─────────────────────────────────────────────

enum AppTheme {
  dark,
  ocean,
  light;

  static const _prefKey = 'app_theme';

  String get label => switch (this) {
        AppTheme.dark => 'Dark',
        AppTheme.ocean => 'Ocean',
        AppTheme.light => 'Light',
      };

  ThemeData toThemeData() => switch (this) {
        AppTheme.dark => NutTheme.dark(),
        AppTheme.ocean => NutTheme.ocean(),
        AppTheme.light => NutTheme.light(),
      };

  ThemeMode get themeMode => switch (this) {
        AppTheme.light => ThemeMode.light,
        _ => ThemeMode.dark,
      };

  static AppTheme fromString(String? value) => switch (value) {
        'ocean' => AppTheme.ocean,
        'light' => AppTheme.light,
        _ => AppTheme.dark,
      };

  String get persistValue => name;

  static Future<AppTheme> load() async {
    final prefs = await SharedPreferences.getInstance();
    return fromString(prefs.getString(_prefKey));
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, persistValue);
  }
}

// ─────────────────────────────────────────────

class NutApp extends StatelessWidget {
  const NutApp({
    super.key,
    required this.streakService,
    required this.onboardingService,
    required this.feedService,
    required this.initialStreak,
    required this.initialOnboarding,
    this.initialTheme = AppTheme.dark,
    this.locale,
    this.showSplash = true,
  });

  final StreakService streakService;
  final OnboardingService onboardingService;
  final FeedService feedService;
  final StreakModel initialStreak;
  final OnboardingProfile initialOnboarding;
  final AppTheme initialTheme;
  final Locale? locale;
  final bool showSplash;

  @override
  Widget build(BuildContext context) {
    return _NutRoot(
      streakService: streakService,
      onboardingService: onboardingService,
      feedService: feedService,
      initialStreak: initialStreak,
      initialOnboarding: initialOnboarding,
      initialTheme: initialTheme,
      locale: locale,
      showSplash: showSplash,
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
    required this.initialTheme,
    this.locale,
    required this.showSplash,
  });

  final StreakService streakService;
  final OnboardingService onboardingService;
  final FeedService feedService;
  final StreakModel initialStreak;
  final OnboardingProfile initialOnboarding;
  final AppTheme initialTheme;
  final Locale? locale;
  final bool showSplash;

  @override
  State<_NutRoot> createState() => _NutRootState();
}

class _NutRootState extends State<_NutRoot> with WidgetsBindingObserver {
  late OnboardingProfile _onboarding = widget.initialOnboarding;
  late bool _showSplash = widget.showSplash;
  late AppTheme _appTheme = widget.initialTheme;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_showSplash) {
      Future<void>.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _showSplash = false);
      });
    }
    _checkAppLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _lockApp();
    } else if (state == AppLifecycleState.resumed) {
      _checkAppLock();
    }
  }

  void _lockApp() async {
    final authService = AuthService();
    if (await authService.isAppLockEnabled()) {
      setState(() => _isLocked = true);
    }
  }

  Future<void> _checkAppLock() async {
    final authService = AuthService();
    if (await authService.isAppLockEnabled()) {
      setState(() => _isLocked = true);
      final authenticated = await authService.authenticate();
      if (authenticated) {
        setState(() => _isLocked = false);
      }
    }
  }

  Future<void> _finishOnboarding(OnboardingProfile profile) async {
    final savedProfile = await widget.onboardingService.saveProfile(profile);
    if (mounted) setState(() => _onboarding = savedProfile);
  }

  Future<void> _onThemeChanged(AppTheme theme) async {
    await theme.save();
    if (mounted) setState(() => _appTheme = theme);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = _appTheme.toThemeData();

    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: themeData,
      darkTheme: themeData,
      themeMode: ThemeMode.dark, // always use our explicit theme, not system
      locale: widget.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [
        Locale('en'),
        Locale('pt'),
        Locale('ja'),
      ],
      home: Builder(
        builder: (context) {
          if (_showSplash) return const SplashScreen();

          if (_isLocked) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline, size: 64),
                    const SizedBox(height: 24),
                    Text(context.l10n.appLockLockedTitle),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _checkAppLock,
                      child: Text(context.l10n.appLockUnlock),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!_onboarding.hasSeenOnboarding) {
            return OnboardingScreen(onComplete: _finishOnboarding);
          }

          return _NutShell(
            streakService: widget.streakService,
            feedService: widget.feedService,
            initialStreak: widget.initialStreak,
            onboarding: _onboarding,
            currentTheme: _appTheme,
            onThemeChanged: _onThemeChanged,
          );
        },
      ),
    );
  }
}

class _NutShell extends StatefulWidget {
  const _NutShell({
    required this.streakService,
    required this.feedService,
    required this.initialStreak,
    required this.onboarding,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  final StreakService streakService;
  final FeedService feedService;
  final StreakModel initialStreak;
  final OnboardingProfile onboarding;
  final AppTheme currentTheme;
  final ValueChanged<AppTheme> onThemeChanged;

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
        builder: (_) => PaywallScreen(streak: _streak),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(
          currentTheme: widget.currentTheme,
          onThemeChanged: widget.onThemeChanged,
        ),
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
        onOpenSettings: () => _openSettings(context),
      ),
    ];

    final destinations = [
      _NutDestination(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: l10n.navHome),
      _NutDestination(
          icon: Icons.forum_outlined,
          selectedIcon: Icons.forum,
          label: l10n.navFeed),
      _NutDestination(
          icon: Icons.workspace_premium_outlined,
          selectedIcon: Icons.workspace_premium,
          label: l10n.navBadges),
      _NutDestination(
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          label: l10n.navProfile),
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
                    onDestinationSelected: (i) =>
                        setState(() => _selectedIndex = i),
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      for (final d in destinations)
                        NavigationRailDestination(
                          icon: Icon(d.icon),
                          selectedIcon: Icon(d.selectedIcon),
                          label: Text(d.label),
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
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            destinations: [
              for (final d in destinations)
                NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: d.label,
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
