import 'package:core/constants/app_animations.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/constants/app_images.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/utils/app_utils.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/routes/app_routes.dart';
import 'package:services/app_update_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class AppUpdateScreen extends StatelessWidget {
  final bool isForceUpdate;
  final String message;
  final String storeUrl;
  final String versionName;

  const AppUpdateScreen({
    super.key,
    required this.isForceUpdate,
    required this.message,
    required this.storeUrl,
    required this.versionName,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isForceUpdate,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (isForceUpdate) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Stack(
          children: [
            // region Background Decorative Circles
            Positioned(
              top: -60.h,
              left: -60.w,
              child: _buildCircle(200.w, AppColors.primary.withValues(alpha: 0.05)),
            ),
            Positioned(
              bottom: -80.h,
              right: -40.w,
              child: _buildCircle(250.w, AppColors.primary.withValues(alpha: 0.03)),
            ),
            // endregion

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      _buildLogo(),
                      SizedBox(height: 16.h),
                      _buildAnimation(),
                      SizedBox(height: 32.h),
                      
                      Text(
                        'Update Available',
                        style: AppTextStyle.style_24_600(color: AppColors.black1),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 12.h),
                      _buildVersionBadge(),
                      SizedBox(height: 32.h),
                      _buildWhatsNewSection(),
                      SizedBox(height: 20.h),

                      AppCommonButton(
                        text: 'Update App',
                        onPressed: () => AppUtils.launchURL(context, storeUrl),
                      ),

                      if (!isForceUpdate) ...[
                        SizedBox(height: 8.h),
                        AppCommonButton(
                          text: 'Not Now, Later',
                          variant: ButtonVariant.text,
                          textColor: AppColors.grey500,
                          onPressed: () {
                            try {
                              Get.find<AppUpdateService>().setUpdateSkipped(true);
                            } catch (e) {
                              debugPrint("Could not set skip flag: $e");
                            }
                            Get.offAllNamed(AppRoutes.initial);
                          },
                        ),
                      ] else
                        SizedBox(height: 40.h),

                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // region Helper Widgets
  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 80.w,
      width: 80.w,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Image.asset(AppImages.appLogo, fit: BoxFit.contain),
    );
  }

  Widget _buildAnimation() {
    return SizedBox(
      width: 200.w,
      height: 160.w,
      child: Lottie.asset(
        AppAnimations.appUpdateAnimation,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.system_update_rounded,
            size: 70.sp,
            color: AppColors.primary,
          );
        },
      ),
    );
  }

  Widget _buildVersionBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_outlined, size: 14.sp, color: AppColors.primary),
          SizedBox(width: 6.w),
          Text(
            'Version: $versionName',
            style: AppTextStyle.style_12_600(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsNewSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 16.sp, color: AppColors.orange),
              SizedBox(width: 8.w),
              Text(
                "What's New?",
                style: AppTextStyle.style_14_600(color: AppColors.black1),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            message,
            style: AppTextStyle.style_14_400(color: AppColors.grey600, height: 1.5),
          ),
        ],
      ),
    );
  }
  // endregion
}









