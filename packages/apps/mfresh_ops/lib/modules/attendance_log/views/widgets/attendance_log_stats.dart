import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/attendance_log/controllers/attendance_log_controller.dart';

class AttendanceLogStats extends GetView<AttendanceLogController> {
  const AttendanceLogStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summary = controller.responseData.value?.summary;
      if (summary == null) {
        return const SizedBox.shrink();
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatCard('Present', summary.present.toString(), const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
          _buildStatCard('Absent', summary.absent.toString(), const Color(0xFFFFEBEE), const Color(0xFFD32F2F)),
          _buildStatCard('Late', summary.late.toString(), const Color(0xFFFFF3E0), const Color(0xFFE65100)),
        ],
      );
    });
  }

  Widget _buildStatCard(String title, String value, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        height: 24.h,
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: textColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: AppTextStyle.style_10_500(color: textColor),
            ),
            Text(
              value,
              style: AppTextStyle.style_12_600(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
