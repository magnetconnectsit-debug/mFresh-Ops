import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_images.dart';
import 'package:core/constants/app_colors.dart';
import 'package:mfresh_ops/modules/splash/controllers/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put controller here if not put elsewhere
    Get.put(SplashController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Central Logo
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppImages.appLogo,
                  width: 150.w,
                  height: 150.h,
                ),
              ],
            ),
          ),
          // Footer Text
          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'MAGNET CONNECTS',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: 4.0,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'EMPOWERING OPERATIONS',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey300,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
