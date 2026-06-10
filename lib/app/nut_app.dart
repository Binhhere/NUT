import 'package:flutter/material.dart';

import '../features/badges/badges_screen.dart';
import '../features/feed/feed_screen.dart';
import '../features/feed/feed_service.dart';
import '../features/paywall/paywall_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/streak/home_screen.dart';
import '../features/streak/relapse_screen.dart';
import '../features/streak/streak_model.dart';
import '../features/streak/streak_service.dart';
import 'theme.dart';

class NutApp extends StatelessWidget {
  const NutApp({
    super.key,
    required this.streakService,
    required this.feedService,
    required this.initialStreak,
  });

  final StreakService streakService;
  final FeedService feedService;
  final StreakModel initialStreak;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NUT',
      debugShowCheckedModeBanner: false,
      theme: NutTheme.light(),
      home: _NutShell(
        streakService: streakService,
        feedService: feedService,
        initialStreak: initialStreak,
      ),
    );
  }
}

class _NutShell extends StatefulWidget {
  const _NutShell({
    required this.streakService,
    required this.feedService,
    required this.initialStreak,
  });

  final StreakService streakService;
  final FeedService feedService;
  final StreakModel initialStreak;

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

  Future<void> _startStreak() async {
    final streak = await widget.streakService.startStreak();
    setState(() => _streak = streak);
  }

  Future<void> _resetStreak(BuildContext context) async {
    final streak = await widget.streakService.resetStreak(_streak);
    if (!mounted || !context.mounted) return;

    setState(() => _streak = streak);

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RelapseScreen(streak: streak),
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
    final pages = [
      HomeScreen(
        streak: _streak,
        onStartStreak: _startStreak,
        onResetStreak: () => _resetStreak(context),
      ),
      FeedScreen(feedService: widget.feedService, streak: _streak),
      BadgesScreen(streak: _streak),
      ProfileScreen(
        streak: _streak,
        onOpenPaywall: () => _openPaywall(context),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.workspace_premium_outlined),
            selectedIcon: Icon(Icons.workspace_premium),
            label: 'Badges',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
