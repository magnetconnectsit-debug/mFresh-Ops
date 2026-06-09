import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:services/services.dart';
import 'package:mfresh_ops/routes/app_routes.dart';

class LocationPermissionController extends GetxController with WidgetsBindingObserver {
  final StorageService _storageService = Get.find<StorageService>();
  final isChecking = false.obs;

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

      // If either was permanently denied, we prompt the user to open settings
      final currentFg = await Permission.location.status;
      final currentBg = await Permission.locationAlways.status;
      if (currentFg.isPermanentlyDenied || currentBg.isPermanentlyDenied) {
        await openAppSettings();
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
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
