// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mfresh_ops/core/config/app_config.dart';
import 'package:mfresh_ops/data/services/tracking_service.dart';
import 'package:mfresh_ops/modules/profile/controllers/profile_controller.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
// endregion

// region ProfileScreen View
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        topHeader: const CommonShortcutHeader(),
        title: Text(
          'My Profile',
          style: AppTextStyle.style_16_700(color: AppColors.black),
        ),
        showAppDrawer: true,
        hasBackButton: false,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: AppColors.primary, size: 20.r),
            tooltip: 'Edit Profile',
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
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 580.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeroCard(context, controller),
                  SizedBox(height: 16.h),
                  _buildAccountDetailsSection(context, controller),
                  SizedBox(height: 16.h),
                  if (AppConfig.enableBiometricAuth) ...[
                    _buildSecuritySection(controller),
                    SizedBox(height: 16.h),
                  ],
                  _buildAppInfoSection(context, controller),
                  SizedBox(height: 24.h),
                  _buildLogoutButton(context, controller),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  // endregion

  // region Profile Hero Card
  Widget _buildProfileHeroCard(BuildContext context, ProfileController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14.r,
            offset: Offset(0, 4.h),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Avatar with Camera Icon
          Stack(
            clipBehavior: Clip.none,
            children: [
              Obx(() {
                final imageFile = controller.selectedImage.value;
                final user = controller.user.value;
                final imageUrl = user?.imageUrl ?? user?.uimage;

                return Container(
                  width: 68.r,
                  height: 68.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: imageFile != null
                        ? Image.file(imageFile, fit: BoxFit.cover)
                        : (imageUrl != null && imageUrl.isNotEmpty)
                            ? AppImageView(
                                imageUrl: imageUrl,
                                width: 68.r,
                                height: 68.r,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: AppColors.aliceBlue,
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 38.sp,
                                  color: AppColors.primary,
                                ),
                              ),
                  ),
                );
              }),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showImageSourceSheet(context, controller),
                  child: Container(
                    padding: EdgeInsets.all(5.r),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 4.r,
                          offset: Offset(0, 1.h),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.white,
                      size: 11.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 14.w),

          // Column with User Name and Badges Row
          Expanded(
            child: Obx(() {
              final user = controller.user.value;
              final name = user?.name ?? 'mFresh Ops User';
              final role = user?.roleName ?? user?.role ?? 'Operations Team';

              if (controller.isLoading.value && user == null) {
                return _buildHeaderSkeleton();
              }

              // Check Duty state if TrackingService is present
              final isTrackingServiceRegistered = Get.isRegistered<TrackingService>();
              final isOnDuty = isTrackingServiceRegistered
                  ? Get.find<TrackingService>().isTracking.value
                  : (user?.isOnDuty == 1 || (user?.isCheckedIn ?? false));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: AppTextStyle.style_16_700(color: AppColors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6.w,
                    runSpacing: 4.h,
                    children: [
                      // Role Badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: AppColors.aliceBlue,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              size: 11.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              role,
                              style: AppTextStyle.style_11_600(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),

                      // Duty Status Badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: isOnDuty
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: isOnDuty
                                ? const Color(0xFFA7F3D0)
                                : AppColors.borderColor,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.r,
                              height: 6.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isOnDuty
                                    ? const Color(0xFF059669)
                                    : AppColors.grey500,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              isOnDuty ? 'On Duty' : 'Off Duty',
                              style: AppTextStyle.style_11_600(
                                color: isOnDuty
                                    ? const Color(0xFF059669)
                                    : AppColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
  // endregion

  // region Account Details Section
  Widget _buildAccountDetailsSection(BuildContext context, ProfileController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
            child: Row(
              children: [
                Container(
                  width: 4.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Personal & Contact Information',
                    style: AppTextStyle.style_14_700(color: AppColors.black),
                  ),
                ),
                Icon(Icons.badge_outlined, size: 18.sp, color: AppColors.grey400),
              ],
            ),
          ),
          Divider(height: 1.h, thickness: 1, color: AppColors.borderColor),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 14.h),
            child: Obx(() {
              final user = controller.user.value;
              final fullName = user?.name?.trim().isNotEmpty == true ? user!.name! : 'Not specified';
              final phone = user?.mob?.trim().isNotEmpty == true ? user!.mob! : 'Not specified';
              final email = user?.email?.trim().isNotEmpty == true ? user!.email! : 'Not specified';

              return Column(
                children: [
                  _buildInfoTile(
                    icon: Icons.person_rounded,
                    label: 'Full Name',
                    value: fullName,
                    accentColor: const Color(0xFF2563EB),
                  ),
                  _buildInfoTile(
                    icon: Icons.phone_rounded,
                    label: 'Phone Number',
                    value: phone,
                    accentColor: const Color(0xFF059669),
                  ),
                  _buildInfoTile(
                    icon: Icons.mail_rounded,
                    label: 'Email Address',
                    value: email,
                    accentColor: const Color(0xFFD97706),
                    isLast: true,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color accentColor,
    bool isLast = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.borderColor.withValues(alpha: 0.6),
                  width: 0.8,
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: accentColor, size: 18.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyle.style_11_500(color: AppColors.grey500),
                ),
                SizedBox(height: 3.h),
                Text(
                  value,
                  style: AppTextStyle.style_13_600(color: AppColors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // endregion

  // region Security Section (Biometrics)
  Widget _buildSecuritySection(ProfileController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
            child: Row(
              children: [
                Container(
                  width: 4.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Security & Authentication',
                    style: AppTextStyle.style_14_700(color: AppColors.black),
                  ),
                ),
                Icon(Icons.security_rounded, size: 18.sp, color: AppColors.grey400),
              ],
            ),
          ),
          Divider(height: 1.h, thickness: 1, color: AppColors.borderColor),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
            child: Obx(() {
              final bios = controller.biometricService;
              final isSupported = bios.canCheckBiometrics.value;
              final isEnabled = bios.isBiometricEnabled.value;

              return Row(
                children: [
                  Container(
                    width: 38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.fingerprint_rounded,
                      color: const Color(0xFF059669),
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Biometric App Lock',
                          style: AppTextStyle.style_13_600(color: AppColors.black),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          isSupported
                              ? (isEnabled
                                  ? 'Fingerprint & Face unlock enabled'
                                  : 'Tap switch to enable quick unlock')
                              : 'Biometric hardware unavailable',
                          style: AppTextStyle.style_11_400(
                            color: isSupported
                                ? (isEnabled ? const Color(0xFF059669) : AppColors.grey500)
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: isEnabled,
                    activeColor: const Color(0xFF059669),
                    onChanged: isSupported
                        ? (val) => controller.toggleBiometricLock(val)
                        : null,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
  // endregion

  // region App Info Section
  Widget _buildAppInfoSection(BuildContext context, ProfileController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
            child: Row(
              children: [
                Container(
                  width: 4.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Application Information',
                    style: AppTextStyle.style_14_700(color: AppColors.black),
                  ),
                ),
                Icon(Icons.info_outline_rounded, size: 18.sp, color: AppColors.grey400),
              ],
            ),
          ),
          Divider(height: 1.h, thickness: 1, color: AppColors.borderColor),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38.r,
                      height: 38.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.smartphone_rounded,
                        color: const Color(0xFF6366F1),
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Text(
                      'App Version',
                      style: AppTextStyle.style_13_600(color: AppColors.black),
                    ),
                  ],
                ),
                Obx(
                  () => Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.aliceBlue,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Text(
                      'v${controller.appVersion.value}',
                      style: AppTextStyle.style_11_600(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // endregion

  // region Logout Button
  Widget _buildLogoutButton(BuildContext context, ProfileController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: AppCommonButton(
        width: double.infinity,
        height: 40.h,
        textSize: 13.sp,
        borderRadius: 8.r,
        useGradient: false,
        variant: ButtonVariant.outline,
        borderColor: const Color(0xFFFCA5A5),
        textColor: AppColors.error,
        icon: Icons.logout_rounded,
        iconSize: 18.sp,
        iconColor: AppColors.error,
        text: 'Sign Out of Account',
        onPressed: () => controller.handleLogout(context),
      ),
    );
  }
  // endregion

  // region Dialogs & Action Handlers
  void _showEditDialog(BuildContext context, ProfileController controller) {
    controller.selectedImage.value = null;
    controller.isPasswordVisible.value = false;
    if (controller.user.value != null) {
      controller.nameController.text = controller.user.value!.name ?? '';
      controller.passwordController.clear();
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 440.w),
          child: Padding(
            padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 18.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Profile',
                        style: AppTextStyle.style_16_700(color: AppColors.black),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(Icons.close_rounded, size: 20.sp, color: AppColors.grey500),
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Divider(height: 1.h, thickness: 1, color: AppColors.borderColor),
                  SizedBox(height: 18.h),

                  // Avatar Pick in Edit Modal
                  Center(
                    child: GestureDetector(
                      onTap: () => _showImageSourceSheet(context, controller),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Obx(() {
                            final imageFile = controller.selectedImage.value;
                            final user = controller.user.value;
                            final imageUrl = user?.imageUrl ?? user?.uimage;

                            return Container(
                              width: 80.r,
                              height: 80.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary, width: 2.r),
                              ),
                              child: ClipOval(
                                child: imageFile != null
                                    ? Image.file(imageFile, fit: BoxFit.cover)
                                    : (imageUrl != null && imageUrl.isNotEmpty)
                                        ? AppImageView(
                                            imageUrl: imageUrl,
                                            width: 80.r,
                                            height: 80.r,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: AppColors.aliceBlue,
                                            child: Icon(
                                              Icons.person_rounded,
                                              size: 40.sp,
                                              color: AppColors.primary,
                                            ),
                                          ),
                              ),
                            );
                          }),
                          Container(
                            padding: EdgeInsets.all(5.r),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.white, width: 2.r),
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: AppColors.white,
                              size: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  AppCommonTextField(
                    controller: controller.nameController,
                    titleText: 'Full Name',
                    hintText: 'Enter full name',
                    useFloatingLabel: true,
                    borderRadius: 8.r,
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      size: 18.sp,
                      color: AppColors.iconPrimary,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Obx(
                    () => AppCommonTextField(
                      controller: controller.passwordController,
                      titleText: 'New Password (Optional)',
                      hintText: 'Leave empty to keep unchanged',
                      useFloatingLabel: true,
                      obscureText: !controller.isPasswordVisible.value,
                      borderRadius: 8.r,
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        size: 18.sp,
                        color: AppColors.iconPrimary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18.sp,
                          color: AppColors.iconPrimary,
                        ),
                        splashRadius: 18.r,
                        onPressed: () {
                          controller.isPasswordVisible.value =
                              !controller.isPasswordVisible.value;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  Row(
                    children: [
                      Expanded(
                        child: AppCommonButton(
                          height: 34.h,
                          textSize: 12.sp,
                          borderRadius: 6.r,
                          useGradient: false,
                          variant: ButtonVariant.outline,
                          borderColor: AppColors.grey300,
                          textColor: AppColors.grey600,
                          text: 'Cancel',
                          onPressed: () {
                            controller.selectedImage.value = null;
                            Navigator.of(dialogCtx).pop();
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Obx(
                          () => AppCommonButton(
                            height: 34.h,
                            textSize: 12.sp,
                            borderRadius: 6.r,
                            useGradient: false,
                            buttonColor: AppColors.primary,
                            textColor: AppColors.white,
                            text: 'Save Changes',
                            isLoading: controller.isSaving.value,
                            onPressed: () => controller.saveProfile(),
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
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context, ProfileController controller) {
    AppCommonBottomSheet.showModal(
      context,
      title: 'Select Photo Source',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.pickImage(ImageSource.camera),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    decoration: BoxDecoration(
                      color: AppColors.aliceBlue,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.fieldBorderColor),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 28.sp),
                        SizedBox(height: 8.h),
                        Text(
                          'Camera',
                          style: AppTextStyle.style_13_600(color: AppColors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.pickImage(ImageSource.gallery),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    decoration: BoxDecoration(
                      color: AppColors.aliceBlue,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.fieldBorderColor),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.photo_library_outlined, color: AppColors.primary, size: 28.sp),
                        SizedBox(height: 8.h),
                        Text(
                          'Gallery',
                          style: AppTextStyle.style_13_600(color: AppColors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildHeaderSkeleton() {
    return Column(
      children: [
        Container(
          width: 140.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 90.w,
          height: 14.h,
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ],
    );
  }
  // endregion
}
// endregion

