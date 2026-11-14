// region Models
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

  // region Factory & Serialization
  factory BookingHistoryModel.fromJson(Map<String, dynamic> json) {
    return BookingHistoryModel(
      bookingId: json['booking_id']?.toString() ?? '',
      encryptBookingId: json['encrypt_booking_id']?.toString() ?? '',
      unitNo: json['unit_no']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      totalAmount: json['total_amount']?.toString() ?? '',
      paymentMode: int.tryParse(json['payment_mode']?.toString() ?? '') ?? 0,
    );
  }
  // endregion
}
// endregion
