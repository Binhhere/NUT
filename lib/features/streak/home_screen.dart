import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../app/theme.dart';
import '../../l10n/l10n.dart';
import '../../shared/widgets/nut_button.dart';
import '../../shared/widgets/nut_card.dart';
import '../../shared/widgets/nut_pill.dart';
import '../../shared/widgets/responsive_page.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/stat_card.dart';
import 'streak_model.dart';

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
  Timer? _timer;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _runAction(Future<void> Function() action) async {
    setState(() => _isBusy = true);
    await action();
    if (mounted) setState(() => _isBusy = false);
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.streak.currentDuration();
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final l10n = context.l10n;
    final palette = context.nutPalette;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: NutResponsiveListView(
        children: [
          SectionHeader(
            title: l10n.homeTitle,
            subtitle: _supportLineForReason(l10n, widget.reason),
          ),
          const SizedBox(height: NutSpacing.large),
          NutCard(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            borderColor: palette.accentBg,
            child: Column(
              children: [
                Text(
                  l10n.homeCurrentStreak,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.textMuted,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: NutSpacing.medium),
                _StreakRing(
                  days: days,
                  progress: widget.streak.nextMilestoneProgress,
                ),
                const SizedBox(height: NutSpacing.medium),
                Text(
                  widget.streak.hasStarted
                      ? l10n.homeStartedMessage
                      : l10n.homeNotStartedMessage,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: palette.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: NutSpacing.medium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SmallTime(
                      label: l10n.homeHours,
                      value: hours.toString().padLeft(2, '0'),
                    ),
                    const SizedBox(width: NutSpacing.medium),
                    _SmallTime(
                      label: l10n.homeMinutes,
                      value: minutes.toString().padLeft(2, '0'),
                    ),
                  ],
                ),
                const SizedBox(height: NutSpacing.large),
                NutPrimaryButton(
                  onPressed:
                      _isBusy ? null : () => _runAction(widget.onStartStreak),
                  icon: widget.streak.isCheckedInToday
                      ? Icons.check
                      : Icons.check_circle_outline,
                  label: widget.streak.isCheckedInToday
                      ? l10n.homeCheckedInToday
                      : l10n.homeCheckInToday,
                ),
                const SizedBox(height: NutSpacing.small),
                NutGhostButton(
                  onPressed: _isBusy || !widget.streak.hasStarted
                      ? null
                      : () => _runAction(widget.onResetStreak),
                  icon: Icons.replay_outlined,
                  foregroundColor: palette.reset,
                  label: l10n.homeResetWithSupport,
                ),
              ],
            ),
          ),
          const SizedBox(height: NutSpacing.large),
          SectionHeader(title: l10n.homeProgressTitle),
          const SizedBox(height: NutSpacing.medium),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: l10n.lifetimeCleanDays,
                  value: widget.streak.lifetimeCleanDays.toString(),
                  icon: Icons.favorite_outline,
                  accentColor: palette.success,
                ),
              ),
              const SizedBox(width: NutSpacing.medium),
              Expanded(
                child: StatCard(
                  label: l10n.homeBestStreak,
                  value: widget.streak.effectiveBestStreak.toString(),
                  icon: Icons.emoji_events_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: NutSpacing.large),
          _WeekCard(
            checkedToday: widget.streak.isCheckedInToday,
            labels: [
              l10n.homeWeekdayMonday,
              l10n.homeWeekdayTuesday,
              l10n.homeWeekdayWednesday,
              l10n.homeWeekdayThursday,
              l10n.homeWeekdayFriday,
              l10n.homeWeekdaySaturday,
              l10n.homeWeekdaySunday,
            ],
          ),
          const SizedBox(height: NutSpacing.medium),
          _MilestoneCard(streak: widget.streak),
          const SizedBox(height: NutSpacing.medium),
          _QuoteCard(),
          const SizedBox(height: NutSpacing.medium),
          _RyanTeaserCard(),
        ],
      ),
    );
  }
}

String _supportLineForReason(AppLocalizations l10n, String? reason) {
  switch (reason) {
    case final reason when reason == l10n.onboardingReasonFocus:
      return l10n.homeSupportFocus;
    case final reason when reason == l10n.onboardingReasonConfidence:
      return l10n.homeSupportConfidence;
    case final reason when reason == l10n.onboardingReasonDiscipline:
      return l10n.homeSupportDiscipline;
    case final reason when reason == l10n.onboardingReasonEnergy:
      return l10n.homeSupportEnergy;
    case final reason when reason == l10n.onboardingReasonJustTrying:
      return l10n.homeSupportJustTrying;
    default:
      return l10n.homeSupportDefault;
  }
}

class _StreakRing extends StatelessWidget {
  const _StreakRing({
    required this.days,
    required this.progress,
  });

  final int days;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(220),
            painter: _StreakRingPainter(
              progress: progress,
              baseColor: palette.surface,
              progressColor: palette.accentGold,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                days.toString(),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: palette.accentGold,
                      fontSize: 88,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -4,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.homeDaysClean,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.textSecondary,
                      letterSpacing: 1,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakRingPainter extends CustomPainter {
  const _StreakRingPainter({
    required this.progress,
    required this.baseColor,
    required this.progressColor,
  });

  final double progress;
  final Color baseColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final basePaint = Paint()
      ..color = baseColor
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke;
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, basePaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StreakRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.progressColor != progressColor;
  }
}

class _SmallTime extends StatelessWidget {
  const _SmallTime({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;

    return Container(
      width: 92,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(NutRadius.card),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({
    required this.checkedToday,
    required this.labels,
  });

  final bool checkedToday;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final todayIndex = DateTime.now().weekday - 1;

    return NutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.homeThisWeekTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: NutSpacing.medium),
          Row(
            children: [
              for (var index = 0; index < labels.length; index++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == labels.length - 1 ? 0 : 6,
                    ),
                    child: _WeekDay(
                      label: labels[index],
                      isToday: index == todayIndex,
                      checked: index < todayIndex ||
                          (index == todayIndex && checkedToday),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekDay extends StatelessWidget {
  const _WeekDay({
    required this.label,
    required this.isToday,
    required this.checked,
  });

  final String label;
  final bool isToday;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;
    final color = checked ? palette.accentGold : palette.surface;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 34,
          decoration: BoxDecoration(
            color: checked ? palette.accentBg : palette.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isToday ? palette.accentGold : palette.border,
            ),
          ),
          child: Center(
            child: Icon(
              checked ? Icons.check : Icons.circle_outlined,
              size: 15,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isToday ? palette.textPrimary : palette.textMuted,
              ),
        ),
      ],
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({required this.streak});

  final StreakModel streak;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.nutPalette;

    return NutCard(
      borderColor: palette.accentBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.homeNextMilestone,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              NutPill(label: '${streak.nextMilestone}'),
            ],
          ),
          const SizedBox(height: NutSpacing.medium),
          ClipRRect(
            borderRadius: BorderRadius.circular(NutRadius.pill),
            child: LinearProgressIndicator(
              value: streak.nextMilestoneProgress,
              minHeight: 8,
              backgroundColor: palette.surface,
              color: palette.accentGold,
            ),
          ),
          const SizedBox(height: NutSpacing.medium),
          Text(
            l10n.homeNextMilestoneBody(
              streak.daysToNextMilestone,
              streak.nextMilestone,
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NutPill(
            label: context.l10n.homeQuoteTitle,
            icon: Icons.wb_sunny_outlined,
          ),
          const SizedBox(height: NutSpacing.medium),
          Text(
            context.l10n.homeQuoteBody,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _RyanTeaserCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;

    return NutCard(
      borderColor: palette.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NutPill(
            label: context.l10n.homeRyanTeaserTitle,
            icon: Icons.auto_awesome,
            backgroundColor: palette.surface,
            foregroundColor: palette.textSecondary,
          ),
          const SizedBox(height: NutSpacing.medium),
          Text(
            context.l10n.homeRyanTeaserBody,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
