import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';

class TaskFilterCard extends StatelessWidget {
  final TasksController controller;

  const TaskFilterCard({super.key, required this.controller});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: AppTextStyle.style_12_600(color: AppColors.grey800),
              ),
              Obx(() {
                if (controller.isFiltered) {
                  return InkWell(
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
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
          Obx(() {
            if (!controller.isFiltered) return const SizedBox.shrink();

            final List<Widget> chips = [];

            Widget buildChip(String label, VoidCallback onDeleted) {
              return Padding(
                padding: EdgeInsets.only(top: 8.h, right: 6.w),
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
                        Icon(Icons.close, size: 14.r, color: AppColors.blue500),
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

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: chips,
              ),
            );
          }),
          SizedBox(height: 8.h),
          if (canFilterProject || canFilterUnit)
            Row(
              children: [
                if (canFilterProject)
                  Expanded(
                    child: Obx(
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
                  ),
                if (canFilterProject && canFilterUnit) SizedBox(width: 8.w),
                if (canFilterUnit)
                  Expanded(
                    child: Obx(
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
                  ),
              ],
            ),
          if ((canFilterProject || canFilterUnit) && (canFilterGroup || canFilterAssignee))
            SizedBox(height: 8.h),
          if (canFilterGroup || canFilterAssignee)
            Row(
              children: [
                if (canFilterGroup)
                  Expanded(
                    child: Obx(
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
                  ),
                if (canFilterGroup && canFilterAssignee) SizedBox(width: 8.w),
                if (canFilterAssignee)
                  Expanded(
                    child: Obx(
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
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
