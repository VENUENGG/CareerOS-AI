// Stub implementation for non-web platforms (mobile, desktop, test).
// This file is compiled when the target is NOT web.

import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

Future<void> openPdfInBrowser(Uint8List bytes, String title) async {
  if (bytes.isEmpty) return;
  await downloadPdf(bytes, title);
}

Future<void> downloadPdf(Uint8List bytes, String filename) async {
  if (bytes.isEmpty) return;
  final safeName = filename.endsWith('.pdf') ? filename : '$filename.pdf';
  await SharePlus.instance.share(
    ShareParams(
      files: [
        XFile.fromData(
          bytes,
          name: safeName,
          mimeType: 'application/pdf',
        ),
      ],
      subject: filename,
    ),
  );
}
