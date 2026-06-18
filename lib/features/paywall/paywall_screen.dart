import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/l10n.dart';
import '../../shared/widgets/nut_button.dart';
import '../../shared/widgets/nut_card.dart';
import '../../shared/widgets/nut_pill.dart';
import '../../shared/widgets/responsive_page.dart';
import '../analytics/relapse_analytics_screen.dart';
import '../journal/journal_screen.dart';
import '../streak/streak_model.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key, this.streak});

  /// Optional — when provided, the Relapse analytics preview can show
  /// real (free) numbers instead of zeroed placeholders.
  final StreakModel? streak;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.nutPalette;
    final features = <_PaywallFeature>[
      _PaywallFeature(
        label: l10n.paywallFeatureJournal,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => JournalScreen(onOpenPaywall: () {}),
          ),
        ),
      ),
      _PaywallFeature(
        label: l10n.paywallFeatureRelapseAnalytics,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => RelapseAnalyticsScreen(
              streak: streak ?? const StreakModel(startDate: null, lifetimeCleanDays: 0),
              onOpenPaywall: () {},
            ),
          ),
        ),
      ),
      _PaywallFeature(label: l10n.paywallFeatureAdvancedStats),
      _PaywallFeature(label: l10n.paywallFeatureCustomNotifications),
      _PaywallFeature(label: l10n.paywallFeatureWidgetsThemes),
    ];

    // TODO: Wire these plans to RevenueCat or platform billing after MVP validation.
    return Scaffold(
      body: NutResponsiveListView(
        children: [
          NutCard(
            color: palette.premiumSurface,
            borderColor: palette.premium.withOpacity(0.34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NutPill(
                  label: l10n.paywallPremiumPlaceholder,
                  icon: Icons.auto_awesome,
                  backgroundColor: palette.premiumBg,
                  foregroundColor: palette.premium,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.paywallHeadline,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.paywallBody,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: palette.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          NutCard(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              children: [
                for (final feature in features)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.check_circle_outline,
                      color: palette.premium,
                    ),
                    title: Text(feature.label),
                    trailing: feature.onTap == null
                        ? null
                        : Icon(
                            Icons.chevron_right,
                            color: palette.textMuted,
                          ),
                    onTap: feature.onTap,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _PriceCard(
            title: l10n.paywallMonthlyTitle,
            price: l10n.paywallMonthlyPrice,
            caption: l10n.paywallMonthlyCaption,
            isPrimary: false,
          ),
          const SizedBox(height: 16),
          _PriceCard(
            title: l10n.paywallYearlyTitle,
            price: l10n.paywallYearlyPrice,
            caption: l10n.paywallYearlyCaption,
            isPrimary: true,
          ),
        ],
      ),
    );
  }
}

class _PaywallFeature {
  const _PaywallFeature({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.title,
    required this.price,
    required this.caption,
    required this.isPrimary,
  });

  final String title;
  final String price;
  final String caption;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;

    return NutCard(
      borderColor: isPrimary ? palette.premium.withOpacity(0.5) : null,
      color: isPrimary ? palette.premiumSurface : palette.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (isPrimary)
                NutPill(
                  label: context.l10n.paywallPopular,
                  backgroundColor: palette.premiumBg,
                  foregroundColor: palette.premium,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: palette.premium,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          NutSecondaryButton(
            onPressed: () {},
            label: context.l10n.paywallComingSoon,
            foregroundColor: palette.premium,
            borderColor: palette.premium.withOpacity(0.45),
          ),
        ],
      ),
    );
  }
}
