import 'package:go_router/go_router.dart';

import '../core/widgets/app_shell.dart';
import '../providers/app_providers.dart';
import '../screens/ai/ai_screen.dart';
import '../screens/ats/ats_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/legal/legal_content.dart';
import '../screens/legal/legal_page_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/resume/resume_screen.dart';
import '../screens/resume/resume_viewer_screen.dart';
import '../screens/salary/salary_screen.dart';
import '../screens/settings/settings_screen.dart';

GoRouter createRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: auth.authenticated ? '/' : '/login',
    redirect: (context, state) {
      final loggedIn = auth.authenticated;
      final onLogin = state.matchedLocation == '/login';
      if (auth.loading) return null;
      if (!loggedIn && !onLogin) return '/login';
      if (loggedIn && onLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const AuthScreen(),
      ),
      // Own top-level route (not inside AppShell's ShellRoute) -- a resume
      // preview is a focused, full-screen task, not a tab destination, so
      // it owns its own Scaffold/back button rather than sitting inside the
      // bottom-nav shell.
      GoRoute(
        path: '/resume/:id/view',
        builder: (context, state) => ResumeViewerScreen(
          resumeId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
          title: state.uri.queryParameters['title'] ?? 'Resume',
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(
          currentPath: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(
            path: '/resume',
            builder: (_, __) => const ResumeScreen(),
          ),
          GoRoute(
            path: '/resume/:id',
            builder: (context, state) => ResumeScreen(
              initialResumeId: int.tryParse(state.pathParameters['id'] ?? ''),
            ),
          ),
          GoRoute(path: '/ai', builder: (_, __) => const AiScreen()),
          GoRoute(path: '/ats', builder: (_, __) => const AtsScreen()),
          GoRoute(path: '/salary', builder: (_, __) => const SalaryScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
          GoRoute(
            path: '/settings/privacy',
            builder: (_, __) => const LegalPageScreen(
              title: 'Privacy Policy',
              lastUpdated: kLegalLastUpdated,
              intro:
                  'This policy explains what information CareerOS AI collects, how it\'s used, and the choices you have. Written in plain language -- no legalese.',
              sections: kPrivacyPolicySections,
            ),
          ),
          GoRoute(
            path: '/settings/terms',
            builder: (_, __) => const LegalPageScreen(
              title: 'Terms of Service',
              lastUpdated: kLegalLastUpdated,
              intro: 'These terms govern your use of CareerOS AI. By using the app, you agree to them.',
              sections: kTermsOfServiceSections,
            ),
          ),
          GoRoute(
            path: '/settings/about',
            builder: (_, __) => const LegalPageScreen(
              title: 'About CareerOS',
              lastUpdated: kLegalLastUpdated,
              intro: kAboutIntro,
              sections: kAboutSections,
            ),
          ),
        ],
      ),
    ],
  );
}