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

// Conditional import: web-specific PDF opening vs stub for non-web
import '_pdf_downloader_stub.dart'
    if (dart.library.js_interop) '_pdf_downloader_web.dart' as pdf_helper;

/// A real, in-app "open resume" experience that works across all platforms.
///
/// - **Web**: Fetches PDF bytes with authentication, creates a Blob URL, and
///   opens in a new browser tab with proper cleanup.
/// - **Mobile/Desktop**: Loads the resume's rendered HTML in a WebView with
///   loading state, error handling, and retry mechanism.
///
/// This is its own top-level route (not inside AppShell's ShellRoute), so
/// it owns its own Scaffold.
class ResumeViewerScreen extends StatefulWidget {
  final int resumeId;
  final String title;

  const ResumeViewerScreen({super.key, required this.resumeId, required this.title});

  @override
  State<ResumeViewerScreen> createState() => _ResumeViewerScreenState();
}

class _ResumeViewerScreenState extends State<ResumeViewerScreen> {
  WebViewController? _controller;
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
      if (kIsWeb) {
        await _loadWeb();
      } else {
        await _loadMobile();
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

  /// Web implementation: Fetch PDF bytes and open in new tab
  Future<void> _loadWeb() async {
    if (!mounted) return;

    // Use the platform-specific helper to open PDF in browser
    final pdfUrl = '${ApiConfig.baseUrl}/v1/resumes/${widget.resumeId}/pdf';
    await pdf_helper.openPdfInBrowser(pdfUrl, widget.title);

    // Success - navigate back since PDF opened in new tab
    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const material.Text('PDF opened in new tab'),
          backgroundColor: AppColors.successContainer,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) context.pop();
      });
    }
  }

  /// Mobile/Desktop implementation: Load HTML in WebView
  Future<void> _loadMobile() async {
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
  }

  String _formatApiError(ApiException e) {
    switch (e.statusCode) {
      case 401:
        return 'Session expired. Please sign in again.';
      case 403:
        return 'You don\'t have permission to view this resume.';
      case 404:
        return 'Resume not found. It may have been deleted.';
      case 500:
        return 'Server error. Please try again in a moment.';
      default:
        if (e.message.contains('timeout') || e.message.contains('connection')) {
          return 'Connection failed. Check your internet and try again.';
        }
        return e.message;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: material.Text(widget.title, style: AppTypography.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: AppIconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!_loading && _error == null && !kIsWeb)
            AppIconButton(
              icon: const Icon(Icons.refresh_rounded, size: 22),
              onPressed: _retry,
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_controller != null && _error == null && !kIsWeb)
            WebViewWidget(controller: _controller!),
          
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
