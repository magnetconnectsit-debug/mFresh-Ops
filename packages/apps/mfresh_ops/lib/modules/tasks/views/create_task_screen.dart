import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/appointment_recurrence_dialog.dart';

class CreateTaskScreen extends GetView<TasksController> {
  const CreateTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskItem? task = Get.arguments;
    final isEdit = task != null;

    if (!controller.formInitialized.value) {
      if (isEdit) {
        controller.initializeFormForEdit(task);
      } else {
        controller.resetForm();
      }
      controller.formInitialized.value = true;
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Obx(
          () => Text(
            controller.isReadOnly.value
                ? 'Task Details'
                : isEdit
                ? 'Edit Task'
                : 'Create New Task',
            style: AppTextStyle.style_18_700(color: AppColors.black),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => AbsorbPointer(
                  absorbing: controller.isReadOnly.value,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: controller.titleController,
                        label: 'Task Title',
                      ),
                      SizedBox(height: 12.h),
                      _buildTextField(
                        controller: controller.descriptionController,
                        label: 'Description',
                        maxLines: 3,
                      ),
                      SizedBox(height: 12.h),

                      Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => MultiSelectDropdownWidget<TaskProject>(
                                label: 'Project',
                                isSingleSelect: true,
                                showSearch: true,
                                selectedValues:
                                    controller.selectedProjectForCreate.value ==
                                        null
                                    ? <TaskProject>{}
                                    : {
                                        controller
                                            .selectedProjectForCreate
                                            .value!,
                                      },
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
                                    controller.selectedProjectForCreate.value =
                                        values.isEmpty ? null : values.first,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Obx(
                              () => MultiSelectDropdownWidget<SupportUnit>(
                                label: 'Store (Unit)',
                                isSingleSelect: true,
                                showSearch: true,
                                selectedValues:
                                    controller.selectedUnitForCreate.value ==
                                        null
                                    ? <SupportUnit>{}
                                    : {controller.selectedUnitForCreate.value!},
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
                                onChanged: (values) =>
                                    controller.selectedUnitForCreate.value =
                                        values.isEmpty ? null : values.first,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => MultiSelectDropdownWidget<TaskGroup>(
                                label: 'Security Group',
                                isSingleSelect: true,
                                showSearch: true,
                                selectedValues:
                                    controller.selectedGroupForCreate.value ==
                                        null
                                    ? <TaskGroup>{}
                                    : {
                                        controller
                                            .selectedGroupForCreate
                                            .value!,
                                      },
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
                                onChanged: (values) =>
                                    controller.onGroupForCreateChanged(
                                        values.isEmpty ? null : values.first),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Obx(
                              () => MultiSelectDropdownWidget<AssigneeModel>(
                                label: 'Assignee',
                                isSingleSelect: true,
                                showSearch: true,
                                selectedValues:
                                    controller
                                            .selectedAssigneeForCreate
                                            .value ==
                                        null
                                    ? <AssigneeModel>{}
                                    : {
                                        controller
                                            .selectedAssigneeForCreate
                                            .value!,
                                      },
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
                                    controller.selectedAssigneeForCreate.value =
                                        values.isEmpty ? null : values.first,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => _buildDateTimeField(
                                label: 'Start Date',
                                icon: Icons.calendar_today_outlined,
                                value:
                                    controller.selectedStartDate.value != null
                                    ? AppDateUtils.formatToOrdinalDate(
                                        controller.selectedStartDate.value!
                                            .toIso8601String(),
                                      )
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
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Obx(
                              () => _buildDateTimeField(
                                label: 'Time',
                                icon: Icons.keyboard_arrow_down,
                                value: controller.selectedStartTime.value
                                    ?.format(context),
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
                      SizedBox(height: 12.h),

                      Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => _buildDateTimeField(
                                label: 'End Date',
                                icon: Icons.calendar_today_outlined,
                                value: controller.selectedEndDate.value != null
                                    ? AppDateUtils.formatToOrdinalDate(
                                        controller.selectedEndDate.value!
                                            .toIso8601String(),
                                      )
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
                          SizedBox(width: 12.w),
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
                      SizedBox(height: 16.h),

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
                                        style: AppTextStyle.style_12_400(
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Obx(
                                      () => _buildSwitch(
                                        controller.photoRequired.value,
                                        (val) =>
                                            controller.photoRequired.value =
                                                val,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Approval required',
                                        style: AppTextStyle.style_12_400(
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Obx(
                                      () => _buildSwitch(
                                        controller.approvalRequired.value,
                                        (val) =>
                                            controller.approvalRequired.value =
                                                val,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (!isEdit) ...[
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [_buildRecurringTask(context)],
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 12.h),

                      Obx(() {
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
                              selectedValues:
                                  controller.selectedApproverForCreate.value ==
                                      null
                                  ? <AssigneeModel>{}
                                  : {
                                      controller
                                          .selectedApproverForCreate
                                          .value!,
                                    },
                              items: controller.allAssignees
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
                                  controller.selectedApproverForCreate.value =
                                      values.isEmpty ? null : values.first,
                            ),
                          ],
                        );
                      }),
                      SizedBox(height: 24.h),

                      if (isEdit) ...[
                        SizedBox(height: 20.h),
                        Text(
                          'Update Level',
                          style: AppTextStyle.style_14_700(
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Theme(
                          data: Theme.of(context).copyWith(
                            unselectedWidgetColor: Colors.grey.shade300,
                          ),
                          child: Obx(
                            () => Column(
                              children: [
                                RadioListTile<String>(
                                  title: Text(
                                    'This Task Only',
                                    style: AppTextStyle.style_12_500(
                                      color: AppColors.black,
                                    ),
                                  ),
                                  value: "0",
                                  groupValue: controller.updateLevel.value,
                                  activeColor: const Color(0xFF0066FF),
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  visualDensity: const VisualDensity(
                                    horizontal: -4,
                                    vertical: -4,
                                  ),
                                  onChanged: (value) {
                                    if (value != null) {
                                      controller.updateLevel.value = value;
                                    }
                                  },
                                ),
                                RadioListTile<String>(
                                  title: Text(
                                    'Entire Task Series.',
                                    style: AppTextStyle.style_12_500(
                                      color: AppColors.black,
                                    ),
                                  ),
                                  value: "1",
                                  groupValue: controller.updateLevel.value,
                                  activeColor: const Color(0xFF0066FF),
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  visualDensity: const VisualDensity(
                                    horizontal: -4,
                                    vertical: -4,
                                  ),
                                  onChanged: (value) {
                                    if (value != null) {
                                      controller.updateLevel.value = value;
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              Obx(
                () => controller.isReadOnly.value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 100.w,
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.grey100,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Close',
                                style: AppTextStyle.style_14_600(
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 100.w,
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.grey100),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Cancel',
                                style: AppTextStyle.style_14_600(
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          SizedBox(
                            width: 130.w,
                            child: ElevatedButton(
                              onPressed: () {
                                if (isEdit) {
                                  controller.updateTask(task);
                                } else {
                                  controller.createTask();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isEdit
                                    ? const Color(
                                        0xFFFF6F00,
                                      ) // Orange color matching edit task screenshot
                                    : AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                elevation: 0,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                isEdit ? 'Update Task' : 'Create Task',
                                style: AppTextStyle.style_14_600(
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
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
          contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
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
          style: AppTextStyle.style_12_400(color: AppColors.grey900),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildSwitch(bool value, Function(bool) onChanged) {
    return SizedBox(
      width: 44.w,
      height: 28.h,
      child: Transform.scale(
        scale: 0.7,
        alignment: Alignment.centerRight,
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

  Widget _buildRecurringTask(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Recurring Task',
            style: AppTextStyle.style_12_400(color: AppColors.black),
          ),
        ),
        SizedBox(width: 6.w),
        Obx(
          () => _buildSwitch(controller.isRecurring.value, (val) async {
            if (val) {
              // Open Recurrence Dialog
              final result = await Get.dialog<RecurrenceData>(
                AppointmentRecurrenceDialog(
                  initialData: controller.recurrenceData.value,
                  defaultStartDate: controller.selectedStartDate.value,
                  defaultEndDate: controller.selectedEndDate.value,
                  defaultStartTime: controller.selectedStartTime.value,
                  defaultEndTime: controller.selectedEndTime.value,
                ),
              );
              if (result != null) {
                controller.recurrenceData.value = result;
                controller.selectedStartDate.value = result.startDate;
                controller.selectedEndDate.value = result.endByDate;
                controller.selectedStartTime.value = controller.parseTimeOfDay(
                  result.startTime,
                );
                controller.selectedEndTime.value = controller.parseTimeOfDay(
                  result.endTime,
                );
                controller.isRecurring.value = true;
              } else {
                controller.isRecurring.value = false;
              }
            } else {
              controller.isRecurring.value = false;
              controller.recurrenceData.value = null;
            }
          }),
        ),
      ],
    );
  }
}
