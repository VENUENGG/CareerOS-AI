// Stub implementation for non-web platforms (mobile, desktop, test).
// This file is only compiled when the target is NOT web.

import 'package:flutter/foundation.dart';

Future<void> openPdfInBrowser(String pdfUrl, String title) async {
  throw UnsupportedError('Browser PDF opening is only available on web.');
}

String createPdfObjectUrl(Uint8List data, String mimeType) {
  throw UnsupportedError('Blob URLs are only available on web.');
}
