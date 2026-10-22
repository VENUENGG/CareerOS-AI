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
  static Future<bool> launch(String? url) async {
    if (url == null || url.trim().isEmpty) return false;
    
    String normalizedUrl = url.trim();
    
    // Add https:// if no protocol is present
    if (!normalizedUrl.startsWith('http://') && 
        !normalizedUrl.startsWith('https://') &&
        !normalizedUrl.startsWith('mailto:')) {
      normalizedUrl = 'https://$normalizedUrl';
    }
    
    try {
      final uri = Uri.tryParse(normalizedUrl);
      if (uri == null || !uri.hasScheme) return false;
      if (uri.scheme != 'mailto' && (!uri.hasAuthority || !uri.host.contains('.'))) {
        return false;
      }
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      return false;
    }
  }
  
  /// Checks if a string appears to be a valid URL.
  static bool isUrl(String? text) {
    if (text == null || text.trim().isEmpty) return false;
    
    final trimmed = text.trim();
    final toParse = (trimmed.startsWith('http://') || trimmed.startsWith('https://'))
        ? trimmed
        : 'https://$trimmed';
    final uri = Uri.tryParse(toParse);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority || !uri.host.contains('.')) {
      return false;
    }
    if (uri.host.contains(' ')) return false;
    return true;
  }
}
