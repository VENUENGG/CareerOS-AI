import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/design/design.dart';
import '../../core/validation/validation.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';
import '../../repositories/careeros_repository.dart';
import '../../core/network/api_client.dart';

class ResumeScreen extends StatefulWidget {
  const ResumeScreen({super.key, this.initialResumeId});

  final int? initialResumeId;

  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  String _template = 'MODERN';
  bool _publicResume = false;
  bool _creating = false;
  bool _showCreateForm = false;
  bool _editingExisting = false;
  int? _editingResumeId;
  int? _processingResumeId;

  late final CareerOSRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = context.read<CareerOSRepository>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CareerDataProvider>().loadAll();
      if (widget.initialResumeId != null) {
        _loadResumeForEditing(widget.initialResumeId!);
      }
    });
  }

  Future<void> _loadResumeForEditing(int resumeId) async {
    try {
      final resumes = await _repository.resumes();
      final resume = resumes.firstWhere((r) => r.id == resumeId);
      if (mounted) {
        _titleController.text = resume.title ?? '';
        _summaryController.text = resume.professionalSummary ?? '';
        _template = resume.templateType ?? 'MODERN';
        _publicResume = resume.isPublic ?? false;
        _editingExisting = true;
        _editingResumeId = resumeId;
        setState(() => _showCreateForm = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load resume: $e'),
            backgroundColor: AppColors.dangerContainer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _submitResume() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _creating = true);
    final provider = context.read<CareerDataProvider>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (_editingExisting && _editingResumeId != null) {
        await _repository.updateResume(_editingResumeId!, {
          'title': _titleController.text.trim(),
          'templateType': _template,
          'professionalSummary': _summaryController.text.trim(),
          'isPublic': _publicResume,
        });
        if (mounted) {
          await provider.loadAll();
          _resetForm();
          messenger.showSnackBar(
            SnackBar(
              content: const Text('Resume updated successfully'),
              backgroundColor: AppColors.successContainer,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
            ),
          );
        }
      } else {
        await _repository.createResume({
          'title': _titleController.text.trim(),
          'templateType': _template,
          'professionalSummary': _summaryController.text.trim(),
          'isPublic': _publicResume,
        });
        if (mounted) {
          await provider.loadAll();
          _resetForm();
          messenger.showSnackBar(
            SnackBar(
              content: const Text('Resume created successfully'),
              backgroundColor: AppColors.successContainer,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
            ),
          );
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(_formatError(e)),
            backgroundColor: AppColors.dangerContainer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Something went wrong. Please try again.'),
            backgroundColor: AppColors.dangerContainer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  void _resetForm() {
    _titleController.clear();
    _summaryController.clear();
    _template = 'MODERN';
    _publicResume = false;
    _editingExisting = false;
    _editingResumeId = null;
    setState(() => _showCreateForm = false);
  }

  String _formatError(ApiException e) {
    switch (e.statusCode) {
      case 401:
        return 'Session expired. Please sign in again.';
      case 403:
        return 'You don\'t have permission to create resumes.';
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

  Future<void> _deleteResume(int id) async {
    final provider = context.read<CareerDataProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.dialog, side: BorderSide(color: AppColors.border, width: 0.5)),
        title: Text('Delete Resume', style: AppTypography.titleMedium),
        content: Text('Are you sure you want to delete this resume? This action cannot be undone.', style: AppTypography.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: AppTypography.labelMedium)),
          AppButton(label: 'Delete', onPressed: () => Navigator.pop(context, true), style: AppButtonStyle.danger, size: AppButtonSize.small),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _repository.deleteById('/api/v1/resumes', id);
      if (mounted) {
        await provider.loadAll();
        messenger.showSnackBar(
          SnackBar(content: const Text('Resume deleted'), backgroundColor: AppColors.successContainer, behavior: SnackBarBehavior.floating),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(_formatError(e)), backgroundColor: AppColors.dangerContainer, behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: const Text('Something went wrong. Please try again.'), backgroundColor: AppColors.dangerContainer, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  void _useForAts(Resume resume) {
    context.go('/ats?resumeId=${resume.id}');
  }

  Future<void> _ensureSelections(int resumeId) {
    final data = context.read<CareerDataProvider>();
    return _repository.ensureResumeSelections(
      resumeId,
      skillIds: data.skills.map((s) => s.id).whereType<int>().toList(),
      projectIds: data.projects.map((p) => p.id).whereType<int>().toList(),
      experienceIds: data.experience.map((e) => e.id).whereType<int>().toList(),
      educationIds: data.education.map((e) => e.id).whereType<int>().toList(),
      certificationIds: data.certifications.map((c) => c.id).whereType<int>().toList(),
      languageIds: data.languages.map((l) => l.id).whereType<int>().toList(),
    );
  }

  Future<void> _openResume(Resume resume) async {
    if (resume.id == null) return;
    setState(() => _processingResumeId = resume.id);
    final messenger = ScaffoldMessenger.of(context);
    try {
      // The renderer 400s until the resume has a curated selection; a
      // resume that was created but never explicitly curated still needs
      // one before it can be opened, same as ATS analysis.
      await _ensureSelections(resume.id!);
      if (mounted) {
        context.push('/resume/${resume.id}/view?title=${Uri.encodeComponent(resume.title ?? 'Resume')}');
      }
    } on ApiException catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(_formatError(e)), backgroundColor: AppColors.dangerContainer, behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: const Text('Couldn\'t open this resume. Please try again.'), backgroundColor: AppColors.dangerContainer, behavior: SnackBarBehavior.floating));
      }
    } finally {
      if (mounted) setState(() => _processingResumeId = null);
    }
  }

  Future<void> _shareResume(Resume resume) async {
    if (resume.id == null) return;
    setState(() => _processingResumeId = resume.id);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _ensureSelections(resume.id!);
      final bytes = await _repository.resumePdfBytes(resume.id!);
      final safeName = (resume.title ?? 'Resume').replaceAll(RegExp(r'[^\w\s-]'), '').trim();
      await SharePlus.instance.share(ShareParams(
        files: [XFile.fromData(Uint8List.fromList(bytes), name: '${safeName.isEmpty ? 'Resume' : safeName}.pdf', mimeType: 'application/pdf')],
        text: 'My resume${resume.title != null ? ': ${resume.title}' : ''}',
      ));
    } on ApiException catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(_formatError(e)), backgroundColor: AppColors.dangerContainer, behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: const Text('Couldn\'t share this resume. Please try again.'), backgroundColor: AppColors.dangerContainer, behavior: SnackBarBehavior.floating));
      }
    } finally {
      if (mounted) setState(() => _processingResumeId = null);
    }
  }

  void _duplicateResume(Resume resume) {
    _titleController.text = '${resume.title} (Copy)';
    _summaryController.text = resume.professionalSummary ?? '';
    _template = resume.templateType ?? 'MODERN';
    _publicResume = resume.isPublic ?? false;
    _editingExisting = false;
    _editingResumeId = null;
    setState(() => _showCreateForm = true);
  }

  void _cancelForm() {
    _resetForm();
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
          title: Text('Resume Studio', style: AppTypography.titleLarge),
          actions: [
            if (!_showCreateForm)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.lg),
                child: AppButton(
                  label: 'Create Resume',
                  onPressed: () {
                    _resetForm();
                    setState(() => _showCreateForm = true);
                  },
                  leading: const Icon(Icons.add_rounded, size: 20),
                  size: AppButtonSize.medium,
                ),
              ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: _buildBody(data),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(CareerDataProvider data) {
    if (data.loading && data.resumes.isEmpty) {
      return _buildLoadingState();
    }

    if (data.error != null) {
      return _buildErrorState(data.error!);
    }

    return AnimatedCrossFade(
      firstChild: _buildResumeList(data),
      secondChild: _buildCreateForm(),
      crossFadeState: _showCreateForm ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: AppMotion.medium,
      firstCurve: AppMotion.decelerate,
      secondCurve: AppMotion.decelerate,
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xxxl),
        LoadingSkeletonList(itemCount: 3),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xxxl),
        ErrorStateVariant.networkError(onRetry: () => context.read<CareerDataProvider>().loadAll()),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildResumeList(CareerDataProvider data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        final isTablet = constraints.maxWidth >= 600;

        if (data.resumes.isEmpty) {
          return EmptyStateVariant.noResumes.copyWith(
            actionLabel: 'Create Resume',
            onAction: () {
              _resetForm();
              setState(() => _showCreateForm = true);
            },
          );
        }

        if (isDesktop || isTablet) {
          // Grid layout for tablet/desktop
          final crossAxisCount = isDesktop ? 3 : 2;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Your Resumes', style: AppTypography.headlineSmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  TextButton.icon(
                    onPressed: () {
                      _resetForm();
                      setState(() => _showCreateForm = true);
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text('New', style: AppTypography.labelMedium),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              data.loading
                  ? LoadingSkeletonList(itemCount: crossAxisCount * 2)
                  : GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.4,
                      children: data.resumes.map((resume) => ResumeCard(
                        id: resume.id?.toString() ?? '',
                        title: resume.title ?? 'Untitled Resume',
                        template: resume.templateType,
                        isPublic: resume.isPublic,
                        updatedAt: resume.updatedAt,
                        selected: false,
                        busy: _processingResumeId == resume.id,
                        onTap: () => _openResume(resume),
                        onOpen: () => _openResume(resume),
                        onShare: () => _shareResume(resume),
                        onEdit: () => _editResume(resume),
                        onDuplicate: () => _duplicateResume(resume),
                        onUseForAts: () => _useForAts(resume),
                        onDelete: () => _deleteResume(resume.id!),
                      )).toList(),
                    ),
            ],
          );
        }

        // List layout for mobile
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Your Resumes', style: AppTypography.headlineSmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                TextButton.icon(
                  onPressed: () {
                    _resetForm();
                    setState(() => _showCreateForm = true);
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text('New', style: AppTypography.labelMedium),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            data.loading
                ? LoadingSkeletonList(itemCount: 3)
                : Column(
                    children: data.resumes.map((resume) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: ResumeCard(
                        id: resume.id?.toString() ?? '',
                        title: resume.title ?? 'Untitled Resume',
                        template: resume.templateType,
                        isPublic: resume.isPublic,
                        updatedAt: resume.updatedAt,
                        selected: false,
                        busy: _processingResumeId == resume.id,
                        onTap: () => _openResume(resume),
                        onOpen: () => _openResume(resume),
                        onShare: () => _shareResume(resume),
                        onEdit: () => _editResume(resume),
                        onDuplicate: () => _duplicateResume(resume),
                        onUseForAts: () => _useForAts(resume),
                        onDelete: () => _deleteResume(resume.id!),
                      ),
                    )).toList(),
                  ),
          ],
        );
      },
    );
  }

  Widget _buildCreateForm() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        final isTablet = constraints.maxWidth >= 600;
        final maxContentWidth = isDesktop ? 720.0 : (isTablet ? 600.0 : double.infinity);

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(_editingExisting ? 'Edit Resume' : 'Create Resume', style: AppTypography.headlineSmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    TextButton(
                      onPressed: _cancelForm,
                      child: Text('Cancel', style: AppTypography.labelMedium),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('Build a professional resume tailored to your target role.', style: AppTypography.bodyMedium.muted()),
                const SizedBox(height: AppSpacing.xxl),
                Form(
                  key: _formKey,
                  child: AppCard(
                    padding: AppSpacing.xxlAll,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Basic Information', style: AppTypography.titleMedium),
                        const SizedBox(height: AppSpacing.lg),
                        ValidatedFormField(
                          controller: _titleController,
                          label: 'Resume Title',
                          hint: 'Senior Software Engineer Resume',
                          validators: [Validators.required, Validators.minLengthValidator(3, fieldName: 'Title'), Validators.maxLengthValidator(100, fieldName: 'Title')],
                          prefixIcon: Icon(Icons.title_rounded, color: AppColors.textTertiary),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppSelectField<String>(
                          value: _template,
                          label: 'Template',
                          items: const ['MODERN', 'PROFESSIONAL', 'MINIMAL', 'DEVELOPER', 'EXECUTIVE']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => _template = v!),
                          prefixIcon: Icon(Icons.dashboard_customize_rounded, color: AppColors.textTertiary),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ValidatedFormField(
                          controller: _summaryController,
                          label: 'Professional Summary',
                          hint: 'Write a compelling summary highlighting your key achievements and value proposition...',
                          maxLines: 5,
                          validators: [Validators.maxLengthValidator(1000, fieldName: 'Summary')],
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          prefixIcon: Icon(Icons.summarize_rounded, color: AppColors.textTertiary),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // A SwitchListTile paints its background/ink on the
                        // nearest Material ancestor -- but AppCard is a
                        // DecoratedBox with its own background sitting in
                        // between, which silently hides that feedback. Use a
                        // plain Row (matching the rest of the design system)
                        // so the Switch's own themed feedback stays visible.
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Public Resume', style: AppTypography.bodyMedium),
                                  Text('Visible to recruiters and in public searches', style: AppTypography.bodySmall.muted()),
                                ],
                              ),
                            ),
                            Switch(
                              value: _publicResume,
                              onChanged: (v) => setState(() => _publicResume = v),
                              activeThumbColor: AppColors.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: 'Cancel',
                                onPressed: _cancelForm,
                                style: AppButtonStyle.outline,
                                size: AppButtonSize.large,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: AppButton(
                                label: _editingExisting ? 'Update Resume' : 'Create Resume',
                                onPressed: _creating ? null : _submitResume,
                                loading: _creating,
                                size: AppButtonSize.large,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                _buildTemplatePreview(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTemplatePreview() {
    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Template Preview', style: AppTypography.titleMedium),
              const SizedBox(width: AppSpacing.md),
              Text('Choose a template that fits your style', style: AppTypography.bodySmall.muted()),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const ['MODERN', 'PROFESSIONAL', 'MINIMAL', 'DEVELOPER', 'EXECUTIVE'].map((template) {
                final selected = template == _template;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: Pressable(
                    onTap: () => setState(() => _template = template),
                    borderRadius: AppRadii.card,
                    child: AnimatedContainer(
                      duration: AppMotion.fast,
                      width: 160,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primaryContainer : AppColors.surface,
                        borderRadius: AppRadii.card,
                        border: Border.all(
                          color: selected ? AppColors.primary : AppColors.border,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Padding(
                        padding: AppSpacing.cardPadding,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: selected ? AppColors.primary : AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(AppRadii.lg),
                              ),
                              child: Icon(
                                _templateIcon(template),
                                color: selected ? AppColors.onPrimary : AppColors.textSecondary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(template, style: AppTypography.bodyMedium.copyWith(
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              color: selected ? AppColors.primary : AppColors.textPrimary,
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _editResume(Resume resume) {
    _titleController.text = resume.title ?? '';
    _summaryController.text = resume.professionalSummary ?? '';
    _template = resume.templateType ?? 'MODERN';
    _publicResume = resume.isPublic ?? false;
    _editingExisting = true;
    _editingResumeId = resume.id;
    setState(() => _showCreateForm = true);
  }

  IconData _templateIcon(String template) {
    switch (template) {
      case 'MODERN': return Icons.dashboard_customize_rounded;
      case 'PROFESSIONAL': return Icons.business_rounded;
      case 'MINIMAL': return Icons.minimize_rounded;
      case 'DEVELOPER': return Icons.code_rounded;
      case 'EXECUTIVE': return Icons.leaderboard_rounded;
      default: return Icons.description_rounded;
    }
  }
}