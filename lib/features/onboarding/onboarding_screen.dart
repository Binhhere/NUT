// lib/features/onboarding/onboarding_screen.dart
//
// 3 steps match HTML v5:
//   Step 1 — Name (username input)
//   Step 2 — Reason (multi-select pills)
//   Step 3 — Ready (streak counter = 0, "Start my streak" CTA)
//
// Progress bar animate theo step. PageView + AnimatedSwitcher.
// Step 3 không có "Skip" — user phải tap "Start my streak".

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/l10n.dart';
import '../../shared/widgets/nut_button.dart';
import '../../shared/widgets/nut_card.dart';
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

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _step = 0; // 0, 1, 2

  // Step 1
  final _usernameController = TextEditingController();

  // Step 2
  String? _selectedReason;

  bool _isSaving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
      _pageController.animateToPage(
        _step,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() => _next();

  Future<void> _finish() async {
    setState(() => _isSaving = true);
    final username = _usernameController.text.trim();
    await widget.onComplete(
      OnboardingProfile(
        hasSeenOnboarding: true,
        username: username.isEmpty ? null : username,
        reason: _selectedReason,
      ),
    );
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress bar ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NutSpacing.screenHorizontal,
                20,
                NutSpacing.screenHorizontal,
                0,
              ),
              child: _ProgressBar(step: _step, total: 3),
            ),

            // ── Pages ─────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step1Name(
                    controller: _usernameController,
                    onContinue: _next,
                    onSkip: _skip,
                    palette: palette,
                  ),
                  _Step2Reason(
                    selectedReason: _selectedReason,
                    onReasonChanged: (r) => setState(() => _selectedReason = r),
                    onContinue: _next,
                    onSkip: _skip,
                    palette: palette,
                  ),
                  _Step3Ready(
                    isSaving: _isSaving,
                    onStart: _finish,
                    palette: palette,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Progress bar
// ─────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;

    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              height: 2,
              decoration: BoxDecoration(
                color: i <= step ? palette.accentGold : palette.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          if (i < total - 1) const SizedBox(width: 5),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step 1 — Name
// ─────────────────────────────────────────────────────────────

class _Step1Name extends StatelessWidget {
  const _Step1Name({
    required this.controller,
    required this.onContinue,
    required this.onSkip,
    required this.palette,
  });

  final TextEditingController controller;
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final NutPalette palette;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        NutSpacing.screenHorizontal,
        28,
        NutSpacing.screenHorizontal,
        NutSpacing.screenBottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step label — via l10n
          Text(
            l10n.onboardingStepLabel(1, 3),
            style: TextStyle(
              fontSize: 10,
              color: palette.textMuted,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),

          Text(
            l10n.onboardingStep1Title,
            style: textTheme.headlineSmall?.copyWith(
              fontSize: 28,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingStep1Subtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: palette.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),

          NutCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.onboardingStep1InputLabel,
                  style: TextStyle(
                    fontSize: 10,
                    color: palette.textMuted,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: controller,
                  maxLength: 24,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onContinue(),
                  style: textTheme.bodyMedium,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: l10n.onboardingStep1InputHint,
                    hintStyle: textTheme.bodyMedium
                        ?.copyWith(color: palette.textMuted),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(l10n.onboardingStep1Note, style: textTheme.bodySmall),
          const SizedBox(height: 40),

          NutPrimaryButton(
            label: l10n.onboardingContinue,
            icon: Icons.arrow_forward,
            onPressed: onContinue,
          ),
          const SizedBox(height: 8),
          NutGhostButton(
            label: l10n.onboardingSkip,
            onPressed: onSkip,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step 2 — Reason
// ─────────────────────────────────────────────────────────────

class _Step2Reason extends StatelessWidget {
  const _Step2Reason({
    required this.selectedReason,
    required this.onReasonChanged,
    required this.onContinue,
    required this.onSkip,
    required this.palette,
  });

  final String? selectedReason;
  final ValueChanged<String?> onReasonChanged;
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final NutPalette palette;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final reasons = [
      l10n.onboardingReasonFocus,
      l10n.onboardingReasonConfidence,
      l10n.onboardingReasonDiscipline,
      l10n.onboardingReasonEnergy,
      l10n.onboardingReasonJustTrying,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        NutSpacing.screenHorizontal,
        28,
        NutSpacing.screenHorizontal,
        NutSpacing.screenBottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingStepLabel(2, 3),
            style: TextStyle(
              fontSize: 10,
              color: palette.textMuted,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.onboardingStep2Title,
            style: textTheme.headlineSmall?.copyWith(
              fontSize: 28,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingStep2Subtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: palette.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final reason in reasons)
                _ReasonPill(
                  label: reason,
                  selected: reason == selectedReason,
                  palette: palette,
                  onTap: () => onReasonChanged(
                    reason == selectedReason ? null : reason,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 40),
          NutPrimaryButton(
            label: l10n.onboardingContinue,
            icon: Icons.arrow_forward,
            onPressed: onContinue,
          ),
          const SizedBox(height: 8),
          NutGhostButton(
            label: l10n.onboardingSkip,
            onPressed: onSkip,
          ),
        ],
      ),
    );
  }
}

class _ReasonPill extends StatelessWidget {
  const _ReasonPill({
    required this.label,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final NutPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? palette.accentBg : palette.surface,
            borderRadius: BorderRadius.circular(NutRadius.pill),
            border: Border.all(
              color: selected
                  ? palette.accentGold.withOpacity(0.46)
                  : palette.border,
              width: selected ? 1 : 0.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? palette.accentGold : palette.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step 3 — Ready
// ─────────────────────────────────────────────────────────────

class _Step3Ready extends StatefulWidget {
  const _Step3Ready({
    required this.isSaving,
    required this.onStart,
    required this.palette,
  });

  final bool isSaving;
  final Future<void> Function() onStart;
  final NutPalette palette;

  @override
  State<_Step3Ready> createState() => _Step3ReadyState();
}

class _Step3ReadyState extends State<_Step3Ready>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  bool _privacyAccepted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    Future<void>.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = widget.palette;
    final textTheme = Theme.of(context).textTheme;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          NutSpacing.screenHorizontal,
          28,
          NutSpacing.screenHorizontal,
          NutSpacing.screenBottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.onboardingStep3Title,
              style: textTheme.headlineSmall?.copyWith(
                fontSize: 28,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.onboardingStep3Subtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: palette.textSecondary,
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 48),
            Center(
              child: Column(
                children: [
                  Text(
                    l10n.onboardingStep3StreakLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: palette.textMuted,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '0',
                    style: TextStyle(
                      fontSize: 104,
                      fontWeight: FontWeight.w300,
                      color: palette.accentGold,
                      height: 1,
                      letterSpacing: -5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.homeDaysClean,
                    style: TextStyle(
                      fontSize: 14,
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            NutCard(
              color: _privacyAccepted
                  ? palette.accentBg.withOpacity(0.48)
                  : palette.card,
              borderColor: _privacyAccepted
                  ? palette.accentGold.withOpacity(0.38)
                  : palette.border,
              padding: const EdgeInsets.all(12),
              child: CheckboxListTile(
                value: _privacyAccepted,
                activeColor: palette.accentGold,
                checkColor: const Color(0xFF1A0E00),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  l10n.onboardingPrivacyConfirmTitle,
                  style: textTheme.bodyMedium,
                ),
                subtitle: Text(
                  l10n.onboardingPrivacyConfirmBody,
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary,
                    height: 1.4,
                  ),
                ),
                onChanged: widget.isSaving
                    ? null
                    : (value) {
                        setState(() => _privacyAccepted = value ?? false);
                      },
              ),
            ),
            const SizedBox(height: 16),
            NutPrimaryButton(
              label: l10n.onboardingStep3CTA,
              isLoading: widget.isSaving,
              onPressed:
                  widget.isSaving || !_privacyAccepted ? null : widget.onStart,
            ),
          ],
        ),
      ),
    );
  }
}
