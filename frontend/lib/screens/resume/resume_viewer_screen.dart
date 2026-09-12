import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/design/design.dart';
import '../../core/network/api_config.dart';
import '../../core/storage/token_storage.dart';
import '../../core/widgets/widgets.dart';

/// A real, in-app "open resume" experience -- loads the resume's rendered
/// HTML (the backend already generates this at
/// GET /v1/templates/resumes/{id}, the same source it uses for the PDF
/// export) in a WebView with its own back button, loading state, and error
/// state with retry. This is its own top-level route (not inside AppShell's
/// ShellRoute), so -- like AuthScreen -- it owns its own Scaffold.
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

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _load();
    } else {
      // webview_flutter has no bundled web implementation in this project;
      // the "Share" action (which works everywhere via share_plus) is the
      // supported path to view/save a resume on web.
      _loading = false;
      _error = 'In-app preview isn\'t available on web yet. Use Share to download the PDF instead.';
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tokenStorage = context.read<TokenStorage>();
      final token = await tokenStorage.read();
      final url = '${ApiConfig.baseUrl}/v1/templates/resumes/${widget.resumeId}';
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.disabled)
        ..setBackgroundColor(AppColors.surface)
        ..setNavigationDelegate(NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            if (mounted) setState(() => _error = 'Couldn\'t load this resume (${error.description}).');
          },
        ))
        ..loadRequest(
          Uri.parse(url),
          headers: {if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token'},
        );
      if (mounted) setState(() => _controller = controller);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Couldn\'t load this resume. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title, style: AppTypography.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: AppIconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          if (_controller != null && _error == null) WebViewWidget(controller: _controller!),
          if (_error != null)
            Center(
              child: Padding(
                padding: AppSpacing.xxlAll,
                child: ErrorState(
                  title: 'Couldn\'t open resume',
                  message: _error,
                  actionLabel: kIsWeb ? null : 'Retry',
                  onAction: kIsWeb ? null : _load,
                  icon: Icons.description_outlined,
                ),
              ),
            ),
          if (_loading && _error == null)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
