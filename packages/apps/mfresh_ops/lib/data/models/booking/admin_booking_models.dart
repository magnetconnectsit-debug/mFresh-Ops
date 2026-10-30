import 'booking_details_model.dart';

// region Models
class CashierSessionModel {
  final int cashierSessionId;
  final int cashierId;
  final int? guestLoginId;
  final String unitId;
  final int? unitRecordId;
  final String status;
  final String? loginTime;
  final String? openingCash;

  CashierSessionModel({
    required this.cashierSessionId,
    required this.cashierId,
    this.guestLoginId,
    required this.unitId,
    this.unitRecordId,
    required this.status,
    this.loginTime,
    this.openingCash,
  });

  // region Factory & Serialization
  factory CashierSessionModel.fromJson(Map<String, dynamic> json) {
    final rawSessionId = json['cashier_session_id'] ?? json['id'] ?? 0;
    final int sessionId = rawSessionId is int ? rawSessionId : int.tryParse(rawSessionId.toString()) ?? 0;

    final rawCashierId = json['cashier_id'] ?? json['user_id'] ?? 0;
    final int cashierId = rawCashierId is int ? rawCashierId : int.tryParse(rawCashierId.toString()) ?? 0;

    final rawGuestLoginId = json['guest_login_id'];
    final int? guestLoginId = rawGuestLoginId != null
        ? (rawGuestLoginId is int ? rawGuestLoginId : int.tryParse(rawGuestLoginId.toString()))
        : null;

    final rawUnitRecId = json['unit_record_id'];
    final int? unitRecordId = rawUnitRecId != null
        ? (rawUnitRecId is int ? rawUnitRecId : int.tryParse(rawUnitRecId.toString()))
        : null;

    return CashierSessionModel(
      cashierSessionId: sessionId,
      cashierId: cashierId,
      guestLoginId: guestLoginId,
      unitId: (json['unit_id'] ?? '').toString(),
      unitRecordId: unitRecordId,
      status: (json['status'] ?? 'ACTIVE').toString(),
      loginTime: json['login_time']?.toString(),
      openingCash: json['opening_cash']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cashier_session_id': cashierSessionId,
      'cashier_id': cashierId,
      'guest_login_id': guestLoginId,
      'unit_id': unitId,
      'unit_record_id': unitRecordId,
      'status': status,
      'login_time': loginTime,
      'opening_cash': openingCash,
    };
  }
  // endregion
}

class UnitEnterResult {
  final bool status;
  final String message;
  final bool sessionCreated;
  final bool restoredPendingHandover;
  final int? bookingActorUserId;
  final int? guestParentId;
  final String? nextStep;
  final CashierSessionModel? session;

  UnitEnterResult({
    required this.status,
    required this.message,
    this.sessionCreated = false,
    this.restoredPendingHandover = false,
    this.bookingActorUserId,
    this.guestParentId,
    this.nextStep,
    this.session,
  });

  // region Factory & Serialization
  factory UnitEnterResult.fromJson(Map<String, dynamic> json) {
    final rawActorId = json['booking_actor_user_id'];
    final int? actorId = rawActorId != null
        ? (rawActorId is int ? rawActorId : int.tryParse(rawActorId.toString()))
        : null;

    final rawParentId = json['guest_parent_id'];
    final int? parentId = rawParentId != null
        ? (rawParentId is int ? rawParentId : int.tryParse(rawParentId.toString()))
        : null;

    CashierSessionModel? sessionModel;
    if (json['data'] is Map) {
      sessionModel = CashierSessionModel.fromJson(Map<String, dynamic>.from(json['data']));
    }

    return UnitEnterResult(
      status: json['status'] == true || json['status'] == 'true',
      message: (json['message'] ?? '').toString(),
      sessionCreated: json['session_created'] == true || json['session_created'] == 'true',
      restoredPendingHandover: json['restored_pending_handover'] == true || json['restored_pending_handover'] == 'true',
      bookingActorUserId: actorId,
      guestParentId: parentId,
      nextStep: json['next_step']?.toString(),
      session: sessionModel,
    );
  }
  // endregion
}

class CartItemPayload {
  final String assignServiceId;
  final int serviceQuantity;
  final double price;
  final double totalPrice;

  CartItemPayload({
    required this.assignServiceId,
    required this.serviceQuantity,
    required this.price,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'Assign_Service_Id': assignServiceId,
      'service_quantity': serviceQuantity.toString(),
      'Price': price.toStringAsFixed(0),
      'Total_price': totalPrice.toStringAsFixed(0),
    };
  }
}

class BookingInitiateResult {
  final bool status;
  final String message;
  final String? bookingId;
  final String? encryptBookingId;
  final String? merchantTransactionId;
  final int? bookingActorUserId;
  final int? cashierSessionId;
  final int? guestParentId;
  final String? unitNo;
  final double? totalAmount;
  final String? paymentStatus;
  final int? paymentMode;
  final int? serviceType;
  final int? memStatus;
  final String? receiptUrl;
  final List<dynamic>? cart;
  final String? bookingTimeDate;
  final String? unitLocation;
  final String? fullAddress;
  final Map<String, dynamic>? rawJson;

  BookingInitiateResult({
    required this.status,
    required this.message,
    this.bookingId,
    this.encryptBookingId,
    this.merchantTransactionId,
    this.bookingActorUserId,
    this.cashierSessionId,
    this.guestParentId,
    this.unitNo,
    this.totalAmount,
    this.paymentStatus,
    this.paymentMode,
    this.serviceType,
    this.memStatus,
    this.receiptUrl,
    this.cart,
    this.bookingTimeDate,
    this.unitLocation,
    this.fullAddress,
    this.rawJson,
  });

  BookingDetailsModel toBookingDetailsModel({
    List<BookingServiceDetailItem>? fallbackServices,
    String? fallbackLocation,
    String? fallbackAddress,
  }) {
    List<BookingServiceDetailItem> serviceItems = [];
    if (fallbackServices != null && fallbackServices.isNotEmpty) {
      serviceItems = fallbackServices;
    } else if (cart != null && cart!.isNotEmpty) {
      serviceItems = cart!.map((item) {
        if (item is Map<String, dynamic>) {
          return BookingServiceDetailItem.fromJson(item);
        } else if (item is Map) {
          return BookingServiceDetailItem.fromJson(Map<String, dynamic>.from(item));
        }
        return BookingServiceDetailItem();
      }).toList();
    }

    return BookingDetailsModel(
      bookingId: bookingId ?? '',
      unitNo: unitNo ?? '',
      bookingTimeDate: bookingTimeDate ?? DateTime.now().toString(),
      unitLocation: (unitLocation != null && unitLocation!.isNotEmpty)
          ? unitLocation!
          : (fallbackLocation ?? ''),
      totalAmount: (totalAmount != null ? totalAmount!.toStringAsFixed(0) : ''),
      serviceIcon: '',
      fullAddress: (fullAddress != null && fullAddress!.isNotEmpty)
          ? fullAddress!
          : ((fallbackAddress != null && fallbackAddress.isNotEmpty)
              ? fallbackAddress
              : (fallbackLocation ?? '')),
      services: serviceItems,
      paymentMode: paymentMode ?? 1,
      paymentStatus: paymentStatus ?? 'PAYMENT_SUCCESS',
      encryptBookingId: encryptBookingId,
    );
  }

  // region Factory & Serialization
  factory BookingInitiateResult.fromJson(Map<String, dynamic> json) {
    final rawActorId = json['booking_actor_user_id'];
    final int? actorId = rawActorId != null
        ? (rawActorId is int ? rawActorId : int.tryParse(rawActorId.toString()))
        : null;

    final rawSessionId = json['cashier_session_id'];
    final int? sessionId = rawSessionId != null
        ? (rawSessionId is int ? rawSessionId : int.tryParse(rawSessionId.toString()))
        : null;

    final rawParentId = json['guest_parent_id'];
    final int? parentId = rawParentId != null
        ? (rawParentId is int ? rawParentId : int.tryParse(rawParentId.toString()))
        : null;

    final rawTotal = json['total_amount'];
    final double? total = rawTotal != null
        ? (rawTotal is num ? rawTotal.toDouble() : double.tryParse(rawTotal.toString()))
        : null;

    return BookingInitiateResult(
      status: json['status'] == true || json['status'] == 'true',
      message: (json['message'] ?? '').toString(),
      bookingId: json['booking_id']?.toString(),
      encryptBookingId: json['encrypt_booking_id']?.toString(),
      merchantTransactionId: json['merchant_transaction_id']?.toString(),
      bookingActorUserId: actorId,
      cashierSessionId: sessionId,
      guestParentId: parentId,
      unitNo: json['Unit_no']?.toString(),
      totalAmount: total,
      paymentStatus: json['Payment_status']?.toString(),
      paymentMode: json['payment_mode'] is int
          ? json['payment_mode'] as int
          : int.tryParse(json['payment_mode']?.toString() ?? ''),
      serviceType: json['service_type'] is int
          ? json['service_type'] as int
          : int.tryParse(json['service_type']?.toString() ?? ''),
      memStatus: json['mem_status'] is int
          ? json['mem_status'] as int
          : int.tryParse(json['mem_status']?.toString() ?? ''),
      receiptUrl: json['receipt_url']?.toString(),
      cart: json['cart'] is List ? (json['cart'] as List) : null,
      bookingTimeDate: json['booking_time_date']?.toString() ??
          json['created_at']?.toString(),
      unitLocation: (json['unit_location'] ??
              json['Unit_location'] ??
              json['location'] ??
              json['full_add'] ??
              '')
          .toString(),
      fullAddress: json['fullAddress']?.toString() ??
          json['full_address']?.toString() ??
          json['unit_location']?.toString(),
      rawJson: json,
    );
  }
  // endregion
}

class BookingPaymentSuccessResult {
  final bool status;
  final String message;
  final String? bookingId;
  final String? paymentStatus;
  final int? paymentMode;
  final String? paymentStatusSource;
  final bool paymentVerifiedByGateway;
  final String? providerReferenceId;
  final int? cashierId;
  final int? cashierSessionId;
  final String? receiptUrl;

  BookingPaymentSuccessResult({
    required this.status,
    required this.message,
    this.bookingId,
    this.paymentStatus,
    this.paymentMode,
    this.paymentStatusSource,
    this.paymentVerifiedByGateway = false,
    this.providerReferenceId,
    this.cashierId,
    this.cashierSessionId,
    this.receiptUrl,
  });

  // region Factory & Serialization
  factory BookingPaymentSuccessResult.fromJson(Map<String, dynamic> json) {
    return BookingPaymentSuccessResult(
      status: json['status'] == true || json['status'] == 'true',
      message: (json['message'] ?? '').toString(),
      bookingId: json['booking_id']?.toString(),
      paymentStatus: json['Payment_status']?.toString(),
      paymentMode: json['payment_mode'] is int
          ? json['payment_mode'] as int
          : int.tryParse(json['payment_mode']?.toString() ?? ''),
      paymentStatusSource: json['payment_status_source']?.toString(),
      paymentVerifiedByGateway: json['payment_verified_by_gateway'] == true || json['payment_verified_by_gateway'] == 'true',
      providerReferenceId: json['provider_reference_id']?.toString(),
      cashierId: json['cashier_id'] is int
          ? json['cashier_id'] as int
          : int.tryParse(json['cashier_id']?.toString() ?? ''),
      cashierSessionId: json['cashier_session_id'] is int
          ? json['cashier_session_id'] as int
          : int.tryParse(json['cashier_session_id']?.toString() ?? ''),
      receiptUrl: json['receipt_url']?.toString(),
    );
  }
  // endregion
}
// endregion
