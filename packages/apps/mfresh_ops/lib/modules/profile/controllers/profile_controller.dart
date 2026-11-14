// region Imports
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mfresh_ops/core/config/app_config.dart';
import 'package:mfresh_ops/data/models/user.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/data/repositories/user_repository.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:services/services.dart';
// endregion

// region ProfileController
class ProfileController extends GetxController {
  // region Dependencies & Repositories
  final UserRepository _userRepository = Get.find<UserRepository>();
  final StorageService _storageService = Get.find<StorageService>();
  final BiometricAuthService biometricService = Get.find<BiometricAuthService>();
  // endregion

  // region Text Controllers & Focus Nodes
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  // endregion

  // region Observables & State Variables
  final user = Rxn<User>();
  final isLoading = false.obs;
  final isSaving = false.obs;
  final selectedImage = Rxn<File>();
  final ImagePicker _picker = ImagePicker();
  final appVersion = '1.0.0'.obs;
  final isPasswordVisible = false.obs;
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    user.value = _storageService.getUser();
    _populateControllers();
    _loadAppVersion();
    fetchProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
  // endregion

  // region API & Network Operations
  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final fetchedUser = await _userRepository.getProfile();
      if (fetchedUser != null) {
        user.value = fetchedUser;
        _populateControllers();
      }
    } catch (e) {
      debugPrint('ProfileController: Error fetching profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveProfile() async {
    try {
      isSaving.value = true;
      final updatedUser = await _userRepository.updateProfile(
        name: nameController.text.trim(),
        image: selectedImage.value,
      );

      if (passwordController.text.isNotEmpty) {
        await _userRepository.updatePassword(passwordController.text.trim());
      }

      if (updatedUser != null) {
        user.value = updatedUser;
      }

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      AppCommonToastMessage.show(
        message: 'Profile updated successfully!',
        type: ToastType.success,
      );

      passwordController.clear();
      selectedImage.value = null;
      return true;
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      AppCommonToastMessage.show(
        message: 'Failed to update profile: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }
  // endregion

  // region Business Logic & Helpers
  void _populateControllers() {
    if (user.value != null) {
      nameController.text = user.value?.name ?? '';
      phoneController.text = user.value?.mob ?? '';
      emailController.text = user.value?.email ?? '';
    }
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion.value = '${info.version} (${info.buildNumber})';
    } catch (_) {}
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 75,
      );
      if (image != null) {
        selectedImage.value = File(image.path);
        Get.back(); // Close bottom sheet
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to pick image: $e',
        type: ToastType.error,
      );
    }
  }

  Future<void> toggleBiometricLock(bool enabled) async {
    if (!AppConfig.enableBiometricAuth) return;

    if (enabled) {
      final status = await biometricService.authenticate(
        localizedReason: 'Authenticate to enable Biometric App Lock',
      );
      if (status == BiometricAuthStatus.success) {
        await biometricService.setBiometricEnabled(true);
        AppCommonToastMessage.show(
          message: 'Biometric App Lock enabled',
          type: ToastType.success,
        );
      } else {
        AppCommonToastMessage.show(
          message: 'Authentication failed. App Lock not enabled.',
          type: ToastType.warning,
        );
      }
    } else {
      await biometricService.setBiometricEnabled(false);
      AppCommonToastMessage.show(
        message: 'Biometric App Lock disabled',
        type: ToastType.info,
      );
    }
  }

  Future<void> handleLogout(BuildContext context) async {
    final confirmed = await AppCommonDialogBox.showConfirm(
      context,
      title: 'Confirm Logout',
      message: 'Are you sure you want to log out of mFresh Ops?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
      confirmButtonColor: AppColors.error,
    );

    if (confirmed) {
      Get.dialog(
        const PopScope(
          canPop: false,
          child: Center(child: CustomAppLoader()),
        ),
        barrierDismissible: false,
      );

      try {
        await Get.find<AuthRepository>().logout();
      } catch (_) {
      } finally {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        Get.offAllNamed(AppRoutes.login);
      }
    }
  }
  // endregion
}
// endregion
