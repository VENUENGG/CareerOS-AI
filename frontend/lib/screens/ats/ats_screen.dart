import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/design/design.dart';
import '../../core/validation/validation.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';
import '../../repositories/careeros_repository.dart';
import '../../core/network/api_client.dart';

class AtsScreen extends StatefulWidget {
  const AtsScreen({super.key});

  @override
  State<AtsScreen> createState() => _AtsScreenState();
}

class _AtsScreenState extends State<AtsScreen> {
  final _jobTitleController = TextEditingController();
  final _jobDescriptionController = TextEditingController();

  String _analysisType = 'GENERAL';
  Resume? _selectedResume;
  AtsAnalysis? _result;
  List<AtsAnalysis> _history = [];
  bool _busy = false;
  bool _loadingHistory = false;
  String? _error;
  int? _resumeIdFromQuery;

  late final CareerOSRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = context.read<CareerOSRepository>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CareerDataProvider>().loadAll();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadHistoryFromQuery();
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _jobDescriptionController.dispose();
    super.dispose();
  }

  void _loadHistoryFromQuery() {
    final uri = Uri.base;
    final resumeIdParam = uri.queryParameters['resumeId'];
    if (resumeIdParam != null) {
      final resumeId = int.tryParse(resumeIdParam);
      if (resumeId != null && resumeId != _resumeIdFromQuery) {
        _resumeIdFromQuery = resumeId;
        _loadHistory(resumeId);
      }
    }
  }

  Future<void> _loadHistory(int resumeId) async {
    setState(() => _loadingHistory = true);
    try {
      _history = await _repository.atsHistory(resumeId);
    } catch (e) {
      // Silently fail for history
    } finally {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  Future<void> _analyze() async {
    if (_selectedResume == null) {
      setState(() => _error = 'Please select a resume to analyze');
      return;
    }

    final data = context.read<CareerDataProvider>();

    setState(() {
      _busy = true;
      _error = null;
      _result = null;
    });

    try {
      final resumeId = _selectedResume!.id!;
      if (!await _repository.hasResumeSelections(resumeId)) {
        // This resume was never curated with specific selections; default
        // to including everything the user currently has so analysis can
        // run against their real data instead of failing outright.
        await _repository.saveResumeSelections(resumeId, {
          'skillIds': data.skills.map((s) => s.id).whereType<int>().toList(),
          'projectIds': data.projects.map((p) => p.id).whereType<int>().toList(),
          'experienceIds': data.experience.map((e) => e.id).whereType<int>().toList(),
          'educationIds': data.education.map((e) => e.id).whereType<int>().toList(),
          'certificationIds': data.certifications.map((c) => c.id).whereType<int>().toList(),
          'languageIds': data.languages.map((l) => l.id).whereType<int>().toList(),
        });
      }
      _result = await _repository.atsAnalyze(
        resumeId,
        _analysisType,
        jobTitle: _jobTitleController.text.trim().isEmpty ? null : _jobTitleController.text.trim(),
        jobDescription: _jobDescriptionController.text.trim().isEmpty ? null : _jobDescriptionController.text.trim(),
      );
      await _loadHistory(resumeId);
    } on ApiException catch (e) {
      setState(() => _error = _formatError(e));
    } catch (e) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _loadLatest(int resumeId) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      _result = await _repository.atsLatest(resumeId);
      await _loadHistory(resumeId);
    } on ApiException catch (e) {
      setState(() => _error = _formatError(e));
    } catch (e) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _formatError(ApiException e) {
    switch (e.statusCode) {
      case 401:
        return 'Session expired. Please sign in again.';
      case 403:
        return 'You don\'t have permission to run ATS analysis.';
      case 404:
        return 'Service not found. Please try again later.';
      case 500:
        return 'Server error. Please try again in a moment.';
      default:
        if (e.message.contains('timeout') || e.message.contains('connection')) {
          return 'Connection failed. Check your internet and try again.';
        }
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<CareerDataProvider>();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: false,
          pinned: true,
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text('ATS Analyzer', style: AppTypography.titleLarge),
          actions: [
            if (_result != null)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.lg),
                child: AppIconButton(
                  icon: const Icon(Icons.history_rounded, size: 22),
                  onPressed: _showHistorySheet,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isDesktop || isTablet) ...[
                          _buildDesktopTabletLayout(data),
                        ] else ...[
                          _buildMobileLayout(data),
                        ],
                        const SizedBox(height: AppSpacing.xxxl),
                      ],
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

  Widget _buildMobileLayout(CareerDataProvider data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResumePicker(data),
        const SizedBox(height: AppSpacing.xxxl),
        _buildAnalysisForm(),
        const SizedBox(height: AppSpacing.xxxl),
        if (_result != null) _buildResult(_result!),
      ],
    );
  }

  Widget _buildDesktopTabletLayout(CareerDataProvider data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResumePicker(data),
              const SizedBox(height: AppSpacing.lg),
              _buildAnalysisForm(),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_result != null) _buildResult(_result!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResumePicker(CareerDataProvider data) {
    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.description_outlined,
            title: 'Select Resume',
            subtitle: data.resumes.isEmpty ? 'Create a resume first to run ATS analysis' : 'Choose which resume to analyze',
          ),
          const SizedBox(height: AppSpacing.lg),
          data.loading
              ? LoadingSkeletonList(itemCount: 3)
              : data.resumes.isEmpty
                  ? EmptyStateVariant.noResumes.copyWith(
                      actionLabel: 'Create Resume',
                      onAction: () => context.go('/resume'),
                    )
                  : Column(
                      children: data.resumes.map((resume) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _ResumePickerTile(
                          resume: resume,
                          selected: _selectedResume?.id == resume.id,
                          onTap: () {
                            setState(() => _selectedResume = resume);
                            if (resume.id != null) _loadHistory(resume.id!);
                          },
                          onUseLatest: resume.id != null ? () => _loadLatest(resume.id!) : null,
                        ),
                      )).toList(),
                    ),
        ],
      ),
    );
  }

  Widget _buildAnalysisForm() {
    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.analytics_outlined,
            title: 'Analysis Configuration',
            subtitle: 'Configure how the resume should be analyzed',
            iconColor: AppColors.info,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSelectField<String>(
            value: _analysisType,
            label: 'Analysis Type',
            items: const ['GENERAL', 'JOB_SPECIFIC']
                .map((e) => DropdownMenuItem(value: e, child: Text(e.replaceAll('_', ' ')))).toList(),
            onChanged: (v) => setState(() => _analysisType = v!),
            prefixIcon: const Icon(Icons.analytics_outlined, color: AppColors.textTertiary),
          ),
          if (_analysisType == 'JOB_SPECIFIC') ...[
            const SizedBox(height: AppSpacing.lg),
            ValidatedFormField(
              controller: _jobTitleController,
              label: 'Job Title (Optional)',
              hint: 'e.g., Senior Software Engineer',
              validators: [Validators.maxLengthValidator(100, fieldName: 'Job Title')],
              prefixIcon: const Icon(Icons.work_outline_rounded, color: AppColors.textTertiary),
            ),
            const SizedBox(height: AppSpacing.lg),
            ValidatedFormField(
              controller: _jobDescriptionController,
              label: 'Job Description (Optional)',
              hint: 'Paste the job description here for targeted analysis...',
              maxLines: 6,
              validators: [Validators.maxLengthValidator(5000, fieldName: 'Job Description')],
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              prefixIcon: const Icon(Icons.description_outlined, color: AppColors.textTertiary),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: _busy ? 'Analyzing...' : 'Analyze Resume',
            onPressed: (_selectedResume == null || _busy) ? null : _analyze,
            loading: _busy,
            fullWidth: true,
            size: AppButtonSize.large,
            leading: _busy ? null : const Icon(Icons.radar_rounded, size: 22),
            style: AppButtonStyle.primary,
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            ErrorBanner(message: _error!, onDismiss: () => setState(() => _error = null), icon: Icons.error_outline_rounded),
          ],
        ],
      ),
    );
  }

  Widget _buildResult(AtsAnalysis result) {
    return ATSScoreCard(
      overallScore: result.atsScore ?? 0,
      keywordScore: result.keywordScore ?? 0,
      skillsScore: result.skillsScore ?? 0,
      experienceScore: result.experienceScore ?? 0,
      educationScore: result.educationScore ?? 0,
      formattingScore: result.formattingScore ?? 0,
      matchedKeywords: result.matchedKeywords,
      missingKeywords: result.missingKeywords,
      strengths: result.strengths,
      weaknesses: result.weaknesses,
      suggestions: result.suggestions,
      jobTitle: result.jobTitle,
      analyzedAt: result.createdAt,
    );
  }

  void _showHistorySheet() {
    if (_selectedResume == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _HistoryBottomSheet(
        history: _history,
        loading: _loadingHistory,
        onLoadMore: _selectedResume!.id != null ? () => _loadHistory(_selectedResume!.id!) : null,
      ),
    );
  }
}

class _ResumePickerTile extends StatelessWidget {
  final Resume resume;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onUseLatest;

  const _ResumePickerTile({
    required this.resume,
    required this.selected,
    required this.onTap,
    this.onUseLatest,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      borderRadius: AppRadii.card,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryContainer : AppColors.surface,
          borderRadius: AppRadii.card,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(Icons.description_outlined, color: selected ? AppColors.onPrimary : AppColors.primary, size: 24),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(resume.title ?? 'Untitled Resume', style: AppTypography.bodyMedium.copyWith(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                  ), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppSpacing.xs),
                  // Wrap (not Row) so template/visibility badges plus the
                  // "updated" timestamp fold onto a second line instead of
                  // overflowing when the tile is narrow or the trailing
                  // refresh button is present.
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (resume.templateType != null)
                        AppBadge(label: resume.templateType!, style: AppBadgeStyle.primary),
                      if (resume.isPublic == true)
                        AppBadge(label: 'Public', style: AppBadgeStyle.success)
                      else
                        AppBadge(label: 'Private', style: AppBadgeStyle.neutral),
                      if (resume.updatedAt != null)
                        Text(
                          'Updated ${_formatDate(resume.updatedAt!)}',
                          style: AppTypography.caption,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24),
            if (onUseLatest != null) ...[
              const SizedBox(width: AppSpacing.md),
              AppIconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20),
                onPressed: onUseLatest,
                size: AppButtonSize.small,
                tooltip: 'Load latest analysis',
              ),
            ],
          ],
        ),
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

class _HistoryBottomSheet extends StatelessWidget {
  final List<AtsAnalysis> history;
  final bool loading;
  final VoidCallback? onLoadMore;

  const _HistoryBottomSheet({
    required this.history,
    required this.loading,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.sheet,
        border: const Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(color: AppColors.textTertiary, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: AppSpacing.horizontalLg,
            child: Row(
              children: [
                Expanded(child: Text('Analysis History', style: AppTypography.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
                if (history.isNotEmpty)
                  AppBadge(label: '${history.length}', style: AppBadgeStyle.neutral),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: history.isEmpty
                ? Center(
                    child: EmptyStateVariant.noAtsAnalysis.copyWith(
                      padding: AppSpacing.xlAll,
                      iconSize: 48,
                    ),
                  )
                : ListView.builder(
                    padding: AppSpacing.allLg,
                    itemCount: history.length + (loading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == history.length) {
                        return Center(
                          child: Padding(
                            padding: AppSpacing.allLg,
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        );
                      }
                      final analysis = history[index];
                      return _HistoryTile(analysis: analysis);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final AtsAnalysis analysis;

  const _HistoryTile({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            CircularProgressCard(
              label: '',
              progress: (analysis.atsScore ?? 0) / 100,
              value: '${analysis.atsScore ?? 0}',
              size: 56,
              strokeWidth: 6,
              progressColor: _scoreColor(analysis.atsScore ?? 0),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    analysis.jobTitle ?? (analysis.analysisType == 'JOB_SPECIFIC' ? 'Job Specific' : 'General Analysis'),
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    analysis.createdAt != null ? _formatDate(analysis.createdAt!) : 'Unknown date',
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      AppBadge(label: analysis.analysisType ?? 'GENERAL', style: AppBadgeStyle.info),
                      if (analysis.keywordScore != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        _MiniScore(label: 'Keywords', score: analysis.keywordScore!),
                      ],
                      if (analysis.skillsScore != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        _MiniScore(label: 'Skills', score: analysis.skillsScore!),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    if (score >= 40) return AppColors.info;
    return AppColors.danger;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _MiniScore extends StatelessWidget {
  final String label;
  final int score;

  const _MiniScore({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(score);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: AppTypography.caption),
        Text('$score%', style: AppTypography.labelSmall.copyWith(color: color, fontWeight: FontWeight.w600)),
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