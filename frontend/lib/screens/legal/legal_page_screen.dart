import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/design.dart';
import '../../core/widgets/widgets.dart';

class LegalSection {
  final String heading;
  final String body;
  const LegalSection(this.heading, this.body);
}

/// Renders any of the app's legal/info documents (Privacy Policy, Terms,
/// About) from structured content rather than a WebView or a "Coming Soon"
/// placeholder -- one shared, premium-typeset page instead of three
/// near-duplicate screens.
class LegalPageScreen extends StatelessWidget {
  final String title;
  final String lastUpdated;
  final String intro;
  final List<LegalSection> sections;

  const LegalPageScreen({
    super.key,
    required this.title,
    required this.lastUpdated,
    required this.intro,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: false,
          pinned: true,
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(title, style: AppTypography.titleLarge),
          leading: AppIconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 22),
            onPressed: () => context.pop(),
          ),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.headlineLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Last updated: $lastUpdated', style: AppTypography.bodySmall.muted()),
                    const SizedBox(height: AppSpacing.xl),
                    Text(intro, style: AppTypography.bodyLarge.copyWith(height: 1.6)),
                    const SizedBox(height: AppSpacing.xxl),
                    for (final section in sections) ...[
                      Text(section.heading, style: AppTypography.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Text(section.body, style: AppTypography.bodyMedium.copyWith(height: 1.6).muted()),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    Container(
                      padding: AppSpacing.cardPadding,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: AppRadii.card,
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.textTertiary),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'This is a first-version product policy, not a substitute for review by a qualified lawyer before a commercial launch.',
                              style: AppTypography.bodySmall.muted(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
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
