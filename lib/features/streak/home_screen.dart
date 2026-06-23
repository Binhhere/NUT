import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../l10n/l10n.dart';
import '../../shared/widgets/nut_button.dart';
import 'streak_model.dart';
import 'widgets/shrine_core.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.streak,
    this.reason,
    required this.onStartStreak,
    required this.onResetStreak,
  });

  final StreakModel streak;
  final String? reason;
  final Future<void> Function() onStartStreak;
  final Future<void> Function() onResetStreak;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _shrineKey = GlobalKey<ShrineCoreState>();

  Timer? _timer;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    // Refresh time display every 30s
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _runAction(
    Future<void> Function() action, {
    bool isCheckIn = false,
  }) async {
    HapticFeedback.lightImpact();
    setState(() => _isBusy = true);

    final oldDays = widget.streak.currentStreakDays();
    await action();
    final newDays = widget.streak.currentStreakDays();

    if (isCheckIn && newDays > oldDays) {
      _shrineKey.currentState?.triggerCheckInPulse();
    }

    if (mounted) setState(() => _isBusy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.nutPalette;
    final lifetimeDays = widget.streak.lifetimeCleanDays;

    return Scaffold(
      key: const Key('homeShrineScreen'),
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top: lifetime clean days ───────────────────
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: Text(
                '$lifetimeDays ${l10n.lifetimeCleanDays}'.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.accentGold.withOpacity(0.75),
                      fontSize: 11,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),

            // ── Center: shrine visual ──────────────────────
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShrineCore(
                        key: _shrineKey,
                        streak: widget.streak,
                      ),
                      const SizedBox(height: 32),

                      // ── Check-in button ──────────────────
                      NutPrimaryButton(
                        onPressed: _isBusy
                            ? null
                            : () => _runAction(
                                  widget.onStartStreak,
                                  isCheckIn: true,
                                ),
                        icon: widget.streak.isCheckedInToday
                            ? Icons.check
                            : Icons.check_circle_outline,
                        label: widget.streak.isCheckedInToday
                            ? l10n.homeCheckedInToday
                            : l10n.homeCheckInToday,
                      ),
                      const SizedBox(height: 12),

                      // ── Reset button (subtle) ────────────
                      NutGhostButton(
                        onPressed: _isBusy || !widget.streak.hasStarted
                            ? null
                            : () => _runAction(widget.onResetStreak),
                        icon: Icons.replay_outlined,
                        borderColor: palette.reset.withOpacity(0.22),
                        label: l10n.homeResetWithSupport,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom: daily quote ────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
              child: Text(
                l10n.homeQuoteBody,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.textMuted,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
