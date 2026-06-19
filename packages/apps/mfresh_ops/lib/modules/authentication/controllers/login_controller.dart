import 'dart:convert';

import 'package:core/utils/app_common_toast_message.dart';
import 'package:dev/routes/dev_routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/data/services/tracking/tracking_service.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:services/services.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:pinput/pinput.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final rememberMe = false.obs;
  final obscurePassword = true.obs;
  final isLoading = false.obs;
  final isOtpLogin = false.obs;
  final otpController = TextEditingController();
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
      usernameController.text = '6370658717';
      passwordController.text = 'itadmin@1234';
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

  void toggleLoginMode() {
    isOtpLogin.value = !isOtpLogin.value;
  }

  void handleLoginAction() {
    if (isOtpLogin.value) {
      if (usernameController.text.isEmpty) {
        AppCommonToastMessage.show(
          message: 'Please enter your mobile number first',
          type: ToastType.error,
        );
        return;
      }
      showOtpBottomSheet();
    } else {
      login();
    }
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

        Get.find<TrackingService>().startAutoTracking();
        Get.offAllNamed(AppRoutes.home);
      } else {
        AppCommonToastMessage.show(
          message: 'Login failed. Please check your credentials.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      String errorMessage = 'An error occurred. Please try again.';
      if (e is DioException) {
        final data = e.response?.data;
        Map? errorMap;
        if (data is Map) {
          errorMap = data;
        } else if (data is String) {
          try {
            errorMap = jsonDecode(data);
          } catch (_) {}
        }

        if (errorMap != null) {
          if (errorMap.containsKey('error')) {
            errorMessage = errorMap['error'].toString();
          } else if (errorMap.containsKey('message')) {
            errorMessage = errorMap['message'].toString();
          }
        } else {
          errorMessage = e.message ?? errorMessage;
        }
      } else {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }

      AppCommonToastMessage.show(message: errorMessage, type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  void showOtpBottomSheet() {
    otpController.clear();
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: 24 + Get.mediaQuery.viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter OTP',
                style: AppTextStyle.style_20_600(color: AppColors.black),
              ),
              const SizedBox(height: 8),
              Text(
                'Please enter the 6-digit OTP sent to your mobile number.',
                style: AppTextStyle.style_14_400(color: AppColors.grey500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Pinput(
                length: 6,
                controller: otpController,
                keyboardType: TextInputType.number,
                defaultPinTheme: PinTheme(
                  width: 48,
                  height: 48,
                  textStyle: AppTextStyle.style_20_600(color: AppColors.black),
                  decoration: BoxDecoration(
                    color: AppColors.blue500.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey200),
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: 48,
                  height: 48,
                  textStyle: AppTextStyle.style_20_600(color: AppColors.black),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.blue500, width: 2),
                  ),
                ),
                onCompleted: (pin) {
                  verifyOtp(pin);
                },
              ),
              const SizedBox(height: 32),
              AppCommonButton(
                text: 'Verify OTP',
                onPressed: () {
                  if (otpController.text.length == 6) {
                    verifyOtp(otpController.text);
                  } else {
                    AppCommonToastMessage.show(
                      message: 'Please enter a valid 6-digit OTP',
                      type: ToastType.warning,
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void verifyOtp(String otp) {
    // Add real verification logic here later
    Get.back(); // close bottom sheet
    AppCommonToastMessage.show(
      message: 'OTP verified (Placeholder logic)',
      type: ToastType.success,
    );
  }
}
