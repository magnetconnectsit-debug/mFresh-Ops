import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookingConfirmedScreen extends StatelessWidget {
  const BookingConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        title: const Text('Booking Confirmed'),
        hasBackButton: true,
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Details - Single Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: AppColors.appCardDecoration(
                borderColor: AppColors.grey50,
                containerColor: AppColors.white,
                borderRadius: 8,
                isShadow: true,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Unit Info + Image
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Unit No.: MM20240001',
                              style: AppTextStyle.style_12_600(color: AppColors.black),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'SERVICES:',
                              style: AppTextStyle.style_10_600(color: AppColors.black),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Urinal - Female : 3\nToilet - Male : 1\nToilet - Female : 2',
                              style: AppTextStyle.style_10_400(color: AppColors.grey300),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 90.w,
                        height: 90.w,
                        decoration: BoxDecoration(
                          color: AppColors.grey50,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.image, size: 40.sp, color: AppColors.grey200),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Location
                  Text(
                    'Location:',
                    style: AppTextStyle.style_10_600(color: AppColors.black),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'View Address',
                          style: AppTextStyle.style_10_600(color: AppColors.primary),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Get Direction',
                          style: AppTextStyle.style_10_600(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Scan QR at Unit divider
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.grey50, width: 1),
                        bottom: BorderSide(color: AppColors.grey50, width: 1),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'SCAN QR AT UNIT',
                        style: AppTextStyle.style_10_600(color: AppColors.grey300),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Amount Paid
                  Row(
                    children: [
                      Text(
                        'Amount Paid: ',
                        style: AppTextStyle.style_10_400(color: AppColors.black),
                      ),
                      Text(
                        '₹ 280',
                        style: AppTextStyle.style_12_600(color: AppColors.black),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Booking Details + QR Placeholder
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Booking Id: ',
                                    style: AppTextStyle.style_10_400(color: AppColors.black),
                                  ),
                                  TextSpan(
                                    text: 'MM00001',
                                    style: AppTextStyle.style_10_600(color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Booking Date & Time: DEC 03 2024, 12:33 PM',
                              style: AppTextStyle.style_10_400(color: AppColors.grey300),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Payment method: GPE',
                              style: AppTextStyle.style_10_400(color: AppColors.grey300),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 70.w,
                        height: 70.w,
                        decoration: BoxDecoration(
                          color: AppColors.grey50,
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(color: AppColors.grey200),
                        ),
                        child: Icon(Icons.qr_code, size: 40.sp, color: AppColors.grey300),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Bottom row: Payment details + T&C + Print
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Payment details',
                          style: AppTextStyle.style_10_600(color: AppColors.primary),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'T&C',
                              style: AppTextStyle.style_10_600(color: AppColors.grey300),
                            ),
                            SizedBox(width: 2.w),
                            Icon(Icons.description, size: 12.sp, color: AppColors.grey300),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Print',
                          style: AppTextStyle.style_10_600(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}
