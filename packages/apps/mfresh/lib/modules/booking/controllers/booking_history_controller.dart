import 'package:get/get.dart';
import 'package:mfresh/data/models/booking_history_model.dart';
import 'package:mfresh/data/repositories/user_repository.dart';
import 'package:core/utils/app_common_toast_message.dart';

class BookingHistoryController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();

  final bookings = <BookingHistoryModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookingHistory();
  }

  Future<void> fetchBookingHistory() async {
    try {
      isLoading.value = true;
      final result = await _userRepository.getBookingHistory();
      bookings.assignAll(result);
    } catch (e) {
      AppCommonToastMessage.show(message: 'Failed to fetch booking history', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }
}
