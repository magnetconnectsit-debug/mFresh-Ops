// region Imports
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/service_details/controllers/service_details_controller.dart';
import 'package:mfresh_ops/modules/service_details/views/widgets/service_card.dart';
import 'package:mfresh_ops/modules/service_details/views/widgets/handover_dialog_helper.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
// endregion

class ServiceDetailsScreen extends StatelessWidget {
  // region Constructor
  const ServiceDetailsScreen({super.key});
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ServiceDetailsController());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          controller.handleBackExit(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: AppRefreshIndicator(
            onRefresh: () => controller.refreshData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildTopBanner(context, controller),
                  _buildTogglesBar(context, controller),
                  _buildServicesSection(context, controller),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomSummaryBar(context, controller),
      ),
    );
  }
  // endregion

  // region Section Builders
  Widget _buildTopBanner(
    BuildContext context,
    ServiceDetailsController controller,
  ) {
    return Builder(
      builder: (context) {
        final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
        final bool isDesktop = MediaQuery.of(context).size.width > 1000;
        final double bannerHeight =
            isDesktop ? 160.h : (isTablet ? 136.h : 124.h);

        final double btnWidth = isTablet ? 120.w : 88.w;
        final double btnHeight = isTablet ? 36.h : 25.h;
        final double fontSize = isTablet ? 13.sp : 9.5.sp;
        final double iconSize = isTablet ? 17.sp : 12.sp;

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
                        placeholder: (context, url) => Container(),
                        errorWidget: (context, url, error) => Container(),
                      )
                    : const SizedBox.shrink(),
              ),
              // Dark overlay
              Container(color: AppColors.black.withValues(alpha: 0.5)),
              // Unit info
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 136.w : 94.w,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(
                        () => Text(
                          controller.unitNo.value,
                          style: isTablet
                              ? AppTextStyle.style_32_700(
                                  color: AppColors.white,
                                )
                              : AppTextStyle.style_22_600(
                                  color: AppColors.white,
                                ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: isTablet ? 6.h : 4.h),
                      Obx(
                        () => Text(
                          controller.location.value,
                          style: isTablet
                              ? AppTextStyle.style_18_500(
                                  color: AppColors.white,
                                )
                              : AppTextStyle.style_14_400(
                                  color: AppColors.white,
                                ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Top Left Action: Back button
              Positioned(
                left: isTablet ? 16.w : 8.w,
                top: isTablet ? 14.h : 6.h,
                child: GestureDetector(
                  onTap: () => controller.handleBackExit(context),
                  child: Container(
                    height: btnHeight,
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    color: Colors.transparent,
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: isTablet ? 20.sp : 18.sp,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              // Top Right Action: History Button (Positioned at Top-Right)
              Positioned(
                right: isTablet ? 16.w : 10.w,
                top: isTablet ? 14.h : 6.h,
                child: AppCommonButton(
                  text: 'History',
                  width: btnWidth,
                  height: btnHeight,
                  textSize: fontSize,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 8.w : 4.w,
                  ),
                  buttonColor: AppColors.primary,
                  prefixIcon: Icons.history,
                  iconSize: iconSize,
                  iconColor: AppColors.white,
                  textColor: AppColors.white,
                  onPressed: () => Get.toNamed(
                    AppRoutes.bookingHistory,
                    arguments: {
                      'unitId': controller.unitNo.value,
                      'cashierSessionId': controller.cashierSessionId.value,
                      'location': controller.location.value,
                      'paperRollSize': controller.paperRollSize.value,
                      'printingType': controller.printingType.value,
                    },
                  ),
                ),
              ),
              // Bottom Left Action: All Units Button (Positioned at Bottom-Left)
              Positioned(
                left: isTablet ? 16.w : 10.w,
                bottom: isTablet ? 14.h : 6.h,
                child: AppCommonButton(
                  text: 'All Units',
                  width: btnWidth,
                  height: btnHeight,
                  textSize: fontSize,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 8.w : 4.w,
                  ),
                  buttonColor: AppColors.primary,
                  prefixIcon: Icons.grid_view_rounded,
                  iconSize: iconSize,
                  iconColor: AppColors.white,
                  textColor: AppColors.white,
                  onPressed: () => controller.handleBackExit(context),
                ),
              ),
              // Bottom Right Action: Handover Button (Positioned at Bottom-Right)
              Positioned(
                right: isTablet ? 16.w : 10.w,
                bottom: isTablet ? 14.h : 6.h,
                child: AppCommonButton(
                  text: 'Handover',
                  width: btnWidth,
                  height: btnHeight,
                  textSize: fontSize,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 8.w : 4.w,
                  ),
                  buttonColor: AppColors.primary,
                  prefixIcon: Icons.payments_outlined,
                  iconSize: iconSize,
                  iconColor: AppColors.white,
                  textColor: AppColors.white,
                  onPressed: () {
                    HandoverDialogHelper.showHandoverDialog(
                      context: context,
                      unitNo: controller.unitNo.value,
                      cashierSessionId: controller.cashierSessionId.value,
                      onSuccess: () {},
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTogglesBar(
    BuildContext context,
    ServiceDetailsController controller,
  ) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final double tabHeight = isTablet ? 38.h : 32.h;
    final double toggleWidth = isTablet ? 110.w : 80.w;
    final double toggleHeight = isTablet ? 36.h : 28.h;
    final double thumbSize = isTablet ? 28.h : 22.h;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: isTablet ? 8.h : 6.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Customer / Membership Tab Switch (Full width container)
          Obx(() {
            return AppCommonConnectedTabBar(
              tabs: const ['Customer', 'Membership'],
              selectedIndex: controller.isCustomer.value ? 0 : 1,
              height: tabHeight,
              isPillStyle: true,
              borderColor: const Color(0xFFE2E8F0),
              backgroundColor: const Color(0xFFEEF2F6),
              activeTabColor: AppColors.white,
              activeTextColor: AppColors.primary,
              inactiveTextColor: const Color(0xFF64748B),
              activeTextStyle: isTablet
                  ? AppTextStyle.style_14_600(color: AppColors.primary)
                  : AppTextStyle.style_11_600(color: AppColors.primary),
              inactiveTextStyle: isTablet
                  ? AppTextStyle.style_14_500(color: const Color(0xFF64748B))
                  : AppTextStyle.style_11_500(color: const Color(0xFF64748B)),
              borderRadius: BorderRadius.circular(isTablet ? 10.r : 8.r),
              onTabChanged: (index) {
                controller.toggleCustomerType(index == 0);
              },
            );
          }),
          SizedBox(height: isTablet ? 8.h : 6.h),

          // Centered Online / Offline Switch Row (Below Customer/Membership container)
          Center(
            child: Obx(() {
              final isOnline = controller.isOnline.value;
              final Color activeColor =
                  isOnline ? const Color(0xFFF15A24) : const Color(0xFF0288D1);
              final String labelText = isOnline ? 'Online' : 'Offline';

              return GestureDetector(
                onTap: () => controller.toggleOnline(),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Pill Toggle Switch
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      width: isTablet ? 50.w : 42.w,
                      height: isTablet ? 26.h : 22.h,
                      padding: EdgeInsets.all(2.5.r),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        color: activeColor,
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        // Left for Online (Image 2), Right for Offline (Image 1)
                        alignment: isOnline
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                          width: isTablet ? 21.h : 17.h,
                          height: isTablet ? 21.h : 17.h,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // External Label to the Right
                    Text(
                      labelText,
                      style: isTablet
                          ? AppTextStyle.style_13_600(
                              color: const Color(0xFF0F172A),
                            )
                          : AppTextStyle.style_11_600(
                              color: const Color(0xFF0F172A),
                            ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection(
    BuildContext context,
    ServiceDetailsController controller,
  ) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: const Center(child: CustomAppLoader(size: 60)),
        );
      }
      if (controller.services.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Center(
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
                  style: AppTextStyle.style_14_600(color: AppColors.grey300),
                ),
              ],
            ),
          ),
        );
      }
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
              builder: (context) {
                final double screenWidth = MediaQuery.of(context).size.width;
                final bool isTabletLandscape = screenWidth > 800;
                final bool isTabletPortrait = MediaQuery.of(context).size.shortestSide >= 600;

                // 4 in a row for tablet landscape, 3 in a row for tablet portrait, 2 for mobile
                final int crossAxisCount = isTabletLandscape
                    ? 4
                    : (isTabletPortrait ? 3 : 2);

                // Higher aspect ratio = more compact, smaller vertical height
                final double childAspectRatio = isTabletLandscape
                    ? 2.8
                    : (isTabletPortrait ? 2.6 : 1.7);

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.services.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemBuilder: (context, index) {
                    return ServiceCard(controller: controller, index: index);
                  },
                );
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      );
    });
  }

  Widget _buildBottomSummaryBar(
    BuildContext context,
    ServiceDetailsController controller,
  ) {
    return Obx(
      () => controller.total > 0
          ? Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
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
                      top: false,
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
                                child: AppCommonTextField(
                                  controller: controller.mobileController,
                                  labelText: 'Mobile Number',
                                  hintText: 'Enter Mobile Number',
                                  isRequired: true,
                                  readOnly: true,
                                  useFloatingLabel: true,
                                  keyboardType: TextInputType.phone,
                                  borderRadius: 8.r,
                                  fillColor: AppColors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: AppCommonTextField(
                                  controller: controller.nameController,
                                  labelText: 'Full Name',
                                  hintText: 'Enter Full Name',
                                  readOnly: true,
                                  useFloatingLabel: true,
                                  borderRadius: 8.r,
                                  fillColor: AppColors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Expanded(
                                child: AppCommonTextField(
                                  controller: controller.addPhoneController,
                                  labelText: 'Additional Phone',
                                  hintText: 'Enter Additional Phone',
                                  useFloatingLabel: true,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  borderRadius: 8.r,
                                  fillColor: AppColors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: AppCommonTextField(
                                  controller: controller.referralController,
                                  labelText: 'Referral ID',
                                  hintText: 'Enter Referral ID',
                                  useFloatingLabel: true,
                                  borderRadius: 8.r,
                                  fillColor: AppColors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Membership Verification
                          Obx(
                            () => !controller.isCustomer.value
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 8.h),
                                      Text(
                                        'Membership Details',
                                        style: AppTextStyle.style_12_600(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      SizedBox(height: 6.h),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: AppCommonTextField(
                                              controller: controller
                                                  .memberMobileController,
                                              labelText: 'Member Mobile Number',
                                              hintText:
                                                  'Enter Member Mobile Number',
                                              useFloatingLabel: true,
                                              keyboardType: TextInputType.phone,
                                              maxLength: 10,
                                              borderRadius: 8.r,
                                              fillColor: AppColors.white,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 12.w,
                                                    vertical: 6.h,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),
                          SizedBox(height: 8.h),

                          // Dashed Divider
                          Row(
                            children: List.generate(
                              150,
                              (index) => Expanded(
                                child: Container(
                                  color: index % 2 == 0
                                      ? Colors.transparent
                                      : AppColors.grey100,
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
                          _buildPaymentButtons(controller),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
    );
  }

  Widget _buildPaymentButtons(ServiceDetailsController controller) {
    return Obx(
      () => !controller.isOnline.value
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
                  onPressed: () =>
                      controller.initiateBooking(isExternalQr: false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
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
                      onPressed: () =>
                          controller.initiateBooking(isExternalQr: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'PAY',
                        style: AppTextStyle.style_14_700(
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
                          color: AppColors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () =>
                          controller.initiateBooking(isExternalQr: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.grey400,
                        padding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 4.w,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'External QR Payment',
                          maxLines: 1,
                          style: AppTextStyle.style_12_600(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // endregion
}
