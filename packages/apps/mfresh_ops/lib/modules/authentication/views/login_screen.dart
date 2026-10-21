// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/authentication/controllers/login_controller.dart';
// endregion

// region Enums
enum LoginTabType { booking, operation }
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
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 360.w),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Form(
                      key: controller.formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          SizedBox(height: 28.h),
                          _buildLogo(controller),
                          SizedBox(height: 20.h),
                          _buildCard(context, controller),
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

  // region Header & Logo
  Widget _buildLogo(LoginController controller) {
    return Center(
      child: GestureDetector(
        onTap: controller.handleLogoTap,
        child: Image.asset(
          AppImages.appLogo,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
  // endregion

  // region Section Builders
  Widget _buildCard(BuildContext context, LoginController controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1.r,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 20.r,
            spreadRadius: 0,
            offset: Offset(0, 6.h),
          ),
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 6.r,
            spreadRadius: 0,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top Connected Tabs Header with Border & Contrast ──
            _buildTabHeader(controller),

            // ── Form Content ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMobileField(controller),
                  Obx(
                    () => AnimatedCrossFade(
                      duration: const Duration(milliseconds: 250),
                      crossFadeState: controller.isOtpLogin.value
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstChild: const SizedBox.shrink(),
                      secondChild: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 12.h),
                          _buildPasswordField(controller),
                          SizedBox(height: 8.h),
                          _buildRememberMe(controller),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  _buildActionButton(controller),
                  SizedBox(height: 14.h),
                  _buildModeSwitcher(controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabHeader(LoginController controller) {
    return Obx(() {
      final selectedTab = controller.selectedTab.value;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildTabItem(
                    controller: controller,
                    tabIndex: 0,
                    title: 'Booking',
                    type: LoginTabType.booking,
                    isSelected: selectedTab == 0,
                  ),
                ),
                Container(
                  width: 1.r,
                  color: AppColors.borderColor,
                ),
                Expanded(
                  child: _buildTabItem(
                    controller: controller,
                    tabIndex: 1,
                    title: 'Operation',
                    type: LoginTabType.operation,
                    isSelected: selectedTab == 1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1.r,
            color: AppColors.borderColor,
          ),
        ],
      );
    });
  }

  Widget _buildTabItem({
    required LoginController controller,
    required int tabIndex,
    required String title,
    required LoginTabType type,
    required bool isSelected,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.selectTab(tabIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: isSelected ? AppColors.white : const Color(0xFFF8FAFC),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 12.h, bottom: 6.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoginTabAnimationWidget(
                    type: type,
                    isSelected: isSelected,
                    size: 46.r,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    title,
                    style: isSelected
                        ? AppTextStyle.style_14_700(color: AppColors.primary)
                        : AppTextStyle.style_14_600(color: AppColors.iconPrimary),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3.h,
              width: isSelected ? 76.w : 0,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.transparent,
                borderRadius: BorderRadius.vertical(top: Radius.circular(3.r)),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.45),
                          blurRadius: 4.r,
                          offset: Offset(0, -1.h),
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileField(LoginController controller) {
    return AppCommonTextField(
      controller: controller.usernameController,
      focusNode: controller.mobileFocusNode,
      titleText: 'Mobile Number',
      hintText: 'Enter Mobile Number',
      useFloatingLabel: true,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      borderRadius: 8.r,
      fillColor: AppColors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      prefixIconConstraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
      prefixIcon: Icon(
        Icons.phone_android_rounded,
        size: 18.sp,
        color: AppColors.iconPrimary,
      ),
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
    );
  }

  Widget _buildPasswordField(LoginController controller) {
    return Obx(
      () => AppCommonTextField(
        controller: controller.passwordController,
        focusNode: controller.passwordFocusNode,
        titleText: 'Password',
        hintText: 'Enter Password',
        useFloatingLabel: true,
        obscureText: controller.obscurePassword.value,
        borderRadius: 8.r,
        fillColor: AppColors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        prefixIconConstraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          size: 18.sp,
          color: AppColors.iconPrimary,
        ),
        suffixIconConstraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
        suffixIcon: IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
          icon: Icon(
            controller.obscurePassword.value
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 18.sp,
            color: AppColors.iconPrimary,
          ),
          onPressed: controller.togglePasswordVisibility,
        ),
        validator: controller.validatePassword,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => controller.handleLoginAction(),
      ),
    );
  }

  Widget _buildRememberMe(LoginController controller) {
    return Row(
      children: [
        SizedBox(
          width: 16.w,
          height: 16.w,
          child: Obx(
            () => Checkbox(
              value: controller.rememberMe.value,
              onChanged: controller.toggleRememberMe,
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
              side: BorderSide(color: AppColors.borderColor, width: 1.2.r),
            ),
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          'Remember Me',
          style: AppTextStyle.style_11_400(color: AppColors.black300),
        ),
      ],
    );
  }

  Widget _buildActionButton(LoginController controller) {
    return Obx(
      () => AppCommonButton(
        width: double.infinity,
        height: 36.h,
        textSize: 13.sp,
        borderRadius: 8.r,
        elevation: 2.r,
        useGradient: false,
        buttonColor: AppColors.primary,
        textColor: AppColors.white,
        text: controller.isOtpLogin.value ? 'Send OTP' : 'Login',
        isLoading: controller.isLoading.value,
        onPressed: controller.handleLoginAction,
      ),
    );
  }

  Widget _buildModeSwitcher(LoginController controller) {
    return Center(
      child: InkWell(
        onTap: controller.toggleLoginMode,
        borderRadius: BorderRadius.circular(4.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          child: Obx(
            () => Text(
              controller.isOtpLogin.value
                  ? 'Login with Password'
                  : 'Login with OTP',
              style: AppTextStyle.style_13_600(color: AppColors.primary),
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
        style: AppTextStyle.style_10_400(color: AppColors.grey200),
      ),
    );
  }
  // endregion

  // region Dialogs & Action Handlers
  // endregion
}
// endregion

// region Tab Animation & Illustration Widget
class LoginTabAnimationWidget extends StatefulWidget {
  final LoginTabType type;
  final bool isSelected;
  final String? lottieAsset;
  final double? size;

  const LoginTabAnimationWidget({
    super.key,
    required this.type,
    required this.isSelected,
    this.lottieAsset,
    this.size,
  });

  @override
  State<LoginTabAnimationWidget> createState() =>
      _LoginTabAnimationWidgetState();
}

class _LoginTabAnimationWidgetState extends State<LoginTabAnimationWidget>
    with SingleTickerProviderStateMixin {
  // region State & Animation Controller
  late final AnimationController _controller;
  // endregion

  // region Lifecycle Methods
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.isSelected) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant LoginTabAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isSelected && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final gifPath = widget.type == LoginTabType.operation
        ? AppAnimations.operationGif
        : AppAnimations.bookingGif;
    final double effSize = widget.size ?? 40.r;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isSelected ? 1.0 : 0.45,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: isSelected ? 1.0 : 0.92,
        child: SizedBox(
          width: effSize,
          height: effSize,
          child: Image.asset(
            gifPath,
            width: effSize,
            height: effSize,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return widget.type == LoginTabType.operation
                  ? _buildOperationIcon(isSelected)
                  : _buildBookingIcon(isSelected);
            },
          ),
        ),
      ),
    );
  }
  // endregion

  // region Icon Fallback Builders
  Widget _buildOperationIcon(bool isSelected) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: 18.w,
          height: 26.h,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.blue50 : AppColors.transparent,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(
              color: isSelected ? AppColors.blue700 : AppColors.grey200,
              width: 1.5.r,
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 2.h),
              Container(
                width: 5.w,
                height: 1.2.h,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.blue700 : AppColors.grey200,
                  borderRadius: BorderRadius.circular(1.r),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 1.w,
          top: 6.h,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: isSelected ? (_controller.value * 2 * 3.14159) : 0,
                child: child,
              );
            },
            child: Container(
              width: 12.r,
              height: 12.r,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.grey200,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 1.2.r),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 3.r,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Icon(Icons.settings, size: 7.r, color: AppColors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingIcon(bool isSelected) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: 20.w,
          height: 26.h,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.blue50 : AppColors.transparent,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(
              color: isSelected ? AppColors.blue700 : AppColors.grey200,
              width: 1.5.r,
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 2.h),
              Container(
                width: 13.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.blue100 : AppColors.black12,
                  borderRadius: BorderRadius.circular(2.r),
                ),
                child: Center(
                  child: Container(
                    width: 5.r,
                    height: 5.r,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.blue700 : AppColors.grey200,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [_buildDot(isSelected), _buildDot(isSelected)],
                ),
              ),
              SizedBox(height: 1.5.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [_buildDot(isSelected), _buildDot(isSelected)],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDot(bool isSelected) {
    return Container(
      width: 2.r,
      height: 2.r,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.blue700 : AppColors.grey200,
        shape: BoxShape.circle,
      ),
    );
  }

  // endregion
}

// endregion
