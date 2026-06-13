import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/l10n.dart';
import '../../shared/widgets/nut_button.dart';
import '../../shared/widgets/nut_card.dart';
import '../../shared/widgets/nut_pill.dart';
import '../../shared/widgets/responsive_page.dart';
import '../../shared/widgets/stat_card.dart';
import 'streak_model.dart';

class RelapseScreen extends StatefulWidget {
  const RelapseScreen({
    super.key,
    required this.streak,
    required this.onConfirmReset,
  });

  final StreakModel streak;
  final Future<void> Function() onConfirmReset;

  @override
  State<RelapseScreen> createState() => _RelapseScreenState();
}

class _RelapseScreenState extends State<RelapseScreen> {
  final Set<String> _selectedTriggers = {};
  bool _isResetting = false;

  Future<void> _showResetConfirmation() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.nutPalette.surface,
      showDragHandle: true,
      builder: (context) {
        final l10n = context.l10n;
        final palette = context.nutPalette;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.relapseConfirmTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: NutSpacing.small),
                Text(
                  l10n.relapseConfirmBody,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: palette.textSecondary,
                      ),
                ),
                const SizedBox(height: NutSpacing.large),
                NutResetConfirmButton(
                  label: l10n.relapseConfirmReset,
                  onPressed: _isResetting
                      ? null
                      : () async {
                          setState(() => _isResetting = true);
                          await widget.onConfirmReset();
                          if (!mounted || !context.mounted) return;
                          Navigator.of(context).pop();
                          Navigator.of(this.context).pop();
                        },
                ),
                const SizedBox(height: NutSpacing.small),
                NutGhostButton(
                  label: l10n.relapseConfirmCancel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (mounted) setState(() => _isResetting = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.nutPalette;
    final streakDays = widget.streak.currentStreakDays();
    final triggers = [
      l10n.relapseTriggerStress,
      l10n.relapseTriggerBoredom,
      l10n.relapseTriggerLateNight,
      l10n.relapseTriggerPhoneInBed,
      l10n.relapseTriggerLonely,
      l10n.relapseTriggerOther,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.relapseTitle)),
      body: NutResponsiveListView(
        children: [
          NutCard(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              children: [
                NutPill(
                  label: l10n.relapseGentleReset,
                  icon: Icons.circle,
                  backgroundColor: palette.resetBg,
                  foregroundColor: palette.reset,
                ),
                const SizedBox(height: NutSpacing.large),
                Text(
                  l10n.relapseHeadline,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: NutSpacing.medium),
                Text(
                  l10n.relapseBody,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: palette.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: NutSpacing.medium),
          NutCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.relapseStreakRecap,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.textMuted,
                        letterSpacing: 1,
                      ),
                ),
                const SizedBox(height: NutSpacing.small),
                Text(
                  streakDays.toString(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: palette.accentGold,
                        fontSize: 40,
                      ),
                ),
                const SizedBox(height: NutSpacing.small),
                Text(
                  l10n.relapseStreakRecapBody(streakDays),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: palette.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: NutSpacing.medium),
          StatCard(
            label: l10n.relapseLifetimeCleanDaysSaved,
            value: widget.streak.lifetimeCleanDays.toString(),
            icon: Icons.verified_outlined,
            accentColor: palette.success,
          ),
          const SizedBox(height: NutSpacing.medium),
          NutCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.relapseReflectionTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: NutSpacing.small),
                Text(
                  l10n.relapseReflectionBody,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: NutSpacing.medium),
                Wrap(
                  spacing: NutSpacing.small,
                  runSpacing: NutSpacing.small,
                  children: [
                    for (final trigger in triggers)
                      ChoiceChip(
                        label: Text(trigger),
                        selected: _selectedTriggers.contains(trigger),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTriggers.add(trigger);
                            } else {
                              _selectedTriggers.remove(trigger);
                            }
                          });
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: NutSpacing.large),
          NutPrimaryButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icons.arrow_forward,
            label: l10n.relapseKeepGoing,
          ),
          const SizedBox(height: NutSpacing.small),
          NutDestructiveButton(
            onPressed: _showResetConfirmation,
            icon: Icons.replay_outlined,
            label: l10n.relapseResetMyStreak,
          ),
          const SizedBox(height: NutSpacing.medium),
          Text(
            l10n.relapseFooter,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.textMuted,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
