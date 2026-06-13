import 'package:flutter/material.dart';

import '../../app/theme.dart';

class NutCard extends StatelessWidget {
  const NutCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? palette.card,
        borderRadius: BorderRadius.circular(NutRadius.card),
        border: Border.all(color: borderColor ?? palette.border, width: 1),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
