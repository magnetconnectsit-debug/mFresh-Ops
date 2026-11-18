import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:core/widgets/custom_app_loader.dart';

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
  bool _isLoading = true;
  String _url = '';
  String _title = 'Browser';
  String? _redirectUrlToCapture;
  final RxDouble _progress = 0.0.obs;
  bool _isRedirected = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _url = widget.url ?? args?['url'] ?? '';
    _title = widget.title ?? args?['title'] ?? 'Browser';
    _redirectUrlToCapture =
        widget.redirectUrlToCapture ?? args?['redirectUrlToCapture'];

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            _progress.value = progress / 100.0;
          },
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            debugPrint("WebView Page Started: $url");
            _checkRedirect(url);

            // Clean non-invasive styling to ensure 100% viewport width without horizontal scroll
            _controller.runJavaScript("""
              (function() {
                var styleId = 'phonepe-clean-responsive-style';
                if (!document.getElementById(styleId)) {
                  var style = document.createElement('style');
                  style.id = styleId;
                  style.innerHTML = `
                    html, body {
                      max-width: 100% !important;
                      overflow-x: hidden !important;
                      -webkit-text-size-adjust: 100% !important;
                    }
                    .qr-image-wrapper img, [data-testid*="qr"] img, img[alt*="qr" i] {
                      max-width: min(65vw, 220px) !important;
                      height: auto !important;
                      margin: 0 auto !important;
                      display: block !important;
                    }
                  `;
                  document.head.appendChild(style);
                }
              })();
            """);

            _controller.runJavaScript("""
              if (!Array.prototype.at) {
                Array.prototype.at = function(n) {
                  n = Math.trunc(n) || 0;
                  if (n < 0) n += this.length;
                  if (n < 0 || n >= this.length) return undefined;
                  return this[n];
                };
              }
              if (!String.prototype.at) {
                String.prototype.at = function(n) {
                  n = Math.trunc(n) || 0;
                  if (n < 0) n += this.length;
                  if (n < 0 || n >= this.length) return undefined;
                  return this[n];
                };
              }
            """);

            _checkRedirect(url);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            debugPrint("WebView Page Finished: $url");
            _checkRedirect(url);
          },
          onUrlChange: (UrlChange change) {
            if (change.url != null) {
              _checkRedirect(change.url!);
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("WebView Error: ${error.description} for ${error.url}");
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;

            if (_checkRedirect(url)) {
              return NavigationDecision.prevent;
            }

            if (url.startsWith('ppesim://') ||
                url.startsWith('phonepe://') ||
                url.startsWith('upi://') ||
                url.startsWith('paytmmp://') ||
                url.startsWith('gpay://')) {
              debugPrint("External Scheme Detected: $url");
              _launchExternalApp(url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );

    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller.clearCache();
    _controller.clearLocalStorage();

    if (_url.isNotEmpty) {
      if (!_url.startsWith('http')) {
        _url = 'https://$_url';
      }

      // Load request with mandatory headers for production whitelisting
      _controller.loadRequest(
        Uri.parse(_url),
        headers: {
          'Referer': 'https://magnetconnects.com/',
          'Origin': 'https://magnetconnects.com',
        },
      );
    }
  }

  Future<void> _launchExternalApp(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Could not launch $url: $e");
    }
  }

  bool _checkRedirect(String url) {
    if (_isRedirected) return false;

    final uri = Uri.tryParse(url);
    final params = uri?.queryParameters ?? {};
    final String code =
        (params['code'] ?? params['status'] ?? '').toString().toUpperCase();

    // 1. Explicit Failure or Cancellation
    final bool isExplicitFailure = code.contains('ERROR') ||
        code.contains('FAIL') ||
        code.contains('CANCEL') ||
        code.contains('DECLIN') ||
        url.contains('PAYMENT_ERROR') ||
        url.contains('status=FAILED') ||
        url.contains('payment_status=failed');

    if (isExplicitFailure) {
      debugPrint("⚠️ FAILURE/CANCEL REDIRECT DETECTED: $url");
      _isRedirected = true;
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          Get.back(result: {
            'status': 'FAILURE',
            'code': code,
            'url': url,
            'params': params,
          });
        }
      });
      return true;
    }

    // 2. Explicit Success
    final bool isExplicitSuccess = code == 'PAYMENT_SUCCESS' ||
        code == 'SUCCESS' ||
        url.contains('booking-success') ||
        url.contains('PAYMENT_SUCCESS') ||
        url.contains('status=SUCCESS') ||
        url.contains('payment_status=success');

    // 3. Domain Whitelist match
    final bool matchesRedirect =
        _redirectUrlToCapture != null && url.contains(_redirectUrlToCapture!);

    if (isExplicitSuccess || matchesRedirect) {
      debugPrint("🎯 REDIRECT DETECTED: $url (success: $isExplicitSuccess)");
      _isRedirected = true;
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          Get.back(result: {
            'status': isExplicitSuccess ? 'SUCCESS' : 'REDIRECTED',
            'code': code,
            'url': url,
            'params': params,
          });
        }
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: CustomAppLoader(size: 20, strokeWidth: 1.0),
              ),
            ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
