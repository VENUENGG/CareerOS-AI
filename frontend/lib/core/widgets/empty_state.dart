import 'package:flutter/material.dart';
import '../../core/design/design.dart';
import 'app_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final AppButtonStyle actionStyle;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.actionStyle = AppButtonStyle.primary,
    this.iconSize = 64,
    this.padding = AppSpacing.xxlAll,
  });

  EmptyState copyWith({
    IconData? icon,
    String? title,
    String? description,
    String? actionLabel,
    VoidCallback? onAction,
    AppButtonStyle? actionStyle,
    double? iconSize,
    EdgeInsetsGeometry? padding,
  }) {
    return EmptyState(
      icon: icon ?? this.icon,
      title: title ?? this.title,
      description: description ?? this.description,
      actionLabel: actionLabel ?? this.actionLabel,
      onAction: onAction ?? this.onAction,
      actionStyle: actionStyle ?? this.actionStyle,
      iconSize: iconSize ?? this.iconSize,
      padding: padding ?? this.padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: iconSize + 32,
            height: iconSize + 32,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(iconSize / 2 + 16),
            ),
            child: Center(
              child: Icon(icon, size: iconSize, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(title, style: AppTypography.headlineSmall, textAlign: TextAlign.center),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(description!, style: AppTypography.bodyMedium.muted(), textAlign: TextAlign.center),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: actionLabel!, onPressed: onAction, style: actionStyle, size: AppButtonSize.medium),
          ],
        ],
      ),
    );
  }
}

class EmptyStateVariant {
  static const EmptyState noResumes = EmptyState(
    icon: Icons.description_outlined,
    title: 'No resumes yet',
    description: 'Create your first resume to unlock ATS analysis, AI insights, and salary comparisons.',
    actionLabel: 'Create resume',
  );

  static const EmptyState noExperience = EmptyState(
    icon: Icons.work_outline,
    title: 'No experience added',
    description: 'Add your work experience to build a complete profile and get better career recommendations.',
    actionLabel: 'Add experience',
  );

  static const EmptyState noEducation = EmptyState(
    icon: Icons.school_outlined,
    title: 'No education added',
    description: 'Add your educational background to strengthen your profile.',
    actionLabel: 'Add education',
  );

  static const EmptyState noSkills = EmptyState(
    icon: Icons.bolt_outlined,
    title: 'No skills added',
    description: 'Add your skills to improve ATS matching and get personalized career insights.',
    actionLabel: 'Add skills',
  );

  static const EmptyState noProjects = EmptyState(
    icon: Icons.code_outlined,
    title: 'No projects added',
    description: 'Showcase your projects to demonstrate practical experience.',
    actionLabel: 'Add project',
  );

  static const EmptyState noCertifications = EmptyState(
    icon: Icons.verified_outlined,
    title: 'No certifications added',
    description: 'Add certifications to validate your expertise.',
    actionLabel: 'Add certification',
  );

  static const EmptyState noLanguages = EmptyState(
    icon: Icons.language_outlined,
    title: 'No languages added',
    description: 'Add languages you speak to enhance your profile.',
    actionLabel: 'Add language',
  );

  static const EmptyState noAtsAnalysis = EmptyState(
    icon: Icons.radar_outlined,
    title: 'No ATS analysis yet',
    description: 'Run an ATS analysis on your resume to see how it performs against job descriptions.',
    actionLabel: 'Analyze resume',
  );

  static const EmptyState noSalaryEstimates = EmptyState(
    icon: Icons.payments_outlined,
    title: 'No salary estimates yet',
    description: 'Estimate market compensation for your role and location to know your worth.',
    actionLabel: 'Estimate salary',
  );

  static const EmptyState noAiHistory = EmptyState(
    icon: Icons.auto_awesome_outlined,
    title: 'No AI conversations yet',
    description: 'Start a conversation with Career AI to get personalized career guidance.',
    actionLabel: 'Ask Career AI',
  );

  static const EmptyState noSearchResults = EmptyState(
    icon: Icons.search_off_outlined,
    title: 'No results found',
    description: 'Try adjusting your search or filters.',
  );

  static const EmptyState noData = EmptyState(
    icon: Icons.inbox_outlined,
    title: 'No data available',
    description: 'Pull to refresh or check back later.',
  );

  static const EmptyState offline = EmptyState(
    icon: Icons.wifi_off_outlined,
    title: 'You\'re offline',
    description: 'Check your connection and try again.',
    actionLabel: 'Retry',
  );

  static EmptyState noResumesWithAction(VoidCallback? onAction) => EmptyState(
    icon: Icons.description_outlined,
    title: 'No resumes yet',
    description: 'Create your first resume to unlock ATS analysis, AI insights, and salary comparisons.',
    actionLabel: 'Create resume',
    onAction: onAction,
  );

  static EmptyState noExperienceWithAction(VoidCallback? onAction) => EmptyState(
    icon: Icons.work_outline,
    title: 'No experience added',
    description: 'Add your work experience to build a complete profile and get better career recommendations.',
    actionLabel: 'Add experience',
    onAction: onAction,
  );

  static EmptyState noEducationWithAction(VoidCallback? onAction) => EmptyState(
    icon: Icons.school_outlined,
    title: 'No education added',
    description: 'Add your educational background to strengthen your profile.',
    actionLabel: 'Add education',
    onAction: onAction,
  );

  static EmptyState noSkillsWithAction(VoidCallback? onAction) => EmptyState(
    icon: Icons.bolt_outlined,
    title: 'No skills added',
    description: 'Add your skills to improve ATS matching and get personalized career insights.',
    actionLabel: 'Add skills',
    onAction: onAction,
  );

  static EmptyState noProjectsWithAction(VoidCallback? onAction) => EmptyState(
    icon: Icons.code_outlined,
    title: 'No projects added',
    description: 'Showcase your projects to demonstrate practical experience.',
    actionLabel: 'Add project',
    onAction: onAction,
  );

  static EmptyState noCertificationsWithAction(VoidCallback? onAction) => EmptyState(
    icon: Icons.verified_outlined,
    title: 'No certifications added',
    description: 'Add certifications to validate your expertise.',
    actionLabel: 'Add certification',
    onAction: onAction,
  );

  static EmptyState noLanguagesWithAction(VoidCallback? onAction) => EmptyState(
    icon: Icons.language_outlined,
    title: 'No languages added',
    description: 'Add languages you speak to enhance your profile.',
    actionLabel: 'Add language',
    onAction: onAction,
  );

  static EmptyState noAtsAnalysisWithAction(VoidCallback? onAction) => EmptyState(
    icon: Icons.radar_outlined,
    title: 'No ATS analysis yet',
    description: 'Run an ATS analysis on your resume to see how it performs against job descriptions.',
    actionLabel: 'Analyze resume',
    onAction: onAction,
  );

  static EmptyState noSalaryEstimatesWithAction(VoidCallback? onAction) => EmptyState(
    icon: Icons.payments_outlined,
    title: 'No salary estimates yet',
    description: 'Estimate market compensation for your role and location to know your worth.',
    actionLabel: 'Estimate salary',
    onAction: onAction,
  );

  static EmptyState noAiHistoryWithAction(VoidCallback? onAction) => EmptyState(
    icon: Icons.auto_awesome_outlined,
    title: 'No AI conversations yet',
    description: 'Start a conversation with Career AI to get personalized career guidance.',
    actionLabel: 'Ask Career AI',
    onAction: onAction,
  );

  static EmptyState offlineWithAction(VoidCallback? onAction) => EmptyState(
    icon: Icons.wifi_off_outlined,
    title: 'You\'re offline',
    description: 'Check your connection and try again.',
    actionLabel: 'Retry',
    onAction: onAction,
  );
}

class EmptyStateBuilder extends StatelessWidget {
  final bool isEmpty;
  final bool isLoading;
  final Widget child;
  final EmptyState emptyState;
  final Widget? loadingWidget;

  const EmptyStateBuilder({
    super.key,
    required this.isEmpty,
    required this.isLoading,
    required this.child,
    required this.emptyState,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ?? const Center(child: CircularProgressIndicator());
    }
    if (isEmpty) {
      return Center(child: SingleChildScrollView(child: emptyState));
    }
    return child;
  }
}