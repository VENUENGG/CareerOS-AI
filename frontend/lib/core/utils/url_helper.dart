import 'package:url_launcher/url_launcher.dart';

/// URL handling utilities for CareerOS.
///
/// Provides safe URL launching with proper https:// prefix handling
/// and error fallback for external links.
class UrlHelper {
  /// Attempts to launch a URL, adding https:// prefix if missing.
  ///
  /// Returns true if the URL was successfully launched, false otherwise.
  /// Handles URLs that may be missing the protocol (e.g., "github.com/user")
  static Future<bool> launch(String url) async {
    if (url.isEmpty) return false;
    
    String normalizedUrl = url.trim();
    
    // Add https:// if no protocol is present
    if (!normalizedUrl.startsWith('http://') && 
        !normalizedUrl.startsWith('https://') &&
        !normalizedUrl.startsWith('mailto:')) {
      normalizedUrl = 'https://$normalizedUrl';
    }
    
    try {
      final uri = Uri.parse(normalizedUrl);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      return false;
    }
  }
  
  /// Checks if a string appears to be a valid URL.
  static bool isUrl(String? text) {
    if (text == null || text.isEmpty) return false;
    
    final urlPattern = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );
    
    return urlPattern.hasMatch(text.trim());
  }
}
