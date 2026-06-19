import 'package:core/widgets/app_common_button.dart';
import 'package:mfresh/routes/app_routes.dart';
import 'package:services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:dev/routes/dev_routes.dart';
import 'package:mfresh/data/repositories/auth_repository.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:pinput/pinput.dart';

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
    
    // Set default credentials in debug mode for easier testing
    if (kDebugMode && mobileController.text.isEmpty && passwordController.text.isEmpty) {
      mobileController.text = "6370658717";
      passwordController.text = "12345";
    }
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
      sendOtp();
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

  Future<void> sendOtp() async {
    if (mobileController.text.length != 10) {
      AppCommonToastMessage.show(
        message: "Please enter a valid 10-digit mobile number",
        type: ToastType.warning,
      );
      return;
    }

    isLoading.value = true;
    try {
      final success = await Get.find<AuthRepository>().sendOtp(mobile: mobileController.text);
      if (success) {
        AppCommonToastMessage.show(message: "OTP sent successfully", type: ToastType.success);
        _showOtpBottomSheet();
      } else {
        AppCommonToastMessage.show(message: "Failed to send OTP", type: ToastType.error);
      }
    } catch (e) {
      AppCommonToastMessage.show(message: e.toString(), type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  void _showOtpBottomSheet() {
    final otpController = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              "Verify OTP",
              style: AppTextStyle.style_20_700(color: AppColors.black),
            ),
            const SizedBox(height: 8),
            Text(
              "Enter the 6-digit code sent to ${mobileController.text}",
              textAlign: TextAlign.center,
              style: AppTextStyle.style_14_400(color: AppColors.grey400),
            ),
            const SizedBox(height: 32),
            Obx(() => Pinput(
              length: 6,
              autofillHints: const [AutofillHints.oneTimeCode],
              controller: otpController,
              readOnly: isLoading.value,
              onCompleted: (pin) {
                if (!isLoading.value) verifyOtp(pin);
              },
              defaultPinTheme: PinTheme(
                width: 45,
                height: 50,
                textStyle: AppTextStyle.style_20_700(color: AppColors.black),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              focusedPinTheme: PinTheme(
                width: 45,
                height: 50,
                textStyle: AppTextStyle.style_20_700(color: AppColors.black),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )),
            const SizedBox(height: 32),
            Obx(() => AppCommonButton(
              text: "VERIFY & LOGIN",
              isLoading: isLoading.value,
              onPressed: () {
                if (!isLoading.value) verifyOtp(otpController.text);
              },
            )),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code? ",
                  style: AppTextStyle.style_12_400(color: AppColors.grey400),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                    sendOtp();
                  },
                  child: Text(
                    "Resend",
                    style: AppTextStyle.style_12_700(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> verifyOtp(String otp) async {
    if (otp.length != 6) {
      AppCommonToastMessage.show(message: "Please enter 6-digit OTP", type: ToastType.warning);
      return;
    }

    Get.back(); // Close bottomsheet
    isLoading.value = true;
    try {
      final user = await Get.find<AuthRepository>().verifyOtp(
        mobile: mobileController.text,
        otp: otp,
      );

      if (user != null) {
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        AppCommonToastMessage.show(message: "Invalid OTP", type: ToastType.error);
      }
    } catch (e) {
      AppCommonToastMessage.show(message: e.toString(), type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }
}
