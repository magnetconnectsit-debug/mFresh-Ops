// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/constants/app_images.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/authentication/controllers/login_controller.dart';
// endregion

// region LoginScreen View
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // region Main Build
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
                  constraints: BoxConstraints(maxWidth: 480.w),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Form(
                      key: controller.formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),
                          _buildLogo(controller),
                          SizedBox(height: 12.h),
                          _buildTitle(),
                          SizedBox(height: 14.h),
                          _buildMobileField(controller),
                          SizedBox(height: 10.h),
                          _buildPasswordField(controller),
                          _buildRememberMe(controller),
                          SizedBox(height: 14.h),
                          _buildLoginButton(controller),
                          SizedBox(height: 14.h),
                          _buildOrDivider(),
                          SizedBox(height: 14.h),
                          _buildModeSwitcher(controller),
                          const Spacer(),
                          _buildFooter(),
                          SizedBox(height: 16.h),
                        ],
                      ),
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
  // endregion

  // region Section Builders
  Widget _buildLogo(LoginController controller) {
    return Center(
      child: GestureDetector(
        onTap: controller.handleLogoTap,
        child: Image.asset(
          AppImages.appLogo,
          width: 280.w,
          height: 140.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Login',
      style: AppTextStyle.style_22_600(
        color: AppColors.black,
      ),
    );
  }

  Widget _buildMobileField(LoginController controller) {
    return Obx(
      () => AppLoginTextField(
        controller: controller.usernameController,
        focusNode: controller.mobileFocusNode,
        titleText: 'Mobile No.',
        isRequired: true,
        hintText: 'Enter your 10-digit mobile number',
        keyboardType: TextInputType.phone,
        maxLength: 10,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        validator: controller.validateMobileNumber,
        textInputAction: controller.isOtpLogin.value
            ? TextInputAction.done
            : TextInputAction.next,
        onFieldSubmitted: (_) {
          if (controller.isOtpLogin.value) {
            controller.handleLoginAction();
          } else {
            controller.passwordFocusNode.requestFocus();
          }
        },
        prefixIcon: Icon(
          Icons.phone_android_outlined,
          color: AppColors.black200,
          size: 18.sp,
        ),
      ),
    );
  }

  Widget _buildPasswordField(LoginController controller) {
    return Obx(
      () => controller.isOtpLogin.value
          ? const SizedBox.shrink()
          : Column(
              children: [
                AppLoginTextField(
                  controller: controller.passwordController,
                  focusNode: controller.passwordFocusNode,
                  titleText: 'Password',
                  isRequired: true,
                  hintText: 'Enter your password',
                  obscureText: controller.obscurePassword.value,
                  textInputAction: TextInputAction.done,
                  validator: controller.validatePassword,
                  onFieldSubmitted: (_) => controller.handleLoginAction(),
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
    );
  }

  Widget _buildRememberMe(LoginController controller) {
    return Obx(
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
    );
  }

  Widget _buildLoginButton(LoginController controller) {
    return Obx(
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
    );
  }

  Widget _buildOrDivider() {
    return Row(
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
    );
  }

  Widget _buildModeSwitcher(LoginController controller) {
    return Obx(
      () => Material(
        color: AppColors.transparent,
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
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        '© 2026 ALL RIGHTS RESERVED',
        style: AppTextStyle.style_12_400(
          color: AppColors.black200,
        ),
      ),
    );
  }
  // endregion
}
// endregion
