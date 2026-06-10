import 'dart:async';

import 'package:flutter/material.dart';

import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/stat_card.dart';
import 'streak_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.streak,
    required this.onStartStreak,
    required this.onResetStreak,
  });

  final StreakModel streak;
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

    return Scaffold(
      appBar: AppBar(title: const Text('NUT')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionHeader(
            title: 'Protect today.',
            subtitle: 'A small, steady streak is still worth protecting.',
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.streak.hasStarted
                        ? 'Current streak'
                        : 'Ready when you are',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _TimeBlock(value: days.toString(), label: 'days'),
                      _TimeBlock(
                          value: hours.toString().padLeft(2, '0'),
                          label: 'hours'),
                      _TimeBlock(
                          value: minutes.toString().padLeft(2, '0'),
                          label: 'min'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (widget.streak.hasStarted)
                    Text(
                      'You do not need a perfect week. You only need the next right choice.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    Text(
                      'Start a streak to begin tracking your progress privately on this device.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          StatCard(
            label: 'Lifetime clean days',
            value: widget.streak.lifetimeCleanDays.toString(),
            icon: Icons.favorite_outline,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _isBusy ? null : () => _runAction(widget.onStartStreak),
            icon: const Icon(Icons.play_arrow),
            label: Text(
                widget.streak.hasStarted ? 'Restart streak' : 'Start streak'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _isBusy || !widget.streak.hasStarted
                ? null
                : () => _runAction(widget.onResetStreak),
            icon: const Icon(Icons.refresh),
            label: const Text('I relapsed, reset with support'),
          ),
        ],
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  const _TimeBlock({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
