import 'dart:convert';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mfresh/modules/booking/controllers/booking_details_controller.dart';
import 'package:mfresh/modules/profile/controllers/profile_controller.dart';
import 'package:mfresh/data/models/booking_details_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:services/plutus_service.dart';
import 'package:mfresh/routes/app_routes.dart';
import 'package:mfresh/core/utils/print_util.dart';

class BookingConfirmedScreen extends StatefulWidget {
  const BookingConfirmedScreen({super.key});

  @override
  State<BookingConfirmedScreen> createState() => _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends State<BookingConfirmedScreen> {
  final controller = Get.put(BookingDetailsController());
  final plutusService = Get.find<PlutusService>();
  final profileController = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    final String? bookingId = Get.arguments?['bookingId'] ?? Get.parameters['bookingId'];
    if (bookingId != null) {
      controller.fetchBookingDetails(bookingId);
    }
  }

  Future<void> _handlePrint(BookingDetailsModel booking) async {
    PrintUtil.showPrintSelectionDialog(
      context: context,
      booking: booking,
      encryptedBookingId: Get.arguments?['encryptBookingId'],
    );
  }

  String formatBookingDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy hh:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(date.toLocal());
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Booking Confirmed'),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final booking = controller.bookingDetails.value;
        if (booking == null) {
          return const Center(child: Text("No booking details available"));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            children: [
              // Main Ticket Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: AppColors.appCardDecoration(
                  borderColor: AppColors.grey50.withValues(alpha: 0.5),
                  containerColor: AppColors.white,
                  borderRadius: 24,
                  isShadow: true,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Unit & Services Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Unit No.: ${booking.unitNo}',
                                style: AppTextStyle.style_14_600(color: AppColors.grey400),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'SERVICES:',
                                style: AppTextStyle.style_10_600(color: AppColors.grey300),
                              ),
                              SizedBox(height: 4.h),
                              ...booking.services.map((service) => Padding(
                                    padding: EdgeInsets.only(bottom: 2.h),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${service.servicesName} : ',
                                            style: AppTextStyle.style_11_400(color: AppColors.grey400),
                                          ),
                                          TextSpan(
                                            text: service.quantity.toString(),
                                            style: AppTextStyle.style_11_700(color: AppColors.grey400),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        // Orange Icon Box
                        Container(
                          width: 100.w,
                          height: 100.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF15A22),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/toilet.png',
                              width: 70.w,
                              height: 70.w,
                              color: AppColors.white,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.wc, size: 50.sp, color: AppColors.white),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Location Section
                    Text(
                      'Location',
                      style: AppTextStyle.style_10_400(color: AppColors.grey200),
                    ),
                    Text(
                      booking.fullAddress,
                      style: AppTextStyle.style_13_600(color: AppColors.black),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          'View Address',
                          style: AppTextStyle.style_10_600(color: const Color(0xFFF15A22)),
                        ),
                        SizedBox(width: 12.w),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.navigation, color: const Color(0xFFF15A22), size: 10.sp),
                            SizedBox(width: 2.w),
                            Text(
                              'Get Direction',
                              style: AppTextStyle.style_10_600(color: const Color(0xFFF15A22)),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Dashed Divider with text
                    Row(
                      children: [
                        Expanded(child: _buildDashedLine()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Text(
                            'SCAN QR AT UNIT',
                            style: AppTextStyle.style_8_600(color: AppColors.grey200, spacing: 1),
                          ),
                        ),
                        Expanded(child: _buildDashedLine()),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Bottom Section: Details & QR
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Amount Paid : ',
                                      style: AppTextStyle.style_12_400(color: AppColors.grey300),
                                    ),
                                    TextSpan(
                                      text: '₹ ${booking.totalAmount}',
                                      style: AppTextStyle.style_12_600(color: AppColors.grey400),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12.h),
                              _buildDetailRow('Booking ID', booking.bookingId),
                              _buildDetailRow('Booking Date & Time', formatBookingDate(booking.bookingTimeDate).toUpperCase()),
                              _buildDetailRow('Payment method', booking.paymentMode == 1 ? 'CASH' : booking.paymentMode == 2 ? 'UPI' : 'EXTERNAL QR'),
                              
                              SizedBox(height: 16.h),
                              
                              // Footer links
                              Row(
                                children: [
                                  Text(
                                    'Payment details',
                                    style: AppTextStyle.style_10_600(color: const Color(0xFFF15A22), isUnderline: true),
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    'T&C',
                                    style: AppTextStyle.style_10_600(color: AppColors.grey300, isUnderline: true),
                                  ),
                                  SizedBox(width: 8.w),
                                  Icon(Icons.share, color: AppColors.grey300, size: 14.sp),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                        GestureDetector(
                          onTap: () {
                            Get.dialog(
                              Dialog(
                                backgroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                                child: Padding(
                                  padding: EdgeInsets.all(20.w),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Scan QR at Unit',
                                        style: AppTextStyle.style_14_600(color: AppColors.black),
                                      ),
                                      SizedBox(height: 16.h),
                                      QrImageView(
                                        data: jsonEncode({
                                          "BookingID": Get.arguments?['encryptBookingId'] ?? booking.bookingId,
                                          "DeviceID": 'NA',
                                          "AccessDate": formatDate(booking.bookingTimeDate),
                                        }),
                                        version: QrVersions.auto,
                                        size: 250.w,
                                      ),
                                      SizedBox(height: 16.h),
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: Text(
                                          'Close',
                                          style: AppTextStyle.style_12_600(color: const Color(0xFFF15A22)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.grey50),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: QrImageView(
                              data: jsonEncode({
                                "BookingID": Get.arguments?['encryptBookingId'] ?? booking.bookingId,
                                "DeviceID": 'NA',
                                "AccessDate": formatDate(booking.bookingTimeDate),
                              }),
                              version: QrVersions.auto,
                              size: 80.w,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                            SizedBox(height: 4.h),
                            GestureDetector(
                              onTap: () => _handlePrint(booking),
                              child: Text(
                                'Print',
                                style: AppTextStyle.style_10_600(color: const Color(0xFF1A9FD9), isUnderline: true),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: AppTextStyle.style_10_400(color: AppColors.grey200),
            ),
            TextSpan(
              text: value,
              style: AppTextStyle.style_10_600(color: AppColors.grey300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 3.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: AppColors.grey200),
              ),
            );
          }),
        );
      },
    );
  }
}
