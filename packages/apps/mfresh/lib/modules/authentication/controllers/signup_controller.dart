import 'package:core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
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
    isLoading.value = true;
    // Simulate signup
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
    Get.offAllNamed(AppRoutes.home);
  }
}
