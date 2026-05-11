import 'package:core/utils/app_common_toast_message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:dev/routes/dev_routes.dart';
import 'package:services/services.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';

import 'package:flutter/foundation.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final rememberMe = false.obs;
  final obscurePassword = true.obs;
  final isLoading = false.obs;
  int _logoTapCount = 0;
  DateTime? _lastTapTime;

  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() {
    if (kDebugMode) {
      usernameController.text = '9337881379';
      passwordController.text = '123456';
      rememberMe.value = true;
      return;
    }

    final isRemembered = _storageService.getRememberMe();
    rememberMe.value = isRemembered;

    if (isRemembered) {
      final credentials = _storageService.getCredentials();
      if (credentials != null) {
        usernameController.text = credentials['mobile'] ?? '';
        passwordController.text = credentials['password'] ?? '';
      }
    }
  }

  void handleLogoTap() {
    final now = DateTime.now();
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > const Duration(seconds: 2)) {
      _logoTapCount = 1;
    } else {
      _logoTapCount++;
    }
    _lastTapTime = now;

    if (_logoTapCount >= 5) {
      _logoTapCount = 0; // Reset
      Get.toNamed(DevRoutes.devPasscode);
    }
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      AppCommonToastMessage.show(
        message: 'Please enter mobile and password',
        type: ToastType.error,
      );
      return;
    }

    isLoading.value = true;
    try {
      final user = await _authRepository.login(
        mobile: usernameController.text,
        password: passwordController.text,
      );

      if (user != null) {
        // Handle Remember Me
        await _storageService.saveRememberMe(rememberMe.value);
        if (rememberMe.value) {
          await _storageService.saveCredentials(
            mobile: usernameController.text,
            password: passwordController.text,
          );
        } else {
          await _storageService.clearCredentials();
        }

        Get.offAllNamed(AppRoutes.home);
      } else {
        AppCommonToastMessage.show(
          message: 'Login failed. Please check your credentials.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'An error occurred: $e',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
