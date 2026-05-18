import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
                Image.asset(AppImages.appLogo, width: 300.w, height: 200.h),
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
                  'mFresh Ops',
                  style: AppTextStyle.style_22_600(color: AppColors.primary),
                ),
                SizedBox(height: 8.h),
                Text(
                  'EMPOWERING OPERATIONS',
                  style: AppTextStyle.style_12_500(color: AppColors.grey300),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
