import 'package:flutter/material.dart';

// Why: wrapping screens in GestureWrapper means any screen gets
// swipe/double-tap/long-press without repeating the detector logic.
// Foundation: GestureDetector intercepts touch events before they reach children.

class GestureWrapper extends StatelessWidget {
  final Widget child;

  // Swipe callbacks
  final VoidCallback? onSwipeLeft;   // → Settings
  final VoidCallback? onSwipeRight;  // → Back / previous
  final VoidCallback? onSwipeUp;     // → Primary action (start session)
  final VoidCallback? onSwipeDown;   // → Dismiss / cancel

  // Tap callbacks
  final VoidCallback? onDoubleTap;   // → Toggle theme
  final VoidCallback? onLongPress;   // → Read gesture summary aloud

  // Swipe sensitivity — minimum pixels to register as a swipe
  static const double _minSwipeDistance = 80.0;
  static const double _maxVerticalDrift = 60.0;

  const GestureWrapper({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
    this.onDoubleTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    Offset? _startPos;

    return GestureDetector(
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,

      onPanStart: (details) {
        _startPos = details.globalPosition;
      },

      onPanEnd: (details) {
        if (_startPos == null) return;
        final delta = details.velocity.pixelsPerSecond;

        final dx = delta.dx;
        final dy = delta.dy;

        // Only register if movement is primarily horizontal or vertical
        if (dx.abs() > dy.abs()) {
          // Horizontal swipe
          if (dx.abs() > _minSwipeDistance && dy.abs() < _maxVerticalDrift) {
            if (dx > 0) {
              onSwipeRight?.call();
            } else {
              onSwipeLeft?.call();
            }
          }
        } else {
          // Vertical swipe
          if (dy.abs() > _minSwipeDistance && dx.abs() < _maxVerticalDrift) {
            if (dy < 0) {
              onSwipeUp?.call();
            } else {
              onSwipeDown?.call();
            }
          }
        }
        _startPos = null;
      },

      // Pass all other touches through to child widgets normally
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}