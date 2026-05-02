import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/constants/app_images.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:mfresh/routes/app_routes.dart';
import 'package:mfresh/modules/authentication/controllers/signup_controller.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background Watermark Logo
          Positioned(
            bottom: -125.h,
            right: -125.w,
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                AppImages.appLogo,
                width: 345.w,
                height: 345.w,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 30.h),
                  Text(
                    'Create your Account',
                    style: AppTextStyle.style_22_600(color: AppColors.black),
                  ),
                  SizedBox(height: 22.h),

                  // Full Name Field
                  AppCommonTextField(
                    controller: controller.fullNameController,
                    titleText: 'Full Name',
                    isRequired: true,
                    hintText: 'Full Name',
                  ),
                  SizedBox(height: 8.h),

                  // Email Field
                  AppCommonTextField(
                    controller: controller.emailController,
                    titleText: 'Email',
                    isRequired: true,
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 8.h),

                  // Mobile Number Field
                  PhoneNoTextField(
                    controller: controller.mobileController,
                    hintText: 'Mobile Number',
                  ),
                  SizedBox(height: 8.h),

                  // Password Field
                  Obx(
                    () => AppCommonTextField(
                      controller: controller.passwordController,
                      titleText: 'Password',
                      isRequired: true,
                      hintText: 'Password',
                      obscureText: controller.obscurePassword.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscurePassword.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.grey400,
                          size: 24.sp,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                  ),

                  SizedBox(height: 22.h),

                  // Sign Up Button
                  Obx(
                    () => AppCommonButton(
                      text: 'Sign Up',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.signup,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'Or',
                          style: AppTextStyle.style_12_400(
                            color: AppColors.grey200,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Google Sign In
                  AppCommonButton(
                    text: 'Continue with Google',
                    textSize: 14.sp,
                    variant: ButtonVariant.outline,
                    prefixWidget: SvgPicture.asset(
                      AppImages.googleIcon,
                      width: 24.w,
                      height: 24.w,
                    ),
                    onPressed: () {},
                  ),

                  const Spacer(),

                  // Already have an account? Login
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: AppTextStyle.style_14_400(
                            color: AppColors.grey200,
                          ),
                        ),
                        InkWell(
                          onTap: () => Get.offNamed(AppRoutes.login),
                          child: Text(
                            'Login',
                            style: AppTextStyle.style_14_600(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
