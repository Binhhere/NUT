import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../streak_model.dart';

class PetCompanion extends StatefulWidget {
  const PetCompanion({
    super.key,
    required this.accessories,
    required this.accentColor,
  });

  final Set<PetAccessory> accessories;
  final Color accentColor;

  @override
  State<PetCompanion> createState() => _PetCompanionState();
}

class _PetCompanionState extends State<PetCompanion>
    with TickerProviderStateMixin {
  late final AnimationController _blinkController;
  late final AnimationController _tiltController;
  final _random = math.Random();
  Timer? _idleTimer;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _tiltController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ??
        MediaQuery.maybeOf(context)?.accessibleNavigation ??
        false;
    if (!reduceMotion &&
        !const String.fromEnvironment('FLUTTER_TEST').contains('true')) {
      _scheduleIdle();
    }
  }

  void _scheduleIdle() {
    if (_idleTimer?.isActive ?? false) return;
    _idleTimer = Timer(Duration(seconds: 4 + _random.nextInt(5)), () async {
      if (!mounted) return;

      if (_random.nextBool()) {
        await _blinkController.forward(from: 0);
        if (mounted) _blinkController.reverse();
      } else {
        await _tiltController.forward(from: 0);
        if (mounted) _tiltController.reverse();
      }

      if (mounted) {
        _idleTimer = null;
        _scheduleIdle();
      }
    });
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _blinkController.dispose();
    _tiltController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_blinkController, _tiltController]),
      builder: (context, _) {
        final blink = math.sin(_blinkController.value * math.pi);
        final tilt = math.sin(_tiltController.value * math.pi) * 0.08;

        return SizedBox(
          width: 220,
          height: 220,
          child: CustomPaint(
            painter: _PetPainter(
              accessories: widget.accessories,
              accentColor: widget.accentColor,
              blinkProgress: blink,
              tiltRadians: tilt,
            ),
          ),
        );
      },
    );
  }
}

class _PetPainter extends CustomPainter {
  const _PetPainter({
    required this.accessories,
    required this.accentColor,
    required this.blinkProgress,
    required this.tiltRadians,
  });

  final Set<PetAccessory> accessories;
  final Color accentColor;
  final double blinkProgress;
  final double tiltRadians;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 8);
    _drawBackdrop(canvas, size, center);

    if (accessories.contains(PetAccessory.chair)) {
      _drawChair(canvas, center);
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tiltRadians);
    canvas.translate(-center.dx, -center.dy);

    final rockPath = _rockPath(center);
    canvas.drawPath(
      rockPath,
      Paint()
        ..color = const Color(0xFF9B9489)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      rockPath,
      Paint()
        ..color = Colors.white.withOpacity(0.16)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );

    _drawFace(canvas, center);

    if (accessories.contains(PetAccessory.glasses)) {
      _drawGlasses(canvas, center);
    }
    if (accessories.contains(PetAccessory.hat)) {
      _drawHat(canvas, center);
    }

    canvas.restore();

    if (accessories.contains(PetAccessory.drink)) {
      _drawDrink(canvas, center);
    }
  }

  Path _rockPath(Offset center) {
    return Path()
      ..moveTo(center.dx - 45, center.dy + 19)
      ..cubicTo(center.dx - 52, center.dy - 12, center.dx - 28, center.dy - 42,
          center.dx + 3, center.dy - 43)
      ..cubicTo(center.dx + 35, center.dy - 44, center.dx + 53, center.dy - 14,
          center.dx + 47, center.dy + 17)
      ..cubicTo(center.dx + 42, center.dy + 47, center.dx - 37, center.dy + 48,
          center.dx - 45, center.dy + 19)
      ..close();
  }

  void _drawBackdrop(Canvas canvas, Size size, Offset center) {
    canvas.drawCircle(
      center + const Offset(0, 16),
      72,
      Paint()
        ..color = accentColor.withOpacity(0.07)
        ..style = PaintingStyle.fill,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center + const Offset(0, 48),
        width: 112,
        height: 18,
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  void _drawChair(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = accentColor.withOpacity(0.32)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
        center + const Offset(-58, 39), center + const Offset(60, 39), paint);
    canvas.drawLine(
        center + const Offset(-45, 39), center + const Offset(-62, 66), paint);
    canvas.drawLine(
        center + const Offset(42, 39), center + const Offset(58, 66), paint);
    canvas.drawLine(
        center + const Offset(45, -8), center + const Offset(70, -32), paint);
  }

  void _drawFace(Canvas canvas, Offset center) {
    final eyePaint = Paint()
      ..color = const Color(0xFF211B17)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final eyeHeight = (5.0 * (1 - blinkProgress)).clamp(0.4, 5.0);
    for (final dx in [-15.0, 15.0]) {
      final eyeCenter = center + Offset(dx, -5);
      if (eyeHeight < 1) {
        canvas.drawLine(eyeCenter + const Offset(-4, 0),
            eyeCenter + const Offset(4, 0), eyePaint);
      } else {
        canvas.drawOval(
          Rect.fromCenter(center: eyeCenter, width: 6, height: eyeHeight),
          Paint()
            ..color = const Color(0xFF211B17)
            ..style = PaintingStyle.fill,
        );
      }
    }

    canvas.drawArc(
      Rect.fromCenter(
          center: center + const Offset(0, 12), width: 20, height: 12),
      0.18,
      math.pi - 0.36,
      false,
      eyePaint,
    );
  }

  void _drawHat(Canvas canvas, Offset center) {
    final brimPaint = Paint()
      ..color = accentColor.withOpacity(0.92)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center + const Offset(-32, -43),
        center + const Offset(33, -43), brimPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center + const Offset(0, -58),
          width: 45,
          height: 25,
        ),
        const Radius.circular(8),
      ),
      Paint()
        ..color = accentColor.withOpacity(0.82)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawGlasses(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = const Color(0xFF211B17)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center + const Offset(-15, -5), 10, paint);
    canvas.drawCircle(center + const Offset(15, -5), 10, paint);
    canvas.drawLine(
        center + const Offset(-5, -5), center + const Offset(5, -5), paint);
  }

  void _drawDrink(Canvas canvas, Offset center) {
    final cup = RRect.fromRectAndRadius(
      Rect.fromLTWH(center.dx + 50, center.dy + 18, 24, 34),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      cup,
      Paint()
        ..color = Colors.white.withOpacity(0.78)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      cup,
      Paint()
        ..color = accentColor.withOpacity(0.7)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    canvas.drawLine(
        center + const Offset(63, 16),
        center + const Offset(72, -2),
        Paint()
          ..color = accentColor.withOpacity(0.85)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant _PetPainter oldDelegate) =>
      !setEquals(oldDelegate.accessories, accessories) ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.blinkProgress != blinkProgress ||
      oldDelegate.tiltRadians != tiltRadians;
}
