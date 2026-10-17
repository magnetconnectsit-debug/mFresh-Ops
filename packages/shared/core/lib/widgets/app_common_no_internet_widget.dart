import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/constants/app_animations.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_button.dart';

class AppCommonNoInternetWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const AppCommonNoInternetWidget({
    super.key,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 180.w,
              height: 180.w,
              child: Lottie.asset(
                AppAnimations.noInternetAnimation,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.wifi_off_rounded,
                    size: 72.r,
                    color: AppColors.grey400,
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'No Internet Connection',
              style: AppTextStyle.style_16_700(color: AppColors.black),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              message ?? 'Please check your internet connection and try again.',
              style: AppTextStyle.style_12_400(color: AppColors.grey600),
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
}
