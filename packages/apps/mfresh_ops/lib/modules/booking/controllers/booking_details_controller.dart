// region Imports
import 'package:core/utils/app_common_toast_message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/booking/booking_models.dart';
import 'package:mfresh_ops/data/repositories/booking_repository.dart';
// endregion

// region Controller
class BookingDetailsController extends GetxController {
  // region Dependencies & Repositories
  final BookingRepository _bookingRepository = Get.find<BookingRepository>();
  // endregion

  // region Observables & State Variables
  final bookingDetails = Rxn<BookingDetailsModel>();
  final isLoading = false.obs;

  // Printer Config
  final printingType = 'thermal'.obs;
  final paperRollSize = 80.obs;
  // endregion

  void setBookingDetails(
    BookingDetailsModel details, {
    String? pType,
    int? rSize,
  }) {
    bookingDetails.value = details;
    if (pType != null && pType.isNotEmpty) {
      printingType.value = pType;
    }
    if (rSize != null && rSize > 0) {
      paperRollSize.value = rSize;
    }
    isLoading.value = false;
  }

  // region API & Business Logic Operations
  Future<void> fetchBookingDetails(
    String bookingId, {
    String? fallbackUnitNo,
    String? fallbackAmount,
    String? encryptId,
    String? receiptUrl,
  }) async {
    try {
      isLoading.value = true;

      if (bookingDetails.value != null &&
          bookingDetails.value!.bookingId == bookingId) {
        return;
      }

      if (bookingId.startsWith("DUMMY")) {
        bookingDetails.value = BookingDetailsModel(
          bookingId: bookingId,
          unitNo: "MM2500DEV",
          bookingTimeDate: DateTime.now().toString(),
          unitLocation: "Puri",
          totalAmount: "1",
          paymentMode: 1,
          fullAddress: "Puri Beach Road",
          services: [BookingServiceDetailItem(servicesName: "Toilet - Male", quantity: "1")],
        );
        printingType.value = 'thermal';
        paperRollSize.value = 80;
        return;
      }

      if (fallbackUnitNo != null && fallbackUnitNo.isNotEmpty) {
        bookingDetails.value = BookingDetailsModel(
          bookingId: bookingId,
          unitNo: fallbackUnitNo,
          bookingTimeDate: DateTime.now().toString(),
          totalAmount: fallbackAmount ?? '',
          paymentMode: 1,
          paymentStatus: 'PAYMENT_SUCCESS',
          encryptBookingId: encryptId,
        );
      }
    } catch (e) {
      debugPrint("fetchBookingDetails error: $e");
      if (fallbackUnitNo != null && fallbackUnitNo.isNotEmpty) {
        bookingDetails.value = BookingDetailsModel(
          bookingId: bookingId,
          unitNo: fallbackUnitNo,
          bookingTimeDate: DateTime.now().toString(),
          totalAmount: fallbackAmount ?? '',
          paymentMode: 1,
          paymentStatus: 'PAYMENT_SUCCESS',
          encryptBookingId: encryptId,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendSms(String phone) async {
    if (bookingDetails.value == null) return;

    try {
      final success = await _bookingRepository.sendSmsReceipt(
        bookingId: bookingDetails.value!.bookingId,
        phone: phone,
      );

      if (success) {
        AppCommonToastMessage.show(message: "sent successfully", type: ToastType.success);
      } else {
        AppCommonToastMessage.show(message: "Failed to send SMS", type: ToastType.error);
      }
    } catch (e) {
      AppCommonToastMessage.show(message: "Error: $e", type: ToastType.error);
    }
  }
  // endregion
}
// endregion
