import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mfresh_ops/data/models/booking_details_model.dart';
import 'package:mfresh_ops/data/repositories/booking_repository.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/models/unit_model.dart';

class BookingDetailsController extends GetxController {
  final BookingRepository _bookingRepository = Get.find<BookingRepository>();

  final bookingDetails = Rxn<BookingDetailsModel>();
  final isLoading = false.obs;
  
  // Printer Config
  final printingType = 'thermal'.obs;
  final paperRollSize = 80.obs;

  Future<void> fetchBookingDetails(String bookingId) async {
    try {
      isLoading.value = true;
      
      if (bookingId.startsWith("DUMMY")) {
        bookingDetails.value = BookingDetailsModel(
          bookingId: bookingId,
          unitNo: "MM2500DEV",
          bookingTimeDate: DateTime.now().toString(),
          unitLocation: "Puri",
          totalAmount: "1",
          paymentMode: 1,
          fullAddress: "Puri Beach Road",
          services: [ServiceItem(servicesName: "Toilet - Male", quantity: "1")],
        );
        printingType.value = 'thermal';
        paperRollSize.value = 80;
        return;
      }

      var result = await _bookingRepository.getBookingDetails(bookingId: bookingId);
      if (result != null) {
        try {
          UnitModel? unitConfig;
          
          unitConfig = UnitModel(
            id: 0,
            unitId: result.unitNo,
            unitImage: '',
            unitLocation: '',
            timing: '',
            printingType: 'thermal', // Default fallback
            paperRollSize: 80,
          );

          printingType.value = unitConfig.printingType;
          paperRollSize.value = unitConfig.paperRollSize;
          debugPrint("BookingDetailsController: FINAL CONFIG -> Type: ${printingType.value}, Size: ${paperRollSize.value}");
        } catch (e) {
          debugPrint("Failed to fetch unit config in BookingDetailsController: $e");
        }
        // ENRICHMENT: Match service names with unit services to get accurate prices
        try {
          final unitServices = await _bookingRepository.getServices(
            unitNo: result.unitNo,
            serviceMode: result.paymentMode == 2 ? '2' : '1',
            customerMode: '0', // Default to 0 for matching
          );

          if (unitServices.isNotEmpty) {
            final List<ServiceItem> enrichedServices = [];
            for (var item in result.services) {
              // Only try to find price if it's missing or zero
              if (item.price.isEmpty || item.price == '0' || item.price == '0.0' || item.price == '0.00') {
                final match = unitServices.firstWhereOrNull(
                  (s) => (s.serviceName ?? '').trim().toLowerCase() == item.servicesName.trim().toLowerCase(),
                );
                if (match != null) {
                  enrichedServices.add(item.copyWith(price: match.price.toString()));
                } else {
                  enrichedServices.add(item);
                }
              } else {
                enrichedServices.add(item);
              }
            }
            result = result.copyWith(services: enrichedServices);
          }
        } catch (e) {
          debugPrint("Enrichment failed: $e");
        }
        
        bookingDetails.value = result;
      }
    } catch (e) {
      AppCommonToastMessage.show(message: 'Failed to fetch booking details', type: ToastType.error);
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
}
