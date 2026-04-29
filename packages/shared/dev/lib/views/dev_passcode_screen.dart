import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:dev/controllers/dev_passcode_controller.dart';

class DevPasscodeScreen extends GetView<DevPasscodeController> {
  const DevPasscodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50.w,
      height: 50.w,
      textStyle: AppTextStyle.style_20_600(color: AppColors.black),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12.r),
        color: AppColors.grey50,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const AppCommonAppBar(title: Text('Developer Access')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock_person_rounded, 
                    color: AppColors.primary, 
                    size: 40.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Enter Passcode',
                  style: AppTextStyle.style_20_700(color: AppColors.black),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Please enter the 6-digit developer passcode to continue.',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.style_14_400(color: AppColors.grey300),
                ),
                SizedBox(height: 40.h),
                Pinput(
                  length: 6,
                  controller: controller.passcodeController,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyDecorationWith(
                    border: Border.all(color: AppColors.primary, width: 2),
                    color: Colors.white,
                  ),
                  obscureText: true,
                  onCompleted: controller.verifyPasscode,
                ),
                SizedBox(height: 40.h),
                Obx(() => controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
