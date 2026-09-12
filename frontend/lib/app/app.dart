import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../providers/theme_controller.dart';
import 'router.dart';

class CareerOSApp extends StatelessWidget {
  const CareerOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeController = context.watch<ThemeController>();
    final router = createRouter(auth);

    // AppColors' tokens resolve dynamically against whichever of
    // AppTheme.light/AppTheme.dark was evaluated last (see colors.dart) --
    // so only ONE of them may be evaluated per build. Deciding the single
    // active theme here (instead of passing both theme/darkTheme +
    // themeMode to MaterialApp) is what keeps that invariant intact while
    // still supporting System/Light/Dark.
    final theme = themeController.effectiveBrightness == Brightness.dark ? AppTheme.dark : AppTheme.light;

    return MaterialApp.router(
      title: 'CareerOS AI',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: router,
    );
  }
}