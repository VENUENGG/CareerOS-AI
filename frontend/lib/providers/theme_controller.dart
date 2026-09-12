import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The user's theme preference. "system" tracks the OS setting and updates
/// live if the user flips their phone's system theme while the app is open.
enum AppThemeMode { system, light, dark }

/// Owns the app's single source of truth for light/dark: which mode the
/// user picked (persisted), and -- when that mode is "system" -- the
/// current OS brightness (kept live via WidgetsBindingObserver so a system
/// theme change is reflected without an app restart).
///
/// CareerOSApp reads [effectiveBrightness] to decide which of
/// AppTheme.light/AppTheme.dark to hand to MaterialApp, and AppColors'
/// tokens (see core/design/colors.dart) resolve against whichever one that
/// was -- so a single change here repaints every screen consistently,
/// rather than each screen deciding its own colors.
class ThemeController extends ChangeNotifier with WidgetsBindingObserver {
  static const _prefsKey = 'theme_mode';

  AppThemeMode _mode = AppThemeMode.system;
  Brightness _platformBrightness;

  ThemeController({Brightness? initialPlatformBrightness})
      : _platformBrightness = initialPlatformBrightness ?? WidgetsBinding.instance.platformDispatcher.platformBrightness {
    WidgetsBinding.instance.addObserver(this);
    _restore();
  }

  AppThemeMode get mode => _mode;

  Brightness get effectiveBrightness =>
      _mode == AppThemeMode.system ? _platformBrightness : (_mode == AppThemeMode.dark ? Brightness.dark : Brightness.light);

  @override
  void didChangePlatformBrightness() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    if (brightness == _platformBrightness) return;
    _platformBrightness = brightness;
    if (_mode == AppThemeMode.system) notifyListeners();
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      final restored = AppThemeMode.values.where((m) => m.name == saved).firstOrNull;
      if (restored != null && restored != _mode) {
        _mode = restored;
        notifyListeners();
      }
    } catch (_) {
      // No local storage available -- stay on the "system" default.
    }
  }

  Future<void> setMode(AppThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, mode.name);
    } catch (_) {
      // Selection still applies for this session even if it can't persist.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
