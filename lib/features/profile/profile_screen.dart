import 'package:flutter/material.dart';

import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/stat_card.dart';
import '../streak/streak_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.streak,
    required this.onOpenPaywall,
  });

  final StreakModel streak;
  final VoidCallback onOpenPaywall;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionHeader(
            title: '@you',
            subtitle: 'Private local profile for the MVP.',
          ),
          const SizedBox(height: 20),
          StatCard(
            label: 'Current streak days',
            value: streak.currentStreakDays().toString(),
            icon: Icons.local_fire_department_outlined,
          ),
          const SizedBox(height: 12),
          StatCard(
            label: 'Lifetime clean days',
            value: streak.lifetimeCleanDays.toString(),
            icon: Icons.favorite_outline,
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Premium placeholder',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Journal, analytics, stats, notifications, widgets, and themes will live here later.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton(
                    onPressed: onOpenPaywall,
                    child: const Text('View premium'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
