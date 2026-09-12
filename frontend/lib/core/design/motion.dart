import 'package:flutter/material.dart';

class AppMotion {
  static const Duration instant = Duration(milliseconds: 0);
  static const Duration fast = Duration(milliseconds: 100);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration slower = Duration(milliseconds: 500);

  static const Curve standard = Curves.easeInOut;
  static const Curve emphasize = Curves.easeOutCubic;
  static const Curve decelerate = Curves.easeOutQuart;
  static const Curve accelerate = Curves.easeInQuart;
  static const Curve spring = Curves.elasticOut;

  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration dialogTransition = Duration(milliseconds: 200);
  static const Duration bottomSheetTransition = Duration(milliseconds: 250);
  static const Duration snackBarTransition = Duration(milliseconds: 150);
  static const Duration pressFeedback = Duration(milliseconds: 80);
  static const Duration hoverFeedback = Duration(milliseconds: 50);
  static const Duration focusFeedback = Duration(milliseconds: 50);
  static const Duration loadingShimmer = Duration(milliseconds: 1500);
}

extension AnimationExtensions on Widget {
  Widget fadeIn({Duration? duration, Curve? curve}) => AnimatedOpacity(
    opacity: 1,
    duration: duration ?? AppMotion.normal,
    curve: curve ?? AppMotion.standard,
    child: this,
  );

  Widget slideUp({Duration? duration, Curve? curve, double offset = 20}) => TweenAnimationBuilder<Offset>(
    tween: Tween(begin: Offset(0, offset), end: Offset.zero),
    duration: duration ?? AppMotion.medium,
    curve: curve ?? AppMotion.decelerate,
    builder: (context, value, child) => Transform.translate(offset: value, child: child),
    child: this,
  );

  Widget scaleIn({Duration? duration, Curve? curve, double begin = 0.95}) => TweenAnimationBuilder<double>(
    tween: Tween(begin: begin, end: 1.0),
    duration: duration ?? AppMotion.fast,
    curve: curve ?? AppMotion.emphasize,
    builder: (context, value, child) => Transform.scale(scale: value, child: child),
    child: this,
  );
}

class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleFactor;
  final Duration duration;
  final Curve curve;
  final Color? splashColor;
  final Object? borderRadius;
  final double? radius;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleFactor = 0.97,
    this.duration = AppMotion.pressFeedback,
    this.curve = AppMotion.emphasize,
    this.splashColor,
    this.borderRadius,
    this.radius,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scale = Tween(begin: 1.0, end: widget.scaleFactor).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) => _controller.forward();
  void _handleTapUp(TapUpDetails details) => _controller.reverse();
  void _handleTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}