import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:services/api_services.dart';
import 'package:mfresh_ops/data/models/booking_details_model.dart';
import 'package:mfresh_ops/data/models/booking_history_model.dart';
import 'package:mfresh_ops/data/models/service_model.dart';
import 'package:mfresh_ops/data/models/unit_model.dart';

class BookingRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<BookingDetailsModel?> getBookingDetails({required String bookingId}) async {
    try {
      final response = await _apiService.post(
        AppConstants.customerBookingDetails,
        data: {'booking_id': bookingId},
      );

      if (response != null && response['status'] == 'success') {
        final List data = response['data'] ?? [];
        if (data.isNotEmpty) {
          return BookingDetailsModel.fromJson(data[0]);
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> sendSmsReceipt({required String bookingId, required String phone}) async {
    try {
      final response = await _apiService.post(
        AppConstants.resendBookingSms,
        data: {
          'booking_id': bookingId,
          'phone_no': phone,
        },
      );
      if (response != null && response['status'] == 'success') {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<ServiceModel>> getServices({
    required String unitNo,
    required String serviceMode,
    required String customerMode,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.allUnitServices,
        data: {
          'mem_status': customerMode,
          'unit_id': unitNo,
          'service_type': serviceMode,
        },
      );
      debugPrint('ℹ️ getServices response: $response');

      if (response != null && response['status'] == 'success') {
        final List data = response['data'] ?? [];
        return data.map((e) => ServiceModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ getServices error: $e');
      return [];
    }
  }

  Future<List<BookingHistoryModel>> getBookingHistory() async {
    try {
      final response = await _apiService.post(AppConstants.bookingHistory);
      if (response != null && response['status'] == 'success') {
        final List data = response['data'] ?? [];
        return data.map((e) => BookingHistoryModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<UnitModel>> getAllUnits() async {
    try {
      final response = await _apiService.post(
        AppConstants.allUnits,
        data: {},
      );

      if (response != null && response['status'] == 'success') {
        final List data = response['data'] ?? [];
        return data.map((e) => UnitModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> initiateBooking({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.initiateBooking,
        data: data,
      );

      if (response != null && response['booking_id'] != null) {
        return response;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> confirmSuccessBooking({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.successBooking,
        data: data,
      );

      return response != null && response['status'] == 'success';
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> validateMemberPhone({required String phone}) async {
    try {
      final response = await _apiService.post(
        AppConstants.validateMemPhone,
        data: {'phone': phone},
      );

      return response != null && response['status'] == 'valid';
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendMemberOtp({required String phone}) async {
    try {
      final response = await _apiService.post(
        AppConstants.sendOtpMember,
        data: {'phone': phone},
      );

      return response != null && response['status'] == 'success';
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyMemberOtp({required String phone, required String otp}) async {
    try {
      final response = await _apiService.post(
        AppConstants.verifyOtpMember,
        data: {'phone': phone, 'otp': otp},
      );

      return response != null && response['status'] == 'success';
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> kioskScan({
    required String bookingId,
    String deviceId = "NA",
  }) async {
    try {
      final now = DateTime.now();
      final formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      final response = await _apiService.post(
        AppConstants.kioskScan,
        data: {
          "BookingID": bookingId,
          "DeviceID": deviceId,
          "AccessDate": formattedDate,
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
