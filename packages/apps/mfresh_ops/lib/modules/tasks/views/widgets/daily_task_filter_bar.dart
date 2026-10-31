// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/widgets/month_range_picker.dart';
import '../../controllers/daily_task_filter_controller.dart';
// endregion

// region DailyTaskFilterBar Widget
class DailyTaskFilterBar extends StatelessWidget {
  // region Properties & Constants
  final DailyTaskFilterController controller;

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  // endregion

  // region Constructor
  const DailyTaskFilterBar({
    super.key,
    required this.controller,
  });
  // endregion

  // region Month Formatter Helpers
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
      return yearStr.isNotEmpty
          ? '$fromName - $toName $yearStr'
          : '$fromName - $toName';
    } else if (fromName.isNotEmpty) {
      return yearStr.isNotEmpty ? '$fromName $yearStr' : fromName;
    } else if (toName.isNotEmpty) {
      return yearStr.isNotEmpty ? '$toName $yearStr' : toName;
    }
    return yearStr;
  }
  // endregion

  // region Month Range Picker Dialog
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
  // endregion

  // region Month Selector Field Builder
  Widget _buildMonthSelectorField({
    required BuildContext context,
    required String label,
    required String valueText,
    required bool hasValue,
  }) {
    return AppCommonMultiSelectDropdown<String>(
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
                  style: AppTextStyle.style_11_500(color: AppColors.grey300),
                ),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 6.w,
                vertical: 2.0.h,
              ),
              filled: true,
              fillColor: AppColors.aliceBlue,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: BorderSide(
                  color: AppColors.fieldBorderColor,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: BorderSide(
                  color: AppColors.fieldBorderColor,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: 4.w),
                child: Icon(
                  Icons.calendar_month_outlined,
                  size: 16.r,
                  color: AppColors.grey300,
                ),
              ),
              suffixIconConstraints: BoxConstraints(
                minWidth: 20.w,
                minHeight: 20.h,
              ),
            ),
            child: SizedBox(
              height: 18.h,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hasValue ? valueText : 'Select',
                      style: hasValue
                          ? AppTextStyle.style_12_400(color: AppColors.grey900)
                          : AppTextStyle.style_12_400(color: AppColors.grey300),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  // endregion

  // region Main Build
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
          // Selected Filter Chips
          Obx(() {
            final List<Widget> chips = [];

            Widget buildChip(String label, VoidCallback onDeleted) {
              return Padding(
                padding: EdgeInsets.only(right: 4.w),
                child: InkWell(
                  onTap: onDeleted,
                  borderRadius: BorderRadius.circular(6.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColors.blue500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: AppColors.blue500.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: AppTextStyle.style_10_500(color: AppColors.blue500),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.close,
                          size: 12.r,
                          color: AppColors.blue500,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            for (var p in controller.selectedProjects) {
              chips.add(buildChip(p.projectName, () {
                controller.selectedProjects.remove(p);
                controller.fetchFilterData();
              }));
            }
            for (var u in controller.selectedUnits) {
              chips.add(buildChip(u.unitName, () {
                controller.selectedUnits.remove(u);
                controller.fetchFilterData();
              }));
            }
            for (var g in controller.selectedGroups) {
              chips.add(buildChip(g.roleName, () {
                controller.selectedGroups.remove(g);
                controller.fetchFilterData();
              }));
            }
            for (var a in controller.selectedAssignees) {
              chips.add(buildChip(a.name, () {
                controller.selectedAssignees.remove(a);
                controller.fetchFilterData();
              }));
            }

            if (chips.isEmpty) return const SizedBox.shrink();

            return Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: chips,
                ),
              ),
            );
          }),
          // Row 1: Month & Project
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
              // Project Multi-Select
              Expanded(
                flex: 1,
                child: Obx(
                  () => AppCommonMultiSelectDropdown<TaskProject>(
                    label: 'Project',
                    isSingleSelect: false,
                    showSelectAll: true,
                    selectedValues: controller.selectedProjects.toSet(),
                    items: controller.projectsOptions.map((p) {
                      return DropdownMenuItem<TaskProject>(
                        value: p,
                        child: Text(
                          p.projectName,
                          style: AppTextStyle.style_12_400(
                            color: AppColors.grey900,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (values) {
                      controller.selectedProjects.assignAll(values);
                      controller.fetchFilterData();
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          // Row 2: Group & Assignee
          Row(
            children: [
              // Group Multi-Select
              Expanded(
                flex: 1,
                child: Obx(
                  () => AppCommonMultiSelectDropdown<TaskGroup>(
                    label: 'Group',
                    isSingleSelect: false,
                    showSelectAll: true,
                    selectedValues: controller.selectedGroups.toSet(),
                    items: controller.groupsOptions.map((g) {
                      return DropdownMenuItem<TaskGroup>(
                        value: g,
                        child: Text(
                          g.roleName,
                          style: AppTextStyle.style_12_400(
                            color: AppColors.grey900,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (values) {
                      controller.selectedGroups.assignAll(values);
                      controller.fetchFilterData();
                    },
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              // Assignee Multi-Select
              Expanded(
                flex: 1,
                child: Obx(
                  () => AppCommonMultiSelectDropdown<AssigneeModel>(
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
                            color: AppColors.grey900,
                          ),
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
        ],
      ),
    );
  }
  // endregion
}
// endregion
