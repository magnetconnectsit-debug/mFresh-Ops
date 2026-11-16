// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/core/config/app_config.dart';
import 'package:services/connectivity_service.dart';
// endregion

// region GlobalConnectivityBanner
class GlobalConnectivityBanner extends StatefulWidget {
  const GlobalConnectivityBanner({super.key});

  @override
  State<GlobalConnectivityBanner> createState() =>
      _GlobalConnectivityBannerState();
}

class _GlobalConnectivityBannerState extends State<GlobalConnectivityBanner> {
  // region Observables & State
  bool _wasOffline = false;
  bool _showRestoredBanner = false;
  Worker? _worker;
  // endregion

  // region Lifecycle Methods
  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<ConnectivityService>()) {
      final connService = Get.find<ConnectivityService>();
      _worker = ever(connService.isConnected, (bool isOnline) {
        if (!isOnline) {
          _wasOffline = true;
          if (_showRestoredBanner) {
            setState(() {
              _showRestoredBanner = false;
            });
          }
        } else if (_wasOffline) {
          // Device just transitioned back online from offline
          _wasOffline = false;
          setState(() {
            _showRestoredBanner = true;
          });
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _showRestoredBanner = false;
              });
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _worker?.dispose();
    super.dispose();
  }
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ConnectivityService>()) {
      return const SizedBox.shrink();
    }

    final connService = Get.find<ConnectivityService>();

    return Obx(() {
      final isOffline =
          !connService.isConnected.value || AppConfig.simulateNoInternet;
      final showBanner = isOffline || _showRestoredBanner;

      if (!showBanner) {
        return const SizedBox.shrink();
      }

      final double bannerHeight = 32.h;

      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Material(
          type: MaterialType.transparency,
          child: SafeArea(
            top: false,
            child: Container(
              height: bannerHeight,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: isOffline ? AppColors.red : AppColors.primaryGreen,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOffline
                        ? Icons.wifi_off_rounded
                        : Icons.wifi_rounded,
                    size: 15.sp,
                    color: AppColors.white,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    isOffline
                        ? 'No Internet Connection'
                        : 'Internet Connection Restored',
                    style: AppTextStyle.style_12_500(color: AppColors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
  // endregion
}
// endregion
