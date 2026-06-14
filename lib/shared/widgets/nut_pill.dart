import 'package:flutter/material.dart';

import '../../app/theme.dart';

class NutPill extends StatelessWidget {
  const NutPill({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });

  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;
    final bg = backgroundColor ?? palette.accentBg;
    final fg = foregroundColor ?? palette.accentGold;
    final border = borderColor ?? fg.withOpacity(0.25);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(NutRadius.pill),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: fg,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.22,
                ),
          ),
        ],
      ),
    );
  }
}
