// lib/features/streak/widgets/ripple_painter.dart
//
// CustomPainter vẽ hệ thống ripple bất đối xứng cho RippleField.
//
// RENDER PATHS:
//   seed        — chỉ điểm sáng, không arc
//   growing     — 1–6 arcs, lớp mới fade-in, lớp cũ đẩy ra xa
//   breakthrough — same as growing nhưng BreakthroughAnimation wrap bên ngoài
//   ascending   — 6 arcs full + arc cuối cùng decay (mờ hơn) + origin mờ nhẹ
//   rising      — 6 arcs, opacity toàn bộ giảm (field đang "chìm" xuống)
//   orbit       — 6 arcs rất mờ, field gần như invisible, chỉ còn orb
//
// COORDINATE SYSTEM:
//   Canvas size = 220×220
//   Origin lệch trái: x = width * 0.38, y = height * 0.5
//   Arc tỏa phải: startAngle = -80°, sweepAngle = 160°

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../streak_model.dart';

class RippleConfig {
  const RippleConfig({
    required this.radius,
    required this.opacity,
    required this.strokeWidth,
  });

  final double radius;
  final double opacity;
  final double strokeWidth;
}

class RipplePainter extends CustomPainter {
  RipplePainter({
    required this.phase,
    required this.rippleCount,
    required this.newRippleProgress,
    required this.accentColor,
    required this.originColor,
    this.tiltProgress = 0.0,
  });

  final RipplePhase phase;
  final int rippleCount;
  final double newRippleProgress; // [0–1] fade-in ripple mới nhất
  final Color accentColor;
  final Color originColor;
  final double tiltProgress; // reserved cho BreakthroughAnimation

  // ── Constants ─────────────────────────────────

  static const double _startAngleDeg = -80.0;
  static const double _sweepAngleDeg = 160.0;
  static const double _rippleSpacing = 22.0;
  static const double _baseRadius = 24.0;
  static const double _originRadius = 6.0;
  static const double _originXRatio = 0.38;

  static double _deg(double d) => d * math.pi / 180.0;

  // ── Phase-aware global multipliers ────────────

  /// Opacity toàn cục của field tùy phase.
  /// ascending: full, rising: 0.65, orbit: 0.25
  double get _fieldOpacity {
    return switch (phase) {
      RipplePhase.seed => 1.0,
      RipplePhase.growing => 1.0,
      RipplePhase.breakthrough => 1.0,
      RipplePhase.ascending => 1.0,
      RipplePhase.rising => 0.65,
      RipplePhase.orbit => 0.25,
    };
  }

  /// Số arc hiển thị theo phase.
  int get _activeCount {
    return switch (phase) {
      RipplePhase.seed => 0,
      RipplePhase.growing => rippleCount,
      RipplePhase.breakthrough => rippleCount,
      RipplePhase.ascending => 6,
      RipplePhase.rising => 6,
      RipplePhase.orbit => 6,
    };
  }

  /// Origin point opacity — mờ dần ở phase sau (orb đã bay lên)
  double get _originOpacity {
    return switch (phase) {
      RipplePhase.ascending => 0.5,
      RipplePhase.rising => 0.2,
      RipplePhase.orbit => 0.0, // tắt hẳn, chỉ còn orb ở BreakthroughAnimation
      _ => 1.0,
    };
  }

  // ── Per-arc opacity ────────────────────────────

  double _opacityForIndex(int index, int total) {
    if (total == 0) return 0.0;

    // index 0 = mới nhất (gần tâm), total-1 = cũ nhất (xa tâm)
    double base;
    if (index == 0) {
      // Fade-in animation cho ripple mới nhất trong growing phase
      base = phase == RipplePhase.growing
          ? Curves.easeOut.transform(newRippleProgress) * 0.95
          : 0.9;
    } else {
      final age = index / (total - 1 + 0.001);
      base = (1.0 - age * 0.75).clamp(0.1, 0.85);
    }

    return (base * _fieldOpacity).clamp(0.0, 1.0);
  }

  double _strokeWidthForIndex(int index) => (3.0 - index * 0.3).clamp(1.2, 3.0);

  // ── Build configs ──────────────────────────────

  List<RippleConfig> _buildConfigs(int count) => List.generate(
        count,
        (i) => RippleConfig(
          radius: _baseRadius + i * _rippleSpacing,
          opacity: _opacityForIndex(i, count),
          strokeWidth: _strokeWidthForIndex(i),
        ),
      );

  // ── Paint ──────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width * _originXRatio, size.height * 0.5);
    final count = _activeCount;

    if (phase == RipplePhase.seed || count == 0) {
      if (_originOpacity > 0) _drawOrigin(canvas, origin, _originOpacity);
      return;
    }

    final configs = _buildConfigs(count);

    // Vẽ ngoài → trong (cũ → mới)
    for (var i = configs.length - 1; i >= 0; i--) {
      _drawArc(canvas, origin, configs[i]);
    }

    if (_originOpacity > 0) _drawOrigin(canvas, origin, _originOpacity);
  }

  void _drawArc(Canvas canvas, Offset origin, RippleConfig cfg) {
    canvas.drawArc(
      Rect.fromCircle(center: origin, radius: cfg.radius),
      _deg(_startAngleDeg),
      _deg(_sweepAngleDeg),
      false,
      Paint()
        ..color = accentColor.withOpacity(cfg.opacity)
        ..strokeWidth = cfg.strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawOrigin(Canvas canvas, Offset origin, double opacity) {
    // Glow
    canvas.drawCircle(
      origin,
      _originRadius * 2.2,
      Paint()
        ..color = originColor.withOpacity(0.25 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    // Core
    canvas.drawCircle(
      origin,
      _originRadius,
      Paint()
        ..color = originColor.withOpacity(opacity)
        ..style = PaintingStyle.fill,
    );
    // Inner highlight
    canvas.drawCircle(
      origin,
      _originRadius * 0.38,
      Paint()
        ..color = Colors.white.withOpacity(0.7 * opacity)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant RipplePainter old) =>
      old.phase != phase ||
      old.rippleCount != rippleCount ||
      old.newRippleProgress != newRippleProgress ||
      old.accentColor != accentColor ||
      old.tiltProgress != tiltProgress;
}
