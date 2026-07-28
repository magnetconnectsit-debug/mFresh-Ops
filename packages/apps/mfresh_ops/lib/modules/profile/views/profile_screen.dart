import 'package:core/widgets/app_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        title: const Text('Profile'),
        showAppDrawer: true,
        hasBackButton: false,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: AppColors.primary, size: 22.r),
            onPressed: () => _showEditDialog(context, controller),
          ),
        ],
      ),
      drawer: const CommonSidebar(),
      body: RefreshIndicator(
        onRefresh: controller.fetchProfile,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildProfileHeader(controller),
              _buildOverviewTab(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Obx(
                () => Container(
                  width: 110.r,
                  height: 110.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(55.r),
                    child: controller.selectedImage.value != null
                        ? Image.file(
                            controller.selectedImage.value!,
                            fit: BoxFit.cover,
                          )
                        : AppImageView(
                            imageUrl: controller.user.value?.imageUrl ?? controller.user.value?.uimage,
                            width: 110.r,
                            height: 110.r,
                            borderRadius: 55.r,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified,
                    color: AppColors.white,
                    size: 20.r,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Obx(
            () => controller.isLoading.value && controller.user.value == null
                ? _buildHeaderSkeleton()
                : Text(
                    controller.user.value?.name ?? 'User',
                    style: AppTextStyle.style_20_700(color: AppColors.black),
                  ),
          ),
          Obx(
            () => controller.isLoading.value && controller.user.value == null
                ? const SizedBox.shrink()
                : Text(
                    controller.user.value?.roleName ?? controller.user.value?.role ?? 'User',
                    style: AppTextStyle.style_14_500(color: AppColors.grey300),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ProfileController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Obx(() {
        final user = controller.user.value;
        return Column(
          children: [
            _buildInfoTile(
              Icons.person_outline,
              'Full Name',
              user?.name ?? 'N/A',
            ),
            _buildInfoTile(Icons.work_outline, 'Role', user?.roleName ?? 'N/A'),
            _buildInfoTile(Icons.phone_outlined, 'Phone', user?.mob ?? 'N/A'),
            _buildInfoTile(Icons.email_outlined, 'Email', user?.email ?? 'N/A'),
          ],
        );
      }),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey100.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20.r),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyle.style_12_500(color: AppColors.grey300),
                ),
                Text(
                  value,
                  style: AppTextStyle.style_14_600(color: AppColors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, ProfileController controller) {
    // Reset selected image on open
    controller.selectedImage.value = null;
    if (controller.user.value != null) {
      controller.nameController.text = controller.user.value!.name ?? '';
      controller.passwordController.clear();
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit Profile',
                  style: AppTextStyle.style_18_700(color: AppColors.black),
                ),
                SizedBox(height: 24.h),
                // Profile Image Section
                GestureDetector(
                  onTap: () => _showImageSourceSheet(context, controller),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Obx(
                        () => Container(
                          width: 80.r,
                          height: 80.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40.r),
                            child: controller.selectedImage.value != null
                                ? Image.file(
                                    controller.selectedImage.value!,
                                    fit: BoxFit.cover,
                                  )
                                : AppImageView(
                                    imageUrl: controller.user.value?.imageUrl ??
                                        controller.user.value?.uimage,
                                    width: 80.r,
                                    height: 80.r,
                                    borderRadius: 40.r,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: AppColors.white,
                          size: 14.r,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                AppCommonTextField(
                  controller: controller.nameController,
                  titleText: 'Full Name',
                  hintText: 'Enter full name',
                ),
                SizedBox(height: 16.h),
                AppCommonTextField(
                  controller: controller.passwordController,
                  titleText: 'New Password',
                  hintText: 'Enter new password (optional)',
                  obscureText: true,
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          side: const BorderSide(color: AppColors.grey300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () {
                          controller.selectedImage.value = null; // reset
                          Get.back();
                        },
                        child: Text(
                          'Cancel',
                          style: AppTextStyle.style_14_600(color: AppColors.grey600),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () async {
                          await controller.saveProfile();
                        },
                        child: Text(
                          'OK',
                          style: AppTextStyle.style_14_600(color: AppColors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImageSourceSheet(
    BuildContext context,
    ProfileController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Select Image Source',
              style: AppTextStyle.style_18_700(color: AppColors.black),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                _buildSourceItem(
                  Icons.camera_alt_outlined,
                  'Camera',
                  () => controller.pickImage(ImageSource.camera),
                ),
                _buildSourceItem(
                  Icons.photo_library_outlined,
                  'Gallery',
                  () => controller.pickImage(ImageSource.gallery),
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceItem(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          padding: EdgeInsets.symmetric(vertical: 24.h),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.grey100.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 32.r),
              SizedBox(height: 8.h),
              Text(
                label,
                style: AppTextStyle.style_14_600(color: AppColors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSkeleton() {
    return Column(
      children: [
        Container(
          width: 120.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 80.w,
          height: 14.h,
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ],
    );
  }
}
