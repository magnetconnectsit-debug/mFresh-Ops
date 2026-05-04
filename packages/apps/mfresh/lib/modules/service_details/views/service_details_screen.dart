import 'package:core/constants/app_colors.dart';
import 'package:core/constants/app_images.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh/modules/service_details/controllers/service_details_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
              height: 120.h,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppImages.unitCard),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Unit Image (Overlays the fallback decoration)
                  Obx(
                    () => controller.unitImage.value.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: controller.unitImage.value,
                            width: double.infinity,
                            height: 120.h,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(), // Falls back to decoration
                            errorWidget: (context, url, error) => Container(), // Falls back to decoration
                          )
                        : const SizedBox.shrink(),
                  ),
                  // Dark overlay
                  Container(color: AppColors.black.withValues(alpha: 0.5)),
                  // Unit info
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(
                          () => Text(
                            controller.unitNo.value,
                            style: AppTextStyle.style_18_600(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Obx(
                          () => Text(
                            controller.location.value,
                            style: AppTextStyle.style_10_400(
                              color: AppColors.white,
                            ),
                          ),
                        ),
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
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        color: Colors.transparent,
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 18.sp,
                          color: AppColors.white,
                        ),
                      ),
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
                  Obx(
                    () => GestureDetector(
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
                            style: AppTextStyle.style_12_600(
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20.w),
                  // Membership radio
                  Obx(
                    () => GestureDetector(
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
                            style: AppTextStyle.style_12_600(
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Online toggle
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Online',
                        style: AppTextStyle.style_10_600(
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Obx(
                        () => GestureDetector(
                          onTap: controller.toggleOnline,
                          child: Container(
                            width: 36.w,
                            height: 18.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9.r),
                              color: controller.isOnline.value
                                  ? AppColors.red
                                  : AppColors.grey200,
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
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.services.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 48.sp,
                          color: AppColors.grey200,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'No services available for this unit',
                          style: AppTextStyle.style_14_600(
                            color: AppColors.grey300,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Services Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.services.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                          childAspectRatio: 2.1,
                        ),
                        itemBuilder: (context, index) {
                          return _ServiceCard(
                            controller: controller,
                            index: index,
                          );
                        },
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => controller.total > 0
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
                      style: AppTextStyle.style_12_600(
                        color: AppColors.primary,
                      ),
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
                              controller: controller.mobileController,
                              keyboardType: TextInputType.phone,
                              style: AppTextStyle.style_12_400(
                                color: AppColors.black,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Mobile Number*',
                                hintStyle: AppTextStyle.style_10_400(
                                  color: AppColors.grey200,
                                ),
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
                              controller: controller.nameController,
                              style: AppTextStyle.style_12_400(
                                color: AppColors.black,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Full Name',
                                hintStyle: AppTextStyle.style_10_400(
                                  color: AppColors.grey200,
                                ),
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

                    // Membership Verification Section
                    Obx(
                      () => !controller.isCustomer.value
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 12.h),
                                Text(
                                  'Membership Verification',
                                  style: AppTextStyle.style_12_600(
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(height: 6.h),
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
                                        child: Stack(
                                          alignment: Alignment.centerRight,
                                          children: [
                                            TextField(
                                              controller: controller
                                                  .memberMobileController,
                                              keyboardType: TextInputType.phone,
                                              maxLength: 10,
                                              onChanged: (val) {
                                                if (val.length == 10) {
                                                  controller.verifyMemberPhone(
                                                    val,
                                                  );
                                                }
                                              },
                                              style: AppTextStyle.style_12_400(
                                                color: AppColors.black,
                                              ),
                                              decoration: InputDecoration(
                                                isDense: true,
                                                counterText: "",
                                                hintText:
                                                    'Member Mobile Number',
                                                hintStyle:
                                                    AppTextStyle.style_10_400(
                                                      color: AppColors.grey200,
                                                    ),
                                                border: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      horizontal: 10.w,
                                                      vertical: 8.h,
                                                    ),
                                              ),
                                            ),
                                            if (controller
                                                .isVerifyingMember
                                                .value)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  right: 8.w,
                                                ),
                                                child: SizedBox(
                                                  width: 12.w,
                                                  height: 12.w,
                                                  child:
                                                      const CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (controller.isOtpSent.value &&
                                        !controller.isOtpVerified.value) ...[
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Container(
                                          decoration:
                                              AppColors.appCardDecoration(
                                                borderColor: AppColors.grey50,
                                                containerColor: AppColors.white,
                                                borderRadius: 4,
                                                isShadow: false,
                                              ),
                                          child: TextField(
                                            controller:
                                                controller.otpController,
                                            keyboardType: TextInputType.number,
                                            style: AppTextStyle.style_12_400(
                                              color: AppColors.black,
                                            ),
                                            decoration: InputDecoration(
                                              isDense: true,
                                              hintText: 'Enter OTP',
                                              hintStyle:
                                                  AppTextStyle.style_10_400(
                                                    color: AppColors.grey200,
                                                  ),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 10.w,
                                                    vertical: 8.h,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (controller.isOtpSent.value &&
                                    !controller.isOtpVerified.value)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.h),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: controller.verifyMemberOtp,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryVariant,
                                          padding: EdgeInsets.symmetric(
                                            vertical: 4.h,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          'Verify OTP',
                                          style: AppTextStyle.style_10_600(
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),

                    SizedBox(height: 12.h),

                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL',
                          style: AppTextStyle.style_14_600(
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '₹ ${controller.total}',
                          style: AppTextStyle.style_18_600(
                            color: AppColors.primary,
                          ),
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
                                onPressed: () => controller.initiateBooking(
                                  isExternalQr: false,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: controller.isOnline.value
                                      ? AppColors.blue
                                      : AppColors.green,
                                  foregroundColor: AppColors.white,
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'PAY',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyle.style_12_600(
                                    color: AppColors.white,
                                  ),
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
                              onPressed: () => controller.initiateBooking(
                                isExternalQr: true,
                              ),
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
                                style: AppTextStyle.style_12_600(
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.pineOrange,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: service.image != null && service.image!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: service.image!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: Icon(
                          Icons.image,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.image,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.image,
                        size: 20,
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 8.w),
          // Service Details & Counter
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  service.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.style_10_600(color: AppColors.black),
                ),
                SizedBox(height: 1.h),
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
                SizedBox(height: 4.h),
                // Dynamic Blue/White Counter
                Obx(() {
                  final bool isAdded = service.quantity.value > 0;
                  final Color themeColor = AppColors.pineBlue;
                  return Container(
                    height: 22.h,
                    decoration: BoxDecoration(
                      color: isAdded ? themeColor : AppColors.white,
                      border: Border.all(color: themeColor, width: 1),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => controller.decrement(index),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.w),
                            child: Text(
                              '-',
                              style: AppTextStyle.style_14_600(
                                color: isAdded ? AppColors.white : themeColor,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '${service.quantity.value}',
                          style: AppTextStyle.style_11_600(
                            color: isAdded ? AppColors.white : themeColor,
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => controller.increment(index),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.w),
                            child: Text(
                              '+',
                              style: AppTextStyle.style_14_600(
                                color: isAdded ? AppColors.white : themeColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
