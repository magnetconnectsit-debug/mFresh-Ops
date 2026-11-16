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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    AppImages.mfreshFullLogo,
                    width: 300.w,
                    fit: BoxFit.contain,
                  ),
                  Text(
                    'Find & Book Luxury Washrooms',
                    style: AppTextStyle.style_14_400(color: AppColors.grey300),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
