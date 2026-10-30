// region Imports
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:services/services.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:core/core.dart';
// endregion

// region LocationPermissionController Class
class LocationPermissionController extends GetxController with WidgetsBindingObserver {
  // region Dependencies & Repositories
  final StorageService _storageService = Get.find<StorageService>();
  // endregion

  // region Observables & State Variables
  final isChecking = false.obs;
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    checkPermissionStatus();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkPermissionStatus();
    }
  }
  // endregion

  // region Business Logic & Helpers
  Future<void> checkPermissionStatus() async {
    isChecking.value = true;
    try {
      final fgStatus = await Permission.location.status;
      final bgStatus = await Permission.locationAlways.status;

      if (fgStatus.isGranted && bgStatus.isGranted) {
        _navigateToNext();
      }
    } catch (e) {
      debugPrint("Error checking location permissions: $e");
    } finally {
      isChecking.value = false;
    }
  }

  Future<void> requestPermissions() async {
    isChecking.value = true;
    try {
      // 1. Request Foreground Location first
      var fgStatus = await Permission.location.status;
      if (!fgStatus.isGranted) {
        fgStatus = await Permission.location.request();
      }

      if (fgStatus.isGranted) {
        // 2. Request Background Location
        var bgStatus = await Permission.locationAlways.status;
        if (!bgStatus.isGranted) {
          bgStatus = await Permission.locationAlways.request();
        }

        if (bgStatus.isGranted) {
          _navigateToNext();
          return;
        }
      }

      // If either is not granted, we show a toast. We only open settings if permanently denied.
      final currentFg = await Permission.location.status;
      final currentBg = await Permission.locationAlways.status;
      if (!currentFg.isGranted || !currentBg.isGranted) {
        AppCommonToastMessage.show(
          message: 'Please select ${Platform.isIOS ? '"Always"' : '"Allow all the time"'} in location permissions to use this app.',
          type: ToastType.error,
        );
        
        final shouldShowSettings = currentFg.isPermanentlyDenied ||
            currentBg.isPermanentlyDenied ||
            (Platform.isIOS && (currentFg.isDenied || currentBg.isDenied));
        
        if (shouldShowSettings) {
          final ctx = Get.context;
          if (ctx != null && ctx.mounted) {
            final confirmed = await AppCommonDialogBox.showConfirm(
              ctx,
              title: 'Permission Required',
              message: 'Location permissions are required. Please enable them in app settings to continue.',
              confirmText: 'Open Settings',
              cancelText: 'Cancel',
              confirmButtonColor: AppColors.primary,
            );
            if (confirmed) {
              await openAppSettings();
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error requesting location permissions: $e");
    } finally {
      isChecking.value = false;
    }
  }

  void _navigateToNext() {
    final token = _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      final loginMode = _storageService.getLoginMode();
      if (loginMode == 'booking') {
        Get.offAllNamed(AppRoutes.bookingUnitSelection);
        return;
      }

      final user = _storageService.getUser();
      final roleId = user?.role;
      if (roleId == '1' || roleId == 1) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.dailyTasks);
      }
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
  // endregion
}
// endregion
