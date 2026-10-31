// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_multi_select_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/selfie_attendance/controllers/selfie_attendance_controller.dart';
// endregion

// region View
class SelfieAttendanceFilterBar extends StatelessWidget {
  const SelfieAttendanceFilterBar({super.key});

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SelfieAttendanceController>();

    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeaderRow(controller),
          SizedBox(height: 8.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;

              if (isMobile) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDateRangeField(context, controller),
                    SizedBox(height: 8.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: _buildUserDropdown(controller)),
                        SizedBox(width: 6.w),
                        Expanded(child: _buildUnitDropdown(controller)),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: _buildDateRangeField(context, controller)),
                  SizedBox(width: 6.w),
                  Expanded(child: _buildUserDropdown(controller)),
                  SizedBox(width: 6.w),
                  Expanded(child: _buildUnitDropdown(controller)),
                ],
              );
            },
          ),
          _buildActiveFilterChips(controller),
        ],
      ),
    );
  }
  // endregion

  // region Section Builders
  Widget _buildHeaderRow(SelfieAttendanceController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 2.w),
          child: Text(
            'Filters',
            style: AppTextStyle.style_14_600(color: AppColors.black),
          ),
        ),
        Obx(() {
          final hasFilter = controller.fromDate.value != null ||
              controller.selectedUserIds.isNotEmpty ||
              controller.selectedUnitIds.isNotEmpty;
          if (!hasFilter) return const SizedBox.shrink();
          return InkWell(
            onTap: controller.resetFilters,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Text(
                'Reset All',
                style: AppTextStyle.style_12_600(color: AppColors.primary),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDateRangeField(
    BuildContext context,
    SelfieAttendanceController controller,
  ) {
    return InkWell(
      onTap: () => controller.pickDateRange(context),
      child: Obx(() {
        final hasDates = controller.fromDate.value != null &&
            controller.fromDate.value!.isNotEmpty;
        final displayText = hasDates ? controller.dateRangeText.value : '';

        return InputDecorator(
          decoration: InputDecoration(
            labelText: 'Select Date Range',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelStyle: AppTextStyle.style_11_500(color: AppColors.grey300),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 6.w,
              vertical: 2.0.h,
            ),
            filled: true,
            fillColor: AppColors.aliceBlue,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: const BorderSide(
                color: AppColors.fieldBorderColor,
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: const BorderSide(
                color: AppColors.fieldBorderColor,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
          child: SizedBox(
            height: 18.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    displayText.isEmpty ? 'Select Date Range' : displayText,
                    style: displayText.isEmpty
                        ? AppTextStyle.style_12_400(color: AppColors.grey300)
                        : AppTextStyle.style_12_400(color: AppColors.grey900),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (hasDates)
                  InkWell(
                    onTap: controller.clearDateRange,
                    child: Padding(
                      padding: EdgeInsets.all(2.r),
                      child: Icon(
                        Icons.close,
                        size: 13.sp,
                        color: AppColors.grey500,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 13.sp,
                    color: AppColors.grey300,
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildUserDropdown(SelfieAttendanceController controller) {
    return Obx(() {
      final items = controller.usersList
          .map((u) => DropdownMenuItem<int>(
                value: u.id,
                child: Text(
                  u.name,
                  style: AppTextStyle.style_12_400(
                    color: AppColors.grey900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList();

      return AppCommonMultiSelectDropdown<int>(
        label: 'Select User',
        hint: 'User(s)',
        showSelectAll: true,
        showSearch: true,
        selectedValues: controller.selectedUserIds.toSet(),
        items: items,
        onChanged: (selected) {
          controller.onUserSelectionChanged(selected);
        },
      );
    });
  }

  Widget _buildUnitDropdown(SelfieAttendanceController controller) {
    return Obx(() {
      final items = controller.unitsList
          .map((u) {
            final displayName = u.unitId.isNotEmpty
                ? u.unitId
                : (u.unitLocation.isNotEmpty
                    ? u.unitLocation
                    : 'Unit #${u.id}');
            return DropdownMenuItem<int>(
              value: u.id,
              child: Text(
                displayName,
                style: AppTextStyle.style_12_400(
                  color: AppColors.grey900,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          })
          .toList();

      return AppCommonMultiSelectDropdown<int>(
        label: 'Select Unit',
        hint: 'Unit(s)',
        showSelectAll: true,
        showSearch: true,
        selectedValues: controller.selectedUnitIds.toSet(),
        items: items,
        onChanged: (selected) {
          controller.onUnitSelectionChanged(selected);
        },
      );
    });
  }


  Widget _buildActiveFilterChips(SelfieAttendanceController controller) {
    return Obx(() {
      final hasDate = controller.fromDate.value != null &&
          controller.fromDate.value!.isNotEmpty;
      final selectedUsers = controller.selectedUserIds;
      final selectedUnits = controller.selectedUnitIds;

      if (!hasDate && selectedUsers.isEmpty && selectedUnits.isEmpty) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Active Filters:',
                style: AppTextStyle.style_11_600(color: AppColors.grey500),
              ),
              SizedBox(width: 6.w),
              if (hasDate)
                Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: _buildChip(
                    label: controller.dateRangeText.value,
                    onDeleted: controller.clearDateRange,
                  ),
                ),
              for (final userId in selectedUsers) ...[
                Builder(builder: (context) {
                  final userName = controller.usersList
                      .firstWhereOrNull((u) => u.id == userId)
                      ?.name ??
                      'User #$userId';
                  return Padding(
                    padding: EdgeInsets.only(right: 6.w),
                    child: _buildChip(
                      label: userName,
                      onDeleted: () {
                        final updated = Set<int>.from(controller.selectedUserIds)
                          ..remove(userId);
                        controller.onUserSelectionChanged(updated);
                      },
                    ),
                  );
                }),
              ],
              for (final unitId in selectedUnits) ...[
                Builder(builder: (context) {
                  final unit = controller.unitsList
                      .firstWhereOrNull((u) => u.id == unitId);
                  final unitName = unit != null
                      ? (unit.unitId.isNotEmpty
                          ? unit.unitId
                          : (unit.unitLocation.isNotEmpty
                              ? unit.unitLocation
                              : 'Unit #${unit.id}'))
                      : 'Unit #$unitId';
                  return Padding(
                    padding: EdgeInsets.only(right: 6.w),
                    child: _buildChip(
                      label: unitName,
                      onDeleted: () {
                        final updated = Set<int>.from(controller.selectedUnitIds)
                          ..remove(unitId);
                        controller.onUnitSelectionChanged(updated);
                      },
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.aliceBlue,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.fieldBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyle.style_10_500(color: AppColors.primary),
          ),
          SizedBox(width: 4.w),
          InkWell(
            onTap: onDeleted,
            child: Icon(
              Icons.close,
              size: 11.sp,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
  // endregion
}
// endregion
