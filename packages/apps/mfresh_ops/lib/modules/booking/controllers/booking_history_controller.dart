import 'package:get/get.dart';

import 'package:mfresh_ops/data/models/booking_history_model.dart';
import 'package:mfresh_ops/data/repositories/booking_repository.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/modules/profile/controllers/profile_controller.dart';

class BookingHistoryController extends GetxController {
  final BookingRepository _bookingRepository = Get.find<BookingRepository>();
  final ProfileController _profileController = Get.put(ProfileController());

  final bookings = <BookingHistoryModel>[].obs;
  final isLoading = false.obs;

  // Filters
  final selectedDateFilter = 'All'.obs; // All, Today, Yesterday
  final selectedModeFilter = 'All'.obs; // All, Cash, Online

  bool get showFilters => _profileController.user.value?.permissions?.contains('userProfileFilter') ?? false;

  @override
  void onInit() {
    super.onInit();
    fetchBookingHistory();
  }

  List<BookingHistoryModel> get filteredBookings {
    return bookings.where((booking) {
      // Date filter
      bool dateMatch = true;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      
      try {
        final bDate = DateTime.parse(booking.createdAt).toLocal();
        final bDay = DateTime(bDate.year, bDate.month, bDate.day);
        
        if (selectedDateFilter.value == 'Today') {
          dateMatch = bDay.isAtSameMomentAs(today);
        } else if (selectedDateFilter.value == 'Yesterday') {
          dateMatch = bDay.isAtSameMomentAs(yesterday);
        }
      } catch (_) {}

      // Mode filter
      bool modeMatch = true;
      if (selectedModeFilter.value != 'All') {
        final String mode = booking.paymentMode == 1 ? 'Cash' : 'Online';
        modeMatch = mode.toLowerCase() == selectedModeFilter.value.toLowerCase();
      }

      return dateMatch && modeMatch;
    }).toList();
  }

  Future<void> fetchBookingHistory() async {
    try {
      isLoading.value = true;
      final result = await _bookingRepository.getBookingHistory();
      bookings.assignAll(result);
    } catch (e) {
      AppCommonToastMessage.show(message: 'Failed to fetch booking history', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await Future.wait([
      fetchBookingHistory(),
    ]);
  }
}
