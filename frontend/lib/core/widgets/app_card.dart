import 'package:flutter/material.dart';
import '../../core/design/design.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final List<BoxShadow>? shadows;
  final Border? border;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool interactive;

  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardPadding,
    this.margin,
    this.color,
    this.shadows,
    this.border,
    this.borderRadius,
    this.onTap,
    this.interactive = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).cardColor;
    final effectiveBorderRadius = borderRadius ?? AppRadii.card;
    final effectiveBorder = border ?? Border.all(color: AppColors.border, width: 0.5);
    final effectiveShadows = shadows ?? AppElevation.level1;

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: effectiveBorderRadius,
        border: effectiveBorder,
        boxShadow: effectiveShadows,
      ),
      child: Padding(padding: padding!, child: child),
    );

    if (interactive && onTap != null) {
      return Pressable(onTap: onTap, child: card);
    }

    return card;
  }
}

class AppCardElevated extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final int elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const AppCardElevated({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardPadding,
    this.margin,
    this.color,
    this.elevation = 2,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shadows = switch (elevation) {
      0 => AppElevation.level0,
      1 => AppElevation.level1,
      2 => AppElevation.level2,
      3 => AppElevation.level3,
      4 => AppElevation.level4,
      _ => AppElevation.level5,
    };

    return AppCard(
      padding: padding,
      margin: margin,
      color: color,
      shadows: shadows,
      borderRadius: borderRadius,
      onTap: onTap,
      interactive: onTap != null,
      child: child,
    );
  }
}

class AppCardOutlined extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const AppCardOutlined({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardPadding,
    this.margin,
    this.color,
    this.borderColor,
    this.borderWidth = 0.5,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding,
      margin: margin,
      color: color,
      border: Border.all(color: borderColor ?? AppColors.border, width: borderWidth),
      borderRadius: borderRadius,
      onTap: onTap,
      interactive: onTap != null,
      child: child,
    );
  }
}

class AppCardSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? action;
  final EdgeInsetsGeometry? padding;
  final CrossAxisAlignment crossAxisAlignment;

  const AppCardSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.action,
    this.padding = AppSpacing.cardPadding,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.titleMedium),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(subtitle!, style: AppTypography.bodySmall.muted()),
                    ],
                  ],
                ),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}