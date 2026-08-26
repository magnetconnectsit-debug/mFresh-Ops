import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:core/widgets/month_year_picker_field.dart';

class DashboardFilters extends GetView<DashboardController> {
  const DashboardFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildFilterCard(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      child: Obx(() {
                        final selectedUnitIds = controller.rxSelectedUnitIds;

                        final items = controller.units
                            .map(
                              (unit) => DropdownMenuItem(
                                value: unit.unitName,
                                child: Text(unit.unitName),
                              ),
                            )
                            .toList();

                        return MultiSelectDropdownWidget<String>(
                          isSingleSelect: false,
                          selectedValues: selectedUnitIds,
                          items: items,
                          onChanged: (vals) {
                            controller.setUnitFilters(vals);
                          },
                          customChild: _buildFilterHeaderRow(
                            'Units',
                            selectedUnitIds.isEmpty
                                ? 'Select Unit(s)'
                                : selectedUnitIds.length == 1
                                ? selectedUnitIds.first
                                : '${selectedUnitIds.length} units',
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => controller.resetFilters(),
                    child: _buildFilterCard(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh,
                            size: 16.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Reset',
                            style: AppTextStyle.style_12_600(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),

            _buildFilterCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterHeaderRow(
                    'Date',
                    'Custom',
                    isDropdown: false,
                    onActionTap: () => controller.showCustomDateRangePicker(),
                  ),
                  SizedBox(height: 6.h),
                  _buildFilterGrid(
                    items: {
                      'Yesterday': 'yesterday',
                      'Today': 'today',
                      'This Week': 'this_week',
                      'Last Week': 'last_week',
                      'This Month': 'this_month',
                      'Last Month': 'last_month',
                    },
                    crossAxisCount: 3,
                    selectedValue: controller.rxDateFilter.value,
                    onSelected: (val) => controller.setDateFilter(val),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),

            _buildFilterCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterHeaderRow('Mode Of Payment', ''),
                  SizedBox(height: 6.h),
                  _buildFilterGrid(
                    items: {
                      'ON - Cust': '0',
                      'ON - Ex_QR': '3',
                      'ON - In_QR': '2',
                      'Cash': '1',
                    },
                    crossAxisCount: 4,
                    selectedValue: controller.rxPaymentMode.value,
                    onSelected: (val) => controller.setPaymentMode(val),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),

            _buildFilterCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterHeaderRow(
                    'Months',
                    'Custom',
                    isDropdown: false,
                    onActionTap: () => _showCustomMonthRangeDialog(context),
                  ),
                  SizedBox(height: 6.h),
                  _buildFilterGrid(
                    items: {
                      'Last 3 Months': 'threemonth',
                      'Last 6 Months': 'sixmonth',
                    },
                    crossAxisCount: 2,
                    selectedValue: controller.rxMonthFilter.value,
                    onSelected: (val) => controller.setMonthFilter(val),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),

            _buildFilterCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterHeaderRow('Growth Rate', ''),
                  SizedBox(height: 6.h),
                  _buildFilterGrid(
                    items: {
                      'Monthly': 'monthly',
                      'Quarterly': 'quarterly',
                      'Half Yearly': 'halfyearly',
                    },
                    crossAxisCount: 3,
                    selectedValue: controller.rxGrowthFilter.value,
                    onSelected: (val) => controller.setGrowthFilter(val),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildFilterHeaderRow(
    String title,
    String action, {
    bool isDropdown = true,
    VoidCallback? onActionTap,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyle.style_14_600(color: AppColors.primary),
        ),
        if (action.isNotEmpty) ...[
          SizedBox(width: 12.w),
          Flexible(
            child: GestureDetector(
              onTap: onActionTap,
              child: isDropdown
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey300),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            action,
                            style: AppTextStyle.style_12_400(
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 16.r,
                            color: AppColors.grey500,
                          ),
                        ],
                      ),
                    )
                  : Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        action,
                        style: AppTextStyle.style_12_500(color: Colors.blue),
                      ),
                    ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFilterGrid({
    required Map<String, String> items,
    required int crossAxisCount,
    required String? selectedValue,
    required void Function(String) onSelected,
    bool isWrap = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = 6.w;
        final double width = isWrap
            ? 100.w
            : ((constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
                      crossAxisCount) -
                  0.1;

        return Wrap(
          spacing: spacing,
          runSpacing: 6.h,
          children: items.entries.map((entry) {
            final isSelected = selectedValue == entry.value;

            return GestureDetector(
              onTap: () => onSelected(entry.value),
              child: Container(
                width: width,
                padding: EdgeInsets.symmetric(vertical: 6.h),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    entry.key,
                    style: AppTextStyle.style_10_600(
                      color: isSelected ? Colors.white : AppColors.black,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showCustomMonthRangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _CustomMonthRangeDialog(
        initialFrom: controller.rxFromMonth.value,
        initialTo: controller.rxToMonth.value,
        onApply: (from, to) {
          if (from != null) controller.setCustomFromMonth(from);
          if (to != null) controller.setCustomToMonth(to);
        },
      ),
    );
  }
}

class _CustomMonthRangeDialog extends StatefulWidget {
  const _CustomMonthRangeDialog({
    this.initialFrom,
    this.initialTo,
    required this.onApply,
  });

  final String? initialFrom;
  final String? initialTo;
  final void Function(String? from, String? to) onApply;

  @override
  State<_CustomMonthRangeDialog> createState() =>
      _CustomMonthRangeDialogState();
}

class _CustomMonthRangeDialogState extends State<_CustomMonthRangeDialog> {
  String? _fromMonth;
  String? _toMonth;

  @override
  void initState() {
    super.initState();
    _fromMonth = widget.initialFrom;
    _toMonth = widget.initialTo;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 16.r,
                  color: AppColors.primary,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Select Month Range',
                  style: AppTextStyle.style_16_700(color: AppColors.primary),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.close,
                    size: 16.r,
                    color: AppColors.grey300,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Divider(height: 1, color: AppColors.borderColor),
            SizedBox(height: 16.h),

            // From Month
            Text(
              'From Month',
              style: AppTextStyle.style_12_500(color: AppColors.grey700),
            ),
            SizedBox(height: 8.h),
            MonthYearPickerField(
              value: _fromMonth,
              label: 'Select start month',
              showFloatingLabel: false,
              onChanged: (v) => setState(() => _fromMonth = v),
            ),

            SizedBox(height: 16.h),

            // To Month
            Text(
              'To Month',
              style: AppTextStyle.style_12_500(color: AppColors.grey700),
            ),
            SizedBox(height: 8.h),
            MonthYearPickerField(
              value: _toMonth,
              label: 'Select end month',
              showFloatingLabel: false,
              onChanged: (v) => setState(() => _toMonth = v),
            ),

            SizedBox(height: 24.h),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_fromMonth != null || _toMonth != null)
                    ? () {
                        widget.onApply(_fromMonth, _toMonth);
                        Navigator.of(context).pop();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Apply',
                  style: AppTextStyle.style_14_600(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
