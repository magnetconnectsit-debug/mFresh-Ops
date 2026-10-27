// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/appointment_recurrence_dialog.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
// endregion

// region EditTaskScreen Widget
class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({super.key});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}
// endregion

// region State Implementation
class _EditTaskScreenState extends State<EditTaskScreen> {
  // region Focus Nodes & Controllers
  final GlobalKey<MultiSelectDropdownWidgetState> _groupKey =
      GlobalKey<MultiSelectDropdownWidgetState>();
  final GlobalKey<MultiSelectDropdownWidgetState> _assigneeKey =
      GlobalKey<MultiSelectDropdownWidgetState>();
  final GlobalKey<MultiSelectDropdownWidgetState> _unitKey =
      GlobalKey<MultiSelectDropdownWidgetState>();
  final GlobalKey<MultiSelectDropdownWidgetState> _projectKey =
      GlobalKey<MultiSelectDropdownWidgetState>();

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  TaskItem? _task;
  // endregion

  // region Lifecycle & Disposal
  @override
  void initState() {
    super.initState();
    final controller = Get.find<TasksController>();
    if (Get.arguments is TaskItem) {
      _task = Get.arguments as TaskItem;
    }

    final task = _task;
    if (task != null) {
      final isEntireSeries = controller.updateLevel.value == "1";
      controller.initializeFormForEdit(task, thisOccurrenceOnly: !isEntireSeries);
      if (isEntireSeries) {
        controller.isRecurring.value = true;
        controller.recurrenceData.value = RecurrenceData.fromTaskItem(task);
      } else {
        controller.isRecurring.value = false;
      }
      controller.formInitialized.value = true;
      _syncDisplayControllers(controller);
    }
  }

  void _syncDisplayControllers(TasksController controller) {
    if (controller.selectedStartDate.value != null) {
      _startDateController.text = AppDateUtils.formatToApiDate(
        controller.selectedStartDate.value!.toIso8601String(),
      );
    }
    if (controller.selectedEndDate.value != null) {
      _endDateController.text = AppDateUtils.formatToApiDate(
        controller.selectedEndDate.value!.toIso8601String(),
      );
    }
    if (controller.selectedStartTime.value != null) {
      _startTimeController.text =
          controller.formatTimeOfDay(controller.selectedStartTime.value) ?? '';
    }
    if (controller.selectedEndTime.value != null) {
      _endTimeController.text =
          controller.formatTimeOfDay(controller.selectedEndTime.value) ?? '';
    }
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();

    final controller = Get.find<TasksController>();
    controller.formInitialized.value = false;
    controller.resetForm();
    super.dispose();
  }
  // endregion

  // region Date & Time Pickers
  Future<void> _pickStartDate(
    BuildContext context,
    TasksController controller,
  ) async {
    final now = DateTime.now();
    final initial = controller.selectedStartDate.value ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Select Start Date',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFF15A24),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      controller.selectedStartDate.value = picked;
      _startDateController.text = AppDateUtils.formatToApiDate(
        picked.toIso8601String(),
      );
      if (controller.selectedEndDate.value == null ||
          controller.selectedEndDate.value!.isBefore(picked)) {
        controller.selectedEndDate.value = picked;
        _endDateController.text = AppDateUtils.formatToApiDate(
          picked.toIso8601String(),
        );
      }
    }
  }

  Future<void> _pickEndDate(
    BuildContext context,
    TasksController controller,
  ) async {
    final start = controller.selectedStartDate.value ?? DateTime.now();
    final initial = controller.selectedEndDate.value ?? start;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(start) ? start : initial,
      firstDate: start,
      lastDate: DateTime(2100),
      helpText: 'Select End Date',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFF15A24),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      controller.selectedEndDate.value = picked;
      _endDateController.text = AppDateUtils.formatToApiDate(
        picked.toIso8601String(),
      );
    }
  }

  Future<void> _pickStartTime(
    BuildContext context,
    TasksController controller,
  ) async {
    final initial = controller.selectedStartTime.value ?? TimeOfDay.now();
    final time = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: 'Select Start Time',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF15A24),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        ),
      ),
    );
    if (time != null) {
      controller.selectedStartTime.value = time;
      _startTimeController.text = controller.formatTimeOfDay(time) ?? '';
    }
  }

  Future<void> _pickEndTime(
    BuildContext context,
    TasksController controller,
  ) async {
    final initial = controller.selectedEndTime.value ?? TimeOfDay.now();
    final time = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: 'Select End Time',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF15A24),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        ),
      ),
    );
    if (time != null) {
      controller.selectedEndTime.value = time;
      _endTimeController.text = controller.formatTimeOfDay(time) ?? '';
    }
  }
  // endregion

  // region Form Validation & Submission
  Future<void> _handleUpdateTask(
    BuildContext context,
    TasksController controller,
    TaskItem task,
  ) async {
    // Permission guard
    final userPermissions = Get.find<AuthRepository>().rxUserPermissions;
    if (!userPermissions.contains('Task_Edit')) {
      AppCommonToastMessage.show(
        message: 'You do not have permission to edit tasks.',
        type: ToastType.warning,
      );
      return;
    }

    if (controller.titleController.text.trim().isEmpty) {
      AppCommonToastMessage.show(
        message: 'Please enter a task title',
        type: ToastType.warning,
      );
      _titleFocusNode.requestFocus();
      return;
    }

    final isEntireSeries = controller.updateLevel.value == "1";
    if (isEntireSeries) {
      if (controller.recurrenceData.value == null) {
        AppCommonToastMessage.show(
          message: 'Please configure recurrence pattern',
          type: ToastType.warning,
        );
        return;
      }
      final rec = controller.recurrenceData.value!;
      if (rec.startTime.isEmpty) {
        AppCommonToastMessage.show(
          message: 'Please select a start time',
          type: ToastType.warning,
        );
        return;
      }
      if (rec.endTime.isEmpty) {
        AppCommonToastMessage.show(
          message: 'Please select an end time',
          type: ToastType.warning,
        );
        return;
      }
    } else {
      if (controller.selectedStartDate.value == null) {
        AppCommonToastMessage.show(
          message: 'Please select a start date',
          type: ToastType.warning,
        );
        return;
      }

      if (controller.selectedEndDate.value == null) {
        AppCommonToastMessage.show(
          message: 'Please select an end date',
          type: ToastType.warning,
        );
        return;
      }

      if (controller.selectedStartTime.value == null) {
        AppCommonToastMessage.show(
          message: 'Please select a start time',
          type: ToastType.warning,
        );
        return;
      }

      if (controller.selectedEndTime.value == null) {
        AppCommonToastMessage.show(
          message: 'Please select an end time',
          type: ToastType.warning,
        );
        return;
      }
    }

    // Assignment validation: At least one of assignee, allgroup, store
    if (controller.selectedAssigneeForCreate.value == null &&
        controller.selectedGroupForCreate.value == null &&
        controller.selectedUnitForCreate.value == null) {
      AppCommonToastMessage.show(
        message: 'Please select an Assignee, Security Group, or Store (Unit)',
        type: ToastType.warning,
      );
      return;
    }

    if (controller.selectedProjectForCreate.value == null) {
      AppCommonToastMessage.show(
        message: 'Please select a project',
        type: ToastType.warning,
      );
      return;
    }

    if (controller.approvalRequired.value &&
        controller.selectedApproverForCreate.value == null) {
      AppCommonToastMessage.show(
        message: 'Please select an approver',
        type: ToastType.warning,
      );
      return;
    }

    await controller.updateTask(task);
  }

  Future<void> _advanceToNextDropdown(String currentField) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    final controller = Get.find<TasksController>();

    if (currentField == 'group') {
      if (controller.selectedAssigneeForCreate.value == null) {
        _assigneeKey.currentState?.openMenu();
        return;
      }
    }

    if (currentField == 'group' || currentField == 'assignee') {
      if (controller.selectedUnitForCreate.value == null) {
        _unitKey.currentState?.openMenu();
        return;
      }
    }

    if (currentField == 'group' ||
        currentField == 'assignee' ||
        currentField == 'unit') {
      if (controller.selectedProjectForCreate.value == null) {
        _projectKey.currentState?.openMenu();
        return;
      }
    }
  }
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TasksController>();
    if (_task == null && Get.arguments is TaskItem) {
      _task = Get.arguments as TaskItem;
    }
    final task = _task;

    if (task == null) {
      return Scaffold(
        appBar: AppCommonAppBar(
          title: Text(
            'Edit Task',
            style: AppTextStyle.style_18_700(color: AppColors.black),
          ),
          onBackButtonPressed: () => Navigator.of(context).pop(),
        ),
        body: const Center(child: Text('No task data provided for editing.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(context, controller),
      body: Obx(() {
        final isSubmitting = controller.isFormSubmitting.value;

        return Stack(
          children: [
            AbsorbPointer(
              absorbing: isSubmitting,
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: _buildFormBody(context, controller, task),
              ),
            ),
            if (isSubmitting) _buildSubmittingOverlay(),
          ],
        );
      }),
    );
  }
  // endregion

  // region App Bar
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    TasksController controller,
  ) {
    return AppCommonAppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      topHeader: const CommonShortcutHeader(),
      onBackButtonPressed: () => Navigator.of(context).pop(),
      title: Text(
        controller.isReadOnly.value ? 'Task Details' : 'Edit Task',
        style: AppTextStyle.style_18_700(color: AppColors.black),
      ),
    );
  }
  // endregion

  // region Form Body
  Widget _buildFormBody(
    BuildContext context,
    TasksController controller,
    TaskItem task,
  ) {
    final isReadOnly = controller.isReadOnly.value;
    final isEntireSeries =
        controller.isRecurring.value && controller.updateLevel.value == "1";

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Task Details Section
              _buildTaskDetailsSection(controller, isReadOnly),
              SizedBox(height: 16.h),
              const Divider(height: 1, color: Color(0xFFDEE2E6)),
              SizedBox(height: 16.h),

              // 2. Recurrence / Date & Time Section
              if (isEntireSeries) ...[
                AppointmentRecurrenceForm(
                  initialData: controller.recurrenceData.value,
                  defaultStartDate: controller.selectedStartDate.value,
                  defaultEndDate: controller.selectedEndDate.value,
                  defaultStartTime: controller.selectedStartTime.value,
                  defaultEndTime: controller.selectedEndTime.value,
                  readOnly: isReadOnly,
                  onChanged: (data) {
                    controller.recurrenceData.value = data;
                    controller.selectedStartDate.value = data.startDate;
                    controller.selectedEndDate.value = data.endByDate;
                    controller.selectedStartTime.value =
                        controller.parseTimeOfDay(data.startTime);
                    controller.selectedEndTime.value =
                        controller.parseTimeOfDay(data.endTime);
                  },
                ),
              ] else ...[
                _buildDateTimeSection(context, controller, task, isReadOnly),
              ],
              SizedBox(height: 16.h),
              const Divider(height: 1, color: Color(0xFFDEE2E6)),
              SizedBox(height: 16.h),

              // 3. Assignee & Settings Section
              _buildAssigneeAndSettingsSection(
                context,
                controller,
                task,
                isReadOnly,
              ),
              SizedBox(height: 16.h),
              const Divider(height: 1, color: Color(0xFFDEE2E6)),
              SizedBox(height: 20.h),

              // 4. Action Buttons Section
              _buildActionButtons(context, controller, task, isReadOnly),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
  // endregion

  // region Section: Task Details
  Widget _buildTaskDetailsSection(TasksController controller, bool isReadOnly) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Details',
          style: AppTextStyle.style_14_700(color: AppColors.black),
        ),
        SizedBox(height: 12.h),
        AppCommonTextField(
          controller: controller.titleController,
          labelText: 'Task Title',
          hintText: 'Enter task title',
          isRequired: true,
          focusNode: _titleFocusNode,
          readOnly: isReadOnly,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _descriptionFocusNode.requestFocus(),
        ),
        SizedBox(height: 14.h),
        AppCommonTextField(
          controller: controller.descriptionController,
          labelText: 'Description',
          hintText: 'Enter description',
          maxLines: 2,
          focusNode: _descriptionFocusNode,
          readOnly: isReadOnly,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }
  // endregion

  // region Section: Date & Time
  Widget _buildDateTimeSection(
    BuildContext context,
    TasksController controller,
    TaskItem task,
    bool isReadOnly,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.isRecurring
              ? 'This Occurrence - Date & Time'
              : 'Date & Time',
          style: AppTextStyle.style_14_700(color: AppColors.black),
        ),
        SizedBox(height: 12.h),

        // Row 1: Start Date & End Date
        Row(
          children: [
            Expanded(
              child: AppCommonTextField(
                controller: _startDateController,
                labelText: 'Start Date',
                hintText: 'Select date',
                isRequired: true,
                readOnly: true,
                enabled: !isReadOnly,
                onTap: isReadOnly
                    ? null
                    : () => _pickStartDate(context, controller),
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.grey400,
                    size: 16.r,
                  ),
                ),
                suffixIconConstraints: BoxConstraints(
                  minWidth: 24.w,
                  minHeight: 0,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AppCommonTextField(
                controller: _endDateController,
                labelText: 'End Date',
                hintText: 'Select date',
                isRequired: true,
                readOnly: true,
                enabled: !isReadOnly,
                onTap: isReadOnly
                    ? null
                    : () => _pickEndDate(context, controller),
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.grey400,
                    size: 16.r,
                  ),
                ),
                suffixIconConstraints: BoxConstraints(
                  minWidth: 24.w,
                  minHeight: 0,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // Row 2: Start Time & End Time
        Row(
          children: [
            Expanded(
              child: AppCommonTextField(
                controller: _startTimeController,
                labelText: 'Start Time',
                hintText: 'Select time',
                isRequired: true,
                readOnly: true,
                enabled: !isReadOnly,
                onTap: isReadOnly
                    ? null
                    : () => _pickStartTime(context, controller),
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Icon(
                    Icons.access_time_rounded,
                    color: AppColors.grey400,
                    size: 16.r,
                  ),
                ),
                suffixIconConstraints: BoxConstraints(
                  minWidth: 24.w,
                  minHeight: 0,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AppCommonTextField(
                controller: _endTimeController,
                labelText: 'End Time',
                hintText: 'Select time',
                isRequired: true,
                readOnly: true,
                enabled: !isReadOnly,
                onTap: isReadOnly
                    ? null
                    : () => _pickEndTime(context, controller),
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Icon(
                    Icons.access_time_rounded,
                    color: AppColors.grey400,
                    size: 16.r,
                  ),
                ),
                suffixIconConstraints: BoxConstraints(
                  minWidth: 24.w,
                  minHeight: 0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  // endregion

  // region Section: Assignee & Settings
  Widget _buildAssigneeAndSettingsSection(
    BuildContext context,
    TasksController controller,
    TaskItem task,
    bool isReadOnly,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assignee & Settings',
          style: AppTextStyle.style_14_700(color: AppColors.black),
        ),
        SizedBox(height: 12.h),

        // Row 1: Security Group & Assignee
        Row(
          children: [
            Expanded(
              child: Obx(
                () => AppCommonMultiSelectDropdown<TaskGroup>(
                  key: _groupKey,
                  label: 'Security Group',
                  isSingleSelect: true,
                  showSearch: true,
                  selectedValues:
                      controller.selectedGroupForCreate.value == null
                      ? <TaskGroup>{}
                      : {controller.selectedGroupForCreate.value!},
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
                  onChanged: isReadOnly
                      ? (_) {}
                      : (values) async {
                          final group = values.isEmpty ? null : values.first;
                          await controller.onGroupForCreateChanged(group);
                          if (group != null) {
                            _advanceToNextDropdown('group');
                          }
                        },
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Obx(
                () => AppCommonMultiSelectDropdown<AssigneeModel>(
                  key: _assigneeKey,
                  label: 'Assignee',
                  isSingleSelect: true,
                  showSearch: true,
                  selectedValues:
                      controller.selectedAssigneeForCreate.value == null
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
                  onChanged: isReadOnly
                      ? (_) {}
                      : (values) {
                          final assignee = values.isEmpty ? null : values.first;
                          controller.selectedAssigneeForCreate.value = assignee;
                          if (assignee != null) {
                            _advanceToNextDropdown('assignee');
                          }
                        },
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // Row 2: Store (Unit) & Project
        Row(
          children: [
            Expanded(
              child: Obx(
                () => AppCommonMultiSelectDropdown<SupportUnit>(
                  key: _unitKey,
                  label: 'Store (Unit)',
                  isSingleSelect: true,
                  showSearch: true,
                  selectedValues: controller.selectedUnitForCreate.value == null
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
                  onChanged: isReadOnly
                      ? (_) {}
                      : (values) {
                          final unit = values.isEmpty ? null : values.first;
                          controller.selectedUnitForCreate.value = unit;
                          if (unit != null) {
                            _advanceToNextDropdown('unit');
                          }
                        },
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Obx(
                () => AppCommonMultiSelectDropdown<TaskProject>(
                  key: _projectKey,
                  label: 'Project',
                  isSingleSelect: true,
                  showSearch: true,
                  selectedValues:
                      controller.selectedProjectForCreate.value == null
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
                  onChanged: isReadOnly
                      ? (_) {}
                      : (values) {
                          final project = values.isEmpty ? null : values.first;
                          controller.selectedProjectForCreate.value = project;
                        },
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 18.h),

        // Row 3: Photo Required & Approval Required Switches
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _buildSwitchItem(
                  label: 'Photo Required',
                  value: controller.photoRequired.value,
                  enabled: !isReadOnly,
                  onChanged: (val) => controller.photoRequired.value = val,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Obx(
                () => _buildSwitchItem(
                  label: 'Approval Required',
                  value: controller.approvalRequired.value,
                  enabled: !isReadOnly,
                  onChanged: (val) => controller.approvalRequired.value = val,
                ),
              ),
            ),
          ],
        ),

        // Conditional Row 4: Approver Selection (if Approval Required is enabled)
        Obx(() {
          if (!controller.approvalRequired.value) {
            return const SizedBox.shrink();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 14.h),
              AppCommonMultiSelectDropdown<AssigneeModel>(
                label: 'Approver Name/ Team',
                isSingleSelect: true,
                showSearch: true,
                selectedValues:
                    controller.selectedApproverForCreate.value == null
                    ? <AssigneeModel>{}
                    : {controller.selectedApproverForCreate.value!},
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
                onChanged: isReadOnly
                    ? (_) {}
                    : (values) => controller.selectedApproverForCreate.value =
                          values.isEmpty ? null : values.first,
              ),
            ],
          );
        }),
      ],
    );
  }
  // endregion

  // region Section: Action Buttons
  Widget _buildActionButtons(
    BuildContext context,
    TasksController controller,
    TaskItem task,
    bool isReadOnly,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppCommonButton(
          text: 'Cancel',
          variant: ButtonVariant.outline,
          width: 90.w,
          height: 32.h,
          textSize: 12.sp,
          borderRadius: 6.r,
          textColor: AppColors.black,
          borderColor: Colors.grey.shade300,
          onPressed: () => Navigator.of(context).pop(),
        ),
        if (!isReadOnly) ...[
          SizedBox(width: 10.w),
          AppCommonButton(
            text: 'Update Task',
            width: 120.w,
            height: 32.h,
            textSize: 12.sp,
            borderRadius: 6.r,
            buttonColor: const Color(0xFFF15A24),
            textColor: AppColors.white,
            useGradient: false,
            onPressed: () => _handleUpdateTask(context, controller, task),
          ),
        ],
      ],
    );
  }
  // endregion

  // region Helper UI Builders
  Widget _buildSwitchItem({
    required String label,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyle.style_12_500(color: AppColors.black),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 4.w),
        Transform.scale(
          scale: 0.75,
          alignment: Alignment.centerRight,
          child: Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: AppColors.white,
            activeTrackColor: const Color(0xFFF15A24),
            inactiveTrackColor: AppColors.grey100,
            inactiveThumbColor: AppColors.white,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmittingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.25),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 32.r,
                  height: 32.r,
                  child: const CircularProgressIndicator(
                    color: Color(0xFFF15A24),
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Updating Task...',
                  style: AppTextStyle.style_13_500(color: AppColors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // endregion
}

// endregion
