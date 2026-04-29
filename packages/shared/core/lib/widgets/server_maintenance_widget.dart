
import 'package:core/constants/app_animations.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:lottie/lottie.dart';

/// A full-screen widget displayed when an internal server error (500) occurs.
/// Shows a maintenance animation, message, and an optional refresh button.
class ServerMaintenanceWidget extends StatelessWidget {
  /// Called when the user taps the refresh button.
  final VoidCallback? onRefresh;

  /// Whether a refresh is currently in progress.
  final bool isLoading;

  final String? title;
  final String? message;
  final String? lottieAsset;

  const ServerMaintenanceWidget({
    super.key,
    this.onRefresh,
    this.isLoading = false,
    this.title,
    this.message,
    this.lottieAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation
            SizedBox(
              width: 220.w,
              height: 220.w,
              child: Lottie.asset(
                lottieAsset ?? AppAnimations.serverMaintenanceAnimation,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to icon if lottie fails to load
                  return Container(
                    width: 140.w,
                    height: 140.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.07),
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.dns_rounded, color: AppColors.primary, size: 38.sp),
                        SizedBox(height: 4.h),
                        Icon(
                          Icons.build_rounded,
                          color: AppColors.primary.withValues(alpha: 0.7),
                          size: 22.sp,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16.h),

            // Title
            Text(
              title ?? 'Server Under Maintenance',
              style: AppTextStyle.style_20_600(color: AppColors.black1),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12.h),

            // Subtitle
            Text(
              message ??
                  'We are currently performing scheduled maintenance.\nPlease try again after some time.',
              style: AppTextStyle.style_14_400(
                color: AppColors.grey600,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 40.h),

            // Refresh button
            if (onRefresh != null)
              AppCommonButton(
                text: isLoading ? 'Refreshing...' : 'Refresh',
                onPressed: onRefresh,
                isLoading: isLoading,
              ),
          ],
        ),
      ),
    );
  }
}










