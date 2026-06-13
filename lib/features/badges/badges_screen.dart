import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/l10n.dart';
import '../../shared/widgets/nut_card.dart';
import '../../shared/widgets/nut_pill.dart';
import '../../shared/widgets/responsive_page.dart';
import '../../shared/widgets/section_header.dart';
import '../streak/streak_model.dart';
import 'badge_model.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key, required this.streak});

  final StreakModel streak;

  @override
  Widget build(BuildContext context) {
    final currentDays = streak.currentStreakDays();
    final l10n = context.l10n;
    final badges = [
      BadgeModel(
        title: l10n.badgeFirstWeekTitle,
        requiredDays: 7,
        description: l10n.badgeFirstWeekDescription,
      ),
      BadgeModel(
        title: l10n.badgeThirtyDaysTitle,
        requiredDays: 30,
        description: l10n.badgeThirtyDaysDescription,
      ),
      BadgeModel(
        title: l10n.badgeNinetyDaysTitle,
        requiredDays: 90,
        description: l10n.badgeNinetyDaysDescription,
      ),
      BadgeModel(
        title: l10n.badgeOneYearTitle,
        requiredDays: 365,
        description: l10n.badgeOneYearDescription,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.badgesTitle)),
      body: NutResponsiveListView(
        children: [
          SectionHeader(
            title: l10n.badgesHeaderTitle,
            subtitle: l10n.badgesHeaderSubtitle,
          ),
          const SizedBox(height: NutSpacing.large),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: NutSpacing.medium,
              crossAxisSpacing: NutSpacing.medium,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              return _BadgeCard(
                badge: badges[index],
                currentDays: currentDays,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.badge,
    required this.currentDays,
  });

  final BadgeModel badge;
  final int currentDays;

  @override
  Widget build(BuildContext context) {
    final unlocked = badge.isUnlocked(currentDays);
    final remainingDays =
        (badge.requiredDays - currentDays).clamp(0, badge.requiredDays);
    final l10n = context.l10n;
    final palette = context.nutPalette;

    return NutCard(
      padding: const EdgeInsets.all(16),
      borderColor: unlocked ? palette.success.withOpacity(0.55) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: unlocked
                    ? palette.success.withOpacity(0.16)
                    : palette.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: unlocked ? palette.success : palette.border,
                ),
              ),
              child: Icon(
                unlocked ? Icons.verified : Icons.lock_outline,
                color: unlocked ? palette.success : palette.textMuted,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: NutSpacing.medium),
          Text(
            badge.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: NutSpacing.small),
          Text(
            l10n.badgeDetail(badge.requiredDays, badge.description),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.textSecondary,
                ),
          ),
          const Spacer(),
          NutPill(
            label: unlocked
                ? l10n.badgeUnlocked
                : l10n.badgeDaysLeft(remainingDays),
            backgroundColor:
                unlocked ? palette.success.withOpacity(0.14) : palette.surface,
            foregroundColor: unlocked ? palette.success : palette.textSecondary,
          ),
        ],
      ),
    );
  }
}
