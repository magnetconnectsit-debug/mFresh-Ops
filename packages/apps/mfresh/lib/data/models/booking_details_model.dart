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
  });

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
      paymentMode: json['payment_mode'] ?? 0,
    );
  }
}

class ServiceItem {
  final String servicesName;
  final String quantity;

  ServiceItem({
    this.servicesName = '',
    this.quantity = '',
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      servicesName: json['services_name'] ?? '',
      quantity: json['quantity']?.toString() ?? '',
    );
  }
}
