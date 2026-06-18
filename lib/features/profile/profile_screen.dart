import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/l10n.dart';
import '../../shared/widgets/nut_button.dart';
import '../../shared/widgets/nut_card.dart';
import '../../shared/widgets/nut_pill.dart';
import '../../shared/widgets/responsive_page.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/stat_card.dart';
import '../analytics/relapse_analytics_screen.dart';
import '../journal/journal_screen.dart';
import '../streak/streak_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.streak,
    this.username,
    this.reason,
    required this.onOpenPaywall,
    required this.onOpenSettings,
  });

  final StreakModel streak;
  final String? username;
  final String? reason;
  final VoidCallback onOpenPaywall;
  final VoidCallback onOpenSettings;

  void _openJournal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JournalScreen(onOpenPaywall: onOpenPaywall),
      ),
    );
  }

  void _openAnalytics(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RelapseAnalyticsScreen(
          streak: streak,
          onOpenPaywall: onOpenPaywall,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayName = _displayUsername(context, username);
    final hasUsername = _hasUsername(username);
    final palette = context.nutPalette;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: onOpenSettings,
          ),
        ],
      ),
      body: NutResponsiveListView(
        children: [
          SectionHeader(
            title: hasUsername
                ? l10n.profileUsername(displayName)
                : l10n.profileAnonymousUsername,
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
                  valueColor: _statColor(
                    streak.currentStreakDays(),
                    palette.accentGold,
                    palette.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: NutSpacing.medium),
              Expanded(
                child: StatCard(
                  label: l10n.lifetimeCleanDays,
                  value: streak.lifetimeCleanDays.toString(),
                  sublabel: l10n.homeDaysClean,
                  valueColor: _statColor(
                    streak.lifetimeCleanDays,
                    palette.success,
                    palette.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StatCard(
            label: l10n.profileTotalRelapses,
            value: streak.relapseCount.toString(),
            valueColor: _statColor(
              streak.relapseCount,
              palette.reset,
              palette.textMuted,
            ),
          ),
          const SizedBox(height: 24),

          // ── Premium tools — Journal + Analytics entry points ──────
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

                // Journal entry point
                _PremiumFeatureRow(
                  icon: Icons.book_outlined,
                  label: l10n.paywallFeatureJournal,
                  onTap: () => _openJournal(context),
                  palette: palette,
                ),
                const SizedBox(height: 10),

                // Analytics entry point
                _PremiumFeatureRow(
                  icon: Icons.bar_chart_outlined,
                  label: l10n.paywallFeatureRelapseAnalytics,
                  onTap: () => _openAnalytics(context),
                  palette: palette,
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

class _PremiumFeatureRow extends StatelessWidget {
  const _PremiumFeatureRow({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.palette,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final NutPalette palette;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(NutRadius.card),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: palette.premiumSurface,
          borderRadius: BorderRadius.circular(NutRadius.card),
          border: Border.all(color: palette.premium.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: palette.premium),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.textPrimary,
                    ),
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: palette.textMuted),
          ],
        ),
      ),
    );
  }
}

bool _hasUsername(String? username) {
  final value = username?.trim();
  return value != null && value.isNotEmpty;
}

String _displayUsername(BuildContext context, String? username) {
  final l10n = context.l10n;
  final value = username?.trim();
  if (value == null || value.isEmpty) return l10n.profileAnonymousUsername;
  return value;
}

Color _statColor(int value, Color accent, Color muted) {
  return value == 0 ? muted : accent;
}
