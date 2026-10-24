// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/selfie_attendance/controllers/selfie_attendance_controller.dart';
import 'package:mfresh_ops/modules/selfie_attendance/views/widgets/selfie_attendance_filter_bar.dart';
import 'package:mfresh_ops/modules/selfie_attendance/views/widgets/selfie_attendance_report_table.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
// endregion

// region View
class SelfieAttendanceReportScreen extends GetView<SelfieAttendanceController> {
  const SelfieAttendanceReportScreen({super.key});

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      drawer: const CommonSidebar(),
      body: SafeArea(
        child: AppRefreshIndicator(
          onRefresh: () async => controller.fetchReport(page: 1),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SelfieAttendanceFilterBar(),
                SizedBox(height: 14.h),
                const SelfieAttendanceReportTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // endregion

  // region Header & App Bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppCommonAppBar(
      backgroundColor: AppColors.white,
      elevation: 1,
      showAppDrawer: true,
      hasBackButton: false,
      topHeader: const CommonShortcutHeader(),
      toolbarHeight: 45.h,
      title: Text(
        'Selfie Attendance Report',
        style: AppTextStyle.style_16_700(color: AppColors.black),
      ),
      actions: [
        Obx(
          () => Center(
            child: Padding(
              padding: EdgeInsets.only(right: 14.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.borderColor, width: 1.r),
                ),
                child: Text(
                  'Data: ${controller.totalRecords.value}',
                  style: AppTextStyle.style_11_600(color: AppColors.grey600),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  // endregion
}
// endregion
