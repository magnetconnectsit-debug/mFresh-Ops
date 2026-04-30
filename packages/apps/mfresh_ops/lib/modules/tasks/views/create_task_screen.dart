import 'package:core/widgets/app_common_drop_down.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:models/models.dart';

class CreateTaskScreen extends GetView<TasksController> {
  const CreateTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskItem? task = Get.arguments;
    final isEdit = task != null;

    if (isEdit) {
      controller.titleController.text = task.title;
      controller.descriptionController.text = task.description;
    } else {
      controller.resetForm();
    }
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          isEdit ? 'Edit Task' : 'Create New Task',
          style: AppTextStyle.style_18_700(color: AppColors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: controller.titleController,
                hintText: 'Task Title',
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: controller.descriptionController,
                hintText: 'Description',
                maxLines: 3,
              ),
              SizedBox(height: 12.h),
              
              Row(
                children: [
                  Expanded(
                    child: Obx(() => AppCommonDropdown<TaskProject>(
                      hintText: 'Project',
                      options: controller.projects.map((e) => DropdownOption(value: e, label: e.projectName)).toList(),
                      value: controller.selectedProjectForCreate.value,
                      onChanged: (val) => controller.selectedProjectForCreate.value = val,
                      height: 38.h,
                    )),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Obx(() => AppCommonDropdown<SupportUnit>(
                      hintText: 'Store (Unit)',
                      options: controller.units.map((e) => DropdownOption(value: e, label: e.unitName)).toList(),
                      value: controller.selectedUnitForCreate.value,
                      onChanged: (val) => controller.selectedUnitForCreate.value = val,
                      height: 38.h,
                    )),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              
              Row(
                children: [
                  Expanded(
                    child: Obx(() => AppCommonDropdown<TaskGroup>(
                      hintText: 'Security Group',
                      options: controller.groups.map((e) => DropdownOption(value: e, label: e.roleName)).toList(),
                      value: controller.selectedGroupForCreate.value,
                      onChanged: (val) => controller.selectedGroupForCreate.value = val,
                      height: 38.h,
                    )),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Obx(() => AppCommonDropdown<AssigneeModel>(
                      hintText: 'Assignee',
                      options: controller.assignees.map((e) => DropdownOption(value: e, label: e.name)).toList(),
                      value: controller.selectedAssigneeForCreate.value,
                      onChanged: (val) => controller.selectedAssigneeForCreate.value = val,
                      height: 38.h,
                    )),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              
              Row(
                children: [
                  Expanded(
                    child: _buildDateTimeField(
                      label: 'Start Date', 
                      icon: Icons.calendar_today_outlined, 
                      value: controller.selectedStartDate.value != null 
                        ? "${controller.selectedStartDate.value!.day}-${controller.selectedStartDate.value!.month}-${controller.selectedStartDate.value!.year}"
                        : null,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildDateTimeField(
                      label: 'Time', 
                      icon: Icons.keyboard_arrow_down,
                      value: controller.selectedStartTime.value?.format(context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              
              Row(
                children: [
                  Expanded(
                    child: _buildDateTimeField(
                      label: 'End Date', 
                      value: controller.selectedEndDate.value != null 
                        ? "${controller.selectedEndDate.value!.day}-${controller.selectedEndDate.value!.month}-${controller.selectedEndDate.value!.year}"
                        : null,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildDateTimeField(
                      label: 'Time', 
                      icon: Icons.keyboard_arrow_down,
                      value: controller.selectedEndTime.value?.format(context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Photo Required', style: AppTextStyle.style_13_600(color: AppColors.black)),
                  Row(
                    children: [
                      Obx(() => _buildSwitch(
                        controller.photoRequired.value, 
                        (val) => controller.photoRequired.value = val
                      )),
                      SizedBox(width: 24.w),
                      _buildRecurringTask(),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Completion approval required', style: AppTextStyle.style_13_600(color: AppColors.black)),
                  Obx(() => _buildSwitch(
                    controller.approvalRequired.value, 
                    (val) => controller.approvalRequired.value = val
                  )),
                ],
              ),
              SizedBox(height: 12.h),
              
              Obx(() => AppCommonDropdown<AssigneeModel>(
                hintText: 'Approver Name/ Team',
                options: controller.assignees.map((e) => DropdownOption(value: e, label: e.name)).toList(),
                value: controller.selectedApproverForCreate.value,
                onChanged: (val) => controller.selectedApproverForCreate.value = val,
                height: 38.h,
              )),
              SizedBox(height: 24.h),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 100.w,
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.grey100),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                      child: Text('Cancel', style: AppTextStyle.style_14_600(color: AppColors.black)),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  SizedBox(
                    width: 130.w,
                    child: ElevatedButton(
                      onPressed: () {
                        final data = {
                          "title": controller.titleController.text,
                          "description": controller.descriptionController.text,
                          "project_id": controller.selectedProjectForCreate.value?.projectId,
                          "unit_id": controller.selectedUnitForCreate.value?.unitId,
                          "group_id": controller.selectedGroupForCreate.value?.id,
                          "assignee_id": controller.selectedAssigneeForCreate.value?.id,
                          "approver_id": controller.selectedApproverForCreate.value?.id,
                          "photo_required": controller.photoRequired.value ? 1 : 0,
                          "approval_required": controller.approvalRequired.value ? 1 : 0,
                          "is_recurring": controller.isRecurring.value ? 1 : 0,
                        };
                        controller.createTask(data);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEdit ? AppColors.info : AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        elevation: 0,
                      ),
                      child: Text(
                        isEdit ? 'Submit' : 'Create Task', 
                        style: AppTextStyle.style_14_600(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hintText, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.grey50),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyle.style_12_400(color: AppColors.grey300),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: maxLines > 1 ? 12.h : 0),
          border: InputBorder.none,
          isDense: true,
        ),
        style: AppTextStyle.style_14_500(color: AppColors.black),
      ),
    );
  }

  Widget _buildDateTimeField({required String label, IconData? icon, String? value}) {
    return Container(
      height: 38.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.grey50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              value ?? label,
              style: AppTextStyle.style_12_500(color: value != null ? AppColors.black : AppColors.grey300),
            ),
          ),
          if (icon != null) Icon(icon, color: AppColors.grey300, size: 18.r),
        ],
      ),
    );
  }

  Widget _buildSwitch(bool value, Function(bool) onChanged) {
    return Transform.scale(
      scale: 0.7,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.white,
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.grey100,
        inactiveThumbColor: AppColors.white,
      ),
    );
  }

  Widget _buildRecurringTask() {
    return Obx(() => GestureDetector(
      onTap: () => controller.isRecurring.value = !controller.isRecurring.value,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sync, 
            size: 18.r, 
            color: controller.isRecurring.value ? AppColors.primary : AppColors.grey300
          ),
          SizedBox(width: 4.w),
          Text(
            'Recurring Task', 
            style: AppTextStyle.style_11_600(
              color: controller.isRecurring.value ? AppColors.black : AppColors.grey300
            ),
          ),
        ],
      ),
    ));
  }
}
