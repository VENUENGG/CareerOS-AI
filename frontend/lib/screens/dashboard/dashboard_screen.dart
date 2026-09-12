import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/design/design.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CareerDataProvider>().loadAll();
    });
  }

  Future<void> _refresh() async {
    await context.read<CareerDataProvider>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final data = context.watch<CareerDataProvider>();
    final profile = auth.profileData;
    final completion = _calculateCompletion(profile, data);

    return CustomScrollView(
      slivers: [
        _buildAppBar(context, profile, completion),
        SliverToBoxAdapter(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: _buildBody(data, profile, completion),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(CareerDataProvider data, UserProfile? profile, int completion) {
    if (data.loading && data.resumes.isEmpty && data.skills.isEmpty) {
      return _buildLoadingState();
    }

    if (data.error != null) {
      return _buildErrorState(data.error!, _refresh);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        final isTablet = constraints.maxWidth >= 600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(profile),
            const SizedBox(height: AppSpacing.xxxl),
            _buildCareerHealth(completion),
            const SizedBox(height: AppSpacing.xxxl),
            _buildQuickStats(data),
            const SizedBox(height: AppSpacing.xxxl),
            if (isDesktop) ...[
              _buildDesktopLayout(data, profile, completion),
            ] else if (isTablet) ...[
              _buildTabletLayout(data, profile, completion),
            ] else ...[
              _buildMobileLayout(data, profile, completion),
            ],
            const SizedBox(height: AppSpacing.xxxl),
          ],
        );
      },
    );
  }

  Widget _buildMobileLayout(CareerDataProvider data, UserProfile? profile, int completion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCurrentRoleSection(profile),
        const SizedBox(height: AppSpacing.xxl),
        _buildAIInsights(profile, data),
        const SizedBox(height: AppSpacing.xxl),
        _buildNextActions(context, profile, data),
        const SizedBox(height: AppSpacing.xxl),
        _buildQuickActions(context),
      ],
    );
  }

  Widget _buildTabletLayout(CareerDataProvider data, UserProfile? profile, int completion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentRoleSection(profile),
                  const SizedBox(height: AppSpacing.lg),
                  _buildAIInsights(profile, data),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNextActions(context, profile, data),
                  const SizedBox(height: AppSpacing.lg),
                  _buildQuickActions(context),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(CareerDataProvider data, UserProfile? profile, int completion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentRoleSection(profile),
                  const SizedBox(height: AppSpacing.lg),
                  _buildAIInsights(profile, data),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNextActions(context, profile, data),
                  const SizedBox(height: AppSpacing.lg),
                  _buildQuickActions(context),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xxxl),
        LoadingSkeletonList(itemCount: 6, lines: 3, showAvatar: false),
        const SizedBox(height: AppSpacing.xxl),
        LoadingSkeletonList(itemCount: 4, lines: 2, showAvatar: false),
      ],
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xxxl),
        ErrorStateVariant.networkError(onRetry: onRetry),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, UserProfile? profile, int completion) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: AppSpacing.horizontalLg.copyWith(bottom: 16),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Dashboard', style: AppTypography.titleLarge),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: _completionColor(completion).withValues(alpha: 0.15),
                    borderRadius: AppRadii.chip,
                  ),
                  child: Text(
                    '$completion% Complete',
                    style: AppTypography.labelSmall.copyWith(color: _completionColor(completion), fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (profile?.currentJobTitle != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: AppRadii.chip),
                    child: Text(profile!.currentJobTitle!, style: AppTypography.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: Row(
            children: [
              AppIconButton(
                icon: const Icon(Icons.notifications_outlined, size: 22),
                onPressed: () {},
                tooltip: 'Notifications',
              ),
              const SizedBox(width: AppSpacing.sm),
              AppIconButton(
                icon: const Icon(Icons.settings_outlined, size: 22),
                onPressed: () => context.go('/settings'),
                tooltip: 'Settings',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting(UserProfile? profile) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    final name = profile?.firstName ?? 'there';
    final avatarController = context.watch<AvatarController>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppAvatar(
          imageUrl: profile?.profilePhotoUrl,
          initials: avatarController.initials,
          radius: 28,
          onTap: () => context.go('/profile'),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$greeting, $name', style: AppTypography.headlineLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: AppSpacing.xs),
              Text(
                profile?.headline ?? 'Your career, organized intelligently.',
                style: AppTypography.bodyLarge.muted(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCareerHealth(int completion) {
    final color = _completionColor(completion);
    final icon = _completionIcon(completion);

    // The single most important metric on the dashboard gets the one hero
    // treatment on the page -- everything else stays on plain AppCard so
    // this doesn't have to compete with a wall of identical containers.
    return HeroPanel(
      padding: AppSpacing.xxlAll,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color.withValues(alpha: 0.16), AppColors.surfaceElevated],
      ),
      borderColor: color.withValues(alpha: 0.3),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  icon: Icons.favorite_outline_rounded,
                  title: 'Career Health',
                  iconColor: color,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _healthDescription(completion),
                  style: AppTypography.bodyMedium.muted(),
                ),
                const SizedBox(height: AppSpacing.lg),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: completion / 100,
                    minHeight: 10,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Text('$completion% complete', style: AppTypography.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(child: Text(_nextMilestone(completion), style: AppTypography.labelSmall.primary(), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          CircularProgressCard(
            label: '',
            progress: completion / 100,
            value: '$completion%',
            size: 80,
            strokeWidth: 8,
            progressColor: color,
            centerChild: Icon(icon, size: 28, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(CareerDataProvider data) {
    final stats = [
      _StatDatum('Skills', '${data.skills.length}', Icons.bolt_rounded, AppColors.primary, () => context.go('/profile')),
      _StatDatum('Experience', '${data.experience.length}', Icons.work_outline_rounded, AppColors.info, () => context.go('/profile')),
      _StatDatum('Projects', '${data.projects.length}', Icons.code_rounded, AppColors.success, () => context.go('/profile')),
      _StatDatum('Resumes', '${data.resumes.length}', Icons.description_outlined, AppColors.warning, () => context.go('/resume')),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Overview', style: AppTypography.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
            TextButton(
              onPressed: () => context.go('/profile'),
              child: Text('View all', style: AppTypography.labelMedium.primary()),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        data.loading
            ? LoadingSkeletonList(itemCount: 1, lines: 2, showAvatar: false)
            // A single dense strip (not four separate cards) -- a compact
            // row of numbers is what makes a dashboard read as a product,
            // not a stack of identical containers.
            : LayoutBuilder(
                builder: (context, constraints) {
                  final perRow = constraints.maxWidth >= 560 ? 4 : 2;
                  final spacing = AppSpacing.md;
                  final itemWidth = (constraints.maxWidth - spacing * (perRow - 1)) / perRow;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [for (final s in stats) SizedBox(width: itemWidth, child: _StatStripTile(datum: s))],
                  );
                },
              ),
      ],
    );
  }

  Widget _buildCurrentRoleSection(UserProfile? profile) {
    if (profile?.currentJobTitle == null && profile?.headline == null) {
      return _EmptyStateCard(
        title: 'Current Role',
        message: 'Add your current position to unlock personalized insights',
        actionLabel: 'Add Role',
        onAction: () => context.go('/profile'),
        icon: Icons.work_outline_rounded,
      );
    }

    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.work_outline_rounded,
            title: 'Current Role',
            subtitle: 'Your professional snapshot',
          ),
          const SizedBox(height: AppSpacing.lg),
          _RoleItem(
            icon: Icons.work_outline_rounded,
            label: 'Current Position',
            value: profile?.currentJobTitle ?? 'Not specified',
            subtitle: _formatLocation(profile),
          ),
          if (profile?.headline != null) ...[
            Divider(height: 1, color: AppColors.border),
            _RoleItem(
              icon: Icons.flag_outlined,
              label: 'Career Headline',
              value: profile!.headline!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAIInsights(UserProfile? profile, CareerDataProvider data) {
    if (profile?.currentJobTitle == null) {
      return const SizedBox.shrink();
    }

    return AppCard(
      padding: AppSpacing.cardPadding,
      // A faint AI tint on an otherwise-plain card gives this section its
      // own identity without escalating it to a full HeroPanel treatment.
      color: AppColors.aiContainer.withValues(alpha: 0.14),
      border: Border.all(color: AppColors.ai.withValues(alpha: 0.25), width: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.auto_awesome_outlined,
            title: 'AI Insights',
            subtitle: 'Personalized recommendations',
            iconColor: AppColors.ai,
          ),
          const SizedBox(height: AppSpacing.lg),
          AIInsightCard(
            title: 'Resume Readiness',
            content: data.resumes.isEmpty
                ? 'Create your first resume to get ATS analysis and salary comparisons.'
                : 'You have ${data.resumes.length} resume${data.resumes.length > 1 ? 's' : ''}. Consider tailoring one for your target role.',
            icon: Icons.description_outlined,
            color: AppColors.info,
            actions: data.resumes.isEmpty ? ['Create Resume'] : ['View Resumes'],
            onAction: (action) => context.go('/resume'),
          ),
          const SizedBox(height: AppSpacing.md),
          AIInsightCard(
            title: 'Skill Gaps',
            content: data.skills.length < 5
                ? 'Add more skills to improve ATS matching and get better career recommendations.'
                : 'Your skill set looks solid. Consider adding trending skills in your field.',
            icon: Icons.bolt_outlined,
            color: AppColors.warning,
            actions: ['Add Skills'],
            onAction: (action) => context.go('/profile'),
          ),
          const SizedBox(height: AppSpacing.md),
          AIInsightCard(
            title: 'Market Value',
            content: 'Run a salary estimate to see how your compensation compares to the market.',
            icon: Icons.payments_outlined,
            color: AppColors.success,
            actions: ['Estimate Salary'],
            onAction: (action) => context.go('/salary'),
          ),
        ],
      ),
    );
  }

  Widget _buildNextActions(BuildContext context, UserProfile? profile, CareerDataProvider data) {
    final actions = <_ActionItem>[];

    if (data.resumes.isEmpty) {
      actions.add(_ActionItem(
        icon: Icons.description_outlined,
        label: 'Create your first resume',
        subtitle: 'Unlock ATS analysis and job applications',
        color: AppColors.primary,
        onTap: () => context.go('/resume'),
      ));
    } else if (data.resumes.length == 1) {
      actions.add(_ActionItem(
        icon: Icons.radar_outlined,
        label: 'Run ATS analysis',
        subtitle: 'See how your resume performs against job descriptions',
        color: AppColors.info,
        onTap: () => context.go('/ats'),
      ));
    }

    if (profile?.currentJobTitle != null) {
      actions.add(_ActionItem(
        icon: Icons.payments_outlined,
        label: 'Check market salary',
        subtitle: 'Compare your compensation to industry standards',
        color: AppColors.success,
        onTap: () => context.go('/salary'),
      ));
    }

    if (data.skills.length < 10) {
      actions.add(_ActionItem(
        icon: Icons.bolt_outlined,
        label: 'Add more skills',
        subtitle: 'Improve profile completeness and AI recommendations',
        color: AppColors.warning,
        onTap: () => context.go('/profile'),
      ));
    }

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(icon: Icons.flag_outlined, title: 'Next Best Actions'),
          const SizedBox(height: AppSpacing.lg),
          ...actions.map((action) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _ActionCard(item: action),
          )),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    // Deliberately the quietest section on the page: a plain grouped list
    // (matching Settings' rows) rather than another stack of bordered
    // cards, so it reads as secondary navigation, not a competing priority.
    return ListSectionCard(
      title: 'Quick Actions',
      children: [
        QuietListTile(
          icon: Icons.auto_awesome_rounded,
          label: 'Career AI',
          subtitle: 'Get an AI career assessment and roadmap',
          iconColor: AppColors.ai,
          onTap: () => context.go('/ai'),
        ),
        QuietListTile(
          icon: Icons.description_outlined,
          label: 'Resume Studio',
          subtitle: 'Build and manage your resumes',
          iconColor: AppColors.primary,
          onTap: () => context.go('/resume'),
        ),
        QuietListTile(
          icon: Icons.radar_rounded,
          label: 'ATS Analyzer',
          subtitle: 'Measure a resume against a role',
          iconColor: AppColors.info,
          onTap: () => context.go('/ats'),
        ),
        QuietListTile(
          icon: Icons.payments_rounded,
          label: 'Salary Intelligence',
          subtitle: 'Estimate and compare market compensation',
          iconColor: AppColors.success,
          onTap: () => context.go('/salary'),
        ),
      ],
    );
  }

  int _calculateCompletion(UserProfile? profile, CareerDataProvider data) {
    int score = 0;
    if (profile?.firstName != null) score += 10;
    if (profile?.lastName != null) score += 5;
    if (profile?.headline != null) score += 10;
    if (profile?.currentJobTitle != null) score += 15;
    if (profile?.bio != null) score += 10;
    if (profile?.city != null) score += 5;
    if (data.experience.isNotEmpty) score += 15;
    if (data.education.isNotEmpty) score += 10;
    if (data.skills.length >= 5) score += 10;
    if (data.projects.isNotEmpty) score += 5;
    if (data.resumes.isNotEmpty) score += 5;
    return score.clamp(0, 100);
  }

  Color _completionColor(int completion) {
    if (completion >= 80) return AppColors.success;
    if (completion >= 50) return AppColors.warning;
    return AppColors.info;
  }

  IconData _completionIcon(int completion) {
    if (completion >= 80) return Icons.check_circle_rounded;
    if (completion >= 50) return Icons.trending_up_rounded;
    return Icons.insights_rounded;
  }

  String _healthDescription(int completion) {
    if (completion >= 80) return 'Your profile is strong and ready for opportunities.';
    if (completion >= 50) return 'Good foundation. Add more details to improve visibility.';
    return 'Your profile needs work. Complete key sections to unlock full features.';
  }

  String _nextMilestone(int completion) {
    if (completion >= 80) return 'Maintain excellence';
    if (completion >= 50) return '${80 - completion}% to strong';
    return '${50 - completion}% to good';
  }

  String _formatLocation(UserProfile? profile) {
    final parts = <String>[];
    if (profile?.city != null) parts.add(profile!.city!);
    if (profile?.state != null) parts.add(profile!.state!);
    if (profile?.country != null) parts.add(profile!.country!);
    return parts.isEmpty ? 'Not specified' : parts.join(', ');
  }
}

class _EmptyStateCard extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData icon;

  const _EmptyStateCard({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(icon: icon, title: title, subtitle: message),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: actionLabel,
            onPressed: onAction,
            style: AppButtonStyle.ghost,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }
}

class _RoleItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  const _RoleItem({required this.icon, required this.label, required this.value, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(AppRadii.md)),
            child: Icon(icon, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.bodySmall.muted()),
                Text(value, style: AppTypography.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (subtitle != null) Text(subtitle!, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  _ActionItem({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});
}

class _ActionCard extends StatelessWidget {
  final _ActionItem item;

  const _ActionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: item.onTap,
      borderRadius: AppRadii.card,
      child: AppCard(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(color: item.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppRadii.lg)),
              child: Icon(item.icon, color: item.color, size: 24),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label, style: AppTypography.bodyLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(item.subtitle, style: AppTypography.bodySmall.muted()),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textTertiary, size: 16),
          ],
        ),
      ),
    );
  }
}

class _StatDatum {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _StatDatum(this.label, this.value, this.icon, this.color, this.onTap);
}

/// A dense, low-chrome stat cell -- icon, big number, label -- meant to sit
/// edge-to-edge with its siblings in a Wrap rather than as its own bordered
/// card, which is what makes the Overview section read as one compact strip.
class _StatStripTile extends StatelessWidget {
  final _StatDatum datum;

  const _StatStripTile({required this.datum});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: datum.onTap,
      borderRadius: AppRadii.cardCompact,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(datum.icon, color: datum.color, size: 18),
            const SizedBox(height: AppSpacing.sm),
            Text(datum.value, style: AppTypography.headlineSmall),
            Text(datum.label, style: AppTypography.bodySmall.muted(), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}