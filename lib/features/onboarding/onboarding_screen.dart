import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/l10n.dart';
import '../../shared/widgets/nut_button.dart';
import '../../shared/widgets/nut_card.dart';
import '../../shared/widgets/nut_pill.dart';
import '../../shared/widgets/responsive_page.dart';
import 'onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  final Future<void> Function(OnboardingProfile profile) onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _usernameController = TextEditingController();
  String? _selectedReason;
  bool _isSaving = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _complete({bool skipped = false}) async {
    setState(() => _isSaving = true);

    final username = skipped ? null : _usernameController.text.trim();

    await widget.onComplete(
      OnboardingProfile(
        hasSeenOnboarding: true,
        username: username == null || username.isEmpty ? null : username,
        reason: skipped ? null : _selectedReason,
      ),
    );

    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.nutPalette;
    final reasons = [
      l10n.onboardingReasonFocus,
      l10n.onboardingReasonConfidence,
      l10n.onboardingReasonDiscipline,
      l10n.onboardingReasonEnergy,
      l10n.onboardingReasonJustTrying,
    ];

    return Scaffold(
      body: SafeArea(
        child: NutResponsiveListView(
          children: [
            const SizedBox(height: 24),
            NutPill(
              label: l10n.onboardingWelcome,
              icon: Icons.nightlight_outlined,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.onboardingHeadline,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.onboardingBody,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            NutCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.onboardingUsernameQuestion,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _usernameController,
                    enabled: !_isSaving,
                    maxLength: 24,
                    textInputAction: TextInputAction.done,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: l10n.onboardingUsernameHint,
                      hintStyle:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: palette.textMuted,
                              ),
                      filled: true,
                      fillColor: palette.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(NutRadius.button),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(NutRadius.button),
                        borderSide: BorderSide(color: palette.accentGold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.onboardingOptionalReason,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.onboardingReasonHelper,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final reason in reasons)
                        _ReasonChoice(
                          label: reason,
                          selected: reason == _selectedReason,
                          onTap: _isSaving
                              ? null
                              : () {
                                  setState(() {
                                    _selectedReason = reason == _selectedReason
                                        ? null
                                        : reason;
                                  });
                                },
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            NutPrimaryButton(
              onPressed: _isSaving ? null : _complete,
              label: l10n.onboardingContinue,
              icon: Icons.arrow_forward,
            ),
            const SizedBox(height: 8),
            NutGhostButton(
              onPressed: _isSaving ? null : () => _complete(skipped: true),
              label: l10n.onboardingSkip,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonChoice extends StatelessWidget {
  const _ReasonChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(NutRadius.pill),
      child: NutPill(
        label: label,
        icon: selected ? Icons.check : null,
        backgroundColor: selected ? palette.accentBg : palette.surface,
        foregroundColor: selected ? palette.accentGold : palette.textSecondary,
      ),
    );
  }
}
