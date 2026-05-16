import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh/routes/app_routes.dart';
import 'package:services/storage_service.dart';
import 'package:services/app_update_service.dart';
import 'package:mfresh/views/app_update_screen.dart';

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
      final updateInfo = await _updateService.getUpdateInfo();
      if (updateInfo.isAvailable) {
        if (Platform.isAndroid) {
          // Trigger native immediate update overlay
          await _updateService.performAndroidUpdate();
          return;
        } else {
          Get.offAll(
            () => AppUpdateScreen(
              isForceUpdate: updateInfo.isForceUpdate,
              message: updateInfo.message,
              storeUrl: updateInfo.storeUrl,
              versionName: updateInfo.versionName,
            ),
          );
          return;
        }
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
