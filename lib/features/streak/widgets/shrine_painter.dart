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

  /// 0-1: how cracked the layers are (day 4-21).
  final double crackProgress;

  /// 0-1: core breathing scale animation.
  final double breathingScale;

  /// 0-1: shell opening burst progress (breakthrough).
  final double openProgress;

  /// 0-1: sprout growth after day 22.
  final double sproutHeight;

  /// 0-1: subtle idle glow oscillation.
  final double glowPulse;

  final ShrinePalette palette;

  static const _layerCount = 5;
  static const _majorPointCount = 8;
  static const _outerR = 130.0;
  static const _innerR = 32.0;
  static const _coreR = 14.0;
  static const _layerWarpStrength = 0.28;
  static const _layerThickness = 12.0;
  static const _grooveWidth = 8.0;
  static const _massShadowYOffset = 28.0;
  static const _lowerMassDarkenOpacity = 0.22;
  static const _cavityRadius = 34.0;
  static const _deepSourceYOffset = 112.0;
  static const _deepSourceWidth = 118.0;
  static const _deepSourceHeight = 24.0;
  static const _deepSourceOpacity = 0.13;
  static const _coreIrregularity = 0.12;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    _drawDeepSource(canvas, center);
    _drawAmbientGlow(canvas, center);
    _drawHeavyMassShadow(canvas, center);
    _drawLayers(canvas, center);
    _drawLowerMassDarkening(canvas, center);
    _drawRoot(canvas, center);
    _drawInnerCavity(canvas, center);
    _drawCore(canvas, center);

    if (phase == ShrinePhase.sprout) {
      _drawSprout(canvas, center);
    }
    if (phase == ShrinePhase.opening) {
      _drawOpeningBurst(canvas, center);
    }
  }

  void _drawDeepSource(Canvas canvas, Offset center) {
    final sourceCenter = center + const Offset(0, _deepSourceYOffset);
    final pulse = 0.88 + glowPulse * 0.12;
    final sourceRect = Rect.fromCenter(
      center: sourceCenter,
      width: _deepSourceWidth * pulse,
      height: _deepSourceHeight,
    );

    canvas.drawOval(
      sourceRect.inflate(18),
      Paint()
        ..color = palette.coreGlow.withOpacity(_deepSourceOpacity * 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );
    canvas.drawOval(
      sourceRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            palette.coreInner.withOpacity(_deepSourceOpacity),
            palette.coreGlow.withOpacity(_deepSourceOpacity * 0.38),
            Colors.transparent,
          ],
          stops: const [0.0, 0.52, 1.0],
        ).createShader(sourceRect),
    );
  }

  void _drawAmbientGlow(Canvas canvas, Offset center) {
    final glowOpacity = switch (phase) {
      ShrinePhase.rooting => 0.06 + glowPulse * 0.03,
      ShrinePhase.cracking => 0.09 + crackProgress * 0.08 + glowPulse * 0.04,
      ShrinePhase.opening => 0.40 + openProgress * 0.25,
      ShrinePhase.sprout => 0.14 + glowPulse * 0.05,
    };
    canvas.drawCircle(
      center,
      _outerR * 0.88,
      Paint()
        ..color = palette.coreGlow.withOpacity(glowOpacity.clamp(0.0, 0.65))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50),
    );
  }

  void _drawHeavyMassShadow(Canvas canvas, Offset center) {
    final base = center + const Offset(0, _massShadowYOffset);
    canvas.drawOval(
      Rect.fromCenter(
        center: base + const Offset(0, 42),
        width: _outerR * 1.95,
        height: 72,
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.34)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: base + const Offset(0, 22),
        width: _outerR * 1.45,
        height: 48,
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
  }

  void _drawLayers(Canvas canvas, Offset center) {
    for (var i = _layerCount - 1; i >= 0; i--) {
      _drawSingleLayer(canvas, center, i);
    }
  }

  void _drawLowerMassDarkening(Canvas canvas, Offset center) {
    final rect = Rect.fromCenter(
      center: center + const Offset(0, _outerR * 0.37),
      width: _outerR * 1.85,
      height: _outerR * 0.78,
    );
    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 0.2),
          colors: [
            Colors.black.withOpacity(_lowerMassDarkenOpacity),
            Colors.black.withOpacity(_lowerMassDarkenOpacity * 0.55),
            Colors.transparent,
          ],
          stops: const [0.0, 0.58, 1.0],
        ).createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  void _drawSingleLayer(Canvas canvas, Offset center, int layerIndex) {
    final t = layerIndex / (_layerCount - 1);
    final baseR = _innerR + (_outerR - _innerR) * t;
    final openingPush =
        phase == ShrinePhase.opening ? openProgress * (1 - t) * 12.0 : 0.0;
    final crackShift = crackProgress * (1 - t) * 10.0 + openingPush;
    final r = baseR + crackShift;
    final layerColor = Color.lerp(palette.layerInner, palette.layerOuter, t)!;
    final path = _buildLayerPath(center, r, layerIndex);
    final bounds = path.getBounds().inflate(6);

    final backingPath = _buildLayerPath(
      center + Offset(0, _layerThickness * (0.22 + t * 0.18)),
      r + _layerThickness * (0.74 + t * 0.22),
      layerIndex + 31,
    );
    canvas.drawPath(
      backingPath,
      Paint()
        ..color = Colors.black.withOpacity(0.18 + t * 0.13)
        ..style = PaintingStyle.fill,
    );

    final groovePath = _buildLayerPath(
      center + const Offset(0, 1.5),
      r + _layerThickness * 0.44,
      layerIndex + 17,
    );
    canvas.drawPath(
      groovePath,
      Paint()
        ..color = palette.crackColor.withOpacity(0.22 + t * 0.14)
        ..strokeWidth = (_grooveWidth * (1.12 - t * 0.28)).clamp(4.0, 9.0)
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(layerColor, palette.rimHighlight, 0.18)!,
            layerColor,
            Color.lerp(layerColor, palette.crackColor, 0.42)!,
          ],
          stops: const [0.0, 0.46, 1.0],
        ).createShader(bounds)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color =
            palette.rimHighlight.withOpacity((0.18 - t * 0.08).clamp(0.0, 0.18))
        ..strokeWidth = (3.2 - t * 1.3).clamp(0.8, 3.2)
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    _drawLayerGrooves(canvas, center, r, layerIndex, t);
    _drawLayerChips(canvas, center, r, layerIndex, t);

    if (phase == ShrinePhase.cracking || phase == ShrinePhase.opening) {
      _drawCrackLines(canvas, center, r, layerIndex);
    }
  }

  Path _buildLayerPath(Offset center, double r, int seed) {
    final points = <Offset>[];
    final xScale = 1.04 + _signedNoise(seed, 90) * 0.06;
    final yScale = 0.90 + _signedNoise(seed, 91) * 0.05;
    final layerOffset = Offset(
      _signedNoise(seed, 92) * 5.5,
      _signedNoise(seed, 93) * 4.0,
    );

    for (var i = 0; i < _majorPointCount; i++) {
      final angle = -math.pi / 2 + (i / _majorPointCount) * math.pi * 2;
      final lowerMass = math.sin(angle) > 0 ? 1.07 : 0.97;
      final warp = 1 + _signedNoise(seed, i) * _layerWarpStrength;
      final localR = r * lowerMass * warp;
      points.add(
        center +
            layerOffset +
            Offset(
              math.cos(angle) * localR * xScale,
              math.sin(angle) * localR * yScale,
            ),
      );
    }
    return _smoothClosedPath(points);
  }

  Path _smoothClosedPath(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;

    final firstMid = Offset.lerp(points.last, points.first, 0.5)!;
    path.moveTo(firstMid.dx, firstMid.dy);
    for (var i = 0; i < points.length; i++) {
      final current = points[i];
      final next = points[(i + 1) % points.length];
      final mid = Offset.lerp(current, next, 0.5)!;
      path.quadraticBezierTo(current.dx, current.dy, mid.dx, mid.dy);
    }
    path.close();
    return path;
  }

  void _drawLayerGrooves(
    Canvas canvas,
    Offset center,
    double r,
    int seed,
    double t,
  ) {
    final groovePaint = Paint()
      ..color = palette.crackColor.withOpacity(0.13 + t * 0.12)
      ..strokeWidth = 1.0 + (1 - t) * 0.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 4; i++) {
      final angle = _noise(seed + 41, i) * math.pi * 2;
      final arc = 0.17 + _noise(seed + 43, i) * 0.18;
      final localR = r * (0.70 + _noise(seed + 45, i) * 0.22);
      final start = _polar(center, angle - arc, localR, seed);
      final end = _polar(center, angle + arc, localR, seed);
      final control = _polar(
        center,
        angle,
        localR + _signedNoise(seed + 47, i) * 10,
        seed,
      );
      canvas.drawPath(
        Path()
          ..moveTo(start.dx, start.dy)
          ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy),
        groovePaint,
      );
    }
  }

  void _drawLayerChips(
    Canvas canvas,
    Offset center,
    double r,
    int seed,
    double t,
  ) {
    final darkChip = Paint()
      ..color = Colors.black.withOpacity(0.12 + t * 0.10)
      ..strokeWidth = 3.0 + t * 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final lightChip = Paint()
      ..color = palette.rimHighlight.withOpacity(0.08 + (1 - t) * 0.06)
      ..strokeWidth = 1.2 + (1 - t) * 0.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 5; i++) {
      final angle = _noise(seed + 111, i) * math.pi * 2;
      final chipR = r * (0.82 + _noise(seed + 113, i) * 0.16);
      final length = 0.06 + _noise(seed + 115, i) * 0.08;
      final start = _polar(center, angle - length, chipR, seed);
      final end = _polar(center, angle + length, chipR, seed);
      final control = _polar(
        center,
        angle,
        chipR + _signedNoise(seed + 117, i) * 7,
        seed,
      );
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
      canvas.drawPath(path, darkChip);

      final lift = Offset(0, -1.8 - t * 1.4);
      canvas.drawPath(path.shift(lift), lightChip);
    }
  }

  void _drawCrackLines(Canvas canvas, Offset center, double r, int seed) {
    final crackCount = 2 + seed % 3;
    final op = (crackProgress * 0.55 * (1 - seed * 0.07)).clamp(0.0, 0.55);
    final crackPaint = Paint()
      ..color = palette.crackColor.withOpacity(op)
      ..strokeWidth = 0.9 + crackProgress * 0.9
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var c = 0; c < crackCount; c++) {
      final startAngle = _noise(seed + 61, c) * math.pi * 2;
      final length = r * (0.14 + _noise(seed + 63, c) * 0.10) * crackProgress;
      final endAngle = startAngle + _signedNoise(seed + 65, c) * 0.62;
      final start = _polar(center, startAngle, r * 0.78, seed);
      final end = start +
          Offset(math.cos(endAngle), math.sin(endAngle)) *
              length.clamp(0.0, r * 0.28);
      final mid = Offset.lerp(start, end, 0.5)! +
          Offset(
            _signedNoise(seed + 67, c) * 7 * crackProgress,
            _signedNoise(seed + 69, c) * 7 * crackProgress,
          );
      canvas.drawLine(start, mid, crackPaint);
      canvas.drawLine(mid, end, crackPaint);
    }
  }

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

  void _drawInnerCavity(Canvas canvas, Offset center) {
    final openingRadius = phase == ShrinePhase.opening ? openProgress * 10 : 0;
    final r = _cavityRadius + crackProgress * 6 + openingRadius;
    final rect = Rect.fromCenter(
      center: center + const Offset(0, 1.5),
      width: r * 2.16,
      height: r * 1.78,
    );

    canvas.drawOval(
      rect.inflate(9),
      Paint()
        ..color = Colors.black.withOpacity(0.42)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.08),
          colors: [
            const Color(0xFF100B08).withOpacity(0.94),
            palette.coreOuter.withOpacity(0.22),
            palette.rimHighlight.withOpacity(0.11),
            Colors.transparent,
          ],
          stops: const [0.0, 0.52, 0.78, 1.0],
        ).createShader(rect),
    );
    canvas.drawOval(
      rect,
      Paint()
        ..color = palette.rimHighlight.withOpacity(0.18 + crackProgress * 0.08)
        ..strokeWidth = 3.2
        ..style = PaintingStyle.stroke,
    );
    canvas.drawArc(
      rect.deflate(2),
      math.pi * 0.1,
      math.pi * 0.8,
      false,
      Paint()
        ..color = Colors.black.withOpacity(0.32)
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawCore(Canvas canvas, Offset center) {
    final scale = switch (phase) {
      ShrinePhase.rooting => 0.7 + breathingScale * 0.3,
      ShrinePhase.cracking => 1.0 + breathingScale * 0.06,
      ShrinePhase.opening => 1.0 + openProgress * 0.5,
      ShrinePhase.sprout => 1.0 + glowPulse * 0.06,
    };
    final r = _coreR * scale;
    final extraGlow = phase == ShrinePhase.opening ? openProgress * 0.32 : 0.0;
    final glowRect = Rect.fromCenter(
      center: center,
      width: r * 5.0,
      height: r * 4.4,
    );

    canvas.drawOval(
      glowRect,
      Paint()
        ..color = palette.coreGlow
            .withOpacity((0.14 + glowPulse * 0.08 + extraGlow).clamp(0.0, 0.58))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 17),
    );

    final corePath = _buildCorePath(center, r);
    canvas.drawPath(
      corePath.shift(const Offset(0, 2.6)),
      Paint()
        ..color = Colors.black.withOpacity(0.26)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      corePath,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.32, -0.38),
          colors: [
            palette.coreInner.withOpacity(0.98),
            palette.coreOuter,
            const Color(0xFF7C3108),
          ],
          stops: const [0.0, 0.52, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: r * 1.4))
        ..style = PaintingStyle.fill,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(-r * 0.28, -r * 0.34),
        width: r * 0.50,
        height: r * 0.34,
      ),
      Paint()
        ..color = Colors.white.withOpacity(0.46)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      corePath,
      Paint()
        ..color = const Color(0xFFFFC373).withOpacity(0.18)
        ..strokeWidth = 1.1
        ..style = PaintingStyle.stroke,
    );
  }

  Path _buildCorePath(Offset center, double r) {
    final points = <Offset>[];
    const pointsCount = 7;
    for (var i = 0; i < pointsCount; i++) {
      final angle = -math.pi / 2 + (i / pointsCount) * math.pi * 2;
      final warp = 1 + _signedNoise(101, i) * _coreIrregularity;
      points.add(
        center +
            Offset(
              math.cos(angle) * r * 1.04 * warp,
              math.sin(angle) * r * 1.18 * warp,
            ),
      );
    }
    return _smoothClosedPath(points);
  }

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

  Offset _polar(Offset center, double angle, double r, int seed) {
    final xScale = 1.04 + _signedNoise(seed, 90) * 0.06;
    final yScale = 0.90 + _signedNoise(seed, 91) * 0.05;
    return center +
        Offset(
          math.cos(angle) * r * xScale,
          math.sin(angle) * r * yScale,
        );
  }

  double _noise(int seed, int index) {
    final raw =
        math.sin((seed + 1) * 91.345 + (index + 1) * 47.123) * 43758.5453;
    return raw - raw.floorToDouble();
  }

  double _signedNoise(int seed, int index) => _noise(seed, index) * 2 - 1;

  @override
  bool shouldRepaint(covariant ShrinePainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.crackProgress != crackProgress ||
      oldDelegate.breathingScale != breathingScale ||
      oldDelegate.openProgress != openProgress ||
      oldDelegate.sproutHeight != sproutHeight ||
      oldDelegate.glowPulse != glowPulse ||
      oldDelegate.palette != palette;
}
