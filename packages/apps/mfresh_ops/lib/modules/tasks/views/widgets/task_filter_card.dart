import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';

class TaskFilterCard extends StatelessWidget {
  final TasksController controller;

  const TaskFilterCard({super.key, required this.controller});

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
          Row(
            children: [
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
                      controller.refreshData();
                    },
                  ),
                ),
              ),
              SizedBox(width: 8.w),
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
                      controller.refreshData();
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
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
                      controller.refreshData();
                    },
                  ),
                ),
              ),
              SizedBox(width: 8.w),
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
                      controller.refreshData();
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
