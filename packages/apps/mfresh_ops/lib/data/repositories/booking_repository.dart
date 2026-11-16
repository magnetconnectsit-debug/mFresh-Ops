// region Imports
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:mfresh_ops/data/models/models.dart';
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
  Future<MemberValidateResult> validateMemberPhone({required String phone}) async {
    try {
      final response = await _apiService.post(
        AppConstants.validateMemPhone,
        data: {'phone': phone},
      );

      if (response != null && response is Map) {
        return MemberValidateResult.fromJson(Map<String, dynamic>.from(response));
      }
      return MemberValidateResult(
        isValid: false,
        status: 'error',
        message: 'Invalid response from server.',
      );
    } catch (e) {
      debugPrint('validateMemberPhone error: $e');
      String errorMsg = 'Failed to validate member.';
      if (e is Exception && e.toString().contains('response:')) {
        // Extract Dio response data if available
      }
      // Check if it is a DioException with 403 or 404 response payload
      try {
        final dynamic dynErr = e;
        if (dynErr?.response?.data != null && dynErr.response.data is Map) {
          final resData = Map<String, dynamic>.from(dynErr.response.data);
          return MemberValidateResult.fromJson(resData);
        }
      } catch (_) {}

      return MemberValidateResult(
        isValid: false,
        status: 'error',
        message: errorMsg,
      );
    }
  }

  Future<MemberOtpSendResult> sendMemberOtp({required String phone}) async {
    try {
      final response = await _apiService.post(
        AppConstants.sendOtpMember,
        data: {'phone': phone},
      );

      if (response != null && response is Map) {
        return MemberOtpSendResult.fromJson(Map<String, dynamic>.from(response));
      }
      return MemberOtpSendResult(
        isSuccess: false,
        status: 'error',
        message: 'Failed to send OTP.',
      );
    } catch (e) {
      debugPrint('sendMemberOtp error: $e');
      try {
        final dynamic dynErr = e;
        if (dynErr?.response?.data != null && dynErr.response.data is Map) {
          final resData = Map<String, dynamic>.from(dynErr.response.data);
          return MemberOtpSendResult.fromJson(resData);
        }
      } catch (_) {}
      return MemberOtpSendResult(
        isSuccess: false,
        status: 'error',
        message: 'Failed to send OTP: $e',
      );
    }
  }

  Future<MemberOtpVerifyResult> verifyMemberOtp({required String phone, required String otp}) async {
    try {
      final response = await _apiService.post(
        AppConstants.verifyOtpMember,
        data: {'phone': phone, 'otp': otp},
      );

      if (response != null && response is Map) {
        return MemberOtpVerifyResult.fromJson(Map<String, dynamic>.from(response));
      }
      return MemberOtpVerifyResult(
        isVerified: false,
        status: 'error',
        message: 'Invalid OTP.',
      );
    } catch (e) {
      debugPrint('verifyMemberOtp error: $e');
      try {
        final dynamic dynErr = e;
        if (dynErr?.response?.data != null && dynErr.response.data is Map) {
          final resData = Map<String, dynamic>.from(dynErr.response.data);
          return MemberOtpVerifyResult.fromJson(resData);
        }
      } catch (_) {}
      return MemberOtpVerifyResult(
        isVerified: false,
        status: 'error',
        message: 'OTP verification failed.',
      );
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

  // region Recent Bookings Operations
  Future<List<RecentBookingItemModel>> getRecentBookings({
    required String unitId,
    int? cashierSessionId,
  }) async {
    final int effectiveSessionId =
        cashierSessionId ?? rxActiveCashierSessionId.value ?? 0;

    try {
      final response = await _apiService.post(
        AppConstants.adminBookingRecentBookings,
        data: {
          'unit_id': unitId,
          if (effectiveSessionId > 0) 'cashier_session_id': effectiveSessionId,
        },
      );
      debugPrint('admin-booking/unit/recent-bookings response: $response');

      if (response != null && response is Map && (response['status'] == true || response['status'] == 'success')) {
        final dynamic rawList = response['bookings'] ??
            (response['data'] is List
                ? response['data']
                : (response['data'] is Map ? response['data']['bookings'] : null));

        if (rawList is List) {
          return rawList.map((e) {
            if (e is Map<String, dynamic>) {
              return RecentBookingItemModel.fromJson(e);
            } else if (e is Map) {
              return RecentBookingItemModel.fromJson(Map<String, dynamic>.from(e));
            }
            return RecentBookingItemModel.fromJson({});
          }).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('getRecentBookings error: $e');
      return [];
    }
  }
  // endregion

  // region Cash Handover & C-to-D API Operations
  Future<HandoverOverviewResult> getHandoverOverview({
    required String unitId,
    int? sessionId,
  }) async {
    final int effectiveSessionId =
        sessionId ?? rxActiveCashierSessionId.value ?? 0;

    try {
      final response = await _apiService.post(
        AppConstants.adminHandoverOverview,
        data: {
          'unit_id': unitId,
          'session_id': effectiveSessionId,
        },
      );

      if (response != null && response is Map) {
        return HandoverOverviewResult.fromJson(Map<String, dynamic>.from(response));
      }
      return HandoverOverviewResult(
        status: false,
        message: 'Invalid response from handover overview',
      );
    } catch (e) {
      debugPrint('getHandoverOverview error: $e');
      rethrow;
    }
  }

  Future<List<CtodDateEntryModel>> getCtodDates({
    required String unitId,
    int? sessionId,
    String? fromDate,
    String? toDate,
  }) async {
    final int effectiveSessionId =
        sessionId ?? rxActiveCashierSessionId.value ?? 0;

    try {
      final response = await _apiService.post(
        AppConstants.adminHandoverCtodDates,
        data: {
          'unit_id': unitId,
          'session_id': effectiveSessionId,
          if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
          if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
        },
      );

      if (response != null && response is Map && (response['status'] == true || response['status'] == 'success')) {
        final rawData = response['data'];
        final List list = rawData is List
            ? rawData
            : (rawData is Map && rawData['dates'] is List ? rawData['dates'] : []);

        return list.map((e) {
          if (e is Map<String, dynamic>) {
            return CtodDateEntryModel.fromJson(e);
          } else if (e is Map) {
            return CtodDateEntryModel.fromJson(Map<String, dynamic>.from(e));
          }
          return CtodDateEntryModel.fromJson({});
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('getCtodDates error: $e');
      return [];
    }
  }

  Future<HandoverUsersResult> getHandoverUsers() async {
    try {
      final response = await _apiService.get(AppConstants.adminHandoverUsers);

      if (response != null && response is Map && (response['status'] == true || response['status'] == 'success')) {
        final handoverRaw = response['handover_users'] ?? [];
        final ctodRaw = response['ctod_users'] ?? [];

        final handoverUsers = (handoverRaw as List).map((e) {
          if (e is Map<String, dynamic>) {
            return AssigneeModel.fromJson(e);
          } else if (e is Map) {
            return AssigneeModel.fromJson(Map<String, dynamic>.from(e));
          }
          return AssigneeModel(id: 0, name: '');
        }).where((u) => u.id > 0).toList();

        final ctodUsers = (ctodRaw as List).map((e) {
          if (e is Map<String, dynamic>) {
            return AssigneeModel.fromJson(e);
          } else if (e is Map) {
            return AssigneeModel.fromJson(Map<String, dynamic>.from(e));
          }
          return AssigneeModel(id: 0, name: '');
        }).where((u) => u.id > 0).toList();

        return HandoverUsersResult(
          status: true,
          message: response['message']?.toString() ?? 'Users fetched successfully.',
          handoverUsers: handoverUsers,
          ctodUsers: ctodUsers,
        );
      }
      return HandoverUsersResult(
        status: false,
        message: 'Failed to fetch handover users',
      );
    } catch (e) {
      debugPrint('getHandoverUsers error: $e');
      return HandoverUsersResult(
        status: false,
        message: 'Error fetching handover users: $e',
      );
    }
  }

  Future<HandoverCreateResult> createHandover({
    required String currentUnit,
    required int sessionId,
    required dynamic nextCashier,
    required String handoverAction,
    double? amount,
    List<Map<String, dynamic>>? collectionEntries,
  }) async {
    try {
      final payload = {
        'current_unit': currentUnit,
        'session_id': sessionId,
        'next_cashier': nextCashier,
        'handover_action': handoverAction,
        if (amount != null) 'amount': amount,
        if (collectionEntries != null && collectionEntries.isNotEmpty)
          'collection_entries': collectionEntries,
      };

      final response = await _apiService.post(
        AppConstants.adminHandoverCreate,
        data: payload,
      );

      if (response != null && response is Map) {
        return HandoverCreateResult.fromJson(Map<String, dynamic>.from(response));
      }
      return HandoverCreateResult(
        status: false,
        message: 'Invalid response from handover create',
      );
    } catch (e) {
      debugPrint('createHandover error: $e');
      rethrow;
    }
  }

  Future<bool> resendHandoverOtp({required int handoverId}) async {
    try {
      final response = await _apiService.post(
        AppConstants.adminHandoverResendOtp,
        data: {'handover_id': handoverId},
      );
      return response != null && (response['status'] == true || response['status'] == 'success');
    } catch (e) {
      debugPrint('resendHandoverOtp error: $e');
      return false;
    }
  }

  Future<HandoverVerifyOtpResult> verifyHandoverOtp({
    required int handoverId,
    required String otp,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.adminHandoverVerifyOtp,
        data: {
          'handover_id': handoverId,
          'otp': otp,
        },
      );

      if (response != null && response is Map) {
        final result = HandoverVerifyOtpResult.fromJson(Map<String, dynamic>.from(response));
        if (result.sessionClosed) {
          rxActiveCashierSessionId.value = null;
          rxSelectedUnitId.value = '';
        }
        return result;
      }
      return HandoverVerifyOtpResult(
        status: false,
        message: 'Invalid response from handover verify OTP',
      );
    } catch (e) {
      debugPrint('verifyHandoverOtp error: $e');
      rethrow;
    }
  }

  Future<bool> exitCheck({required String unitId, int? sessionId}) async {
    final int effectiveSessionId =
        sessionId ?? rxActiveCashierSessionId.value ?? 0;

    try {
      final response = await _apiService.post(
        AppConstants.adminHandoverExitCheck,
        data: {
          'unit_id': unitId,
          'session_id': effectiveSessionId,
        },
      );
      return response != null && (response['status'] == true || response['status'] == 'success');
    } catch (e) {
      debugPrint('exitCheck error: $e');
      return false;
    }
  }
  // endregion
}
// endregion
