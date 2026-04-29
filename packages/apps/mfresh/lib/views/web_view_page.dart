import 'package:core/constants/app_colors.dart';
import 'package:services/connectivity_service.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh/widgets/no_internet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class WebViewPage extends StatelessWidget {
  final String url;
  final String title;

  WebViewPage({
    super.key,
    required this.url,
    required this.title,
  }) {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            _progress.value = progress / 100;
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    // Handle permissions for video/audio on Android if needed
    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController androidController =
          _controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
    }
  }

  late final WebViewController _controller;
  final RxDouble _progress = 0.0.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppCommonAppBar(
        title: Text(title),
        backgroundColor: AppColors.white,
        elevation: 0.5,
        hasBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.black),
            onPressed: () => _controller.reload(),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Obx(() {
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













