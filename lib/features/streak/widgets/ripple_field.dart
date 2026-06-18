// lib/features/streak/widgets/ripple_field.dart
//
// Widget chính thay thế _StreakRing trong home_screen.dart.
//
// Quản lý 2 AnimationController:
//   1. _pulseCtrl    — scale pulse khi check-in (600ms, easeOut)
//   2. _breatheCtrl  — idle breathe liên tục ở điểm sáng (2800ms, repeat)
//
// Public API:
//   GlobalKey<RippleFieldState> + triggerCheckInPulse()
//   → HomeScreen gọi sau khi streak update thành công.
//
// Session 2 sẽ bổ sung BreakthroughAnimation riêng cho phase == breakthrough.

import 'package:flutter/material.dart';
import '../streak_model.dart';
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
  late final Animation<double> _pulseAnim;

  // ── Idle breathe ─────────────────────────────
  late final AnimationController _breatheCtrl;
  late final Animation<double> _breatheAnim;

  // ── New ripple fade-in ────────────────────────
  double _newRippleProgress = 1.0;
  int _lastKnownRippleCount = 0;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut);

    _breatheCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _breatheAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOut),
    );

    _lastKnownRippleCount = widget.streak.rippleCount;
    _newRippleProgress    = 1.0; // settled on first build
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

  /// Public — HomeScreen gọi sau khi check-in thành công.
  void triggerCheckInPulse() {
    _pulseCtrl.forward(from: 0);
    _triggerNewRippleFadeIn();
  }

  void _triggerNewRippleFadeIn() {
    setState(() => _newRippleProgress = 0.0);
    // Animate progress từ 0 → 1 trong 600ms
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

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final accentColor = theme.colorScheme.primary;
    final days        = widget.streak.currentStreakDays();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Ripple visual ─────────────────────
        AnimatedBuilder(
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

        // ── Số ngày — nhỏ, bên dưới, không dominant ──
        const SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: days.toString(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color:       accentColor,
                  fontSize:    36,
                  fontWeight:  FontWeight.w600,
                  letterSpacing: -1,
                ),
              ),
              TextSpan(
                text: '  days',
                style: theme.textTheme.bodySmall?.copyWith(
                  color:    theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // ── Phase label — hint tiến trình ─────
        if (widget.streak.hasStarted) ...[
          const SizedBox(height: 4),
          Text(
            _phaseLabel(widget.streak.ripplePhase, days),
            style: theme.textTheme.bodySmall?.copyWith(
              color:       theme.colorScheme.onSurfaceVariant,
              fontSize:    11,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ],
    );
  }

  String _phaseLabel(RipplePhase phase, int days) {
    return switch (phase) {
      RipplePhase.seed        => 'Start your streak',
      RipplePhase.growing     => '${7 - days} days to first breakthrough',
      RipplePhase.breakthrough => 'First breakthrough 🌱',
      RipplePhase.ascending   => '${30 - days} days to next level',
      RipplePhase.rising      => '${90 - days} days to orbit',
      RipplePhase.orbit       => 'In orbit ✦',
    };
  }
}
