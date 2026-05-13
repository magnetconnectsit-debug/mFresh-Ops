import 'package:core/constants/app_colors.dart';
import 'package:mfresh/modules/service_details/views/widgets/service_card.dart';
import 'package:core/constants/app_images.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh/modules/service_details/controllers/service_details_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mfresh/routes/app_routes.dart';
import 'package:core/widgets/custom_app_loader.dart';

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ServiceDetailsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
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
                      // History button
                      Positioned(
                        right: 8.w,
                        top: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.bookingHistory),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            color: Colors.transparent,
                            child: Icon(
                              Icons.history,
                              size: 22.sp,
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
                  // Customer / Membership radio toggle
                  Obx(() {
                    final canToggle = controller.appPermissions?.customerMemberRadio ?? false;
                    if (!canToggle) return const SizedBox.shrink();
                    
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
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
                        SizedBox(width: 20.w),
                        GestureDetector(
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
                        SizedBox(width: 20.w),
                      ],
                    );
                  }),
                  const Spacer(),
                  // Online toggle
                  Obx(() {
                    final canToggle = controller.appPermissions?.onlineOfflineToggle ?? false;
                    if (!canToggle) return const SizedBox.shrink();
                    
                    return Column(
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
                          onTap: () => controller.toggleOnline(),
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
                    );
                  }),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CustomAppLoader(size: 60));
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
                return RefreshIndicator(
                  onRefresh: () => controller.refreshData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                                crossAxisSpacing: 10.w,
                                mainAxisSpacing: 10.h,
                                childAspectRatio: isDesktop ? 2.4 : 1.7,
                              ),
                              itemBuilder: (context, index) {
                                return ServiceCard(
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
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => controller.total > 0
            ? Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
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
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contact Details Section
                      Text(
                        'Contact Details',
                        style: AppTextStyle.style_12_600(
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: AppColors.grey50.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: TextField(
                                controller: controller.mobileController,
                                keyboardType: TextInputType.phone,
                                style: AppTextStyle.style_12_400(color: AppColors.black),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintText: 'Mobile Number*',
                                  hintStyle: AppTextStyle.style_12_400(color: AppColors.grey200),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: AppColors.grey50.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: TextField(
                                controller: controller.nameController,
                                style: AppTextStyle.style_12_400(color: AppColors.black),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintText: 'Full Name',
                                  hintStyle: AppTextStyle.style_12_400(color: AppColors.grey200),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Obx(() {
                        final canShowAddPhone = controller.appPermissions?.additionalPhoneNo ?? false;
                        if (!canShowAddPhone) return const SizedBox.shrink();
                        
                        return Column(
                          children: [
                            SizedBox(height: 6.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: AppColors.grey50.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: TextField(
                                controller: controller.addPhoneController,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                style: AppTextStyle.style_12_400(color: AppColors.black),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  counterText: "",
                                  hintText: 'Additional Phone',
                                  hintStyle: AppTextStyle.style_12_400(color: AppColors.grey200),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      
                      // Membership Verification (Restored from old project)
                      Obx(() => !controller.isCustomer.value
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8.h),
                                Text(
                                  'Membership Details',
                                  style: AppTextStyle.style_12_600(color: AppColors.primary),
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                                        decoration: BoxDecoration(
                                          color: AppColors.grey50.withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: TextField(
                                          controller: controller.memberMobileController,
                                          keyboardType: TextInputType.phone,
                                          maxLength: 10,
                                          onChanged: (value) {
                                            if (value.length == 10) {
                                              controller.verifyMemberPhone(value);
                                            }
                                          },
                                          style: AppTextStyle.style_12_400(color: AppColors.black),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            isDense: true,
                                            counterText: "",
                                            hintText: 'Member Mobile Number',
                                            hintStyle: AppTextStyle.style_12_400(color: AppColors.grey200),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Obx(() => controller.isOtpSent.value && !controller.isOtpVerified.value
                                    ? Padding(
                                        padding: EdgeInsets.only(top: 6.h),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                                          decoration: BoxDecoration(
                                            color: AppColors.grey50.withValues(alpha: 0.5),
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: TextField(
                                            controller: controller.otpController,
                                            keyboardType: TextInputType.number,
                                            style: AppTextStyle.style_12_400(color: AppColors.black),
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              isDense: true,
                                              hintText: 'Enter OTP',
                                              hintStyle: AppTextStyle.style_12_400(color: AppColors.grey200),
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink()),
                              ],
                            )
                          : const SizedBox.shrink()),
                      SizedBox(height: 8.h),

                      // Dashed Divider
                      Row(
                        children: List.generate(
                          150,
                          (index) => Expanded(
                            child: Container(
                              color: index % 2 == 0 ? Colors.transparent : AppColors.grey100,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),

                      // Total Amount Display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL',
                            style: AppTextStyle.style_12_600(
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '₹ ${controller.total}',
                            style: AppTextStyle.style_14_700(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 6.h),

                      // Payment Buttons
                      Obx(() => !controller.isOnline.value
                          ? SizedBox(
                              width: double.infinity,
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withValues(alpha: 0.3),
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
                                    backgroundColor: AppColors.green,
                                    padding: EdgeInsets.symmetric(vertical: 8.h), // Decreased size further
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                  ),
                                  child: Text(
                                    'PAY CASH',
                                    style: AppTextStyle.style_14_700(color: AppColors.white),
                                  ),
                                ),
                              ),
                            )
                          : Row(
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
                                        backgroundColor: AppColors.blue,
                                        padding: EdgeInsets.symmetric(vertical: 12.h), 
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.r),
                                        ),
                                      ),
                                      child: Text(
                                        'PAY',
                                        style: AppTextStyle.style_14_700(color: AppColors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                Obx(() {
                                  final canShowExternalQr = (controller.appPermissions?.externalQr ?? false) && controller.isOnline.value;
                                  if (!canShowExternalQr) return const SizedBox.shrink();
                                  
                                  return Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(left: 12.w),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.black.withValues(alpha: 0.1),
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
                                          backgroundColor: AppColors.grey400,
                                          padding: EdgeInsets.symmetric(vertical: 12.h), 
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.r),
                                          ),
                                        ),
                                        child: Text(
                                          'External QR Payment',
                                          style: AppTextStyle.style_12_600(color: AppColors.white),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            )),
                    ],
                  ),
                ),
              ),
            )
            : const SizedBox.shrink(),
      ),
    );
  }
}

