import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/widgets/month_range_picker.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';
import '../../controllers/daily_task_filter_controller.dart';

class DailyTaskFilterBar extends StatelessWidget {
  final DailyTaskFilterController controller;

  const DailyTaskFilterBar({
    super.key,
    required this.controller,
  });

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _getMonthName(int? monthValue) {
    if (monthValue != null && monthValue >= 1 && monthValue <= 12) {
      return _monthNames[monthValue - 1];
    }
    return '';
  }

  String _getMonthDisplayText(int? year, int? from, int? to) {
    final fromName = _getMonthName(from);
    final toName = _getMonthName(to);
    final yearStr = year != null ? '$year' : '';

    if (fromName.isNotEmpty && toName.isNotEmpty) {
      if (from == to) {
        return yearStr.isNotEmpty ? '$fromName $yearStr' : fromName;
      }
      return yearStr.isNotEmpty ? '$fromName - $toName $yearStr' : '$fromName - $toName';
    } else if (fromName.isNotEmpty) {
      return yearStr.isNotEmpty ? '$fromName $yearStr' : fromName;
    } else if (toName.isNotEmpty) {
      return yearStr.isNotEmpty ? '$toName $yearStr' : toName;
    }
    return yearStr;
  }

  Future<void> _openMonthRangePicker(BuildContext context) async {
    final DateTime? initialStart = controller.selectedFromMonth.value != null
        ? DateTime(
            controller.selectedYear.value ?? DateTime.now().year,
            controller.selectedFromMonth.value!,
          )
        : null;
    final DateTime? initialEnd = controller.selectedToMonth.value != null
        ? DateTime(
            controller.selectedYear.value ?? DateTime.now().year,
            controller.selectedToMonth.value!,
          )
        : null;

    final DateTimeRange? picked = await showMonthRangePicker(
      context,
      initialStartMonth: initialStart,
      initialEndMonth: initialEnd,
    );

    if (picked != null) {
      controller.selectedYear.value = picked.start.year;
      controller.selectedFromMonth.value = picked.start.month;
      controller.selectedToMonth.value = picked.end.month;
      controller.fetchFilterData();
    }
  }

  Widget _buildMonthSelectorField({
    required BuildContext context,
    required String label,
    required String valueText,
    required bool hasValue,
  }) {
    return MultiSelectDropdownWidget<String>(
      label: label,
      isSingleSelect: true,
      showSearch: false,
      hint: 'Select',
      selectedValues: hasValue ? {valueText} : <String>{},
      items: const [],
      onChanged: (_) {},
      customChild: Builder(
        builder: (fieldContext) => InkWell(
          onTap: () => _openMonthRangePicker(fieldContext),
          child: InputDecorator(
            decoration: InputDecoration(
              label: RichText(
                text: TextSpan(
                  text: label,
                  style: AppTextStyle.style_12_400(color: AppColors.grey200),
                ),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 10.w, vertical: 4.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: BorderSide(
                    color: AppColors.borderColor, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: BorderSide(
                    color: AppColors.borderColor, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: BorderSide(
                    color: AppColors.borderColor, width: 1.0),
              ),
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: 4.w),
                child: Icon(
                  Icons.calendar_month_outlined,
                  size: 16.r,
                  color: AppColors.grey300,
                ),
              ),
              suffixIconConstraints:
                  BoxConstraints(minWidth: 20.w, minHeight: 20.h),
            ),
            child: Text(
              hasValue ? valueText : 'Select',
              style: hasValue
                  ? AppTextStyle.style_12_400(color: AppColors.grey900)
                  : AppTextStyle.style_12_400(color: AppColors.grey300)
                      .copyWith(fontSize: 11.sp),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Month/Year & Assignee
          Row(
            children: [
              // Combined Month & Year Field
              Expanded(
                flex: 1,
                child: Obx(() {
                  final monthText = _getMonthDisplayText(
                    controller.selectedYear.value,
                    controller.selectedFromMonth.value,
                    controller.selectedToMonth.value,
                  );
                  final hasValue = monthText.isNotEmpty;
                  return _buildMonthSelectorField(
                    context: context,
                    label: 'Month',
                    valueText: monthText,
                    hasValue: hasValue,
                  );
                }),
              ),
              SizedBox(width: 6.w),
              // Assignee Field
              Expanded(
                flex: 1,
                child: Obx(
                  () => MultiSelectDropdownWidget<AssigneeModel>(
                    label: 'Assignee',
                    isSingleSelect: false,
                    showSelectAll: true,
                    selectedValues: controller.selectedAssignees.toSet(),
                    items: controller.assigneesOptions.map((a) {
                      return DropdownMenuItem<AssigneeModel>(
                        value: a,
                        child: Text(
                          a.name,
                          style: AppTextStyle.style_12_400(
                              color: AppColors.grey900),
                        ),
                      );
                    }).toList(),
                    onChanged: (values) {
                      controller.selectedAssignees.assignAll(values);
                      controller.fetchFilterData();
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Row 2: Reset, Create Task
          Row(
            children: [
              // Reset Button
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 24.h,
                  child: InkWell(
                    onTap: () => controller.resetFilters(),
                    borderRadius: BorderRadius.circular(4.r),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.borderColor),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh_rounded, size: 13.r, color: const Color(0xFFEF4444)),
                          SizedBox(width: 2.w),
                          Text(
                            'Reset',
                            style: AppTextStyle.style_11_600(color: const Color(0xFFEF4444)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              // Create Task Button
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 24.h,
                  child: InkWell(
                    onTap: () => Get.toNamed(AppRoutes.createTask),
                    borderRadius: BorderRadius.circular(4.r),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E9F6E),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Create Task',
                        style: AppTextStyle.style_11_600(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
