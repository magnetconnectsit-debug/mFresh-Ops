import 'package:core/constants/app_colors.dart';
import 'package:services/connectivity_service.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh/widgets/no_internet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewPage extends StatefulWidget {
  final String? url;
  final String? title;
  final String? redirectUrlToCapture;

  const WebViewPage({
    super.key,
    this.url,
    this.title,
    this.redirectUrlToCapture,
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  final RxDouble _progress = 0.0.obs;
  String _url = '';
  String _title = '';
  String? _redirectUrlToCapture;

  @override
  void initState() {
    super.initState();
    
    final args = Get.arguments as Map<String, dynamic>?;
    _url = widget.url ?? args?['url'] ?? '';
    _title = widget.title ?? args?['title'] ?? 'Browser';
    _redirectUrlToCapture = widget.redirectUrlToCapture ?? args?['redirectUrlToCapture'];

    // Initialize controller
    _controller = WebViewController();
    
    // Configure controller
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    _controller.setBackgroundColor(AppColors.white);
    
    // Set standard User Agent to avoid ORB blocks
    _controller.setUserAgent("Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36");

    _controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          _progress.value = progress / 100;
        },
        onPageStarted: (String url) {
          _checkRedirect(url);
        },
        onPageFinished: (String url) {
          _checkRedirect(url);
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('WebView Error: ${error.description}');
        },
        onNavigationRequest: (NavigationRequest request) {
          if (_checkRedirect(request.url)) {
            return NavigationDecision.prevent;
          }
          
          if (!request.url.startsWith('http')) {
            _launchDeepLink(request.url);
            return NavigationDecision.prevent;
          }
          
          return NavigationDecision.navigate;
        },
      ),
    );

    if (_url.isNotEmpty) {
      if (!_url.startsWith('http')) {
        _url = 'https://$_url';
      }
      
      // Load request with headers for whitelisting
      _controller.loadRequest(
        Uri.parse(_url),
        headers: {
          'Referer': 'https://magnetconnects.com/',
          'Origin': 'https://magnetconnects.com',
        },
      );
    }
  }

  bool _checkRedirect(String url) {
    if (_redirectUrlToCapture != null && url.contains(_redirectUrlToCapture!)) {
      final uri = Uri.parse(url);
      Get.back(result: uri.queryParameters);
      return true;
    }
    return false;
  }

  Future<void> _launchDeepLink(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("WebView DeepLink Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppCommonAppBar(
        title: Text(_title),
        backgroundColor: AppColors.white,
        elevation: 0.5,
        hasBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser, color: AppColors.black),
            onPressed: () async {
              if (_url.isNotEmpty) {
                final uri = Uri.parse(_url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.black),
            onPressed: () => _controller.reload(),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: _url.isEmpty 
          ? const Center(child: Text("Invalid URL"))
          : Obx(() {
        final connectivity = Get.find<ConnectivityService>();
        if (!connectivity.isConnected.value) {
          return NoInternetWidget(
            onRetry: () {
              if (connectivity.isConnected.value) {
                _controller.reload();
              }
            },
          );
        }

        return Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_progress.value < 1.0)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: _progress.value,
                  color: AppColors.primary,
                  backgroundColor: AppColors.grey50,
                  minHeight: 3.0,
                ),
              ),
          ],
        );
      }),
    );
  }
}
