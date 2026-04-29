import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mfresh/modules/service_details/controllers/service_details_controller.dart';
import 'package:core/routes/app_routes.dart';

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ServiceDetailsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Banner
            Container(
              width: double.infinity,
              height: 80.h,
              color: AppColors.grey50,
              child: Stack(
                children: [
                  // Placeholder image
                  Center(
                    child: Icon(Icons.image, size: 40.sp, color: AppColors.grey200),
                  ),
                  // Dark overlay
                  Container(color: AppColors.black.withValues(alpha: 0.5)),
                  // Unit info
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(() => Text(
                              controller.unitNo.value,
                              style: AppTextStyle.style_18_600(color: AppColors.white),
                            )),
                        SizedBox(height: 2.h),
                        Obx(() => Text(
                              controller.location.value,
                              style: AppTextStyle.style_10_400(color: AppColors.white),
                            )),
                      ],
                    ),
                  ),
                  // Back button
                  Positioned(
                    left: 8.w,
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(Icons.arrow_back_ios, size: 18.sp, color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Customer / Membership toggle + Online toggle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  const Spacer(),
                  // Customer radio
                  Obx(() => GestureDetector(
                        onTap: () => controller.toggleCustomerType(true),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              controller.isCustomer.value
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              size: 16.sp,
                              color: AppColors.primaryVariant,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Customer',
                              style: AppTextStyle.style_12_600(color: AppColors.black),
                            ),
                          ],
                        ),
                      )),
                  SizedBox(width: 20.w),
                  // Membership radio
                  Obx(() => GestureDetector(
                        onTap: () => controller.toggleCustomerType(false),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              !controller.isCustomer.value
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              size: 16.sp,
                              color: AppColors.primaryVariant,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Membership',
                              style: AppTextStyle.style_12_600(color: AppColors.black),
                            ),
                          ],
                        ),
                      )),
                  const Spacer(),
                  // Online toggle
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Online',
                        style: AppTextStyle.style_10_600(color: AppColors.black),
                      ),
                      SizedBox(height: 2.h),
                      Obx(() => GestureDetector(
                            onTap: controller.toggleOnline,
                            child: Container(
                              width: 36.w,
                              height: 18.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9.r),
                                color: controller.isOnline.value ? AppColors.red : AppColors.grey200,
                              ),
                              child: AnimatedAlign(
                                duration: const Duration(milliseconds: 200),
                                alignment: controller.isOnline.value
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  width: 14.w,
                                  height: 14.h,
                                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Services Grid
                    Obx(() => GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.services.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                            childAspectRatio: 1.5,
                          ),
                          itemBuilder: (context, index) {
                            return _ServiceCard(
                              controller: controller,
                              index: index,
                            );
                          },
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() => controller.total > 0
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact Details
                  Text(
                    'Contact Details',
                    style: AppTextStyle.style_12_600(color: AppColors.primary),
                  ),
                  SizedBox(height: 6.h),

                  // Mobile + Name fields
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: AppColors.appCardDecoration(
                            borderColor: AppColors.grey50,
                            containerColor: AppColors.white,
                            borderRadius: 4,
                            isShadow: false,
                          ),
                          child: TextField(
                            onChanged: (val) => controller.mobileController.value = val,
                            keyboardType: TextInputType.phone,
                            style: AppTextStyle.style_12_400(color: AppColors.black),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Mobile Number*',
                              hintStyle: AppTextStyle.style_10_400(color: AppColors.grey200),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 8.h,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Container(
                          decoration: AppColors.appCardDecoration(
                            borderColor: AppColors.grey50,
                            containerColor: AppColors.white,
                            borderRadius: 4,
                            isShadow: false,
                          ),
                          child: TextField(
                            onChanged: (val) => controller.nameController.value = val,
                            style: AppTextStyle.style_12_400(color: AppColors.black),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Full Name',
                              hintStyle: AppTextStyle.style_10_400(color: AppColors.grey200),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 8.h,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL',
                        style: AppTextStyle.style_14_600(color: AppColors.primary),
                      ),
                      Text(
                        '₹ ${controller.total}',
                        style: AppTextStyle.style_18_600(color: AppColors.primary),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Payment Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              foregroundColor: AppColors.white,
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Pay via PhonePe',
                              textAlign: TextAlign.center,
                              style: AppTextStyle.style_12_600(color: AppColors.white),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              final result = await Get.toNamed(AppRoutes.qrScanner);
                              if (result != null) {
                                String scanData = result.toString().trim();
                                debugPrint("RAW SCAN RESULT: '$scanData'");
                                
                                Uri? uri = Uri.tryParse(scanData);

                                if (uri != null && uri.scheme.isEmpty && scanData.contains('@')) {
                                  scanData = 'upi://pay?pa=$scanData';
                                  uri = Uri.tryParse(scanData);
                                }

                                if (uri != null && (uri.scheme == 'upi' || scanData.startsWith('upi://'))) {
                                  try {
                                    // Try with externalNonBrowserApplication first as it's more specific
                                    bool launched = await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalNonBrowserApplication,
                                    );
                                    
                                    if (!launched) {
                                      // Fallback to externalApplication if the specific mode fails
                                      launched = await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }

                                    if (!launched) {
                                      Get.snackbar(
                                        'Payment Error',
                                        'No payment apps found. Please ensure PhonePe, GPay, or Paytm is installed.',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: AppColors.red.withValues(alpha: 0.8),
                                        colorText: AppColors.white,
                                        duration: const Duration(seconds: 5),
                                      );
                                    }
                                  } catch (e) {
                                    Get.snackbar(
                                      'Launch Error',
                                      'Error opening payment app: $e',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  }
                                } else {
                                  Get.defaultDialog(
                                    title: 'Invalid QR',
                                    middleText: 'Scanned data is not a valid UPI payment link:\n\n$scanData',
                                    textConfirm: 'OK',
                                    onConfirm: () => Get.back(),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.grey300,
                              foregroundColor: AppColors.white,
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'External QR Payment',
                              textAlign: TextAlign.center,
                              style: AppTextStyle.style_12_600(color: AppColors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const SizedBox.shrink()),
    );
  }
}

/// Individual service card with icon placeholder, name, price, and qty counter
class _ServiceCard extends StatelessWidget {
  final ServiceDetailsController controller;
  final int index;

  const _ServiceCard({required this.controller, required this.index});

  @override
  Widget build(BuildContext context) {
    final service = controller.services[index];

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: AppColors.appCardDecoration(
        borderColor: AppColors.grey50,
        containerColor: AppColors.white,
        borderRadius: 12,
        isShadow: true,
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Icon(Icons.wc, size: 28.sp, color: AppColors.white),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      service.name,
                      style: AppTextStyle.style_10_600(color: AppColors.black),
                    ),
                    Row(
                      children: [
                        Text(
                          '₹ ${service.price}',
                          style: AppTextStyle.style_10_600(color: AppColors.black),
                        ),
                        Text(
                          ' / use',
                          style: AppTextStyle.style_8_400(color: AppColors.black),
                        ),
                      ],
                    ),
                  ],
                ),
                // Counter at the bottom right
                Align(
                  alignment: Alignment.bottomRight,
                  child: Obx(() => Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primaryVariant, width: 1),
                          borderRadius: BorderRadius.circular(6.r),
                          color: service.quantity.value > 0
                              ? AppColors.primaryVariant
                              : AppColors.white,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => controller.decrement(index),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                child: Text('-',
                                    style: AppTextStyle.style_14_600(
                                        color: service.quantity.value > 0
                                            ? AppColors.white
                                            : AppColors.primaryVariant)),
                              ),
                            ),
                            Text(
                              '${service.quantity.value}',
                              style: AppTextStyle.style_10_600(
                                  color: service.quantity.value > 0
                                      ? AppColors.white
                                      : AppColors.primaryVariant),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => controller.increment(index),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                child: Text('+',
                                    style: AppTextStyle.style_14_600(
                                        color: service.quantity.value > 0
                                            ? AppColors.white
                                            : AppColors.primaryVariant)),
                              ),
                            ),
                          ],
                        ),
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
