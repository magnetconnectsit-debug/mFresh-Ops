import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/constants/app_colors.dart';

class AppCommonWebView extends StatefulWidget {
  final String url;
  final String title;

  const AppCommonWebView({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<AppCommonWebView> createState() => _AppCommonWebViewState();
}

class _AppCommonWebViewState extends State<AppCommonWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppCommonAppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}
