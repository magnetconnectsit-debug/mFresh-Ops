import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:mfresh_ops/modules/attendance_log/controllers/attendance_log_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';

class AttendanceLogFilters extends GetView<AttendanceLogController> {
  const AttendanceLogFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Obx(() {
                return MultiSelectDropdownWidget<int>(
                  isSingleSelect: false,
                  label: 'Employee',
                  selectedValues: controller.selectedEmployeeIds.toSet(),
                  items: controller.allEmployees
                      .map((emp) => DropdownMenuItem<int>(
                            value: emp['id'] as int,
                            child: Text(emp['name']?.toString() ?? 'Unknown',
                                style: AppTextStyle.style_12_400(
                                    color: AppColors.grey900)),
                          ))
                      .toList(),
                  onChanged: (values) {
                    controller.selectedEmployeeIds.assignAll(values);
                    controller.fetchAttendanceLog();
                  },
                );
              }),
            ),
            SizedBox(width: 8.w),
            Expanded(
              flex: 1,
              child: Obx(() => _buildDatePickerField(
                    'From Date',
                    AppDateUtils.formatToApiDate(controller.startDate.value),
                    controller.showCustomDateRangePicker,
                  )),
            ),
            SizedBox(width: 8.w),
            Expanded(
              flex: 1,
              child: Obx(() => _buildDatePickerField(
                    'To Date',
                    AppDateUtils.formatToApiDate(controller.endDate.value),
                    controller.showCustomDateRangePicker,
                  )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePickerField(
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: AppTextStyle.style_12_400(color: AppColors.grey200),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: BorderSide(color: AppColors.grey50),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: BorderSide(color: AppColors.grey50),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value.isEmpty ? 'Select Date' : value,
                style: AppTextStyle.style_10_400(color: AppColors.grey900),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
