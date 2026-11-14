// region Imports
import 'package:core/constants/app_animations.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
// endregion

// region AppCommonNoInternetWidget
class AppCommonNoInternetWidget extends StatelessWidget {
  // region Properties
  final VoidCallback? onRetry;
  final String? message;
  // endregion

  // region Constructor
  const AppCommonNoInternetWidget({super.key, this.onRetry, this.message});
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIllustration(),
            SizedBox(height: 16.h),
            Text(
              'No Internet Connection',
              style: AppTextStyle.style_16_700(color: AppColors.black),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              message ?? 'Please check your internet connection and try again.',
              style: AppTextStyle.style_12_400(color: AppColors.grey400),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 20.h),
              AppCommonButton(
                text: 'Try Again',
                variant: ButtonVariant.primary,
                height: 36.h,
                width: 130.w,
                isSmall: true,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
  // endregion

  // region Section Builders
  Widget _buildIllustration() {
    return Container(
      width: 110.r,
      height: 110.r,
      decoration: BoxDecoration(
        color: AppColors.boxColor2,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderColor, width: 1.r),
      ),
      child: Center(
        child: Lottie.asset(
          AppAnimations.noInternetAnimation,
          width: 90.r,
          height: 90.r,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.wifi_off_rounded,
              size: 48.sp,
              color: AppColors.grey300,
            );
          },
        ),
      ),
    );
  }

  // endregion
}

// endregion
