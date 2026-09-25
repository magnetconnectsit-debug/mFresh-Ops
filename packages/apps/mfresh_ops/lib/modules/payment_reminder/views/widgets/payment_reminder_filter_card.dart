import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mfresh_ops/modules/payment_reminder/controllers/payment_reminder_controller.dart';
import 'package:mfresh_ops/data/models/payment_reminder/payment_reminder_model.dart';
import 'package:mfresh_ops/widgets/month_range_picker.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';

class PaymentReminderFilterCard extends StatelessWidget {
  final PaymentReminderController controller;

  const PaymentReminderFilterCard({super.key, required this.controller});

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
      controller.applyFilters();
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
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Header: Title + Reset
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: AppTextStyle.style_12_600(color: AppColors.grey800),
              ),
              InkWell(
                onTap: () => controller.resetFilters(),
                borderRadius: BorderRadius.circular(4.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, size: 14.r, color: AppColors.red),
                      SizedBox(width: 4.w),
                      Text(
                        'Reset',
                        style: AppTextStyle.style_12_600(color: AppColors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),

          // Row 1: Combined Month & Assignee
          Row(
            children: [
              Expanded(
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
              SizedBox(width: 8.w),
              Expanded(
                child: Obx(
                  () => MultiSelectDropdownWidget<PaymentReminderUser>(
                    label: 'Assignee',
                    selectedValues: controller.selectedAssignees.toSet(),
                    items: controller.users
                        .map<DropdownMenuItem<PaymentReminderUser>>(
                          (e) => DropdownMenuItem<PaymentReminderUser>(
                            value: e,
                            child: Text(
                              e.name ?? '-',
                              style: AppTextStyle.style_12_400(
                                color: AppColors.grey900,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (values) {
                      controller.selectedAssignees.assignAll(values);
                      controller.applyFilters();
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),

          // Row 2: Status
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  final statusOptions = [
                    {'value': 'due', 'label': 'Due'},
                    {'value': 'overdue', 'label': 'Overdue'},
                    {'value': 'upcoming', 'label': 'Upcoming'},
                  ];
                  return MultiSelectDropdownWidget<String>(
                    label: 'Status',
                    selectedValues: controller.selectedStatus.toSet(),
                    items: statusOptions
                        .map<DropdownMenuItem<String>>(
                          (opt) => DropdownMenuItem<String>(
                            value: opt['value']!,
                            child: Text(
                              opt['label']!,
                              style: AppTextStyle.style_12_400(color: AppColors.grey900),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (values) {
                      controller.selectedStatus.assignAll(values);
                      controller.applyFilters();
                    },
                  );
                }),
              ),
              SizedBox(width: 8.w),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ],
      ),
    );
  }
}
