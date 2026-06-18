import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/l10n.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;

    return Scaffold(
      backgroundColor: palette.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.appTitle,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: palette.accentGold,
                    fontSize: 48,
                    letterSpacing: 1.5,
                  ),
            ),
            const SizedBox(height: NutSpacing.small),
            Container(
              width: 44,
              height: 2,
              decoration: BoxDecoration(
                color: palette.accentGold.withOpacity(0.7),
                borderRadius: BorderRadius.circular(NutRadius.pill),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
