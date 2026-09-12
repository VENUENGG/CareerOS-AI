import 'package:flutter/material.dart';
import '../../core/design/design.dart';
import 'app_button.dart';

class ErrorState extends StatelessWidget {
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final IconData icon;
  final Color? iconColor;
  final EdgeInsetsGeometry padding;

  const ErrorState({
    super.key,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.icon = Icons.error_outline_rounded,
    this.iconColor,
    this.padding = AppSpacing.xxlAll,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.danger;
    return Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: effectiveIconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(48),
            ),
            child: Center(child: Icon(icon, size: 48, color: effectiveIconColor)),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(title, style: AppTypography.headlineSmall, textAlign: TextAlign.center),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(message!, style: AppTypography.bodyMedium.muted(), textAlign: TextAlign.center),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: actionLabel!, onPressed: onAction, style: AppButtonStyle.primary, size: AppButtonSize.medium),
          ],
          if (secondaryActionLabel != null && onSecondaryAction != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: secondaryActionLabel!,
              onPressed: onSecondaryAction,
              style: AppButtonStyle.ghost,
              size: AppButtonSize.medium,
            ),
          ],
        ],
      ),
    );
  }
}

class ErrorStateVariant {
  static ErrorState networkError({VoidCallback? onRetry}) => ErrorState(
    title: 'Connection failed',
    message: 'Unable to reach CareerOS. Check your internet connection and try again.',
    actionLabel: 'Try again',
    onAction: onRetry,
    icon: Icons.wifi_off_rounded,
    iconColor: AppColors.warning,
  );

  static ErrorState unauthorized({VoidCallback? onLogin}) => ErrorState(
    title: 'Session expired',
    message: 'Please sign in again to continue.',
    actionLabel: 'Sign in',
    onAction: onLogin,
    icon: Icons.lock_outline_rounded,
  );

  static ErrorState forbidden({VoidCallback? onHome}) => ErrorState(
    title: 'Access denied',
    message: 'You don\'t have permission to access this resource.',
    actionLabel: 'Go home',
    onAction: onHome,
    icon: Icons.block_outlined,
  );

  static ErrorState notFound({VoidCallback? onHome}) => ErrorState(
    title: 'Not found',
    message: 'The requested resource could not be found.',
    actionLabel: 'Go home',
    onAction: onHome,
    icon: Icons.search_off_rounded,
  );

  static ErrorState conflict({VoidCallback? onRetry}) => ErrorState(
    title: 'Conflict',
    message: 'This resource already exists or has been modified.',
    actionLabel: 'Try again',
    onAction: onRetry,
    icon: Icons.warning_amber_rounded,
    iconColor: AppColors.warning,
  );

  static ErrorState validationError(String message, {VoidCallback? onRetry}) => ErrorState(
    title: 'Invalid input',
    message: message,
    actionLabel: 'Fix and retry',
    onAction: onRetry,
    icon: Icons.error_outline_rounded,
  );

  static ErrorState serverError({VoidCallback? onRetry}) => ErrorState(
    title: 'Something went wrong',
    message: 'Our servers are having trouble. Please try again in a moment.',
    actionLabel: 'Retry',
    onAction: onRetry,
    icon: Icons.dashboard_outlined,
  );

  static ErrorState unknown(String message, {VoidCallback? onRetry}) => ErrorState(
    title: 'Error',
    message: message,
    actionLabel: 'Try again',
    onAction: onRetry,
  );
}

class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final String? actionLabel;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData icon;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.onAction,
    this.actionLabel,
    this.backgroundColor,
    this.textColor,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.dangerContainer;
    final fgColor = textColor ?? AppColors.onDangerContainer;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadii.card,
        border: Border.all(color: bgColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: fgColor, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(message, style: AppTypography.bodyMedium.copyWith(color: fgColor))),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: AppSpacing.md),
            TextButton(onPressed: onAction, child: Text(actionLabel!, style: AppTypography.labelMedium.copyWith(color: fgColor))),
          ],
          if (onDismiss != null) ...[
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: Icon(Icons.close, color: fgColor, size: 20),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ],
      ),
    );
  }
}

class SuccessBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final String? actionLabel;

  const SuccessBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorBanner(
      message: message,
      onDismiss: onDismiss,
      onAction: onAction,
      actionLabel: actionLabel,
      backgroundColor: AppColors.successContainer,
      textColor: AppColors.onSuccessContainer,
      icon: Icons.check_circle_outline_rounded,
    );
  }
}

class WarningBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final String? actionLabel;

  const WarningBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorBanner(
      message: message,
      onDismiss: onDismiss,
      onAction: onAction,
      actionLabel: actionLabel,
      backgroundColor: AppColors.warningContainer,
      textColor: AppColors.onWarningContainer,
      icon: Icons.warning_amber_rounded,
    );
  }
}

class InfoBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final String? actionLabel;

  const InfoBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorBanner(
      message: message,
      onDismiss: onDismiss,
      onAction: onAction,
      actionLabel: actionLabel,
      backgroundColor: AppColors.infoContainer,
      textColor: AppColors.onInfoContainer,
      icon: Icons.info_outline_rounded,
    );
  }
}