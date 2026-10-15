// region Imports
import 'dart:convert';

import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:dev/routes/dev_routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/data/services/tracking_service.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:pinput/pinput.dart';
import 'package:services/services.dart';
// endregion

// region LoginController
class LoginController extends GetxController {
  // region Dependencies & Repositories
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final StorageService _storageService = Get.find<StorageService>();
  // endregion

  // region Form Keys, Text Controllers & Focus Nodes
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();
  final mobileFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  // endregion

  // region Observables & State Variables
  final rememberMe = false.obs;
  final obscurePassword = true.obs;
  final isLoading = false.obs;
  final isOtpLogin = false.obs;
  int _logoTapCount = 0;
  DateTime? _lastTapTime;
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    _loadSavedCredentials();
  }
  // endregion

  // region Validation Helpers
  /// Validates standard 10-digit Indian mobile number format.
  String? validateMobileNumber(String? value) {
    final clean = (value ?? '').trim();
    if (clean.isEmpty) {
      return 'Mobile number is required';
    }
    if (clean.length != 10) {
      return 'Mobile number must be 10 digits';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(clean)) {
      return 'Please enter a valid 10-digit mobile number';
    }
    return null;
  }

  /// Validates password field requirement.
  String? validatePassword(String? value) {
    final clean = (value ?? '').trim();
    if (clean.isEmpty) {
      return 'Password is required';
    }
    return null;
  }
  // endregion

  // region Credential Management
  void _loadSavedCredentials() {
    final isRemembered = _storageService.getRememberMe();
    if (isRemembered) {
      rememberMe.value = true;
      final credentials = _storageService.getCredentials();
      if (credentials != null && (credentials['mobile']?.isNotEmpty ?? false)) {
        usernameController.text = credentials['mobile'] ?? '';
        passwordController.text = credentials['password'] ?? '';
        return;
      }
    }

    if (kDebugMode) {
      ///   [Prod Credential]
      usernameController.text = '7873168884';
      passwordController.text = 'Zero@7873';

      ///  [Test Credential]
      // usernameController.text = '9776888070';
      // passwordController.text = '123456789';
      rememberMe.value = true;
      return;
    }

    rememberMe.value = isRemembered;
  }
  // endregion

  // region UI Event Handlers
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
  // endregion

  // region Authentication Actions
  Future<void> handleLoginAction() async {
    // 1. Mobile number validation check
    final mobileError = validateMobileNumber(usernameController.text);
    if (mobileError != null) {
      AppCommonToastMessage.show(
        message: mobileError,
        type: ToastType.warning,
      );
      mobileFocusNode.requestFocus();
      return;
    }

    if (isOtpLogin.value) {
      isLoading.value = true;
      try {
        final success = await _authRepository.sendOtp(
          mobile: usernameController.text.trim(),
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
      await login();
    }
  }

  Future<void> login() async {
    // 1. Mobile number validation check
    final mobileError = validateMobileNumber(usernameController.text);
    if (mobileError != null) {
      AppCommonToastMessage.show(
        message: mobileError,
        type: ToastType.warning,
      );
      mobileFocusNode.requestFocus();
      return;
    }

    // 2. Password validation check
    if (passwordController.text.trim().isEmpty) {
      AppCommonToastMessage.show(
        message: 'Please enter password',
        type: ToastType.warning,
      );
      passwordFocusNode.requestFocus();
      return;
    }

    isLoading.value = true;
    try {
      final user = await _authRepository.login(
        mobile: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (user != null) {
        // Handle Remember Me
        await _storageService.saveRememberMe(rememberMe.value);
        if (rememberMe.value) {
          await _storageService.saveCredentials(
            mobile: usernameController.text.trim(),
            password: passwordController.text.trim(),
          );
        } else {
          await _storageService.clearCredentials();
        }

        Get.find<TrackingService>().startAutoTracking();
        final updatedUser = await _authRepository.fetchProfile() ?? user;
        final roleId = updatedUser.role;
        if (roleId == '1' || roleId == 1) {
          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.offAllNamed(AppRoutes.dailyTasks);
        }
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
  // endregion

  // region OTP Verification
  void showOtpBottomSheet() {
    otpController.clear();
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          top: 24.h,
          bottom: 24.h + Get.mediaQuery.viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter OTP',
                style: AppTextStyle.style_20_600(color: AppColors.black),
              ),
              SizedBox(height: 8.h),
              Text(
                'Please enter the 6-digit OTP sent to your mobile number.',
                style: AppTextStyle.style_14_400(color: AppColors.grey500),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              Obx(
                () => Pinput(
                  length: 6,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  controller: otpController,
                  readOnly: isLoading.value,
                  keyboardType: TextInputType.number,
                  defaultPinTheme: PinTheme(
                    width: 48.w,
                    height: 48.h,
                    textStyle: AppTextStyle.style_20_600(
                      color: AppColors.black,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.blue500.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.grey200),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 48.w,
                    height: 48.h,
                    textStyle: AppTextStyle.style_20_600(
                      color: AppColors.black,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                  ),
                  onCompleted: (pin) {
                    if (!isLoading.value) verifyOtp(pin);
                  },
                ),
              ),
              SizedBox(height: 32.h),
              Obx(
                () => AppCommonButton(
                  width: double.infinity,
                  height: 38.h,
                  textSize: 13.sp,
                  borderRadius: 8.r,
                  useGradient: false,
                  buttonColor: AppColors.primary,
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
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
    );
  }

  Future<void> verifyOtp(String otp) async {
    isLoading.value = true;
    try {
      final user = await _authRepository.verifyOtp(
        mobile: usernameController.text.trim(),
        otp: otp.trim(),
      );

      if (user != null) {
        Get.back(); // close bottom sheet

        await _storageService.saveRememberMe(rememberMe.value);
        if (rememberMe.value) {
          await _storageService.saveCredentials(
            mobile: usernameController.text.trim(),
            password: '',
          );
        } else {
          await _storageService.clearCredentials();
        }

        Get.find<TrackingService>().startAutoTracking();
        final updatedUser = await _authRepository.fetchProfile() ?? user;
        final roleId = updatedUser.role;
        if (roleId == '1' || roleId == 1) {
          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.offAllNamed(AppRoutes.dailyTasks);
        }
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
  // endregion
}
// endregion
