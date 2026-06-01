import 'dart:convert';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mfresh/data/models/booking_details_model.dart';
import 'package:mfresh/core/utils/print_util.dart';
import 'package:core/constants/app_images.dart';
import 'package:mfresh/routes/app_routes.dart';

class PrintReceiptScreen extends StatelessWidget {
  final BookingDetailsModel booking;
  final String? encryptedBookingId;
  final int rollSize;

  const PrintReceiptScreen({
    super.key,
    required this.booking,
    this.encryptedBookingId,
    this.rollSize = 58,
  });

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy hh:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildReceiptCard(ServiceItem service) {
    return Center(
      child: Container(
        width: 300.w,
        margin: EdgeInsets.only(bottom: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Thermal Paper Top
            Container(
              height: 10.h,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE0E0E0), Colors.white],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 4.h),
              child: Column(
                children: [
                  // Logo
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      AppImages.mFreshLogo,
                      width: 120.w,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint("Receipt Preview Logo Load Error: $error");
                        return Text(
                          'mFresh',
                          style: AppTextStyle.style_24_600(
                            color: const Color(0xFFF15A22),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Unit Info
                  _buildLeftAlignedRow(
                    'Unit No.: ${booking.unitNo}',
                    isBold: true,
                  ),
                  _buildLeftAlignedRow('Location: ${booking.fullAddress}'),
                  _buildDivider(),

                  // Booking Details
                  _buildLeftAlignedRow('Booking ID: ${booking.bookingId}'),
                  _buildLeftAlignedRow(
                    'Date & Time: ${_formatDate(booking.bookingTimeDate)}',
                  ),
                  _buildLeftAlignedRow(
                    'Payment: ${booking.paymentMode == 1
                        ? 'CASH'
                        : booking.paymentMode == 2
                        ? 'UPI'
                        : 'QR'}',
                  ),
                  _buildDivider(),

                  // Service specific to this receipt
                  _buildLeftAlignedRow(
                    '${service.servicesName} (QTY: 1)',
                    isBold: true,
                  ),
                  _buildLeftAlignedRow('Unit Price: ₹ ${service.price}'),

                  _buildDivider(),

                  // Total for THIS receipt
                  _buildLeftAlignedRow(
                    'TOTAL AMOUNT: ₹ ${service.price}',
                    isBold: true,
                    fontSize: 16,
                  ),
                  const SizedBox(height: 20),

                  // QR Code
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SCAN AT UNIT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Image.network(
                            'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${Uri.encodeComponent(jsonEncode({"BookingID": encryptedBookingId ?? booking.bookingId, "DeviceID": 'NA', "AccessDate": booking.bookingTimeDate}))}',
                            width: 120.w,
                            height: 120.w,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.qr_code, size: 100),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Thank you for using mFresh!',
                    style: TextStyle(fontSize: 9, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '--------------------------------',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Thermal Paper Bottom
            SizedBox(
              height: 8.h,
              width: double.infinity,
              child: _buildDashedLine(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Share Receipt'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black),
            onPressed: () => Get.toNamed(AppRoutes.bookingHistory),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  ...booking.services.expand((service) {
                    final qty = int.tryParse(service.quantity) ?? 1;
                    return List.generate(
                      qty,
                      (index) => _buildReceiptCard(service),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: const BorderSide(color: Color(0xFFF15A22)),
                      foregroundColor: const Color(0xFFF15A22),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      PrintUtil.shareSystem(
                        booking,
                        encryptedBookingId,
                        rollSize: rollSize,
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share Now'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      backgroundColor: const Color(0xFFF15A22),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftAlignedRow(
    String text, {
    bool isBold = false,
    double fontSize = 12,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: const Text(
        '--------------------------------',
        style: TextStyle(fontFamily: 'monospace', color: Colors.grey),
      ),
    );
  }

  Widget _buildDashedLine() {
    return SizedBox(
      height: 1,
      child: Row(
        children: List.generate(
          150,
          (index) => Expanded(
            child: Container(
              color: index % 2 == 0 ? Colors.transparent : Colors.grey.shade300,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
