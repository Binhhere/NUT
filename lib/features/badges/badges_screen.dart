// lib/features/badges/badges_screen.dart
//
// Layout: 2-column grid, match HTML v5 Screen 08.
// Visual: emoji ring (SVG-style CustomPaint) thay vì Icons.verified.
// Unlocked badge: gold ring + top shimmer line, locked: muted ring.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/l10n.dart';
import '../../shared/widgets/nut_card.dart';
import '../../shared/widgets/nut_pill.dart';
import '../../shared/widgets/responsive_page.dart';
import '../../shared/widgets/section_header.dart';
import '../streak/streak_model.dart';
import 'badge_model.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key, required this.streak});

  final StreakModel streak;

  @override
  Widget build(BuildContext context) {
    final currentDays = streak.currentStreakDays();
    final l10n = context.l10n;

    final badges = [
      BadgeModel(
        id: 'first_week',
        emoji: '🌱',
        title: l10n.badgeFirstWeekTitle,
        requiredDays: 7,
        description: l10n.badgeFirstWeekDescription,
      ),
      BadgeModel(
        id: 'thirty_days',
        emoji: '🔥',
        title: l10n.badgeThirtyDaysTitle,
        requiredDays: 30,
        description: l10n.badgeThirtyDaysDescription,
      ),
      BadgeModel(
        id: 'ninety_days',
        emoji: '⚡',
        title: l10n.badgeNinetyDaysTitle,
        requiredDays: 90,
        description: l10n.badgeNinetyDaysDescription,
      ),
      BadgeModel(
        id: 'one_year',
        emoji: '🏆',
        title: l10n.badgeOneYearTitle,
        requiredDays: 365,
        description: l10n.badgeOneYearDescription,
      ),
    ];

    return Scaffold(
      body: NutResponsiveListView(
        children: [
          SectionHeader(
            title: l10n.badgesHeaderTitle,
            subtitle: l10n.badgesHeaderSubtitle,
          ),
          const SizedBox(height: NutSpacing.large),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) => _BadgeCard(
              badge: badges[index],
              currentDays: currentDays,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Badge card
// ─────────────────────────────────────────────────────────────

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.badge,
    required this.currentDays,
  });

  final BadgeModel badge;
  final int currentDays;

  @override
  Widget build(BuildContext context) {
    final unlocked = badge.isUnlocked(currentDays);
    final remaining =
        (badge.requiredDays - currentDays).clamp(0, badge.requiredDays);
    final progress = (currentDays / badge.requiredDays).clamp(0.0, 1.0);
    final l10n = context.l10n;
    final palette = context.nutPalette;

    return Stack(
      children: [
        NutCard(
          padding: const EdgeInsets.fromLTRB(14, 20, 14, 16),
          borderColor:
              unlocked ? palette.accentGold.withOpacity(0.22) : palette.border,
          color: unlocked ? palette.accentBg.withOpacity(0.35) : palette.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Emoji ring ───────────────────────────
              _EmojiRing(
                emoji: badge.emoji,
                progress: progress,
                unlocked: unlocked,
                palette: palette,
              ),
              const SizedBox(height: 12),

              // ── Title ────────────────────────────────
              Text(
                badge.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14,
                    ),
              ),
              const SizedBox(height: 5),

              // ── Description ──────────────────────────
              Text(
                badge.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.textSecondary,
                      fontSize: 11,
                    ),
              ),

              const Spacer(),

              // ── Status pill ──────────────────────────
              NutPill(
                label: unlocked
                    ? l10n.badgeUnlocked
                    : l10n.badgeDaysLeft(remaining),
                backgroundColor: unlocked ? palette.accentBg : palette.surface,
                foregroundColor:
                    unlocked ? palette.accentGold : palette.textMuted,
                borderColor: unlocked
                    ? palette.accentGold.withOpacity(0.28)
                    : palette.border,
              ),
            ],
          ),
        ),

        // ── Top shimmer line (unlocked only) — match HTML ::before ──
        if (unlocked)
          Positioned(
            top: 0,
            left: 1,
            right: 1,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(NutRadius.card),
              ),
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      palette.accentGold.withOpacity(0.45),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Emoji ring — match HTML .badge-ring-outer / SVG ring
// ─────────────────────────────────────────────────────────────

class _EmojiRing extends StatelessWidget {
  const _EmojiRing({
    required this.emoji,
    required this.progress,
    required this.unlocked,
    required this.palette,
  });

  final String emoji;
  final double progress;
  final bool unlocked;
  final NutPalette palette;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(64),
            painter: _RingPainter(
              progress: progress,
              unlocked: unlocked,
              trackColor: palette.surface,
              progressColor: unlocked
                  ? palette.accentGold
                  : palette.accentGold.withOpacity(0.4),
            ),
          ),
          Text(emoji, style: const TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.unlocked,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final bool unlocked;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Track
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final sweep = math.pi * 2 * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweep,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress ||
      old.unlocked != unlocked ||
      old.trackColor != trackColor ||
      old.progressColor != progressColor;
}
