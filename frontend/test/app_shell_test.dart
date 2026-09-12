// Regression + responsive sweep for every screen rendered inside the app's
// ShellRoute (Dashboard, Resume, AI, ATS, Salary, Profile, Settings).
//
// AppShell is the single Material/Scaffold ancestor those screens rely on
// (TextField, IconButton, NavigationBar, PopupMenuButton, etc. all assert
// on it) -- if that ancestor is ever removed, or a screen regresses to
// overflowing at a real device width, this fails loudly here instead of
// manifesting as a runtime "black screen" or yellow/black stripe a user
// has to discover by hand. No emulator/browser is available in this
// environment, so this is the automated substitute for a manual
// small-phone/phone/tablet/desktop pass across every route.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:careeros/core/network/api_client.dart';
import 'package:careeros/core/storage/token_storage.dart';
import 'package:careeros/core/theme/app_theme.dart';
import 'package:careeros/core/widgets/app_shell.dart';
import 'package:careeros/providers/app_providers.dart';
import 'package:careeros/repositories/careeros_repository.dart';
import 'package:careeros/screens/ai/ai_screen.dart';
import 'package:careeros/screens/ats/ats_screen.dart';
import 'package:careeros/screens/dashboard/dashboard_screen.dart';
import 'package:careeros/screens/profile/profile_screen.dart';
import 'package:careeros/screens/resume/resume_screen.dart';
import 'package:careeros/screens/salary/salary_screen.dart';
import 'package:careeros/screens/settings/settings_screen.dart';

Widget _harness(Widget shellChild, {required String currentPath}) {
  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenStorage);
  final repository = CareerOSRepository(apiClient);

  return MultiProvider(
    providers: [
      Provider<TokenStorage>.value(value: tokenStorage),
      Provider<ApiClient>.value(value: apiClient),
      Provider<CareerOSRepository>.value(value: repository),
      ChangeNotifierProvider(create: AuthProvider.create),
      ChangeNotifierProvider(create: CareerDataProvider.create),
      ChangeNotifierProvider(create: (_) => AvatarController()),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      home: AppShell(currentPath: currentPath, child: shellChild),
    ),
  );
}

/// A handful of manually-timed pumps rather than pumpAndSettle: the app has
/// legitimately perpetual animations (indeterminate loading spinners/
/// skeletons), which pumpAndSettle can never consider "settled", so it
/// isn't the right tool here. This just needs to flush the microtask/timer
/// chain behind CareerDataProvider.loadAll()'s parallel requests.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('AppShell gives the AI screen a Material ancestor for its TextFields', (tester) async {
    await tester.pumpWidget(_harness(const AiScreen(), currentPath: '/ai'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(TextFormField), findsWidgets);
  });

  testWidgets('Mobile bottom NavigationBar renders without a Material assertion', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_harness(const DashboardScreen(), currentPath: '/'));
    await _settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  // Every route the ShellRoute serves, swept across small phone / phone /
  // tablet / desktop widths -- the exact breakpoints DashboardScreen,
  // AtsScreen, etc. branch their layout on (600, 900) plus the extremes on
  // either side of them.
  final screens = <String, Widget Function()>{
    '/': () => const DashboardScreen(),
    '/profile': () => const ProfileScreen(),
    '/resume': () => const ResumeScreen(),
    '/ai': () => const AiScreen(),
    '/ats': () => const AtsScreen(),
    '/salary': () => const SalaryScreen(),
    '/settings': () => const SettingsScreen(),
  };

  final widths = <String, double>{
    'small phone 360w': 360,
    'phone 412w': 412,
    'tablet 768w': 768,
    'desktop 1280w': 1280,
  };

  for (final screenEntry in screens.entries) {
    for (final widthEntry in widths.entries) {
      testWidgets('${screenEntry.key} renders at ${widthEntry.key} without overflow or exceptions', (tester) async {
        tester.view.physicalSize = Size(widthEntry.value, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_harness(screenEntry.value(), currentPath: screenEntry.key));
        await _settle(tester);

        expect(tester.takeException(), isNull);
      });
    }
  }
}
