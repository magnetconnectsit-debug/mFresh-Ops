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
        children: [
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
