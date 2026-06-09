import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:services/services.dart';
import 'package:mfresh_ops/routes/app_routes.dart';

class SplashController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final AppUpdateService _updateService = Get.find<AppUpdateService>();

  @override
  void onReady() {
    super.onReady();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // 1. Check for updates first
    try {
      final isUpdating = await _updateService.checkForUpdate();
      if (isUpdating) {
        return; // Halt navigation to let update run
      }
    } catch (e) {
      debugPrint("Splash Update Check Error: $e");
    }

    // Show splash for 2 seconds to ensure visibility
    await Future.delayed(const Duration(seconds: 2));

    // 2. Check and enforce location permissions
    try {
      final fgGranted = await Permission.location.isGranted;
      final bgGranted = await Permission.locationAlways.isGranted;

      if (!fgGranted || !bgGranted) {
        Get.offAllNamed(AppRoutes.locationPermission);
        return;
      }
    } catch (e) {
      debugPrint("Splash Location Check Error: $e");
    }

    final token = _storageService.getToken();

    if (token != null && token.isNotEmpty) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
