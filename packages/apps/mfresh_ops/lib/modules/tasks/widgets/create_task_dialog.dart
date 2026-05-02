import 'package:core/widgets/app_common_drop_down.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:mfresh_ops/data/models/models.dart';

class CreateTaskDialog extends GetView<TasksController> {
  final TaskItem? task;
  const CreateTaskDialog({super.key, this.task});

  @override
  Widget build(BuildContext context) {
    final isEdit = task != null;
    
    if (isEdit) {
      controller.titleController.text = task!.title;
      controller.descriptionController.text = task!.description;
    } else {
      controller.resetForm();
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.transparent,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Task' : 'Create New Task',
                    style: AppTextStyle.style_16_700(color: AppColors.black),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(Icons.close, color: AppColors.black, size: 20.r),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              
              _buildTextField(
                controller: controller.titleController,
                hintText: 'Task Title',
              ),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: controller.descriptionController,
                hintText: 'Description',
                maxLines: 2,
              ),
              SizedBox(height: 8.h),
              
              Row(
                children: [
                  Expanded(
                    child: Obx(() => AppCommonDropdown<TaskProject>(
                      hintText: 'Project',
                      options: controller.projects.map((e) => DropdownOption(value: e, label: e.projectName)).toList(),
                      value: controller.selectedProjectForCreate.value,
                      onChanged: (val) => controller.selectedProjectForCreate.value = val,
                      height: 30.h,
                      style: AppTextStyle.style_10_500(color: AppColors.black),
                    )),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Obx(() => AppCommonDropdown<AssigneeModel>(
                      hintText: 'Assignee',
                      options: controller.assignees.map((e) => DropdownOption(value: e, label: e.name)).toList(),
                      value: controller.selectedAssigneeForCreate.value,
                      onChanged: (val) => controller.selectedAssigneeForCreate.value = val,
                      height: 30.h,
                      style: AppTextStyle.style_10_500(color: AppColors.black),
                    )),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Obx(() => _buildDateTimeField(
                      label: 'Start Date', 
                      icon: Icons.calendar_today_outlined, 
                      value: controller.selectedStartDate.value != null 
                        ? "${controller.selectedStartDate.value!.day}-${controller.selectedStartDate.value!.month}-${controller.selectedStartDate.value!.year}"
                        : null,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) controller.selectedStartDate.value = date;
                      },
                    )),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    flex: 2,
                    child: Obx(() => _buildDateTimeField(
                      label: 'Time', 
                      icon: Icons.keyboard_arrow_down,
                      value: controller.selectedStartTime.value?.format(context),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) controller.selectedStartTime.value = time;
                      },
                    )),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Obx(() => _buildDateTimeField(
                      label: 'End Date', 
                      icon: Icons.calendar_today_outlined,
                      value: controller.selectedEndDate.value != null 
                        ? "${controller.selectedEndDate.value!.day}-${controller.selectedEndDate.value!.month}-${controller.selectedEndDate.value!.year}"
                        : null,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: controller.selectedStartDate.value ?? DateTime.now(),
                          firstDate: controller.selectedStartDate.value ?? DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) controller.selectedEndDate.value = date;
                      },
                    )),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    flex: 2,
                    child: Obx(() => _buildDateTimeField(
                      label: 'Time', 
                      icon: Icons.keyboard_arrow_down,
                      value: controller.selectedEndTime.value?.format(context),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) controller.selectedEndTime.value = time;
                      },
                    )),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              
              Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Photo Required', style: AppTextStyle.style_10_600(color: AppColors.black)),
                        SizedBox(width: 6.w),
                        Obx(() => _buildSwitch(
                          controller.photoRequired.value, 
                          (val) => controller.photoRequired.value = val
                        )),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Recurring Task', style: AppTextStyle.style_10_600(color: AppColors.black)),
                        SizedBox(width: 6.w),
                        Obx(() => _buildSwitch(
                          controller.isRecurring.value, 
                          (val) => controller.isRecurring.value = val
                        )),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              
              Row(
                children: [
                  Text('Approval Required', style: AppTextStyle.style_10_600(color: AppColors.black)),
                  SizedBox(width: 8.w),
                  Obx(() => _buildSwitch(
                    controller.approvalRequired.value, 
                    (val) => controller.approvalRequired.value = val
                  )),
                ],
              ),
              SizedBox(height: 10.h),
              
              Obx(() => Opacity(
                opacity: controller.approvalRequired.value ? 1.0 : 0.5,
                child: AbsorbPointer(
                  absorbing: !controller.approvalRequired.value,
                  child: AppCommonDropdown<AssigneeModel>(
                    hintText: 'Approver Name/ Team',
                    options: controller.assignees.map((e) => DropdownOption(value: e, label: e.name)).toList(),
                    value: controller.selectedApproverForCreate.value,
                    onChanged: (val) => controller.selectedApproverForCreate.value = val,
                    height: 30.h,
                    style: AppTextStyle.style_10_500(color: AppColors.black),
                  ),
                ),
              )),
              SizedBox(height: 16.h),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 70.w,
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.borderColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                      ),
                      child: Text('Cancel', style: AppTextStyle.style_11_600(color: AppColors.black)),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  SizedBox(
                    width: 90.w,
                    child: ElevatedButton(
                      onPressed: () {
                        final data = {
                          "title": controller.titleController.text,
                          "description": controller.descriptionController.text,
                          "project_id": controller.selectedProjectForCreate.value?.projectId,
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        elevation: 0,
                      ),
                      child: Text(
                        isEdit ? 'Submit' : 'Create Task', 
                        style: AppTextStyle.style_11_600(color: AppColors.white),
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
      height: maxLines > 1 ? null : 30.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        textAlignVertical: maxLines > 1 ? TextAlignVertical.top : TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyle.style_10_500(color: AppColors.grey200),
          contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: maxLines > 1 ? 6.h : 4.h),
          border: InputBorder.none,
          isDense: true,
        ),
        style: AppTextStyle.style_10_600(color: AppColors.black),
      ),
    );
  }

  Widget _buildDateTimeField({required String label, IconData? icon, String? value, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30.h,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value ?? label,
                style: AppTextStyle.style_10_500(color: value != null ? AppColors.black : AppColors.grey200),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (icon != null) Icon(icon, color: AppColors.grey200, size: 14.r),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch(bool value, Function(bool) onChanged) {
    return SizedBox(
      height: 20.h,
      width: 36.w,
      child: Transform.scale(
        scale: 0.6,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.white,
          activeTrackColor: AppColors.primary,
          inactiveTrackColor: AppColors.grey100,
          inactiveThumbColor: AppColors.white,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
