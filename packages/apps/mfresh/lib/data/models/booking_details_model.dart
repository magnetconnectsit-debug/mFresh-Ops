class BookingDetailsModel {
  final String bookingId;
  final String unitNo;
  final String bookingTimeDate;
  final String unitLocation;
  final String totalAmount;
  final String serviceIcon;
  final String fullAddress;
  final List<ServiceItem> services;
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

  BookingDetailsModel copyWith({
    String? bookingId,
    String? unitNo,
    String? bookingTimeDate,
    String? unitLocation,
    String? totalAmount,
    String? serviceIcon,
    String? fullAddress,
    List<ServiceItem>? services,
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

  factory BookingDetailsModel.fromJson(Map<String, dynamic> json) {
    return BookingDetailsModel(
      bookingId: json['booking_id'] ?? '',
      unitNo: json['unit_no'] ?? '',
      bookingTimeDate: json['booking_time_date'] ?? '',
      unitLocation: json['unit_location'] ?? '',
      totalAmount: json['total_amount'] ?? '',
      serviceIcon: json['service_icon'] ?? '',
      fullAddress: json['fullAddress'] ?? '',
      services: json['services'] != null
          ? List<ServiceItem>.from(
              json['services'].map((service) => ServiceItem.fromJson(service)),
            )
          : [],
      paymentMode: int.tryParse(json['payment_mode']?.toString() ?? '') ?? 0,
      paymentStatus: json['payment_status'] ?? json['Payment_status'] ?? '',
      encryptBookingId: json['encrypt_booking_id']?.toString(),
    );
  }
}

class ServiceItem {
  final String servicesName;
  final String quantity;
  final String price;

  ServiceItem({
    this.servicesName = '',
    this.quantity = '',
    this.price = '',
  });

  ServiceItem copyWith({
    String? servicesName,
    String? quantity,
    String? price,
  }) {
    return ServiceItem(
      servicesName: servicesName ?? this.servicesName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      servicesName: (json['services_name'] ?? json['Service_Name'] ?? json['service_name'] ?? '').toString(),
      quantity: (json['quantity'] ?? json['service_quantity'] ?? json['Quantity'] ?? json['service_qty'] ?? '1').toString(),
      price: (json['price'] ?? json['Price'] ?? json['amount'] ?? json['Amount'] ?? json['service_price'] ?? json['Service_Price'] ?? json['Total_price'] ?? json['total_price'] ?? json['rate'] ?? json['Rate'] ?? '').toString(),
    );
  }
}
