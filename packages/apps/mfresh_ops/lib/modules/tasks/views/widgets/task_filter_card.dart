// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
// endregion

// region TaskFilterCard Widget
class TaskFilterCard extends StatelessWidget {
  // region Properties
  final TasksController controller;
  final bool showMonthYearFilter;
  // endregion

  // region Constructor
  const TaskFilterCard({
    super.key,
    required this.controller,
    this.showMonthYearFilter = false,
  });
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final userPermissions = Get.find<AuthRepository>().rxUserPermissions;
    final canFilter = userPermissions.contains('Daily_Task_Filter');
    final canFilterProject = userPermissions.contains('Daily_Task_Project_Filter');
    final canFilterUnit = userPermissions.contains('Daily_Task_Unit_Filter');
    final canFilterGroup = userPermissions.contains('Daily_Task_Group_Filter');
    final canFilterAssignee = userPermissions.contains('Daily_Task_Assignee_Filter');

    if (!canFilter) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
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
          Obx(() {
            if (!controller.isFiltered) return const SizedBox.shrink();

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
                controller.applyFilters();
              }));
            }
            for (var u in controller.selectedUnits) {
              chips.add(buildChip(u.unitName, () {
                controller.selectedUnits.remove(u);
                controller.applyFilters();
              }));
            }
            for (var g in controller.selectedGroups) {
              chips.add(buildChip(g.roleName, () {
                controller.selectedGroups.remove(g);
                controller.applyFilters();
              }));
            }
            for (var a in controller.selectedAssignees) {
              chips.add(buildChip(a.name, () {
                controller.selectedAssignees.remove(a);
                controller.applyFilters();
              }));
            }

            if (showMonthYearFilter &&
                controller.selectedYear.value != null &&
                controller.selectedMonths.isNotEmpty) {
              const monthNames = [
                'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
              ];
              final sorted = List<int>.from(controller.selectedMonths)..sort();
              final names = sorted
                  .where((m) => m >= 1 && m <= 12)
                  .map((m) => monthNames[m - 1])
                  .toList();
              final label = '${names.join(', ')} ${controller.selectedYear.value}';
              chips.add(buildChip(label, () {
                controller.selectedYear.value = null;
                controller.selectedMonths.clear();
                controller.applyFilters();
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
          Builder(
            builder: (context) {
              final List<Widget> fields = [];

              if (showMonthYearFilter) {
                fields.add(
                  Obx(
                    () => AppMultiMonthYearPickerField(
                      label: 'Month / Year',
                      selectedYear: controller.selectedYear.value,
                      selectedMonths: controller.selectedMonths,
                      onChanged: (result) {
                        if (result == null) {
                          controller.selectedYear.value = null;
                          controller.selectedMonths.clear();
                        } else {
                          controller.selectedYear.value = result.year;
                          controller.selectedMonths.assignAll(result.months);
                        }
                        controller.applyFilters();
                      },
                    ),
                  ),
                );
              }

              if (canFilterProject) {
                fields.add(
                  Obx(
                    () => MultiSelectDropdownWidget<TaskProject>(
                      label: 'Project',
                      selectedValues: controller.selectedProjects.toSet(),
                      items: controller.projects
                          .map<DropdownMenuItem<TaskProject>>(
                            (e) => DropdownMenuItem<TaskProject>(
                              value: e,
                              child: Text(
                                e.projectName,
                                style: AppTextStyle.style_12_400(
                                  color: AppColors.grey900,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (values) {
                        controller.selectedProjects.assignAll(values);
                        controller.applyFilters();
                      },
                    ),
                  ),
                );
              }

              if (canFilterUnit) {
                fields.add(
                  Obx(
                    () => MultiSelectDropdownWidget<SupportUnit>(
                      label: 'Unit',
                      selectedValues: controller.selectedUnits.toSet(),
                      items: controller.units
                          .map<DropdownMenuItem<SupportUnit>>(
                            (e) => DropdownMenuItem<SupportUnit>(
                              value: e,
                              child: Text(
                                e.unitName,
                                style: AppTextStyle.style_12_400(
                                  color: AppColors.grey900,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (values) {
                        controller.selectedUnits.assignAll(values);
                        controller.applyFilters();
                      },
                    ),
                  ),
                );
              }

              if (canFilterGroup) {
                fields.add(
                  Obx(
                    () => MultiSelectDropdownWidget<TaskGroup>(
                      label: 'Group',
                      selectedValues: controller.selectedGroups.toSet(),
                      items: controller.groups
                          .map<DropdownMenuItem<TaskGroup>>(
                            (e) => DropdownMenuItem<TaskGroup>(
                              value: e,
                              child: Text(
                                e.roleName,
                                style: AppTextStyle.style_12_400(
                                  color: AppColors.grey900,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (values) {
                        controller.selectedGroups.assignAll(values);
                        controller.applyFilters();
                      },
                    ),
                  ),
                );
              }

              if (canFilterAssignee) {
                fields.add(
                  Obx(
                    () => MultiSelectDropdownWidget<AssigneeModel>(
                      label: 'Assignee',
                      selectedValues: controller.selectedAssignees.toSet(),
                      items: controller.assignees
                          .map<DropdownMenuItem<AssigneeModel>>(
                            (e) => DropdownMenuItem<AssigneeModel>(
                              value: e,
                              child: Text(
                                e.name,
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
                );
              }

              if (fields.isEmpty) return const SizedBox.shrink();

              final List<Widget> rows = [];
              for (int i = 0; i < fields.length; i += 2) {
                if (i > 0) {
                  rows.add(SizedBox(height: 4.h));
                }
                final first = fields[i];
                final hasSecond = i + 1 < fields.length;
                final second = hasSecond ? fields[i + 1] : const SizedBox.shrink();

                rows.add(
                  Row(
                    children: [
                      Expanded(child: first),
                      SizedBox(width: 8.w),
                      Expanded(child: second),
                    ],
                  ),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: rows,
              );
            },
          ),
        ],
      ),
    );
  }
  // endregion
}
// endregion
