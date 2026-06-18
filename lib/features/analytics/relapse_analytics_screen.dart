// lib/features/analytics/relapse_analytics_screen.dart
//
// Wave 2 — Premium feature. Gated sau paywall.
// Hiện tại: placeholder scaffold với locked preview stats.
// Wave 2: thêm RelapseEvent model, chart theo tuần/tháng,
//         trigger frequency chart, streak history list.

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../features/streak/streak_model.dart';
import '../../shared/widgets/nut_button.dart';
import '../../shared/widgets/nut_card.dart';
import '../../shared/widgets/nut_pill.dart';
import '../../shared/widgets/responsive_page.dart';
import '../../shared/widgets/stat_card.dart';

class RelapseAnalyticsScreen extends StatelessWidget {
  const RelapseAnalyticsScreen({
    super.key,
    required this.streak,
    this.onOpenPaywall,
  });

  final StreakModel streak;
  final VoidCallback? onOpenPaywall;

  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: NutPill(
              label: 'Premium',
              icon: Icons.auto_awesome,
              backgroundColor: palette.premiumBg,
              foregroundColor: palette.premium,
            ),
          ),
        ],
      ),
      body: NutResponsiveListView(
        children: [
          // ── Stats row (live data, free) ──────────────
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Total resets',
                  value: '${streak.relapseCount}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: 'Best streak',
                  value: '${streak.effectiveBestStreak}d',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Lifetime clean',
                  value: '${streak.lifetimeCleanDays}d',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: 'Current streak',
                  value: '${streak.currentStreakDays()}d',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Locked premium section ───────────────────
          NutCard(
            color: palette.premiumSurface,
            borderColor: palette.premium.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bar_chart_outlined,
                        color: palette.premium, size: 20),
                    const SizedBox(width: 8),
                    Text('Pattern analysis', style: textTheme.titleMedium),
                    const Spacer(),
                    Icon(Icons.lock_outline,
                        color: palette.textMuted, size: 16),
                  ],
                ),
                const SizedBox(height: 12),
                _LockedChartPlaceholder(palette: palette),
                const SizedBox(height: 12),
                Text(
                  'See which days and triggers correlate with resets. Available in Premium.',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Trigger frequency (locked) ───────────────
          NutCard(
            color: palette.premiumSurface,
            borderColor: palette.premium.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology_outlined,
                        color: palette.premium, size: 20),
                    const SizedBox(width: 8),
                    Text('Top triggers', style: textTheme.titleMedium),
                    const Spacer(),
                    Icon(Icons.lock_outline,
                        color: palette.textMuted, size: 16),
                  ],
                ),
                const SizedBox(height: 12),
                for (final label in ['Late night', 'Stress', 'Boredom'])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _LockedBar(
                        palette: palette,
                        textTheme: textTheme,
                        label: label),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── CTA ─────────────────────────────────────
          NutSecondaryButton(
            label: 'Unlock analytics — Coming soon',
            foregroundColor: palette.premium,
            borderColor: palette.premium.withOpacity(0.4),
            onPressed: onOpenPaywall,
          ),
        ],
      ),
    );
  }
}

class _LockedChartPlaceholder extends StatelessWidget {
  const _LockedChartPlaceholder({required this.palette});

  final NutPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: palette.premiumBg,
        borderRadius: BorderRadius.circular(NutRadius.card),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final h in [0.4, 0.7, 0.3, 0.9, 0.5, 0.6, 0.2])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: 20,
                height: 60 * h,
                decoration: BoxDecoration(
                  color: palette.premium.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LockedBar extends StatelessWidget {
  const _LockedBar({
    required this.palette,
    required this.textTheme,
    required this.label,
  });

  final NutPalette palette;
  final TextTheme textTheme;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(color: palette.textMuted),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: palette.premium.withOpacity(0.15),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ],
    );
  }
}
