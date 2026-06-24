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
                      color: const Color(0xFFC7A77B).withOpacity(0.78),
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
  static const _bronzeFill = Color(0xFF4A2E12);
  static const _darkFill = Color(0xFF15100C);
  static const _quietFill = Color(0xFF11100D);

  final String label;
  final IconData icon;
  final bool isCheckedIn;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final foreground = isCheckedIn
        ? _amberText.withOpacity(enabled ? 0.74 : 0.34)
        : const Color(0xFFFFD59A).withOpacity(enabled ? 0.95 : 0.36);
    final fill = isCheckedIn
        ? _darkFill.withOpacity(enabled ? 0.82 : 0.42)
        : _bronzeFill.withOpacity(enabled ? 0.78 : 0.35);
    final border = isCheckedIn
        ? _amberBorder.withOpacity(enabled ? 0.30 : 0.12)
        : _amberBorder.withOpacity(enabled ? 0.46 : 0.14);

    return _ShrineActionButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      foreground: foreground,
      fill: fill,
      border: border,
      pressedFill: isCheckedIn
          ? _quietFill.withOpacity(0.92)
          : const Color(0xFF5B3713).withOpacity(0.86),
      hoverFill: isCheckedIn
          ? _darkFill.withOpacity(0.92)
          : const Color(0xFF553414).withOpacity(0.84),
      focusBorder: _amberBorder.withOpacity(0.58),
      glow: enabled && !isCheckedIn
          ? _amberBorder.withOpacity(0.10)
          : Colors.transparent,
      fontSize: 15,
      fontWeight: FontWeight.w600,
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

    return _ShrineActionButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      foreground: fg,
      fill: _darkFill.withOpacity(enabled ? 0.50 : 0.30),
      border: _mutedBorder.withOpacity(enabled ? 0.18 : 0.08),
      pressedFill: _darkFill.withOpacity(0.70),
      hoverFill: _darkFill.withOpacity(0.60),
      focusBorder: _mutedBorder.withOpacity(0.34),
      glow: Colors.transparent,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
  }
}

class _ShrineActionButton extends StatefulWidget {
  const _ShrineActionButton({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.fill,
    required this.border,
    required this.pressedFill,
    required this.hoverFill,
    required this.focusBorder,
    required this.glow,
    required this.fontSize,
    required this.fontWeight,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color foreground;
  final Color fill;
  final Color border;
  final Color pressedFill;
  final Color hoverFill;
  final Color focusBorder;
  final Color glow;
  final double fontSize;
  final FontWeight fontWeight;
  final VoidCallback? onPressed;

  @override
  State<_ShrineActionButton> createState() => _ShrineActionButtonState();
}

class _ShrineActionButtonState extends State<_ShrineActionButton> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final fill = !_enabled
        ? widget.fill
        : _pressed
            ? widget.pressedFill
            : _hovered || _focused
                ? widget.hoverFill
                : widget.fill;
    final border = _focused ? widget.focusBorder : widget.border;
    final scale = _pressed ? 0.985 : 1.0;

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      child: FocusableActionDetector(
        enabled: _enabled,
        mouseCursor:
            _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onShowHoverHighlight: (value) => setState(() => _hovered = value),
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
          onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
          onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 90),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              width: double.infinity,
              height: 54,
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(NutRadius.button),
                border: Border.all(color: border, width: _focused ? 1.0 : 0.8),
                boxShadow: [
                  if (_enabled && widget.glow != Colors.transparent)
                    BoxShadow(
                      color: widget.glow,
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 18, color: widget.foreground),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.foreground,
                      fontSize: widget.fontSize,
                      fontWeight: widget.fontWeight,
                      letterSpacing: 0.08,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
