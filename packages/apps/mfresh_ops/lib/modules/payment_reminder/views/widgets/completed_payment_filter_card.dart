import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mfresh_ops/modules/payment_reminder/controllers/completed_payment_controller.dart';
import 'package:mfresh_ops/data/models/payment_reminder/payment_reminder_model.dart';
import 'package:mfresh_ops/widgets/month_range_picker.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';

class CompletedPaymentFilterCard extends StatelessWidget {
  final CompletedPaymentController controller;

  const CompletedPaymentFilterCard({super.key, required this.controller});

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
        children: [
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
          SizedBox(height: 8.h),
          // Row 2: Search, Reset, Apply
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 28.h,
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: (v) {
                      controller.searchQuery.value = v;
                    },
                    style: AppTextStyle.style_12_400(color: AppColors.grey900),
                    decoration: InputDecoration(
                      hintText: 'Search completed payments...',
                      hintStyle: AppTextStyle.style_12_400(color: AppColors.grey300),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.r),
                        borderSide: BorderSide(color: AppColors.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.r),
                        borderSide: BorderSide(color: AppColors.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.r),
                        borderSide: BorderSide(color: AppColors.borderColor),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              SizedBox(
                height: 28.h,
                child: OutlinedButton(
                  onPressed: () => controller.resetFilters(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                  ),
                  child: Text('Reset', style: AppTextStyle.style_12_500(color: AppColors.black)),
                ),
              ),
              SizedBox(width: 6.w),
              SizedBox(
                height: 28.h,
                child: ElevatedButton(
                  onPressed: () => controller.applyFilters(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                    elevation: 0,
                  ),
                  child: Text('Apply', style: AppTextStyle.style_12_500(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
