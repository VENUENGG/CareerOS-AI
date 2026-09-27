// Overflow stress sweep using REALISTIC, deliberately long career data.
//
// app_shell_test.dart already proves every shell route renders cleanly with
// empty/no profile data at 360/412/768/1280 -- but that is exactly why it
// could not catch the overflow the user found on a real device: a real
// profile has long job titles, multi-word company names, long degree names,
// many skills, and long headlines, and several of those content-driven
// layouts only overflow once real-length strings flow through them. This
// file seeds AuthProvider/CareerDataProvider directly (via the test-only
// CareerDataProvider.debugSeed) with long-but-realistic data and sweeps the
// full required width set (360/375/390/412/768/1024/1280).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:careeros/core/network/api_client.dart';
import 'package:careeros/core/storage/token_storage.dart';
import 'package:careeros/core/theme/app_theme.dart';
import 'package:careeros/core/widgets/app_shell.dart';
import 'package:careeros/models/models.dart';
import 'package:careeros/providers/app_providers.dart';
import 'package:careeros/providers/theme_controller.dart';
import 'package:careeros/repositories/careeros_repository.dart';
import 'package:careeros/screens/ai/ai_screen.dart';
import 'package:careeros/screens/ats/ats_screen.dart';
import 'package:careeros/screens/dashboard/dashboard_screen.dart';
import 'package:careeros/screens/profile/profile_screen.dart';
import 'package:careeros/screens/resume/resume_screen.dart';
import 'package:careeros/screens/salary/salary_screen.dart';

final _longProfile = UserProfile.fromJson({
  'id': 1,
  'userId': 1,
  'firstName': 'Alexandria',
  'lastName': 'Montgomery-Fitzgerald',
  'email': 'alexandria.montgomery.fitzgerald@averyverylongcorporatedomainname.com',
  'headline': 'Senior Staff Software Engineer & Technical Lead specializing in Distributed Systems, Cloud Infrastructure, and Platform Engineering',
  'currentJobTitle': 'Principal Staff Software Engineer, Platform Infrastructure & Reliability',
  'bio': 'Long bio ' * 20,
  'city': 'San Francisco',
  'state': 'California',
  'country': 'United States of America',
  'phone': '+1 (555) 123-4567',
  'yearsOfExperience': 12,
});

final _longExperience = [
  Experience.fromJson({
    'id': 1,
    'jobTitle': 'Principal Staff Software Engineer, Platform Infrastructure & Reliability Engineering',
    'companyName': 'International Business Solutions & Advanced Technology Consulting Group LLC',
    'location': 'San Francisco, California, United States',
    'startDate': '2019-01-01',
    'currentlyWorking': true,
  }),
  Experience.fromJson({
    'id': 2,
    'jobTitle': 'Senior Backend Engineer',
    'companyName': 'Acme',
    'location': 'Remote',
    'startDate': '2016-06-01',
    'endDate': '2018-12-31',
    'currentlyWorking': false,
  }),
];

final _longEducation = [
  Education.fromJson({
    'id': 1,
    'degree': 'Master of Science in Computer Science and Engineering, Specialization in Distributed Systems',
    'institutionName': 'Massachusetts Institute of Technology, School of Engineering',
    'fieldOfStudy': 'Computer Science and Artificial Intelligence Laboratory Research Track',
    'startDate': '2014-09-01',
    'endDate': '2016-06-01',
  }),
];

final _longSkills = List.generate(18, (i) => Skill.fromJson({'id': i, 'skillName': 'Distributed Systems Architecture Design Pattern $i'}));

final _longProjects = [
  Project.fromJson({
    'id': 1,
    'projectName': 'Enterprise-Grade Real-Time Distributed Event Streaming and Analytics Platform',
    'technologies': 'Kotlin, Kafka, Kubernetes, Terraform, Prometheus, Grafana, PostgreSQL, Redis, gRPC',
  }),
];

final _longCertifications = [
  Certification.fromJson({
    'id': 1,
    'certificationName': 'AWS Certified Solutions Architect - Professional Level Advanced Certification',
    'issuingOrganization': 'Amazon Web Services Training and Certification Program',
    'issueDate': '2021-03-01',
  }),
];

final _longLanguages = [
  Language.fromJson({'id': 1, 'languageName': 'English', 'proficiency': 'Native or Bilingual Proficiency'}),
];

final _longResumes = [
  Resume.fromJson({'id': 1, 'title': 'Senior Platform Engineering Leadership Resume — Full Stack + Infra', 'createdAt': '2024-01-01', 'updatedAt': '2024-06-01'}),
];

UserProfile longProfileForTest() => _longProfile;

void seedForTest(CareerDataProvider data) {
  data.debugSeed(
    education: _longEducation,
    experience: _longExperience,
    skills: _longSkills,
    projects: _longProjects,
    certifications: _longCertifications,
    languages: _longLanguages,
    resumes: _longResumes,
  );
}

Widget _harness(Widget shellChild, {required String currentPath, bool seed = true}) {
  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenStorage);
  final repository = CareerOSRepository(apiClient);

  return MultiProvider(
    providers: [
      Provider<TokenStorage>.value(value: tokenStorage),
      Provider<ApiClient>.value(value: apiClient),
      Provider<CareerOSRepository>.value(value: repository),
      ChangeNotifierProvider(create: (ctx) {
        final auth = AuthProvider.create(ctx);
        if (seed) auth.setProfile(_longProfile);
        return auth;
      }),
      ChangeNotifierProvider(create: (ctx) {
        final data = CareerDataProvider.create(ctx);
        if (seed) {
          data.debugSeed(
            education: _longEducation,
            experience: _longExperience,
            skills: _longSkills,
            projects: _longProjects,
            certifications: _longCertifications,
            languages: _longLanguages,
            resumes: _longResumes,
          );
        }
        return data;
      }),
      ChangeNotifierProvider(create: (_) => AvatarController()),
      ChangeNotifierProvider(create: (_) => ThemeController()),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      home: AppShell(currentPath: currentPath, child: shellChild),
    ),
  );
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  final screens = <String, Widget Function()>{
    '/': () => const DashboardScreen(),
    '/profile': () => const ProfileScreen(),
    '/resume': () => const ResumeScreen(),
    '/ai': () => const AiScreen(),
    '/ats': () => const AtsScreen(),
    '/salary': () => const SalaryScreen(),
  };

  // The full width set the product spec requires zero overflow at.
  final widths = <String, double>{
    '360w': 360,
    '375w': 375,
    '390w': 390,
    '412w': 412,
    '768w': 768,
    '1024w': 1024,
    '1280w': 1280,
  };

  for (final screenEntry in screens.entries) {
    for (final widthEntry in widths.entries) {
      testWidgets('${screenEntry.key} with realistic long data renders at ${widthEntry.key} without overflow', (tester) async {
        tester.view.physicalSize = Size(widthEntry.value, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_harness(screenEntry.value(), currentPath: screenEntry.key));
        await _settle(tester);

        final exception = tester.takeException();
        expect(exception, isNull, reason: 'Overflow/exception on ${screenEntry.key} at ${widthEntry.key}: $exception');
      });
    }
  }
}
