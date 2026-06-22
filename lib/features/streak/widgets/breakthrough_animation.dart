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
  final Widget child;
  final VoidCallback? onComplete;

  @override
  State<BreakthroughAnimation> createState() => _BreakthroughAnimationState();
}

class _BreakthroughAnimationState extends State<BreakthroughAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasPlayed = false;
  bool _hasCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..addStatusListener((status) {
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
    if (widget.phase != RipplePhase.breakthrough) return;
    if (_hasPlayed) return;

    _hasPlayed = true;
    Future<void>.delayed(const Duration(milliseconds: 260), () {
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
    if (widget.phase != RipplePhase.breakthrough) {
      return widget.child;
    }

    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ??
        MediaQuery.maybeOf(context)?.accessibleNavigation ??
        false;

    if (reduceMotion) {
      return const SizedBox(width: 220, height: 220);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = _controller.value;
        final collapse = Curves.easeInCubic.transform(
          (progress / 0.48).clamp(0.0, 1.0),
        );
        final flash = Curves.easeOut.transform(
          ((progress - 0.38) / 0.24).clamp(0.0, 1.0),
        );
        final flight = Curves.easeInOutCubic.transform(
          ((progress - 0.54) / 0.46).clamp(0.0, 1.0),
        );

        return SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: (1 - collapse).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: (1 - collapse).clamp(0.0, 1.0),
                  child: widget.child,
                ),
              ),
              if (flash > 0 && flash < 1)
                _FlashCore(
                  progress: flash,
                  color: widget.accentColor,
                ),
              if (flight > 0)
                Transform.translate(
                  offset: Offset(92 * flight, -112 * flight),
                  child: Opacity(
                    opacity: (1 - flight * 0.12).clamp(0.0, 1.0),
                    child: _FlyingSeed(
                      progress: flight,
                      color: widget.accentColor,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FlashCore extends StatelessWidget {
  const _FlashCore({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final radius = 12 + progress * 34;
    return CustomPaint(
      size: Size(radius * 2.4, radius * 2.4),
      painter: _FlashPainter(radius: radius, color: color),
    );
  }
}

class _FlyingSeed extends StatelessWidget {
  const _FlyingSeed({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final radius = 9 + progress * 5;
    return CustomPaint(
      size: Size(radius * 5, radius * 5),
      painter: _SeedPainter(radius: radius, color: color),
    );
  }
}

class _FlashPainter extends CustomPainter {
  const _FlashPainter({required this.radius, required this.color});

  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.drawCircle(
      center,
      radius * 0.34,
      Paint()
        ..color = Colors.white.withOpacity(0.88)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _FlashPainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.color != color;
}

class _SeedPainter extends CustomPainter {
  const _SeedPainter({required this.radius, required this.color});

  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      center,
      radius * 2.2,
      Paint()
        ..color = color.withOpacity(0.26)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withOpacity(0.94)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _SeedPainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.color != color;
}
