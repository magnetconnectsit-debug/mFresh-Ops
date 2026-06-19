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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: controller.handleLogoTap,
                        child: Image.asset(
                          AppImages.appLogo,
                          width: 350.w,
                          height: 175.w,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Login',
                      style: AppTextStyle.style_22_600(
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // Username Field
                    AppCommonTextField(
                      controller: controller.usernameController,
                      titleText: 'Username',
                      hintText: 'Enter your username',
                      keyboardType: TextInputType.text,
                    ),

                    SizedBox(height: 8.h),

                    // Password Field
                    Obx(
                      () => controller.isOtpLogin.value
                          ? const SizedBox.shrink()
                          : Column(
                              children: [
                                AppCommonTextField(
                                  controller: controller.passwordController,
                                  titleText: 'Password',
                                  hintText: 'Enter your password',
                                  obscureText: controller.obscurePassword.value,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      controller.obscurePassword.value
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppColors.grey400,
                                      size: 20.sp,
                                    ),
                                    onPressed: controller.togglePasswordVisibility,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                              ],
                            ),
                    ),

                    // Remember Me & Forget Password
                    Obx(
                      () => controller.isOtpLogin.value
                          ? const SizedBox.shrink()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 20.w,
                                      height: 20.w,
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
                                        color: AppColors.grey400,
                                      ),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Text(
                                    'Forget Password',
                                    style: AppTextStyle.style_12_600(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),

                    SizedBox(height: 12.h),

                    // Login Button
                    Obx(
                      () => AppCommonButton(
                        text: controller.isOtpLogin.value ? 'Get OTP' : 'Login',
                        isLoading: controller.isLoading.value,
                        onPressed: controller.handleLoginAction,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.grey200)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            'OR',
                            style: AppTextStyle.style_12_400(color: AppColors.grey400),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppColors.grey200)),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Switch Mode Text Button
                    Center(
                      child: Obx(
                        () => TextButton(
                          onPressed: controller.toggleLoginMode,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                          child: Text(
                            controller.isOtpLogin.value
                                ? 'Login with Password'
                                : 'Login with OTP',
                            style: AppTextStyle.style_14_600(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // mFresh Ops
                    Center(
                      child: Text(
                        'mFresh Ops',
                        style: AppTextStyle.style_20_600(
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Footer
                    Center(
                      child: Text(
                        '© 2024 ALL RIGHTS RESERVED',
                        style: AppTextStyle.style_12_400(
                          color: AppColors.grey400,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
