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
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  
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
        emailController.text = result.email ?? '';
        mobileController.text = result.mob ?? '';
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

  Future<void> updateFullProfile() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final mob = mobileController.text.trim();
    final pass = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || mob.isEmpty || pass.isEmpty) {
      AppCommonToastMessage.show(message: 'Please fill all required fields', type: ToastType.error);
      return;
    }

    try {
      isLoading.value = true;
      final response = await _userRepository.editProfile(
        name: name,
        email: email,
        mob: mob,
        profileImage: userImage.isEmpty ? "NA" : userImage,
        password: pass,
      );
      if (response != null) {
        final successMsg = response['message'] ?? "Profile updated successfully";
        AppCommonToastMessage.show(message: successMsg, type: ToastType.success);
        // Re-fetch profile to sync state
        await fetchProfile();
      }
    } catch (e) {
      AppCommonToastMessage.show(message: 'Failed to update profile: $e', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }
}
