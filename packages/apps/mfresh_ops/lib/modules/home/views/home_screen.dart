// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
  Future<void> _handleCheckInOut(BuildContext context) async {
    final authRepo = Get.find<AuthRepository>();
    if (authRepo.rxIsCheckedIn.value) {
      final capturedPath = await Get.toNamed(
        AppRoutes.camera,
        arguments: {'confirmButtonText': 'Check Out'},
      );
      if (capturedPath != null &&
          capturedPath is String &&
          capturedPath.isNotEmpty) {
        final compressedPath = await AppImageCompressor.compressPath(
              capturedPath,
              quality: 50,
            ) ??
            capturedPath;
        await authRepo.attendanceCheckOut(imagePath: compressedPath);
      }
    } else {
      await UnitSelectionScreen.show(context, isSelfieAttendance: true);
    }
  }
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return AppDoubleBackToClose(
      scaffoldKey: _scaffoldKey,
      child: Scaffold(
        key: _scaffoldKey,
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
      final isSubmitting = authRepo.isSubmittingAttendance.value;

      return Column(
        children: [
          Row(
            children: [
              // Duty status card — equal width
              const Expanded(child: DutyStatusCard()),
              SizedBox(width: 10.w),
              // White elevated Selfie Attendance button with shadows — equal width
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  child: InkWell(
                    onTap: isSubmitting
                        ? null
                        : () => _handleCheckInOut(context),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Ink(
                      height: 35.h,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.grey200,
                          width: 1.r,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.08),
                            blurRadius: 8.r,
                            spreadRadius: 0,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: isSubmitting
                          ? const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CustomAppLoader(),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 24.r,
                                  height: 24.r,
                                  decoration: BoxDecoration(
                                    color: AppColors.aliceBlue,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  padding: EdgeInsets.all(2.r),
                                  child: Center(
                                    child: Image.asset(
                                      AppImages.selfieIcon,
                                      width: 20.r,
                                      height: 20.r,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Flexible(
                                  child: Text(
                                    authRepo.rxIsCheckedIn.value
                                        ? 'Selfie Check-Out'
                                        : 'Selfie Punch',
                                    style: AppTextStyle.style_12_600(
                                      color: authRepo.rxIsCheckedIn.value
                                          ? AppColors.red
                                          : AppColors.black,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
