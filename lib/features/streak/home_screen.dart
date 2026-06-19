import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:confetti/confetti.dart';

import '../../app/theme.dart';
import '../../l10n/l10n.dart';
import '../../shared/widgets/nut_button.dart';
import '../../shared/widgets/nut_card.dart';
import '../../shared/widgets/nut_pill.dart';
import '../../shared/widgets/responsive_page.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/stat_card.dart';
import 'streak_model.dart';
import 'widgets/ripple_field.dart';

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
  // RippleField key — dùng để trigger check-in pulse từ ngoài vào
  final _rippleKey = GlobalKey<RippleFieldState>();

  Timer? _timer;
  bool _isBusy = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    // Refresh hours/minutes display mỗi 30s
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
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
      // Trigger ripple pulse
      _rippleKey.currentState?.triggerCheckInPulse();

      // Confetti tại milestone
      const milestones = [1, 3, 7, 14, 30, 60, 90, 180, 365];
      if (milestones.contains(newDays)) {
        _confettiController.play();
        HapticFeedback.heavyImpact();
      }
    }

    if (mounted) setState(() => _isBusy = false);
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.streak.currentDuration();
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final l10n = context.l10n;
    final palette = context.nutPalette;

    return Scaffold(
      body: Stack(
        children: [
          NutResponsiveListView(
            children: [
              SectionHeader(
                title: l10n.homeTitle,
                subtitle: _supportLineForReason(l10n, widget.reason),
              ),
              const SizedBox(height: NutSpacing.large),

              // ── Streak card ───────────────────────────
              NutCard(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                borderColor: palette.accentGold.withOpacity(0.18),
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

                    // RippleField — thay thế _StreakRing
                    RippleField(
                      key: _rippleKey,
                      streak: widget.streak,
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

                    // Hours / Minutes
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
                    const SizedBox(height: NutSpacing.small),
                    NutGhostButton(
                      onPressed: _isBusy || !widget.streak.hasStarted
                          ? null
                          : () => _runAction(widget.onResetStreak),
                      icon: Icons.replay_outlined,
                      borderColor: palette.reset.withOpacity(0.28),
                      label: l10n.homeResetWithSupport,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: NutSpacing.large),

              // ── Progress stats ────────────────────────
              SmallSectionLabel(title: l10n.homeProgressTitle),
              const SizedBox(height: NutSpacing.medium),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: l10n.lifetimeCleanDays,
                      value: widget.streak.lifetimeCleanDays.toString(),
                      sublabel: l10n.homeDaysClean,
                      valueColor: palette.success,
                    ),
                  ),
                  const SizedBox(width: NutSpacing.medium),
                  Expanded(
                    child: StatCard(
                      label: l10n.homeBestStreak,
                      value: widget.streak.effectiveBestStreak.toString(),
                      sublabel: l10n.homeDays,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: NutSpacing.large),

              // ── This week ─────────────────────────────
              SmallSectionLabel(title: l10n.homeThisWeekTitle),
              const SizedBox(height: NutSpacing.medium),
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
              const SizedBox(height: NutSpacing.large),

              // ── Next milestone ────────────────────────
              SmallSectionLabel(title: l10n.homeNextMilestone),
              const SizedBox(height: NutSpacing.medium),
              _MilestoneCard(streak: widget.streak),
              const SizedBox(height: NutSpacing.large),

              // ── Quote ─────────────────────────────────
              SmallSectionLabel(title: l10n.homeQuoteTitle),
              const SizedBox(height: NutSpacing.medium),
              _QuoteCard(),
              const SizedBox(height: NutSpacing.medium),
              _RyanTeaserCard(),
            ],
          ),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [
                palette.accentGold,
                palette.success,
                palette.premium,
                Colors.white,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SUPPORT LINE
// ─────────────────────────────────────────────

String _supportLineForReason(AppLocalizations l10n, String? reason) {
  if (reason == null) return l10n.homeSupportDefault;
  final r = reason.toLowerCase();
  if (r.contains('focus') || r.contains('foco')) return l10n.homeSupportFocus;
  if (r.contains('confidence') || r.contains('confiança')) {
    return l10n.homeSupportConfidence;
  }
  if (r.contains('discipline') || r.contains('disciplina')) {
    return l10n.homeSupportDiscipline;
  }
  if (r.contains('energy') || r.contains('energia')) {
    return l10n.homeSupportEnergy;
  }
  if (r.contains('trying') || r.contains('tentando')) {
    return l10n.homeSupportJustTrying;
  }
  return l10n.homeSupportDefault;
}

// ─────────────────────────────────────────────
// SMALL WIDGETS
// ─────────────────────────────────────────────

class _SmallTime extends StatelessWidget {
  const _SmallTime({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;

    return Semantics(
      label: '$label $value',
      child: Container(
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
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.checkedToday, required this.labels});

  final bool checkedToday;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final todayIndex = DateTime.now().weekday - 1;

    return NutCard(
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == labels.length - 1 ? 0 : 6),
                child: _WeekDay(
                  label: labels[i],
                  isToday: i == todayIndex,
                  checked: i < todayIndex || (i == todayIndex && checkedToday),
                ),
              ),
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
      child: Text(
        context.l10n.homeQuoteBody,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
            ),
      ),
    );
  }
}

class _RyanTeaserCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;

    return NutCard(
      borderColor: palette.premiumBg,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: palette.premiumSurface,
              shape: BoxShape.circle,
              border: Border.all(color: palette.premium.withOpacity(0.2)),
            ),
            child: Center(
              child: Icon(
                Icons.nightlight_round_outlined,
                size: 19,
                color: palette.premium,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.homeRyanTeaserTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 13,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.homeRyanTeaserBody,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          NutPill(
            label: 'V2',
            backgroundColor: palette.premiumBg,
            foregroundColor: palette.premium,
          ),
        ],
      ),
    );
  }
}
