import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../streak_model.dart';

/// Visual phase mapping for the shrine core widget.
/// seed/breathing  -> rooting (day 0-3)   : dark closed shell, living core trapped
/// piercing        -> cracking (day 4-20) : layers crack open, root grows downward
/// breakthrough    -> opening (day 21)    : shell opens, light pulse
/// pet             -> sprout  (day 22+)   : small sprout grows upward from core
enum ShrinePhase { rooting, cracking, opening, sprout }

ShrinePhase shrinePhaseFrom(RipplePhase rp) => switch (rp) {
      RipplePhase.seed || RipplePhase.breathing => ShrinePhase.rooting,
      RipplePhase.piercing => ShrinePhase.cracking,
      RipplePhase.breakthrough => ShrinePhase.opening,
      RipplePhase.pet => ShrinePhase.sprout,
    };

/// Color palette used by [ShrinePainter].
/// Fixed dark-warm tones inspired by the Gemini reference image.
class ShrinePalette {
  const ShrinePalette({
    required this.layerInner,
    required this.layerOuter,
    required this.rimHighlight,
    required this.crackColor,
    required this.rootColor,
    required this.coreOuter,
    required this.coreInner,
    required this.coreGlow,
    required this.sproutGreen,
  });

  final Color layerInner;
  final Color layerOuter;
  final Color rimHighlight;
  final Color crackColor;
  final Color rootColor;
  final Color coreOuter;
  final Color coreInner;
  final Color coreGlow;
  final Color sproutGreen;

  /// Fixed warm palette that works across all app themes.
  static const warm = ShrinePalette(
    layerInner: Color(0xFF4A3D32), // warm dark bark
    layerOuter: Color(0xFF2C2520), // deep charcoal outer layer
    rimHighlight: Color(0xFFD4A87A), // warm sandy edge
    crackColor: Color(0xFF1A1410), // very dark shadow crack
    rootColor: Color(0xFF8B6D4A), // dried root tan
    coreOuter: Color(0xFFD4680A), // amber core outer
    coreInner: Color(0xFFF5A020), // bright gold core inner
    coreGlow: Color(0xFFF5A020), // warm gold glow
    sproutGreen: Color(0xFF4E8A4A), // muted sage sprout
  );
}

/// Returns the shrine palette to use (always warm for now).
ShrinePalette buildShrinePalette(BuildContext context) => ShrinePalette.warm;

/// CustomPainter that draws the layered organic shrine core.
class ShrinePainter extends CustomPainter {
  const ShrinePainter({
    required this.phase,
    required this.crackProgress,
    required this.breathingScale,
    required this.openProgress,
    required this.sproutHeight,
    required this.glowPulse,
    required this.palette,
  });

  final ShrinePhase phase;

  /// 0–1: how cracked the layers are (day 4–21).
  final double crackProgress;

  /// 0–1: core breathing scale animation.
  final double breathingScale;

  /// 0–1: shell opening burst progress (breakthrough).
  final double openProgress;

  /// 0–1: sprout growth after day 22.
  final double sproutHeight;

  /// 0–1: subtle idle glow oscillation.
  final double glowPulse;

  final ShrinePalette palette;

  // ── layer constants ────────────────────────────────────────
  static const _layerCount = 5;
  static const _outerR = 130.0;
  static const _innerR = 32.0;
  static const _coreR = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    _drawAmbientGlow(canvas, center);
    _drawLayers(canvas, center);
    _drawRoot(canvas, center);
    _drawCore(canvas, center);

    if (phase == ShrinePhase.sprout) {
      _drawSprout(canvas, center);
    }
    if (phase == ShrinePhase.opening) {
      _drawOpeningBurst(canvas, center);
    }
  }

  // ── ambient glow ──────────────────────────────────────────
  void _drawAmbientGlow(Canvas canvas, Offset center) {
    final glowOpacity = switch (phase) {
      ShrinePhase.rooting => 0.08 + glowPulse * 0.04,
      ShrinePhase.cracking => 0.12 + crackProgress * 0.10 + glowPulse * 0.05,
      ShrinePhase.opening => 0.55 + openProgress * 0.35,
      ShrinePhase.sprout => 0.20 + glowPulse * 0.06,
    };
    canvas.drawCircle(
      center,
      _outerR * 0.92,
      Paint()
        ..color = palette.coreGlow.withOpacity(glowOpacity.clamp(0.0, 0.9))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 55),
    );
  }

  // ── concentric heavy organic layers ──────────────────────
  void _drawLayers(Canvas canvas, Offset center) {
    for (var i = _layerCount - 1; i >= 0; i--) {
      _drawSingleLayer(canvas, center, i);
    }
  }

  void _drawSingleLayer(Canvas canvas, Offset center, int layerIndex) {
    final t = layerIndex / (_layerCount - 1);
    final baseR = _innerR + (_outerR - _innerR) * t;
    final crackShift = crackProgress * (1 - t) * 10.0;
    final r = baseR + crackShift;

    final layerColor = Color.lerp(palette.layerInner, palette.layerOuter, t)!;
    final path = _buildLayerPath(center, r, layerIndex);

    canvas.drawPath(
      path,
      Paint()
        ..color = layerColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color =
            palette.rimHighlight.withOpacity((0.13 - t * 0.07).clamp(0.0, 0.13))
        ..strokeWidth = (2.5 - t * 1.2).clamp(0.5, 2.5)
        ..style = PaintingStyle.stroke,
    );

    if (phase == ShrinePhase.cracking || phase == ShrinePhase.opening) {
      _drawCrackLines(canvas, center, r, layerIndex);
    }
  }

  Path _buildLayerPath(Offset center, double r, int seed) {
    final random = math.Random(seed * 1337 + 42);
    final path = Path();
    const points = 12;
    Offset firstPt = Offset.zero;

    for (var i = 0; i < points; i++) {
      final angle = (i / points) * math.pi * 2;
      final warp = 1.0 + (random.nextDouble() - 0.5) * 0.16;
      final pt = center + Offset(math.cos(angle), math.sin(angle)) * r * warp;
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
        firstPt = pt;
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.lineTo(firstPt.dx, firstPt.dy);
    path.close();
    return path;
  }

  void _drawCrackLines(Canvas canvas, Offset center, double r, int seed) {
    final random = math.Random(seed * 7919 + 13);
    final crackCount = 2 + seed % 3;
    final op = (crackProgress * 0.55 * (1 - seed * 0.07)).clamp(0.0, 0.55);
    final crackPaint = Paint()
      ..color = palette.crackColor.withOpacity(op)
      ..strokeWidth = 0.8 + crackProgress * 0.7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var c = 0; c < crackCount; c++) {
      final startAngle = random.nextDouble() * math.pi * 2;
      final length = r * 0.22 * crackProgress;
      final endAngle = startAngle + (random.nextDouble() - 0.5) * 0.55;
      final start = center +
          Offset(math.cos(startAngle), math.sin(startAngle)) * (r * 0.78);
      final end =
          start + Offset(math.cos(endAngle), math.sin(endAngle)) * length;
      final mid = Offset.lerp(start, end, 0.5)! +
          Offset(
            (random.nextDouble() - 0.5) * 5 * crackProgress,
            (random.nextDouble() - 0.5) * 5 * crackProgress,
          );
      canvas.drawLine(start, mid, crackPaint);
      canvas.drawLine(mid, end, crackPaint);
    }
  }

  // ── downward root ─────────────────────────────────────────
  void _drawRoot(Canvas canvas, Offset center) {
    if (phase == ShrinePhase.opening || phase == ShrinePhase.sprout) return;

    final rootProgress = switch (phase) {
      ShrinePhase.rooting => breathingScale * 0.3,
      ShrinePhase.cracking => 0.3 + crackProgress * 0.7,
      _ => 0.0,
    };
    if (rootProgress <= 0) return;

    final paint = Paint()
      ..color = palette.rootColor.withOpacity(0.65 * rootProgress)
      ..strokeWidth = 2.0 + rootProgress * 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final mainLength = 38.0 * rootProgress;
    final start = center + const Offset(0, _coreR * 1.2);
    final end = start + Offset(0, mainLength);

    final path = Path()..moveTo(start.dx, start.dy);
    path.cubicTo(
      start.dx - 3,
      start.dy + mainLength * 0.35,
      start.dx + 3,
      start.dy + mainLength * 0.65,
      end.dx,
      end.dy,
    );
    canvas.drawPath(path, paint);

    if (rootProgress > 0.5) {
      final thinPaint = Paint()
        ..color = palette.rootColor.withOpacity(0.35 * rootProgress)
        ..strokeWidth = 0.9
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final midY = start.dy + mainLength * 0.55;
      canvas.drawLine(
        Offset(start.dx, midY),
        Offset(start.dx - 11 * rootProgress, midY + 7 * rootProgress),
        thinPaint,
      );
      canvas.drawLine(
        Offset(start.dx, midY),
        Offset(start.dx + 9 * rootProgress, midY + 5 * rootProgress),
        thinPaint,
      );
    }
  }

  // ── living core (the trapped seed) ───────────────────────
  void _drawCore(Canvas canvas, Offset center) {
    final scale = switch (phase) {
      ShrinePhase.rooting => 0.7 + breathingScale * 0.3,
      ShrinePhase.cracking => 1.0 + breathingScale * 0.06,
      ShrinePhase.opening => 1.0 + openProgress * 0.5,
      ShrinePhase.sprout => 1.0 + glowPulse * 0.06,
    };
    final r = _coreR * scale;
    final extraGlow = phase == ShrinePhase.opening ? openProgress * 0.45 : 0.0;

    canvas.drawCircle(
      center,
      r * 2.8,
      Paint()
        ..color = palette.coreGlow
            .withOpacity((0.20 + glowPulse * 0.12 + extraGlow).clamp(0.0, 0.8))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = palette.coreOuter
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      r * 0.62,
      Paint()
        ..color = palette.coreInner
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center + Offset(-r * 0.25, -r * 0.28),
      r * 0.22,
      Paint()
        ..color = Colors.white.withOpacity(0.72)
        ..style = PaintingStyle.fill,
    );
  }

  // ── sprout upward growth ──────────────────────────────────
  void _drawSprout(Canvas canvas, Offset center) {
    if (sproutHeight <= 0) return;

    final stemHeight = 52.0 * sproutHeight;
    final stemBase = center - const Offset(0, _coreR * 1.05);
    final stemTop = stemBase - Offset(0, stemHeight);

    final stemPaint = Paint()
      ..color = palette.sproutGreen.withOpacity(0.88)
      ..strokeWidth = 2.2 + sproutHeight * 1.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(
      Path()
        ..moveTo(stemBase.dx, stemBase.dy)
        ..cubicTo(
          stemBase.dx + 5,
          stemBase.dy - stemHeight * 0.35,
          stemBase.dx - 4,
          stemBase.dy - stemHeight * 0.65,
          stemTop.dx,
          stemTop.dy,
        ),
      stemPaint,
    );

    if (sproutHeight > 0.4) {
      final lp = ((sproutHeight - 0.4) / 0.6).clamp(0.0, 1.0);
      _drawLeaf(canvas, stemTop + const Offset(2, 8), -0.6, lp);
      if (sproutHeight > 0.65) {
        final lp2 = ((sproutHeight - 0.65) / 0.35).clamp(0.0, 1.0);
        _drawLeaf(canvas, stemTop + const Offset(-2, 16), 0.5, lp2);
      }
    }
  }

  void _drawLeaf(Canvas canvas, Offset base, double angle, double progress) {
    final size = 12.0 * progress;
    final path = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(
        base.dx + math.cos(angle) * size,
        base.dy + math.sin(angle) * size - size * 0.5,
        base.dx + math.cos(angle) * size * 1.6,
        base.dy - size * 0.2,
      )
      ..quadraticBezierTo(
        base.dx + math.cos(angle) * size * 0.7,
        base.dy + size * 0.3,
        base.dx,
        base.dy,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = palette.sproutGreen.withOpacity(0.82 * progress)
        ..style = PaintingStyle.fill,
    );
  }

  // ── breakthrough burst ────────────────────────────────────
  void _drawOpeningBurst(Canvas canvas, Offset center) {
    if (openProgress <= 0) return;

    final burstR = _outerR * 0.55 * openProgress;
    const rays = 8;
    final rayPaint = Paint()
      ..color =
          palette.coreGlow.withOpacity((0.5 * openProgress).clamp(0.0, 0.5))
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < rays; i++) {
      final angle = (i / rays) * math.pi * 2;
      final innerPt =
          center + Offset(math.cos(angle), math.sin(angle)) * (_coreR * 2.0);
      final outerPt =
          center + Offset(math.cos(angle), math.sin(angle)) * burstR;
      canvas.drawLine(innerPt, outerPt, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ShrinePainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.crackProgress != crackProgress ||
      oldDelegate.breathingScale != breathingScale ||
      oldDelegate.openProgress != openProgress ||
      oldDelegate.sproutHeight != sproutHeight ||
      oldDelegate.glowPulse != glowPulse;
}
