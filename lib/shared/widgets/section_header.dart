import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Screen-level title, used at the top of a full screen.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.textSecondary,
                ),
          ),
        ],
      ],
    );
  }
}

/// Small in-screen section label matching the HTML `.sh` style.
class SmallSectionLabel extends StatelessWidget {
  const SmallSectionLabel({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: palette.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 10,
                letterSpacing: 1.3,
              ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
