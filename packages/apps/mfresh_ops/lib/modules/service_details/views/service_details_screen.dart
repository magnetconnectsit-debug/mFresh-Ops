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

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.refreshData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    _buildTopBanner(context, controller),
                    _buildTogglesBar(controller),
                    _buildServicesSection(context, controller),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomSummaryBar(context, controller),
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
                        placeholder: (context, url) => Container(),
                        errorWidget: (context, url, error) => Container(),
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
              // History button (Top Right)
              Positioned(
                right: 8.w,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () => Get.toNamed(
                    AppRoutes.bookingHistory,
                    arguments: {
                      'unitId': controller.unitNo.value,
                      'cashierSessionId': controller.cashierSessionId.value,
                      'location': controller.location.value,
                      'paperRollSize': controller.paperRollSize.value,
                      'printingType': controller.printingType.value,
                    },
                  ),
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
              // Handover Button (Bottom Right Corner of Banner)
              Positioned(
                right: 8.w,
                bottom: 6.h,
                child: AppCommonButton(
                  text: 'Handover',
                  isSmall: true,
                  buttonColor: AppColors.primary,
                  prefixIcon: Icons.payments_outlined,
                  iconColor: AppColors.white,
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

  Widget _buildTogglesBar(ServiceDetailsController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Row(
        children: [
          // Customer / Membership Tab Switch
          Obx(() {
            return SizedBox(
              width: 195.w,
              child: AppCommonConnectedTabBar(
                tabs: const ['Customer', 'Membership'],
                selectedIndex: controller.isCustomer.value ? 0 : 1,
                height: 30.h,
                isPillStyle: true,
                borderColor: const Color(0xFFE2E8F0),
                backgroundColor: const Color(0xFFEEF2F6),
                activeTabColor: AppColors.white,
                activeTextColor: AppColors.primary,
                inactiveTextColor: const Color(0xFF64748B),
                activeTextStyle:
                    AppTextStyle.style_12_600(color: AppColors.primary),
                inactiveTextStyle:
                    AppTextStyle.style_12_500(color: const Color(0xFF64748B)),
                borderRadius: BorderRadius.circular(8.r),
                onTabChanged: (index) {
                  controller.toggleCustomerType(index == 0);
                },
              ),
            );
          }),
          const Spacer(),
          // Online / Offline Animated Switch
          Obx(() {
            final isOnline = controller.isOnline.value;
            final activeColor = isOnline ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
            final labelText = isOnline ? 'Online' : 'Offline';

            return GestureDetector(
              onTap: () => controller.toggleOnline(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: 86.w,
                height: 30.h,
                padding: EdgeInsets.symmetric(horizontal: 3.5.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  color: activeColor,
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Animated text fade and slide transition
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      left: isOnline ? 8.w : 30.w,
                      right: isOnline ? 30.w : 8.w,
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            labelText,
                            key: ValueKey<String>(labelText),
                            style: AppTextStyle.style_11_700(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Animated sliding thumb
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      alignment: isOnline ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: 23.h,
                        height: 23.h,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
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
                final bool isDesktop = MediaQuery.of(context).size.width > 1000;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.services.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop
                        ? 4
                        : (MediaQuery.of(context).size.shortestSide >= 600
                              ? 3
                              : 2),
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: isDesktop ? 2.4 : 1.7,
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
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: 1.0,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
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
