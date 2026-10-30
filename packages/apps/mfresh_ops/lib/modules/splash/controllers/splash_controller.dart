// region Imports
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/core/config/app_config.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:services/services.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/data/services/tracking_service.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
// endregion

// region SplashController Class
class SplashController extends GetxController {
  // region Dependencies & Repositories
  final StorageService _storageService = Get.find<StorageService>();
  final AppUpdateService _updateService = Get.find<AppUpdateService>();
  final TrackingService _trackingService = Get.find<TrackingService>();
  final BiometricAuthService _biometricService = Get.find<BiometricAuthService>();
  // endregion

  // region Lifecycle Methods
  @override
  void onReady() {
    super.onReady();
    _navigateToNext();
  }
  // endregion

  // region Business Logic & Helpers
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

    // 2. Check login state & mode
    final token = _storageService.getToken();

    if (token != null && token.isNotEmpty) {
      final loginMode = _storageService.getLoginMode();
      final cachedUser = _storageService.getUser();
      final bool isCashierUser =
          cachedUser?.roleName?.toString().toLowerCase().contains('cashier') == true;

      // ── Booking Mode Flow ──
      if (loginMode == 'booking' || isCashierUser) {
        if (loginMode != 'booking') {
          await _storageService.saveLoginMode('booking');
        }

        // Check if Biometric App Lock should lock on cold start
        if (AppConfig.enableBiometricAuth) {
          _biometricService.lockApp();
        }

        Get.offAllNamed(AppRoutes.bookingUnitSelection);
        return;
      }

      // ── Operation Mode Flow ──
      // Check and enforce location permissions for operations mode
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

      // Proactively fetch latest profile and permissions on startup
      final user = await Get.find<AuthRepository>().fetchProfile();
      if (user == null) {
        final bool isOnDuty = cachedUser?.isOnDuty == 1;
        await _trackingService.syncDutyStatus(isOnDuty);
      }

      // Check if Biometric App Lock should lock on cold start
      if (AppConfig.enableBiometricAuth) {
        _biometricService.lockApp();
      }

      final roleId = user?.role ?? cachedUser?.role;
      if (roleId == '1' || roleId == 1) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.dailyTasks);
      }

      // Trigger the global GPS & permission check on cold start
      Future.delayed(const Duration(milliseconds: 500), () {
        _trackingService.didChangeAppLifecycleState(AppLifecycleState.resumed);
      });
    } else {
      // 3. Unauthenticated flow: check location permissions before login
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

      Get.offAllNamed(AppRoutes.login);
    }
  }
  // endregion
}
// endregion
