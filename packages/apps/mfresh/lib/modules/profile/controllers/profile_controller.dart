import 'package:core/routes/app_routes.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  // Expandable section states
  final isMyBookingExpanded = false.obs;
  final isReferEarnExpanded = false.obs;
  final isHelpSupportExpanded = false.obs;
  final isFeedbackExpanded = false.obs;

  // User info (placeholder)
  final userName = 'Flyod Miles'.obs;
  final userPhone = '(225) 555-0118'.obs;
  final userEmail = 'flyod.miles@example.com'.obs;

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

  void logout() {
    Get.offAllNamed(AppRoutes.login);
  }
}
