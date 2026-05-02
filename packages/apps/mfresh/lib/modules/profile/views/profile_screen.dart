import 'package:core/constants/app_colors.dart';
import 'package:mfresh/routes/app_routes.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
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
        title: Text('Edit Profile Name', style: AppTextStyle.style_16_600(color: AppColors.black)),
        content: TextField(
          controller: controller.nameController,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: AppTextStyle.style_14_400(color: AppColors.grey300)),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateProfileName();
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Save', style: AppTextStyle.style_14_400(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, ProfileController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout', style: AppTextStyle.style_16_600(color: AppColors.black)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('No', style: AppTextStyle.style_14_400(color: AppColors.grey300)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Yes', style: AppTextStyle.style_14_400(color: AppColors.white)),
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
      appBar: AppCommonAppBar(
        title: const Text('Profile'),
        hasBackButton: false,
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 8.h),
            // User Card
            Container(
              width: double.infinity,
              decoration: AppColors.appCardDecoration(
                borderColor: AppColors.primary,
                containerColor: AppColors.white,
                borderRadius: 12,
                isShadow: true,
              ),
              child: Column(
                children: [
                  // User Info Row
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.grey500,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12.r),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Profile Image Placeholder
                        Container(
                          width: 70.w,
                          height: 70.w,
                          decoration: BoxDecoration(
                            color: AppColors.grey200,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: AppColors.white,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.r),
                            child: Obx(() => controller.userImage.isNotEmpty && controller.userImage != 'NA'
                                ? CachedNetworkImage(
                                    imageUrl: controller.userImage,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.person,
                                      size: 40.sp,
                                      color: AppColors.grey50,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 40.sp,
                                    color: AppColors.grey50,
                                  )),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // User Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() => Text(
                                controller.userName,
                                style: AppTextStyle.style_16_600(
                                  color: AppColors.white,
                                ),
                              )),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    size: 14.sp,
                                    color: AppColors.white,
                                  ),
                                  SizedBox(width: 4.w),
                                  Obx(() => Text(
                                    controller.userPhone,
                                    style: AppTextStyle.style_12_400(
                                      color: AppColors.white,
                                    ),
                                  )),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.email,
                                    size: 14.sp,
                                    color: AppColors.white,
                                  ),
                                  SizedBox(width: 4.w),
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
                  ),
                  // Edit Info
                  GestureDetector(
                    onTap: () => _showEditNameDialog(context, controller),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Edit Info',
                            style: AppTextStyle.style_12_600(
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(Icons.edit, size: 14.sp, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // My Booking Section
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

            // Refer & Earn Section
            _buildExpandableSection(
              title: 'Refer & Earn',
              isExpanded: controller.isReferEarnExpanded,
              onTap: controller.toggleReferEarn,
              children: [],
            ),

            SizedBox(height: 12.h),

            // Help & Support Section
            _buildExpandableSection(
              title: 'Help & Support',
              isExpanded: controller.isHelpSupportExpanded,
              onTap: controller.toggleHelpSupport,
              children: [],
            ),

            SizedBox(height: 12.h),

            // Feedback Section
            _buildExpandableSection(
              title: 'Feedback',
              isExpanded: controller.isFeedbackExpanded,
              onTap: controller.toggleFeedback,
              children: [],
            ),

            SizedBox(height: 12.h),

            // Logout
            GestureDetector(
              onTap: () => _showLogoutDialog(context, controller),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: AppColors.appCardDecoration(
                  borderColor: AppColors.grey50,
                  containerColor: AppColors.white,
                  borderRadius: 8,
                  isShadow: true,
                ),
                child: Row(
                  children: [
                    Text(
                      'Logout',
                      style: AppTextStyle.style_14_400(color: AppColors.black),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 22.sp,
                      color: AppColors.grey300,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  /// Builds an expandable section with a title and optional children
  Widget _buildExpandableSection({
    required String title,
    required RxBool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Obx(
      () => Container(
        width: double.infinity,
        decoration: AppColors.appCardDecoration(
          borderColor: AppColors.grey50,
          containerColor: AppColors.white,
          borderRadius: 8,
          isShadow: true,
        ),
        child: Column(
          children: [
            // Header
            GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: AppTextStyle.style_14_400(color: AppColors.black),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: isExpanded.value ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 22.sp,
                        color: AppColors.grey300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Expanded Content
            if (isExpanded.value && children.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Column(children: children),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds a sub-item inside an expandable section
  Widget _buildSubItem({required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        child: Row(
          children: [
            Text(
              title,
              style: AppTextStyle.style_12_400(color: AppColors.grey300),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, size: 18.sp, color: AppColors.grey200),
          ],
        ),
      ),
    );
  }
}
