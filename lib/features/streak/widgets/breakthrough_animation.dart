// lib/features/streak/widgets/breakthrough_animation.dart
//
// Animation xảy ra tại ngày 7 (RipplePhase.breakthrough) và kéo dài
// sang các phase sau (ascending, rising, orbit).
//
// STAGES:
//   Stage 1 [0.0–0.4] — Tâm rung, các arc rung nhẹ (impact tremor)
//   Stage 2 [0.4–0.7] — Toàn bộ mặt phẳng ripple nghiêng góc 3D
//                        dùng Matrix4 perspective transform
//   Stage 3 [0.7–1.0] — Điểm sáng xuyên lên, ripple field thu nhỏ
//                        và mờ dần phía dưới
//
// Sau khi animation hoàn tất, widget ở trạng thái "post-breakthrough":
//   - Ripple field hiện nhỏ, nghiêng, phía dưới
//   - Điểm sáng ở cao, có trail mờ phía sau
//
// API:
//   BreakthroughAnimation(
//     phase: streak.ripplePhase,
//     accentColor: ...,
//     child: RippleField(...),       // field bên dưới
//   )
//
// Widget này wrap RippleField và add layer điểm sáng đang bay lên.
// Chỉ active khi phase >= breakthrough. Phase seed/growing → passthrough.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../streak_model.dart';

class BreakthroughAnimation extends StatefulWidget {
  const BreakthroughAnimation({
    super.key,
    required this.phase,
    required this.accentColor,
    required this.child,
    this.onComplete,
  });

  final RipplePhase phase;
  final Color accentColor;

  /// RippleField hoặc bất kỳ widget nào bên dưới.
  final Widget child;

  /// Callback khi animation stage 3 hoàn tất lần đầu.
  final VoidCallback? onComplete;

  @override
  State<BreakthroughAnimation> createState() => _BreakthroughAnimationState();
}

class _BreakthroughAnimationState extends State<BreakthroughAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Stage sub-animations
  late final Animation<double> _tremorAnim; // [0.0–0.4]
  late final Animation<double> _tiltAnim; // [0.4–0.7]
  late final Animation<double> _ascentAnim; // [0.7–1.0]

  bool _hasPlayed = false;
  bool _hasCompleted = false;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _tremorAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
    );

    _tiltAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.35, 0.72, curve: Curves.easeInOut),
    );

    _ascentAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_hasCompleted) {
        _hasCompleted = true;
        widget.onComplete?.call();
      }
    });

    _maybePlay();
  }

  @override
  void didUpdateWidget(covariant BreakthroughAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase != widget.phase) {
      _maybePlay();
    }
  }

  void _maybePlay() {
    final shouldPlay = widget.phase == RipplePhase.breakthrough ||
        widget.phase == RipplePhase.ascending ||
        widget.phase == RipplePhase.rising ||
        widget.phase == RipplePhase.orbit;

    if (shouldPlay && !_hasPlayed) {
      _hasPlayed = true;
      // Small delay để user vừa thấy check-in confirm xong rồi mới animate
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _ctrl.forward();
      });
    }

    // Post-breakthrough phases — jump thẳng đến end state nếu đã qua
    if (shouldPlay && _hasPlayed && widget.phase != RipplePhase.breakthrough) {
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Phase seed/growing — passthrough, không có gì thêm
    if (widget.phase == RipplePhase.seed ||
        widget.phase == RipplePhase.growing) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final tremor = _tremorAnim.value;
        final tilt = _tiltAnim.value;
        final ascent = _ascentAnim.value;

        return SizedBox(
          width: 220,
          height: 280, // extra height để điểm sáng bay lên
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // ── Layer 1: Ripple field nghiêng + thu nhỏ ──
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _TiltedField(
                  tilt: tilt,
                  ascent: ascent,
                  tremor: tremor,
                  child: widget.child,
                ),
              ),

              // ── Layer 2: Điểm sáng bay lên ───────────────
              if (ascent > 0)
                Positioned(
                  // Bay từ center (140px từ bottom) lên top
                  bottom: 140 + ascent * 120,
                  left: 0,
                  right: 0,
                  child: _AscendingOrb(
                    progress: ascent,
                    accentColor: widget.accentColor,
                  ),
                ),

              // ── Layer 3: Trail mờ phía sau orb ───────────
              if (ascent > 0.2)
                Positioned(
                  bottom: 140 + ascent * 80,
                  left: 0,
                  right: 0,
                  child: _OrbTrail(
                    progress: ascent,
                    accentColor: widget.accentColor,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// TILTED FIELD
// Dùng Transform + Matrix4 perspective để nghiêng ripple field
// như nhìn từ góc xiên — lộ ra "độ sâu" của các lớp ripple.
// ─────────────────────────────────────────────

class _TiltedField extends StatelessWidget {
  const _TiltedField({
    required this.tilt,
    required this.ascent,
    required this.tremor,
    required this.child,
  });

  final double tilt; // [0–1] mức độ nghiêng
  final double ascent; // [0–1] mức độ thu nhỏ khi orb bay lên
  final double tremor; // [0–1] rung trước khi nghiêng
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Tremor: rung nhỏ theo trục Y trước khi tilt
    final tremorOffset = math.sin(tremor * math.pi * 6) * 4 * (1 - tilt);

    // Scale nhỏ dần khi ascent tăng (field trở thành "vết sóng phía dưới")
    final fieldScale = 1.0 - ascent * 0.35;

    // Opacity field giảm dần khi orb đã lên cao
    final fieldOpacity = (1.0 - ascent * 0.5).clamp(0.0, 1.0);

    // Matrix4 perspective tilt — nghiêng quanh trục X
    // rotateX(angle): -pi/2 = nằm ngang, 0 = đứng thẳng
    // Chúng ta tilt từ 0 → -35° để tạo cảm giác nhìn từ góc xiên
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective depth
      ..rotateX(-tilt * 35 * math.pi / 180);

    return Opacity(
      opacity: fieldOpacity,
      child: Transform(
        transform: matrix,
        alignment: Alignment.bottomCenter,
        child: Transform.scale(
          scale: fieldScale,
          child: Transform.translate(
            offset: Offset(0, tremorOffset),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ASCENDING ORB
// Điểm sáng xuyên lên — to dần, sáng dần khi mới bay lên,
// sau đó ổn định thành orb tĩnh ở phase orbit.
// ─────────────────────────────────────────────

class _AscendingOrb extends StatelessWidget {
  const _AscendingOrb({
    required this.progress,
    required this.accentColor,
  });

  final double progress;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    // Orb size: nhỏ lúc đầu → lớn dần → settle ở size cố định
    final orbRadius = 5.0 + Curves.easeOut.transform(progress) * 7.0;

    // Opacity: fade in nhanh, sau đó ổn định
    final opacity = Curves.easeOut.transform(progress.clamp(0.0, 1.0));

    return Center(
      child: CustomPaint(
        size: Size(orbRadius * 6, orbRadius * 6),
        painter: _OrbPainter(
          radius: orbRadius,
          color: accentColor,
          glowOpacity: opacity * 0.4,
          coreOpacity: opacity,
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  const _OrbPainter({
    required this.radius,
    required this.color,
    required this.glowOpacity,
    required this.coreOpacity,
  });

  final double radius;
  final Color color;
  final double glowOpacity;
  final double coreOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Outer glow
    canvas.drawCircle(
      center,
      radius * 2.5,
      Paint()
        ..color = color.withOpacity(glowOpacity * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Mid glow
    canvas.drawCircle(
      center,
      radius * 1.6,
      Paint()
        ..color = color.withOpacity(glowOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Core
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withOpacity(coreOpacity)
        ..style = PaintingStyle.fill,
    );

    // Inner spark
    canvas.drawCircle(
      center,
      radius * 0.35,
      Paint()
        ..color = Colors.white.withOpacity(coreOpacity * 0.9)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbPainter old) =>
      old.radius != radius ||
      old.glowOpacity != glowOpacity ||
      old.coreOpacity != coreOpacity;
}

// ─────────────────────────────────────────────
// ORB TRAIL
// Vệt sáng mờ phía sau orb đang bay lên — tạo cảm giác chuyển động.
// Vẽ 4-5 vòng nhỏ giảm dần opacity.
// ─────────────────────────────────────────────

class _OrbTrail extends StatelessWidget {
  const _OrbTrail({
    required this.progress,
    required this.accentColor,
  });

  final double progress;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: const Size(40, 60),
        painter: _TrailPainter(
          color: accentColor,
          progress: progress,
        ),
      ),
    );
  }
}

class _TrailPainter extends CustomPainter {
  const _TrailPainter({required this.color, required this.progress});

  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    // Vẽ 5 chấm trail phía dưới, mỗi chấm nhỏ hơn và mờ hơn
    for (var i = 0; i < 5; i++) {
      final t = i / 4.0;
      final radius = (3.5 - t * 2.5).clamp(0.5, 3.5);
      final opacity = ((1.0 - t) * 0.45 * progress).clamp(0.0, 1.0);
      final yOffset = 8.0 + t * 40.0;

      canvas.drawCircle(
        Offset(cx, yOffset),
        radius,
        Paint()
          ..color = color.withOpacity(opacity)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrailPainter old) =>
      old.progress != progress || old.color != old.color;
}
