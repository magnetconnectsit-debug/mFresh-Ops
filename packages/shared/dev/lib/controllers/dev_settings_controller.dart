import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:services/dio_client.dart';
import 'package:services/storage_service.dart';
import 'package:services/settings_service.dart';
import 'package:dev/routes/dev_routes.dart';

class DevSettingsController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final DioClient _dioClient = Get.find<DioClient>();
  final SettingsService settingsService = Get.find<SettingsService>();

  late final TextEditingController baseUrlController;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    baseUrlController = TextEditingController(
      text: _storageService.getBaseUrl(),
    );
  }

  @override
  void onClose() {
    baseUrlController.dispose();
    super.onClose();
  }

  Future<void> saveSettingsAndRestart() async {
    final newUrl = baseUrlController.text.trim();

    if (newUrl.isEmpty) {
      AppCommonToastMessage.show(message: "Base URL cannot be empty", type: ToastType.error);
      return;
    }

    isLoading.value = true;
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      await _storageService.saveBaseUrl(newUrl);
      await _storageService.saveShowLogger(settingsService.showLogger.value);

      _dioClient.dio.options.baseUrl = newUrl;

      await Future.delayed(const Duration(milliseconds: 500));

      // 6. Soft Restart (Navigate to Splash)
      debugPrint("Triggering Soft Restart...");
      AppCommonToastMessage.show(
        message: "Settings saved. Please restart the app for changes to take effect fully.",
        type: ToastType.success,
      );
      
      Get.offAllNamed('/'); // Navigate to splash or initial route

    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppCommonToastMessage.show(message: "Error saving settings: $e", type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleLogger(bool value) {
    settingsService.showLogger.value = value;
  }

  void goToLogViewer() {
    Get.toNamed(DevRoutes.logViewer);
  }
}