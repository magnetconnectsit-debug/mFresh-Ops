import 'package:mfresh_ops/data/models/assignee_model.dart';
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
    String? phone,
    String? addPhone,
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
      phone: phone,
      addPhone: addPhone,
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

  BookingDetailsModel toBookingDetailsModel({
    String? unitNo,
    String? location,
    String? phone,
    String? addPhone,
  }) {
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
      phone: phone,
      addPhone: addPhone,
    );
  }
  // endregion
}

// region Handover Models
class ReceivedCashEntry {
  final String senderName;
  final double amount;
  final String handoverCode;
  final String note;
  final String date;
  final String createdAt;
  final double? pendingFromReceivedCash;
  final String pendingNote;
  final int? handoverId;

  ReceivedCashEntry({
    required this.senderName,
    required this.amount,
    this.handoverCode = '',
    this.note = '',
    this.date = '',
    this.createdAt = '',
    this.pendingFromReceivedCash,
    this.pendingNote = '',
    this.handoverId,
  });

  // region Factory & Serialization
  factory ReceivedCashEntry.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'] ?? json['received_amount'] ?? json['cash_received'] ?? 0;
    final double amt = rawAmount is num
        ? rawAmount.toDouble()
        : double.tryParse(rawAmount?.toString() ?? '0') ?? 0.0;

    final sender = (json['sender_name'] ??
            json['received_from'] ??
            json['from_cashier'] ??
            json['cashier_name'] ??
            json['sender'] ??
            '')
        .toString();

    final code = (json['handover_code'] ??
            json['code'] ??
            json['reference_no'] ??
            json['hnd_code'] ??
            '')
        .toString();

    final note = (json['note'] ?? json['description'] ?? '').toString();

    final rawPending = json['pending_from_received_cash'] ??
        json['pending_received_cash'] ??
        json['pending_cash'];
    final double? pendingAmt = rawPending != null
        ? (rawPending is num ? rawPending.toDouble() : double.tryParse(rawPending.toString()))
        : null;

    String pNote = (json['pending_note'] ?? '').toString();
    if (pNote.isEmpty && pendingAmt != null && pendingAmt > 0) {
      pNote = 'Pending from received cash: ₹${pendingAmt.toStringAsFixed(2)}';
    } else if (pNote.isEmpty && note.toLowerCase().contains('pending')) {
      pNote = note;
    }

    final rawCreated = json['created_at'] ?? json['timestamp'] ?? json['date_time'] ?? json['time'] ?? '';
    final rawDate = json['date'] ?? json['collection_date'] ?? (rawCreated.toString().split(' ').first);

    return ReceivedCashEntry(
      senderName: sender,
      amount: amt,
      handoverCode: code,
      note: note,
      date: rawDate.toString(),
      createdAt: rawCreated.toString(),
      pendingFromReceivedCash: pendingAmt,
      pendingNote: pNote,
      handoverId: json['handover_id'] is int
          ? json['handover_id']
          : int.tryParse(json['handover_id']?.toString() ?? ''),
    );
  }
  // endregion
}

class HandoverCollectionGroup {
  final String date; // Formatted as "05-11-2026"
  final String rawDate; // Original e.g. "2026-11-05" or "05-11-2026"
  final bool hasOwnBookingCash;
  final bool ownCashInputRequired;
  final bool ownCashZeroAllowed;
  final double ownBookingCashDue;
  final double receivedCashPendingTotal;
  final List<ReceivedCashEntry> receivedItems;

  HandoverCollectionGroup({
    required this.date,
    required this.rawDate,
    this.hasOwnBookingCash = false,
    this.ownCashInputRequired = false,
    this.ownCashZeroAllowed = true,
    this.ownBookingCashDue = 0.0,
    this.receivedCashPendingTotal = 0.0,
    this.receivedItems = const [],
  });

  // region Factory & Serialization
  factory HandoverCollectionGroup.fromJson(Map<String, dynamic> json) {
    final rawDate = (json['date'] ?? json['collection_date'] ?? '').toString();
    final dispDate = HandoverOverviewResult.normalizeToDisplayDate(rawDate);
    final hasOwn = json['own_cash_input_required'] == true ||
        json['has_own_cash'] == true ||
        json['requires_own_cash'] == true ||
        json['show_own_cash'] == true ||
        json['is_pending_date'] == true ||
        json['has_booking_cash'] == true;

    final rawPendingTotal = json['received_cash_pending_total'];
    final double pendingTotal = rawPendingTotal is num
        ? rawPendingTotal.toDouble()
        : double.tryParse(rawPendingTotal?.toString() ?? '0') ?? 0.0;

    final rawItems = json['received_handovers'] ?? json['received_cash'] ?? json['items'] ?? [];
    final List<ReceivedCashEntry> items = [];
    if (rawItems is List) {
      for (var it in rawItems) {
        if (it is Map<String, dynamic>) {
          items.add(ReceivedCashEntry.fromJson(it));
        } else if (it is Map) {
          items.add(ReceivedCashEntry.fromJson(Map<String, dynamic>.from(it)));
        }
      }
    }

    final rawDue = json['own_booking_cash'] ?? json['booking_cash'] ?? json['own_cash_due'] ?? 0;
    final double due = rawDue is num ? rawDue.toDouble() : double.tryParse(rawDue.toString()) ?? 0.0;

    return HandoverCollectionGroup(
      date: dispDate,
      rawDate: rawDate,
      hasOwnBookingCash: hasOwn,
      ownCashInputRequired: json['own_cash_input_required'] == true,
      ownCashZeroAllowed: json['own_cash_zero_allowed'] != false,
      ownBookingCashDue: due,
      receivedCashPendingTotal: pendingTotal,
      receivedItems: items,
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
  final String? activeDate;
  final List<String> pendingDates;
  final List<ReceivedCashEntry> receivedHandovers;
  final List<HandoverCollectionGroup> collectionGroups;
  final double totalReceivedCash;
  final List<AssigneeModel> receivers;
  final List<AssigneeModel> ctodUsers;
  final String? actionCode;
  final String? pendingCashier;
  final String? pendingDate;
  final String? reason;
  final String cashMode;
  final Map<String, dynamic>? rawJson;

  HandoverOverviewResult({
    required this.status,
    required this.message,
    this.cashDue = 0.0,
    this.cashBalance = 0.0,
    this.totalShortage = 0.0,
    this.cashierSessionId,
    this.unitId,
    this.activeDate,
    this.pendingDates = const [],
    this.receivedHandovers = const [],
    this.collectionGroups = const [],
    this.totalReceivedCash = 0.0,
    this.receivers = const [],
    this.ctodUsers = const [],
    this.actionCode,
    this.pendingCashier,
    this.pendingDate,
    this.reason,
    this.cashMode = 'LEGACY',
    this.rawJson,
  });

  static String normalizeToDisplayDate(String rawDate) {
    final trimmed = rawDate.trim();
    if (trimmed.isEmpty) return '';
    // YYYY-MM-DD
    if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(trimmed)) {
      final parts = trimmed.split(' ')[0].split('-');
      return '${parts[2].padLeft(2, '0')}-${parts[1].padLeft(2, '0')}-${parts[0]}';
    }
    // DD-MM-YYYY
    if (RegExp(r'^\d{2}-\d{2}-\d{4}').hasMatch(trimmed)) {
      return trimmed.split(' ')[0];
    }
    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) {
      final d = parsed.day.toString().padLeft(2, '0');
      final m = parsed.month.toString().padLeft(2, '0');
      final y = parsed.year.toString();
      return '$d-$m-$y';
    }
    return trimmed;
  }

  static DateTime? parseDisplayDate(String dateStr) {
    try {
      final trimmed = dateStr.trim();
      if (RegExp(r'^\d{2}-\d{2}-\d{4}').hasMatch(trimmed)) {
        final p = trimmed.split('-');
        return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
      }
      if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(trimmed)) {
        final p = trimmed.split('-');
        return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
      }
    } catch (_) {}
    return DateTime.tryParse(dateStr);
  }

  // region Factory & Serialization
  factory HandoverOverviewResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map : json;
    final rawCashDue = data['cash_due'] ?? data['cashDue'] ?? 0;
    final rawBalance = data['cash_balance'] ?? data['cashBalance'] ?? 0;
    final rawShortage = data['total_shortage'] ?? data['shortages'] ?? 0;

    final dynamic handoverObj = json['handover'] ?? data['handover'];
    final Map? handoverMap = handoverObj is Map ? handoverObj : null;

    final dynamic ctodObj = json['ctod'] ?? data['ctod'];
    final Map? ctodMap = ctodObj is Map ? ctodObj : null;

    // Parse pending dates
    final rawPendingDates = data['pending_dates'] ?? json['pending_dates'];
    final List<String> pDates = [];
    if (rawPendingDates is List) {
      for (var d in rawPendingDates) {
        if (d != null) pDates.add(d.toString());
      }
    }

    // Parse received handovers and collection groups
    final List<ReceivedCashEntry> rHandovers = [];
    final List<HandoverCollectionGroup> cGroups = [];

    double totalReceived = 0.0;
    if (handoverMap != null) {
      final rawTotal = handoverMap['received_cash_pending_total'];
      if (rawTotal is num) {
        totalReceived = rawTotal.toDouble();
      } else if (rawTotal != null) {
        totalReceived = double.tryParse(rawTotal.toString()) ?? 0.0;
      }

      final rawHandoverDates = handoverMap['dates'];
      if (rawHandoverDates is List && rawHandoverDates.isNotEmpty) {
        for (var d in rawHandoverDates) {
          if (d is Map) {
            final dMap = Map<String, dynamic>.from(d);
            final rawDate = (dMap['collection_date'] ?? dMap['date'] ?? '').toString();
            final dispDate = normalizeToDisplayDate(rawDate);
            final bool hasOwn = dMap['own_cash_input_required'] == true ||
                dMap['has_own_cash'] == true ||
                dMap['requires_own_cash'] == true;

            final rawPendingTotal = dMap['received_cash_pending_total'];
            final double pendingTotal = rawPendingTotal is num
                ? rawPendingTotal.toDouble()
                : double.tryParse(rawPendingTotal?.toString() ?? '0') ?? 0.0;

            final rawSources = dMap['received_sources'] ?? dMap['received_handovers'] ?? dMap['items'] ?? [];
            final List<ReceivedCashEntry> items = [];
            if (rawSources is List) {
              for (int i = 0; i < rawSources.length; i++) {
                final s = rawSources[i];
                if (s is Map) {
                  final sMap = Map<String, dynamic>.from(s);
                  String? pNote;
                  if (i == rawSources.length - 1 && pendingTotal > 0) {
                    pNote = 'Pending from received cash: ₹${pendingTotal.toStringAsFixed(2)}';
                  }
                  final rawCreated = sMap['completed_at'] ?? sMap['created_at'] ?? sMap['timestamp'] ?? '';
                  final entry = ReceivedCashEntry(
                    senderName: (sMap['cashier_name'] ?? sMap['sender_name'] ?? sMap['sender'] ?? '').toString(),
                    amount: (sMap['received_amount'] ?? sMap['amount'] ?? 0) is num
                        ? (sMap['received_amount'] ?? sMap['amount'] as num).toDouble()
                        : double.tryParse((sMap['received_amount'] ?? sMap['amount']).toString()) ?? 0.0,
                    handoverCode: (sMap['handover_code'] ?? sMap['handover_id'] ?? '').toString(),
                    note: (sMap['note'] ?? '').toString(),
                    date: rawDate,
                    createdAt: rawCreated.toString(),
                    pendingFromReceivedCash: pendingTotal > 0 ? pendingTotal : null,
                    pendingNote: pNote ?? (sMap['pending_note']?.toString() ?? ''),
                    handoverId: sMap['handover_id'] is int
                        ? sMap['handover_id']
                        : int.tryParse(sMap['handover_id']?.toString() ?? ''),
                  );
                  items.add(entry);
                  rHandovers.add(entry);
                }
              }
            }

            final rawDue = dMap['own_booking_cash'] ?? dMap['own_cash_amount'] ?? 0;
            final double due = rawDue is num ? rawDue.toDouble() : double.tryParse(rawDue.toString()) ?? 0.0;

            cGroups.add(
              HandoverCollectionGroup(
                date: dispDate,
                rawDate: rawDate,
                hasOwnBookingCash: hasOwn,
                ownCashInputRequired: dMap['own_cash_input_required'] == true,
                ownCashZeroAllowed: dMap['own_cash_zero_allowed'] != false,
                ownBookingCashDue: due,
                receivedCashPendingTotal: pendingTotal,
                receivedItems: items,
              ),
            );
          }
        }
      }
    }

    // If cGroups is still empty, fallback to synthesize from pendingDates & receivedHandovers
    if (cGroups.isEmpty) {
      final rawReceived = data['received_handovers'] ??
          data['received_cash'] ??
          data['received_cash_entries'] ??
          json['received_handovers'];
      if (rawReceived is List) {
        for (var r in rawReceived) {
          if (r is Map<String, dynamic>) {
            rHandovers.add(ReceivedCashEntry.fromJson(r));
          } else if (r is Map) {
            rHandovers.add(ReceivedCashEntry.fromJson(Map<String, dynamic>.from(r)));
          }
        }
      }

      if (rHandovers.isEmpty && (data['received_from'] != null || data['received_amount'] != null)) {
        rHandovers.add(ReceivedCashEntry.fromJson(Map<String, dynamic>.from(data)));
      }

      final rawTotalReceived = data['total_received_cash'] ??
          data['received_amount'] ??
          data['total_received'];
      if (totalReceived == 0) {
        totalReceived = rawTotalReceived is num
            ? rawTotalReceived.toDouble()
            : double.tryParse(rawTotalReceived?.toString() ?? '0') ?? 0.0;
        if (totalReceived == 0 && rHandovers.isNotEmpty) {
          totalReceived = rHandovers.fold(0.0, (sum, item) => sum + item.amount);
        }
      }

      final rawCollections = data['collections'] ??
          data['collection_groups'] ??
          json['collections'];
      if (rawCollections is List && rawCollections.isNotEmpty) {
        for (var c in rawCollections) {
          if (c is Map<String, dynamic>) {
            cGroups.add(HandoverCollectionGroup.fromJson(c));
          } else if (c is Map) {
            cGroups.add(HandoverCollectionGroup.fromJson(Map<String, dynamic>.from(c)));
          }
        }
      }

      if (cGroups.isEmpty) {
        final Map<String, List<ReceivedCashEntry>> dateToItems = {};
        final Map<String, String> displayToRawDate = {};

        for (var entry in rHandovers) {
          final dDate = normalizeToDisplayDate(entry.date);
          if (dDate.isNotEmpty) {
            dateToItems.putIfAbsent(dDate, () => []).add(entry);
            displayToRawDate.putIfAbsent(dDate, () => entry.date);
          }
        }

        final Set<String> pendingDisplayDates = {};
        for (var pDate in pDates) {
          final dDate = normalizeToDisplayDate(pDate);
          if (dDate.isNotEmpty) {
            pendingDisplayDates.add(dDate);
            displayToRawDate.putIfAbsent(dDate, () => pDate);
          }
        }

        final activeDisp = normalizeToDisplayDate(
          (data['active_date'] ?? data['date'] ?? json['date'])?.toString() ?? '',
        );
        if (activeDisp.isNotEmpty) {
          pendingDisplayDates.add(activeDisp);
          displayToRawDate.putIfAbsent(activeDisp, () => (data['active_date'] ?? data['date'] ?? json['date']).toString());
        }

        final allDisplayDates = <String>{
          ...pendingDisplayDates,
          ...dateToItems.keys,
        }.toList();

        allDisplayDates.sort((a, b) {
          final da = parseDisplayDate(a);
          final db = parseDisplayDate(b);
          if (da != null && db != null) {
            return da.compareTo(db);
          }
          return a.compareTo(b);
        });

        for (var dDate in allDisplayDates) {
          final items = dateToItems[dDate] ?? [];
          final hasOwn = pendingDisplayDates.contains(dDate);
          cGroups.add(
            HandoverCollectionGroup(
              date: dDate,
              rawDate: displayToRawDate[dDate] ?? dDate,
              hasOwnBookingCash: hasOwn,
              receivedItems: items,
            ),
          );
        }
      }
    }

    // Parse receivers if present
    final rawReceivers = (handoverMap != null ? handoverMap['handover_users'] : null) ??
        data['receivers'] ??
        data['receiver_list'] ??
        data['handover_users'] ??
        json['receivers'];
    final List<AssigneeModel> recList = [];
    if (rawReceivers is List) {
      for (var u in rawReceivers) {
        if (u is Map<String, dynamic>) {
          recList.add(AssigneeModel.fromJson(u));
        } else if (u is Map) {
          recList.add(AssigneeModel.fromJson(Map<String, dynamic>.from(u)));
        }
      }
    }

    // Parse C-to-D users if present
    final List<AssigneeModel> cUsers = [];
    final rawCtodUsers = (ctodMap != null ? ctodMap['ctod_users'] : null) ??
        data['ctod_users'] ??
        json['ctod_users'];
    if (rawCtodUsers is List) {
      for (var u in rawCtodUsers) {
        if (u is Map<String, dynamic>) {
          cUsers.add(AssigneeModel.fromJson(u));
        } else if (u is Map) {
          cUsers.add(AssigneeModel.fromJson(Map<String, dynamic>.from(u)));
        }
      }
    }

    return HandoverOverviewResult(
      status: json['status'] == true || json['status'] == 'true',
      message: (json['message'] ?? data['message'] ?? '').toString(),
      cashDue: rawCashDue is num ? rawCashDue.toDouble() : double.tryParse(rawCashDue.toString()) ?? 0.0,
      cashBalance: rawBalance is num ? rawBalance.toDouble() : double.tryParse(rawBalance.toString()) ?? 0.0,
      totalShortage: rawShortage is num ? rawShortage.toDouble() : double.tryParse(rawShortage.toString()) ?? 0.0,
      cashierSessionId: json['session_id'] ?? data['session_id'],
      unitId: json['unit_id']?.toString() ?? data['unit_id']?.toString(),
      activeDate: (data['active_date'] ?? data['date'] ?? json['date'])?.toString(),
      pendingDates: pDates,
      receivedHandovers: rHandovers,
      collectionGroups: cGroups,
      totalReceivedCash: totalReceived,
      receivers: recList,
      ctodUsers: cUsers,
      actionCode: json['action']?.toString() ?? json['action_code']?.toString() ?? data['action']?.toString(),
      pendingCashier: (data['pending_cashier'] ?? json['pending_cashier'])?.toString(),
      pendingDate: (data['pending_date'] ?? json['pending_date'])?.toString(),
      reason: (data['reason'] ?? json['reason'])?.toString(),
      cashMode: (json['cash_mode'] ?? (handoverMap != null ? handoverMap['cash_mode'] : null) ?? data['cash_mode'])?.toString() ?? 'LEGACY',
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

class HandoverUsersResult {
  final bool status;
  final String message;
  final List<AssigneeModel> handoverUsers;
  final List<AssigneeModel> ctodUsers;

  HandoverUsersResult({
    required this.status,
    required this.message,
    this.handoverUsers = const [],
    this.ctodUsers = const [],
  });
}

class HandoverCreateResult {
  final bool status;
  final String message;
  final int? handoverId;
  final String? handoverAction;
  final bool otpSent;
  final String? actionCode;
  final String? pendingCashier;
  final String? pendingDate;
  final String? reason;

  HandoverCreateResult({
    required this.status,
    required this.message,
    this.handoverId,
    this.handoverAction,
    this.otpSent = false,
    this.actionCode,
    this.pendingCashier,
    this.pendingDate,
    this.reason,
  });

  // region Factory & Serialization
  factory HandoverCreateResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map : json;
    final rawId = json['handover_id'] ?? json['id'] ?? data['handover_id'] ?? data['id'];
    final int? hId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
    final action = (json['action'] ?? json['action_code'] ?? data['action'])?.toString();

    return HandoverCreateResult(
      status: json['status'] == true || json['status'] == 'true' || action == 'HANDOVER_OTP',
      message: (json['message'] ?? data['message'] ?? '').toString(),
      handoverId: hId,
      handoverAction: json['handover_action']?.toString() ?? data['handover_action']?.toString(),
      otpSent: json['otp_sent'] == true ||
          json['otp_sent'] == 'true' ||
          action == 'HANDOVER_OTP' ||
          json['status'] == true,
      actionCode: action,
      pendingCashier: (data['pending_cashier'] ?? json['pending_cashier'])?.toString(),
      pendingDate: (data['pending_date'] ?? json['pending_date'])?.toString(),
      reason: (data['reason'] ?? json['reason'])?.toString(),
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
  final String? actionCode;
  final String? pendingCashier;
  final String? pendingDate;
  final String? reason;

  HandoverVerifyOtpResult({
    required this.status,
    required this.message,
    this.handoverCompleted = false,
    this.sessionClosed = false,
    this.shortfall,
    this.whatsappAlertTriggered = false,
    this.actionCode,
    this.pendingCashier,
    this.pendingDate,
    this.reason,
  });

  bool get isHandoverCompleted =>
      actionCode == 'HANDOVER_COMPLETED' ||
      actionCode == 'ALREADY_COMPLETED' ||
      handoverCompleted;

  bool get isCtodCompleted => actionCode == 'CASH_C_TO_D_COMPLETED';
  bool get isAlreadyCompleted => actionCode == 'ALREADY_COMPLETED';
  bool get isInvalidOtp => actionCode == 'INVALID_OTP';
  bool get isOtpExpired => actionCode == 'OTP_EXPIRED';
  bool get isCtodPending => actionCode == 'CTOD_HANDOVER_PENDING';
  bool get isSessionNotActive => actionCode == 'SESSION_NOT_ACTIVE';

  // region Factory & Serialization
  factory HandoverVerifyOtpResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map : json;
    final rawShortfall = json['shortfall'] ?? data['shortfall'];
    final double? sf = rawShortfall != null
        ? (rawShortfall is num ? rawShortfall.toDouble() : double.tryParse(rawShortfall.toString()))
        : null;

    final action = (json['action'] ?? json['action_code'] ?? data['action'])?.toString();
    final bool completed = json['handover_completed'] == true ||
        json['status'] == true ||
        action == 'HANDOVER_COMPLETED' ||
        action == 'CASH_C_TO_D_COMPLETED' ||
        action == 'ALREADY_COMPLETED';

    final bool closed = json['session_closed'] == true ||
        json['session_status'] == 'CLOSED' ||
        action == 'HANDOVER_COMPLETED';

    return HandoverVerifyOtpResult(
      status: json['status'] == true || json['status'] == 'true' || completed,
      message: (json['message'] ?? data['message'] ?? '').toString(),
      handoverCompleted: completed,
      sessionClosed: closed,
      shortfall: sf,
      whatsappAlertTriggered: json['whatsapp_alert_triggered'] == true || json['whatsapp_alerts'] != null,
      actionCode: action,
      pendingCashier: (data['pending_cashier'] ?? json['pending_cashier'])?.toString(),
      pendingDate: (data['pending_date'] ?? json['pending_date'])?.toString(),
      reason: (data['reason'] ?? json['reason'])?.toString(),
    );
  }
  // endregion
}

class HandoverExitCheckResult {
  final bool status;
  final bool canExit;
  final String message;
  final double pendingAmount;
  final String? pendingCashier;
  final String? pendingDate;
  final String? reason;
  final String? actionCode;
  final Map<String, dynamic>? rawJson;

  HandoverExitCheckResult({
    required this.status,
    required this.canExit,
    required this.message,
    this.pendingAmount = 0.0,
    this.pendingCashier,
    this.pendingDate,
    this.reason,
    this.actionCode,
    this.rawJson,
  });

  // region Factory & Serialization
  factory HandoverExitCheckResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map : json;
    final isSuccess = json['status'] == true || json['status'] == 'success';
    final hasPending = data['pending_handover'] == true ||
        data['handover_pending'] == true ||
        data['pending'] == true ||
        json['action'] == 'CTOD_HANDOVER_PENDING' ||
        data['action'] == 'CTOD_HANDOVER_PENDING';
    final canExit = (data['can_exit'] == true || isSuccess) && !hasPending;

    final rawAmount = data['pending_amount'] ?? data['amount'] ?? data['cash_due'] ?? 0;
    final double pAmount = rawAmount is num
        ? rawAmount.toDouble()
        : double.tryParse(rawAmount?.toString() ?? '0') ?? 0.0;

    return HandoverExitCheckResult(
      status: isSuccess,
      canExit: canExit,
      message: (json['message'] ?? data['message'] ?? '').toString(),
      pendingAmount: pAmount,
      pendingCashier: data['pending_cashier']?.toString() ?? data['cashier_name']?.toString(),
      pendingDate: data['pending_date']?.toString() ?? data['date']?.toString(),
      reason: data['reason']?.toString(),
      actionCode: json['action']?.toString() ?? json['action_code']?.toString() ?? data['action']?.toString(),
      rawJson: json,
    );
  }
  // endregion
}
// endregion


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
