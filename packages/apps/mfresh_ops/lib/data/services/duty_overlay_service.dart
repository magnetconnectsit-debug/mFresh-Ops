import 'dart:async';
import 'dart:io';

import 'package:core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart'
    hide NotificationVisibility;
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/services/tracking_service.dart';
import 'package:mfresh_ops/routes/app_routes.dart';

class DutyOverlayService extends GetxService with WidgetsBindingObserver {
  static DutyOverlayService get to => Get.find<DutyOverlayService>();

  final RxBool isOverlayActive = false.obs;
  StreamSubscription? _overlayListenerSubscription;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initOverlayListener();
  }

  void _initOverlayListener() {
    if (!Platform.isAndroid) return;
    try {
      _overlayListenerSubscription =
          FlutterOverlayWindow.overlayListener.listen((data) async {
        if (data == "OPEN_APP") {
          try {
            FlutterForegroundTask.launchApp(AppRoutes.home);
          } catch (_) {
            try {
              FlutterForegroundTask.launchApp('/');
            } catch (_) {}
          }
          await hideOverlay();
        }
      });
    } catch (e) {
      debugPrint('[DutyOverlayService] Error setting up listener: $e');
    }
  }

  @override
  void onClose() {
    _overlayListenerSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App is visible on screen -> Hide floating overlay to keep UI clean
      hideOverlay();
    } else if (state == AppLifecycleState.paused) {
      // App is actually minimized/home screen -> Show overlay if ON DUTY
      _checkAndShowOverlayIfDutyOn();
    }
  }

  Future<void> _checkAndShowOverlayIfDutyOn() async {
    try {
      if (Get.isRegistered<TrackingService>()) {
        final trackingService = Get.find<TrackingService>();
        if (trackingService.isTracking.value) {
          final isGranted = await checkPermission();
          if (isGranted) {
            await _launchOverlayWindow();
          }
        }
      }
    } catch (e) {
      debugPrint('[DutyOverlayService] Error checking overlay on background: $e');
    }
  }

  Future<bool> checkPermission() async {
    if (!Platform.isAndroid) return false;
    try {
      return await FlutterOverlayWindow.isPermissionGranted();
    } catch (e) {
      debugPrint('[DutyOverlayService] Error checking permission: $e');
      return false;
    }
  }

  Future<bool> requestPermissionWithRationale() async {
    if (!Platform.isAndroid) return false;

    final isGranted = await checkPermission();
    if (isGranted) return true;

    // Show Google Play policy compliant explanatory dialog
    bool userConsented = false;
    await Get.dialog(
      PopScope(
        canPop: true,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.layers_rounded,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Display Over Other Apps',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'mFresh Ops uses a floating shortcut bubble while you are ON DUTY. This keeps tracking active in the background and lets you reopen the app with a single tap.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Get.back();
                          userConsented = false;
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Not Now'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          userConsented = true;
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Allow'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (userConsented) {
      final status = await FlutterOverlayWindow.requestPermission();
      return status ?? false;
    }

    return false;
  }

  Future<void> showOverlay() async {
    if (!Platform.isAndroid) return;

    try {
      bool hasPermission = await checkPermission();
      if (!hasPermission) {
        await requestPermissionWithRationale();
        hasPermission = await checkPermission();
        if (!hasPermission) return;
      }

      await _launchOverlayWindow();
    } catch (e) {
      debugPrint('[DutyOverlayService] Error showing overlay: $e');
    }
  }

  Future<void> _launchOverlayWindow() async {
    final isActive = await FlutterOverlayWindow.isActive();
    if (!isActive) {
      await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        overlayTitle: "",
        overlayContent: "",
        flag: OverlayFlag.defaultFlag,
        alignment: OverlayAlignment.centerRight,
        visibility: NotificationVisibility.visibilitySecret,
        positionGravity: PositionGravity.right,
        height: 120,
        width: 120,
      );
      isOverlayActive.value = true;
    }
  }

  Future<void> hideOverlay() async {
    if (!Platform.isAndroid) return;

    try {
      final isActive = await FlutterOverlayWindow.isActive();
      if (isActive) {
        await FlutterOverlayWindow.closeOverlay();
      }
      isOverlayActive.value = false;
    } catch (e) {
      debugPrint('[DutyOverlayService] Error hiding overlay: $e');
    }
  }
}
