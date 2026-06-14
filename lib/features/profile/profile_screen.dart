import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../app/theme.dart';
import '../../l10n/l10n.dart';
import '../../shared/widgets/nut_button.dart';
import '../../shared/widgets/nut_card.dart';
import '../../shared/widgets/nut_pill.dart';
import '../../shared/widgets/responsive_page.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/stat_card.dart';
import '../streak/streak_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.streak,
    this.username,
    this.reason,
    required this.onOpenPaywall,
  });

  final StreakModel streak;
  final String? username;
  final String? reason;
  final VoidCallback onOpenPaywall;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayName = _displayUsername(l10n, username);
    final palette = context.nutPalette;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: NutResponsiveListView(
        children: [
          SectionHeader(
            title: l10n.profileUsername(displayName),
            subtitle: reason == null
                ? l10n.profileDefaultSubtitle
                : l10n.profileReasonSubtitle(reason!),
          ),
          const SizedBox(height: 24),
          if (reason != null) ...[
            NutCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  NutPill(
                    label: l10n.profileYourReason,
                    icon: Icons.flag_outlined,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      reason!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: l10n.profileCurrentStreakDays,
                  value: streak.currentStreakDays().toString(),
                  sublabel: l10n.homeDays,
                ),
              ),
              const SizedBox(width: NutSpacing.medium),
              Expanded(
                child: StatCard(
                  label: l10n.lifetimeCleanDays,
                  value: streak.lifetimeCleanDays.toString(),
                  sublabel: l10n.homeDaysClean,
                  valueColor: palette.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StatCard(
            label: l10n.profileTotalRelapses,
            value: streak.relapseCount.toString(),
            valueColor: palette.reset,
          ),
          const SizedBox(height: 24),
          NutCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NutPill(
                  label: l10n.profilePremium,
                  icon: Icons.auto_awesome,
                  backgroundColor: palette.premiumBg,
                  foregroundColor: palette.premium,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.profilePremiumTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.profilePremiumBody,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: palette.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),
                NutSecondaryButton(
                  onPressed: onOpenPaywall,
                  label: l10n.profileViewPremium,
                  foregroundColor: palette.premium,
                  borderColor: palette.premium.withOpacity(0.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _displayUsername(AppLocalizations l10n, String? username) {
  final value = username?.trim();
  if (value == null || value.isEmpty) return l10n.profileDefaultUsername;
  return value;
}
