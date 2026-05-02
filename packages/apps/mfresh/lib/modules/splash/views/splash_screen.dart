import 'package:core/constants/app_colors.dart';
import 'package:core/constants/app_images.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh/modules/splash/controllers/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    AppImages.appLogo,
                    width: 180.w,
                    height: 180.w,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 40.h),
                Text(
                  'mFresh',
                  style: AppTextStyle.style_24_600(color: AppColors.primary),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Cleanliness Redefined',
                  style: AppTextStyle.style_14_400(color: AppColors.grey300),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 60.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: 30.w,
                  height: 30.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Initializing...',
                  style: AppTextStyle.style_12_400(color: AppColors.grey200),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
