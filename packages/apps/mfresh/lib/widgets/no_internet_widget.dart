import 'package:core/constants/app_animations.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class NoInternetWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200.w,
              height: 200.w,
              child: Lottie.asset(
                AppAnimations.noInternetAnimation,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.wifi_off_rounded,
                    size: 80.w,
                    color: AppColors.grey400,
                  );
                },
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No Internet Connection',
              style: AppTextStyle.style_18_600(color: AppColors.black1),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'Please check your internet connection and try again.',
              style: AppTextStyle.style_14_400(color: AppColors.grey600),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 32.h),
              AppCommonButton(
                text: 'Try Again',
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}









