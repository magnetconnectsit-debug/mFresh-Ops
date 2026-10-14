import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/appointment_recurrence_dialog.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';

class _FormLifecycleWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onDispose;
  const _FormLifecycleWrapper({required this.child, required this.onDispose});
  @override
  State<_FormLifecycleWrapper> createState() => _FormLifecycleWrapperState();
}

class _FormLifecycleWrapperState extends State<_FormLifecycleWrapper> {
  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final GlobalKey<MultiSelectDropdownWidgetState> _projectKey =
      GlobalKey<MultiSelectDropdownWidgetState>();
  final GlobalKey<MultiSelectDropdownWidgetState> _unitKey =
      GlobalKey<MultiSelectDropdownWidgetState>();
  final GlobalKey<MultiSelectDropdownWidgetState> _groupKey =
      GlobalKey<MultiSelectDropdownWidgetState>();
  final GlobalKey<MultiSelectDropdownWidgetState> _assigneeKey =
      GlobalKey<MultiSelectDropdownWidgetState>();

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _recurrenceIntervalFocusNode = FocusNode();

  int _currentStep =
      0; // 0: Step 1 (Title, Description, Dates/Recurrence), 1: Step 2 (Group, Assignee, Unit, Project, Rules)

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _recurrenceIntervalFocusNode.dispose();
    super.dispose();
  }

  bool _validateStep1(
    BuildContext context,
    TasksController controller, {
    bool autoPrompt = false,
  }) {
    if (controller.titleController.text.trim().isEmpty) {
      _titleFocusNode.requestFocus();
      AppCommonToastMessage.show(
        message: 'Please enter task title',
        type: ToastType.warning,
      );
      return false;
    }

    if (!controller.isRecurring.value) {
      if (controller.selectedStartDate.value == null) {
        AppCommonToastMessage.show(
          message: 'Please select start date',
          type: ToastType.warning,
        );
        if (autoPrompt) _pickStartDate(context, controller);
        return false;
      }
      if (controller.selectedStartTime.value == null) {
        AppCommonToastMessage.show(
          message: 'Please select start time',
          type: ToastType.warning,
        );
        if (autoPrompt) {
          _pickStartTime(context, controller, autoProceedToEndTime: true);
        }
        return false;
      }
      if (controller.selectedEndTime.value == null) {
        AppCommonToastMessage.show(
          message: 'Please select end time',
          type: ToastType.warning,
        );
        if (autoPrompt) _pickEndTime(context, controller);
        return false;
      }
    } else {
      final rec = controller.recurrenceData.value;
      if (rec == null) {
        AppCommonToastMessage.show(
          message: 'Please configure recurrence pattern',
          type: ToastType.warning,
        );
        if (autoPrompt && _recurrenceIntervalFocusNode.canRequestFocus) {
          _recurrenceIntervalFocusNode.requestFocus();
        }
        return false;
      }
      if (rec.startTime.trim().isEmpty) {
        AppCommonToastMessage.show(
          message: 'Please select start time',
          type: ToastType.warning,
        );
        return false;
      }
      if (rec.endTime.trim().isEmpty) {
        AppCommonToastMessage.show(
          message: 'Please select end time',
          type: ToastType.warning,
        );
        return false;
      }
      if (rec.endByDate == null &&
          (rec.occurrences == null || rec.occurrences! <= 0)) {
        AppCommonToastMessage.show(
          message: 'Please specify an end date or occurrence count',
          type: ToastType.warning,
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _pickStartDate(
    BuildContext context,
    TasksController controller,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = controller.selectedStartDate.value ?? today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(today) ? today : initial,
      firstDate: today,
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
      if (controller.selectedEndDate.value == null ||
          controller.selectedEndDate.value!.isBefore(picked)) {
        controller.selectedEndDate.value = picked;
      }
    }
  }

  Future<void> _pickEndDate(
    BuildContext context,
    TasksController controller,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = controller.selectedStartDate.value ?? today;
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
    }
  }

  Future<void> _pickStartTime(
    BuildContext context,
    TasksController controller, {
    bool autoProceedToEndTime = false,
  }) async {
    final initial = controller.selectedStartTime.value ?? TimeOfDay.now();
    final time = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: 'Select Start Time',
      builder: (context, child) {
        return MediaQuery(
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
        );
      },
    );
    if (time != null) {
      controller.selectedStartTime.value = time;
      if (autoProceedToEndTime) {
        if (!context.mounted) return;
        await _pickEndTime(context, controller);
      }
    }
  }

  Future<void> _pickEndTime(
    BuildContext context,
    TasksController controller,
  ) async {
    final initial =
        controller.selectedEndTime.value ??
        (controller.selectedStartTime.value != null
            ? TimeOfDay(
                hour: (controller.selectedStartTime.value!.hour + 1) % 24,
                minute: controller.selectedStartTime.value!.minute,
              )
            : TimeOfDay.now());
    final time = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: 'Select End Time',
      builder: (context, child) {
        return MediaQuery(
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
        );
      },
    );
    if (time != null) {
      controller.selectedEndTime.value = time;
    }
  }

  void _jumpToNextUnfilledField(
    BuildContext context,
    TasksController controller,
    bool isRecurring,
  ) {
    if (isRecurring) {
      if (_recurrenceIntervalFocusNode.canRequestFocus) {
        _recurrenceIntervalFocusNode.requestFocus();
      }
    } else {
      if (controller.selectedStartDate.value == null) {
        _pickStartDate(context, controller);
      } else if (controller.selectedStartTime.value == null) {
        _pickStartTime(context, controller, autoProceedToEndTime: true);
      } else if (controller.selectedEndDate.value == null) {
        _pickEndDate(context, controller);
      } else if (controller.selectedEndTime.value == null) {
        _pickEndTime(context, controller);
      } else {
        FocusScope.of(context).unfocus();
      }
    }
  }

  Future<void> _proceedToNextUnselectedDropdown(
    TasksController controller,
  ) async {
    await Future.delayed(const Duration(milliseconds: 180));
    if (!mounted || _currentStep != 1) return;

    if (controller.selectedGroupForCreate.value == null) {
      _groupKey.currentState?.openMenu();
    } else if (controller.selectedAssigneeForCreate.value == null) {
      _assigneeKey.currentState?.openMenu();
    } else if (controller.selectedUnitForCreate.value == null) {
      _unitKey.currentState?.openMenu();
    } else if (controller.selectedProjectForCreate.value == null) {
      _projectKey.currentState?.openMenu();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TasksController>();
    final TaskItem? task = Get.arguments;
    final isEdit = task != null;

    if (!controller.formInitialized.value) {
      if (isEdit) {
        controller.initializeFormForEdit(task);
      } else {
        controller.resetForm();
      }
      controller.formInitialized.value = true;
    } else if (!isEdit && controller.selectedStartDate.value == null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      controller.selectedStartDate.value = today;
      controller.selectedEndDate.value = today;
    }

    return _FormLifecycleWrapper(
      onDispose: () {
        controller.formInitialized.value = false;
        controller.resetForm();
      },
      child: PopScope(
        canPop: _currentStep == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_currentStep > 0) {
            setState(() => _currentStep = 0);
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppCommonAppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            topHeader: const CommonShortcutHeader(),
            onBackButtonPressed: () {
              if (_currentStep > 0) {
                setState(() => _currentStep = 0);
              } else {
                Navigator.of(context).pop();
              }
            },
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
          body: Obx(() {
            final isSubmitting = controller.isFormSubmitting.value;
            final isReadOnly = controller.isReadOnly.value;
            final isRecurring = controller.isRecurring.value;

            return Stack(
              children: [
                AbsorbPointer(
                  absorbing: isSubmitting,
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 16.h),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ── TOP TAB SWITCHER (One-Time vs Recurring) ──
                                AppCommonConnectedTabBar(
                                  tabs: const ['One-Time', 'Recurring'],
                                  selectedIndex: isRecurring ? 1 : 0,
                                  readOnly: isReadOnly,
                                  height: 32.h,
                                  borderColor: const Color(0xFFCBD5E1),
                                  onTabChanged: (index) {
                                    if (index == 0) {
                                      controller.isRecurring.value = false;
                                      if (controller.selectedEndDate.value ==
                                          null) {
                                        final now = DateTime.now();
                                        controller.selectedEndDate.value =
                                            controller.selectedStartDate
                                                .value ??
                                            DateTime(
                                              now.year,
                                              now.month,
                                              now.day,
                                            );
                                      }
                                    } else {
                                      controller.isRecurring.value = true;
                                    }
                                  },
                                ),

                                // ── STEP INDICATOR HEADER ──
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: AppColors.white,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Color(0xFFE2E8F0),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildStepBadge(
                                        stepNumber: 1,
                                        title: 'Task Details',
                                        isActive: _currentStep == 0,
                                        isDone: _currentStep > 0,
                                        onTap: () {
                                          if (_currentStep != 0) {
                                            setState(() => _currentStep = 0);
                                          }
                                        },
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 2.h,
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                          ),
                                          color: _currentStep > 0
                                              ? const Color(0xFFF15A24)
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                      _buildStepBadge(
                                        stepNumber: 2,
                                        title: 'Assignee & Settings',
                                        isActive: _currentStep == 1,
                                        isDone: false,
                                        onTap: () {
                                          if (_currentStep != 1) {
                                            if (_validateStep1(
                                              context,
                                              controller,
                                              autoPrompt: true,
                                            )) {
                                              setState(() => _currentStep = 1);
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                // ── WIZARD BODY CONTENT ──
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    10.w,
                                    12.h,
                                    10.w,
                                    10.h,
                                  ),
                                  child: _currentStep == 0
                                      ? _buildStep1Content(
                                          context,
                                          controller,
                                          isReadOnly,
                                          isRecurring,
                                        )
                                      : _buildStep2Content(
                                          context,
                                          controller,
                                          isReadOnly,
                                          isEdit,
                                          task,
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (isSubmitting)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.25),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 20.h,
                          ),
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
                                width: 36.r,
                                height: 36.r,
                                child: const CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 3,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                isEdit
                                    ? 'Updating Task...'
                                    : 'Creating Task...',
                                style: AppTextStyle.style_13_500(
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStepBadge({
    required int stepNumber,
    required String title,
    required bool isActive,
    required bool isDone,
    VoidCallback? onTap,
  }) {
    final color = (isActive || isDone)
        ? const Color(0xFFF15A24)
        : Colors.grey.shade400;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22.r,
              height: 22.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? const Color(0xFFF15A24)
                    : isActive
                    ? Colors.white
                    : Colors.grey.shade200,
                border: Border.all(color: color, width: 1.5),
              ),
              child: isDone
                  ? Icon(Icons.check, size: 13.r, color: Colors.white)
                  : Text(
                      '$stepNumber',
                      style: AppTextStyle.style_11_700(
                        color: isActive
                            ? const Color(0xFFF15A24)
                            : Colors.grey.shade600,
                      ),
                    ),
            ),
            SizedBox(width: 6.w),
            Text(
              title,
              style: AppTextStyle.style_12_600(
                color: (isActive || isDone)
                    ? AppColors.black
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── STEP 1: TASK TITLE, DESCRIPTION & DATES / RECURRENCE ──
  Widget _buildStep1Content(
    BuildContext context,
    TasksController controller,
    bool isReadOnly,
    bool isRecurring,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCommonTextField(
          controller: controller.titleController,
          labelText: 'Task Title',
          hintText: 'Enter task title',
          isRequired: true,
          focusNode: _titleFocusNode,
          textInputAction: TextInputAction.next,
          readOnly: isReadOnly,
          onFieldSubmitted: (_) {
            if (controller.descriptionController.text.trim().isEmpty) {
              _descriptionFocusNode.requestFocus();
            } else {
              _jumpToNextUnfilledField(context, controller, isRecurring);
            }
          },
        ),
        SizedBox(height: 10.h),
        AppCommonTextField(
          controller: controller.descriptionController,
          labelText: 'Description',
          hintText: 'Enter description',
          maxLines: 2,
          focusNode: _descriptionFocusNode,
          textInputAction: TextInputAction.next,
          readOnly: isReadOnly,
          onFieldSubmitted: (_) {
            _jumpToNextUnfilledField(context, controller, isRecurring);
          },
        ),
        SizedBox(height: 10.h),
        const Divider(height: 1, color: Color(0xffDEE2E6)),
        SizedBox(height: 10.h),

        if (!isRecurring) ...[
          // ONE-TIME TASK DATES
          Obx(() {
            return Column(
              children: [
                SizedBox(height: 10.h),

                Row(
                  children: [
                    Expanded(
                      child: _buildDateTimeField(
                        label: 'Start Date',
                        isRequired: true,
                        icon: Icons.calendar_today_outlined,
                        value: controller.selectedStartDate.value != null
                            ? AppDateUtils.formatToShortOrdinalDate(
                                controller.selectedStartDate.value!
                                    .toIso8601String(),
                              )
                            : null,
                        readOnly: isReadOnly,
                        onTap: () => _pickStartDate(context, controller),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildDateTimeField(
                        label: 'Start Time',
                        isRequired: true,
                        icon: Icons.access_time_rounded,
                        value: controller.formatTimeOfDay(
                          controller.selectedStartTime.value,
                        ),
                        readOnly: isReadOnly,
                        onTap: () => _pickStartTime(
                          context,
                          controller,
                          autoProceedToEndTime: true,
                        ),
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
                        isRequired: true,
                        icon: Icons.calendar_today_outlined,
                        value: controller.selectedEndDate.value != null
                            ? AppDateUtils.formatToShortOrdinalDate(
                                controller.selectedEndDate.value!
                                    .toIso8601String(),
                              )
                            : null,
                        readOnly: isReadOnly,
                        onTap: () => _pickEndDate(context, controller),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildDateTimeField(
                        label: 'End Time',
                        isRequired: true,
                        icon: Icons.access_time_rounded,
                        value: controller.formatTimeOfDay(
                          controller.selectedEndTime.value,
                        ),
                        readOnly: isReadOnly,
                        onTap: () => _pickEndTime(context, controller),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ] else ...[
          // RECURRING TASK PATTERN FORM INLINE
          AppointmentRecurrenceForm(
            initialData: controller.recurrenceData.value,
            defaultStartDate: controller.selectedStartDate.value,
            defaultEndDate: controller.recurrenceData.value?.endByDate,
            defaultStartTime: controller.selectedStartTime.value,
            defaultEndTime: controller.selectedEndTime.value,
            readOnly: isReadOnly,
            intervalFocusNode: _recurrenceIntervalFocusNode,
            onChanged: (data) {
              controller.recurrenceData.value = data;
              controller.selectedStartDate.value = data.startDate;
              controller.selectedEndDate.value = data.endByDate;
              controller.selectedStartTime.value = controller.parseTimeOfDay(
                data.startTime,
              );
              controller.selectedEndTime.value = controller.parseTimeOfDay(
                data.endTime,
              );
            },
          ),
        ],

        // ── STEP 1 ACTION BUTTONS (Cancel & Next right aligned at end of content) ──
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppCommonButton(
              text: 'Cancel',
              variant: ButtonVariant.outline,
              width: 90.w,
              height: 26.h,
              textSize: 12.sp,
              borderRadius: 6.r,
              textColor: AppColors.black,
              borderColor: AppColors.borderColor,
              onPressed: controller.isFormSubmitting.value
                  ? null
                  : () => Get.back(),
            ),
            SizedBox(width: 8.w),
            if (!isReadOnly)
              AppCommonButton(
                text: 'Next',
                suffixIcon: Icons.arrow_forward_rounded,
                width: 100.w,
                height: 26.h,
                textSize: 12.sp,
                borderRadius: 6.r,
                buttonColor: const Color(0xFFF15A24),
                textColor: AppColors.white,
                useGradient: false,
                onPressed: () {
                  if (_validateStep1(context, controller, autoPrompt: true)) {
                    setState(() => _currentStep = 1);
                  }
                },
              ),
          ],
        ),
      ],
    );
  }

  // ── STEP 2: ASSIGNEE, GROUP, UNIT, PROJECT & RULES ──
  Widget _buildStep2Content(
    BuildContext context,
    TasksController controller,
    bool isReadOnly,
    bool isEdit,
    TaskItem? task,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── STEP 1 SUMMARY CARD ──
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F5),
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: const Color(0xFFFFDCD0), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Container(
                  //   padding: EdgeInsets.symmetric(
                  //     horizontal: 6.w,
                  //     vertical: 1.h,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color: const Color(0xFFF15A24).withValues(alpha: 0.12),
                  //     borderRadius: BorderRadius.circular(3.r),
                  //   ),
                  //   child: Text(
                  //     'TASK OVERVIEW',
                  //     style: AppTextStyle.style_10_700(
                  //       color: const Color(0xFFF15A24),
                  //     ),
                  //   ),
                  // ),
                  Text(
                    controller.titleController.text,
                    style: AppTextStyle.style_12_700(color: AppColors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isReadOnly)
                    InkWell(
                      onTap: () => setState(() => _currentStep = 0),
                      borderRadius: BorderRadius.circular(3.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 12.r,
                              color: const Color(0xFFF15A24),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              'Edit',
                              style: AppTextStyle.style_11_600(
                                color: const Color(0xFFF15A24),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 4.h),
              if (controller.descriptionController.text.trim().isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  controller.descriptionController.text.trim(),
                  style: AppTextStyle.style_11_400(color: AppColors.grey700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 6.h),
              const Divider(height: 1, color: Color(0xFFFFE3D6)),
              SizedBox(height: 6.h),
              Obx(() {
                if (controller.isRecurring.value) {
                  final rec = controller.recurrenceData.value;
                  if (rec == null) {
                    return Row(
                      children: [
                        Icon(
                          Icons.event_repeat_rounded,
                          size: 12.r,
                          color: const Color(0xFFF15A24),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Not configured',
                          style: AppTextStyle.style_11_400(
                            color: AppColors.grey700,
                          ),
                        ),
                      ],
                    );
                  }

                  final count = rec.repeatInterval;
                  String freqText = '';
                  String detailsText = '';

                  switch (rec.frequency.toLowerCase()) {
                    case 'day':
                      if (rec.selectedDays == 'Mon,Tue,Wed,Thu,Fri') {
                        freqText = 'Every weekday';
                      } else {
                        final unit = count == 1 ? 'day' : 'days';
                        freqText = 'Every $count $unit';
                      }
                      break;

                    case 'week':
                      final unit = count == 1 ? 'week' : 'weeks';
                      freqText = 'Every $count $unit';
                      if (rec.selectedDays != null &&
                          rec.selectedDays!.isNotEmpty) {
                        detailsText = rec.selectedDays!.replaceAll(',', ', ');
                      }
                      break;

                    case 'month':
                      final unit = count == 1 ? 'month' : 'months';
                      freqText = 'Every $count $unit';
                      if (rec.monthlyMode == 'the' &&
                          rec.monthOrdinal != null &&
                          rec.monthWeekday != null) {
                        detailsText =
                            'the ${rec.monthOrdinal} ${rec.monthWeekday}';
                      } else if (rec.monthDay != null) {
                        detailsText = 'Day ${rec.monthDay}';
                      }
                      break;

                    case 'year':
                      final unit = count == 1 ? 'year' : 'years';
                      freqText = 'Every $count $unit';
                      if (rec.yearlyMode == 'the' &&
                          rec.yearlyOrdinal != null &&
                          rec.yearlyWeekday != null &&
                          rec.yearlyTheMonth != null) {
                        detailsText =
                            'the ${rec.yearlyOrdinal} ${rec.yearlyWeekday} of ${rec.yearlyTheMonth}';
                      } else if (rec.yearlyMonth != null &&
                          rec.yearlyDay != null) {
                        detailsText = '${rec.yearlyMonth} ${rec.yearlyDay}';
                      }
                      break;

                    default:
                      freqText = 'Every $count days';
                  }

                  final startDateStr = AppDateUtils.formatToShortOrdinalDate(
                    rec.startDate.toIso8601String(),
                  );
                  String rangeText = startDateStr;
                  if (rec.endByDate != null) {
                    final endDateStr = AppDateUtils.formatToShortOrdinalDate(
                      rec.endByDate!.toIso8601String(),
                    );
                    if (startDateStr != endDateStr) {
                      rangeText = '$startDateStr - $endDateStr';
                    }
                  } else if (rec.occurrences != null && rec.occurrences! > 0) {
                    final count = rec.occurrences;
                    final occUnit = count == 1 ? 'occurrence' : 'occurrences';
                    rangeText = '$startDateStr ($count $occUnit)';
                  }

                  final line1 =
                      '$freqText | $rangeText | ${rec.startTime} - ${rec.endTime}';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 2.h),
                            child: Icon(
                              Icons.event_repeat_rounded,
                              size: 12.r,
                              color: const Color(0xFFF15A24),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              line1,
                              style: AppTextStyle.style_11_400(
                                color: AppColors.grey700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (detailsText.isNotEmpty) ...[
                        SizedBox(height: 3.h),
                        Padding(
                          padding: EdgeInsets.only(left: 16.w),
                          child: Text(
                            'on $detailsText',
                            style: AppTextStyle.style_11_600(
                              color: const Color(0xFFF15A24),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  );
                }

                final startD = controller.selectedStartDate.value != null
                    ? AppDateUtils.formatToShortOrdinalDate(
                        controller.selectedStartDate.value!.toIso8601String(),
                      )
                    : null;
                final endD = controller.selectedEndDate.value != null
                    ? AppDateUtils.formatToShortOrdinalDate(
                        controller.selectedEndDate.value!.toIso8601String(),
                      )
                    : null;
                final startT = controller.formatTimeOfDay(
                  controller.selectedStartTime.value,
                );
                final endT = controller.formatTimeOfDay(
                  controller.selectedEndTime.value,
                );

                String dateText = '';
                if (startD != null && endD != null && startD != endD) {
                  dateText = '$startD - $endD';
                } else if (startD != null) {
                  dateText = startD;
                } else if (endD != null) {
                  dateText = endD;
                }

                String timeText = '';
                if (startT != null && endT != null) {
                  timeText = '$startT - $endT';
                } else if (startT != null) {
                  timeText = startT;
                } else if (endT != null) {
                  timeText = endT;
                }

                return Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12.w,
                  runSpacing: 4.h,
                  children: [
                    if (dateText.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12.r,
                            color: const Color(0xFFF15A24),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            dateText,
                            style: AppTextStyle.style_11_400(
                              color: AppColors.grey800,
                            ),
                          ),
                        ],
                      ),
                    if (timeText.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12.r,
                            color: const Color(0xFFF15A24),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            timeText,
                            style: AppTextStyle.style_11_400(
                              color: AppColors.grey800,
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // GROUP & ASSIGNEE
        Row(
          children: [
            Expanded(
              child: Obx(
                () => MultiSelectDropdownWidget<TaskGroup>(
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
                  onChanged: (values) async {
                    final group = values.isEmpty ? null : values.first;
                    await controller.onGroupForCreateChanged(group);
                    if (group != null) {
                      _proceedToNextUnselectedDropdown(controller);
                    }
                  },
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Obx(
                () => MultiSelectDropdownWidget<AssigneeModel>(
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
                  onChanged: (values) {
                    final assignee = values.isEmpty ? null : values.first;
                    controller.selectedAssigneeForCreate.value = assignee;
                    if (assignee != null) {
                      _proceedToNextUnselectedDropdown(controller);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // STORE & PROJECT
        Row(
          children: [
            Expanded(
              child: Obx(
                () => MultiSelectDropdownWidget<SupportUnit>(
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
                  onChanged: (values) {
                    final unit = values.isEmpty ? null : values.first;
                    controller.selectedUnitForCreate.value = unit;
                    if (unit != null) {
                      _proceedToNextUnselectedDropdown(controller);
                    }
                  },
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Obx(
                () => MultiSelectDropdownWidget<TaskProject>(
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
                  onChanged: (values) {
                    final project = values.isEmpty ? null : values.first;
                    controller.selectedProjectForCreate.value = project;
                    if (project != null) {
                      _proceedToNextUnselectedDropdown(controller);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // RULES TOGGLES
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Photo required',
                      style: AppTextStyle.style_10_500(color: AppColors.black),
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
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Approval required',
                      style: AppTextStyle.style_10_500(color: AppColors.black),
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
            ),
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
              SizedBox(height: 6.h),
              MultiSelectDropdownWidget<AssigneeModel>(
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
                onChanged: (values) =>
                    controller.selectedApproverForCreate.value = values.isEmpty
                    ? null
                    : values.first,
              ),
            ],
          );
        }),

        if (isEdit) ...[
          Obx(() {
            if (!controller.isRecurring.value) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Text(
                  'Update Level',
                  style: AppTextStyle.style_14_700(color: AppColors.black),
                ),
                SizedBox(height: 8.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => controller.updateLevel.value = "0",
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 22.r,
                              height: 22.r,
                              child: Radio<String>(
                                value: "0",
                                // ignore: deprecated_member_use
                                groupValue: controller.updateLevel.value,
                                // ignore: deprecated_member_use
                                onChanged: (v) {
                                  if (v != null) {
                                    controller.updateLevel.value = v;
                                  }
                                },
                                activeColor: const Color(0xFF0066FF),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'This Task Only',
                              style: AppTextStyle.style_12_500(
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    InkWell(
                      onTap: () => controller.updateLevel.value = "1",
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 22.r,
                              height: 22.r,
                              child: Radio<String>(
                                value: "1",
                                // ignore: deprecated_member_use
                                groupValue: controller.updateLevel.value,
                                // ignore: deprecated_member_use
                                onChanged: (v) {
                                  if (v != null) {
                                    controller.updateLevel.value = v;
                                  }
                                },
                                activeColor: const Color(0xFF0066FF),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Entire Task Series.',
                              style: AppTextStyle.style_12_500(
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],

        // ── STEP 2 ACTION BUTTONS (Back & Submit at end of content) ──
        SizedBox(height: 12.h),
        if (isReadOnly)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppCommonButton(
                text: 'Close',
                variant: ButtonVariant.outline,
                width: 90.w,
                height: 32.h,
                textSize: 12.sp,
                borderRadius: 6.r,
                textColor: AppColors.black,
                borderColor: AppColors.borderColor,
                onPressed: () => Get.back(),
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppCommonButton(
                text: 'Back',
                variant: ButtonVariant.outline,
                width: 90.w,
                height: 32.h,
                textSize: 12.sp,
                borderRadius: 6.r,
                textColor: AppColors.black,
                borderColor: AppColors.borderColor,
                onPressed: () {
                  setState(() => _currentStep = 0);
                },
              ),
              SizedBox(width: 8.w),
              AppCommonButton(
                text: isEdit ? 'Update Task' : 'Create Task',
                width: 120.w,
                height: 32.h,
                textSize: 12.sp,
                borderRadius: 6.r,
                buttonColor: const Color(0xFFF15A24),
                textColor: AppColors.white,
                useGradient: false,
                isLoading: controller.isFormSubmitting.value,
                onPressed: controller.isFormSubmitting.value
                    ? null
                    : () {
                        if (isEdit) {
                          controller.updateTask(task!);
                        } else {
                          controller.createTask();
                        }
                      },
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDateTimeField({
    required String label,
    IconData? icon,
    String? value,
    VoidCallback? onTap,
    bool readOnly = false,
    bool isRequired = false,
  }) {
    return AppCommonTextField(
      controller: TextEditingController(text: value ?? ''),
      labelText: label,
      isRequired: isRequired,
      hintText: 'Select',
      readOnly: true,
      enabled: !readOnly,
      fillColor: readOnly ? const Color(0xFFF1F3F5) : Colors.white,
      onTap: readOnly ? null : onTap,
      suffixIcon: icon != null
          ? Padding(
              padding: EdgeInsets.only(right: 6.w),
              child: Icon(icon, color: AppColors.grey200, size: 14.r),
            )
          : null,
      suffixIconConstraints: BoxConstraints(minWidth: 20.w, minHeight: 0),
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
          activeTrackColor: const Color(0xFFF15A24),
          inactiveTrackColor: AppColors.grey100,
          inactiveThumbColor: AppColors.white,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
