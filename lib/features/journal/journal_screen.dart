// lib/features/journal/journal_screen.dart
//
// Wave 2 — Premium feature. Gated sau paywall.
// Hiện tại: placeholder scaffold với paywall CTA.
// Wave 2: thêm JournalEntry model, JournalService (SharedPreferences),
//         text editor, entry list, mood tags.

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/l10n.dart';
import '../../shared/widgets/nut_button.dart';
import '../../shared/widgets/nut_card.dart';
import '../../shared/widgets/nut_pill.dart';
import '../../shared/widgets/responsive_page.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({
    super.key,
    this.onOpenPaywall,
  });

  final VoidCallback? onOpenPaywall;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.nutPalette;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.journalTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: NutPill(
              label: l10n.profilePremium,
              icon: Icons.auto_awesome,
              backgroundColor: palette.premiumBg,
              foregroundColor: palette.premium,
            ),
          ),
        ],
      ),
      body: NutResponsiveListView(
        children: [
          // ── Header card ──────────────────────────────
          NutCard(
            color: palette.premiumSurface,
            borderColor: palette.premium.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.book_outlined, color: palette.premium, size: 32),
                const SizedBox(height: 12),
                Text(l10n.journalPrivateTitle, style: textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  l10n.journalPrivateBody,
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Locked preview entries ───────────────────
          _LockedEntry(
            palette: palette,
            textTheme: textTheme,
            label: l10n.journalPreviewDaySeven,
          ),
          const SizedBox(height: 10),
          _LockedEntry(
            palette: palette,
            textTheme: textTheme,
            label: l10n.journalPreviewDayFour,
          ),
          const SizedBox(height: 10),
          _LockedEntry(
            palette: palette,
            textTheme: textTheme,
            label: l10n.journalPreviewDayOne,
          ),
          const SizedBox(height: 24),

          // ── CTA ─────────────────────────────────────
          NutSecondaryButton(
            label: l10n.journalUnlockCta,
            foregroundColor: palette.premium,
            borderColor: palette.premium.withOpacity(0.4),
            onPressed: onOpenPaywall,
          ),
        ],
      ),
    );
  }
}

class _LockedEntry extends StatelessWidget {
  const _LockedEntry({
    required this.palette,
    required this.textTheme,
    required this.label,
  });

  final NutPalette palette;
  final TextTheme textTheme;
  final String label;

  @override
  Widget build(BuildContext context) {
    return NutCard(
      color: palette.surface,
      borderColor: palette.border,
      child: Row(
        children: [
          Icon(Icons.lock_outline, size: 16, color: palette.textMuted),
          const SizedBox(width: 10),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(color: palette.textMuted),
          ),
        ],
      ),
    );
  }
}
