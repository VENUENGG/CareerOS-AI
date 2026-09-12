import 'package:flutter/material.dart';
import '../../core/design/design.dart';
import 'app_card.dart';
import 'app_chip.dart';
import 'app_button.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final Color? valueColor;
  final String? trend;
  final AppTrendDirection? trendDirection;
  final VoidCallback? onTap;
  final Widget? action;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.valueColor,
    this.trend,
    this.trendDirection,
    this.onTap,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final card = AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primary).withValues(alpha: 0.15),
borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Icon(icon, size: 20, color: iconColor ?? AppColors.primary),
                )
              else if (action != null)
                const Spacer()
              else
                const SizedBox.shrink(),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(value, style: AppTypography.displaySmall.copyWith(color: valueColor ?? AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Text(label, style: AppTypography.bodySmall.muted()),
              if (trend != null && trendDirection != null) ...[
                const SizedBox(width: AppSpacing.md),
                _TrendIndicator(value: trend!, direction: trendDirection!),
              ],
            ],
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Pressable(onTap: onTap, radius: AppRadii.xl, child: card);
    }

    return card;
  }
}

class _TrendIndicator extends StatelessWidget {
  final String value;
  final AppTrendDirection direction;

  const _TrendIndicator({required this.value, required this.direction});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (direction) {
      AppTrendDirection.up => (AppColors.success, Icons.trending_up_rounded),
      AppTrendDirection.down => (AppColors.danger, Icons.trending_down_rounded),
      AppTrendDirection.neutral => (AppColors.textTertiary, Icons.trending_flat_rounded),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(value, style: AppTypography.labelSmall.copyWith(color: color)),
      ],
    );
  }
}

enum AppTrendDirection { up, down, neutral }

class StatCardGrid extends StatelessWidget {
  final List<StatCard> cards;
  final int crossAxisCount;
  final double spacing;

  const StatCardGrid({
    super.key,
    required this.cards,
    this.crossAxisCount = 2,
    this.spacing = AppSpacing.md,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth > 600 ? (crossAxisCount * 2).clamp(2, 4) : crossAxisCount;
        // A fixed childAspectRatio (the previous GridView.count approach)
        // forces every cell to a fixed height regardless of what its content
        // actually needs -- it overflows the moment a trend indicator is
        // present, a value is long, or the system font size is scaled up.
        // Wrap lets each card claim its own natural height instead.
        final itemWidth = (constraints.maxWidth - spacing * (count - 1)) / count;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in cards) SizedBox(width: itemWidth, child: card),
          ],
        );
      },
    );
  }
}

class ProgressCard extends StatelessWidget {
  final String label;
  final double progress;
  final String? value;
  final Color? progressColor;
  final Color? trackColor;
  final double height;
  final BorderRadius? borderRadius;
  final Widget? trailing;

  const ProgressCard({
    super.key,
    required this.label,
    required this.progress,
    this.value,
    this.progressColor,
    this.trackColor,
    this.height = 8,
    this.borderRadius,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: AppTypography.bodyMedium)),
              if (value != null) Text(value!, style: AppTypography.labelMedium.primary()),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: height,
              backgroundColor: trackColor ?? AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor ?? AppColors.primary),
              borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
            ),
          ),
        ],
      ),
    );
  }
}

class CircularProgressCard extends StatelessWidget {
  final String label;
  final double progress;
  final String? value;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? trackColor;
  final Widget? centerChild;

  const CircularProgressCard({
    super.key,
    required this.label,
    required this.progress,
    this.value,
    this.size = 80,
    this.strokeWidth = 6,
    this.progressColor,
    this.trackColor,
    this.centerChild,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                strokeWidth: strokeWidth,
                backgroundColor: trackColor ?? AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor ?? AppColors.primary),
                strokeCap: StrokeCap.round,
              ),
            ),
            if (centerChild != null) centerChild!,
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(label, style: AppTypography.bodyMedium, textAlign: TextAlign.center),
        if (value != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(value!, style: AppTypography.headlineSmall.primary(), textAlign: TextAlign.center),
        ],
      ],
    );
  }
}

class ScoreCard extends StatelessWidget {
  final int score;
  final String label;
  final String? subtitle;
  final List<ScoreBreakdown> breakdown;
  final Color? scoreColor;
  final VoidCallback? onTap;

  const ScoreCard({
    super.key,
    required this.score,
    required this.label,
    this.subtitle,
    this.breakdown = const [],
    this.scoreColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = scoreColor ?? _scoreColor(score);
    final card = AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTypography.titleMedium),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(subtitle!, style: AppTypography.bodySmall.muted()),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$score', style: AppTypography.displayMedium.copyWith(color: effectiveColor)),
                  Text('/ 100', style: AppTypography.bodySmall.muted()),
                ],
              ),
            ],
          ),
          if (breakdown.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            ...breakdown.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _ScoreBreakdownRow(item: item),
            )),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return Pressable(onTap: onTap, radius: AppRadii.xl, child: card);
    }

    return card;
  }

  Color _scoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    if (score >= 40) return AppColors.info;
    return AppColors.danger;
  }
}

class ScoreBreakdown {
  final String label;
  final int score;
  final Color? color;

  const ScoreBreakdown({required this.label, required this.score, this.color});
}

class _ScoreBreakdownRow extends StatelessWidget {
  final ScoreBreakdown item;

  const _ScoreBreakdownRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.color ?? _scoreColor(item.score);
    return Row(
      children: [
        SizedBox(width: 100, child: Text(item.label, style: AppTypography.bodySmall)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: item.score / 100,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text('${item.score}%', style: AppTypography.labelSmall.copyWith(color: color)),
      ],
    );
  }

  Color _scoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    if (score >= 40) return AppColors.info;
    return AppColors.danger;
  }
}

class ResumeCard extends StatelessWidget {
  final String id;
  final String title;
  final String? template;
  final bool? isPublic;
  final DateTime? updatedAt;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;
  final VoidCallback? onUseForAts;
  final bool selected;

  const ResumeCard({
    super.key,
    required this.id,
    required this.title,
    this.template,
    this.isPublic,
    this.updatedAt,
    this.onTap,
    this.onEdit,
    this.onDuplicate,
    this.onUseForAts,
    this.onDelete,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppSpacing.cardPadding,
      border: selected ? Border.all(color: AppColors.primary, width: 2) : Border.all(color: AppColors.border, width: 0.5),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: const Center(child: Icon(Icons.description_outlined, color: AppColors.primary, size: 24)),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: AppSpacing.xs),
                // Wrap so template/visibility badges plus the "updated"
                // timestamp fold onto a second line instead of overflowing
                // in narrower cards (grid layouts, smaller breakpoints).
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (template != null)
                      AppChip(label: template!, style: AppChipStyle.assist, onPressed: null),
                    if (isPublic == true)
                      AppBadge(label: 'Public', style: AppBadgeStyle.success)
                    else
                      AppBadge(label: 'Private', style: AppBadgeStyle.neutral),
                    if (updatedAt != null)
                      Text(
                        'Updated ${_formatDate(updatedAt!)}',
                        style: AppTypography.caption,
                      ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textTertiary),
            onSelected: (value) {
              switch (value) {
                case 'edit': onEdit?.call(); break;
                case 'duplicate': onDuplicate?.call(); break;
                case 'ats': onUseForAts?.call(); break;
                case 'delete': onDelete?.call(); break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
              const PopupMenuItem(value: 'ats', child: Text('Use for ATS Analysis')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.danger))),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class ATSScoreCard extends StatelessWidget {
  final int overallScore;
  final int keywordScore;
  final int skillsScore;
  final int experienceScore;
  final int educationScore;
  final int formattingScore;
  final List<String> matchedKeywords;
  final List<String> missingKeywords;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> suggestions;
  final String? jobTitle;
  final DateTime? analyzedAt;

  const ATSScoreCard({
    super.key,
    required this.overallScore,
    required this.keywordScore,
    required this.skillsScore,
    required this.experienceScore,
    required this.educationScore,
    required this.formattingScore,
    this.matchedKeywords = const [],
    this.missingKeywords = const [],
    this.strengths = const [],
    this.weaknesses = const [],
    this.suggestions = const [],
    this.jobTitle,
    this.analyzedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCard(
          padding: AppSpacing.cardPadding,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ATS Score', style: AppTypography.titleMedium),
                        if (jobTitle != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text('vs "$jobTitle"', style: AppTypography.bodySmall.muted()),
                        ],
                        if (analyzedAt != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text('Analyzed ${_formatDate(analyzedAt!)}', style: AppTypography.caption),
                        ],
                      ],
                    ),
                  ),
                  CircularProgressCard(
                    label: '',
                    progress: overallScore / 100,
                    value: '$overallScore',
                    size: 72,
                    strokeWidth: 8,
                    progressColor: _scoreColor(overallScore),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              _ScoreRow(label: 'Keywords', score: keywordScore),
              _ScoreRow(label: 'Skills', score: skillsScore),
              _ScoreRow(label: 'Experience', score: experienceScore),
              _ScoreRow(label: 'Education', score: educationScore),
              _ScoreRow(label: 'Formatting', score: formattingScore),
            ],
          ),
        ),
        if (matchedKeywords.isNotEmpty || missingKeywords.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          AppCardSection(
            title: 'Keyword Analysis',
            child: Column(
              children: [
                if (matchedKeywords.isNotEmpty) _KeywordList(title: 'Matched', keywords: matchedKeywords, color: AppColors.success),
                if (missingKeywords.isNotEmpty) _KeywordList(title: 'Missing', keywords: missingKeywords, color: AppColors.danger),
              ],
            ),
          ),
        ],
        if (strengths.isNotEmpty || weaknesses.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          AppCardSection(
            title: 'Assessment',
            child: Column(
              children: [
                if (strengths.isNotEmpty) _AssessmentList(title: 'Strengths', items: strengths, icon: Icons.check_circle_rounded, color: AppColors.success),
                if (weaknesses.isNotEmpty) _AssessmentList(title: 'Weaknesses', items: weaknesses, icon: Icons.cancel_rounded, color: AppColors.danger),
              ],
            ),
          ),
        ],
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          AppCardSection(
            title: 'Recommendations',
            child: Column(
              children: suggestions.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppColors.info),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text(s, style: AppTypography.bodyMedium)),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _scoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    if (score >= 40) return AppColors.info;
    return AppColors.danger;
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final int score;

  const _ScoreRow({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(score);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: AppTypography.bodyMedium)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text('$score%', style: AppTypography.labelMedium.copyWith(color: color)),
        ],
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    if (score >= 40) return AppColors.info;
    return AppColors.danger;
  }
}

class _KeywordList extends StatelessWidget {
  final String title;
  final List<String> keywords;
  final Color color;

  const _KeywordList({required this.title, required this.keywords, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: AppTypography.labelMedium.copyWith(color: color)),
              const SizedBox(width: AppSpacing.sm),
              AppBadge(label: '${keywords.length}', style: AppBadgeStyle.neutral),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: keywords.map((k) => AppChip(label: k, style: AppChipStyle.outlined)).toList(),
          ),
        ],
      ),
    );
  }
}

class _AssessmentList extends StatelessWidget {
  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;

  const _AssessmentList({required this.title, required this.items, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: AppSpacing.sm),
              Text(title, style: AppTypography.labelMedium.copyWith(color: color)),
              const SizedBox(width: AppSpacing.sm),
              AppBadge(label: '${items.length}', style: AppBadgeStyle.neutral),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 16, color: color.withValues(alpha: 0.7)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(item, style: AppTypography.bodyMedium)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class SalaryRangeCard extends StatelessWidget {
  final String currency;
  final double? minSalary;
  final double? expectedSalary;
  final double? maxSalary;
  final String? marketPosition;
  final String? currentSalary;
  final double? percentageDifference;
  final List<String> factors;
  final List<String> skillPremiums;
  final VoidCallback? onTap;

  const SalaryRangeCard({
    super.key,
    required this.currency,
    this.minSalary,
    this.expectedSalary,
    this.maxSalary,
    this.marketPosition,
    this.currentSalary,
    this.percentageDifference,
    this.factors = const [],
    this.skillPremiums = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Market Estimate', style: AppTypography.titleMedium),
                    if (marketPosition != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      AppBadge(label: marketPosition!, style: AppBadgeStyle.info),
                    ],
                  ],
                ),
              ),
              if (percentageDifference != null)
                _DifferenceBadge(difference: percentageDifference!),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(child: _SalaryPoint(label: 'Min', value: minSalary, color: AppColors.textTertiary)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _SalaryPoint(label: 'Expected', value: expectedSalary, color: AppColors.primary, highlight: true)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _SalaryPoint(label: 'Max', value: maxSalary, color: AppColors.success)),
            ],
          ),
          if (minSalary != null && maxSalary != null && expectedSalary != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _SalaryRangeBar(min: minSalary!, expected: expectedSalary!, max: maxSalary!),
          ],
          if (currentSalary != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: AppRadii.cardCompact),
              child: Row(
                children: [
                  Icon(Icons.person_outline_rounded, color: AppColors.textTertiary, size: 20),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text('Your current: $currentSalary', style: AppTypography.bodyMedium)),
                  if (percentageDifference != null)
                    _DifferenceBadge(difference: percentageDifference!, compact: true),
                ],
              ),
            ),
          ],
          if (factors.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text('Key Factors', style: AppTypography.labelMedium),
            const SizedBox(height: AppSpacing.md),
            Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: factors.map((f) => AppChip(label: f, style: AppChipStyle.outlined)).toList()),
          ],
          if (skillPremiums.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text('Skill Premiums', style: AppTypography.labelMedium),
            const SizedBox(height: AppSpacing.md),
            Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: skillPremiums.map((s) => AppChip(label: s, style: AppChipStyle.ai)).toList()),
          ],
        ],
      ),
    );
  }
}

class _SalaryPoint extends StatelessWidget {
  final String label;
  final double? value;
  final Color color;
  final bool highlight;

  const _SalaryPoint({required this.label, this.value, required this.color, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: AppTypography.caption.copyWith(color: color)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value != null ? _formatSalary(value!) : '—',
          style: (highlight ? AppTypography.headlineSmall : AppTypography.titleLarge).copyWith(color: color, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  String _formatSalary(double salary) {
    if (salary >= 1000000) return '${(salary / 1000000).toStringAsFixed(1)}M';
    if (salary >= 1000) return '${(salary / 1000).toStringAsFixed(0)}K';
    return salary.toStringAsFixed(0);
  }
}

/// Where "expected" actually sits between the market min and max -- a
/// number is honest but a position on a track is instantly readable.
class _SalaryRangeBar extends StatelessWidget {
  final double min;
  final double expected;
  final double max;

  const _SalaryRangeBar({required this.min, required this.expected, required this.max});

  @override
  Widget build(BuildContext context) {
    final span = max - min;
    final ratio = span <= 0 ? 0.5 : ((expected - min) / span).clamp(0.0, 1.0);

    return SizedBox(
      height: 20,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const markerSize = 14.0;
          final trackWidth = constraints.maxWidth;
          final markerX = (ratio * trackWidth).clamp(markerSize / 2, trackWidth - markerSize / 2);
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: LinearGradient(colors: [AppColors.textTertiary.withValues(alpha: 0.4), AppColors.primary, AppColors.success.withValues(alpha: 0.6)]),
                ),
              ),
              Positioned(
                left: markerX - markerSize / 2,
                child: Container(
                  width: markerSize,
                  height: markerSize,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.onPrimary, width: 2),
                    boxShadow: AppElevation.colored(AppColors.primary, intensity: 0.5),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DifferenceBadge extends StatelessWidget {
  final double difference;
  final bool compact;

  const _DifferenceBadge({required this.difference, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final isPositive = difference > 0;
    final color = isPositive ? AppColors.success : AppColors.danger;
    final icon = isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded;
    final label = '${isPositive ? '+' : ''}${difference.toStringAsFixed(1)}%';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? AppSpacing.sm : AppSpacing.md, vertical: compact ? AppSpacing.xs : AppSpacing.sm),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: AppRadii.chip),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTypography.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}

class AIInsightCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;
  final List<String>? actions;
  final ValueChanged<String>? onAction;

  const AIInsightCard({
    super.key,
    required this.title,
    required this.content,
    this.icon = Icons.auto_awesome_outlined,
    this.color = AppColors.ai,
    this.actions,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppRadii.md)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(title, style: AppTypography.titleMedium)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(content, style: AppTypography.bodyMedium),
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: actions!.map((a) => AppButton(label: a, onPressed: () => onAction?.call(a), style: AppButtonStyle.ghost, size: AppButtonSize.small)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class ProfileCompletionCard extends StatelessWidget {
  final int percentage;
  final List<ProfileSection> sections;
  final VoidCallback? onCompleteSection;

  const ProfileCompletionCard({
    super.key,
    required this.percentage,
    required this.sections,
    this.onCompleteSection,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Profile Completion', style: AppTypography.titleMedium)),
              CircularProgressCard(label: '', progress: percentage / 100, value: '$percentage%', size: 60, strokeWidth: 6),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(_progressColor(percentage)),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ...sections.map((section) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                Icon(
                  section.complete ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: section.complete ? AppColors.success : AppColors.textTertiary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(section.title, style: AppTypography.bodyMedium.copyWith(color: section.complete ? AppColors.textPrimary : AppColors.textSecondary))),
                if (!section.complete)
                  AppButton(label: 'Add', onPressed: () => onCompleteSection?.call(), style: AppButtonStyle.ghost, size: AppButtonSize.small),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Color _progressColor(int percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 50) return AppColors.warning;
    return AppColors.info;
  }
}

class ProfileSection {
  final String title;
  final bool complete;

  const ProfileSection({required this.title, required this.complete});
}