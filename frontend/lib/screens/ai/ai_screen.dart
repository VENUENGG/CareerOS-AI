import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/design/design.dart';
import '../../core/validation/validation.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';
import '../../repositories/careeros_repository.dart';
import '../../core/network/api_client.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _goalController = TextEditingController();
  final _promptController = TextEditingController();

  CareerCoach? _coach;
  String? _answer;
  bool _coachBusy = false;
  bool _chatBusy = false;
  String? _coachError;
  String? _chatError;

  late final CareerOSRepository _repository;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: AppMotion.medium, vsync: this);
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: AppMotion.decelerate));
    _animationController.forward();
    _repository = context.read<CareerOSRepository>();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _goalController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _runCoach() async {
    final goal = _goalController.text.trim();
    if (goal.isEmpty) return;

    setState(() {
      _coachBusy = true;
      _coachError = null;
      _coach = null;
    });

    try {
      _coach = await _repository.careerCoach(goal);
    } on ApiException catch (e) {
      setState(() => _coachError = _formatError(e));
    } catch (e) {
      setState(() => _coachError = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _coachBusy = false);
    }
  }

  Future<void> _runGenerate() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _chatBusy = true;
      _chatError = null;
      _answer = null;
    });

    try {
      _answer = await _repository.aiGenerate(prompt);
    } on ApiException catch (e) {
      setState(() => _chatError = _formatError(e));
    } catch (e) {
      setState(() => _chatError = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _chatBusy = false);
    }
  }

  void _copyAnswer(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        backgroundColor: AppColors.surfaceOverlay,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatError(ApiException e) {
    switch (e.statusCode) {
      case 400:
        // The backend's 400 messages here are genuinely actionable ("User
        // profile not found.") -- show them instead of a generic fallback
        // that hides why the request actually failed.
        if (e.message.toLowerCase().contains('profile not found')) {
          return 'Add a headline and current role to your profile before using Career Coach.';
        }
        return e.message.isNotEmpty ? e.message : 'That request wasn\'t valid. Please check your input and try again.';
      case 401:
        return 'Session expired. Please sign in again.';
      case 403:
        return 'You don\'t have permission to access this feature.';
      case 404:
        return 'Service not found. Please try again later.';
      case 500:
        return 'Server error. Please try again in a moment.';
      case 503:
        return 'Career AI is temporarily unavailable. Please try again.';
      default:
        if (e.message.contains('timeout') || e.message.contains('connection')) {
          return 'Connection failed. Check your internet and try again.';
        }
        return 'Something went wrong. Please try again.';
    }
  }

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
          title: Text('Career AI', style: AppTypography.titleLarge),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: AppIconButton(
                icon: const Icon(Icons.history_rounded, size: 22),
                onPressed: () {},
                tooltip: 'History',
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 900;
                final isTablet = constraints.maxWidth >= 600;
                final maxContentWidth = isDesktop ? 1000.0 : (isTablet ? 700.0 : double.infinity);

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWelcomeCard(),
                          const SizedBox(height: AppSpacing.xxxl),
                          if (isDesktop || isTablet) ...[
                            _buildDesktopTabletLayout(),
                          ] else ...[
                            _buildMobileLayout(),
                          ],
                          const SizedBox(height: AppSpacing.xxxl),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCareerCoachSection(),
        const SizedBox(height: AppSpacing.xxxl),
        _buildAIChatSection(),
        const SizedBox(height: AppSpacing.xxxl),
        _buildSuggestedPrompts(),
      ],
    );
  }

  Widget _buildDesktopTabletLayout() {
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
                  _buildCareerCoachSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildAIChatSection(),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSuggestedPrompts(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    // The AI's one hero moment on the page -- everything below it (Career
    // Coach form, chat, suggestions) stays on plain AppCard so this reads
    // as the copilot's identity, not another interchangeable container.
    return HeroPanel(
      padding: AppSpacing.xxlAll,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.aiContainer.withValues(alpha: 0.7), AppColors.surfaceElevated],
      ),
      borderColor: AppColors.ai.withValues(alpha: 0.3),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: AppColors.aiGradient,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              boxShadow: AppElevation.colored(AppColors.ai, intensity: 0.4),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: AppColors.onPrimary, size: 32),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Career Copilot', style: AppTypography.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Personalized roadmaps, skill assessments, and instant answers -- grounded in your real profile.',
                  style: AppTypography.bodyMedium.muted(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerCoachSection() {
    // Career Coach reads the user's profile to ground its assessment; the
    // backend 400s with "User profile not found" for an account that
    // hasn't created one yet. Catching that up front as a real empty state
    // (with a way out) beats letting the user hit a generic error after
    // typing out a goal.
    final hasProfile = context.watch<AuthProvider>().profileData != null;

    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.psychology_rounded,
            title: 'Career Coach',
            subtitle: 'Goal → Assessment → Roles → Gaps → Roadmap → Actions',
            iconColor: AppColors.ai,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (!hasProfile) ...[
            EmptyState(
              icon: Icons.person_outline_rounded,
              title: 'Complete your profile first',
              description: 'Career Coach builds your assessment from your real profile -- add your role and background to get started.',
              actionLabel: 'Go to Profile',
              onAction: () => context.go('/profile'),
              iconSize: 40,
              padding: AppSpacing.xlAll,
            ),
          ] else ...[
            ValidatedFormField(
              controller: _goalController,
              label: 'What career goal are you pursuing?',
              hint: 'e.g., Transition to AI Engineering, Get promoted to Staff Engineer, Switch to Product Management',
              maxLines: 3,
              validators: [Validators.required, Validators.minLengthValidator(10, fieldName: 'Goal')],
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              prefixIcon: Icon(Icons.flag_outlined, color: AppColors.textTertiary),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: _coachBusy ? 'Generating roadmap...' : 'Generate Career Roadmap',
              onPressed: _coachBusy ? null : _runCoach,
              loading: _coachBusy,
              fullWidth: true,
              size: AppButtonSize.large,
              style: AppButtonStyle.ai,
              leading: _coachBusy ? null : const Icon(Icons.auto_awesome_rounded, size: 22),
            ),
            if (_coachError != null) ...[
              const SizedBox(height: AppSpacing.md),
              ErrorBanner(message: _coachError!, onDismiss: () => setState(() => _coachError = null), icon: Icons.error_outline_rounded),
            ],
            if (_coach != null) ...[
              const SizedBox(height: AppSpacing.xl),
              _buildCoachResult(_coach!),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildCoachResult(CareerCoach coach) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(color: AppColors.aiContainer, borderRadius: AppRadii.card),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology_rounded, color: AppColors.ai, size: 22),
                  const SizedBox(width: AppSpacing.md),
                  Text('Assessment', style: AppTypography.titleMedium.ai()),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              coach.careerAssessment != null
                  ? MarkdownText(coach.careerAssessment!, bodyStyle: AppTypography.bodyMedium.copyWith(height: 1.6), accentColor: AppColors.ai)
                  : Text('No assessment available.', style: AppTypography.bodyMedium.muted()),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (coach.recommendedRoles.isNotEmpty) _buildChipSection('Recommended Roles', coach.recommendedRoles, AppColors.primary),
        if (coach.skillGaps.isNotEmpty) _buildChipSection('Skill Gaps', coach.skillGaps, AppColors.danger),
        if (coach.prioritySkills.isNotEmpty) _buildChipSection('Priority Skills', coach.prioritySkills, AppColors.warning),
        if (coach.nextActions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text('Next Actions', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.md),
          ...coach.nextActions.map((action) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 20),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(action, style: AppTypography.bodyMedium)),
              ],
            ),
          )),
        ],
        if (coach.roadmap.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text('Roadmap', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.md),
          ...coach.roadmap.map((phase) => _RoadmapPhaseTile(phase: phase)),
        ],
      ],
    );
  }

  Widget _buildChipSection(String title, List<String> items, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: AppTypography.titleMedium),
              const SizedBox(width: AppSpacing.md),
              AppBadge(label: '${items.length}', style: AppBadgeStyle.neutral),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: items.map((item) => AppChip(
              label: item,
              style: AppChipStyle.outlined,
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAIChatSection() {
    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.chat_outlined,
            title: 'Ask CareerOS AI',
            subtitle: 'Direct AI generation for any career question',
          ),
          const SizedBox(height: AppSpacing.lg),
          ValidatedFormField(
            controller: _promptController,
            label: 'Your question',
            hint: 'e.g., How do I negotiate a higher salary? What skills are trending in DevOps?',
            maxLines: 4,
            validators: [Validators.required, Validators.minLengthValidator(5, fieldName: 'Question')],
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            prefixIcon: Icon(Icons.chat_outlined, color: AppColors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: _chatBusy ? 'Thinking...' : 'Ask CareerOS AI',
            onPressed: _chatBusy ? null : _runGenerate,
            loading: _chatBusy,
            fullWidth: true,
            size: AppButtonSize.large,
            leading: _chatBusy ? null : const Icon(Icons.send_rounded, size: 22),
          ),
          if (_chatError != null) ...[
            const SizedBox(height: AppSpacing.md),
            ErrorBanner(message: _chatError!, onDismiss: () => setState(() => _chatError = null), icon: Icons.error_outline_rounded),
          ],
          if (_answer != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: AppRadii.card, border: Border.all(color: AppColors.border, width: 0.5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome_outlined, size: 18, color: AppColors.ai),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text('AI Response', style: AppTypography.labelMedium.ai())),
                      AppIconButton(
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        size: AppButtonSize.small,
                        tooltip: 'Copy answer',
                        onPressed: () => _copyAnswer(_answer!),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  MarkdownText(_answer!, accentColor: AppColors.ai),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestedPrompts() {
    final prompts = [
      'How do I transition from frontend to full-stack?',
      'What certifications are most valued for cloud engineers?',
      'Create a 30-60-90 day plan for a new engineering manager role.',
      'How to showcase open source contributions on my resume?',
      'What salary should I ask for as a senior developer in NYC?',
      'Help me identify transferable skills for a career pivot.',
    ];

    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Suggested Questions',
            subtitle: 'Tap to start a conversation',
            iconColor: AppColors.warning,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: prompts
                .map((prompt) => _PromptTag(
                      label: prompt,
                      onTap: () {
                        _promptController.text = prompt;
                        _runGenerate();
                      },
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

/// A wrappable prompt suggestion. AppChip assumes short tag-length labels
/// (its Row hugs content via mainAxisSize.min, so it never wraps text) --
/// these are full sentences, so this gets its own bounded-width widget with
/// a real Expanded+ellipsis text instead of forcing a long sentence through
/// a component built for "React", "5 years", etc.
class _PromptTag extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PromptTag({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Pressable(
        onTap: onTap,
        borderRadius: AppRadii.chip,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: AppRadii.chip,
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.ai),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(label, style: AppTypography.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoadmapPhaseTile extends StatelessWidget {
  final RoadmapPhase phase;

  const _RoadmapPhaseTile({required this.phase});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        padding: AppSpacing.cardPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.aiContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  '${phase.phase}',
                  style: AppTypography.labelMedium.ai(),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(phase.title ?? 'Phase ${phase.phase}', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  if (phase.duration != null) Text(phase.duration!, style: AppTypography.bodySmall.muted()),
                  if (phase.skills.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: phase.skills.map((skill) => AppChip(
                        label: skill,
                        style: AppChipStyle.ai,
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}