import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NutPressable extends StatefulWidget {
  const NutPressable({
    super.key,
    required this.child,
    this.onTap,
    this.enabled = true,
    this.enableHaptics = false,
    this.scale = 0.975,
    this.pressedOpacity = 0.92,
    this.duration = const Duration(milliseconds: 90),
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final bool enableHaptics;
  final double scale;
  final double pressedOpacity;
  final Duration duration;
  final Curve curve;

  @override
  State<NutPressable> createState() => _NutPressableState();
}

class _NutPressableState extends State<NutPressable> {
  bool _pressed = false;

  bool get _interactive => widget.enabled && widget.onTap != null;

  void _setPressed(bool value) {
    if (!widget.enabled && value) return;
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  void _handleTap() {
    if (!_interactive) return;
    if (widget.enableHaptics) {
      HapticFeedback.selectionClick();
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations ??
        MediaQuery.maybeOf(context)?.accessibleNavigation ??
        false;
    final showPressed = widget.enabled && _pressed && !disableAnimations;
    final scale = showPressed ? widget.scale : 1.0;
    final opacity = showPressed ? widget.pressedOpacity : 1.0;

    Widget child = Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: scale,
        duration: disableAnimations ? Duration.zero : widget.duration,
        curve: widget.curve,
        child: AnimatedOpacity(
          opacity: opacity,
          duration: disableAnimations ? Duration.zero : widget.duration,
          curve: widget.curve,
          child: widget.child,
        ),
      ),
    );

    if (_interactive) {
      child = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: child,
      );
    }

    return child;
  }
}
