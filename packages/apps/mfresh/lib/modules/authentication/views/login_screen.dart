import 'package:mfresh/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh/modules/authentication/controllers/login_controller.dart';
import 'package:mfresh/core/constants/app_constants.dart';
import 'package:core/core.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
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
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width > 600 ? 900.w : 500.w,
                  ),
                  child: Column(
                    children: [
                      // Top Image
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
                        child: GestureDetector(
                          onTap: controller.handleDevTap,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: Image.asset(
                              AppImages.loginImage,
                              width: double.infinity,
                              height: MediaQuery.of(context).size.width > 600 ? 320.h : 160.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Login your Account',
                              style: AppTextStyle.style_20_700(
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: 8.h),

                            // Mobile or Email Field
                            Obx(
                              () => controller.isEmailLogin.value
                                  ? AppCommonTextField(
                                      controller: controller.emailController,
                                      titleText: 'Email',
                                      hintText: 'Enter your email',
                                      isRequired: true,
                                      keyboardType: TextInputType.emailAddress,
                                    )
                                  : PhoneNoTextField(
                                      controller: controller.mobileController,
                                    ),
                            ),
                            SizedBox(height: 8.h),

                            // Password Field
                            Obx(
                              () => Visibility(
                                visible: !controller.isOtpLogin.value,
                                child: Column(
                                  children: [
                                    AppCommonTextField(
                                      controller: controller.passwordController,
                                      titleText: 'Password',
                                      isRequired: true,
                                      hintText: 'Enter your password',
                                      obscureText:
                                          controller.obscurePassword.value,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          controller.obscurePassword.value
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: AppColors.grey400,
                                          size: 20.sp,
                                        ),
                                        onPressed:
                                            controller.togglePasswordVisibility,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                  ],
                                ),
                              ),
                            ),

                            // Remember Me & Login with OTP
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(
                                  () => Visibility(
                                    visible: !controller.isOtpLogin.value,
                                    maintainSize: true,
                                    maintainAnimation: true,
                                    maintainState: true,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 20.w,
                                          height: 20.w,
                                          child: Checkbox(
                                            value: controller.rememberMe.value,
                                            onChanged:
                                                controller.toggleRememberMe,
                                            activeColor: AppColors.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                4.r,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'Remember Me',
                                          style: AppTextStyle.style_12_400(
                                            color: AppColors.black200,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: controller.toggleLoginType,
                                  child: Obx(
                                    () => Text(
                                      controller.isOtpLogin.value
                                          ? 'Login with Pass'
                                          : 'Login with OTP',
                                      style: AppTextStyle.style_12_600(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 12.h),

                            // Login Button
                            Obx(
                              () => AppCommonButton(
                                text: 'Login',
                                isLoading: controller.isLoading.value,
                                onPressed: controller.login,
                              ),
                            ),

                            SizedBox(height: 12.h),

                            // Not Registered
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Not Registered Yet? ',
                                    style: AppTextStyle.style_12_400(
                                      color: AppColors.grey300,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => Get.toNamed(AppRoutes.signup),
                                    child: Text(
                                      'Create an account',
                                      style: AppTextStyle.style_12_600(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 8.h),

                            // Footer
                            Center(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () => Get.to(
                                          () => const AppCommonWebView(
                                            url: AppConstants.privacyPolicyUrl,
                                            title: 'Privacy Policy',
                                          ),
                                        ),
                                        child: Text(
                                          'Privacy Policy',
                                          style: AppTextStyle.style_12_400(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        ' | ',
                                        style: AppTextStyle.style_12_400(
                                          color: AppColors.black200,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => Get.to(
                                          () => const AppCommonWebView(
                                            url: AppConstants.termsConditionUrl,
                                            title: 'Terms & Condition',
                                          ),
                                        ),
                                        child: Text(
                                          'Terms & Condition',
                                          style: AppTextStyle.style_12_400(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    '© 2024 ALL RIGHTS RESERVED',
                                    style: AppTextStyle.style_12_400(
                                      color: AppColors.black200,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
