// region Imports
import 'package:core/utils/app_common_toast_message.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/booking/booking_models.dart';
import 'package:mfresh_ops/data/repositories/booking_repository.dart';
import 'package:mfresh_ops/modules/profile/controllers/profile_controller.dart';
// endregion

// region Controller
class BookingHistoryController extends GetxController {
  // region Dependencies & Repositories
  final BookingRepository _bookingRepository = Get.find<BookingRepository>();
  final ProfileController _profileController = Get.put(ProfileController());
  // endregion

  // region Observables & State Variables
  final bookings = <BookingHistoryModel>[].obs;
  final isLoading = false.obs;

  // Filters
  final selectedDateFilter = 'All'.obs; // All, Today, Yesterday
  final selectedModeFilter = 'All'.obs; // All, Cash, Online
  // endregion

  // region Getters & Computed Properties
  bool get showFilters =>
      _profileController.user.value?.permissions?.contains('userProfileFilter') ??
      false;

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
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    fetchBookingHistory();
  }
  // endregion

  // region API & Business Logic Operations
  Future<void> fetchBookingHistory() async {
    try {
      isLoading.value = true;
      final result = await _bookingRepository.getBookingHistory();
      bookings.assignAll(result);
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to fetch booking history',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await Future.wait([
      fetchBookingHistory(),
    ]);
  }
  // endregion
}
// endregion
