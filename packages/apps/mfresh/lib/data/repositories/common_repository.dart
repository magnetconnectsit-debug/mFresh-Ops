import 'package:get/get.dart';
import 'package:mfresh/core/constants/app_constants.dart';
import 'package:services/api_services.dart';
import 'package:mfresh/data/models/booking_details_model.dart';
import 'package:mfresh/data/models/service_model.dart';
import 'package:mfresh/data/models/unit_model.dart';

class CommonRepository extends GetxService {
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

  Future<UnitModel?> getUnitConfig({required String unitId}) async {
    try {
      final response = await _apiService.post(
        '/customer/unit-config',
        data: {'unit_id': unitId},
      );

      if (response != null && response['status'] == 'success') {
        final data = response['data'];
        if (data != null) {
          if (data is List && data.isNotEmpty) {
            return UnitModel.fromJson(data[0]);
          } else if (data is Map<String, dynamic>) {
            return UnitModel.fromJson(data);
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<ServiceModel>> getServices({
    required String customerMode,
    required String unitNo,
    required String serviceMode,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.allServices,
        data: {
          'mem_status': customerMode,
          'unit_id': unitNo,
          'service_type': serviceMode,
        },
      );

      if (response != null && response['status'] == 'success') {
        final List data = response['data'] ?? [];
        return data.map((e) => ServiceModel.fromJson(e)).toList();
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

  Future<bool> sendSmsReceipt({required String bookingId, required String phone}) async {
    try {
      final response = await _apiService.post(
        AppConstants.sentSms,
        data: {
          'booking_id': bookingId,
          'mobile_no': phone,
        },
      );

      return response != null && response['status'] == 'success';
    } catch (e) {
      return false;
    }
  }
}
