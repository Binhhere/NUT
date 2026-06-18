// lib/features/journal/journal_screen.dart
//
// Wave 2 — Premium feature. Gated sau paywall.
// Hiện tại: placeholder scaffold với paywall CTA.
// Wave 2: thêm JournalEntry model, JournalService (SharedPreferences),
//         text editor, entry list, mood tags.

import 'package:flutter/material.dart';

import '../../app/theme.dart';
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
    final palette = context.nutPalette;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: NutPill(
              label: 'Premium',
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
                Text('Private journal', style: textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  'Write short reflections to notice patterns and build self-awareness over time.',
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
            label: 'Day 7 · What helped today',
          ),
          const SizedBox(height: 10),
          _LockedEntry(
            palette: palette,
            textTheme: textTheme,
            label: 'Day 4 · Noticed a trigger',
          ),
          const SizedBox(height: 10),
          _LockedEntry(
            palette: palette,
            textTheme: textTheme,
            label: 'Day 1 · First reflection',
          ),
          const SizedBox(height: 24),

          // ── CTA ─────────────────────────────────────
          NutSecondaryButton(
            label: 'Unlock journal — Coming soon',
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
