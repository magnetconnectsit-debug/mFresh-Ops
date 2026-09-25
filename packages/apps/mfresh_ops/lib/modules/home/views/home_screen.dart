import 'package:core/constants/app_colors.dart';
import 'package:core/constants/app_images.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'widgets/home_grid.dart';
import 'widgets/duty_status_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _lastPressed;

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
        appBar: AppCommonAppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AppImages.logo, height: 24.h, fit: BoxFit.contain),
              SizedBox(width: 8.w),
              Text(
                'mFresh Ops',
                style: AppTextStyle.style_14_700(
                  color: AppColors.primaryOrange,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: () => Get.toNamed(AppRoutes.notifications),
              icon: Icon(
                Icons.notifications_none_rounded,
                color: AppColors.primary,
                size: 22.r,
              ),
            ),
          ],
          showAppDrawer: true,
          hasBackButton: false,
          elevation: 0,
        ),
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
                      Text(
                        'Mark Your Attendance',
                        style: AppTextStyle.style_14_700(
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Obx(() {
                        final authRepo = Get.find<AuthRepository>();
                        if (authRepo.rxUserPermissions.contains('duty_punch')) {
                          return Column(
                            children: [
                              const DutyStatusCard(),
                              SizedBox(height: 12.h),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      const HomeGrid(),
                      SizedBox(height: 10.h),
                      Center(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: 14.h,
                            horizontal: 10.w,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.05),
                              width: 1.r,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
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
                      ),
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
}
