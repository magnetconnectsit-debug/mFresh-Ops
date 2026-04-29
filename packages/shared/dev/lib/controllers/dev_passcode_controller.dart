import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:dev/routes/dev_routes.dart';

class DevPasscodeController extends GetxController {
  final passcodeController = TextEditingController();
  final correctPasscode = '121212';
  final isLoading = false.obs;

  void verifyPasscode(String passcode) {
    isLoading.value = true;
    if (passcode == correctPasscode) {
      Get.offNamed(DevRoutes.devSettings);
    } else {
      AppCommonToastMessage.show(
        message: "Invalid Passcode",
        type: ToastType.error,
      );
      passcodeController.clear();
    }
    isLoading.value = false;
  }

  @override
  void onClose() {
    passcodeController.dispose();
    super.onClose();
  }
}