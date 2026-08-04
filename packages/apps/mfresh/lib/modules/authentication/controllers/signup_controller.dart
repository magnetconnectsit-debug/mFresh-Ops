import 'package:core/utils/app_common_toast_message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh/data/repositories/auth_repository.dart';
import 'package:mfresh/routes/app_routes.dart';

class SignupController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();

  final obscurePassword = true.obs;
  final isLoading = false.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> signup() async {
    final name = fullNameController.text.trim();
    final email = emailController.text.trim();
    final phone = mobileController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      AppCommonToastMessage.show(
        message: "Please fill all fields",
        type: ToastType.error,
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await _authRepository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: password,
      );

      if (response != null) {
        final successMsg =
            response['message'] ?? "Account created successfully";
        AppCommonToastMessage.show(
          message: successMsg,
          type: ToastType.success,
        );
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        AppCommonToastMessage.show(
          message: "Signup failed. Please try again.",
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Signup Error: $e",
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }// 
}
