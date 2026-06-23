import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../streak_model.dart';
import 'shrine_painter.dart';

/// Reusable shrine visual widget.
/// Shows a layered organic shrine that evolves with streak phase.
/// Long-press reveals stats overlay.
class ShrineCore extends StatefulWidget {
  const ShrineCore({
    super.key,
    required this.streak,
    this.onCheckInPulse,
  });

  final StreakModel streak;

  /// Call this to trigger a check-in pulse from outside.
  final VoidCallback? onCheckInPulse;

  @override
  State<ShrineCore> createState() => ShrineCoreState();
}

class ShrineCoreState extends State<ShrineCore> with TickerProviderStateMixin {
  // breathing / idle glow oscillation
  late final AnimationController _breathingCtrl;
  // crack progress driven by streak (not animated — computed from model)
  // opening burst (day 21 breakthrough)
  late final AnimationController _openCtrl;
  // sprout growth (post day 22)
  late final AnimationController _sproutCtrl;
  // check-in pulse (short scale pop)
  late final AnimationController _pulseCtrl;

  bool _statsVisible = false;

  @override
  void initState() {
    super.initState();

    _breathingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _openCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _sproutCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    _syncToStreak();
  }

  @override
  void didUpdateWidget(covariant ShrineCore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streak.ripplePhase != widget.streak.ripplePhase ||
        oldWidget.streak.currentStreakDays() !=
            widget.streak.currentStreakDays()) {
      _syncToStreak();
    }
  }

  void _syncToStreak() {
    final phase = shrinePhaseFrom(widget.streak.ripplePhase);

    if (phase == ShrinePhase.opening) {
      if (!_openCtrl.isAnimating && _openCtrl.value == 0) {
        Future.microtask(() {
          if (mounted) _openCtrl.forward();
        });
      }
    }

    if (phase == ShrinePhase.sprout) {
      // Sprout height driven by days beyond 21
      final days = widget.streak.currentStreakDays();
      final sprout = ((days - 21) / 60.0).clamp(0.0, 1.0);
      _sproutCtrl.animateTo(sprout,
          duration: const Duration(milliseconds: 1200), curve: Curves.easeOut);
    }
  }

  /// External trigger for check-in pulse
  void triggerCheckInPulse() {
    _pulseCtrl.forward(from: 0).then((_) {
      if (mounted) _pulseCtrl.reverse();
    });
    HapticFeedback.lightImpact();
    _syncToStreak();
  }

  @override
  void dispose() {
    _breathingCtrl.dispose();
    _openCtrl.dispose();
    _sproutCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phase = shrinePhaseFrom(widget.streak.ripplePhase);
    final days = widget.streak.currentStreakDays();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onLongPress: _showStats,
          onLongPressEnd: (_) => _hideStats(),
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _breathingCtrl,
              _openCtrl,
              _sproutCtrl,
              _pulseCtrl,
            ]),
            builder: (context, _) {
              final breathing =
                  Curves.easeInOut.transform(_breathingCtrl.value);
              final pulse = Curves.elasticOut
                  .transform(Curves.easeOut.transform(_pulseCtrl.value));
              final scale = 1.0 + pulse * 0.04;

              final crackProgress = switch (phase) {
                ShrinePhase.cracking =>
                  widget.streak.ringDecayProgress.clamp(0.0, 1.0),
                ShrinePhase.opening => 1.0,
                _ => 0.0,
              };

              return Transform.scale(
                scale: scale,
                child: SizedBox(
                  width: 280,
                  height: 280,
                  child: CustomPaint(
                    painter: ShrinePainter(
                      phase: phase,
                      crackProgress: crackProgress,
                      breathingScale: breathing,
                      openProgress: _openCtrl.value,
                      sproutHeight: _sproutCtrl.value,
                      glowPulse: breathing,
                      palette: buildShrinePalette(context),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Day count
        _DayLabel(days: days, phase: phase),

        // Stats overlay (shown on long-press)
        if (_statsVisible) _StatsOverlay(streak: widget.streak),
      ],
    );
  }

  void _showStats() {
    HapticFeedback.mediumImpact();
    setState(() => _statsVisible = true);
  }

  void _hideStats() {
    setState(() => _statsVisible = false);
  }
}

// ── Day label ──────────────────────────────────────────────

class _DayLabel extends StatelessWidget {
  const _DayLabel({required this.days, required this.phase});

  final int days;
  final ShrinePhase phase;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.nutPalette;
    final theme = Theme.of(context);

    final phaseLabel = switch (phase) {
      ShrinePhase.rooting => l10n.homeShrineRootingLabel,
      ShrinePhase.cracking => l10n.homeShrineRootingLabel, // "rooting deeper"
      ShrinePhase.opening => l10n.homeShrineOpeningLabel,
      ShrinePhase.sprout => l10n.homeShrinesSproutLabel,
    };

    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: days.toString(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: palette.accentGold,
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1,
                ),
              ),
              TextSpan(
                text: '  ${l10n.homeDays}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        if (days > 0) ...[
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              phaseLabel,
              key: ValueKey(phase),
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.textMuted,
                fontSize: 11,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Stats overlay (long-press) ─────────────────────────────

class _StatsOverlay extends StatelessWidget {
  const _StatsOverlay({required this.streak});

  final StreakModel streak;

  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(NutRadius.card),
          border: Border.all(color: palette.accentGold.withOpacity(0.18)),
        ),
        child: Column(
          children: [
            _StatRow(
              label: l10n.homeCurrentStreak,
              value: '${streak.currentStreakDays()} ${l10n.homeDays}',
              palette: palette,
              theme: theme,
            ),
            _StatRow(
              label: l10n.homeBestStreak,
              value: '${streak.effectiveBestStreak} ${l10n.homeDays}',
              palette: palette,
              theme: theme,
            ),
            _StatRow(
              label: l10n.lifetimeCleanDays,
              value: streak.lifetimeCleanDays.toString(),
              palette: palette,
              theme: theme,
            ),
            _StatRow(
              label: l10n.homeNextMilestone,
              value: '${streak.daysToNextMilestone} ${l10n.homeDays}',
              palette: palette,
              theme: theme,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.palette,
    required this.theme,
    this.isLast = false,
  });

  final String label;
  final String value;
  final NutPalette palette;
  final ThemeData theme;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: palette.textMuted, fontSize: 12)),
          Text(value,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
        ],
      ),
    );
  }
}
