// Web-only implementation - opens PDF blob directly in browser or triggers download.
// This file is ONLY compiled on web targets.

import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

Future<void> openPdfInBrowser(Uint8List bytes, String title) async {
  if (bytes.isEmpty) return;
  final jsArray = bytes.toJS;
  final blobParts = [jsArray].toJS;
  final blob = web.Blob(
    blobParts,
    web.BlobPropertyBag(type: 'application/pdf'),
  );
  final url = web.URL.createObjectURL(blob);
  final win = web.window.open(url, '_blank');
  if (win == null) {
    // Popup was blocked by browser - fallback to downloading directly
    await downloadPdf(bytes, title);
  }
  // Revoke object URL after giving the browser tab enough time to load it
  Future.delayed(const Duration(minutes: 5), () {
    web.URL.revokeObjectURL(url);
  });
}

Future<void> downloadPdf(Uint8List bytes, String filename) async {
  if (bytes.isEmpty) return;
  final jsArray = bytes.toJS;
  final blobParts = [jsArray].toJS;
  final blob = web.Blob(
    blobParts,
    web.BlobPropertyBag(type: 'application/pdf'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = filename.endsWith('.pdf') ? filename : '$filename.pdf';
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
  Future.delayed(const Duration(minutes: 1), () {
    web.URL.revokeObjectURL(url);
  });
}
