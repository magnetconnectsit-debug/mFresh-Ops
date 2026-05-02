import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:services/services.dart';
import 'package:mfresh_ops/data/models/user.dart';
import 'package:mfresh_ops/data/repositories/user_repository.dart';

class ProfileController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final user = Rxn<User>();
  final isLoading = false.obs;
  final selectedImage = Rxn<File>();
  final ImagePicker _picker = ImagePicker();
  final currentTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Load from storage first
    user.value = _storageService.getUser();
    _populateControllers();
    
    // Then fetch from API
    fetchProfile();
  }

  void _populateControllers() {
    if (user.value != null) {
      nameController.text = user.value?.name ?? '';
      phoneController.text = user.value?.mob ?? '';
      emailController.text = user.value?.email ?? '';
    }
  }

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

  void updateTab(int index) {
    currentTab.value = index;
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (image != null) {
        selectedImage.value = File(image.path);
        Get.back(); // Close bottom sheet
        AppCommonToastMessage.show(
          message: "Profile image updated locally",
          type: ToastType.success,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Failed to pick image: $e",
        type: ToastType.error,
      );
    }
  }

  Future<void> saveProfile() async {
    try {
      isLoading.value = true;
      final updatedUser = await _userRepository.updateProfile(
        name: nameController.text.trim(),
      );
      
      if (passwordController.text.isNotEmpty) {
        await _userRepository.updatePassword(passwordController.text.trim());
      }

      if (updatedUser != null) {
        user.value = updatedUser;
      }

      AppCommonToastMessage.show(
        message: "Profile changes saved successfully!",
        type: ToastType.success,
      );
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Failed to update profile: $e",
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
