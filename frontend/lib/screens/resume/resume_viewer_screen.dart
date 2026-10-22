import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:flutter/material.dart' as material show Text;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/design/design.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_config.dart';
import '../../core/storage/token_storage.dart';
import '../../core/widgets/widgets.dart';
import '../../providers/app_providers.dart';
import '../../repositories/careeros_repository.dart';

// Conditional import: web-specific PDF opening vs stub for non-web
import '_pdf_downloader_stub.dart'
    if (dart.library.js_interop) '_pdf_downloader_web.dart' as pdf_helper;

/// An in-app "open resume" experience that works across all platforms.
///
/// - **Web**: Fetches authenticated PDF bytes, creates a Blob URL, opens in a
///   new browser tab, and provides Download and Re-open controls.
/// - **Mobile**: Loads the resume's rendered HTML in a WebView, with an AppBar
///   action to download/share the actual PDF.
/// - **Desktop**: Displays a clean PDF preview card with one-click download/export.
class ResumeViewerScreen extends StatefulWidget {
  final int resumeId;
  final String title;

  const ResumeViewerScreen({super.key, required this.resumeId, required this.title});

  @override
  State<ResumeViewerScreen> createState() => _ResumeViewerScreenState();
}

class _ResumeViewerScreenState extends State<ResumeViewerScreen> {
  WebViewController? _controller;
  Uint8List? _pdfBytes;
  bool _loading = true;
  String? _error;
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repo = context.read<CareerOSRepository>();
      final data = context.read<CareerDataProvider>();

      // Ensure selections are present so the backend can render PDF or HTML
      await repo.ensureResumeSelections(
        widget.resumeId,
        skillIds: data.skills.map((s) => s.id).whereType<int>().toList(),
        projectIds: data.projects.map((p) => p.id).whereType<int>().toList(),
        experienceIds: data.experience.map((e) => e.id).whereType<int>().toList(),
        educationIds: data.education.map((e) => e.id).whereType<int>().toList(),
        certificationIds: data.certifications.map((c) => c.id).whereType<int>().toList(),
        languageIds: data.languages.map((l) => l.id).whereType<int>().toList(),
      );

      final bytes = await repo.resumePdfBytes(widget.resumeId);
      if (bytes.isEmpty) {
        throw ApiException('Server returned an empty PDF file.');
      }
      _pdfBytes = Uint8List.fromList(bytes);

      if (kIsWeb) {
        await _loadWeb();
      } else {
        await _loadMobileOrDesktop();
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = _formatApiError(e);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Couldn\'t load this resume. Please try again.';
        });
      }
    }
  }

  /// Web implementation: opens PDF blob in browser tab and updates state
  Future<void> _loadWeb() async {
    if (!mounted || _pdfBytes == null) return;
    await pdf_helper.openPdfInBrowser(_pdfBytes!, widget.title);
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  /// Mobile/Desktop implementation
  Future<void> _loadMobileOrDesktop() async {
    final isDesktop = defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;

    if (isDesktop) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final tokenStorage = context.read<TokenStorage>();
      final token = await tokenStorage.read();

      if (token == null || token.isEmpty) {
        throw ApiException('Authentication required', statusCode: 401);
      }

      final url = '${ApiConfig.baseUrl}/v1/templates/resumes/${widget.resumeId}';
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.disabled)
        ..setBackgroundColor(AppColors.surface)
        ..setNavigationDelegate(NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() {
                _loading = false;
                _retryCount = 0;
              });
            }
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _loading = false;
                _error = 'Failed to load resume: ${error.description}';
              });
            }
          },
          onHttpError: (error) {
            if (mounted) {
              setState(() {
                _loading = false;
                _error = _formatHttpError(error.response?.statusCode);
              });
            }
          },
        ))
        ..loadRequest(
          Uri.parse(url),
          headers: {'Authorization': 'Bearer $token'},
        );

      if (mounted) setState(() => _controller = controller);
    } catch (_) {
      // Graceful fallback on devices/environments without WebView support
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatApiError(ApiException e) {
    if (e.statusCode == 401) {
      return 'Session expired. Please sign in again.';
    }
    if (e.statusCode == 403) {
      return 'You don\'t have permission to view this resume.';
    }
    final lower = e.message.toLowerCase();
    if (lower.contains('profile not found') || lower.contains('user profile')) {
      return 'Please complete your profile before viewing resumes.';
    }
    if (lower.contains('selection')) {
      return 'Resume content has not been selected yet. Please configure resume content.';
    }
    if (e.statusCode == 404 || lower.contains('not found') || lower.contains('does not exist')) {
      return 'Resume not found. It may have been deleted.';
    }
    if (lower.contains('timeout') || lower.contains('connection')) {
      return 'Connection failed. Check your internet connection and try again.';
    }
    if (e.statusCode != null && e.statusCode! >= 500) {
      return 'Server error. Please try again in a moment.';
    }
    return e.message.isNotEmpty ? e.message : 'Couldn\'t load this resume. Please try again.';
  }

  String _formatHttpError(int? statusCode) {
    switch (statusCode) {
      case 401:
        return 'Session expired. Please sign in again.';
      case 403:
        return 'Access denied. You don\'t have permission to view this resume.';
      case 404:
        return 'Resume not found. It may have been deleted.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again in a moment.';
      default:
        return 'Failed to load resume (HTTP $statusCode).';
    }
  }

  void _retry() {
    _retryCount++;
    _load();
  }

  Future<void> _download() async {
    if (_pdfBytes == null) return;
    await pdf_helper.downloadPdf(_pdfBytes!, widget.title);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const material.Text('Resume download initiated'),
          backgroundColor: AppColors.successContainer,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final showWebOrDesktopCard = !kIsWeb && _controller == null && _pdfBytes != null && !_loading && _error == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: material.Text(widget.title, style: AppTypography.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: AppIconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_pdfBytes != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: AppIconButton(
                icon: const Icon(Icons.download_rounded, size: 22),
                tooltip: 'Download PDF',
                onPressed: _download,
              ),
            ),
          if (!_loading && _error == null && !kIsWeb && _controller != null)
            AppIconButton(
              icon: const Icon(Icons.refresh_rounded, size: 22),
              tooltip: 'Refresh',
              onPressed: _retry,
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_controller != null && _error == null && !kIsWeb)
            WebViewWidget(controller: _controller!),

          if (kIsWeb && !_loading && _error == null && _pdfBytes != null)
            Center(
              child: Padding(
                padding: AppSpacing.xxlAll,
                child: AppCard(
                  padding: AppSpacing.xxlAll,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: AppSpacing.lgAll,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.picture_as_pdf_rounded, size: 40, color: AppColors.primary),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      material.Text(widget.title, style: AppTypography.titleLarge, textAlign: TextAlign.center),
                      const SizedBox(height: AppSpacing.xs),
                      material.Text('PDF document generated successfully', style: AppTypography.bodySmall.muted()),
                      const SizedBox(height: AppSpacing.xl),
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        alignment: WrapAlignment.center,
                        children: [
                          AppButton(
                            label: 'Re-open in browser',
                            leading: const Icon(Icons.open_in_new_rounded, size: 18),
                            onPressed: () => pdf_helper.openPdfInBrowser(_pdfBytes!, widget.title),
                            style: AppButtonStyle.outline,
                          ),
                          AppButton(
                            label: 'Download PDF',
                            leading: const Icon(Icons.download_rounded, size: 18),
                            onPressed: _download,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (showWebOrDesktopCard)
            Center(
              child: Padding(
                padding: AppSpacing.xxlAll,
                child: AppCard(
                  padding: AppSpacing.xxlAll,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: AppSpacing.lgAll,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.picture_as_pdf_rounded, size: 40, color: AppColors.primary),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      material.Text(widget.title, style: AppTypography.titleLarge, textAlign: TextAlign.center),
                      const SizedBox(height: AppSpacing.xs),
                      material.Text('PDF ready for export', style: AppTypography.bodySmall.muted()),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        label: 'Download PDF',
                        leading: const Icon(Icons.download_rounded, size: 18),
                        onPressed: _download,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_error != null)
            Center(
              child: Padding(
                padding: AppSpacing.xxlAll,
                child: ErrorState(
                  title: 'Couldn\'t open resume',
                  message: _error,
                  actionLabel: 'Retry',
                  onAction: _retry,
                  secondaryActionLabel: 'Go back',
                  onSecondaryAction: () => context.pop(),
                  icon: Icons.description_outlined,
                ),
              ),
            ),

          if (_loading && _error == null)
            Container(
              color: AppColors.background,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: AppSpacing.lg),
                    material.Text(
                      kIsWeb ? 'Opening PDF...' : 'Loading resume...',
                      style: AppTypography.bodyMedium.muted(),
                    ),
                    if (_retryCount > 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      material.Text(
                        'Retry attempt $_retryCount',
                        style: AppTypography.bodySmall.muted(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
