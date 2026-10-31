class BookingHistoryModel {
  final String bookingId;
  final String encryptBookingId;
  final String unitNo;
  final String createdAt;
  final String totalAmount;
  final int paymentMode;

  BookingHistoryModel({
    required this.bookingId,
    required this.encryptBookingId,
    required this.unitNo,
    required this.createdAt,
    required this.totalAmount,
    required this.paymentMode,
  });

  factory BookingHistoryModel.fromJson(Map<String, dynamic> json) {
    return BookingHistoryModel(
      bookingId: json['booking_id'] ?? '',
      encryptBookingId: json['encrypt_booking_id'] ?? '',
      unitNo: json['unit_no'] ?? '',
      createdAt: json['created_at'] ?? '',
      totalAmount: json['total_amount'] ?? '',
      paymentMode: json['payment_mode'] ?? 0,
    );
  }
}
