// lib/app/router.dart
//
// Wave 1: app dùng manual Navigator + IndexedStack trong _NutShell.
// File này để sẵn cho GoRouter khi Wave 3 (Supabase auth) vào.
//
// Để add GoRouter sau:
//   1. flutter pub add go_router
//   2. Uncomment và điền routes bên dưới
//   3. Thay MaterialApp → MaterialApp.router trong nut_app.dart
//
// KHÔNG import file này ở Wave 1 — để tránh dead import crash.

// import 'package:go_router/go_router.dart';
// import '../features/splash/splash_screen.dart';
// import '../features/onboarding/onboarding_screen.dart';
// import '../features/streak/home_screen.dart';
// import '../features/streak/relapse_screen.dart';
// import '../features/feed/feed_screen.dart';
// import '../features/badges/badges_screen.dart';
// import '../features/profile/profile_screen.dart';
// import '../features/paywall/paywall_screen.dart';
// import '../features/journal/journal_screen.dart';
// import '../features/analytics/relapse_analytics_screen.dart';
// import '../features/settings/settings_screen.dart';
// import '../features/auth/login_screen.dart';
// import '../features/auth/signup_screen.dart';

// Route name constants — dùng chung để tránh typo khi navigate
abstract class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const relapse = '/relapse';
  static const feed = '/feed';
  static const badges = '/badges';
  static const profile = '/profile';
  static const paywall = '/paywall';
  static const journal = '/journal';
  static const analytics = '/analytics';
  static const settings = '/settings';
  static const login = '/login';
  static const signup = '/signup';
}

// GoRouter config — Wave 3
// final router = GoRouter(
//   initialLocation: Routes.splash,
//   routes: [
//     GoRoute(path: Routes.splash,    builder: (_, __) => const SplashScreen()),
//     GoRoute(path: Routes.onboarding,builder: (_, __) => OnboardingScreen(onComplete: (_) async {})),
//     GoRoute(path: Routes.home,      builder: (_, __) => const HomeScreen()),
//     GoRoute(path: Routes.relapse,   builder: (_, __) => const RelapseScreen()),
//     GoRoute(path: Routes.feed,      builder: (_, __) => const FeedScreen()),
//     GoRoute(path: Routes.badges,    builder: (_, __) => const BadgesScreen()),
//     GoRoute(path: Routes.profile,   builder: (_, __) => const ProfileScreen()),
//     GoRoute(path: Routes.paywall,   builder: (_, __) => const PaywallScreen()),
//     GoRoute(path: Routes.journal,   builder: (_, __) => const JournalScreen()),
//     GoRoute(path: Routes.analytics, builder: (_, __) => const RelapseAnalyticsScreen()),
//     GoRoute(path: Routes.settings,  builder: (_, __) => const SettingsScreen()),
//     GoRoute(path: Routes.login,     builder: (_, __) => const LoginScreen()),
//     GoRoute(path: Routes.signup,    builder: (_, __) => const SignupScreen()),
//   ],
// );
