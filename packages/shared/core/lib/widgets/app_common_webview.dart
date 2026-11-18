// region Imports
import 'dart:io';

import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
// endregion

// region Widget Definition
class AppCommonWebView extends StatefulWidget {
  final String? url;
  final String? title;
  final String? redirectUrlToCapture;
  final Map<String, String>? headers;
  final bool enableUpiSchemes;
  final void Function(Map<String, dynamic> result)? onRedirectCaptured;

  const AppCommonWebView({
    super.key,
    this.url,
    this.title,
    this.redirectUrlToCapture,
    this.headers,
    this.enableUpiSchemes = true,
    this.onRedirectCaptured,
  });

  @override
  State<AppCommonWebView> createState() => _AppCommonWebViewState();
}
// endregion

class _AppCommonWebViewState extends State<AppCommonWebView> {
  // region Properties & State Variables
  late final WebViewController _controller;
  final RxBool _isLoading = true.obs;
  String _url = '';
  String _title = 'Browser';
  String? _redirectUrlToCapture;
  final RxDouble _progress = 0.0.obs;
  bool _isRedirected = false;
  // endregion

  // region Lifecycle Methods
  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _url = widget.url ?? args?['url'] ?? '';
    _title = widget.title ?? args?['title'] ?? 'Browser';
    _redirectUrlToCapture = widget.redirectUrlToCapture ??
        args?['redirectUrlToCapture'] ??
        'https://magnetconnects.com/';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.white)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            _progress.value = progress / 100.0;
          },
          onPageStarted: (String url) {
            _isLoading.value = true;
            debugPrint("AppCommonWebView Page Started: $url");
            _checkRedirect(url);

            // Inject non-invasive styling to ensure 100% viewport width without horizontal scroll
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

            // Polyfills for Array.prototype.at and String.prototype.at for legacy WebViews
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
            _isLoading.value = false;
            debugPrint("AppCommonWebView Page Finished: $url");
            _checkRedirect(url);
          },
          onUrlChange: (UrlChange change) {
            if (change.url != null) {
              _checkRedirect(change.url!);
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("AppCommonWebView Error: ${error.description} for ${error.url}");
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;

            if (_checkRedirect(url)) {
              return NavigationDecision.prevent;
            }

            // Launch UPI & payment app intents outside WebView
            if (widget.enableUpiSchemes &&
                (url.startsWith('ppesim://') ||
                    url.startsWith('phonepe://') ||
                    url.startsWith('upi://') ||
                    url.startsWith('paytmmp://') ||
                    url.startsWith('gpay://'))) {
              debugPrint("External Scheme Detected: $url");
              _launchExternalApp(url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );

    if (Platform.isAndroid && _controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(kDebugMode);
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller.clearCache();
    _controller.clearLocalStorage();

    if (_url.isNotEmpty) {
      if (!_url.startsWith('http')) {
        _url = 'https://$_url';
      }

      final Map<String, String> requestHeaders = {
        'Referer': 'https://magnetconnects.com/',
        'Origin': 'https://magnetconnects.com',
        ...?widget.headers,
        ...?args?['headers'] as Map<String, String>?,
      };

      _controller.loadRequest(
        Uri.parse(_url),
        headers: requestHeaders,
      );
    }
  }
  // endregion

  // region Handlers & Redirect Interception
  Future<void> _launchExternalApp(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Could not launch external url $url: $e");
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
      _controller.loadRequest(Uri.parse('about:blank'));
      final resultMap = {
        'status': 'FAILURE',
        'code': code,
        'url': url,
        'params': params,
      };

      widget.onRedirectCaptured?.call(resultMap);

      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          Get.back(result: resultMap);
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
    final bool matchesRedirect = _redirectUrlToCapture != null &&
        _redirectUrlToCapture!.isNotEmpty &&
        (url.startsWith(_redirectUrlToCapture!) ||
            url.contains('magnetconnects.com'));

    if (isExplicitSuccess || matchesRedirect) {
      debugPrint("🎯 REDIRECT DETECTED: $url (success: $isExplicitSuccess)");
      _isRedirected = true;
      _controller.loadRequest(Uri.parse('about:blank'));
      final resultMap = {
        'status': isExplicitSuccess ? 'SUCCESS' : 'REDIRECTED',
        'code': code,
        'url': url,
        'params': params,
      };

      widget.onRedirectCaptured?.call(resultMap);

      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          Get.back(result: resultMap);
        }
      });
      return true;
    }

    return false;
  }
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          _controller.loadRequest(Uri.parse('about:blank'));
          Get.back();
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }
  // endregion

  // region Header & App Bar
  PreferredSizeWidget _buildAppBar() {
    return AppCommonAppBar(
      title: Text(
        _title,
        style: AppTextStyle.style_16_600(color: AppColors.black),
      ),
      backgroundColor: AppColors.white,
      hasBackButton: true,
      onBackButtonPressed: () {
        _controller.loadRequest(Uri.parse('about:blank'));
        Get.back();
      },
      actions: [
        Obx(
          () => _isLoading.value
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: CustomAppLoader(size: 20.r, strokeWidth: 1.5.w),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
  // endregion

  // region Section Builders
  Widget _buildBody() {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        Obx(() {
          if (_isLoading.value && _progress.value < 1.0) {
            return Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _progress.value,
                backgroundColor: AppColors.transparent,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 2.5.h,
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
  // endregion
}
