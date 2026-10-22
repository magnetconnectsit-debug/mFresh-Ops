import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/attendance_log/controllers/attendance_log_controller.dart';

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
                  showSelectAll: true,
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
              flex: 2,
              child: Obx(() {
                final dateRangeStr = AppDateUtils.formatDateRangeOrdinal(
                  controller.startDate.value,
                  controller.endDate.value,
                  defaultText: 'Select Date Range',
                );
                return _buildDatePickerField(
                  'Date Range',
                  dateRangeStr,
                  controller.showCustomDateRangePicker,
                );
              }),
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
          labelStyle: AppTextStyle.style_11_500(color: AppColors.grey300),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.0.h),
          filled: true,
          fillColor: AppColors.aliceBlue,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: BorderSide(color: AppColors.fieldBorderColor, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: BorderSide(color: AppColors.fieldBorderColor, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        child: SizedBox(
          height: 18.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value.isEmpty ? 'Select Date' : value,
                  style: AppTextStyle.style_12_400(color: AppColors.grey900),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
