// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/selfie_attendance/controllers/selfie_attendance_detail_controller.dart';
import 'package:mfresh_ops/modules/selfie_attendance/views/widgets/selfie_attendance_detail_table.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
// endregion

// region View
class SelfieAttendanceDetailScreen
    extends GetView<SelfieAttendanceDetailController> {
  const SelfieAttendanceDetailScreen({super.key});

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CustomAppLoader());
          }

          return AppRefreshIndicator(
            onRefresh: () async => controller.fetchLogs(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSummaryCards(),
                  SizedBox(height: 14.h),
                  const SelfieAttendanceDetailTable(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
  // endregion

  // region Header & App Bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppCommonAppBar(
      backgroundColor: AppColors.white,
      elevation: 1,
      showAppDrawer: false,
      hasBackButton: true,
      topHeader: const CommonShortcutHeader(),
      toolbarHeight: 45.h,
      title: Text(
        'Selfie Report Detail',
        style: AppTextStyle.style_18_700(color: AppColors.black),
      ),
    );
  }
  // endregion

  // region Section Builders
  Widget _buildSummaryCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useThreeColumns = constraints.maxWidth >= 360;
        return useThreeColumns
            ? _buildThreeColumnLayout()
            : _buildTwoColumnLayout();
      },
    );
  }

  Widget _buildThreeColumnLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _buildField(
              controller: controller.employeeController,
              label: 'Employee',
            ),
            SizedBox(width: 8.w),
            _buildField(
              controller: controller.dateController,
              label: 'Date',
            ),
            SizedBox(width: 8.w),
            _buildField(
              controller: controller.unitsController,
              label: 'Unit(s)',
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            _buildField(
              controller: controller.firstInController,
              label: 'First In',
            ),
            SizedBox(width: 8.w),
            _buildField(
              controller: controller.lastOutController,
              label: 'Last Out',
            ),
            SizedBox(width: 8.w),
            _buildField(
              controller: controller.totalDurationController,
              label: 'Total Duration',
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            _buildField(
              controller: controller.breakDurationController,
              label: 'Break Duration',
            ),
            SizedBox(width: 8.w),
            _buildField(
              controller: controller.actualDurationController,
              label: 'Actual Duration',
            ),
            SizedBox(width: 8.w),
            _buildField(
              controller: controller.totalSessionsController,
              label: 'Total Sessions',
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            _buildField(
              controller: controller.completedOpenController,
              label: 'Completed / Open',
            ),
            SizedBox(width: 8.w),
            const Expanded(child: SizedBox.shrink()),
            SizedBox(width: 8.w),
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
      ],
    );
  }

  Widget _buildTwoColumnLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _buildField(
              controller: controller.employeeController,
              label: 'Employee',
            ),
            SizedBox(width: 8.w),
            _buildField(
              controller: controller.dateController,
              label: 'Date',
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            _buildField(
              controller: controller.unitsController,
              label: 'Unit(s)',
            ),
            SizedBox(width: 8.w),
            _buildField(
              controller: controller.firstInController,
              label: 'First In',
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            _buildField(
              controller: controller.lastOutController,
              label: 'Last Out',
            ),
            SizedBox(width: 8.w),
            _buildField(
              controller: controller.totalDurationController,
              label: 'Total Duration',
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            _buildField(
              controller: controller.breakDurationController,
              label: 'Break Duration',
            ),
            SizedBox(width: 8.w),
            _buildField(
              controller: controller.actualDurationController,
              label: 'Actual Duration',
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            _buildField(
              controller: controller.totalSessionsController,
              label: 'Total Sessions',
            ),
            SizedBox(width: 8.w),
            _buildField(
              controller: controller.completedOpenController,
              label: 'Completed / Open',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
  }) {
    return Expanded(
      child: AppCommonTextField(
        controller: controller,
        labelText: label,
        hintText: label,
        readOnly: true,
      ),
    );
  }
  // endregion
}
// endregion
