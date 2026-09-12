import 'package:flutter/material.dart';
import '../../core/design/design.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Widget? trailing;
  final AppButtonStyle style;
  final AppButtonSize size;
  final bool loading;
  final bool disabled;
  final bool fullWidth;
  final BorderRadius? borderRadius;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.trailing,
    this.style = AppButtonStyle.primary,
    this.size = AppButtonSize.large,
    this.loading = false,
    this.disabled = false,
    this.fullWidth = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDisabled = disabled || loading || onPressed == null;
    final (backgroundColor, foregroundColor, overlayColor, borderSide) = _resolveColors(context);
    final (height, horizontalPadding, textStyle, iconSize, gap) = _resolveSize();

    Widget child = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        else if (leading != null)
          SizedBox(width: iconSize, height: iconSize, child: leading!),
        if ((leading != null || loading) && label.isNotEmpty) SizedBox(width: gap),
        if (label.isNotEmpty)
          Flexible(child: Text(label, style: textStyle, overflow: TextOverflow.ellipsis)),
        if (trailing != null && !loading) ...[
          if (label.isNotEmpty) SizedBox(width: gap),
          SizedBox(width: iconSize, height: iconSize, child: trailing!),
        ],
      ],
    );

    final button = SizedBox(
      height: height,
      width: fullWidth ? double.infinity : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: effectiveDisabled ? null : onPressed,
          borderRadius: borderRadius ?? AppRadii.button,
          overlayColor: WidgetStateProperty.all(overlayColor),
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius ?? AppRadii.button,
              border: borderSide != null ? Border.fromBorderSide(borderSide) : null,
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );

    return Pressable(
      onTap: effectiveDisabled ? null : onPressed,
      scaleFactor: size == AppButtonSize.small ? 0.98 : 0.97,
      child: AnimatedOpacity(opacity: effectiveDisabled ? 0.5 : 1.0, duration: AppMotion.fast, child: button),
    );
  }

  (Color, Color, Color, BorderSide?) _resolveColors(BuildContext context) {
    switch (style) {
      case AppButtonStyle.primary:
        return (
          AppColors.primary,
          AppColors.onPrimary,
          AppColors.primaryDark.withValues(alpha: 0.3),
          null,
        );
      case AppButtonStyle.secondary:
        return (
          AppColors.surfaceElevated,
          AppColors.textPrimary,
          AppColors.primary.withValues(alpha: 0.1),
          BorderSide(color: AppColors.border, width: 1),
        );
      case AppButtonStyle.outline:
        return (
          Colors.transparent,
          AppColors.textPrimary,
          AppColors.primary.withValues(alpha: 0.08),
          BorderSide(color: AppColors.border, width: 1),
        );
      case AppButtonStyle.ghost:
        return (
          Colors.transparent,
          AppColors.primary,
          AppColors.primary.withValues(alpha: 0.08),
          null,
        );
      case AppButtonStyle.danger:
        return (
          AppColors.danger,
          AppColors.onPrimary,
          AppColors.danger.withValues(alpha: 0.3),
          null,
        );
      case AppButtonStyle.success:
        return (
          AppColors.success,
          AppColors.onPrimary,
          AppColors.success.withValues(alpha: 0.3),
          null,
        );
      case AppButtonStyle.ai:
        return (
          AppColors.ai,
          AppColors.onPrimary,
          AppColors.ai.withValues(alpha: 0.3),
          null,
        );
    }
  }

  (double, double, TextStyle, double, double) _resolveSize() {
    switch (size) {
      case AppButtonSize.small:
        return (36, AppSpacing.md, AppTypography.buttonSmall, 16, AppSpacing.sm);
      case AppButtonSize.medium:
        return (44, AppSpacing.lg, AppTypography.buttonMedium, 20, AppSpacing.md);
      case AppButtonSize.large:
        return (52, AppSpacing.xl, AppTypography.buttonLarge, 22, AppSpacing.md);
    }
  }
}

enum AppButtonStyle { primary, secondary, outline, ghost, danger, success, ai }
enum AppButtonSize { small, medium, large }

class AppIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final bool loading;
  final bool disabled;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.loading = false,
    this.disabled = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDisabled = disabled || loading || onPressed == null;
    final (sizeValue, iconSize) = switch (size) {
      AppButtonSize.small => (36.0, 18.0),
      AppButtonSize.medium => (44.0, 22.0),
      AppButtonSize.large => (52.0, 26.0),
    };

    final bgColor = backgroundColor ?? AppColors.surfaceElevated;
    final fgColor = foregroundColor ?? AppColors.textSecondary;
    final overlay = AppColors.primary.withValues(alpha: 0.08);

    Widget child = SizedBox(
      width: sizeValue,
      height: sizeValue,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: effectiveDisabled ? null : onPressed,
          borderRadius: borderRadius ?? AppRadii.buttonCompact,
          overlayColor: WidgetStateProperty.all(overlay),
          child: Ink(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: borderRadius ?? AppRadii.buttonCompact,
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: loading
                ? Center(
                    child: SizedBox(
                      width: iconSize,
                      height: iconSize,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(fgColor)),
                    ),
                  )
                : Center(child: IconTheme(data: IconThemeData(color: fgColor, size: iconSize), child: icon)),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      child = Tooltip(message: tooltip!, child: child);
    }

    return Pressable(
      onTap: effectiveDisabled ? null : onPressed,
      scaleFactor: 0.95,
      child: AnimatedOpacity(opacity: effectiveDisabled ? 0.5 : 1.0, duration: AppMotion.fast, child: child),
    );
  }
}

class AppButtonGroup extends StatelessWidget {
  final List<Widget> children;
  final Axis direction;
  final double spacing;

  const AppButtonGroup({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
    this.spacing = AppSpacing.md,
  });

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: direction,
      mainAxisSize: MainAxisSize.min,
      children: children
          .expand((widget) => [widget, SizedBox(width: direction == Axis.horizontal ? spacing : 0, height: direction == Axis.vertical ? spacing : 0)])
          .take(children.length * 2 - 1)
          .toList(),
    );
  }
}