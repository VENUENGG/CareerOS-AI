import '../../models/models.dart';
import '../../providers/app_providers.dart';

/// Actionable item for improving profile completeness.
class ProfileMissingItem {
  final String label;
  final String route;

  const ProfileMissingItem({required this.label, required this.route});
}

/// Computes profile completeness score (0-100%) and missing improvement items
/// based on real profile and career data.
///
/// Weight breakdown (100% total):
/// - First Name: 5%
/// - Last Name: 5%
/// - Headline: 10%
/// - Current Role: 10%
/// - Bio: 10%
/// - Location (City or Country): 5%
/// - Social/Web Links: 5%
/// - Work Experience: 15%
/// - Education: 10%
/// - Skills (5+ skills = 10%, 1-4 skills = 5%): 10%
/// - Projects: 5%
/// - Certifications: 5%
/// - Languages: 5%
class ProfileCompletenessCalculator {
  static int calculate(UserProfile? profile, CareerDataProvider data) {
    int score = 0;

    if (_hasText(profile?.firstName)) score += 5;
    if (_hasText(profile?.lastName)) score += 5;
    if (_hasText(profile?.headline)) score += 10;
    if (_hasText(profile?.currentJobTitle)) score += 10;
    if (_hasText(profile?.bio)) score += 10;
    if (_hasText(profile?.city) || _hasText(profile?.country)) score += 5;
    if (_hasText(profile?.linkedinUrl) ||
        _hasText(profile?.githubUrl) ||
        _hasText(profile?.portfolioUrl)) {
      score += 5;
    }

    if (data.experience.isNotEmpty) score += 15;
    if (data.education.isNotEmpty) score += 10;
    if (data.skills.length >= 5) {
      score += 10;
    } else if (data.skills.isNotEmpty) {
      score += 5;
    }
    if (data.projects.isNotEmpty) score += 5;
    if (data.certifications.isNotEmpty) score += 5;
    if (data.languages.isNotEmpty) score += 5;

    return score.clamp(0, 100);
  }

  static List<ProfileMissingItem> getMissingItems(
    UserProfile? profile,
    CareerDataProvider data,
  ) {
    final items = <ProfileMissingItem>[];

    if (!_hasText(profile?.headline)) {
      items.add(const ProfileMissingItem(
        label: 'Add a professional headline',
        route: '/profile',
      ));
    }
    if (!_hasText(profile?.currentJobTitle)) {
      items.add(const ProfileMissingItem(
        label: 'Add your current role',
        route: '/profile',
      ));
    }
    if (data.skills.length < 5) {
      final needed = 5 - data.skills.length;
      items.add(ProfileMissingItem(
        label: data.skills.isEmpty
            ? 'Add your core skills'
            : 'Add $needed more skill${needed > 1 ? 's' : ''}',
        route: '/profile/skills',
      ));
    }
    if (data.experience.isEmpty) {
      items.add(const ProfileMissingItem(
        label: 'Add work experience',
        route: '/profile/experience',
      ));
    }
    if (data.education.isEmpty) {
      items.add(const ProfileMissingItem(
        label: 'Add education',
        route: '/profile/education',
      ));
    }
    if (data.projects.isEmpty) {
      items.add(const ProfileMissingItem(
        label: 'Add a project',
        route: '/profile/projects',
      ));
    }
    if (!_hasText(profile?.bio)) {
      items.add(const ProfileMissingItem(
        label: 'Write a professional bio',
        route: '/profile',
      ));
    }
    if (data.resumes.isEmpty) {
      items.add(const ProfileMissingItem(
        label: 'Create your first resume',
        route: '/resume',
      ));
    }
    if (data.certifications.isEmpty) {
      items.add(const ProfileMissingItem(
        label: 'Add certifications',
        route: '/profile/certifications',
      ));
    }
    if (data.languages.isEmpty) {
      items.add(const ProfileMissingItem(
        label: 'Add languages',
        route: '/profile/languages',
      ));
    }
    if (!_hasText(profile?.linkedinUrl) &&
        !_hasText(profile?.githubUrl) &&
        !_hasText(profile?.portfolioUrl)) {
      items.add(const ProfileMissingItem(
        label: 'Add professional links',
        route: '/profile',
      ));
    }

    return items;
  }

  static bool _hasText(String? value) =>
      value != null && value.trim().isNotEmpty;
}
