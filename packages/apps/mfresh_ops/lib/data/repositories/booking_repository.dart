// region Imports
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:mfresh_ops/data/models/booking/booking_models.dart';
import 'package:services/api_services.dart';
// endregion

// region BookingRepository Class
class BookingRepository extends GetxService {
  // region Dependencies & Services
  final ApiService _apiService = Get.find<ApiService>();
  // endregion

  // region Observables & State Variables
  final rxActiveCashierSessionId = Rxn<int>();
  final rxBookingActorUserId = Rxn<int>();
  final rxSelectedUnitId = ''.obs;
  // endregion

  // region Unit & Session API Operations
  Future<List<UnitModel>> getAllUnits() async {
    try {
      // 1. Primary: dedicated /admin-booking/units endpoint (Employee and Guest Cashier)
      final adminResponse = await _apiService.get(
        AppConstants.adminBookingUnits,
      );

      if (adminResponse != null && adminResponse is Map && adminResponse['status'] == true) {
        if (adminResponse['booking_actor_user_id'] != null) {
          final rawActorId = adminResponse['booking_actor_user_id'];
          rxBookingActorUserId.value = rawActorId is int
              ? rawActorId
              : int.tryParse(rawActorId.toString());
        }

        final data = adminResponse['data'];
        final List rawUnits = data is Map && data['units'] is List
            ? data['units']
            : (data is List ? data : []);

        if (rawUnits.isNotEmpty) {
          return rawUnits.map((e) {
            if (e is Map<String, dynamic>) {
              return UnitModel.fromJson(e);
            } else if (e is Map) {
              return UnitModel.fromJson(Map<String, dynamic>.from(e));
            }
            return UnitModel.fromJson({});
          }).toList();
        }
      }
    } catch (e) {
      debugPrint("admin-booking/units fallback to customer/All-Units: $e");
    }

    // 2. Fallback: legacy customer/All-Units
    try {
      final response = await _apiService.post(
        AppConstants.allUnits,
        data: {},
      );

      if (response != null &&
          (response['status'] == 'success' ||
              response['status'] == true ||
              response['status'] == 'true' ||
              response is List)) {
        final List data = response is List
            ? response
            : ((response['data'] is List) ? response['data'] : []);
        return data.map((e) => UnitModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<UnitEnterResult> enterUnitSession({required String unitId}) async {
    try {
      final response = await _apiService.post(
        AppConstants.adminBookingUnitEnter,
        data: {'unit_id': unitId},
      );

      if (response != null && response is Map) {
        final result = UnitEnterResult.fromJson(Map<String, dynamic>.from(response));
        if (result.session != null) {
          rxActiveCashierSessionId.value = result.session!.cashierSessionId;
          rxSelectedUnitId.value = result.session!.unitId;
        }
        if (result.bookingActorUserId != null) {
          rxBookingActorUserId.value = result.bookingActorUserId;
        }
        return result;
      }
      return UnitEnterResult(
        status: false,
        message: 'Invalid response from unit enter API',
      );
    } catch (e) {
      debugPrint("❌ enterUnitSession error: $e");
      rethrow;
    }
  }
  // endregion

  // region Services API Operations
  Future<List<ServiceModel>> getServices({
    required String unitNo,
    required String serviceMode,
    required String customerMode,
    int? cashierSessionId,
  }) async {
    final int effectiveSessionId =
        cashierSessionId ?? rxActiveCashierSessionId.value ?? 0;

    // 1. Primary: /admin-booking/unit/services
    try {
      final response = await _apiService.post(
        AppConstants.adminBookingUnitServices,
        data: {
          'unit_id': unitNo,
          if (effectiveSessionId > 0) 'cashier_session_id': effectiveSessionId,
          'service_type': int.tryParse(serviceMode) ?? 1,
          'mem_status': int.tryParse(customerMode) ?? 0,
        },
      );
      debugPrint('ℹ️ admin-booking/unit/services response: $response');

      if (response != null && response is Map && response['status'] == true) {
        if (response['booking_actor_user_id'] != null) {
          final rawActorId = response['booking_actor_user_id'];
          rxBookingActorUserId.value = rawActorId is int
              ? rawActorId
              : int.tryParse(rawActorId.toString());
        }

        final data = response['data'];
        final List rawServices = data is Map && data['services'] is List
            ? data['services']
            : (data is List ? data : []);

        if (rawServices.isNotEmpty) {
          return rawServices.map((e) {
            if (e is Map<String, dynamic>) {
              return ServiceModel.fromJson(e);
            } else if (e is Map) {
              return ServiceModel.fromJson(Map<String, dynamic>.from(e));
            }
            return ServiceModel.fromJson({});
          }).toList();
        }
      }
    } catch (e) {
      debugPrint("admin-booking/unit/services fallback to customer/Api-get-Unit-services: $e");
    }

    // 2. Fallback: customer/Api-get-Unit-services
    try {
      final response = await _apiService.post(
        AppConstants.allUnitServices,
        data: {
          'mem_status': customerMode,
          'unit_id': unitNo,
          'service_type': serviceMode,
        },
      );
      debugPrint('ℹ️ fallback getServices response: $response');

      if (response != null && response['status'] == 'success') {
        final List data = response['data'] ?? [];
        return data.map((e) => ServiceModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ fallback getServices error: $e');
      return [];
    }
  }
  // endregion

  // region Booking Initiation & Confirmation Operations
  Future<BookingInitiateResult> initiateAdminBooking({
    required String unitNo,
    required String userId,
    required int cashierSessionId,
    required String phoneNo,
    String addPhoneNo = '',
    String userName = '',
    required double totalAmount,
    required String paymentStatus,
    required int paymentMode,
    required int serviceType,
    int memStatus = 0,
    bool externalPaymentConfirmed = false,
    required List<CartItemPayload> cart,
  }) async {
    try {
      final payload = {
        'Unit_no': unitNo,
        'User_Id': userId,
        'cashier_session_id': cashierSessionId,
        'phone_no': phoneNo,
        'Add_phone_no': addPhoneNo,
        'User_name': userName,
        'total_amount': totalAmount.toStringAsFixed(0),
        'Payment_status': paymentStatus,
        'payment_mode': paymentMode.toString(),
        'service_type': serviceType.toString(),
        'mem_status': memStatus.toString(),
        if (externalPaymentConfirmed) 'external_payment_confirmed': true,
        'cart': cart.map((e) => e.toJson()).toList(),
      };

      final response = await _apiService.post(
        AppConstants.adminBookingInitiate,
        data: payload,
      );

      if (response != null && response is Map) {
        return BookingInitiateResult.fromJson(Map<String, dynamic>.from(response));
      }
      return BookingInitiateResult(
        status: false,
        message: 'Invalid response from booking initiate API',
      );
    } catch (e) {
      debugPrint("❌ initiateAdminBooking error: $e");
      rethrow;
    }
  }

  Future<BookingPaymentSuccessResult> submitPaymentSuccess({
    required String userId,
    required String bookingId,
    required String paymentStatus,
    required String providerReferenceId,
    required String checkSum,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.adminBookingPaymentSuccess,
        data: {
          'userId': userId,
          'bookingId': bookingId,
          'Payment_status': paymentStatus,
          'provider_reference_id': providerReferenceId,
          'check_sum': checkSum,
        },
      );

      if (response != null && response is Map) {
        return BookingPaymentSuccessResult.fromJson(
          Map<String, dynamic>.from(response),
        );
      }
      return BookingPaymentSuccessResult(
        status: false,
        message: 'Invalid response from payment success API',
      );
    } catch (e) {
      debugPrint("❌ submitPaymentSuccess error: $e");
      rethrow;
    }
  }

  // endregion

  // region Booking Details & Receipt Operations

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
  // endregion

  // region Membership Validation Operations
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
  // endregion

  // region Kiosk Scan Operations
  Future<Map<String, dynamic>?> kioskScan({
    required String bookingId,
    String deviceId = "NA",
  }) async {
    try {
      final now = DateTime.now();
      final formattedDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

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
  // endregion
}
// endregion
