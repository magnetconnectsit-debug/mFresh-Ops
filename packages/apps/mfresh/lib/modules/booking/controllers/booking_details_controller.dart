import 'package:get/get.dart';
import 'package:mfresh/data/models/booking_details_model.dart';
import 'package:mfresh/data/repositories/common_repository.dart';
import 'package:core/utils/app_common_toast_message.dart';

class BookingDetailsController extends GetxController {
  final CommonRepository _commonRepository = Get.find<CommonRepository>();

  final bookingDetails = Rxn<BookingDetailsModel>();
  final isLoading = false.obs;

  Future<void> fetchBookingDetails(String bookingId) async {
    try {
      isLoading.value = true;
      final result = await _commonRepository.getBookingDetails(bookingId: bookingId);
      if (result != null) {
        bookingDetails.value = result;
      }
    } catch (e) {
      AppCommonToastMessage.show(message: 'Failed to fetch booking details', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }
}
