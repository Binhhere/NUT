import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/l10n.dart';
import '../../shared/widgets/nut_card.dart';
import '../../shared/widgets/responsive_page.dart';
import '../../shared/widgets/section_header.dart';

class PrivacySafetyScreen extends StatelessWidget {
  const PrivacySafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.nutPalette;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: NutResponsiveListView(
        children: [
          NutCard(
            color: palette.accentBg.withOpacity(0.34),
            borderColor: palette.accentGold.withOpacity(0.22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: palette.accentGold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: palette.accentGold.withOpacity(0.22),
                    ),
                  ),
                  child: Icon(
                    Icons.verified_user_outlined,
                    color: palette.accentGold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.onboardingPrivacyConfirmTitle,
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.privacyLocalBody,
                        style: textTheme.bodySmall?.copyWith(
                          color: palette.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SmallSectionLabel(title: l10n.privacySectionPrivacy),
          const SizedBox(height: 8),
          NutCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PrivacyRow(
                  icon: Icons.phone_iphone_outlined,
                  title: l10n.privacyLocalTitle,
                  body: l10n.privacyLocalBody,
                ),
                Divider(color: palette.border, thickness: 0.5, height: 24),
                _PrivacyRow(
                  icon: Icons.cloud_off_outlined,
                  title: l10n.privacyNoAccountTitle,
                  body: l10n.privacyNoAccountBody,
                ),
                Divider(color: palette.border, thickness: 0.5, height: 24),
                _PrivacyRow(
                  icon: Icons.lock_outline,
                  title: l10n.privacyOptionalLockTitle,
                  body: l10n.privacyOptionalLockBody,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SmallSectionLabel(title: l10n.privacySectionSafety),
          const SizedBox(height: 8),
          NutCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.privacySafetyTitle,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.privacySafetyBody,
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SmallSectionLabel(title: l10n.privacySectionStore),
          const SizedBox(height: 8),
          NutCard(
            child: Text(
              l10n.privacyStoreBody,
              style: textTheme.bodySmall?.copyWith(
                color: palette.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _PrivacyRow extends StatelessWidget {
  const _PrivacyRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      label: '$title. $body',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: palette.accentBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: palette.accentGold.withOpacity(0.18)),
            ),
            child: Icon(icon, color: palette.accentGold, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
