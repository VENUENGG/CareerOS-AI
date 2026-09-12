import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/design/design.dart';
import '../../core/validation/validation.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../../repositories/careeros_repository.dart';
import '../../core/network/api_client.dart';

class SalaryScreen extends StatefulWidget {
  const SalaryScreen({super.key});

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _industryController = TextEditingController();
  final _yearsController = TextEditingController();
  final _currentSalaryController = TextEditingController();

  SalaryEstimate? _estimate;
  SalaryCompare? _compare;
  List<SalaryEstimate> _history = [];
  bool _busy = false;
  bool _loadingHistory = false;
  String? _error;

  late final CareerOSRepository _repository;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: AppMotion.medium, vsync: this);
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: AppMotion.decelerate));
    _animationController.forward();
    _repository = context.read<CareerOSRepository>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _industryController.dispose();
    _yearsController.dispose();
    _currentSalaryController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _loadingHistory = true);
    try {
      _history = await _repository.salaryHistory();
    } catch (e) {
      // Silently fail
    } finally {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  Map<String, dynamic> _estimatePayload() {
    return {
      'jobTitle': _titleController.text.trim(),
      'location': _locationController.text.trim(),
      'industry': _industryController.text.trim(),
      'experienceYears': int.tryParse(_yearsController.text.trim()),
      'currentSalary': double.tryParse(_currentSalaryController.text.trim()),
      'skillIds': <int>[],
    };
  }

  Future<void> _runEstimate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _busy = true;
      _error = null;
      _estimate = null;
      _compare = null;
    });

    try {
      _estimate = await _repository.salaryEstimate(_estimatePayload());
    } on ApiException catch (e) {
      setState(() => _error = _formatError(e));
    } catch (e) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _compareSalary() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentSalaryController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your current salary to compare');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      _compare = await _repository.salaryCompare({
        'currentSalary': double.tryParse(_currentSalaryController.text.trim()),
        'estimate': _estimatePayload(),
      });
      await _loadHistory();
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
        return 'You don\'t have permission to run salary analysis.';
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
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: false,
          pinned: true,
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text('Salary Intelligence', style: AppTypography.titleLarge),
          actions: [
            if (_estimate != null || _compare != null)
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
        _buildInputForm(),
        const SizedBox(height: AppSpacing.xxxl),
        if (_estimate != null) _buildEstimateResult(_estimate!),
        if (_compare != null) _buildComparisonResult(_compare!),
      ],
    );
  }

  Widget _buildDesktopTabletLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputForm(),
              const SizedBox(height: AppSpacing.lg),
              if (_estimate != null) _buildEstimateResult(_estimate!),
              if (_compare != null) _buildComparisonResult(_compare!),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_history.isNotEmpty) ...[
                _buildHistorySidebar(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySidebar() {
    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.history_rounded,
            title: 'Recent Estimates',
            subtitle: 'Your salary estimate history',
            iconColor: AppColors.success,
          ),
          const SizedBox(height: AppSpacing.lg),
          ..._history.take(5).map((estimate) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _SalaryHistoryTile(estimate: estimate),
          )),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return AppCard(
      padding: AppSpacing.xxlAll,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: AppColors.successGradient,
              borderRadius: BorderRadius.circular(AppRadii.xl),
            ),
            child: Icon(Icons.payments_rounded, color: AppColors.onPrimary, size: 32),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Know Your Worth', style: AppTypography.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Get accurate market compensation data for your role, location, and experience level.',
                  style: AppTypography.bodyMedium.muted(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.analytics_outlined,
            title: 'Market Estimate',
            subtitle: 'Enter details to get a personalized salary range',
            iconColor: AppColors.success,
          ),
          const SizedBox(height: AppSpacing.lg),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValidatedFormField(
                  controller: _titleController,
                  label: 'Job Title',
                  hint: 'e.g., Senior Software Engineer',
                  validators: [Validators.required, Validators.minLengthValidator(2, fieldName: 'Job Title'), Validators.maxLengthValidator(100, fieldName: 'Job Title')],
                  prefixIcon: Icon(Icons.work_outline_rounded, color: AppColors.textTertiary),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: ValidatedFormField(
                        controller: _locationController,
                        label: 'Location',
                        hint: 'e.g., San Francisco, CA',
                        validators: [Validators.required, Validators.maxLengthValidator(100, fieldName: 'Location')],
                        prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.textTertiary),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ValidatedFormField(
                        controller: _industryController,
                        label: 'Industry',
                        hint: 'e.g., Technology',
                        validators: [Validators.maxLengthValidator(100, fieldName: 'Industry')],
                        prefixIcon: Icon(Icons.factory_outlined, color: AppColors.textTertiary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: ValidatedFormField(
                        controller: _yearsController,
                        label: 'Experience (Years)',
                        hint: '5',
                        keyboardType: TextInputType.number,
                        validators: [
                          Validators.required,
                          Validators.integerValidator(),
                          Validators.rangeValidator(0, 50, fieldName: 'Experience'),
                        ],
                        prefixIcon: Icon(Icons.timeline_outlined, color: AppColors.textTertiary),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ValidatedFormField(
                        controller: _currentSalaryController,
                        label: 'Current Salary (Optional)',
                        hint: '150000',
                        keyboardType: TextInputType.number,
                        validators: [
                          Validators.numericValidator(),
                          Validators.positiveValidator(fieldName: 'Salary'),
                        ],
                        prefixIcon: Icon(Icons.attach_money_rounded, color: AppColors.textTertiary),
                      ),
                    ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  ErrorBanner(message: _error!, onDismiss: () => setState(() => _error = null), icon: Icons.error_outline_rounded),
                ],
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: _busy ? 'Estimating...' : 'Get Estimate',
                        onPressed: _busy ? null : _runEstimate,
                        loading: _busy,
                        size: AppButtonSize.large,
                        leading: _busy ? null : const Icon(Icons.analytics_outlined, size: 22),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppButton(
                        label: _busy ? 'Comparing...' : 'Compare Salary',
                        onPressed: (_busy || _currentSalaryController.text.trim().isEmpty) ? null : _compareSalary,
                        loading: _busy,
                        style: AppButtonStyle.outline,
                        size: AppButtonSize.large,
                        leading: _busy ? null : const Icon(Icons.compare_arrows_rounded, size: 22),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimateResult(SalaryEstimate estimate) {
    return SalaryRangeCard(
      currency: estimate.currency ?? 'USD',
      minSalary: estimate.minimumSalary,
      expectedSalary: estimate.expectedSalary,
      maxSalary: estimate.maximumSalary,
      marketPosition: estimate.marketPosition,
      factors: estimate.factors,
      skillPremiums: estimate.skillNames,
    );
  }

  Widget _buildComparisonResult(SalaryCompare compare) {
    final estimate = compare.estimate;
    final current = compare.currentSalary ?? 0;
    final expected = compare.expectedSalary ?? 0;
    final pct = compare.percentageDifference ?? 0;

    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.compare_arrows_rounded,
            title: 'Salary Comparison',
            subtitle: 'Your current compensation vs market estimate',
          ),
          const SizedBox(height: AppSpacing.lg),
          _ComparisonHeader(
            marketPosition: compare.marketPosition ?? '',
            message: compare.message ?? '',
            percentageDifference: pct,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(child: _ComparisonBar(label: 'Current', value: current, color: AppColors.textSecondary)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _ComparisonBar(label: 'Market', value: expected, color: AppColors.primary, highlight: true)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (estimate != null) ...[
            _buildEstimateDetails(estimate),
          ],
        ],
      ),
    );
  }

  Widget _buildEstimateDetails(SalaryEstimate estimate) {
    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estimate Details', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          if (estimate.minimumSalary != null || estimate.maximumSalary != null) ...[
            Row(
              children: [
                Expanded(child: _DetailItem(label: 'Minimum', value: _formatSalary(estimate.minimumSalary), color: AppColors.textTertiary)),
                Expanded(child: _DetailItem(label: 'Expected', value: _formatSalary(estimate.expectedSalary), color: AppColors.primary, highlight: true)),
                Expanded(child: _DetailItem(label: 'Maximum', value: _formatSalary(estimate.maximumSalary), color: AppColors.success)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (estimate.marketPosition != null) ...[
            Row(
              children: [
                Text('Market Position: ', style: AppTypography.bodyMedium),
                AppBadge(label: estimate.marketPosition!, style: AppBadgeStyle.info),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (estimate.factors.isNotEmpty) ...[
            Text('Key Factors', style: AppTypography.labelMedium),
            const SizedBox(height: AppSpacing.md),
            Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: estimate.factors.map((f) => AppChip(label: f, style: AppChipStyle.outlined)).toList()),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (estimate.skillNames.isNotEmpty) ...[
            Text('Skill Premiums', style: AppTypography.labelMedium),
            const SizedBox(height: AppSpacing.md),
            Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: estimate.skillNames.map((s) => AppChip(label: s, style: AppChipStyle.ai)).toList()),
          ],
        ],
      ),
    );
  }

  Future<void> _showHistorySheet() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SalaryHistorySheet(history: _history, loading: _loadingHistory, onLoadMore: _loadHistory),
    );
  }

  String _formatSalary(double? salary) {
    if (salary == null) return '—';
    if (salary >= 1000000) return '\$${(salary / 1000000).toStringAsFixed(1)}M';
    if (salary >= 1000) return '\$${(salary / 1000).toStringAsFixed(0)}K';
    return '\$${salary.toStringAsFixed(0)}';
  }
}

class _ComparisonHeader extends StatelessWidget {
  final String marketPosition;
  final String message;
  final double percentageDifference;

  const _ComparisonHeader({
    required this.marketPosition,
    required this.message,
    required this.percentageDifference,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = percentageDifference > 0;
    final color = isPositive ? AppColors.success : AppColors.danger;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Market Position: ', style: AppTypography.bodyMedium),
                  AppBadge(label: marketPosition, style: AppBadgeStyle.info),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(message, style: AppTypography.bodyMedium.muted()),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: AppRadii.card,
          ),
          child: Column(
            children: [
              Text('vs Market', style: AppTypography.caption),
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${isPositive ? '+' : ''}${percentageDifference.toStringAsFixed(1)}%',
                    style: AppTypography.headlineSmall.copyWith(color: color, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: color, size: 20),
                ],
              ),
              Text(isPositive ? 'Above market' : 'Below market', style: AppTypography.caption.copyWith(color: color)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ComparisonBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool highlight;

  const _ComparisonBar({required this.label, required this.value, required this.color, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final maxVal = _getMaxValue(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption.copyWith(color: color)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _formatValue(value),
          style: (highlight ? AppTypography.headlineSmall : AppTypography.titleLarge).copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 6,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(3)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (value / maxVal).clamp(0.0, 1.0),
            child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          ),
        ),
      ],
    );
  }

  double _getMaxValue(double value) {
    if (value <= 0) return 100000;
    if (value < 50000) return 100000;
    if (value < 100000) return 200000;
    if (value < 200000) return 300000;
    if (value < 500000) return 600000;
    return (value * 1.5).ceilToDouble();
  }

  String _formatValue(double value) {
    if (value >= 1000000) return '\$${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '\$${(value / 1000).toStringAsFixed(0)}K';
    return '\$${value.toStringAsFixed(0)}';
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool highlight;

  const _DetailItem({required this.label, required this.value, required this.color, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption.copyWith(color: color)),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: (highlight ? AppTypography.titleMedium : AppTypography.bodyLarge).copyWith(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _SalaryHistorySheet extends StatelessWidget {
  final List<SalaryEstimate> history;
  final bool loading;
  final VoidCallback? onLoadMore;

  const _SalaryHistorySheet({required this.history, required this.loading, this.onLoadMore});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.sheet,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
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
                Expanded(child: Text('Estimate History', style: AppTypography.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
                if (history.isNotEmpty)
                  AppBadge(label: '${history.length}', style: AppBadgeStyle.neutral),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          Expanded(
            child: history.isEmpty
                ? Center(
                    child: EmptyStateVariant.noSalaryEstimates.copyWith(
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
                      final estimate = history[index];
                      return _SalaryHistoryTile(estimate: estimate);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SalaryHistoryTile extends StatelessWidget {
  final SalaryEstimate estimate;

  const _SalaryHistoryTile({required this.estimate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.successContainer,
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Icon(Icons.payments_rounded, color: AppColors.success, size: 24),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(estimate.jobTitle ?? 'Unknown Role', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${estimate.location ?? ''}${estimate.industry != null ? ' • ${estimate.industry}' : ''}',
                    style: AppTypography.bodySmall.muted(),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Text(
                        '${_formatSalary(estimate.minimumSalary)} – ${_formatSalary(estimate.maximumSalary)}',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                      if (estimate.expectedSalary != null) ...[
                        const SizedBox(width: AppSpacing.md),
                        Text('(Expected: ${_formatSalary(estimate.expectedSalary)})', style: AppTypography.caption),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (estimate.createdAt != null)
              Text(_formatDate(estimate.createdAt!), style: AppTypography.caption),
          ],
        ),
      ),
    );
  }

  String _formatSalary(double? salary) {
    if (salary == null) return '—';
    if (salary >= 1000000) return '\$${(salary / 1000000).toStringAsFixed(1)}M';
    if (salary >= 1000) return '\$${(salary / 1000).toStringAsFixed(0)}K';
    return '\$${salary.toStringAsFixed(0)}';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays == 0) return 'Today';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}