import 'package:flutter/material.dart';

import '../../app/theme.dart';

class NutResponsiveListView extends StatelessWidget {
  const NutResponsiveListView({
    super.key,
    required this.children,
    this.padding,
    this.maxWidth,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= NutBreakpoints.medium;
        final horizontal = constraints.maxWidth >= NutBreakpoints.compact
            ? NutSpacing.xLarge
            : NutSpacing.screenHorizontal;
        final resolvedPadding = padding ??
            EdgeInsets.fromLTRB(
              horizontal,
              NutSpacing.screenTop,
              horizontal,
              NutSpacing.screenBottom,
            );

        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth ??
                    (isWide
                        ? NutBreakpoints.maxTabletContent
                        : NutBreakpoints.maxPhoneContent),
              ),
              child: ListView(
                padding: resolvedPadding,
                children: children,
              ),
            ),
          ),
        );
      },
    );
  }
}
