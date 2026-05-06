import 'package:core/constants/app_colors.dart';
import 'package:mfresh/routes/app_routes.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh/modules/profile/controllers/profile_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditNameDialog(BuildContext context, ProfileController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile Name',
            style: AppTextStyle.style_16_600(color: AppColors.black)),
        content: TextField(
          controller: controller.nameController,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel',
                style: AppTextStyle.style_14_400(color: AppColors.grey300)),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateProfileName();
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Save',
                style: AppTextStyle.style_14_400(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, ProfileController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout',
            style: AppTextStyle.style_16_600(color: AppColors.black)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('No',
                style: AppTextStyle.style_14_400(color: AppColors.grey300)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Yes',
                style: AppTextStyle.style_14_400(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              SizedBox(height: 16.h),
              // User Card (Orange Header)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Image
                        Container(
                          width: 100.w,
                          height: 100.w,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.r),
                            child: Obx(() => controller.userImage.isNotEmpty &&
                                    controller.userImage != 'NA'
                                ? CachedNetworkImage(
                                    imageUrl: controller.userImage,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.white)),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.person,
                                      size: 50.sp,
                                      color: AppColors.white,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 50.sp,
                                    color: AppColors.white,
                                  )),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        // User Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8.h),
                              Obx(() => Text(
                                    controller.userName,
                                    style: AppTextStyle.style_18_600(
                                      color: AppColors.white,
                                    ),
                                  )),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Icon(Icons.phone,
                                      size: 14.sp, color: AppColors.white),
                                  SizedBox(width: 6.w),
                                  Obx(() => Text(
                                        controller.userPhone,
                                        style: AppTextStyle.style_12_400(
                                          color: AppColors.white,
                                        ),
                                      )),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              Row(
                                children: [
                                  Icon(Icons.email,
                                      size: 14.sp, color: AppColors.white),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: Obx(() => Text(
                                          controller.userEmail,
                                          style: AppTextStyle.style_12_400(
                                            color: AppColors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Edit Info Link
                    Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: () => _showEditNameDialog(context, controller),
                        child: Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Edit Info ',
                                style: AppTextStyle.style_10_400(
                                  color: AppColors.white,
                                ),
                              ),
                              Icon(Icons.edit_note,
                                  size: 16.sp, color: AppColors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Menu Sections
              _buildExpandableSection(
                title: 'My Booking',
                isExpanded: controller.isMyBookingExpanded,
                onTap: controller.toggleMyBooking,
                children: [
                  _buildSubItem(
                    title: 'Booking History',
                    onTap: () {
                      Get.toNamed(AppRoutes.bookingHistory);
                    },
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              _buildExpandableSection(
                title: 'Refer & Earn',
                isExpanded: controller.isReferEarnExpanded,
                onTap: controller.toggleReferEarn,
                children: [],
              ),

              SizedBox(height: 12.h),

              _buildExpandableSection(
                title: 'Help & Support',
                isExpanded: controller.isHelpSupportExpanded,
                onTap: controller.toggleHelpSupport,
                children: [],
              ),

              SizedBox(height: 12.h),

              _buildExpandableSection(
                title: 'Feedback',
                isExpanded: controller.isFeedbackExpanded,
                onTap: controller.toggleFeedback,
                children: [],
              ),

              SizedBox(height: 12.h),

              _buildExpandableSection(
                title: 'Logout',
                isExpanded: controller.isFeedbackExpanded, // Just for visual
                onTap: () => _showLogoutDialog(context, controller),
                children: [],
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required RxBool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Obx(
      () => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: AppTextStyle.style_14_600(color: AppColors.black300),
                    ),
                    const Spacer(),
                    Icon(
                      isExpanded.value
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 24.sp,
                      color: AppColors.grey300,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded.value && children.isNotEmpty) ...[
              _buildDashedDivider(),
              ...children,
              SizedBox(height: 10.h),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubItem({required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
        child: Row(
          children: [
            Text(
              title,
              style: AppTextStyle.style_12_400(color: AppColors.grey200),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, size: 18.sp, color: AppColors.grey200),
          ],
        ),
      ),
    );
  }

  Widget _buildDashedDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boxWidth = constraints.constrainWidth();
          const dashWidth = 3.0;
          const dashHeight = 1.0;
          final dashCount = (boxWidth / (2 * dashWidth)).floor();
          return Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.horizontal,
            children: List.generate(dashCount, (_) {
              return const SizedBox(
                width: dashWidth,
                height: dashHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: AppColors.grey50),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
