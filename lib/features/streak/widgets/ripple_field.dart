// lib/features/streak/widgets/ripple_field.dart
//
// Widget chính thay thế _StreakRing trong home_screen.dart.
//
// ANIMATION LAYERS:
//   1. _breatheCtrl  — idle breathe liên tục (2800ms repeat)
//   2. _pulseCtrl    — scale pulse khi check-in (600ms, easeOut)
//   3. BreakthroughAnimation — wrap toàn bộ khi phase >= breakthrough
//
// PUBLIC API:
//   GlobalKey<RippleFieldState> rippleKey
//   rippleKey.currentState?.triggerCheckInPulse()
//   → HomeScreen gọi sau khi streak update thành công

import 'package:flutter/material.dart';
import '../streak_model.dart';
import 'breakthrough_animation.dart';
import 'ripple_painter.dart';

class RippleField extends StatefulWidget {
  const RippleField({
    super.key,
    required this.streak,
  });

  final StreakModel streak;

  @override
  State<RippleField> createState() => RippleFieldState();
}

class RippleFieldState extends State<RippleField>
    with TickerProviderStateMixin {

  // ── Check-in pulse ───────────────────────────
  late final AnimationController _pulseCtrl;
  late final Animation<double>   _pulseAnim;

  // ── Idle breathe ─────────────────────────────
  late final AnimationController _breatheCtrl;
  late final Animation<double>   _breatheAnim;

  // ── New ripple fade-in state ──────────────────
  double _newRippleProgress = 1.0;
  int    _lastKnownRippleCount = 0;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseAnim = CurvedAnimation(
      parent: _pulseCtrl,
      curve:  Curves.easeOut,
    );

    _breatheCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _breatheAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOut),
    );

    _lastKnownRippleCount = widget.streak.rippleCount;
  }

  @override
  void didUpdateWidget(covariant RippleField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newCount = widget.streak.rippleCount;
    if (newCount > _lastKnownRippleCount) {
      _lastKnownRippleCount = newCount;
      _triggerNewRippleFadeIn();
    }
  }

  // ── Public ────────────────────────────────────

  /// HomeScreen gọi sau khi check-in thành công.
  void triggerCheckInPulse() {
    _pulseCtrl.forward(from: 0);
    _triggerNewRippleFadeIn();
  }

  // ── Private ───────────────────────────────────

  void _triggerNewRippleFadeIn() {
    setState(() => _newRippleProgress = 0.0);
    _pulseCtrl.forward(from: 0).then((_) {
      if (mounted) setState(() => _newRippleProgress = 1.0);
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _breatheCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final accentColor = theme.colorScheme.primary;
    final days        = widget.streak.currentStreakDays();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        // ── Visual layer ──────────────────────────
        // BreakthroughAnimation wrap RippleField canvas.
        // Phase seed/growing → passthrough (no extra cost).
        // Phase breakthrough+ → adds tilt + orb layers.
        BreakthroughAnimation(
          phase:       widget.streak.ripplePhase,
          accentColor: accentColor,
          child: AnimatedBuilder(
            animation: Listenable.merge([_breatheAnim, _pulseAnim]),
            builder: (context, _) {
              final breatheScale = _breatheAnim.value;
              final pulseScale   = 1.0 + _pulseAnim.value * 0.06;

              return Transform.scale(
                scale: breatheScale * pulseScale,
                child: SizedBox(
                  width:  220,
                  height: 220,
                  child: CustomPaint(
                    painter: RipplePainter(
                      phase:             widget.streak.ripplePhase,
                      rippleCount:       widget.streak.rippleCount,
                      newRippleProgress: _newRippleProgress,
                      accentColor:       accentColor,
                      originColor:       Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // ── Day count — nhỏ, bên dưới, không dominant ──
        const SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text:  days.toString(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color:         accentColor,
                  fontSize:      36,
                  fontWeight:    FontWeight.w600,
                  letterSpacing: -1,
                ),
              ),
              TextSpan(
                text:  '  days',
                style: theme.textTheme.bodySmall?.copyWith(
                  color:    theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // ── Phase label — tiến trình hint ─────────
        if (widget.streak.hasStarted) ...[
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              _phaseLabel(widget.streak.ripplePhase, days),
              key:   ValueKey(widget.streak.ripplePhase),
              style: theme.textTheme.bodySmall?.copyWith(
                color:         theme.colorScheme.onSurfaceVariant,
                fontSize:      11,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _phaseLabel(RipplePhase phase, int days) {
    return switch (phase) {
      RipplePhase.seed        => 'Start your streak',
      RipplePhase.growing     => '${7 - days} ${days == 6 ? 'day' : 'days'} to breakthrough',
      RipplePhase.breakthrough => 'First breakthrough 🌱',
      RipplePhase.ascending   => '${30 - days} days to next level',
      RipplePhase.rising      => '${90 - days} days to orbit',
      RipplePhase.orbit       => 'In orbit ✦',
    };
  }
}
