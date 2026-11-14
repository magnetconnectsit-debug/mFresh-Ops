// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/core/config/app_config.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:services/services.dart';
// endregion

// region AppBiometricLockOverlay
class AppBiometricLockOverlay extends StatefulWidget {
  const AppBiometricLockOverlay({super.key});

  @override
  State<AppBiometricLockOverlay> createState() => _AppBiometricLockOverlayState();
}

class _AppBiometricLockOverlayState extends State<AppBiometricLockOverlay> {
  // region Dependencies
  final BiometricAuthService _biometricService = Get.find<BiometricAuthService>();
  final StorageService _storageService = Get.find<StorageService>();
  final isAuthenticating = false.obs;
  // endregion

  // region Lifecycle Methods
  @override
  void initState() {
    super.initState();
    // Auto-prompt biometrics slightly after overlay renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerUnlock();
    });
  }
  // endregion

  // region Business Logic & Helpers
  Future<void> _triggerUnlock() async {
    if (!AppConfig.enableBiometricAuth || isAuthenticating.value) return;

    isAuthenticating.value = true;
    try {
      final success = await _biometricService.authenticateForUnlock(
        localizedReason: 'Scan fingerprint or face to unlock mFresh Ops',
      );
      if (!success) {
        // Kept locked for user to retry manually via button
      }
    } finally {
      isAuthenticating.value = false;
    }
  }

  Future<void> _handleFallbackLogout() async {
    final ctx = context;
    final confirmed = await AppCommonDialogBox.showConfirm(
      ctx,
      title: 'Log Out',
      message: 'Are you sure you want to log out of your current account?',
      confirmText: 'Log Out',
      cancelText: 'Cancel',
      confirmButtonColor: AppColors.error,
    );

    if (confirmed) {
      _biometricService.unlockApp();
      await Get.find<AuthRepository>().logout();
      Get.offAllNamed(AppRoutes.login);
    }
  }
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final user = _storageService.getUser();
    final userName = user?.name ?? 'mFresh Ops User';

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white.withValues(alpha: 0.95),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo Header
                  Image.asset(
                    AppImages.appLogo,
                    width: 140.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 36.h),

                  // Glassmorphism Center Card
                  AppCommonLiquidGlass(
                    width: double.infinity,
                    borderRadius: BorderRadius.circular(20.r),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Fingerprint Icon Container
                        Container(
                          width: 72.r,
                          height: 72.r,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              width: 1.5.r,
                            ),
                          ),
                          child: Icon(
                            Icons.fingerprint_rounded,
                            size: 42.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Title & Subtitle
                        Text(
                          'App Locked',
                          style: AppTextStyle.style_18_700(color: AppColors.black),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Welcome back, $userName',
                          style: AppTextStyle.style_13_500(color: AppColors.black300),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Unlock with Fingerprint or Face ID to continue',
                          style: AppTextStyle.style_11_400(color: AppColors.black200),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 28.h),

                        // Unlock Button
                        Obx(
                          () => AppCommonButton(
                            width: double.infinity,
                            height: 38.h,
                            textSize: 13.sp,
                            borderRadius: 8.r,
                            useGradient: false,
                            buttonColor: AppColors.primary,
                            textColor: AppColors.white,
                            icon: Icons.lock_open_rounded,
                            iconSize: 18.sp,
                            text: 'Unlock with Biometrics',
                            isLoading: isAuthenticating.value,
                            onPressed: _triggerUnlock,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 28.h),

                  // Fallback: Logout & switch user
                  InkWell(
                    onTap: _handleFallbackLogout,
                    borderRadius: BorderRadius.circular(4.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      child: Text(
                        'Switch Account / Log Out',
                        style: AppTextStyle.style_12_600(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  // endregion
}
// endregion
