import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../l10n/l10n.dart';
import '../streak_model.dart';
import 'breakthrough_animation.dart';
import 'pet_companion.dart';
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
  late final AnimationController _breathingPulseController;
  late final AnimationController _pierceController;
  late final AnimationController _settleController;
  late int _lastKnownPiercedCount;

  @override
  void initState() {
    super.initState();
    _breathingPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _pierceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
      value: 1,
    );
    _settleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _lastKnownPiercedCount = widget.streak.piercedRingCount;
  }

  @override
  void didUpdateWidget(covariant RippleField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _lastKnownPiercedCount = widget.streak.piercedRingCount;
  }

  void triggerCheckInPulse() {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ??
        MediaQuery.maybeOf(context)?.accessibleNavigation ??
        false;
    if (reduceMotion) {
      _pierceController.value = 1;
      _settleController.value = 1;
      return;
    }

    switch (widget.streak.ripplePhase) {
      case RipplePhase.seed:
      case RipplePhase.breathing:
        _breathingPulseController.forward(from: 0);
      case RipplePhase.piercing:
        _lastKnownPiercedCount = widget.streak.piercedRingCount;
        _pierceController.forward(from: 0).then((_) {
          if (mounted) _settleController.forward(from: 0);
        });
      case RipplePhase.breakthrough:
      case RipplePhase.pet:
        _breathingPulseController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _breathingPulseController.dispose();
    _pierceController.dispose();
    _settleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;
    final days = widget.streak.currentStreakDays();
    final phase = widget.streak.ripplePhase;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (phase == RipplePhase.pet)
          PetCompanion(
            accessories: widget.streak.petAccessories,
            accentColor: accentColor,
          )
        else
          BreakthroughAnimation(
            phase: phase,
            accentColor: accentColor,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _breathingPulseController,
                _pierceController,
                _settleController,
              ]),
              builder: (context, _) {
                final pulse =
                    mathEaseOut(_breathingPulseController.value) * 0.08;
                final settle =
                    Curves.easeInOut.transform(_settleController.value);
                final settleOffset = Offset(0, mathSin(settle) * 5);

                return Transform.translate(
                  offset: settleOffset,
                  child: Transform.scale(
                    scale: 1 + pulse,
                    child: SizedBox(
                      width: 220,
                      height: 220,
                      child: CustomPaint(
                        painter: RipplePainter(
                          phase: phase,
                          piercedRingCount: _lastKnownPiercedCount,
                          ringDecayProgress: widget.streak.ringDecayProgress,
                          breathingProgress: widget.streak.breathingProgress,
                          pierceProgress: _pierceController.value,
                          accentColor: accentColor,
                          originColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: days.toString(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: accentColor,
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1,
                ),
              ),
              TextSpan(
                text: '  ${context.l10n.homeDays}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        if (widget.streak.hasStarted) ...[
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _phaseLabel(context.l10n, phase, days),
              key: ValueKey('${phase.name}-$days'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _phaseLabel(AppLocalizations l10n, RipplePhase phase, int days) {
    return switch (phase) {
      RipplePhase.seed => l10n.homeRippleSeedLabel,
      RipplePhase.breathing => l10n.homeRippleBreathingLabel,
      RipplePhase.piercing => l10n.homeRipplePiercingLabel(
          widget.streak.piercedRingCount,
          StreakModel.totalRingLayers,
          StreakModel.breakthroughDay - days,
        ),
      RipplePhase.breakthrough => l10n.homeRippleBreakthroughLabel,
      RipplePhase.pet => l10n.homeRipplePetLabel,
    };
  }
}

double mathEaseOut(double value) => Curves.easeOut.transform(value);

double mathSin(double value) {
  // Keeps ripple_field free of a broad dart:math import at call sites.
  return value <= 0 || value >= 1 ? 0 : 4 * value * (1 - value);
}
