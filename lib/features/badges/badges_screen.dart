import 'package:flutter/material.dart';

import '../../shared/widgets/section_header.dart';
import '../streak/streak_model.dart';
import 'badge_model.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key, required this.streak});

  final StreakModel streak;

  static const _badges = [
    BadgeModel(
      title: 'First Week',
      requiredDays: 7,
      description: 'Seven steady days.',
    ),
    BadgeModel(
      title: 'Thirty Days',
      requiredDays: 30,
      description: 'A month of protecting your progress.',
    ),
    BadgeModel(
      title: 'Ninety Days',
      requiredDays: 90,
      description: 'A major reset window.',
    ),
    BadgeModel(
      title: 'One Year',
      requiredDays: 365,
      description: 'A long-term identity shift.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentDays = streak.currentStreakDays();

    return Scaffold(
      appBar: AppBar(title: const Text('Badges')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const SectionHeader(
              title: 'Milestones',
              subtitle: 'Badges unlock from your current streak.',
            );
          }

          return _BadgeCard(
            badge: _badges[index - 1],
            currentDays: currentDays,
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: _badges.length + 1,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: unlocked
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              child: Icon(
                unlocked ? Icons.verified : Icons.lock_outline,
                color: unlocked
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badge.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${badge.requiredDays} days - ${badge.description}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
