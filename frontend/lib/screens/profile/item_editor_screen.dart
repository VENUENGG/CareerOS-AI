import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/design/design.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';
import '../../repositories/careeros_repository.dart';

// ---------------------------------------------------------------------------
// Section editor plumbing
//
// The profile's six career-data sections (education, experience, skills,
// projects, certifications, languages) all share one CRUD shape on the
// backend: list/create/update/delete against a single resource, with typed
// request bodies. `SectionEditorScreen` turns that shared shape into ONE
// production editor -- a list of existing entries with edit/delete, an
// add/edit form with real validation, loading/empty/error states, and real
// API calls -- driven by a per-section `SectionEditorSpec`. This keeps the
// forms, validation, dialogs, and save/error handling consistent instead of
// maintaining six near-identical bespoke screens (the previous "coming soon"
// placeholders).
// ---------------------------------------------------------------------------

/// The kind of input an editor field renders.
enum ItemFieldKind { text, multiline, select, date, switchField }

/// One field in a section editor form. `key` is the payload key sent to the
/// backend (and the key used in `SectionEditorSpec.initialValues`).
class ItemField {
  final ItemFieldKind kind;
  final String key;
  final String label;
  final String? hint;
  final bool required;
  final List<String>? options;
  final TextInputType? keyboardType;
  final IconData? icon;
  final bool defaultValue;

  const ItemField.text(
    this.key,
    this.label, {
    this.hint,
    this.required = false,
    this.keyboardType,
    this.icon,
  })  : kind = ItemFieldKind.text,
        options = null,
        defaultValue = false;

  const ItemField.multiline(
    this.key,
    this.label, {
    this.hint,
    this.required = false,
    this.icon,
  })  : kind = ItemFieldKind.multiline,
        options = null,
        keyboardType = null,
        defaultValue = false;

  const ItemField.select(
    this.key,
    this.label, {
    required this.options,
    this.required = false,
    this.icon,
  })  : kind = ItemFieldKind.select,
        hint = null,
        keyboardType = null,
        defaultValue = false;

  const ItemField.date(
    this.key,
    this.label, {
    this.required = false,
  })  : kind = ItemFieldKind.date,
        hint = null,
        options = null,
        keyboardType = null,
        icon = null,
        defaultValue = false;

  const ItemField.switchField(
    this.key,
    this.label, {
    this.defaultValue = false,
  })  : kind = ItemFieldKind.switchField,
        hint = null,
        required = false,
        options = null,
        keyboardType = null,
        icon = null;
}

/// Declarative description of one section-editor screen.
class SectionEditorSpec {
  final CareerSection section;
  final String title;
  final String singularLabel;
  final String addLabel;
  final IconData icon;
  final String subtitle;
  final String emptyTitle;
  final String emptyDescription;
  final List<ItemField> fields;

  final String Function(dynamic item) itemTitle;
  final String? Function(dynamic item) itemSubtitle;
  final String? Function(dynamic item) itemMeta;
  final int? Function(dynamic item) itemId;
  final Map<String, dynamic> Function(dynamic item) initialValues;

  /// Cross-field validation run after the form fields themselves pass. Return
  /// a user-facing error message, or `null` when the values are acceptable.
  final String? Function(Map<String, dynamic> values)? validateValues;

  const SectionEditorSpec({
    required this.section,
    required this.title,
    required this.singularLabel,
    required this.addLabel,
    required this.icon,
    required this.subtitle,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.fields,
    required this.itemTitle,
    required this.itemSubtitle,
    required this.itemMeta,
    required this.itemId,
    required this.initialValues,
    this.validateValues,
  });
}

// ---------------------------------------------------------------------------
// Form field helpers shared by the specs
// ---------------------------------------------------------------------------

String? _requiredValidator(String fieldLabel, String? v) =>
    v == null || v.trim().isEmpty ? '$fieldLabel is required' : null;

String _titleCase(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1).toLowerCase();
}

String _monthYear(DateTime? date) =>
    date == null ? '' : DateFormat('MMM yyyy').format(date);

/// "2020-11" style date range used as list metadata, e.g. "Nov 2020 – Present".
String _dateRange(DateTime? start, DateTime? end, bool ongoing) {
  final s = _monthYear(start);
  final e = ongoing || end == null ? 'Present' : _monthYear(end);
  if (s.isEmpty) return e;
  return '$s – $e';
}

// ---------------------------------------------------------------------------
// The six section specs
// ---------------------------------------------------------------------------

const _employmentTypes = [
  'Full-time',
  'Part-time',
  'Contract',
  'Freelance',
  'Internship',
  'Self-employed',
];

const _skillProficiencies = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT'];

final _experienceSpec = SectionEditorSpec(
  section: CareerSection.experience,
  title: 'Experience',
  singularLabel: 'Work experience',
  addLabel: 'Add Experience',
  icon: Icons.work_outline_rounded,
  subtitle: 'Your professional history, most recent first.',
  emptyTitle: 'No work experience added',
  emptyDescription:
      'Add your roles to build a complete profile and power ATS, salary, and career-coach insights.',
  fields: [
    const ItemField.text('jobTitle', 'Job Title', required: true),
    const ItemField.text('companyName', 'Company', required: true),
    const ItemField.select('employmentType', 'Employment Type',
        options: _employmentTypes),
    const ItemField.text('location', 'Location',
        hint: 'City, Country'),
    const ItemField.multiline('description', 'Description',
        hint: 'What did you accomplish in this role?'),
    const ItemField.date('startDate', 'Start Date', required: true),
    const ItemField.date('endDate', 'End Date'),
    const ItemField.switchField('currentlyWorking',
        'I currently work here', defaultValue: true),
  ],
  itemTitle: (item) => (item as Experience).jobTitle ?? 'Untitled role',
  itemSubtitle: (item) => (item as Experience).companyName,
  itemMeta: (item) {
    final e = item as Experience;
    return _dateRange(e.startDate, e.endDate, e.currentlyWorking == true);
  },
  itemId: (item) => (item as Experience).id,
  initialValues: (item) {
    final e = item as Experience;
    return {
      'jobTitle': e.jobTitle,
      'companyName': e.companyName,
      'employmentType': e.employmentType,
      'location': e.location,
      'description': e.description,
      'startDate': e.startDate,
      'endDate': e.endDate,
      'currentlyWorking': e.currentlyWorking ?? true,
    };
  },
  validateValues: (values) {
    final start = values['startDate'] as DateTime?;
    final end = values['endDate'] as DateTime?;
    final current = values['currentlyWorking'] as bool? ?? false;
    if (!current && end == null) {
      return 'Add an end date, or switch on "I currently work here".';
    }
    if (start != null && end != null && end.isBefore(start)) {
      return 'End date can\'t be before the start date.';
    }
    return null;
  },
);

final _educationSpec = SectionEditorSpec(
  section: CareerSection.education,
  title: 'Education',
  singularLabel: 'Education',
  addLabel: 'Add Education',
  icon: Icons.school_outlined,
  subtitle: 'Degrees, diplomas, and academic credentials.',
  emptyTitle: 'No education added',
  emptyDescription:
      'Add your academic background to strengthen your profile and resume.',
  fields: [
    const ItemField.text('institutionName', 'Institution', required: true),
    const ItemField.text('degree', 'Degree', required: true),
    const ItemField.text('fieldOfStudy', 'Field of Study', required: true),
    const ItemField.text('grade', 'Grade / GPA'),
    const ItemField.multiline('description', 'Description',
        hint: 'Relevant coursework, honours, or achievements.'),
    const ItemField.date('startDate', 'Start Date', required: true),
    const ItemField.date('endDate', 'End Date'),
    const ItemField.switchField('currentlyStudying',
        'I currently study here', defaultValue: true),
  ],
  itemTitle: (item) => (item as Education).degree ?? 'Degree',
  itemSubtitle: (item) => (item as Education).institutionName,
  itemMeta: (item) {
    final e = item as Education;
    final s = _monthYear(e.startDate);
    final e2 = e.currentlyStudying == true
        ? 'Present'
        : (e.endDate == null ? '' : _monthYear(e.endDate));
    if (s.isEmpty) return e2.isEmpty ? null : e2;
    return e2.isEmpty ? s : '$s – $e2';
  },
  itemId: (item) => (item as Education).id,
  initialValues: (item) {
    final e = item as Education;
    return {
      'institutionName': e.institutionName,
      'degree': e.degree,
      'fieldOfStudy': e.fieldOfStudy,
      'grade': e.grade,
      'description': e.description,
      'startDate': e.startDate,
      'endDate': e.endDate,
      'currentlyStudying': e.currentlyStudying ?? true,
    };
  },
  validateValues: (values) {
    final start = values['startDate'] as DateTime?;
    final end = values['endDate'] as DateTime?;
    final current = values['currentlyStudying'] as bool? ?? false;
    if (!current && end == null) {
      return 'Add an end date, or switch on "I currently study here".';
    }
    if (start != null && end != null && end.isBefore(start)) {
      return 'End date can\'t be before the start date.';
    }
    return null;
  },
);

final _skillsSpec = SectionEditorSpec(
  section: CareerSection.skills,
  title: 'Skills',
  singularLabel: 'Skill',
  addLabel: 'Add Skill',
  icon: Icons.bolt_outlined,
  subtitle: 'Your technical and professional skills.',
  emptyTitle: 'No skills added',
  emptyDescription:
      'Add your skills to improve ATS matching and get personalized career insights.',
  fields: [
    const ItemField.text('skillName', 'Skill Name', required: true),
    const ItemField.select('proficiency', 'Proficiency',
        options: _skillProficiencies, required: true),
  ],
  itemTitle: (item) => (item as Skill).skillName ?? 'Skill',
  itemSubtitle: (item) => _titleCase((item as Skill).proficiency ?? ''),
  itemMeta: (_) => null,
  itemId: (item) => (item as Skill).id,
  initialValues: (item) {
    final e = item as Skill;
    return {'skillName': e.skillName, 'proficiency': e.proficiency};
  },
);

final _projectsSpec = SectionEditorSpec(
  section: CareerSection.projects,
  title: 'Projects',
  singularLabel: 'Project',
  addLabel: 'Add Project',
  icon: Icons.code_outlined,
  subtitle: 'Personal, open-source, and portfolio work.',
  emptyTitle: 'No projects added',
  emptyDescription:
      'Showcase your projects to demonstrate practical experience.',
  fields: [
    const ItemField.text('projectName', 'Project Name', required: true),
    const ItemField.text('technologies', 'Technologies',
        hint: 'Flutter, Firebase, Docker', required: true),
    const ItemField.multiline('description', 'Description',
        hint: 'What the project does and what you built.'),
    const ItemField.text('githubUrl', 'GitHub URL',
        keyboardType: TextInputType.url),
    const ItemField.text('liveUrl', 'Live URL', keyboardType: TextInputType.url),
    const ItemField.date('startDate', 'Start Date', required: true),
    const ItemField.date('endDate', 'End Date'),
    const ItemField.switchField('currentlyWorking',
        'I\'m still working on this', defaultValue: true),
  ],
  itemTitle: (item) => (item as Project).projectName ?? 'Project',
  itemSubtitle: (item) => (item as Project).technologies,
  itemMeta: (item) {
    final p = item as Project;
    return _dateRange(p.startDate, p.endDate, p.currentlyWorking == true);
  },
  itemId: (item) => (item as Project).id,
  initialValues: (item) {
    final p = item as Project;
    return {
      'projectName': p.projectName,
      'technologies': p.technologies,
      'description': p.description,
      'githubUrl': p.githubUrl,
      'liveUrl': p.liveUrl,
      'startDate': p.startDate,
      'endDate': p.endDate,
      'currentlyWorking': p.currentlyWorking ?? true,
    };
  },
  validateValues: (values) {
    final start = values['startDate'] as DateTime?;
    final end = values['endDate'] as DateTime?;
    final current = values['currentlyWorking'] as bool? ?? false;
    if (!current && end == null) {
      return 'Add an end date, or switch on "I\'m still working on this".';
    }
    if (start != null && end != null && end.isBefore(start)) {
      return 'End date can\'t be before the start date.';
    }
    return null;
  },
);

final _certificationsSpec = SectionEditorSpec(
  section: CareerSection.certifications,
  title: 'Certifications',
  singularLabel: 'Certification',
  addLabel: 'Add Certification',
  icon: Icons.verified_outlined,
  subtitle: 'Professional certifications and credentials.',
  emptyTitle: 'No certifications added',
  emptyDescription:
      'Add certifications to show qualifications employers look for.',
  fields: [
    const ItemField.text('certificationName', 'Certification Name',
        required: true),
    const ItemField.text('issuingOrganization', 'Issuing Organization',
        required: true),
    const ItemField.date('issueDate', 'Issue Date', required: true),
    const ItemField.date('expiryDate', 'Expiry Date'),
    const ItemField.text('credentialId', 'Credential ID'),
    const ItemField.text('credentialUrl', 'Credential URL',
        keyboardType: TextInputType.url),
  ],
  itemTitle: (item) =>
      (item as Certification).certificationName ?? 'Certification',
  itemSubtitle: (item) => (item as Certification).issuingOrganization,
  itemMeta: (item) {
    final c = item as Certification;
    final issued = c.issueDate == null ? null : 'Issued ${_monthYear(c.issueDate)}';
    final expires = c.expiryDate == null ? null : 'Expires ${_monthYear(c.expiryDate)}';
    return [issued, expires].whereType<String>().join(' · ');
  },
  itemId: (item) => (item as Certification).id,
  initialValues: (item) {
    final c = item as Certification;
    return {
      'certificationName': c.certificationName,
      'issuingOrganization': c.issuingOrganization,
      'issueDate': c.issueDate,
      'expiryDate': c.expiryDate,
      'credentialId': c.credentialId,
      'credentialUrl': c.credentialUrl,
    };
  },
  validateValues: (values) {
    final issue = values['issueDate'] as DateTime?;
    final expiry = values['expiryDate'] as DateTime?;
    if (issue != null && expiry != null && expiry.isBefore(issue)) {
      return 'Expiry date can\'t be before the issue date.';
    }
    return null;
  },
);

final _languagesSpec = SectionEditorSpec(
  section: CareerSection.languages,
  title: 'Languages',
  singularLabel: 'Language',
  addLabel: 'Add Language',
  icon: Icons.language_outlined,
  subtitle: 'Languages you speak and your proficiency.',
  emptyTitle: 'No languages added',
  emptyDescription: 'Add languages to complete your professional profile.',
  fields: [
    const ItemField.text('languageName', 'Language', required: true),
    const ItemField.text('proficiency', 'Proficiency',
        hint: 'e.g. Native, Fluent, Professional working',
        required: true),
  ],
  itemTitle: (item) => (item as Language).languageName ?? 'Language',
  itemSubtitle: (item) => (item as Language).proficiency,
  itemMeta: (_) => null,
  itemId: (item) => (item as Language).id,
  initialValues: (item) {
    final e = item as Language;
    return {'languageName': e.languageName, 'proficiency': e.proficiency};
  },
);

/// All six specs, keyed by section, so routes and tiles can look the editor
/// up from a `CareerSection` without a switch of their own.
final Map<CareerSection, SectionEditorSpec> sectionEditorSpecs = {
  CareerSection.education: _educationSpec,
  CareerSection.experience: _experienceSpec,
  CareerSection.skills: _skillsSpec,
  CareerSection.projects: _projectsSpec,
  CareerSection.certifications: _certificationsSpec,
  CareerSection.languages: _languagesSpec,
};

// ---------------------------------------------------------------------------
// The editor screen
// ---------------------------------------------------------------------------

class SectionEditorScreen extends StatefulWidget {
  final SectionEditorSpec spec;

  /// When set, the editor opens directly in edit mode for that item id (used
  /// when a profile tile deep-links into a specific entry).
  final int? initialEditId;

  const SectionEditorScreen({super.key, required this.spec, this.initialEditId});

  @override
  State<SectionEditorScreen> createState() => _SectionEditorScreenState();
}

class _SectionEditorScreenState extends State<SectionEditorScreen> {
  bool _editing = false;
  int? _editingId;
  bool _saving = false;
  String? _formError;
  bool _deepLinked = false;

  SectionEditorSpec get spec => widget.spec;

  @override
  void initState() {
    super.initState();
    // Refresh this section when the editor opens so the list is authoritative
    // even if the user landed here before any other screen loaded the data.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CareerDataProvider>().reloadSection(spec.section);
        if (widget.initialEditId != null) _resolveDeepLink();
      }
    });
  }

  void _resolveDeepLink() {
    if (_deepLinked) return;
    final data = context.read<CareerDataProvider>();
    final items = _currentItems(data);
    final match = items.where((i) => spec.itemId(i) == widget.initialEditId);
    if (match.isEmpty) return;
    setState(() {
      _deepLinked = true;
      _editing = true;
      _editingId = widget.initialEditId;
    });
  }

  List<dynamic> _currentItems(CareerDataProvider data) {
    switch (spec.section) {
      case CareerSection.education:
        return data.education;
      case CareerSection.experience:
        return data.experience;
      case CareerSection.skills:
        return data.skills;
      case CareerSection.projects:
        return data.projects;
      case CareerSection.certifications:
        return data.certifications;
      case CareerSection.languages:
        return data.languages;
    }
  }

  Map<String, dynamic>? _initialValues() {
    if (_editingId == null) return null;
    final data = context.read<CareerDataProvider>();
    final items = _currentItems(data);
    for (final item in items) {
      if (spec.itemId(item) == _editingId) return spec.initialValues(item);
    }
    return null;
  }

  Future<void> _createCall(CareerOSRepository repo, Map<String, dynamic> d) {
    switch (spec.section) {
      case CareerSection.education:
        return repo.createEducation(d);
      case CareerSection.experience:
        return repo.createExperience(d);
      case CareerSection.skills:
        return repo.createSkill(d);
      case CareerSection.projects:
        return repo.createProject(d);
      case CareerSection.certifications:
        return repo.createCertification(d);
      case CareerSection.languages:
        return repo.createLanguage(d);
    }
  }

  Future<void> _updateCall(CareerOSRepository repo, int id, Map<String, dynamic> d) {
    switch (spec.section) {
      case CareerSection.education:
        return repo.updateEducation(id, d);
      case CareerSection.experience:
        return repo.updateExperience(id, d);
      case CareerSection.skills:
        return repo.updateSkill(id, d);
      case CareerSection.projects:
        return repo.updateProject(id, d);
      case CareerSection.certifications:
        return repo.updateCertification(id, d);
      case CareerSection.languages:
        return repo.updateLanguage(id, d);
    }
  }

  Future<void> _deleteCall(CareerOSRepository repo, int id) {
    switch (spec.section) {
      case CareerSection.education:
        return repo.deleteEducation(id);
      case CareerSection.experience:
        return repo.deleteExperience(id);
      case CareerSection.skills:
        return repo.deleteSkill(id);
      case CareerSection.projects:
        return repo.deleteProject(id);
      case CareerSection.certifications:
        return repo.deleteCertification(id);
      case CareerSection.languages:
        return repo.deleteLanguage(id);
    }
  }

  bool _hasFormError() => _formError != null && _formError!.isNotEmpty;

  void _startCreate() {
    setState(() {
      _editing = true;
      _editingId = null;
      _formError = null;
    });
  }

  void _startEdit(dynamic item) {
    setState(() {
      _editing = true;
      _editingId = spec.itemId(item);
      _formError = null;
    });
  }

  void _cancel() {
    setState(() {
      _editing = false;
      _editingId = null;
      _formError = null;
    });
  }

  Future<void> _save(Map<String, dynamic> values) async {
    final repo = context.read<CareerOSRepository>();
    final data = context.read<CareerDataProvider>();
    setState(() {
      _saving = true;
      _formError = null;
    });
    try {
      if (_editingId == null) {
        await _createCall(repo, values);
        _snack('${spec.singularLabel} added');
      } else {
        await _updateCall(repo, _editingId!, values);
        _snack('Changes saved');
      }
      await data.reloadSection(spec.section);
      if (mounted) _cancel();
    } on ApiException catch (e) {
      if (mounted) setState(() => _formError = _friendlyError(e));
    } catch (_) {
      if (mounted) {
        setState(() => _formError = 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete(dynamic item) async {
    final title = spec.itemTitle(item);
    final id = spec.itemId(item);
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.dialog,
          side: BorderSide(color: AppColors.border, width: 0.5),
        ),
        title: Text('Delete $title?', style: AppTypography.titleMedium),
        content: Text(
          'This will permanently remove it from your profile.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: AppTypography.labelMedium),
          ),
          AppButton(
            label: 'Delete',
            onPressed: () => Navigator.pop(context, true),
            style: AppButtonStyle.danger,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final repo = context.read<CareerOSRepository>();
    final data = context.read<CareerDataProvider>();
    try {
      await _deleteCall(repo, id);
      await data.reloadSection(spec.section);
      if (mounted) _snack('${spec.singularLabel} deleted');
    } on ApiException catch (e) {
      if (mounted) _snack(_friendlyError(e), error: true);
    } catch (_) {
      if (mounted) {
        _snack('Couldn\'t delete the entry. Please try again.', error: true);
      }
    }
  }

  String _friendlyError(ApiException e) {
    if (e.message.contains('timeout') || e.message.contains('connection')) {
      return 'Lost connection to the server. Check your internet and try again.';
    }
    if (e.statusCode == 401 || e.statusCode == 403) {
      return 'Your session has expired. Please sign in again.';
    }
    return e.message;
  }

  void _snack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.dangerContainer : AppColors.successContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _editing ? _buildForm() : _buildList();
  }

  // ---- List mode ---------------------------------------------------------

  Widget _buildList() {
    final data = context.watch<CareerDataProvider>();
    final items = _currentItems(data);
    final loading = data.loading;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: false,
          pinned: true,
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: AppIconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 22),
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Back',
          ),
          title: Text(spec.title, style: AppTypography.titleLarge),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: AppButton(
                label: spec.addLabel,
                onPressed: _startCreate,
                leading: const Icon(Icons.add_rounded, size: 20),
                size: AppButtonSize.small,
              ),
            ),
          ],
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
                    Text(spec.subtitle, style: AppTypography.bodyMedium.muted()),
                    const SizedBox(height: AppSpacing.xl),
                    if (loading && items.isEmpty)
                      const _ListSkeleton()
                    else if (items.isEmpty)
                      _buildEmptyState()
                    else
                      _buildItemList(items),
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

  Widget _buildEmptyState() {
    return AppCard(
      padding: AppSpacing.xlAll,
      child: EmptyState(
        icon: spec.icon,
        title: spec.emptyTitle,
        description: spec.emptyDescription,
        actionLabel: spec.addLabel,
        onAction: _startCreate,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildItemList(List<dynamic> items) {
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _buildItemCard(item),
          ),
      ],
    );
  }

  Widget _buildItemCard(dynamic item) {
    final title = spec.itemTitle(item);
    final subtitle = spec.itemSubtitle(item);
    final meta = spec.itemMeta(item);

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.sm, AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(spec.icon, size: 20, color: AppColors.textSecondary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.muted(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (meta != null && meta.isNotEmpty)
                    Text(meta, style: AppTypography.caption),
                ],
              ),
            ),
            AppIconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _startEdit(item),
              tooltip: 'Edit',
            ),
            AppIconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: AppColors.danger,
              ),
              onPressed: () => _confirmDelete(item),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  // ---- Form mode -----------------------------------------------------------

  Widget _buildForm() {
    return _ItemForm(
      key: ValueKey('form-${_editingId ?? 'new'}'),
      spec: spec,
      initial: _initialValues(),
      saving: _saving,
      formError: _hasFormError() ? _formError! : null,
      onSave: _save,
      onCancel: _cancel,
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 4; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Container(
              height: 72,
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: AppRadii.card,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.border.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 12,
                          width: 160,
                          decoration: BoxDecoration(
                            color: AppColors.border.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          height: 10,
                          width: 220,
                          decoration: BoxDecoration(
                            color: AppColors.border.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// The form
// ---------------------------------------------------------------------------

class _ItemForm extends StatefulWidget {
  final SectionEditorSpec spec;
  final Map<String, dynamic>? initial;
  final bool saving;
  final String? formError;
  final Future<void> Function(Map<String, dynamic> values) onSave;
  final VoidCallback onCancel;

  const _ItemForm({
    super.key,
    required this.spec,
    required this.initial,
    required this.saving,
    required this.formError,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<_ItemForm> {
  final _formKey = GlobalKey<FormState>();

  late final Map<String, TextEditingController> _controllers;
  late final Map<String, TextEditingController> _dateControllers;
  final Map<String, String> _selectValues = {};
  final Map<String, DateTime?> _dateValues = {};
  final Map<String, bool> _switchValues = {};
  final Map<String, String> _fieldErrors = {};
  String? _formErrorOverride;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final f in widget.spec.fields)
        if (f.kind == ItemFieldKind.text || f.kind == ItemFieldKind.multiline)
          f.key: TextEditingController(
            text: widget.initial?[f.key] as String? ?? '',
          ),
    };
    _dateControllers = {
      for (final f in widget.spec.fields)
        if (f.kind == ItemFieldKind.date)
          f.key: TextEditingController(
            text: _dateDisplayText(widget.initial?[f.key] as DateTime?),
          ),
    };
    for (final f in widget.spec.fields) {
      if (f.kind == ItemFieldKind.select) {
        final v = widget.initial?[f.key] as String?;
        if (v != null) _selectValues[f.key] = v;
      } else if (f.kind == ItemFieldKind.date) {
        _dateValues[f.key] = widget.initial?[f.key] as DateTime?;
      } else if (f.kind == ItemFieldKind.switchField) {
        _switchValues[f.key] =
            (widget.initial?[f.key] as bool?) ?? f.defaultValue;
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final c in _dateControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _dateDisplayText(DateTime? date) =>
      date == null ? '' : DateFormat('MMM d, yyyy').format(date);

  void _pickDate(ItemField field) async {
    final now = DateTime.now();
    final current = _dateValues[field.key];
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(1960),
      lastDate: DateTime(now.year + 20),
      helpText: 'Select ${field.label.toLowerCase()}',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _dateValues[field.key] = picked;
      _dateControllers[field.key]?.text = _dateDisplayText(picked);
      _fieldErrors.remove(field.key);
    });
  }

  void _submit() {
    if (widget.saving) return;
    final valid = _formKey.currentState?.validate() ?? false;
    final errors = <String, String>{};
    for (final f in widget.spec.fields) {
      if (f.kind != ItemFieldKind.date) continue;
      if (f.required && _dateValues[f.key] == null) {
        errors[f.key] = '${f.label} is required';
      }
    }
    if (errors.isNotEmpty) {
      setState(() => _fieldErrors.addAll(errors));
      return;
    }
    final values = <String, dynamic>{};
    for (final f in widget.spec.fields) {
      switch (f.kind) {
        case ItemFieldKind.text:
        case ItemFieldKind.multiline:
          values[f.key] = _controllers[f.key]?.text.trim();
        case ItemFieldKind.select:
          values[f.key] = _selectValues[f.key];
        case ItemFieldKind.date:
          values[f.key] = _dateValues[f.key];
        case ItemFieldKind.switchField:
          values[f.key] = _switchValues[f.key] ?? f.defaultValue;
      }
    }
    // Surface cross-field errors (date ordering, missing end date) at the top
    // of the form while field-level errors show inline.
    final crossError = widget.spec.validateValues?.call(values);
    if (crossError != null && crossError.isNotEmpty) {
      setState(() => _formErrorOverride = crossError);
      return;
    }
    _formErrorOverride = null;
    if (!valid) return;
    final payload = Map<String, dynamic>.from(values);
    for (final entry in values.entries) {
      if (entry.value is DateTime) {
        payload[entry.key] = DateFormat('yyyy-MM-dd').format(entry.value as DateTime);
      }
    }
    widget.onSave(payload);
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
          leading: AppIconButton(
            icon: const Icon(Icons.close_rounded, size: 22),
            onPressed: widget.saving ? null : widget.onCancel,
            tooltip: 'Cancel',
          ),
          title: Text(
            widget.initial == null ? widget.spec.addLabel : 'Edit ${widget.spec.singularLabel}',
            style: AppTypography.titleLarge,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: AppButton(
                label: widget.initial == null ? 'Add' : 'Save',
                onPressed: widget.saving ? null : _submit,
                loading: widget.saving,
                size: AppButtonSize.small,
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      if (widget.formError != null || _formErrorOverride != null)
                        _FormErrorBanner(
                          message: _formErrorOverride ?? widget.formError!,
                        ),
                      for (final field in widget.spec.fields) ...[
                        _buildField(field),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      SafeArea(
                        top: false,
                        child: SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            label: widget.initial == null ? 'Add ${widget.spec.singularLabel}' : 'Save Changes',
                            onPressed: widget.saving ? null : _submit,
                            loading: widget.saving,
                            size: AppButtonSize.large,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField(ItemField field) {
    switch (field.kind) {
      case ItemFieldKind.text:
        return AppTextField(
          key: ValueKey('field-${field.key}'),
          controller: _controllers[field.key],
          label: field.label,
          hint: field.hint,
          keyboardType: field.keyboardType,
          enabled: !widget.saving,
          maxLines: 1,
          textInputAction: TextInputAction.next,
          validator: field.required
              ? (v) => _requiredValidator(field.label, v)
              : null,
          textCapitalization: TextCapitalization.words,
          prefixIcon: field.icon != null
              ? Icon(field.icon, color: AppColors.textTertiary)
              : null,
        );
      case ItemFieldKind.multiline:
        return AppTextField(
          key: ValueKey('field-${field.key}'),
          controller: _controllers[field.key],
          label: field.label,
          hint: field.hint,
          enabled: !widget.saving,
          minLines: 3,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          validator: field.required
              ? (v) => _requiredValidator(field.label, v)
              : null,
          prefixIcon: field.icon != null
              ? Icon(field.icon, color: AppColors.textTertiary)
              : null,
        );
      case ItemFieldKind.select:
        return AppSelectField<String>(
          key: ValueKey('field-${field.key}'),
          value: _selectValues[field.key],
          label: field.label,
          hint: 'Select…',
          enabled: !widget.saving,
          items: [
            for (final option in field.options ?? const [])
              DropdownMenuItem(
                value: option,
                child: Text(_titleCase(option)),
              ),
          ],
          onChanged: (v) => setState(() {
            if (v == null) {
              _selectValues.remove(field.key);
            } else {
              _selectValues[field.key] = v;
            }
            _fieldErrors.remove(field.key);
          }),
          validator: field.required
              ? (v) => v == null ? '${field.label} is required' : null
              : null,
          prefixIcon: field.icon != null
              ? Icon(field.icon, color: AppColors.textTertiary)
              : null,
        );
      case ItemFieldKind.date:
        return AppTextField(
          key: ValueKey('field-${field.key}'),
          controller: _dateControllers[field.key],
          label: field.label,
          hint: _dateValues[field.key] == null ? 'Select a date' : null,
          readOnly: true,
          enabled: !widget.saving,
          onTap: () => _pickDate(field),
          errorText: _fieldErrors[field.key],
          suffixIcon: Icon(
            Icons.calendar_today_outlined,
            color: AppColors.textTertiary,
            size: 18,
          ),
        );
      case ItemFieldKind.switchField:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.label, style: AppTypography.labelMedium),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: AppRadii.input,
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _switchValues[field.key] ?? field.defaultValue
                          ? 'Yes'
                          : 'No',
                      style: AppTypography.bodyLarge,
                    ),
                  ),
                  Switch(
                    value: _switchValues[field.key] ?? field.defaultValue,
                    onChanged: widget.saving
                        ? null
                        : (v) => setState(() => _switchValues[field.key] = v),
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }
}

class _FormErrorBanner extends StatelessWidget {
  final String message;

  const _FormErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.dangerContainer.withValues(alpha: 0.6),
        borderRadius: AppRadii.card,
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.35),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.danger(),
            ),
          ),
        ],
      ),
    );
  }
}