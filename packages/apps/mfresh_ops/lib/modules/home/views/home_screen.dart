// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/constants/app_images.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'widgets/duty_status_card.dart';
import 'widgets/home_grid.dart';
// endregion

// region HomeScreen Widget
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
// endregion

// region HomeScreenState
class _HomeScreenState extends State<HomeScreen> {
  // region State Variables
  DateTime? _lastPressed;
  // endregion

  // region Navigation & Actions
  void _handleCheckIn(BuildContext context) {
    final authRepo = Get.find<AuthRepository>();
    if (!authRepo.rxUserPermissions.contains('duty_punch')) {
      AppCommonToastMessage.show(
        message: 'You do not have permission to perform this action.',
        type: ToastType.warning,
      );
      return;
    }
    Get.toNamed(AppRoutes.camera);
  }
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final now = DateTime.now();
        if (_lastPressed == null ||
            now.difference(_lastPressed!) > const Duration(seconds: 2)) {
          _lastPressed = now;
          AppCommonToastMessage.show(
            message: "Please press back again to close",
            type: ToastType.info,
          );
          return;
        }

        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: const CommonShortcutHeader(),
        drawer: const CommonSidebar(),
        body: AppRefreshIndicator(
          onRefresh: () async {
            try {
              await Get.find<AuthRepository>().fetchProfile();
            } catch (e) {
              debugPrint('Error reloading profile on home refresh: $e');
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: 20.w,
                    right: 20.w,
                    top: 10.h,
                    bottom: 8.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDutySection(context),
                      const HomeGrid(),
                      SizedBox(height: 10.h),
                      _buildFooterLogo(context),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // endregion

  // region Section Builders
  Widget _buildDutySection(BuildContext context) {
    return Obx(() {
      final authRepo = Get.find<AuthRepository>();
      if (authRepo.rxUserPermissions.contains('duty_punch')) {
        return Column(
          children: [
            const DutyStatusCard(),
            SizedBox(height: 8.h),
            AppCommonButton(
              text: 'Check In',
              prefixIcon: Icons.camera_alt_outlined,
              iconSize: 18.r,
              width: double.infinity,
              height: 38.h,
              textSize: 13.sp,
              borderRadius: 10.r,
              useGradient: true,
              gradientColors: const [
                AppColors.secondaryGreen,
                AppColors.primaryGreen,
              ],
              onPressed: () => _handleCheckIn(context),
            ),
            SizedBox(height: 12.h),
          ],
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildFooterLogo(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: 14.h,
          horizontal: 10.w,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.black.withValues(alpha: 0.05),
            width: 1.r,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Image.asset(
              AppImages.appLogo,
              width: 280.w,
              height: 75.h,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
  // endregion
}
// endregion
