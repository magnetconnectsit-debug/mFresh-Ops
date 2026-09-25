import 'dart:convert';
import 'package:get/get.dart';
import 'package:mfresh/data/models/unit_model.dart';
import 'package:mfresh/data/repositories/common_repository.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh/routes/app_routes.dart';

class DashboardController extends GetxController {
  final CommonRepository _commonRepository = Get.find<CommonRepository>();

  final allUnitsList = <UnitModel>[].obs;
  final isLoading = false.obs;
  final currentIndex = 0.obs;

  void onTabTapped(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    fetchUnits();
  }

  Future<void> fetchUnits() async {
    try {
      isLoading.value = true;
      final units = await _commonRepository.getAllUnits();
      allUnitsList.assignAll(units);
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to load units',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> handleScannedCode(String result) async {
    try {
      String? bookingId;
      
      // 1. Try to parse as JSON first (if it's a JSON QR)
      try {
        final decoded = jsonDecode(result);
        if (decoded is Map && decoded.containsKey('BookingID')) {
          bookingId = decoded['BookingID'].toString();
        }
      } catch (e) {
        // Not a JSON, use raw result as bookingId candidate
        bookingId = result;
      }

      if (bookingId == null || bookingId.isEmpty) {
        return {"StatusCode": 400, "ErrorMessage": "Invalid QR code"};
      }

      // 2. Check if it matches a known Unit ID (legacy behavior)
      final unitMatch = allUnitsList.firstWhereOrNull((u) => u.unitId == bookingId);
      if (unitMatch != null) {
        Get.toNamed(
          AppRoutes.serviceDetails,
          arguments: {
            'unitNo': unitMatch.unitId,
            'location': unitMatch.unitLocation,
            'unitImage': unitMatch.unitImage,
            'printingType': unitMatch.printingType,
            'paperRollSize': unitMatch.paperRollSize,
          },
        );
        return {"StatusCode": 200, "Status": "Navigating", "ErrorMessage": "Opening Unit Details"};
      }

      // 3. Otherwise, treat as Kiosk Scan (New behavior)
      final response = await _commonRepository.kioskScan(bookingId: bookingId);
      return response;
    } catch (e) {
      return {"StatusCode": 500, "ErrorMessage": "Scan Error: $e"};
    }
  }
}
