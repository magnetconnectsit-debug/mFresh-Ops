import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/attendance_log/controllers/attendance_log_controller.dart';
import 'package:mfresh_ops/data/models/tracking/attendance_breakdown_model.dart';

class AttendanceBreakdownDialog extends GetView<AttendanceLogController> {
  final String employeeName;
  final String date;

  const AttendanceBreakdownDialog({
    super.key,
    required this.employeeName,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      insetPadding: EdgeInsets.all(16.r),
      child: Container(
        width: 1000.w,
        constraints: BoxConstraints(maxHeight: 700.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 16.w, 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Attendance Breakdown - $date ($employeeName)',
                    style: AppTextStyle.style_18_600(color: AppColors.grey900),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.grey600),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.grey200),
            
            // Content
            Expanded(
              child: Obx(() {
                if (controller.isLoadingBreakdown.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final breakdown = controller.breakdownData.value;
                if (breakdown == null) {
                  return const Center(child: Text('No breakdown data found'));
                }

                final timeline = controller.filteredTimeline;

                return Column(
                  children: [
                    // Filters and Summary
                    Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Row(
                        children: [
                          // Dropdown
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Filter By Status', style: AppTextStyle.style_12_500(color: AppColors.grey700)),
                                SizedBox(height: 8.h),
                                Container(
                                  height: 40.h,
                                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.grey300),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: controller.selectedBreakdownFilter.value,
                                      isExpanded: true,
                                      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.grey600),
                                      items: ['All', 'Online', 'Offline'].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value, style: AppTextStyle.style_14_400(color: AppColors.grey900)),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          controller.selectedBreakdownFilter.value = val;
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16.w),
                          
                          // Summaries
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                _buildSummaryCard(Icons.wifi, breakdown.summary?.onlineDuration ?? '0h 0m', const Color(0xFF2E7D32)),
                                SizedBox(width: 12.w),
                                _buildSummaryCard(Icons.wifi_off, breakdown.summary?.offlineDuration ?? '0h 0m', const Color(0xFFD32F2F)),
                                SizedBox(width: 12.w),
                                _buildSummaryCard(Icons.filter_alt_outlined, breakdown.summary?.totalDuration ?? '0h 0m', const Color(0xFF1976D2)),
                              ],
                            ),
                          ),
                          
                          // Records Count
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Text(
                                'Showing: ${timeline.length} Records',
                                style: AppTextStyle.style_12_500(color: AppColors.grey600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Table
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey200),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildTableHeader(),
                              Expanded(
                                child: timeline.isEmpty
                                    ? Center(
                                        child: Text(
                                          'No tracking data found.',
                                          style: AppTextStyle.style_14_400(color: AppColors.grey500),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: timeline.length,
                                        itemBuilder: (context, index) {
                                          return _buildTableRow(timeline[index]);
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
            
            // Footer
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C757D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(IconData icon, String value, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(top: 24.h), // align with bottom of dropdown
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey200),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 12.w),
            Text(
              value,
              style: AppTextStyle.style_16_700(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(
        children: [
          _buildCell('Type', 100),
          _buildCell('From', 120),
          _buildCell('To', 120),
          _buildCell('Duration', 120),
          Expanded(child: _buildCell('Last Location', 0)), // 0 means ignore width
        ],
      ),
    );
  }

  Widget _buildTableRow(BreakdownTimeline row) {
    final isOnline = row.type.toLowerCase() == 'online';
    final pillColor = isOnline ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F);
    
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(
        children: [
          Container(
            width: 100.w,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: pillColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                row.type.capitalizeFirst ?? '',
                style: AppTextStyle.style_12_500(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          _buildCell(row.from, 120),
          _buildCell(row.to, 120),
          Container(
            width: 120.w,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            child: Text(
              row.duration,
              style: AppTextStyle.style_12_500(color: pillColor),
            ),
          ),
          Expanded(child: _buildCell(row.location, 0)),
        ],
      ),
    );
  }

  Widget _buildCell(String text, double width) {
    return Container(
      width: width > 0 ? width.w : null,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: AppTextStyle.style_12_500(color: AppColors.grey800),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
