import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';

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
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
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
                    child: Icon(
                      Icons.close,
                      color: AppColors.black,
                      size: 20.r,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              _buildTextField(
                controller: controller.titleController,
                label: 'Task Title',
              ),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: controller.descriptionController,
                label: 'Description',
                maxLines: 2,
              ),
              SizedBox(height: 8.h),

              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => MultiSelectDropdownWidget<TaskProject>(
                        label: 'Project',
                        isSingleSelect: true,
                        showSearch: true,
                        selectedValues: controller.selectedProjectForCreate.value == null
                            ? <TaskProject>{}
                            : {controller.selectedProjectForCreate.value!},
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
                        onChanged: (values) =>
                            controller.selectedProjectForCreate.value = values.isEmpty ? null : values.first,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Obx(
                      () => MultiSelectDropdownWidget<AssigneeModel>(
                        label: 'Assignee',
                        isSingleSelect: true,
                        showSearch: true,
                        selectedValues: controller.selectedAssigneeForCreate.value == null
                            ? <AssigneeModel>{}
                            : {controller.selectedAssigneeForCreate.value!},
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
                        onChanged: (values) =>
                            controller.selectedAssigneeForCreate.value = values.isEmpty ? null : values.first,
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
                      () => _buildDateTimeField(
                        label: 'Start Date',
                        icon: Icons.calendar_today_outlined,
                        value: controller.selectedStartDate.value != null
                            ? AppDateUtils.formatToOrdinalDate(controller.selectedStartDate.value!.toIso8601String())
                            : null,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            controller.selectedStartDate.value = date;
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Obx(
                      () => _buildDateTimeField(
                        label: 'Time',
                        icon: Icons.keyboard_arrow_down,
                        value: controller.selectedStartTime.value?.format(
                          context,
                        ),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            controller.selectedStartTime.value = time;
                          }
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
                      () => _buildDateTimeField(
                        label: 'End Date',
                        icon: Icons.calendar_today_outlined,
                        value: controller.selectedEndDate.value != null
                            ? AppDateUtils.formatToOrdinalDate(controller.selectedEndDate.value!.toIso8601String())
                            : null,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate:
                                controller.selectedStartDate.value ??
                                DateTime.now(),
                            firstDate:
                                controller.selectedStartDate.value ??
                                DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            controller.selectedEndDate.value = date;
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Obx(
                      () => _buildDateTimeField(
                        label: 'Time',
                        icon: Icons.keyboard_arrow_down,
                        value: controller.selectedEndTime.value?.format(
                          context,
                        ),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            controller.selectedEndTime.value = time;
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Photo Required',
                                style: AppTextStyle.style_10_600(
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Obx(
                              () => _buildSwitch(
                                controller.photoRequired.value,
                                (val) => controller.photoRequired.value = val,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Approval Required',
                                style: AppTextStyle.style_10_600(
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Obx(
                              () => _buildSwitch(
                                controller.approvalRequired.value,
                                (val) => controller.approvalRequired.value = val,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 24.w),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Recurring Task',
                                style: AppTextStyle.style_10_600(
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Obx(
                              () => _buildSwitch(
                                controller.isRecurring.value,
                                (val) => controller.isRecurring.value = val,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Obx(
                () {
                  if (!controller.approvalRequired.value) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.h),
                      MultiSelectDropdownWidget<AssigneeModel>(
                        label: 'Approver Name/ Team',
                        isSingleSelect: true,
                        showSearch: true,
                        selectedValues: controller.selectedApproverForCreate.value == null
                            ? <AssigneeModel>{}
                            : {controller.selectedApproverForCreate.value!},
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
                        onChanged: (values) =>
                            controller.selectedApproverForCreate.value = values.isEmpty ? null : values.first,
                      ),
                    ],
                  );
                },
              ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyle.style_11_600(
                          color: AppColors.black,
                        ),
                      ),
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
                          "project_id": controller
                              .selectedProjectForCreate
                              .value
                              ?.projectId,
                          "assignee_id":
                              controller.selectedAssigneeForCreate.value?.id,
                          "approver_id":
                              controller.selectedApproverForCreate.value?.id,
                          "photo_required": controller.photoRequired.value
                              ? 1
                              : 0,
                          "approval_required": controller.approvalRequired.value
                              ? 1
                              : 0,
                          "is_recurring": controller.isRecurring.value ? 1 : 0,
                        };
                        controller.createTask(data);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEdit
                            ? AppColors.info
                            : AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        elevation: 0,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        isEdit ? 'Submit' : 'Create Task',
                        style: AppTextStyle.style_11_600(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: AppTextStyle.style_12_400(color: AppColors.grey200),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: maxLines > 1 ? 6.h : 4.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: const BorderSide(color: Color(0xffF15A24), width: 1.5),
        ),
        isDense: true,
      ),
      style: AppTextStyle.style_12_400(color: AppColors.grey900),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    IconData? icon,
    String? value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: AppTextStyle.style_12_400(color: AppColors.grey200),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 4.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: const BorderSide(color: AppColors.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: const BorderSide(color: AppColors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: const BorderSide(color: Color(0xffF15A24), width: 1.5),
          ),
          suffixIcon: icon != null
              ? Padding(
                  padding: EdgeInsets.only(right: 4.w),
                  child: Icon(icon, color: AppColors.grey200, size: 16.r),
                )
              : null,
          suffixIconConstraints: BoxConstraints(
            minWidth: 20.w,
            minHeight: 20.h,
          ),
        ),
        child: Text(
          value ?? 'Select',
          style: AppTextStyle.style_12_400(
            color: AppColors.grey900,
          ),
          overflow: TextOverflow.ellipsis,
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
