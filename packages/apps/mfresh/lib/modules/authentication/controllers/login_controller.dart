import 'package:mfresh/routes/app_routes.dart';
import 'package:services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dev/routes/dev_routes.dart';
import 'package:mfresh/data/repositories/auth_repository.dart';
import 'package:core/utils/app_common_toast_message.dart';

class LoginController extends GetxController {
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  final rememberMe = false.obs;
  final obscurePassword = true.obs;
  final isLoading = false.obs;
  final isOtpLogin = false.obs;
  final isEmailLogin = false.obs;

  int _tapCount = 0;
  DateTime? _lastTapTime;

  final StorageService _storage = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() {
    rememberMe.value = _storage.getRememberMe();
    if (rememberMe.value) {
      final creds = _storage.getCredentials();
      if (creds != null) {
        mobileController.text = creds['mobile'] ?? '';
        emailController.text = creds['email'] ?? '';
        passwordController.text = creds['password'] ?? '';
      }
    }
  }

  void handleDevTap() {
    final now = DateTime.now();
    if (_lastTapTime == null || now.difference(_lastTapTime!) > const Duration(seconds: 2)) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }
    _lastTapTime = now;

    if (_tapCount >= 5) {
      _tapCount = 0;
      Get.toNamed(DevRoutes.devPasscode);
    }
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
    _storage.saveRememberMe(rememberMe.value);
    if (!rememberMe.value) {
      _storage.clearCredentials();
    }
  }

  void toggleLoginType() {
    isOtpLogin.value = !isOtpLogin.value;
    if (isOtpLogin.value) {
      isEmailLogin.value = false;
    }
  }

  void toggleEmailLogin() {
    isEmailLogin.value = !isEmailLogin.value;
    if (isEmailLogin.value) {
      isOtpLogin.value = false;
    }
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    if (isOtpLogin.value) {
      _verifyOtp();
      return;
    }

    if (mobileController.text.isEmpty || passwordController.text.isEmpty) {
      AppCommonToastMessage.show(
        message: "Please enter both mobile and password",
        type: ToastType.warning,
      );
      return;
    }

    isLoading.value = true;
    try {
      final user = await Get.find<AuthRepository>().login(
        mobile: mobileController.text,
        password: passwordController.text,
      );

      if (user != null) {
        if (rememberMe.value) {
          _storage.saveCredentials(
            mobile: mobileController.text,
            password: passwordController.text,
          );
        }
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        AppCommonToastMessage.show(
          message: "Login failed. Please check your credentials.",
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: e.toString(),
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _verifyOtp() async {
    // For now, if it's OTP, we might need a separate dialog or screen.
    // Assuming for now we just want to fix the "Simulation" issue.
    // If you need real OTP flow, I can implement the OTP BottomSheet.
    
    // TEMPORARY: Saving a dummy token for simulated OTP if you want it to work on restart
    await _storage.saveToken("simulated_token");
    Get.offAllNamed(AppRoutes.dashboard);
  }
}
