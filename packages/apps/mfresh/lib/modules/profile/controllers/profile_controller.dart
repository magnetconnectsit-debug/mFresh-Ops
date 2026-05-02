import 'package:mfresh/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:mfresh/data/models/user.dart';
import 'package:mfresh/data/repositories/user_repository.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh/data/models/booking_history_model.dart';
import 'package:mfresh/data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

class ProfileController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final user = Rxn<User>();
  final isLoading = false.obs;
  final bookingHistory = <BookingHistoryModel>[].obs;
  final isHistoryLoading = false.obs;

  final nameController = TextEditingController();
  
  String get userName => user.value?.name ?? 'User Name';
  String get userPhone => user.value?.mob ?? 'User Phone';
  String get userEmail => user.value?.email ?? 'User Email';
  String get userImage => user.value?.profileImage ?? '';

  // Expandable section states
  final isMyBookingExpanded = false.obs;
  final isReferEarnExpanded = false.obs;
  final isHelpSupportExpanded = false.obs;
  final isFeedbackExpanded = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final result = await _userRepository.getProfile();
      if (result != null) {
        user.value = result;
        nameController.text = result.name ?? '';
      }
    } catch (e) {
      AppCommonToastMessage.show(message: 'Failed to fetch profile', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleMyBooking() {
    isMyBookingExpanded.value = !isMyBookingExpanded.value;
  }

  void toggleReferEarn() {
    isReferEarnExpanded.value = !isReferEarnExpanded.value;
  }

  void toggleHelpSupport() {
    isHelpSupportExpanded.value = !isHelpSupportExpanded.value;
  }

  void toggleFeedback() {
    isFeedbackExpanded.value = !isFeedbackExpanded.value;
  }

  void logout() async {
    try {
      final success = await _authRepository.logout();
      if (success) {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> fetchBookingHistory() async {
    try {
      isHistoryLoading.value = true;
      final result = await _userRepository.getBookingHistory();
      bookingHistory.assignAll(result);
    } catch (e) {
      AppCommonToastMessage.show(message: 'Failed to fetch booking history', type: ToastType.error);
    } finally {
      isHistoryLoading.value = false;
    }
  }

  Future<void> updateProfileName() async {
    final newName = nameController.text.trim();
    if (newName.isEmpty) return;

    try {
      isLoading.value = true;
      final updatedUser = await _userRepository.updateProfile(name: newName);
      if (updatedUser != null) {
        user.value = updatedUser;
        AppCommonToastMessage.show(message: 'Profile updated successfully', type: ToastType.success);
      }
    } catch (e) {
      AppCommonToastMessage.show(message: 'Failed to update profile', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }
}
