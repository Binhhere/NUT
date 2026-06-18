import 'package:flutter/material.dart';

class NutColors {
  NutColors._();

  static const background = Color(0xFF0D0D0D);
  static const surface = Color(0xFF161616);
  static const card = Color(0xFF1E1E1E);
  static const border = Color(0x11FFFFFF);

  static const accentGold = Color(0xFFF5A623);
  static const accentDark = Color(0xFFD4850A);
  static const accentBg = Color(0xFF2A1F0A);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA0A0A0);
  static const textMuted = Color(0xFF555555);

  static const success = Color(0xFF1D9E75);
  static const reset = Color(0xFFE24B4A);
  static const resetBg = Color(0xFF2A1515);

  static const premium = Color(0xFF7F77DD);
  static const premiumSurface = Color(0xFF17162A);
  static const premiumBg = Color(0xFF13122A);
}

class NutPalette extends ThemeExtension<NutPalette> {
  const NutPalette({
    required this.background,
    required this.surface,
    required this.card,
    required this.border,
    required this.accentGold,
    required this.accentDark,
    required this.accentBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.reset,
    required this.resetBg,
    required this.premium,
    required this.premiumSurface,
    required this.premiumBg,
  });

  final Color background;
  final Color surface;
  final Color card;
  final Color border;
  final Color accentGold;
  final Color accentDark;
  final Color accentBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color success;
  final Color reset;
  final Color resetBg;
  final Color premium;
  final Color premiumSurface;
  final Color premiumBg;

  // ── Dark ──────────────────────────────────────

  static const dark = NutPalette(
    background:    NutColors.background,
    surface:       NutColors.surface,
    card:          NutColors.card,
    border:        NutColors.border,
    accentGold:    NutColors.accentGold,
    accentDark:    NutColors.accentDark,
    accentBg:      NutColors.accentBg,
    textPrimary:   NutColors.textPrimary,
    textSecondary: NutColors.textSecondary,
    textMuted:     NutColors.textMuted,
    success:       NutColors.success,
    reset:         NutColors.reset,
    resetBg:       NutColors.resetBg,
    premium:       NutColors.premium,
    premiumSurface: NutColors.premiumSurface,
    premiumBg:     NutColors.premiumBg,
  );

  // ── Ocean ─────────────────────────────────────
  //
  // Background: xanh-đen sâu đồng nhất với icon (#0F2027 base)
  // Accent: seafoam/teal lấy từ màu sáng nhất trong icon (#6FA897)
  // Surface/card: dải xanh-xám tối — cảm giác dưới nước xuyên suốt UI
  // Success/reset: giữ nguyên ngữ nghĩa phổ quát, chỉ tone lạnh hơn nhẹ
  // Premium: blue-lavender (#7C9ECC) — phân biệt rõ với accent teal

  static const ocean = NutPalette(
    background:    Color(0xFF0F2027), // xanh-đen sâu — base của icon
    surface:       Color(0xFF16242A), // tầng 1 — xanh xám tối
    card:          Color(0xFF1C2E33), // tầng 2 — sáng hơn surface 1 bậc
    border:        Color(0x1AFFFFFF), // subtle white border

    accentGold:    Color(0xFF6FA897), // seafoam — accent chính, màu sáng nhất trong icon
    accentDark:    Color(0xFF4D8C7A), // seafoam tối — hover / pressed state
    accentBg:      Color(0xFF0D2822), // seafoam bg rất tối — dùng cho chip, tag bg

    textPrimary:   Color(0xFFEAF4F1), // trắng lạnh nhẹ — dễ đọc trên nền xanh sâu
    textSecondary: Color(0xFF7EA8A0), // teal muted — text phụ, subtitle
    textMuted:     Color(0xFF3D5C60), // rất muted — placeholder, divider, icon tắt

    success:       Color(0xFF1DAA79), // xanh lá — giữ ngữ nghĩa, tone lạnh hơn dark
    reset:         Color(0xFFE05252), // đỏ — giữ nguyên ngữ nghĩa
    resetBg:       Color(0xFF2A1515), // reset background — giữ nguyên

    premium:       Color(0xFF7C9ECC), // blue-lavender — phân biệt với accent teal
    premiumSurface: Color(0xFF152030), // premium card surface
    premiumBg:     Color(0xFF0E1A27), // premium background deep
  );

  // ── Light ─────────────────────────────────────

  static const light = NutPalette(
    background:    Color(0xFFF7F4EE),
    surface:       Color(0xFFFFFFFF),
    card:          Color(0xFFFFFFFF),
    border:        Color(0x1A21170A),
    accentGold:    Color(0xFFD4850A),
    accentDark:    Color(0xFF9A5C00),
    accentBg:      Color(0xFFFFF2D6),
    textPrimary:   Color(0xFF18130C),
    textSecondary: Color(0xFF685F53),
    textMuted:     Color(0xFF9A9084),
    success:       Color(0xFF147E5F),
    reset:         Color(0xFFC93D3C),
    resetBg:       Color(0xFFFFE8E8),
    premium:       Color(0xFF665DCF),
    premiumSurface: Color(0xFFF1EFFF),
    premiumBg:     Color(0xFFE7E5FF),
  );

  // ─────────────────────────────────────────────

  @override
  NutPalette copyWith({
    Color? background,
    Color? surface,
    Color? card,
    Color? border,
    Color? accentGold,
    Color? accentDark,
    Color? accentBg,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? success,
    Color? reset,
    Color? resetBg,
    Color? premium,
    Color? premiumSurface,
    Color? premiumBg,
  }) {
    return NutPalette(
      background:    background    ?? this.background,
      surface:       surface       ?? this.surface,
      card:          card          ?? this.card,
      border:        border        ?? this.border,
      accentGold:    accentGold    ?? this.accentGold,
      accentDark:    accentDark    ?? this.accentDark,
      accentBg:      accentBg      ?? this.accentBg,
      textPrimary:   textPrimary   ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted:     textMuted     ?? this.textMuted,
      success:       success       ?? this.success,
      reset:         reset         ?? this.reset,
      resetBg:       resetBg       ?? this.resetBg,
      premium:       premium       ?? this.premium,
      premiumSurface: premiumSurface ?? this.premiumSurface,
      premiumBg:     premiumBg     ?? this.premiumBg,
    );
  }

  @override
  NutPalette lerp(ThemeExtension<NutPalette>? other, double t) {
    if (other is! NutPalette) return this;
    return NutPalette(
      background:    Color.lerp(background,    other.background,    t)!,
      surface:       Color.lerp(surface,       other.surface,       t)!,
      card:          Color.lerp(card,          other.card,          t)!,
      border:        Color.lerp(border,        other.border,        t)!,
      accentGold:    Color.lerp(accentGold,    other.accentGold,    t)!,
      accentDark:    Color.lerp(accentDark,    other.accentDark,    t)!,
      accentBg:      Color.lerp(accentBg,      other.accentBg,      t)!,
      textPrimary:   Color.lerp(textPrimary,   other.textPrimary,   t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted:     Color.lerp(textMuted,     other.textMuted,     t)!,
      success:       Color.lerp(success,       other.success,       t)!,
      reset:         Color.lerp(reset,         other.reset,         t)!,
      resetBg:       Color.lerp(resetBg,       other.resetBg,       t)!,
      premium:       Color.lerp(premium,       other.premium,       t)!,
      premiumSurface: Color.lerp(premiumSurface, other.premiumSurface, t)!,
      premiumBg:     Color.lerp(premiumBg,     other.premiumBg,     t)!,
    );
  }
}

extension NutThemeX on BuildContext {
  NutPalette get nutPalette => Theme.of(this).extension<NutPalette>()!;
}

class NutSpacing {
  NutSpacing._();

  static const small            = 8.0;
  static const medium           = 16.0;
  static const large            = 24.0;
  static const xLarge           = 32.0;
  static const screenHorizontal = 20.0;
  static const screenTop        = 8.0;
  static const screenBottom     = 24.0;

  static const screenPadding = EdgeInsets.fromLTRB(
    screenHorizontal,
    screenTop,
    screenHorizontal,
    screenBottom,
  );
}

class NutRadius {
  NutRadius._();

  static const button = 12.0;
  static const card   = 16.0;
  static const pill   = 999.0;
}

class NutBreakpoints {
  NutBreakpoints._();

  static const compact         = 600.0;
  static const medium          = 840.0;
  static const maxPhoneContent = 560.0;
  static const maxTabletContent = 920.0;
}

class NutTheme {
  NutTheme._();

  static ThemeData light()  => _build(NutPalette.light,  Brightness.light);
  static ThemeData dark()   => _build(NutPalette.dark,   Brightness.dark);

  /// Ocean theme — xanh-đen sâu, accent seafoam, đồng nhất với icon.
  /// Dùng Brightness.dark vì nền tối.
  static ThemeData ocean()  => _build(NutPalette.ocean,  Brightness.dark);

  static ThemeData _build(NutPalette palette, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary:    palette.accentGold,
      onPrimary:  brightness == Brightness.light ? Colors.white : NutColors.background,
      secondary:  palette.success,
      onSecondary: Colors.white,
      error:      palette.reset,
      onError:    Colors.white,
      surface:    palette.surface,
      onSurface:  palette.textPrimary,
    );

    final base = ThemeData(
      colorScheme:             colorScheme,
      brightness:              brightness,
      useMaterial3:            true,
      scaffoldBackgroundColor: palette.background,
      fontFamily:              'Roboto',
      extensions:              <ThemeExtension<dynamic>>[palette],
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        centerTitle:    false,
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        elevation:      0,
        titleTextStyle: TextStyle(
          color:      palette.textPrimary,
          fontSize:   24,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: base.textTheme.copyWith(
        headlineLarge: base.textTheme.headlineLarge?.copyWith(
          color:      palette.textPrimary,
          fontSize:   72,
          height:     0.95,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          color:      palette.textPrimary,
          fontSize:   24,
          height:     1.18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          color:      palette.textPrimary,
          fontSize:   20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          color:      palette.textPrimary,
          fontSize:   16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          color:      palette.textPrimary,
          fontSize:   16,
          height:     1.45,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color:      palette.textPrimary,
          fontSize:   16,
          height:     1.4,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          color:      palette.textSecondary,
          fontSize:   13,
          height:     1.35,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontSize:   16,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color:     palette.card,
        margin:    EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NutRadius.card),
          side: BorderSide(color: palette.border, width: 1),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor:     palette.accentBg,
        disabledColor:       palette.surface,
        selectedColor:       palette.accentBg,
        labelStyle:          TextStyle(color: palette.accentGold, fontSize: 13),
        secondaryLabelStyle: TextStyle(color: palette.textPrimary, fontSize: 13),
        side:  BorderSide.none,
        shape: const StadiumBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor:         palette.accentGold,
          foregroundColor:         colorScheme.onPrimary,
          disabledBackgroundColor: palette.textMuted,
          disabledForegroundColor: palette.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NutRadius.button),
          ),
          padding:   const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.textPrimary,
          side:            BorderSide(color: palette.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NutRadius.button),
          ),
          padding:   const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NutRadius.button),
          ),
          padding:   const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor:  palette.accentBg,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color:      selected ? palette.accentGold : palette.textSecondary,
            fontSize:   12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? palette.accentGold : palette.textSecondary,
            size:  24,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color:     palette.border,
        thickness: 0.5,
      ),
      listTileTheme: ListTileThemeData(
        iconColor:  palette.textSecondary,
        textColor:  palette.textPrimary,
        subtitleTextStyle: TextStyle(
          color:    palette.textSecondary,
          fontSize: 13,
        ),
      ),
    );
  }
}
