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
      final activeFilter = controller.selectedStatusFilter.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatCard('Present', summary.present.toString(), const Color(0xFFE8F5E9), const Color(0xFF2E7D32), activeFilter == 'Present'),
          _buildStatCard('Absent', summary.absent.toString(), const Color(0xFFFFEBEE), const Color(0xFFD32F2F), activeFilter == 'Absent'),
          _buildStatCard('Late', summary.late.toString(), const Color(0xFFFFF3E0), const Color(0xFFE65100), activeFilter == 'Late'),
          _buildStatCard('Shortage', summary.shortage.toString(), const Color(0xFFF3E5F5), const Color(0xFF7B1FA2), activeFilter == 'Shortage'),
        ],
      );
    });
  }

  Widget _buildStatCard(String title, String value, Color bgColor, Color textColor, bool isSelected) {
    return Expanded(
      child: InkWell(
        onTap: () => controller.toggleStatusFilter(title),
        borderRadius: BorderRadius.circular(4.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 24.h,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: isSelected ? textColor.withValues(alpha: 0.15) : bgColor,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(
              color: isSelected ? textColor : textColor.withValues(alpha: 0.3),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: AppTextStyle.style_10_500(color: textColor).copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                value,
                style: AppTextStyle.style_12_600(color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
