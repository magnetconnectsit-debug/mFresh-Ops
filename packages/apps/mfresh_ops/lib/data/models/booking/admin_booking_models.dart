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

class RecentBookingItemModel {
  final String bookingId;
  final String? encryptBookingId;
  final String? bookingTimeDate;
  final String? customerName;
  final String? customerPhone;
  final double totalAmount;
  final int paymentMode;
  final String paymentStatus;
  final String? receiptUrl;
  final List<BookingServiceDetailItem> services;

  RecentBookingItemModel({
    required this.bookingId,
    this.encryptBookingId,
    this.bookingTimeDate,
    this.customerName,
    this.customerPhone,
    required this.totalAmount,
    required this.paymentMode,
    required this.paymentStatus,
    this.receiptUrl,
    this.services = const [],
  });

  // region Factory & Serialization
  factory RecentBookingItemModel.fromJson(Map<String, dynamic> json) {
    final rawTotal = json['total_amount'] ?? json['Total_price'] ?? json['amount'] ?? 0;
    final double total = rawTotal is num
        ? rawTotal.toDouble()
        : double.tryParse(rawTotal.toString()) ?? 0.0;

    final rawMode = json['payment_mode'];
    final int mode = rawMode is int
        ? rawMode
        : int.tryParse(rawMode?.toString() ?? '1') ?? 1;

    List<BookingServiceDetailItem> parsedServices = [];
    if (json['services'] is List) {
      parsedServices = (json['services'] as List)
          .map((e) => e is Map<String, dynamic>
              ? BookingServiceDetailItem.fromJson(e)
              : BookingServiceDetailItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } else if (json['cart'] is List) {
      parsedServices = (json['cart'] as List)
          .map((e) => e is Map<String, dynamic>
              ? BookingServiceDetailItem.fromJson(e)
              : BookingServiceDetailItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return RecentBookingItemModel(
      bookingId: (json['booking_id'] ?? json['BookingID'] ?? json['id'] ?? '').toString(),
      encryptBookingId: json['encrypt_booking_id']?.toString(),
      bookingTimeDate: json['booking_time_date']?.toString() ??
          json['created_at']?.toString() ??
          json['BookingTimeDate']?.toString(),
      customerName: json['User_name']?.toString() ?? json['customer_name']?.toString() ?? json['name']?.toString(),
      customerPhone: json['phone_no']?.toString() ?? json['customer_phone']?.toString() ?? json['mob']?.toString(),
      totalAmount: total,
      paymentMode: mode,
      paymentStatus: (json['Payment_status'] ?? json['payment_status'] ?? 'PAYMENT_SUCCESS').toString(),
      receiptUrl: json['receipt_url']?.toString(),
      services: parsedServices,
    );
  }

  BookingDetailsModel toBookingDetailsModel({String? unitNo, String? location}) {
    return BookingDetailsModel(
      bookingId: bookingId,
      unitNo: unitNo ?? '',
      bookingTimeDate: bookingTimeDate ?? DateTime.now().toString(),
      unitLocation: location ?? '',
      totalAmount: totalAmount.toStringAsFixed(0),
      serviceIcon: '',
      fullAddress: location ?? '',
      services: services,
      paymentMode: paymentMode,
      paymentStatus: paymentStatus,
      encryptBookingId: encryptBookingId,
    );
  }
  // endregion
}

class HandoverOverviewResult {
  final bool status;
  final String message;
  final double cashDue;
  final double cashBalance;
  final double totalShortage;
  final int? cashierSessionId;
  final String? unitId;
  final Map<String, dynamic>? rawJson;

  HandoverOverviewResult({
    required this.status,
    required this.message,
    this.cashDue = 0.0,
    this.cashBalance = 0.0,
    this.totalShortage = 0.0,
    this.cashierSessionId,
    this.unitId,
    this.rawJson,
  });

  // region Factory & Serialization
  factory HandoverOverviewResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map : json;
    final rawCashDue = data['cash_due'] ?? data['cashDue'] ?? 0;
    final rawBalance = data['cash_balance'] ?? data['cashBalance'] ?? 0;
    final rawShortage = data['total_shortage'] ?? data['shortages'] ?? 0;

    return HandoverOverviewResult(
      status: json['status'] == true || json['status'] == 'true',
      message: (json['message'] ?? '').toString(),
      cashDue: rawCashDue is num ? rawCashDue.toDouble() : double.tryParse(rawCashDue.toString()) ?? 0.0,
      cashBalance: rawBalance is num ? rawBalance.toDouble() : double.tryParse(rawBalance.toString()) ?? 0.0,
      totalShortage: rawShortage is num ? rawShortage.toDouble() : double.tryParse(rawShortage.toString()) ?? 0.0,
      cashierSessionId: json['session_id'] ?? data['session_id'],
      unitId: json['unit_id']?.toString() ?? data['unit_id']?.toString(),
      rawJson: json,
    );
  }
  // endregion
}

class CtodDateEntryModel {
  final String date;
  final double bookingCash;
  final double completedCtod;
  final double pendingCtod;
  final double remainingAmount;
  final double collectionActual;

  CtodDateEntryModel({
    required this.date,
    required this.bookingCash,
    required this.completedCtod,
    required this.pendingCtod,
    required this.remainingAmount,
    required this.collectionActual,
  });

  // region Factory & Serialization
  factory CtodDateEntryModel.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic val) {
      if (val is num) return val.toDouble();
      return double.tryParse(val?.toString() ?? '0') ?? 0.0;
    }

    return CtodDateEntryModel(
      date: (json['date'] ?? '').toString(),
      bookingCash: parseNum(json['booking_cash'] ?? json['bookingCash']),
      completedCtod: parseNum(json['completed_ctod'] ?? json['completedCtod']),
      pendingCtod: parseNum(json['pending_ctod'] ?? json['pendingCtod']),
      remainingAmount: parseNum(json['remaining_amount'] ?? json['remainingAmount']),
      collectionActual: parseNum(json['collection_actual'] ?? json['collectionActual']),
    );
  }
  // endregion
}

class HandoverCreateResult {
  final bool status;
  final String message;
  final int? handoverId;
  final String? handoverAction;
  final bool otpSent;

  HandoverCreateResult({
    required this.status,
    required this.message,
    this.handoverId,
    this.handoverAction,
    this.otpSent = false,
  });

  // region Factory & Serialization
  factory HandoverCreateResult.fromJson(Map<String, dynamic> json) {
    final rawId = json['handover_id'] ?? json['id'] ?? (json['data'] is Map ? json['data']['handover_id'] : null);
    final int? hId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');

    return HandoverCreateResult(
      status: json['status'] == true || json['status'] == 'true',
      message: (json['message'] ?? '').toString(),
      handoverId: hId,
      handoverAction: json['handover_action']?.toString(),
      otpSent: json['otp_sent'] == true || json['otp_sent'] == 'true' || json['status'] == true,
    );
  }
  // endregion
}

class HandoverVerifyOtpResult {
  final bool status;
  final String message;
  final bool handoverCompleted;
  final bool sessionClosed;
  final double? shortfall;
  final bool whatsappAlertTriggered;

  HandoverVerifyOtpResult({
    required this.status,
    required this.message,
    this.handoverCompleted = false,
    this.sessionClosed = false,
    this.shortfall,
    this.whatsappAlertTriggered = false,
  });

  // region Factory & Serialization
  factory HandoverVerifyOtpResult.fromJson(Map<String, dynamic> json) {
    final rawShortfall = json['shortfall'];
    final double? sf = rawShortfall != null
        ? (rawShortfall is num ? rawShortfall.toDouble() : double.tryParse(rawShortfall.toString()))
        : null;

    return HandoverVerifyOtpResult(
      status: json['status'] == true || json['status'] == 'true',
      message: (json['message'] ?? '').toString(),
      handoverCompleted: json['handover_completed'] == true || json['status'] == true,
      sessionClosed: json['session_closed'] == true || json['session_status'] == 'CLOSED',
      shortfall: sf,
      whatsappAlertTriggered: json['whatsapp_alert_triggered'] == true || json['whatsapp_alerts'] != null,
    );
  }
  // endregion
}


class MemberValidateResult {
  final bool isValid;
  final String status;
  final String? type;
  final String message;
  final int? customerId;
  final String? phone;
  final int? membershipId;
  final String? validTill;

  MemberValidateResult({
    required this.isValid,
    required this.status,
    this.type,
    required this.message,
    this.customerId,
    this.phone,
    this.membershipId,
    this.validTill,
  });

  factory MemberValidateResult.fromJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] ?? '').toString();
    final isValidStatus = statusStr == 'valid' || statusStr == 'success';
    final rawCustId = json['customer_id'];
    final rawMemId = json['membership_id'];

    return MemberValidateResult(
      isValid: isValidStatus,
      status: statusStr,
      type: json['type']?.toString(),
      message: (json['message'] ?? (isValidStatus ? 'Member is valid.' : 'Membership invalid or not found.')).toString(),
      customerId: rawCustId is int ? rawCustId : int.tryParse(rawCustId?.toString() ?? ''),
      phone: json['phone']?.toString(),
      membershipId: rawMemId is int ? rawMemId : int.tryParse(rawMemId?.toString() ?? ''),
      validTill: json['valid_till']?.toString(),
    );
  }
}

class MemberOtpSendResult {
  final bool isSuccess;
  final String status;
  final String message;

  MemberOtpSendResult({
    required this.isSuccess,
    required this.status,
    required this.message,
  });

  factory MemberOtpSendResult.fromJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] ?? '').toString();
    return MemberOtpSendResult(
      isSuccess: statusStr == 'success' || statusStr == 'true' || json['status'] == true,
      status: statusStr,
      message: (json['message'] ?? 'OTP sent successfully.').toString(),
    );
  }
}

class MemberOtpVerifyResult {
  final bool isVerified;
  final String status;
  final String message;

  MemberOtpVerifyResult({
    required this.isVerified,
    required this.status,
    required this.message,
  });

  factory MemberOtpVerifyResult.fromJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] ?? '').toString();
    final verified = json['verified'] == true || json['verified'] == 'true' || statusStr == 'success';
    return MemberOtpVerifyResult(
      isVerified: verified,
      status: statusStr,
      message: (json['message'] ?? (verified ? 'OTP verified successfully.' : 'Invalid OTP.')).toString(),
    );
  }
}

// endregion
