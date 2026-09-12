import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/design/design.dart';
import '../../core/storage/avatar_storage.dart';
import '../../core/validation/validation.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';
import '../../repositories/careeros_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final _formKey = GlobalKey<FormState>();
  final _headlineController = TextEditingController();
  final _jobController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();
  final _portfolioController = TextEditingController();

  final Map<String, bool> _expandedSections = {
    'identity': true,
    'professional': true,
    'location': false,
    'links': false,
    'experience': false,
    'education': false,
    'skills': false,
    'projects': false,
    'certifications': false,
    'languages': false,
  };

  bool _loaded = false;
  bool _saving = false;
  bool _avatarInitialized = false;

  late final CareerOSRepository _repository;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: AppMotion.medium, vsync: this);
    _repository = context.read<CareerOSRepository>();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _headlineController.dispose();
    _jobController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  Future<void> _initializeAvatar(UserProfile? profile) async {
    if (_avatarInitialized) return;
    final avatarController = context.read<AvatarController>();
    await avatarController.initialize(profile);
    _avatarInitialized = true;

    // Show avatar picker on first visit if no custom avatar selected and no
    // profile photo. Local storage being unavailable shouldn't block the
    // rest of profile initialization -- just skip the one-time prompt.
    bool pickerShown = true;
    try {
      pickerShown = await AvatarStorage.hasAvatarPickerBeenShown();
    } catch (_) {
      return;
    }
    final selectedStyle = avatarController.selectedStyle;
    final hasProfilePhoto = profile?.profilePhotoUrl != null && profile!.profilePhotoUrl!.isNotEmpty;

    if (!pickerShown && selectedStyle == AvatarStyle.initials && !hasProfilePhoto && profile != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showAvatarPicker(context, profile);
      });
      try {
        await AvatarStorage.setAvatarPickerShown();
      } catch (_) {
        // Not persisted -- worst case the picker prompt reappears next visit.
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final profile = context.read<AuthProvider>().profileData;
    _initializeAvatar(profile);
    if (profile != null) {
      _headlineController.text = profile.headline ?? '';
      _jobController.text = profile.currentJobTitle ?? '';
      _bioController.text = profile.bio ?? '';
      _cityController.text = profile.city ?? '';
      _stateController.text = profile.state ?? '';
      _countryController.text = profile.country ?? '';
      _phoneController.text = profile.phone ?? '';
      _linkedinController.text = profile.linkedinUrl ?? '';
      _githubController.text = profile.githubUrl ?? '';
      _portfolioController.text = profile.portfolioUrl ?? '';
    }
    _loaded = true;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final profile = await _repository.updateProfile({
        'headline': _headlineController.text.trim(),
        'currentJobTitle': _jobController.text.trim(),
        'bio': _bioController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'country': _countryController.text.trim(),
        'phone': _phoneController.text.trim(),
        'linkedinUrl': _linkedinController.text.trim(),
        'githubUrl': _githubController.text.trim(),
        'portfolioUrl': _portfolioController.text.trim(),
      });
      if (mounted) {
        context.read<AuthProvider>().setProfile(profile);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated'),
            backgroundColor: AppColors.successContainer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.dangerContainer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toggleSection(String key) {
    setState(() => _expandedSections[key] = !(_expandedSections[key] ?? false));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.profileData;
    final data = context.watch<CareerDataProvider>();
    final completion = _calculateCompletion(profile, data);

    return CustomScrollView(
      slivers: [
        _buildAppBar(context, profile, completion),
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isDesktop || isTablet) ...[
                            _buildDesktopTabletLayout(profile, data, completion),
                          ] else ...[
                            _buildMobileLayout(profile, data, completion),
                          ],
                          const SizedBox(height: AppSpacing.xxl),
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

  Widget _buildMobileLayout(UserProfile? profile, CareerDataProvider data, int completion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileHeader(profile, completion),
        const SizedBox(height: AppSpacing.xxl),
        _buildExpandableSection(
          key: 'identity',
          title: 'Identity',
          subtitle: 'Your account information',
          icon: Icons.person_outline_rounded,
          child: _buildIdentitySection(profile),
        ),
        _buildExpandableSection(
          key: 'professional',
          title: 'Professional Profile',
          subtitle: 'Headline, role, and bio',
          icon: Icons.work_outline_rounded,
          child: _buildProfessionalSection(),
        ),
        _buildExpandableSection(
          key: 'location',
          title: 'Location',
          subtitle: 'City, state, country',
          icon: Icons.location_on_outlined,
          child: _buildLocationSection(),
        ),
        _buildExpandableSection(
          key: 'links',
          title: 'Professional Links',
          subtitle: 'LinkedIn, GitHub, Portfolio',
          icon: Icons.link_outlined,
          child: _buildLinksSection(),
        ),
        _buildDataSections(data),
        const SizedBox(height: AppSpacing.xxl),
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildDesktopTabletLayout(UserProfile? profile, CareerDataProvider data, int completion) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(profile, completion),
              const SizedBox(height: AppSpacing.lg),
              _buildExpandableSection(
                key: 'professional',
                title: 'Professional Profile',
                subtitle: 'Headline, role, and bio',
                icon: Icons.work_outline_rounded,
                child: _buildProfessionalSection(),
              ),
              _buildExpandableSection(
                key: 'location',
                title: 'Location',
                subtitle: 'City, state, country',
                icon: Icons.location_on_outlined,
                child: _buildLocationSection(),
              ),
              _buildExpandableSection(
                key: 'links',
                title: 'Professional Links',
                subtitle: 'LinkedIn, GitHub, Portfolio',
                icon: Icons.link_outlined,
                child: _buildLinksSection(),
              ),
              _buildDataSections(data),
              const SizedBox(height: AppSpacing.xxl),
              _buildSaveButton(),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIdentitySection(profile),
              const SizedBox(height: AppSpacing.lg),
              _buildDataSummary(data, completion),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataSummary(CareerDataProvider data, int completion) {
    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(icon: Icons.analytics_outlined, title: 'Profile Summary'),
          const SizedBox(height: AppSpacing.lg),
          _SummaryRow(label: 'Experience', value: '${data.experience.length} entries', icon: Icons.work_outline_rounded, color: AppColors.info),
          _SummaryRow(label: 'Education', value: '${data.education.length} entries', icon: Icons.school_outlined, color: AppColors.success),
          _SummaryRow(label: 'Skills', value: '${data.skills.length} skills', icon: Icons.bolt_outlined, color: AppColors.primary),
          _SummaryRow(label: 'Projects', value: '${data.projects.length} projects', icon: Icons.code_outlined, color: AppColors.warning),
          _SummaryRow(label: 'Certifications', value: '${data.certifications.length} certifications', icon: Icons.verified_outlined, color: AppColors.ai),
          _SummaryRow(label: 'Languages', value: '${data.languages.length} languages', icon: Icons.language_outlined, color: AppColors.success),
          _SummaryRow(label: 'Resumes', value: '${data.resumes.length} resumes', icon: Icons.description_outlined, color: AppColors.info),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(color: _completionColor(completion).withValues(alpha: 0.1), borderRadius: AppRadii.card),
            child: Row(
              children: [
                Icon(Icons.favorite_rounded, color: _completionColor(completion), size: 20),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text('Profile $completion% complete', style: AppTypography.bodyMedium.copyWith(color: _completionColor(completion)))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSections(CareerDataProvider data) {
    return Column(
      children: [
        _buildDataSection(
          key: 'experience',
          title: 'Experience',
          subtitle: '${data.experience.length} entries',
          icon: Icons.work_outline_rounded,
          emptyMessage: 'No experience added yet',
          emptyAction: 'Add Experience',
          onEmptyAction: () => _navigateToSection(context, 'experience'),
          child: _buildExperienceList(data.experience),
        ),
        _buildDataSection(
          key: 'education',
          title: 'Education',
          subtitle: '${data.education.length} entries',
          icon: Icons.school_outlined,
          emptyMessage: 'No education added yet',
          emptyAction: 'Add Education',
          onEmptyAction: () => _navigateToSection(context, 'education'),
          child: _buildEducationList(data.education),
        ),
        _buildDataSection(
          key: 'skills',
          title: 'Skills',
          subtitle: '${data.skills.length} skills',
          icon: Icons.bolt_outlined,
          emptyMessage: 'No skills added yet',
          emptyAction: 'Add Skill',
          onEmptyAction: () => _navigateToSection(context, 'skills'),
          child: _buildSkillsList(data.skills),
        ),
        _buildDataSection(
          key: 'projects',
          title: 'Projects',
          subtitle: '${data.projects.length} projects',
          icon: Icons.code_outlined,
          emptyMessage: 'No projects added yet',
          emptyAction: 'Add Project',
          onEmptyAction: () => _navigateToSection(context, 'projects'),
          child: _buildProjectsList(data.projects),
        ),
        _buildDataSection(
          key: 'certifications',
          title: 'Certifications',
          subtitle: '${data.certifications.length} certifications',
          icon: Icons.verified_outlined,
          emptyMessage: 'No certifications added yet',
          emptyAction: 'Add Certification',
          onEmptyAction: () => _navigateToSection(context, 'certifications'),
          child: _buildCertificationsList(data.certifications),
        ),
        _buildDataSection(
          key: 'languages',
          title: 'Languages',
          subtitle: '${data.languages.length} languages',
          icon: Icons.language_outlined,
          emptyMessage: 'No languages added yet',
          emptyAction: 'Add Language',
          onEmptyAction: () => _navigateToSection(context, 'languages'),
          child: _buildLanguagesList(data.languages),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, UserProfile? profile, int completion) {
    final avatarController = context.watch<AvatarController>();
    return SliverAppBar(
      // Avatar (88) + gaps + name + optional headline + completion chip row
      // routinely need ~250-260px once a real profile has a headline set.
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      // Plain toolbar title (matches every other screen's SliverAppBar) --
      // NOT flexibleSpace.title, which FlexibleSpaceBar always anchors to
      // the bottom of the expanded space. That put it directly on top of
      // this bar's own background content (avatar/name/completion chips),
      // which is also bottom-anchored -- the actual cause of the header
      // text visually colliding with the avatar block.
      title: Text('Profile', style: AppTypography.titleLarge),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppColors.surfaceGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: AppSpacing.horizontalLg.copyWith(top: 72, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AppAvatar(
                    imageUrl: profile?.profilePhotoUrl,
                    initials: avatarController.initials,
                    radius: 44,
                    onTap: () => _showAvatarPicker(context, profile),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '${profile?.firstName ?? ''} ${profile?.lastName ?? ''}',
                    style: AppTypography.headlineMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (profile?.headline != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(profile!.headline!, style: AppTypography.bodyMedium.muted(), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: _completionColor(completion).withValues(alpha: 0.15),
                          borderRadius: AppRadii.chip,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite_rounded, size: 14, color: _completionColor(completion)),
                            const SizedBox(width: AppSpacing.xs),
                            Text('Profile $completion% complete', style: AppTypography.labelSmall.copyWith(color: _completionColor(completion))),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      if (profile?.currentJobTitle != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                          decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: AppRadii.chip),
                          child: Text(profile!.currentJobTitle!, style: AppTypography.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAvatarPicker(BuildContext context, UserProfile? profile) {
    final avatarController = context.read<AvatarController>();
    final initials = avatarController.initials;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AvatarPicker(
        currentInitials: initials,
        onSelect: (style) => avatarController.selectAvatar(style, profile),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile? profile, int completion) {
    final color = _completionColor(completion);
    return Container(
      padding: AppSpacing.xlAll,
      decoration: BoxDecoration(
        borderRadius: AppRadii.card,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadii.md),
                          ),
                          child: Icon(Icons.person_outline_rounded, color: color, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: Text('Profile Strength', style: AppTypography.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _profileStrengthLabel(completion),
                      style: AppTypography.bodyMedium.copyWith(color: color, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Complete these items to unlock better AI recommendations and salary insights.',
                      style: AppTypography.bodyMedium.muted(),
                    ),
                  ],
                ),
              ),
              CircularProgressCard(
                label: '',
                progress: completion / 100,
                value: '$completion%',
                size: 64,
                strokeWidth: 6,
                progressColor: color,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.3),
                    color,
                    color.withValues(alpha: 0.3),
                  ],
                ),
              ),
              child: LinearProgressIndicator(
                value: completion / 100,
                minHeight: 8,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _profileStrengthLabel(int completion) {
    if (completion >= 80) return 'Strong';
    if (completion >= 60) return 'Good';
    if (completion >= 40) return 'Fair';
    return 'Needs Work';
  }

  Widget _buildExpandableSection({
    required String key,
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    final expanded = _expandedSections[key] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(
          children: [
            Pressable(
              onTap: () => _toggleSection(key),
              borderRadius: AppRadii.card,
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: SectionHeader(
                  icon: icon,
                  title: title,
                  subtitle: subtitle,
                  trailing: AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: AppMotion.fast,
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textTertiary, size: 24),
                  ),
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: AppSpacing.horizontalLg.copyWith(bottom: AppSpacing.lg, top: 0),
                child: child,
              ),
              crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: AppMotion.normal,
              firstCurve: AppMotion.decelerate,
              secondCurve: AppMotion.decelerate,
              sizeCurve: AppMotion.decelerate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection({
    required String key,
    required String title,
    required String subtitle,
    required IconData icon,
    required String emptyMessage,
    required String emptyAction,
    required VoidCallback onEmptyAction,
    required Widget child,
  }) {
    final expanded = _expandedSections[key] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(
          children: [
            Pressable(
              onTap: () => _toggleSection(key),
              borderRadius: AppRadii.card,
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: SectionHeader(
                  icon: icon,
                  title: title,
                  subtitle: subtitle,
                  iconColor: AppColors.textSecondary,
                  iconBackground: AppColors.surfaceElevated,
                  trailing: AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: AppMotion.fast,
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textTertiary, size: 24),
                  ),
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: AppSpacing.horizontalLg.copyWith(bottom: AppSpacing.lg, top: 0),
                child: Column(
                  children: [
                    child,
                    if (child is SizedBox || (child is Column && child.children.isEmpty)) ...[
                      const SizedBox(height: AppSpacing.md),
                      EmptyStateVariant.noExperience.copyWith(
                        icon: icon,
                        title: emptyMessage,
                        description: 'Add your first entry to strengthen your profile.',
                        actionLabel: emptyAction,
                        onAction: onEmptyAction,
                      ),
                    ],
                  ],
                ),
              ),
              crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: AppMotion.normal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentitySection(UserProfile? profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (profile != null) ...[
          _InfoRow(label: 'Email', value: profile.email ?? '—', icon: Icons.email_outlined),
          _InfoRow(label: 'Member since', value: profile.createdAt != null ? _formatDate(profile.createdAt!) : '—', icon: Icons.calendar_today_outlined),
        ],
      ],
    );
  }

  Widget _buildProfessionalSection() {
    return Column(
      children: [
        ValidatedFormField(
          controller: _headlineController,
          label: 'Headline',
          hint: 'Senior Software Engineer | Flutter & AI Enthusiast',
          validators: [Validators.maxLengthValidator(120, fieldName: 'Headline')],
          prefixIcon: Icon(Icons.badge_outlined, color: AppColors.textTertiary),
        ),
        const SizedBox(height: AppSpacing.lg),
        ValidatedFormField(
          controller: _jobController,
          label: 'Current Job Title',
          hint: 'Senior Software Engineer',
          validators: [Validators.maxLengthValidator(100, fieldName: 'Job Title')],
          prefixIcon: Icon(Icons.work_outlined, color: AppColors.textTertiary),
        ),
        const SizedBox(height: AppSpacing.lg),
        ValidatedFormField(
          controller: _bioController,
          label: 'Bio',
          hint: 'Tell your professional story...',
          maxLines: 4,
          validators: [Validators.maxLengthValidator(500, fieldName: 'Bio')],
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          prefixIcon: Icon(Icons.info_outline_rounded, color: AppColors.textTertiary),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ValidatedFormField(
                controller: _cityController,
                label: 'City',
                hint: 'San Francisco',
                validators: [Validators.maxLengthValidator(50, fieldName: 'City')],
                prefixIcon: Icon(Icons.location_city_outlined, color: AppColors.textTertiary),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ValidatedFormField(
                controller: _stateController,
                label: 'State/Province',
                hint: 'CA',
                validators: [Validators.maxLengthValidator(50, fieldName: 'State')],
                prefixIcon: Icon(Icons.map_outlined, color: AppColors.textTertiary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        ValidatedFormField(
          controller: _countryController,
          label: 'Country',
          hint: 'United States',
          validators: [Validators.maxLengthValidator(100, fieldName: 'Country')],
          prefixIcon: Icon(Icons.public_outlined, color: AppColors.textTertiary),
        ),
        const SizedBox(height: AppSpacing.lg),
        ValidatedFormField(
          controller: _phoneController,
          label: 'Phone',
          hint: '+1 (555) 000-0000',
          keyboardType: TextInputType.phone,
          validators: [Validators.maxLengthValidator(30, fieldName: 'Phone')],
          prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textTertiary),
        ),
      ],
    );
  }

  Widget _buildLinksSection() {
    return Column(
      children: [
        ValidatedFormField(
          controller: _linkedinController,
          label: 'LinkedIn URL',
          hint: 'linkedin.com/in/yourname',
          keyboardType: TextInputType.url,
          validators: [Validators.url],
          prefixIcon: Icon(Icons.work_outlined, color: AppColors.textTertiary),
        ),
        const SizedBox(height: AppSpacing.lg),
        ValidatedFormField(
          controller: _githubController,
          label: 'GitHub URL',
          hint: 'github.com/yourname',
          keyboardType: TextInputType.url,
          validators: [Validators.url],
          prefixIcon: Icon(Icons.code_outlined, color: AppColors.textTertiary),
        ),
        const SizedBox(height: AppSpacing.lg),
        ValidatedFormField(
          controller: _portfolioController,
          label: 'Portfolio URL',
          hint: 'yourname.dev',
          keyboardType: TextInputType.url,
          validators: [Validators.url],
          prefixIcon: Icon(Icons.web_outlined, color: AppColors.textTertiary),
        ),
      ],
    );
  }

  Widget _buildExperienceList(List<Experience> experience) {
    if (experience.isEmpty) return const SizedBox.shrink();
    return Column(
      children: experience.map((exp) => _ExperienceTile(experience: exp)).toList(),
    );
  }

  Widget _buildEducationList(List<Education> education) {
    if (education.isEmpty) return const SizedBox.shrink();
    return Column(
      children: education.map((edu) => _EducationTile(education: edu)).toList(),
    );
  }

  Widget _buildSkillsList(List<Skill> skills) {
    if (skills.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: skills.map((skill) => AppChip(
        label: skill.skillName ?? 'Unknown',
        style: AppChipStyle.filled,
      )).toList(),
    );
  }

  Widget _buildProjectsList(List<Project> projects) {
    if (projects.isEmpty) return const SizedBox.shrink();
    return Column(
      children: projects.map((project) => _ProjectTile(project: project)).toList(),
    );
  }

  Widget _buildCertificationsList(List<Certification> certifications) {
    if (certifications.isEmpty) return const SizedBox.shrink();
    return Column(
      children: certifications.map((cert) => _CertificationTile(certification: cert)).toList(),
    );
  }

  Widget _buildLanguagesList(List<Language> languages) {
    if (languages.isEmpty) return const SizedBox.shrink();
    return Column(
      children: languages.map((lang) => _LanguageTile(language: lang)).toList(),
    );
  }

  Widget _buildSaveButton() {
    return AppButton(
      label: 'Save Profile',
      onPressed: _saving ? null : _saveProfile,
      loading: _saving,
      fullWidth: true,
      size: AppButtonSize.large,
    );
  }

  void _navigateToSection(BuildContext context, String section) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$section editor coming soon'), behavior: SnackBarBehavior.floating),
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
    if (data.certifications.isNotEmpty) score += 5;
    if (data.languages.isNotEmpty) score += 5;
    if (data.resumes.isNotEmpty) score += 5;
    return score.clamp(0, 100);
  }

  Color _completionColor(int completion) {
    if (completion >= 80) return AppColors.success;
    if (completion >= 50) return AppColors.warning;
    return AppColors.info;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: AppSpacing.md),
          Text(label, style: AppTypography.bodySmall.muted()),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(value, style: AppTypography.bodyMedium, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _ExperienceTile extends StatelessWidget {
  final Experience experience;

  const _ExperienceTile({required this.experience});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(AppRadii.md)),
            child: Icon(Icons.work_outline_rounded, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(experience.jobTitle ?? 'Unknown Role', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                if (experience.companyName != null) Text(experience.companyName!, style: AppTypography.bodySmall.muted()),
                if (experience.startDate != null)
                  Text(
                    '${_formatDate(experience.startDate!)} – ${experience.currentlyWorking == true ? 'Present' : _formatDate(experience.endDate!)}',
                    style: AppTypography.caption,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.month}/${date.year}';
}

class _EducationTile extends StatelessWidget {
  final Education education;

  const _EducationTile({required this.education});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(AppRadii.md)),
            child: Icon(Icons.school_outlined, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(education.degree ?? 'Degree', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                if (education.institutionName != null) Text(education.institutionName!, style: AppTypography.bodySmall.muted()),
                if (education.fieldOfStudy != null) Text(education.fieldOfStudy!, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  final Project project;

  const _ProjectTile({required this.project});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(AppRadii.md)),
            child: Icon(Icons.code_outlined, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(project.projectName ?? 'Unnamed Project', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                if (project.technologies != null) Text(project.technologies!, style: AppTypography.bodySmall.muted(), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificationTile extends StatelessWidget {
  final Certification certification;

  const _CertificationTile({required this.certification});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(AppRadii.md)),
            child: Icon(Icons.verified_outlined, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(certification.certificationName ?? 'Certification', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                if (certification.issuingOrganization != null) Text(certification.issuingOrganization!, style: AppTypography.bodySmall.muted()),
                if (certification.issueDate != null) Text('Issued: ${_formatDate(certification.issueDate!)}', style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.month}/${date.year}';
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryRow({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppRadii.md)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: AppTypography.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final Language language;

  const _LanguageTile({required this.language});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(AppRadii.md)),
            child: Icon(Icons.language_outlined, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language.languageName ?? 'Language', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                if (language.proficiency != null) Text(language.proficiency!, style: AppTypography.bodySmall.muted()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}