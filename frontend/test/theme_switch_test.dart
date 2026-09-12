// Regression test for real theme switching: AppColors' tokens (see
// core/design/colors.dart) resolve dynamically against whichever
// brightness AppTheme.light/AppTheme.dark last set, and ThemeController
// decides which of those two CareerOSApp evaluates each build.
//
// NOTE: ThemeController's persistence goes through SharedPreferences, whose
// platform channel hangs (rather than rejecting) under plain `testWidgets`
// in this environment -- so this file deliberately never constructs a
// ThemeController or calls setMode(); the actual "does the picker flip
// AppColors" path is covered structurally by the theme rebuild in
// app.dart/settings_screen.dart and by AppShell rendering both themes
// cleanly in live_backend_smoke_test.dart. What matters most, and what
// this actually verifies, is that light and dark are genuinely two
// different, complete palettes -- not one theme with a brightness flag
// flipped, which was the original bug.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careeros/core/theme/app_theme.dart';

void main() {
  testWidgets('AppTheme.light and AppTheme.dark are genuinely different palettes, not one theme with brightness flipped', (tester) async {
    final darkTheme = AppTheme.dark;
    final darkBackground = darkTheme.scaffoldBackgroundColor;
    final lightTheme = AppTheme.light;
    final lightBackground = lightTheme.scaffoldBackgroundColor;

    expect(darkBackground, isNot(equals(lightBackground)), reason: 'light and dark must use different background colors');
    expect(lightTheme.brightness, Brightness.light);
    expect(darkTheme.brightness, Brightness.dark);
    // A real light palette (not an inverted dark one): background should be
    // a light color, not the same near-black used for dark mode.
    expect(lightBackground.computeLuminance(), greaterThan(0.8));
    expect(darkBackground.computeLuminance(), lessThan(0.1));

    // Text/surface colors must also differ, not just the scaffold background
    // -- this is what catches the ".copyWith(brightness: ...)" bug where
    // only the brightness enum flips but every actual color stays dark.
    expect(lightTheme.colorScheme.onSurface, isNot(equals(darkTheme.colorScheme.onSurface)));
    expect(lightTheme.cardTheme.color, isNot(equals(darkTheme.cardTheme.color)));
    expect(lightTheme.colorScheme.onSurface.computeLuminance(), lessThan(0.3), reason: 'light mode body text must be dark-on-light, not still light-on-light');
  });
}
