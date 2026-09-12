import 'package:flutter/material.dart';
import '../../core/design/design.dart';
import 'app_card.dart';

class LoadingSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const LoadingSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  LoadingSkeleton.circular({
    super.key,
    required double size,
    this.baseColor,
    this.highlightColor,
  })  : width = size,
        height = size,
        borderRadius = BorderRadius.circular(size / 2);

  const LoadingSkeleton.rectangular({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: AppMotion.loadingShimmer, vsync: this)..repeat();
    _animation = Tween(begin: -1.0, end: 2.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.baseColor ?? AppColors.surfaceElevated;
    final highlight = widget.highlightColor ?? AppColors.surfaceOverlay;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(AppRadii.sm),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [base, highlight, base],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class LoadingSkeletonCard extends StatelessWidget {
  final bool showAvatar;
  final int lines;
  final double? avatarSize;

  const LoadingSkeletonCard({
    super.key,
    this.showAvatar = true,
    this.lines = 3,
    this.avatarSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showAvatar) LoadingSkeleton.circular(size: avatarSize!),
          if (showAvatar) const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List<Widget>.generate(lines, (index) {
                final isLast = index == lines - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
                  child: LoadingSkeleton(
                    height: index == 0 ? 20 : 14,
                    width: isLast ? 120 : double.infinity,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingSkeletonList extends StatelessWidget {
  final int itemCount;
  final bool showAvatar;
  final int lines;

  const LoadingSkeletonList({
    super.key,
    this.itemCount = 5,
    this.showAvatar = true,
    this.lines = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) => Padding(
        padding: EdgeInsets.only(bottom: index == itemCount - 1 ? 0 : AppSpacing.md),
        child: LoadingSkeletonCard(showAvatar: showAvatar, lines: lines),
      )),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool visible;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.visible,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (visible)
          Positioned.fill(
            child: Container(
              color: AppColors.overlay,
              child: Center(
                child: AppCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(strokeWidth: 3),
                      if (message != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text(message!, style: AppTypography.bodyMedium, textAlign: TextAlign.center),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class PullToRefresh extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final String? message;

  const PullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? AppColors.primary,
      backgroundColor: AppColors.surface,
      displacement: 40,
      strokeWidth: 2.5,
      child: child,
    );
  }
}