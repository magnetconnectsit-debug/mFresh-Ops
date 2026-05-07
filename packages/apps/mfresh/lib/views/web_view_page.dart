import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:get/get.dart';
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

    // Force Mobile User Agent for better scaling of QR
    const String mobileUserAgent =
        "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36";
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setUserAgent(mobileUserAgent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            _progress.value = progress / 100.0;
          },
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            debugPrint("WebView Page Started: $url");
            _checkRedirect(url);
            
            // Inject CSS to scale down QR if too large (Tiny Scale)
            _controller.runJavaScript("""
              var style = document.createElement('style');
              style.innerHTML = 'img { max-width: 30% !important; height: auto !important; margin: 0 auto !important; display: block !important; } .qr-code-container, .qr-container { transform: scale(0.3) !important; transform-origin: top center !important; margin-bottom: -150px !important; }';
              document.head.appendChild(style);
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
            
            // Re-apply tiny scaling after load
            _controller.runJavaScript("""
              var style = document.createElement('style');
              style.innerHTML = 'img { max-width: 30% !important; height: auto !important; margin: 0 auto !important; display: block !important; } .qr-code-container, .qr-container { transform: scale(0.3) !important; transform-origin: top center !important; margin-bottom: -150px !important; }';
              document.head.appendChild(style);
            """);
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

    final bool matchesRedirect =
        _redirectUrlToCapture != null && url.contains(_redirectUrlToCapture!);
    final bool containsSuccess = url.contains('booking-success') ||
        url.contains('PAYMENT_SUCCESS') ||
        url.contains('status=SUCCESS') ||
        url.contains('payment_status=success');

    if (matchesRedirect || containsSuccess) {
      debugPrint("🎯 SUCCESS REDIRECT DETECTED: $url");
      _isRedirected = true;
      final uri = Uri.parse(url);
      
      // Delay slightly to ensure user sees the success state if it's a page
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Get.back(result: uri.queryParameters);
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
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
