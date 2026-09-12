import 'package:flutter/material.dart';
import '../../core/design/design.dart';

class AppChip extends StatelessWidget {
  final String label;
  final Widget? avatar;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onDeleted;
  final VoidCallback? onPressed;
  final bool selected;
  final AppChipStyle style;
  final Color? backgroundColor;
  final Color? labelColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const AppChip({
    super.key,
    required this.label,
    this.avatar,
    this.leading,
    this.trailing,
    this.onDeleted,
    this.onPressed,
    this.selected = false,
    this.style = AppChipStyle.filled,
    this.backgroundColor,
    this.labelColor,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final (bgColor, fgColor, border, overlay) = _resolveStyle();

    Widget chip = Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius ?? AppRadii.chip,
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (avatar != null) ...[
            avatar!,
            const SizedBox(width: AppSpacing.sm),
          ] else if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(label, style: AppTypography.labelMedium.copyWith(color: fgColor)),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
          if (onDeleted != null) ...[
            const SizedBox(width: AppSpacing.xs),
            GestureDetector(
              onTap: onDeleted,
              child: Icon(Icons.close_rounded, size: 16, color: fgColor.withValues(alpha: 0.7)),
            ),
          ],
        ],
      ),
    );

    if (onPressed != null) {
      return Pressable(
        onTap: onPressed,
        scaleFactor: 0.95,
        borderRadius: borderRadius ?? AppRadii.chip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: borderRadius ?? AppRadii.chip,
            overlayColor: WidgetStateProperty.all(overlay),
            child: chip,
          ),
        ),
      );
    }

    return chip;
  }

  (Color, Color, Border?, Color) _resolveStyle() {
    switch (style) {
      case AppChipStyle.filled:
        return (
          selected ? AppColors.primaryContainer : AppColors.surfaceElevated,
          selected ? AppColors.onPrimaryContainer : AppColors.textPrimary,
          null,
          AppColors.primary.withValues(alpha: 0.1),
        );
      case AppChipStyle.outlined:
        return (
          Colors.transparent,
          AppColors.textPrimary,
          Border.all(color: AppColors.border, width: 1),
          AppColors.primary.withValues(alpha: 0.08),
        );
      case AppChipStyle.assist:
        return (
          AppColors.primaryContainer.withValues(alpha: 0.5),
          AppColors.primary,
          null,
          AppColors.primary.withValues(alpha: 0.1),
        );
      case AppChipStyle.success:
        return (AppColors.successContainer, AppColors.onSuccessContainer, null, AppColors.success.withValues(alpha: 0.1));
      case AppChipStyle.warning:
        return (AppColors.warningContainer, AppColors.onWarningContainer, null, AppColors.warning.withValues(alpha: 0.1));
      case AppChipStyle.danger:
        return (AppColors.dangerContainer, AppColors.onDangerContainer, null, AppColors.danger.withValues(alpha: 0.1));
      case AppChipStyle.info:
        return (AppColors.infoContainer, AppColors.onInfoContainer, null, AppColors.info.withValues(alpha: 0.1));
      case AppChipStyle.ai:
        return (AppColors.aiContainer, AppColors.onAiContainer, null, AppColors.ai.withValues(alpha: 0.1));
    }
  }
}

enum AppChipStyle { filled, outlined, assist, success, warning, danger, info, ai }

class AppChipGroup extends StatelessWidget {
  final List<AppChip> chips;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;
  final WrapAlignment runAlignment;

  const AppChipGroup({
    super.key,
    required this.chips,
    this.spacing = AppSpacing.sm,
    this.runSpacing = AppSpacing.sm,
    this.alignment = WrapAlignment.start,
    this.runAlignment = WrapAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: alignment,
      runAlignment: runAlignment,
      children: chips,
    );
  }
}

class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeStyle style;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const AppBadge({
    super.key,
    required this.label,
    this.style = AppBadgeStyle.neutral,
    this.fontSize,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final (bgColor, fgColor) = _resolveStyle();

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius ?? AppRadii.badge,
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(fontSize: fontSize, color: fgColor),
      ),
    );
  }

  (Color, Color) _resolveStyle() {
    switch (style) {
      case AppBadgeStyle.neutral:
        return (AppColors.surfaceElevated, AppColors.textSecondary);
      case AppBadgeStyle.primary:
        return (AppColors.primaryContainer, AppColors.onPrimaryContainer);
      case AppBadgeStyle.success:
        return (AppColors.successContainer, AppColors.onSuccessContainer);
      case AppBadgeStyle.warning:
        return (AppColors.warningContainer, AppColors.onWarningContainer);
      case AppBadgeStyle.danger:
        return (AppColors.dangerContainer, AppColors.onDangerContainer);
      case AppBadgeStyle.info:
        return (AppColors.infoContainer, AppColors.onInfoContainer);
      case AppBadgeStyle.ai:
        return (AppColors.aiContainer, AppColors.onAiContainer);
    }
  }
}

enum AppBadgeStyle { neutral, primary, success, warning, danger, info, ai }

class AppStatusIndicator extends StatelessWidget {
  final AppStatus status;
  final double size;
  final String? label;
  final bool showPulse;

  const AppStatusIndicator({
    super.key,
    required this.status,
    this.size = 10,
    this.label,
    this.showPulse = false,
  });

  @override
  Widget build(BuildContext context) {
    final (color, pulseColor) = _resolveColor();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (showPulse && status == AppStatus.active)
              AnimatedContainer(
                duration: AppMotion.slower,
                width: size * 3,
                height: size * 3,
                decoration: BoxDecoration(
                  color: pulseColor.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: AppElevation.colored(color, intensity: 0.5)),
            ),
          ],
        ),
        if (label != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(label!, style: AppTypography.bodySmall),
        ],
      ],
    );
  }

  (Color, Color) _resolveColor() {
    switch (status) {
      case AppStatus.active:
        return (AppColors.success, AppColors.success);
      case AppStatus.inactive:
        return (AppColors.textTertiary, AppColors.textTertiary);
      case AppStatus.pending:
        return (AppColors.warning, AppColors.warning);
      case AppStatus.error:
        return (AppColors.danger, AppColors.danger);
      case AppStatus.processing:
        return (AppColors.info, AppColors.info);
      case AppStatus.ai:
        return (AppColors.ai, AppColors.ai);
    }
  }
}

enum AppStatus { active, inactive, pending, error, processing, ai }