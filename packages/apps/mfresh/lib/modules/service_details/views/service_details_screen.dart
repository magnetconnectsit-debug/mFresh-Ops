import 'package:core/constants/app_colors.dart';
import 'package:core/constants/app_images.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh/core/config/app_config.dart';
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
            Builder(
              builder: (context) {
                final bool isDesktop = MediaQuery.of(context).size.width > 1000;
                final double bannerHeight = isDesktop ? 150.h : 120.h;
                
                return Container(
                  width: double.infinity,
                  height: bannerHeight,
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
                                height: bannerHeight,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Container(), // Falls back to decoration
                                errorWidget: (context, url, error) =>
                                    Container(), // Falls back to decoration
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
                                style: AppTextStyle.style_32_700(
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Obx(
                              () => Text(
                                controller.location.value,
                                style: AppTextStyle.style_20_400(
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
                );
              }
            ),

            // Customer / Membership toggle + Online toggle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 3.h),
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
                  // Online toggle
                  Obx(
                    () => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          controller.isOnline.value ? 'Online' : 'Offline',
                          style: AppTextStyle.style_14_600(
                            color: controller.isOnline.value
                                ? AppColors.green
                                : AppColors.red,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        GestureDetector(
                          onTap: controller.toggleOnline,
                          child: Container(
                            width: 50.w,
                            height: 25.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.5.r),
                              color: controller.isOnline.value
                                  ? AppColors.green
                                  : AppColors.red,
                            ),
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 200),
                              alignment: controller.isOnline.value
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                width: 20.w,
                                height: 20.h,
                                margin: EdgeInsets.symmetric(horizontal: 2.w),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                      Builder(
                        builder: (context) {
                          final bool isDesktop = MediaQuery.of(context).size.width > 1000;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.services.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isDesktop ? 4 : 2,
                              crossAxisSpacing: 12.w,
                              mainAxisSpacing: 12.h,
                              childAspectRatio: isDesktop ? 2.8 : 1.9,
                            ),
                            itemBuilder: (context, index) {
                              return _ServiceCard(
                                controller: controller,
                                index: index,
                              );
                            },
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
            ? SafeArea(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 6.h,
                  ),
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
                      SizedBox(height: 2.h),

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
                                    vertical: 6.h,
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
                                    vertical: 6.h,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Membership Verification (Hidden because it's now in a BottomSheet)
                      Obx(
                        () => !controller.isCustomer.value
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 6.h),
                                  Text(
                                    'Membership Details',
                                    style: AppTextStyle.style_12_600(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Container(
                                    decoration:
                                        AppColors.appCardDecoration(
                                          borderColor: AppColors.grey50,
                                          containerColor: AppColors.white,
                                          borderRadius: 4,
                                          isShadow: false,
                                        ),
                                    child: TextField(
                                      controller: controller
                                          .memberMobileController,
                                      keyboardType:
                                          TextInputType.phone,
                                      maxLength: 10,
                                      style:
                                          AppTextStyle.style_12_400(
                                            color: AppColors.black,
                                          ),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        counterText: "",
                                        hintText:
                                            'Member Mobile Number',
                                        hintStyle:
                                            AppTextStyle.style_10_400(
                                              color:
                                                  AppColors.grey200,
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
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),

                      SizedBox(height: 4.h),
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

                      SizedBox(height: 4.h),

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
                                  controller.isOnline.value ? 'PAY' : 'PAY CASH',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyle.style_12_600(
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (controller.isOnline.value) ...[
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.black.withValues(
                                        alpha: 0.2,
                                      ),
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
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10.h,
                                    ),
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
                        ],
                      ),
                    ],
                  ),
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
                const SizedBox(height: 4),
                // Dynamic Blue/White Counter
                Obx(() {
                  final bool isAdded = service.quantity.value > 0;
                  final Color themeColor = AppColors.pineBlue;
                  return Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: isAdded ? themeColor : AppColors.white,
                      border: Border.all(color: themeColor, width: 1.5),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => controller.decrement(index),
                          child: Container(
                            width: 40.w,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.remove,
                              size: 20.sp,
                              color: isAdded ? AppColors.white : themeColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${service.quantity.value}',
                          style: AppTextStyle.style_16_600(
                            color: isAdded ? AppColors.white : themeColor,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => controller.increment(index),
                          child: Container(
                            width: 40.w,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.add,
                              size: 20.sp,
                              color: isAdded ? AppColors.white : themeColor,
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
