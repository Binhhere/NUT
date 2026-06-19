import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'nut_card.dart';

/// Vertical stat card matching the HTML home stats:
/// small uppercase label, large value, optional muted sublabel.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.sublabel,
    this.valueColor,
    this.onTap,
  });

  final String label;
  final String value;
  final String? sublabel;
  final Color? valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;
    final color = valueColor ?? palette.accentGold;
    final semanticsLabel = [
      label,
      value,
      if (sublabel != null) sublabel!,
    ].join(', ');

    return Semantics(
      container: true,
      button: onTap != null,
      label: semanticsLabel,
      child: GestureDetector(
        onTap: onTap,
        child: NutCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          borderColor: valueColor == null ? null : color.withOpacity(0.22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: palette.textMuted,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: color,
                  height: 1.05,
                ),
              ),
              if (sublabel != null) ...[
                const SizedBox(height: 3),
                Text(
                  sublabel!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: palette.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
