import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:services/services.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/data/services/tracking_service.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:geolocator/geolocator.dart';
class SplashController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final AppUpdateService _updateService = Get.find<AppUpdateService>();
  final TrackingService _trackingService = Get.find<TrackingService>();

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
    bool isLocationValid = false;
    try {
      final fgGranted = await Permission.location.isGranted;
      final bgGranted = await Permission.locationAlways.isGranted;

      if (fgGranted && bgGranted) {
        isLocationValid = true;
      }
    } catch (e) {
      debugPrint("Splash Location Check Error: $e");
    }

    if (!isLocationValid) {
      Get.offAllNamed(AppRoutes.locationPermission);
      return;
    }

    final token = _storageService.getToken();

    if (token != null && token.isNotEmpty) {
      _trackingService.startAutoTracking();
      // Proactively fetch latest profile and permissions on startup
      await Get.find<AuthRepository>().fetchProfile();
      Get.offAllNamed(AppRoutes.home);
      
      // Trigger the global GPS & permission check on cold start
      Future.delayed(const Duration(milliseconds: 500), () {
        _trackingService.didChangeAppLifecycleState(AppLifecycleState.resumed);
      });
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
