// region Imports
import 'dart:convert';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/booking/booking_models.dart';
import 'package:mfresh_ops/data/repositories/booking_repository.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:services/services.dart';
// endregion

// region BookingUnitSelectionController Class
class BookingUnitSelectionController extends GetxController {
  // region Dependencies & Repositories
  final BookingRepository _bookingRepository = Get.find<BookingRepository>();
  // endregion

  // region Observables & State Variables
  final allUnitsList = <UnitModel>[].obs;
  final isLoading = false.obs;
  final isEnteringSession = false.obs;
  final currentIndex = 0.obs;
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<StorageService>()) {
      Get.find<StorageService>().saveLoginMode('booking');
    }
    fetchUnits();
  }
  // endregion

  // region Tab Navigation
  void onTabTapped(int index) {
    currentIndex.value = index;
  }
  // endregion

  // region Unit & Session Operations
  Future<void> fetchUnits() async {
    try {
      isLoading.value = true;
      final units = await _bookingRepository.getAllUnits();
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

  Future<void> selectAndEnterUnit(UnitModel unit) async {
    try {
      isEnteringSession.value = true;
      final result = await _bookingRepository.enterUnitSession(unitId: unit.unitId);

      final sessionId = result.session?.cashierSessionId ??
          _bookingRepository.rxActiveCashierSessionId.value;

      Get.toNamed(
        AppRoutes.serviceDetails,
        arguments: {
          'unitNo': unit.unitId,
          'location': unit.unitLocation,
          'unitImage': unit.unitImage,
          'printingType': unit.printingType,
          'paperRollSize': unit.paperRollSize,
          'cashierSessionId': sessionId,
        },
      );
    } catch (e) {
      debugPrint("Unit enter failed: $e. Proceeding with fallback unit selection.");
      Get.toNamed(
        AppRoutes.serviceDetails,
        arguments: {
          'unitNo': unit.unitId,
          'location': unit.unitLocation,
          'unitImage': unit.unitImage,
          'printingType': unit.printingType,
          'paperRollSize': unit.paperRollSize,
        },
      );
    } finally {
      isEnteringSession.value = false;
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
        bookingId = result;
      }

      if (bookingId == null || bookingId.isEmpty) {
        return {"StatusCode": 400, "ErrorMessage": "Invalid QR code"};
      }

      // 2. Check if it matches a known Unit ID (Unit Entry behavior)
      final unitMatch = allUnitsList.firstWhereOrNull((u) => u.unitId == bookingId);
      if (unitMatch != null) {
        await selectAndEnterUnit(unitMatch);
        return {"StatusCode": 200, "Status": "Navigating", "ErrorMessage": "Opening Unit Details"};
      }

      // 3. Otherwise, treat as Kiosk Scan
      final response = await _bookingRepository.kioskScan(bookingId: bookingId);
      return response;
    } catch (e) {
      return {"StatusCode": 500, "ErrorMessage": "Scan Error: $e"};
    }
  }
  // endregion
}
// endregion
