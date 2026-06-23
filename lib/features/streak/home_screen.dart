import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../l10n/l10n.dart';
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
                      _ShrineCheckInButton(
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
                        isCheckedIn: widget.streak.isCheckedInToday,
                      ),
                      const SizedBox(height: 12),

                      // ── Reset button (subtle) ────────────
                      _ShrineResetButton(
                        onPressed: _isBusy || !widget.streak.hasStarted
                            ? null
                            : () => _runAction(widget.onResetStreak),
                        icon: Icons.replay_outlined,
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

class _ShrineCheckInButton extends StatelessWidget {
  const _ShrineCheckInButton({
    required this.label,
    required this.icon,
    required this.isCheckedIn,
    this.onPressed,
  });

  static const _amberText = Color(0xFFE0B87C);
  static const _amberBorder = Color(0xFFD4A87A);
  static const _darkFill = Color(0xFF15100C);
  static const _quietFill = Color(0xFF11100D);

  final String label;
  final IconData icon;
  final bool isCheckedIn;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final fg = isCheckedIn
        ? _amberText.withOpacity(0.72)
        : _amberText.withOpacity(enabled ? 0.92 : 0.38);
    final borderOpacity = isCheckedIn ? 0.24 : 0.42;
    final fill = isCheckedIn ? _quietFill.withOpacity(0.72) : _darkFill;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(NutRadius.button),
          boxShadow: [
            if (enabled && !isCheckedIn)
              BoxShadow(
                color: _amberBorder.withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: enabled ? fill : _quietFill.withOpacity(0.38),
            foregroundColor: fg,
            disabledForegroundColor: fg,
            side: BorderSide(
              color: _amberBorder.withOpacity(enabled ? borderOpacity : 0.12),
              width: 0.8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(NutRadius.button),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShrineResetButton extends StatelessWidget {
  const _ShrineResetButton({
    required this.label,
    required this.icon,
    this.onPressed,
  });

  static const _mutedText = Color(0xFFB49C78);
  static const _mutedBorder = Color(0xFFC29D68);
  static const _darkFill = Color(0xFF0D0B09);

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final fg = _mutedText.withOpacity(enabled ? 0.70 : 0.28);

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: _darkFill.withOpacity(enabled ? 0.50 : 0.30),
          foregroundColor: fg,
          disabledForegroundColor: fg,
          side: BorderSide(
            color: _mutedBorder.withOpacity(enabled ? 0.18 : 0.08),
            width: 0.6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NutRadius.button),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.08,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
