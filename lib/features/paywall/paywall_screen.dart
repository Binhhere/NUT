import 'package:flutter/material.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  static const _features = [
    'Journal',
    'Relapse analytics',
    'Advanced stats',
    'Custom notifications',
    'Premium widgets/themes',
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: Wire these plans to RevenueCat or platform billing after MVP validation.
    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Build deeper insight into your recovery.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Placeholder only. RevenueCat or native billing can be integrated after the MVP loop is validated.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (final feature in _features)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(feature),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _PriceCard(
            title: 'Monthly',
            price: r'$4.99/month',
            isPrimary: false,
          ),
          const SizedBox(height: 12),
          const _PriceCard(
            title: 'Yearly',
            price: r'$29.99/year',
            isPrimary: true,
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.title,
    required this.price,
    required this.isPrimary,
  });

  final String title;
  final String price;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: isPrimary ? colorScheme.primaryContainer : null,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(price),
        trailing: FilledButton(
          onPressed: () {},
          child: const Text('Coming soon'),
        ),
      ),
    );
  }
}
