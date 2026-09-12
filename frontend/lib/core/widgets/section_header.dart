import 'package:flutter/material.dart';
import '../../core/design/design.dart';
import 'app_card.dart';

/// The single icon-badge + title (+ subtitle) + trailing-action header used
/// at the top of nearly every card and section across the app. Centralizing
/// it keeps every screen visually consistent and automatically safe against
/// overflow (title/subtitle always shrink with an ellipsis instead of
/// blowing out the row) rather than each screen re-implementing its own
/// slightly-different, occasionally-unsafe version.
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Color? iconBackground;
  final Widget? trailing;
  final TextStyle? titleStyle;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.iconBackground,
    this.trailing,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: iconBackground ?? color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: titleStyle ?? AppTypography.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              if (subtitle != null)
                Text(subtitle!, style: AppTypography.bodySmall.muted(), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}

/// A plain page-level title used under a SliverAppBar (no icon badge) --
/// for the large "Good morning, Alex" / "Resume Studio" style headlines.
class PageHeading extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const PageHeading({super.key, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.headlineLarge),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(subtitle!, style: AppTypography.bodyLarge.muted()),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// A visually distinct, elevated panel reserved for the single most
/// important element on a screen (a hero metric, an AI identity header).
/// Using it sparingly is what gives a page hierarchy instead of a wall of
/// identical flat cards -- most content should stay on plain AppCard.
class HeroPanel extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;

  const HeroPanel({
    super.key,
    required this.child,
    this.gradient,
    this.padding = AppSpacing.xxlAll,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryContainer.withValues(alpha: 0.65), AppColors.surfaceElevated],
            ),
        borderRadius: AppRadii.card,
        border: Border.all(color: borderColor ?? AppColors.borderStrong, width: 0.5),
        boxShadow: AppElevation.level2,
      ),
      child: child,
    );
  }
}

/// A flat, low-emphasis list row for secondary/navigational content (e.g.
/// "Quick Actions") so it doesn't visually compete with primary cards above
/// it -- deliberately quieter than AppCard, with a hairline divider handled
/// by the parent ListSectionCard rather than its own border/shadow.
class QuietListTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const QuietListTile({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.iconColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.textSecondary).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(icon, color: iconColor ?? AppColors.textSecondary, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (subtitle != null)
                    Text(subtitle!, style: AppTypography.bodySmall.muted(), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            trailing ?? (onTap != null ? Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 18) : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

/// A grouped card of rows with automatic hairline dividers between them --
/// the Apple Settings look. Each entry in [children] becomes one row.
class ListSectionCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final double dividerIndent;

  const ListSectionCard({super.key, this.title, required this.children, this.dividerIndent = 56});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.sm),
            child: Text(title!, style: AppTypography.overline),
          ),
        ],
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  Divider(height: 1, indent: dividerIndent, color: AppColors.border),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
