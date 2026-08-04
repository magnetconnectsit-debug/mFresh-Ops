import 'dart:convert';

import 'package:core/utils/app_common_toast_message.dart';
import 'package:dev/routes/dev_routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/data/services/tracking_service.dart';
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

  @override
  void onReady() {
    super.onReady();
    if (kDebugMode &&
        usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      debugPrint("🚀 [DEBUG AUTO-LOGIN] Attempting auto-login with mobile: ${usernameController.text}");
      handleLoginAction();
    }
  }

  void _loadSavedCredentials() {
    if (kDebugMode) {
      usernameController.text = '7873168884';
      passwordController.text = 'nayak@1234';
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

  Future<void> handleLoginAction() async {
    if (isOtpLogin.value) {
      if (usernameController.text.isEmpty) {
        AppCommonToastMessage.show(
          message: 'Please enter your mobile number first',
          type: ToastType.error,
        );
        return;
      }

      isLoading.value = true;
      try {
        final success = await _authRepository.sendOtp(
          mobile: usernameController.text,
        );
        if (success) {
          AppCommonToastMessage.show(
            message: 'OTP Sent Successfully',
            type: ToastType.success,
          );
          showOtpBottomSheet();
        } else {
          AppCommonToastMessage.show(
            message: 'Failed to send OTP',
            type: ToastType.error,
          );
        }
      } catch (e) {
        String errorMessage = 'Failed to send OTP';
        if (e is DioException) {
          errorMessage = e.response?.data?['message'] ?? errorMessage;
        } else {
          errorMessage = e.toString().replaceFirst('Exception: ', '');
        }
        AppCommonToastMessage.show(
          message: errorMessage,
          type: ToastType.error,
        );
      } finally {
        isLoading.value = false;
      }
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
              Obx(
                () => Pinput(
                  length: 6,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  controller: otpController,
                  readOnly: isLoading.value,
                  keyboardType: TextInputType.number,
                  defaultPinTheme: PinTheme(
                    width: 48,
                    height: 48,
                    textStyle: AppTextStyle.style_20_600(
                      color: AppColors.black,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.blue500.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grey200),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 48,
                    height: 48,
                    textStyle: AppTextStyle.style_20_600(
                      color: AppColors.black,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.blue500, width: 2),
                    ),
                  ),
                  onCompleted: (pin) {
                    if (!isLoading.value) verifyOtp(pin);
                  },
                ),
              ),
              const SizedBox(height: 32),
              Obx(
                () => AppCommonButton(
                  text: 'Verify OTP',
                  isLoading: isLoading.value,
                  onPressed: () {
                    if (isLoading.value) return;
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

  Future<void> verifyOtp(String otp) async {
    isLoading.value = true;
    try {
      final user = await _authRepository.verifyOtp(
        mobile: usernameController.text,
        otp: otp,
      );

      if (user != null) {
        Get.back(); // close bottom sheet

        await _storageService.saveRememberMe(rememberMe.value);
        if (rememberMe.value) {
          await _storageService.saveCredentials(
            mobile: usernameController.text,
            password: '',
          );
        } else {
          await _storageService.clearCredentials();
        }

        Get.find<TrackingService>().startAutoTracking();
        Get.offAllNamed(AppRoutes.home);
      } else {
        AppCommonToastMessage.show(
          message: 'OTP Verification failed.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      String errorMessage = 'Verification failed';
      if (e is DioException) {
        errorMessage = e.response?.data?['message'] ?? errorMessage;
      } else {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
      AppCommonToastMessage.show(message: errorMessage, type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }
}
