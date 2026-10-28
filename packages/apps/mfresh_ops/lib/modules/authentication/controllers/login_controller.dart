// region Imports
import 'dart:convert';

import 'package:core/core.dart';
import 'package:dev/routes/dev_routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/authentication/views/widgets/guest_flow_bottom_sheet.dart';
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

  // region Observables & State Variables
  final rememberMe = false.obs;
  final obscurePassword = true.obs;
  final isLoading = false.obs;
  final isOtpLogin = true.obs;
  final selectedTab = 1.obs; // 0 for Booking, 1 for Operation
  int _logoTapCount = 0;
  DateTime? _lastTapTime;

  String get loginMode => selectedTab.value == 0 ? 'booking' : 'operation';
  // endregion

  // region Text Controllers & Focus Nodes
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();
  final mobileFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final otpFocusNode = FocusNode();
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    _loadSavedCredentials();
  }

  @override
  void onClose() {
    FocusManager.instance.primaryFocus?.unfocus();
    super.onClose();
  }
  // endregion

  // region API & Network Operations
  Future<void> handleLoginAction() async {
    // 1. Username / Mobile validation check
    final loginId = usernameController.text.trim();
    if (loginId.isEmpty) {
      AppCommonToastMessage.show(
        message: selectedTab.value == 0
            ? 'Please enter Mobile Number, Email or User ID'
            : 'Please enter mobile number',
        type: ToastType.warning,
      );
      mobileFocusNode.requestFocus();
      return;
    }

    // In OTP mode, mobile must be 10 digits
    if (isOtpLogin.value) {
      final mobileError = validateMobileNumber(loginId);
      if (mobileError != null) {
        AppCommonToastMessage.show(
          message: mobileError,
          type: ToastType.warning,
        );
        mobileFocusNode.requestFocus();
        return;
      }

      isLoading.value = true;
      try {
        if (selectedTab.value == 0) {
          // Employee Booking Send OTP
          final res = await _authRepository.employeeBookingSendOtp(mobile: loginId);
          if (res['status'] == true || res['otp_sent'] == true) {
            AppCommonToastMessage.show(
              message: res['message']?.toString() ?? 'Booking OTP sent successfully',
              type: ToastType.success,
            );
            showOtpBottomSheet();
          } else {
            AppCommonToastMessage.show(
              message: res['message']?.toString() ?? 'Failed to send OTP',
              type: ToastType.error,
            );
          }
        } else {
          // Operation Send OTP
          final success = await _authRepository.sendOtp(mobile: loginId);
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
    final loginId = usernameController.text.trim();
    if (loginId.isEmpty) {
      AppCommonToastMessage.show(
        message: 'Please enter User ID, Mobile or Email',
        type: ToastType.warning,
      );
      mobileFocusNode.requestFocus();
      return;
    }

    // Password validation check
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
      if (selectedTab.value == 0) {
        // ── Booking Mode Login (Employee or Guest Parent) ──
        final result = await _authRepository.bookingPasswordLogin(
          loginId: loginId,
          password: passwordController.text.trim(),
        );

        if (result['status'] == true) {
          final userType = (result['user_type'] ?? '').toString();

          // Case 1: Guest Parent login detected -> Open Guest Cashier bottom sheet
          if (userType == 'GUEST_LOGIN') {
            final guestFlowToken = result['guest_flow_token']?.toString();
            if (guestFlowToken != null && guestFlowToken.isNotEmpty) {
              FocusManager.instance.primaryFocus?.unfocus();
              AppCommonToastMessage.show(
                message: result['message']?.toString() ?? 'Parent login successful. Enter Cashier mobile.',
                type: ToastType.info,
              );
              final ctx = Get.context;
              if (ctx != null) {
                await GuestFlowBottomSheet.show(ctx, guestFlowToken: guestFlowToken);
              }
            } else {
              AppCommonToastMessage.show(
                message: 'Guest flow token missing from server response',
                type: ToastType.error,
              );
            }
            return;
          }

          // Case 2: Employee Booking login detected -> Direct JWT login
          if (result['token'] != null) {
            await _handleSuccessfulLoginState(loginId, passwordController.text.trim());
            FocusManager.instance.primaryFocus?.unfocus();
            Get.offAllNamed(AppRoutes.bookingUnitSelection);
            return;
          }
        }

        AppCommonToastMessage.show(
          message: result['message']?.toString() ?? 'Login failed. Please check your credentials.',
          type: ToastType.error,
        );
      } else {
        // ── Operation Mode Login ──
        final user = await _authRepository.login(
          mobile: loginId,
          password: passwordController.text.trim(),
          loginMode: 'operation',
        );

        if (user != null) {
          await _handleSuccessfulLoginState(loginId, passwordController.text.trim());
          FocusManager.instance.primaryFocus?.unfocus();
          final updatedUser = await _authRepository.fetchProfile() ?? user;
          final roleId = updatedUser.role;
          if (roleId?.toString() == '1') {
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

  Future<void> verifyOtp(String otp) async {
    isLoading.value = true;
    try {
      final mob = usernameController.text.trim();

      if (selectedTab.value == 0) {
        // ── Booking OTP Verification ──
        final res = await _authRepository.employeeBookingVerifyOtp(
          mobile: mob,
          otp: otp.trim(),
        );

        if (res['status'] == true && res['token'] != null) {
          FocusManager.instance.primaryFocus?.unfocus();
          Get.back(); // close bottom sheet

          await _handleSuccessfulLoginState(mob, '');
          Get.offAllNamed(AppRoutes.bookingUnitSelection);
        } else {
          AppCommonToastMessage.show(
            message: res['message']?.toString() ?? 'OTP Verification failed.',
            type: ToastType.error,
          );
        }
      } else {
        // ── Operation OTP Verification ──
        final user = await _authRepository.verifyOtp(
          mobile: mob,
          otp: otp.trim(),
          loginMode: 'operation',
        );

        if (user != null) {
          FocusManager.instance.primaryFocus?.unfocus();
          Get.back(); // close bottom sheet

          await _handleSuccessfulLoginState(mob, '');

          final updatedUser = await _authRepository.fetchProfile() ?? user;
          final roleId = updatedUser.role;
          if (roleId?.toString() == '1') {
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

  Future<void> _handleSuccessfulLoginState(String mobile, String password) async {
    await _storageService.saveRememberMe(rememberMe.value);
    if (rememberMe.value) {
      await _storageService.saveCredentials(
        mobile: mobile,
        password: password,
      );
    } else {
      await _storageService.clearCredentials();
    }
  }
  // endregion

  // region Dialogs & Bottom Sheets
  Future<void> showOtpBottomSheet([BuildContext? context]) async {
    final ctx = context ?? Get.context;
    if (ctx == null) return;

    // Unfocus any active input field before opening bottom sheet to prevent focus desynchronization
    FocusManager.instance.primaryFocus?.unfocus();
    otpController.clear();

    await AppCommonBottomSheet.showModal(
      ctx,
      title: 'Enter OTP',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Please enter the 6-digit OTP sent to your mobile number.',
            style: AppTextStyle.style_14_400(color: AppColors.grey500),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          Obx(
            () => Pinput(
              key: const ValueKey('otp_pinput_field'),
              focusNode: otpFocusNode,
              length: 6,
              autofocus: true,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          SizedBox(height: 28.h),
          Obx(
            () => AppCommonButton(
              width: double.infinity,
              height: 36.h,
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
          SizedBox(height: 12.h),
        ],
      ),
    );

    // Clean up focus after modal closes
    FocusManager.instance.primaryFocus?.unfocus();
  }
  // endregion

  // region Business Logic & Helpers
  void selectTab(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    selectedTab.value = index;
  }

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

  String? validatePassword(String? value) {
    final clean = (value ?? '').trim();
    if (clean.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

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
    FocusManager.instance.primaryFocus?.unfocus();
    isOtpLogin.value = !isOtpLogin.value;
  }
  // endregion
}
// endregion
