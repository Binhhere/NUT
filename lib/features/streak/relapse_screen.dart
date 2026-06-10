import 'package:flutter/material.dart';

import '../../shared/widgets/stat_card.dart';
import 'streak_model.dart';

class RelapseScreen extends StatelessWidget {
  const RelapseScreen({super.key, required this.streak});

  final StreakModel streak;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset complete')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(
            Icons.self_improvement,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            'This is a restart, not a failure.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Notice what happened, protect the next hour, and keep going. Your effort still counts.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          StatCard(
            label: 'Lifetime clean days saved',
            value: streak.lifetimeCleanDays.toString(),
            icon: Icons.favorite,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to my streak'),
          ),
        ],
      ),
    );
  }
}
