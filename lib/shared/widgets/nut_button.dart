// lib/shared/widgets/nut_button.dart
// Source: nut_ui_v5.html → .btnp / .btng / .btnd
//
// NutPrimaryButton   — gold bg, dark text, full-width, h54
// NutGhostButton     — transparent, border2, optional fg override
// NutDestructiveButton — transparent, red border + text (không dùng resetBg!)

import 'package:flutter/material.dart';
import 'package:nut_mvp/app/theme.dart';

// ─────────────────────────────────────────────
// NutPrimaryButton
// HTML: .btnp → bg gold, color #1A0E00, 15px w600, padding 17px, radius --rb
// ─────────────────────────────────────────────
class NutPrimaryButton extends StatelessWidget {
  const NutPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;
    const darkOnGold = Color(0xFF1A0E00);

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          // HTML: color #1A0E00 (dark brownish — intentionally NOT NutColors.background)
          backgroundColor: palette.accentGold,
          foregroundColor: darkOnGold,
          disabledBackgroundColor: palette.accentGold.withOpacity(0.45),
          disabledForegroundColor: darkOnGold.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NutRadius.button),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 17),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: darkOnGold,
                ),
              )
            : _child(),
      ),
    );
  }

  Widget _child() {
    const style = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.01 * 15,
    );
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label, style: style),
        ],
      );
    }
    return Text(label, style: style);
  }
}

// ─────────────────────────────────────────────
// NutGhostButton
// HTML: .btng → transparent, txt2, border 0.5px border2 (rgba 255,255,255,0.12)
//               font 14px, padding 15px
// foregroundColor override — dùng cho Relapse "I relapsed" (màu đỏ)
// ─────────────────────────────────────────────
class NutGhostButton extends StatelessWidget {
  const NutGhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.foregroundColor,
    this.borderColor,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? foregroundColor;
  final Color? borderColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;
    final fg = foregroundColor ?? palette.textSecondary;
    final border = borderColor ?? palette.border;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          side: BorderSide(color: border, width: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NutRadius.button),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: fg),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: fg,
                      letterSpacing: 0.01 * 14,
                    ),
                  ),
                ],
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: fg,
                  letterSpacing: 0.01 * 14,
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// NutDestructiveButton
// HTML: .btnd → transparent bg, color red, border 0.5px rgba(226,75,74,0.25)
//               font 14px, padding 15px
// Khác với primary: KHÔNG có background màu đỏ — chỉ border + text đỏ
// ─────────────────────────────────────────────
class NutSecondaryButton extends StatelessWidget {
  const NutSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.foregroundColor,
    this.borderColor = const Color(0x1EFFFFFF),
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? foregroundColor;
  final Color borderColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;
    final fg = foregroundColor ?? palette.textPrimary;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          side: BorderSide(color: borderColor, width: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NutRadius.button),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: icon == null
            ? Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: fg),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: fg,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class NutDestructiveButton extends StatelessWidget {
  const NutDestructiveButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;
    // HTML: border 0.5px solid rgba(226,75,74,0.25)
    const borderColor = Color(0x40E24B4A);

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.reset,
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: borderColor, width: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NutRadius.button),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: palette.reset),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: palette.reset,
                    ),
                  ),
                ],
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: palette.reset,
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// NutResetConfirmButton
// HTML (inline trong relapse sheet):
//   background: red-bg, color: red, border 0.5px rgba(226,75,74,0.3)
//   font 15px w600 — dùng riêng cho "Yes, reset" trong confirmation sheet
// ─────────────────────────────────────────────
class NutResetConfirmButton extends StatelessWidget {
  const NutResetConfirmButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.resetBg,
          foregroundColor: palette.reset,
          side: const BorderSide(color: Color(0x4DE24B4A), width: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NutRadius.button),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 17),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: palette.reset,
          ),
        ),
      ),
    );
  }
}
