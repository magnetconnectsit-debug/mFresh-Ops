// region Models
class BookingDetailsModel {
  final String bookingId;
  final String unitNo;
  final String bookingTimeDate;
  final String unitLocation;
  final String totalAmount;
  final String serviceIcon;
  final String fullAddress;
  final List<BookingServiceDetailItem> services;
  final int paymentMode;
  final String paymentStatus;
  final String? encryptBookingId;

  BookingDetailsModel({
    this.bookingId = '',
    this.unitNo = '',
    this.bookingTimeDate = '',
    this.unitLocation = '',
    this.totalAmount = '',
    this.serviceIcon = '',
    this.fullAddress = '',
    this.services = const [],
    this.paymentMode = 0,
    this.paymentStatus = '',
    this.encryptBookingId,
  });

  String get displayAddress {
    if (fullAddress.trim().isNotEmpty) return fullAddress.trim();
    if (unitLocation.trim().isNotEmpty) return unitLocation.trim();
    return 'Location not specified';
  }

  // region CopyWith
  BookingDetailsModel copyWith({
    String? bookingId,
    String? unitNo,
    String? bookingTimeDate,
    String? unitLocation,
    String? totalAmount,
    String? serviceIcon,
    String? fullAddress,
    List<BookingServiceDetailItem>? services,
    int? paymentMode,
    String? paymentStatus,
    String? encryptBookingId,
  }) {
    return BookingDetailsModel(
      bookingId: bookingId ?? this.bookingId,
      unitNo: unitNo ?? this.unitNo,
      bookingTimeDate: bookingTimeDate ?? this.bookingTimeDate,
      unitLocation: unitLocation ?? this.unitLocation,
      totalAmount: totalAmount ?? this.totalAmount,
      serviceIcon: serviceIcon ?? this.serviceIcon,
      fullAddress: fullAddress ?? this.fullAddress,
      services: services ?? this.services,
      paymentMode: paymentMode ?? this.paymentMode,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      encryptBookingId: encryptBookingId ?? this.encryptBookingId,
    );
  }
  // endregion

  // region Factory & Serialization
  factory BookingDetailsModel.fromJson(Map<String, dynamic> json) {
    return BookingDetailsModel(
      bookingId: json['booking_id']?.toString() ?? '',
      unitNo: json['unit_no']?.toString() ?? '',
      bookingTimeDate: json['booking_time_date']?.toString() ?? '',
      unitLocation: (json['unit_location'] ??
              json['Unit_location'] ??
              json['location'] ??
              json['full_add'] ??
              '')
          .toString(),
      totalAmount: json['total_amount']?.toString() ?? '',
      serviceIcon: json['service_icon']?.toString() ?? '',
      fullAddress: (json['fullAddress'] ??
              json['full_address'] ??
              json['unit_location'] ??
              json['Unit_location'] ??
              json['location'] ??
              json['address'] ??
              '')
          .toString(),
      services: json['services'] != null
          ? List<BookingServiceDetailItem>.from(
              json['services'].map((service) => BookingServiceDetailItem.fromJson(service)),
            )
          : [],
      paymentMode: int.tryParse(json['payment_mode']?.toString() ?? '') ?? 0,
      paymentStatus: json['payment_status']?.toString() ?? json['Payment_status']?.toString() ?? '',
      encryptBookingId: json['encrypt_booking_id']?.toString(),
    );
  }
  // endregion
}

class BookingServiceDetailItem {
  final String servicesName;
  final String quantity;
  final String price;

  BookingServiceDetailItem({
    this.servicesName = '',
    this.quantity = '',
    this.price = '',
  });

  // region CopyWith
  BookingServiceDetailItem copyWith({
    String? servicesName,
    String? quantity,
    String? price,
  }) {
    return BookingServiceDetailItem(
      servicesName: servicesName ?? this.servicesName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }
  // endregion

  // region Factory & Serialization
  factory BookingServiceDetailItem.fromJson(Map<String, dynamic> json) {
    return BookingServiceDetailItem(
      servicesName: (json['services_name'] ??
              json['Service_Name'] ??
              json['service_name'] ??
              json['serviceName'] ??
              json['name'] ??
              json['Service_name'] ??
              '')
          .toString(),
      quantity: (json['quantity'] ??
              json['service_quantity'] ??
              json['Quantity'] ??
              json['service_qty'] ??
              '1')
          .toString(),
      price: (json['price'] ??
              json['Price'] ??
              json['amount'] ??
              json['Amount'] ??
              json['service_price'] ??
              json['Service_Price'] ??
              json['Total_price'] ??
              json['total_price'] ??
              json['rate'] ??
              json['Rate'] ??
              '')
          .toString(),
    );
  }
  // endregion
}

/// Backward compatibility alias
typedef ServiceDetailItem = BookingServiceDetailItem;
// endregion
