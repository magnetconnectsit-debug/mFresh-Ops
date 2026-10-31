import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh/routes/app_routes.dart';
import 'package:services/storage_service.dart';
import 'package:services/app_update_service.dart';

class SplashController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final AppUpdateService _updateService = Get.find<AppUpdateService>();

  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // 1. Check for updates first
    try {
      final isUpdating = await _updateService.checkForUpdate();
      if (isUpdating) {
        return;
      }
    } catch (e) {
      debugPrint("Splash Update Check Error: $e");
    }

    // 2. Wait for a few seconds for the splash animation
    await Future.delayed(const Duration(seconds: 2));

    if (_storage.getToken() != null) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
