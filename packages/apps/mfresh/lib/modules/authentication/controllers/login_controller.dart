import 'package:core/routes/app_routes.dart';
import 'package:services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  final rememberMe = false.obs;
  final obscurePassword = true.obs;
  final isLoading = false.obs;
  final isOtpLogin = false.obs;
  final isEmailLogin = false.obs;

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
      isEmailLogin.value = false; // Reset email login if switching to OTP
    }
  }

  void toggleEmailLogin() {
    isEmailLogin.value = !isEmailLogin.value;
    if (isEmailLogin.value) {
      isOtpLogin.value = false; // Reset OTP login if switching to Email
    }
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    isLoading.value = true;
    
    // Handle Remember Me saving
    if (rememberMe.value && !isOtpLogin.value) {
      _storage.saveCredentials(
        mobile: isEmailLogin.value ? null : mobileController.text,
        email: isEmailLogin.value ? emailController.text : null,
        password: passwordController.text,
      );
    } else if (!rememberMe.value) {
      _storage.clearCredentials();
    }

    // Simulate login
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
    Get.offAllNamed(AppRoutes.dashboard);
  }
}









