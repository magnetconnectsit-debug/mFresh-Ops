import 'package:core/constants/app_colors.dart';
import 'package:core/constants/app_images.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/authentication/controllers/login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    Center(
                      child: GestureDetector(
                        onTap: controller.handleLogoTap,
                        child: Image.asset(
                          AppImages.appLogo,
                          width: 280.w,
                          height: 140.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Login',
                      style: AppTextStyle.style_22_600(
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    // Username Field
                    AppLoginTextField(
                      controller: controller.usernameController,
                      titleText: 'Mobile No.',
                      hintText: 'Enter your mobile number',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icon(
                        Icons.phone_android_outlined,
                        color: AppColors.black200,
                        size: 18.sp,
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // Password Field
                    Obx(
                      () => controller.isOtpLogin.value
                          ? const SizedBox.shrink()
                          : Column(
                              children: [
                                AppLoginTextField(
                                  controller: controller.passwordController,
                                  titleText: 'Password',
                                  hintText: 'Enter your password',
                                  obscureText: controller.obscurePassword.value,
                                  prefixIcon: Icon(
                                    Icons.lock_outline_rounded,
                                    color: AppColors.black200,
                                    size: 18.sp,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      controller.obscurePassword.value
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppColors.black200,
                                      size: 18.sp,
                                    ),
                                    onPressed: controller.togglePasswordVisibility,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                              ],
                            ),
                    ),

                    // Remember Me
                    Obx(
                      () => controller.isOtpLogin.value
                          ? const SizedBox.shrink()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () => controller.toggleRememberMe(!controller.rememberMe.value),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 18.w,
                                        height: 18.w,
                                        child: Obx(
                                          () => Checkbox(
                                            value: controller.rememberMe.value,
                                            onChanged: controller.toggleRememberMe,
                                            activeColor: AppColors.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4.r),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'Remember Me',
                                        style: AppTextStyle.style_12_400(
                                          color: AppColors.black300,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),

                    SizedBox(height: 14.h),

                    // Login Button
                    Obx(
                      () => AppCommonButton(
                        width: double.infinity,
                        height: 38.h,
                        textSize: 13.sp,
                        borderRadius: 8.r,
                        useGradient: false,
                        buttonColor: AppColors.primary,
                        text: controller.isOtpLogin.value ? 'Get OTP' : 'Login',
                        isLoading: controller.isLoading.value,
                        onPressed: controller.handleLoginAction,
                      ),
                    ),

                    SizedBox(height: 14.h),

                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.grey50)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          child: Text(
                            'OR',
                            style: AppTextStyle.style_11_400(color: AppColors.black200),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppColors.grey50)),
                      ],
                    ),

                    SizedBox(height: 14.h),

                    // Switch Mode Button
                    Obx(
                      () => Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r),
                        child: InkWell(
                          onTap: controller.toggleLoginMode,
                          borderRadius: BorderRadius.circular(8.r),
                          child: Ink(
                            height: 38.h,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  controller.isOtpLogin.value
                                      ? Icons.lock_outline_rounded
                                      : Icons.phone_android_rounded,
                                  size: 16.sp,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  controller.isOtpLogin.value
                                      ? 'Login with Password'
                                      : 'Login with OTP',
                                  style: AppTextStyle.style_12_600(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Footer
                    Center(
                      child: Text(
                        '© 2026 ALL RIGHTS RESERVED',
                        style: AppTextStyle.style_12_400(
                          color: AppColors.black200,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  ),
);
  }
}


