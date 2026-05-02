import 'dart:convert';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mfresh/modules/booking/controllers/booking_details_controller.dart';
import 'package:mfresh/data/models/booking_details_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:services/plutus_service.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh/routes/app_routes.dart';

class BookingConfirmedScreen extends StatefulWidget {
  const BookingConfirmedScreen({super.key});

  @override
  State<BookingConfirmedScreen> createState() => _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends State<BookingConfirmedScreen> {
  final controller = Get.put(BookingDetailsController());
  final plutusService = Get.find<PlutusService>();

  @override
  void initState() {
    super.initState();
    // Assuming bookingId is passed via Get.arguments or parameters
    final String? bookingId = Get.arguments?['bookingId'] ?? Get.parameters['bookingId'];
    if (bookingId != null) {
      controller.fetchBookingDetails(bookingId);
    }
  }

  Future<void> _handlePrint(BookingDetailsModel booking) async {
    try {
      for (var service in booking.services) {
        int repeatCount = int.tryParse(service.quantity) ?? 1;

        for (int i = 0; i < repeatCount; i++) {
          Map<String, dynamic> printDataForService = _buildPrintDataForService(booking, service);
          final printDataJson = jsonEncode(printDataForService);
          await plutusService.startPrintJob(printDataJson);
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    } catch (e) {
      AppCommonToastMessage.show(message: 'Printing failed: $e', type: ToastType.error);
    }
  }

  Map<String, dynamic> _buildPrintDataForService(BookingDetailsModel booking, ServiceItem service) {
    Map<String, dynamic> header = {
      "ApplicationId": "6458835ce3374a60af722c4d51f2ba8f",
      "UserId": "user1234",
      "MethodId": "1002",
      "VersionNo": "1.0",
    };

    List<Map<String, dynamic>> printItems = [];

    // Title
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": true, "DataToPrint": "Booking Confirmation", "ImagePath": "0", "ImageData": "0"});
    // Booking ID
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Booking ID: ${booking.bookingId}", "ImagePath": "0", "ImageData": "0"});
    // Unit No.
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Unit No.: ${booking.unitNo}", "ImagePath": "0", "ImageData": "0"});
    // Amount Paid
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Amount Paid: Rs. ${booking.totalAmount}", "ImagePath": "0", "ImageData": "0"});
    // Date & Time
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Date & Time: ${formatBookingDate(booking.bookingTimeDate)}", "ImagePath": "0", "ImageData": "0"});
    // Payment Mode
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Payment Mode: ${booking.paymentMode == 3 ? 'External QR' : booking.paymentMode == 2 ? 'Online' : 'Cash'}", "ImagePath": "0", "ImageData": "0"});
    // Separator
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": true, "DataToPrint": "------------------------", "ImagePath": "0", "ImageData": "0"});
    // Service Name
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Service: ${service.servicesName} x${service.quantity}", "ImagePath": "0", "ImageData": "0"});
    // Location
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": false, "DataToPrint": "Location: ${booking.fullAddress}", "ImagePath": "0", "ImageData": "0"});
    // QR Section Title
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": true, "DataToPrint": "Scan QR at Unit", "ImagePath": "0", "ImageData": "0"});

    // QR Code
    printItems.add({
      "PrintDataType": "4",
      "PrinterWidth": 24,
      "IsCenterAligned": true,
      "DataToPrint": jsonEncode({
        "BookingID": Get.arguments?['encryptBookingId'] ?? booking.bookingId,
        "DeviceID": "NA",
        "AccessDate": formatDate(booking.bookingTimeDate),
      }),
      "ImagePath": "",
      "ImageData": ""
    });

    for (int i = 0; i < 2; i++) {
      printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": true, "DataToPrint": " ", "ImagePath": "0", "ImageData": "0"});
    }

    // Thank You
    printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": true, "DataToPrint": "Thank You!", "ImagePath": "0", "ImageData": "0"});

    for (int i = 0; i < 4; i++) {
      printItems.add({"PrintDataType": "0", "PrinterWidth": 24, "IsCenterAligned": true, "DataToPrint": " ", "ImagePath": "0", "ImageData": "0"});
    }

    return {
      "Header": header,
      "Detail": {
        "PrintRefNo": booking.bookingId,
        "SavePrintData": false,
        "Data": printItems
      }
    };
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
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Column(
            children: [
              // Success Icon & Message
              Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 60.sp),
                    SizedBox(height: 8.h),
                    Text(
                      'Payment Successful!',
                      style: AppTextStyle.style_18_600(color: Colors.green),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Your booking has been confirmed.',
                      style: AppTextStyle.style_12_400(color: AppColors.grey300),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Main Ticket Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: AppColors.appCardDecoration(
                  borderColor: AppColors.grey50,
                  containerColor: AppColors.white,
                  borderRadius: 16,
                  isShadow: true,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Unit & Services
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Unit No: ${booking.unitNo}',
                                style: AppTextStyle.style_16_600(color: AppColors.black),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'SERVICES:',
                                style: AppTextStyle.style_10_600(color: AppColors.grey300),
                              ),
                              SizedBox(height: 4.h),
                              ...booking.services.map((service) => Padding(
                                padding: EdgeInsets.only(bottom: 2.h),
                                child: Text(
                                  '• ${service.servicesName} x ${service.quantity}',
                                  style: AppTextStyle.style_12_500(color: AppColors.black),
                                ),
                              )),
                            ],
                          ),
                        ),
                        Container(
                          width: 80.w,
                          height: 80.w,
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF15A22),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Image.asset(
                            'assets/images/urinal_female.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.image, size: 40.sp, color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                    
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Divider(color: AppColors.grey50, thickness: 1),
                    ),

                    // Location
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red, size: 16.sp),
                        SizedBox(width: 4.w),
                        Text(
                          'Location',
                          style: AppTextStyle.style_10_600(color: AppColors.grey300),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      booking.fullAddress,
                      style: AppTextStyle.style_12_400(color: AppColors.black),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'Get Directions',
                            style: AppTextStyle.style_10_600(color: AppColors.primary, isUnderline: true),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),
                    
                    // QR Section Label
                    Center(
                      child: Text(
                        'SCAN QR AT UNIT',
                        style: AppTextStyle.style_10_600(color: AppColors.grey300, spacing: 2),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Amount & QR Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Amount Paid',
                                style: AppTextStyle.style_10_400(color: AppColors.grey300),
                              ),
                              Text(
                                '₹ ${booking.totalAmount}',
                                style: AppTextStyle.style_20_600(color: AppColors.black),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'Booking ID',
                                style: AppTextStyle.style_10_400(color: AppColors.grey300),
                              ),
                              Text(
                                booking.bookingId,
                                style: AppTextStyle.style_12_600(color: AppColors.primary),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                formatBookingDate(booking.bookingTimeDate),
                                style: AppTextStyle.style_10_400(color: AppColors.grey300),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey50),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: QrImageView(
                            data: jsonEncode({
                              "BookingID": Get.arguments?['encryptBookingId'] ?? booking.bookingId,
                              "DeviceID": 'NA',
                              "AccessDate": formatDate(booking.bookingTimeDate),
                            }),
                            version: QrVersions.auto,
                            size: 100.w,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Bottom Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _handlePrint(booking),
                            icon: Icon(Icons.print, size: 18.sp),
                            label: const Text('Print Ticket'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                              elevation: 0,
                            ),
                            child: const Text('Back to Home'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              
              // T&C Link
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Terms & Conditions Apply',
                    style: AppTextStyle.style_10_400(color: AppColors.grey300, isUnderline: true),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      }),
    );
  }
}
