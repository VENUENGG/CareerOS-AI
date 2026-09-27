import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence for user preferences that have no dedicated backend
/// surface today (push/email/analytics opt-ins). Storing them locally makes
/// the toggles a real, remembered user preference instead of throwaway UI
/// state that resets every launch. Push delivery itself is a server concern
/// outside this app's current backend contract.
class SettingsStorage {
  static const _pushKey = 'settings_push_notifications';
  static const _emailKey = 'settings_email_updates';
  static const _analyticsKey = 'settings_analytics';

  static Future<bool> pushEnabled() => _read(_pushKey, true);
  static Future<bool> emailEnabled() => _read(_emailKey, true);
  static Future<bool> analyticsEnabled() => _read(_analyticsKey, false);

  static Future<void> setPushEnabled(bool value) => _write(_pushKey, value);
  static Future<void> setEmailEnabled(bool value) => _write(_emailKey, value);
  static Future<void> setAnalyticsEnabled(bool value) => _write(_analyticsKey, value);

  static Future<bool> _read(String key, bool fallback) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key) ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  static Future<void> _write(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (_) {
      // Preference simply won't survive a restart -- not worth failing a
      // settings toggle over.
    }
  }
}