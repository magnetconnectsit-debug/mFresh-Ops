// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/constants/app_images.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:core/utils/app_image_compressor.dart';
import 'widgets/duty_status_card.dart';
import 'widgets/home_grid.dart';
import 'unit_selection_screen.dart';
import '../controllers/home_grid_controller.dart';
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

  // region Lifecycle Methods
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Get.isRegistered<AuthRepository>()) {
        Get.find<AuthRepository>().refreshPermissions();
      }
    });
  }
  // endregion

  // region Navigation & Actions
  Future<void> _handleCheckInOut(BuildContext context, bool isCheckedIn) async {
    final authRepo = Get.find<AuthRepository>();

    String? selectedUnitId;
    if (!isCheckedIn) {
      final selectedUnit = await UnitSelectionScreen.show(context);
      if (selectedUnit == null) {
        // User dismissed the unit selection
        return;
      }
      selectedUnitId = selectedUnit.id;
    }

    final capturedPath = await Get.toNamed(AppRoutes.camera);
    if (capturedPath != null &&
        capturedPath is String &&
        capturedPath.isNotEmpty) {
      final compressedPath = await AppImageCompressor.compressPath(
            capturedPath,
            quality: 50,
          ) ??
          capturedPath;

      if (isCheckedIn) {
        await authRepo.attendanceCheckOut(imagePath: compressedPath);
      } else {
        await authRepo.attendanceCheckIn(
          imagePath: compressedPath,
          unitId: selectedUnitId,
        );
      }
    }
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
              await Get.find<AuthRepository>().refreshPermissions();
              if (Get.isRegistered<HomeGridController>()) {
                Get.find<HomeGridController>().refreshGrid();
              }
            } catch (e) {
              debugPrint('Error reloading profile & permissions on home refresh: $e');
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
      final isCheckedIn = authRepo.rxIsCheckedIn.value;
      final isSubmitting = authRepo.isSubmittingAttendance.value;

      final buttonColors = isCheckedIn
          ? [AppColors.red, const Color(0xFFD32F2F)]
          : [AppColors.secondaryGreen, AppColors.primaryGreen];

      return Column(
        children: [
          Row(
            children: [
              // Duty status card — equal width
              const Expanded(child: DutyStatusCard()),
              SizedBox(width: 10.w),
              // Premium check-in / check-out button — equal width
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  child: InkWell(
                    onTap: isSubmitting
                        ? null
                        : () => _handleCheckInOut(context, isCheckedIn),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Ink(
                      height: 35.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: buttonColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: buttonColors.first.withValues(alpha: 0.28),
                            blurRadius: 8.r,
                            spreadRadius: 0,
                            offset: Offset(0, 3.h),
                          ),
                        ],
                      ),
                      child: isSubmitting
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CustomAppLoader(
                                  color: AppColors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 22.r,
                                  height: 22.r,
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      AppImages.selfieIcon,
                                      width: 14.r,
                                      height: 14.r,
                                      color: AppColors.white,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  isCheckedIn ? 'Selfie Check Out' : 'Selfie Check In',
                                  style: AppTextStyle.style_12_600(
                                    color: AppColors.white,
                                  ),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
        ],
      );
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
