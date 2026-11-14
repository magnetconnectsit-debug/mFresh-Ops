// region Imports
import 'dart:convert';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mfresh_ops/modules/booking/controllers/booking_details_controller.dart';
import 'package:mfresh_ops/data/models/booking/booking_models.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:services/plutus_service.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/core/utils/print_util.dart';
import 'package:mfresh_ops/modules/profile/controllers/profile_controller.dart';
import 'package:services/storage_service.dart';
// endregion

// region View
class BookingConfirmedScreen extends StatefulWidget {
  const BookingConfirmedScreen({super.key});

  @override
  State<BookingConfirmedScreen> createState() => _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends State<BookingConfirmedScreen> {
  // region Dependencies & Controllers
  final controller = Get.put(BookingDetailsController());
  final plutusService = Get.find<PlutusService>();
  final profileController = Get.put(ProfileController());
  // endregion

  // region Lifecycle Methods
  @override
  void initState() {
    super.initState();
    final dynamic rawBooking = Get.arguments?['bookingModel'];
    if (rawBooking is BookingDetailsModel) {
      controller.setBookingDetails(
        rawBooking,
        pType: Get.arguments?['printingType']?.toString(),
        rSize: int.tryParse(Get.arguments?['paperRollSize']?.toString() ?? ''),
      );
    } else {
      final String? bookingId =
          Get.arguments?['bookingId'] ?? Get.parameters['bookingId'];
      if (bookingId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.fetchBookingDetails(
            bookingId,
            fallbackUnitNo: Get.arguments?['unitNo']?.toString(),
            fallbackAmount: Get.arguments?['totalAmount']?.toString(),
            encryptId: Get.arguments?['encryptBookingId']?.toString(),
            receiptUrl: Get.arguments?['receiptUrl']?.toString(),
          );
        });
      }
    }
  }
  // endregion

  // region Action Handlers & Helpers
  Future<void> _handlePrint(BookingDetailsModel booking) async {
    final encryptId =
        booking.encryptBookingId ??
        (Get.arguments?['encryptBookingId'] ??
            Get.parameters['encryptBookingId']);

    // Use values from controller as source of truth (fetched based on unitId)
    final int rollSize = controller.paperRollSize.value;
    final String pType = controller.printingType.value;

    debugPrint("Initiating Print Flow: Type=$pType, RollSize=$rollSize");

    if (pType == 'system') {
      // Direct System/PDF Print
      PrintUtil.printSystem(booking, encryptId, rollSize: rollSize);
    } else {
      // Direct Thermal: Try default first, fallback to selector
      PrintUtil.handleExternalPrint(
        context,
        booking,
        useDefault: true,
        rollSize: rollSize,
        encryptedBookingId: encryptId,
      );
    }
  }

  String formatBookingDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString).toLocal();
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
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Do nothing
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppCommonAppBar(
          title: Text(
            'Booking Confirmed',
            style: AppTextStyle.style_16_600(color: AppColors.black),
          ),
          backgroundColor: AppColors.background,
          elevation: 0,
          hasBackButton: true,
          onBackButtonPressed: () => Get.back(),
          actions: [
            IconButton(
              icon: const Icon(Icons.history, color: AppColors.black),
              onPressed: () => Get.toNamed(AppRoutes.bookingHistory),
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CustomAppLoader(size: 60));
                }

                final booking = controller.bookingDetails.value;
                if (booking == null) {
                  return const Center(
                    child: Text("No booking details available"),
                  );
                }

                return RefreshIndicator(
                  color: const Color(0xFFF15A22),
                  onRefresh: () async {
                    // Re-fetch everything to update permissions and printer config
                    await Future.wait([
                      controller.fetchBookingDetails(
                        controller.bookingDetails.value?.bookingId ?? "",
                      ),
                    ]);
                  },
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
                        child: Column(
                          children: [
                            // Main Ticket Card
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(20.w),
                              decoration: AppColors.appCardDecoration(
                                borderColor: AppColors.grey50.withValues(
                                  alpha: 0.5,
                                ),
                                containerColor: AppColors.white,
                                borderRadius: 24,
                                isShadow: true,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Unit & Services Row
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Unit No.: ${booking.unitNo}',
                                              style: AppTextStyle.style_14_600(
                                                color: AppColors.grey400,
                                              ),
                                            ),
                                            SizedBox(height: 12.h),
                                            Text(
                                              'SERVICES:',
                                              style: AppTextStyle.style_10_600(
                                                color: AppColors.grey300,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            ...booking.services.map(
                                              (service) => Padding(
                                                padding: EdgeInsets.only(
                                                  bottom: 2.h,
                                                ),
                                                child: RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            '${service.servicesName} : ',
                                                        style:
                                                            AppTextStyle.style_11_400(
                                                              color: AppColors
                                                                  .grey400,
                                                            ),
                                                      ),
                                                      TextSpan(
                                                        text: service.quantity
                                                            .toString(),
                                                        style:
                                                            AppTextStyle.style_11_700(
                                                              color: AppColors
                                                                  .grey400,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Orange Icon Box
                                      Container(
                                        width: 100.w,
                                        height: 100.w,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF15A22),
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            'assets/images/toilet.png',
                                            width: 70.w,
                                            height: 70.w,
                                            color: AppColors.white,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Icon(
                                                      Icons.wc,
                                                      size: 50.sp,
                                                      color: AppColors.white,
                                                    ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 16.h),

                                  // Location Section
                                  Text(
                                    'Location',
                                    style: AppTextStyle.style_10_400(
                                      color: AppColors.grey200,
                                    ),
                                  ),
                                  Text(
                                    booking.displayAddress,
                                    style: AppTextStyle.style_13_600(
                                      color: AppColors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    children: [
                                      Text(
                                        'View Address',
                                        style: AppTextStyle.style_10_600(
                                          color: const Color(0xFFF15A22),
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.navigation,
                                            color: const Color(0xFFF15A22),
                                            size: 10.sp,
                                          ),
                                          SizedBox(width: 2.w),
                                          Text(
                                            'Get Direction',
                                            style: AppTextStyle.style_10_600(
                                              color: const Color(0xFFF15A22),
                                            ),
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
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                        ),
                                        child: Text(
                                          'SCAN QR AT UNIT',
                                          style: AppTextStyle.style_8_600(
                                            color: AppColors.grey200,
                                            spacing: 1,
                                          ),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Amount Paid : ',
                                                    style:
                                                        AppTextStyle.style_12_400(
                                                          color:
                                                              AppColors.grey300,
                                                        ),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        '₹ ${booking.totalAmount}',
                                                    style:
                                                        AppTextStyle.style_12_600(
                                                          color:
                                                              AppColors.grey400,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 12.h),
                                            _buildDetailRow(
                                              'Booking ID',
                                              booking.bookingId,
                                            ),
                                            _buildDetailRow(
                                              'Booking Date & Time',
                                              formatBookingDate(
                                                booking.bookingTimeDate,
                                              ).toUpperCase(),
                                            ),
                                            _buildDetailRow(
                                              'Payment method',
                                              booking.paymentMode == 1
                                                  ? 'CASH'
                                                  : booking.paymentMode == 2
                                                  ? 'UPI'
                                                  : 'EXTERNAL QR',
                                            ),

                                            SizedBox(height: 16.h),

                                            // Footer links
                                            Wrap(
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              spacing: 8.w,
                                              runSpacing: 4.h,
                                              children: [
                                                Text(
                                                  'Payment details',
                                                  style:
                                                      AppTextStyle.style_10_600(
                                                        color: const Color(
                                                          0xFFF15A22,
                                                        ),
                                                        isUnderline: true,
                                                      ),
                                                ),
                                                Text(
                                                  'T&C',
                                                  style:
                                                      AppTextStyle.style_10_600(
                                                        color:
                                                            AppColors.grey300,
                                                        isUnderline: true,
                                                      ),
                                                ),
                                                Builder(
                                                  builder: (context) {
                                                    final String? receiptUrl =
                                                        Get.arguments?['receiptUrl']?.toString();
                                                    if (receiptUrl == null || receiptUrl.isEmpty) {
                                                      return const SizedBox.shrink();
                                                    }
                                                    return GestureDetector(
                                                      onTap: () async {
                                                        final uri = Uri.tryParse(receiptUrl);
                                                        if (uri != null && await canLaunchUrl(uri)) {
                                                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                                                        }
                                                      },
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.open_in_new,
                                                            size: 12.sp,
                                                            color: const Color(0xFFF15A22),
                                                          ),
                                                          SizedBox(width: 2.w),
                                                          Text(
                                                            'Receipt',
                                                            style: AppTextStyle.style_10_600(
                                                              color: const Color(0xFFF15A22),
                                                              isUnderline: true,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    final encryptId =
                                                        booking
                                                            .encryptBookingId ??
                                                        (Get.arguments?['encryptBookingId'] ??
                                                            Get.parameters['encryptBookingId']);
                                                    final int rollSize =
                                                        int.tryParse(
                                                          Get.arguments?['paperRollSize']
                                                                  ?.toString() ??
                                                              '58',
                                                        ) ??
                                                        58;
                                                    PrintUtil.shareSystem(
                                                      booking,
                                                      encryptId,
                                                      rollSize: rollSize,
                                                    );
                                                  },
                                                  child: Icon(
                                                    Icons.share,
                                                    color: const Color(
                                                      0xFFF15A22,
                                                    ),
                                                    size: 18.sp,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    final smsPhoneController =
                                                        TextEditingController();
                                                    Get.dialog(
                                                      Dialog(
                                                        backgroundColor:
                                                            AppColors.white,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20.r,
                                                              ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                20.w,
                                                              ),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                'Send Receipt via SMS',
                                                                style: AppTextStyle.style_14_600(
                                                                  color:
                                                                      AppColors
                                                                          .black,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 16.h,
                                                              ),
                                                              AppCommonTextField(
                                                                controller:
                                                                    smsPhoneController,
                                                                hintText:
                                                                    'Enter 10 digit phone number',
                                                                keyboardType:
                                                                    TextInputType
                                                                        .phone,
                                                                maxLength: 10,
                                                              ),
                                                              SizedBox(
                                                                height: 16.h,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Get.back(),
                                                                    child: Text(
                                                                      'Cancel',
                                                                      style: AppTextStyle.style_12_600(
                                                                        color: AppColors
                                                                            .grey300,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 8.w,
                                                                  ),
                                                                  AppCommonButton(
                                                                    text: 'Send',
                                                                    buttonColor:
                                                                        const Color(
                                                                          0xFFF15A22,
                                                                        ),
                                                                    textColor:
                                                                        AppColors
                                                                            .white,
                                                                    height: 36.h,
                                                                    borderRadius:
                                                                        8.r,
                                                                    textSize:
                                                                        12.sp,
                                                                    onPressed: () async {
                                                                      final phone = smsPhoneController
                                                                          .text
                                                                          .trim();
                                                                      if (phone
                                                                              .length ==
                                                                          10) {
                                                                        Get.back();
                                                                        await controller.sendSms(
                                                                          phone,
                                                                        );
                                                                      } else {
                                                                        AppCommonToastMessage.show(
                                                                          message:
                                                                              "Enter valid 10 digit number",
                                                                          type:
                                                                              ToastType.error,
                                                                        );
                                                                      }
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Icon(
                                                    Icons.sms_outlined,
                                                    color: const Color(
                                                      0xFFF15A22,
                                                    ),
                                                    size: 18.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Get.dialog(
                                                Dialog(
                                                  backgroundColor:
                                                      AppColors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20.r,
                                                        ),
                                                  ),
                                                  child: ConstrainedBox(
                                                    constraints:
                                                        const BoxConstraints(
                                                          maxWidth: 400,
                                                        ),
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                        20.w,
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            'Scan QR at Unit',
                                                            style:
                                                                AppTextStyle.style_14_600(
                                                                  color:
                                                                      AppColors
                                                                          .black,
                                                                ),
                                                          ),
                                                          SizedBox(
                                                            height: 16.h,
                                                          ),
                                                          QrImageView(
                                                            data: jsonEncode({
                                                              "BookingID":
                                                                  booking
                                                                      .encryptBookingId ??
                                                                  (Get.arguments?['encryptBookingId'] ??
                                                                      booking
                                                                          .bookingId),
                                                              "DeviceID": 'NA',
                                                              "AccessDate":
                                                                  formatDate(
                                                                    DateTime.now()
                                                                        .toString(),
                                                                  ),
                                                            }),
                                                            version:
                                                                QrVersions.auto,
                                                            size: 250.w,
                                                          ),
                                                          SizedBox(
                                                            height: 16.h,
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Get.back(),
                                                            child: Text(
                                                              'Close',
                                                              style: AppTextStyle.style_12_600(
                                                                color:
                                                                    const Color(
                                                                      0xFFF15A22,
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(4.w),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: AppColors.grey50,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                              child: QrImageView(
                                                data: jsonEncode({
                                                  "BookingID":
                                                      booking
                                                          .encryptBookingId ??
                                                      (Get.arguments?['encryptBookingId'] ??
                                                          booking.bookingId),
                                                  "DeviceID": 'NA',
                                                  "AccessDate": formatDate(
                                                    DateTime.now().toString(),
                                                  ),
                                                }),
                                                version: QrVersions.auto,
                                                size: 80.w,
                                                padding: EdgeInsets.zero,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 16.h),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        AppCommonButton(
                                          text: 'Reset Print',
                                          buttonColor: Colors.red.shade400,
                                          textColor: AppColors.white,
                                          height: 36.h,
                                          width: 120.w,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16.w,
                                            vertical: 8.h,
                                          ),
                                          borderRadius: 8.r,
                                          textSize: 12.sp,
                                          onPressed: () {
                                            Get.find<StorageService>()
                                                .clearDefaultPrinter();
                                            AppCommonToastMessage.show(
                                              message:
                                                  "Default printer cleared",
                                              type: ToastType.success,
                                            );
                                          },
                                        ),
                                        AppCommonButton(
                                          text: 'Print',
                                          buttonColor: const Color(0xFF1A9FD9),
                                          textColor: AppColors.white,
                                          height: 36.h,
                                          width: 120.w,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16.w,
                                            vertical: 8.h,
                                          ),
                                          borderRadius: 8.r,
                                          textSize: 12.sp,
                                          onPressed: () =>
                                              _handlePrint(booking),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

          ],
        ),
      ),
    );
  }
  // endregion

  // region Section Builders
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
  // endregion
}
// endregion
