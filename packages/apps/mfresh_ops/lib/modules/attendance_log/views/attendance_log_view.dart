import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/attendance_log/controllers/attendance_log_controller.dart';
import 'package:mfresh_ops/modules/attendance_log/views/widgets/attendance_log_filters.dart';
import 'package:mfresh_ops/modules/attendance_log/views/widgets/attendance_log_stats.dart';
import 'package:mfresh_ops/modules/attendance_log/views/widgets/attendance_log_table.dart';

import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';

class AttendanceLogView extends GetView<AttendanceLogController> {
  const AttendanceLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCommonAppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        showAppDrawer: true,
        hasBackButton: false,
        topHeader: const CommonShortcutHeader(),
        toolbarHeight: 45.h,
        title: Text(
          "Attendance Log",
          style: AppTextStyle.style_18_700(color: Colors.black),
        ),
      ),
      drawer: const CommonSidebar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.w, 5.h, 10.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selected Employees Chips
              Obx(() {
                if (controller.selectedEmployeeIds.isEmpty)
                  return const SizedBox.shrink();

                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: controller.selectedEmployeeIds.map((id) {
                      final emp = controller.allEmployees.firstWhere(
                        (e) => e['id'] == id,
                        orElse: () => <String, dynamic>{},
                      );
                      final name = emp['name']?.toString() ?? 'Unknown';

                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              name,
                              style: AppTextStyle.style_10_500(
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            InkWell(
                              onTap: () {
                                controller.selectedEmployeeIds.remove(id);
                                controller.fetchAttendanceLog();
                              },
                              child: Icon(
                                Icons.close,
                                size: 10.r,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),

              // Filters and Stats Container
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.grey50),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AttendanceLogFilters(),
                    SizedBox(height: 10.h),
                    const AttendanceLogStats(),
                  ],
                ),
              ),
              SizedBox(height: 10.h),

              // Table
              const Expanded(child: AttendanceLogTable()),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
