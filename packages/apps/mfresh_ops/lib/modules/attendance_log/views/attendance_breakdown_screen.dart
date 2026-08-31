import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:mfresh_ops/modules/attendance_log/controllers/attendance_log_controller.dart';
import 'package:mfresh_ops/data/models/tracking/attendance_breakdown_model.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';

class AttendanceBreakdownScreen extends GetView<AttendanceLogController> {
  final String employeeName;
  final String date;

  const AttendanceBreakdownScreen({
    super.key,
    required this.employeeName,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.grey200),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.grey800, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Attendance Breakdown',
              style: AppTextStyle.style_16_700(color: AppColors.grey900),
            ),
            SizedBox(height: 2.h),
            Text(
              '${AppDateUtils.formatToOrdinalDate(date)}  ·  $employeeName',
              style: AppTextStyle.style_12_400(color: AppColors.grey600),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingBreakdown.value) {
          return const Center(child: CustomAppLoader());
        }

        final breakdown = controller.breakdownData.value;
        if (breakdown == null) {
          return Center(
            child: Text(
              'No breakdown data found.',
              style: AppTextStyle.style_14_400(color: AppColors.grey500),
            ),
          );
        }

        final timeline = controller.filteredTimeline;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Filter + Summary section ────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 78.w, // Decreased to fit 4 on screen
                          child: MultiSelectDropdownWidget<String>(
                            height: 30.h,
                            isSingleSelect: true,
                            label: 'Status',
                            selectedValues: {controller.selectedBreakdownFilter.value},
                            items: ['All', 'Online', 'Offline']
                                .map((v) => DropdownMenuItem<String>(
                                      value: v,
                                      child: Text(v,
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.grey900,
                                          )),
                                    ))
                                .toList(),
                            onChanged: (values) {
                              if (values.isNotEmpty) {
                                controller.selectedBreakdownFilter.value = values.first;
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 4.w),
                        // Summary cards
                        _summaryCard(
                          Icons.wifi,
                          breakdown.summary?.onlineDuration ?? '0h 0m',
                          const Color(0xFF2E7D32),
                        ),
                        SizedBox(width: 4.w),
                        _summaryCard(
                          Icons.wifi_off,
                          breakdown.summary?.offlineDuration ?? '0h 0m',
                          const Color(0xFFD32F2F),
                        ),
                        SizedBox(width: 4.w),
                        _summaryCard(
                          Icons.filter_alt_outlined,
                          breakdown.summary?.totalDuration ?? '0h 0m',
                          const Color(0xFF1976D2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  
                  // Showing count
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Showing: ${timeline.length} Records',
                      style: AppTextStyle.style_12_500(color: AppColors.grey600),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7.r),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 550.w, // 80 + 90 + 90 + 90 + 200
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTableHeader(),
                          timeline.isEmpty
                              ? Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32.h),
                                  child: Center(
                                    child: Text(
                                      'No tracking data found.',
                                      style: AppTextStyle.style_14_400(
                                          color: AppColors.grey500),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: timeline.length,
                                  itemBuilder: (_, i) =>
                                      _buildTableRow(timeline[i], i),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }),
    );
  }

  Widget _summaryCard(IconData icon, String value, Color color) {
    return Container(
      width: 78.w,
      height: 30.h,
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4.r),
        color: color.withValues(alpha: 0.05),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 10),
          SizedBox(width: 2.w),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD4E8D1),
        border: Border(bottom: BorderSide(color: Colors.grey.shade400)),
      ),
      child: Row(
        children: [
          _headerCell('Type', 80),
          _headerCell('From', 90),
          _headerCell('To', 90),
          _headerCell('Duration', 90),
          _headerCell('Last Location', 200),
        ],
      ),
    );
  }

  Widget _buildTableRow(BreakdownTimeline row, int index) {
    final isOnline = row.type.toLowerCase() == 'online';
    final pillColor =
        isOnline ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F);
    final isEven = index % 2 == 0;
    
    bool isExpanded = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Container(
            color: isEven ? Colors.white : const Color(0xFFFAFAFA),
            child: Row(
              children: [
          // Type pill
          SizedBox(
            width: 80.w,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: pillColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  row.type.capitalizeFirst ?? '',
                  style: AppTextStyle.style_11_600(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          _dataCell(row.from, 90),
          _dataCell(row.to, 90),
          // Duration colored
          SizedBox(
            width: 90.w,
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
              child: Text(
                row.duration,
                style: AppTextStyle.style_12_600(color: pillColor),
              ),
            ),
          ),
          SizedBox(
            width: 200.w,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
              child: Text(
                row.location.isEmpty ? 'Location not tracked' : row.location,
                style: AppTextStyle.style_12_400(color: AppColors.grey700),
                maxLines: isExpanded ? null : 1,
                overflow: isExpanded ? null : TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    ),
        );
      },
    );
  }

  Widget _headerCell(String label, double width) {
    return SizedBox(
      width: width.w,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        child: Text(
          label,
          style: AppTextStyle.style_12_600(color: AppColors.grey700),
        ),
      ),
    );
  }

  Widget _dataCell(String text, double width) {
    return SizedBox(
      width: width.w,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        child: Text(
          text,
          style: AppTextStyle.style_12_400(color: AppColors.grey800),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
