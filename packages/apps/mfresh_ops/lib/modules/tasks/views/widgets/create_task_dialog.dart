import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';

class CreateTaskDialog extends StatefulWidget {
  final TaskItem? task;
  const CreateTaskDialog({super.key, this.task});

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  final GlobalKey<MultiSelectDropdownWidgetState> _projectKey =
      GlobalKey<MultiSelectDropdownWidgetState>();
  final GlobalKey<MultiSelectDropdownWidgetState> _assigneeKey =
      GlobalKey<MultiSelectDropdownWidgetState>();

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TasksController>();
    final isEdit = widget.task != null;

    if (isEdit) {
      controller.titleController.text = widget.task!.title;
      controller.descriptionController.text = widget.task!.description;
    } else {
      controller.resetForm();
    }

    Future<void> pickDateRange() async {
      final initialRange =
          controller.selectedStartDate.value != null &&
              controller.selectedEndDate.value != null
          ? DateTimeRange(
              start: controller.selectedStartDate.value!,
              end: controller.selectedEndDate.value!,
            )
          : null;
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        initialDateRange: initialRange,
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        ),
      );
      if (picked != null) {
        controller.selectedStartDate.value = picked.start;
        controller.selectedEndDate.value = picked.end;
      }
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
                  focusNode: _titleFocusNode,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _descriptionFocusNode.requestFocus(),
                ),
                SizedBox(height: 8.h),
                _buildTextField(
                  controller: controller.descriptionController,
                  label: 'Description',
                  maxLines: 2,
                  focusNode: _descriptionFocusNode,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _projectKey.currentState?.openMenu();
                    });
                  },
                ),
                SizedBox(height: 8.h),

                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => MultiSelectDropdownWidget<TaskProject>(
                          key: _projectKey,
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
                          onChanged: (values) {
                            controller.selectedProjectForCreate.value =
                                values.isEmpty ? null : values.first;
                            if (values.isNotEmpty) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _assigneeKey.currentState?.openMenu();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Obx(
                        () => MultiSelectDropdownWidget<AssigneeModel>(
                          key: _assigneeKey,
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
                          onChanged: (values) {
                            controller.selectedAssigneeForCreate.value =
                                values.isEmpty ? null : values.first;
                            if (values.isNotEmpty) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                pickDateRange();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // ── Date Range Row (drag-to-select) ──
                Obx(() {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildDateTimeField(
                          label: 'Start Date',
                          icon: Icons.calendar_today_outlined,
                          value: controller.selectedStartDate.value != null
                              ? AppDateUtils.formatToOrdinalDate(controller.selectedStartDate.value!.toIso8601String())
                              : null,
                          onTap: pickDateRange,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _buildDateTimeField(
                          label: 'Start Time',
                          icon: Icons.keyboard_arrow_down,
                          value: controller.selectedStartTime.value?.format(
                            context,
                          ),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: controller.selectedStartTime.value ?? TimeOfDay.now(),
                              builder: (context, child) => MediaQuery(
                                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                                child: child!,
                              ),
                            );
                            if (time != null) {
                              controller.selectedStartTime.value = time;
                            }
                          },
                        ),
                      ),
                    ],
                  );
                }),
                SizedBox(height: 8.h),

                Obx(() {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildDateTimeField(
                          label: 'End Date',
                          icon: Icons.calendar_today_outlined,
                          value: controller.selectedEndDate.value != null
                              ? AppDateUtils.formatToOrdinalDate(controller.selectedEndDate.value!.toIso8601String())
                              : null,
                          onTap: pickDateRange,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _buildDateTimeField(
                          label: 'End Time',
                          icon: Icons.keyboard_arrow_down,
                          value: controller.selectedEndTime.value?.format(
                            context,
                          ),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: controller.selectedEndTime.value ?? TimeOfDay.now(),
                              builder: (context, child) => MediaQuery(
                                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                                child: child!,
                              ),
                            );
                            if (time != null) {
                              controller.selectedEndTime.value = time;
                            }
                          },
                        ),
                      ),
                    ],
                  );
                }),
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
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
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
