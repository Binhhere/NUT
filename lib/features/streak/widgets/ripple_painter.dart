import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../streak_model.dart';

class RipplePainter extends CustomPainter {
  RipplePainter({
    required this.phase,
    required int piercedRingCount,
    required double ringDecayProgress,
    required double breathingProgress,
    required double pierceProgress,
    required this.accentColor,
    required this.originColor,
  })  : piercedRingCount =
            piercedRingCount.clamp(0, StreakModel.totalRingLayers),
        ringDecayProgress = ringDecayProgress.clamp(0.0, 1.0),
        breathingProgress = breathingProgress.clamp(0.0, 1.0),
        pierceProgress = pierceProgress.clamp(0.0, 1.0);

  final RipplePhase phase;
  final int piercedRingCount;
  final double ringDecayProgress;
  final double breathingProgress;
  final double pierceProgress;
  final Color accentColor;
  final Color originColor;

  static const _innerRadius = 23.0;
  static const _outerRadius = 98.0;
  static const _holeSweep = math.pi / 7;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    if (phase == RipplePhase.seed || phase == RipplePhase.breathing) {
      _drawSeed(canvas, center);
      return;
    }

    for (var i = StreakModel.totalRingLayers - 1; i >= 0; i--) {
      final radius = _ringRadius(i);
      final isPierced = i < piercedRingCount;
      if (isPierced) {
        _drawPiercedRing(canvas, center, i, radius);
      } else {
        _drawIntactRing(canvas, center, i, radius);
      }
    }

    if (phase == RipplePhase.piercing && piercedRingCount > 0) {
      _drawPiercePath(canvas, center, piercedRingCount - 1);
    }

    _drawSeed(canvas, center);
  }

  double _ringRadius(int index) {
    final t = index / (StreakModel.totalRingLayers - 1);
    return _innerRadius + (_outerRadius - _innerRadius) * t;
  }

  double _angleForRing(int index) {
    final random = math.Random(index * 7919 + 17);
    return -math.pi * 0.86 + random.nextDouble() * math.pi * 1.72;
  }

  void _drawIntactRing(Canvas canvas, Offset center, int index, double radius) {
    final opacity = (0.28 - index * 0.006).clamp(0.11, 0.28);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = accentColor.withOpacity(opacity)
        ..strokeWidth = 1.15
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawPiercedRing(
      Canvas canvas, Offset center, int index, double radius) {
    final angle = _angleForRing(index);
    final paint = Paint()
      ..color = accentColor.withOpacity(
        (0.72 - ringDecayProgress * 0.42 - index * 0.008).clamp(0.12, 0.72),
      )
      ..strokeWidth = (1.85 - ringDecayProgress * 0.75).clamp(0.85, 1.85)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final gapCount = 1 + (ringDecayProgress * 18).round();
    final random = math.Random(index * 3571 + 5);
    final baseGap = _holeSweep + ringDecayProgress * math.pi / 18;
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    for (var segment = 0; segment < gapCount; segment++) {
      final segmentStart = (math.pi * 2 / gapCount) * segment;
      final jitter = (random.nextDouble() - 0.5) * ringDecayProgress * 0.22;
      final start = segmentStart + jitter;
      final sweep = (math.pi * 2 / gapCount) -
          baseGap * (segment == 0 ? 1.25 : 0.42 + random.nextDouble() * 0.36);

      if (_crossesHole(start, sweep, angle)) continue;
      canvas.drawArc(
          arcRect, start, sweep.clamp(0.02, math.pi * 2), false, paint);
    }

    final holeCenter =
        center + Offset(math.cos(angle), math.sin(angle)) * radius;
    canvas.drawCircle(
      holeCenter,
      2.5 + ringDecayProgress * 2.0,
      Paint()
        ..color = Colors.black.withOpacity(0.18)
        ..style = PaintingStyle.fill,
    );
  }

  bool _crossesHole(double start, double sweep, double holeAngle) {
    final end = start + sweep;
    var normalizedHole = holeAngle;
    while (normalizedHole < start) {
      normalizedHole += math.pi * 2;
    }
    return normalizedHole >= start - _holeSweep * 0.5 &&
        normalizedHole <= end + _holeSweep * 0.5;
  }

  void _drawPiercePath(Canvas canvas, Offset center, int ringIndex) {
    final radius = _ringRadius(ringIndex);
    final angle = _angleForRing(ringIndex);
    final direction = Offset(math.cos(angle), math.sin(angle));
    final perpendicular = Offset(-direction.dy, direction.dx);
    final points = <Offset>[center];

    for (var i = 1; i <= 5; i++) {
      final t = i / 5;
      final side = i.isOdd ? 1.0 : -1.0;
      final wobble = side * (7.0 + ringIndex % 4) * (1 - t * 0.25);
      points.add(center + direction * radius * t + perpendicular * wobble);
    }

    final progressDistance = radius * pierceProgress;
    var drawnDistance = 0.0;
    final paint = Paint()
      ..color =
          originColor.withOpacity((1.0 - pierceProgress * 0.18).clamp(0.0, 1.0))
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      final length = (b - a).distance;
      if (drawnDistance + length <= progressDistance) {
        canvas.drawLine(a, b, paint);
        drawnDistance += length;
        continue;
      }

      final remaining = progressDistance - drawnDistance;
      if (remaining > 0) {
        final t = (remaining / length).clamp(0.0, 1.0);
        canvas.drawLine(a, Offset.lerp(a, b, t)!, paint);
      }
      break;
    }
  }

  void _drawSeed(Canvas canvas, Offset center) {
    final breathingScale = switch (phase) {
      RipplePhase.seed => 0.82,
      RipplePhase.breathing => 0.88 + breathingProgress * 0.62,
      _ => 1.0,
    };
    final radius = 7.0 * breathingScale;

    canvas.drawCircle(
      center,
      radius * 2.2,
      Paint()
        ..color = accentColor.withOpacity(0.18 + breathingProgress * 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = originColor.withOpacity(0.95)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center + Offset(-radius * 0.25, -radius * 0.25),
      radius * 0.28,
      Paint()
        ..color = Colors.white.withOpacity(0.72)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant RipplePainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.piercedRingCount != piercedRingCount ||
      oldDelegate.ringDecayProgress != ringDecayProgress ||
      oldDelegate.breathingProgress != breathingProgress ||
      oldDelegate.pierceProgress != pierceProgress ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.originColor != originColor;
}
