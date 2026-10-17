import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/ticket_details_controller.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';

// region EditTicketScreen Widget
class EditTicketScreen extends StatefulWidget {
  const EditTicketScreen({super.key});

  @override
  State<EditTicketScreen> createState() => _EditTicketScreenState();
}
// endregion

// region EditTicketScreen State
class _EditTicketScreenState extends State<EditTicketScreen> {
  // region Dropdown GlobalKeys
  final GlobalKey<MultiSelectDropdownWidgetState> _statusKey =
      GlobalKey<MultiSelectDropdownWidgetState>();
  final GlobalKey<MultiSelectDropdownWidgetState> _assigneeKey =
      GlobalKey<MultiSelectDropdownWidgetState>();
  final GlobalKey<MultiSelectDropdownWidgetState> _categoryKey =
      GlobalKey<MultiSelectDropdownWidgetState>();
  final GlobalKey<MultiSelectDropdownWidgetState> _subCategoryKey =
      GlobalKey<MultiSelectDropdownWidgetState>();
  final GlobalKey<MultiSelectDropdownWidgetState> _priorityKey =
      GlobalKey<MultiSelectDropdownWidgetState>();
  final GlobalKey<MultiSelectDropdownWidgetState> _projectKey =
      GlobalKey<MultiSelectDropdownWidgetState>();
  final GlobalKey<MultiSelectDropdownWidgetState> _unitKey =
      GlobalKey<MultiSelectDropdownWidgetState>();
  // endregion

  // region Dropdown Progression Logic
  Future<void> _advanceToNextDropdown(String currentField) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    final controller = Get.find<TicketDetailsController>();

    if (currentField == 'status') {
      if (controller.selectedAssignee.value == null) {
        _assigneeKey.currentState?.openMenu();
        return;
      }
    }

    if (currentField == 'status' || currentField == 'assignee') {
      if (controller.selectedCategory.value == null) {
        _categoryKey.currentState?.openMenu();
        return;
      }
    }

    if (currentField == 'status' ||
        currentField == 'assignee' ||
        currentField == 'category') {
      while (controller.isSubCategoryLoading.value) {
        await Future.delayed(const Duration(milliseconds: 50));
        if (!mounted) return;
      }
      if (controller.selectedSubCategory.value == null) {
        _subCategoryKey.currentState?.openMenu();
        return;
      }
    }

    if (currentField == 'status' ||
        currentField == 'assignee' ||
        currentField == 'category' ||
        currentField == 'subCategory') {
      if (controller.selectedPriority.value == null) {
        _priorityKey.currentState?.openMenu();
        return;
      }
    }

    if (currentField == 'status' ||
        currentField == 'assignee' ||
        currentField == 'category' ||
        currentField == 'subCategory' ||
        currentField == 'priority') {
      if (controller.selectedProject.value == null) {
        _projectKey.currentState?.openMenu();
        return;
      }
    }

    if (currentField == 'status' ||
        currentField == 'assignee' ||
        currentField == 'category' ||
        currentField == 'subCategory' ||
        currentField == 'priority' ||
        currentField == 'project') {
      if (controller.selectedUnit.value == null) {
        _unitKey.currentState?.openMenu();
        return;
      }
    }
  }
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TicketDetailsController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        hasBackButton: true,
        topHeader: const CommonShortcutHeader(),
        title: Obx(
          () => RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Edit Ticket ",
                  style: AppTextStyle.style_15_600(
                    color: AppColors.primaryOrange,
                  ),
                ),
                TextSpan(
                  text:
                      "# ${controller.ticketDetail.value?.caseId ?? controller.ticketDetail.value?.id ?? ''}",
                  style: AppTextStyle.style_15_600(color: AppColors.black),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormGrid(context, controller),
                        SizedBox(height: 14.h),

                        // ── Divider ──
                        Container(height: 0.5.h, color: AppColors.borderColor),
                        SizedBox(height: 14.h),

                        _buildTextField(
                          controller.subjectController,
                          label: "Subject*",
                          hint: "Subject Line",
                          maxLines: 2,
                        ),

                        SizedBox(height: 10.h),

                        _buildTextField(
                          controller.descriptionController,
                          label: "Description",
                          hint: "Description here",
                          maxLines: 4,
                        ),

                        // ─── Subtasks Section ─────────────────────────────
                        Obx(() {
                          final subtasks =
                              controller.ticketDetail.value?.subtasks ?? [];
                          if (subtasks.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 12.h),
                              Text(
                                "Sub Tasks",
                                style: AppTextStyle.style_11_600(
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.grey50,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Column(
                                  children: subtasks.asMap().entries.map((
                                    entry,
                                  ) {
                                    final st = entry.value;
                                    final isLast =
                                        entry.key == subtasks.length - 1;
                                    return Obx(() {
                                      final isChecked = controller
                                          .isSubtaskChecked(st.id);
                                      return Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.w,
                                              vertical: 2.h,
                                            ),
                                            child: Row(
                                              children: [
                                                Checkbox(
                                                  value: isChecked,
                                                  activeColor:
                                                      AppColors.primaryOrange,
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  onChanged: (v) => controller
                                                      .toggleSubtaskCheck(
                                                        st.id,
                                                      ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    st.subtask ?? '',
                                                    style:
                                                        AppTextStyle.style_11_400(
                                                          color: isChecked
                                                              ? AppColors
                                                                    .grey500
                                                              : AppColors
                                                                    .black87,
                                                        ).copyWith(
                                                          decoration: isChecked
                                                              ? TextDecoration
                                                                    .lineThrough
                                                              : null,
                                                        ),
                                                  ),
                                                ),
                                                // Status badge
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 5.w,
                                                    vertical: 2.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isChecked
                                                        ? AppColors.green
                                                              .withValues(
                                                                alpha: 0.1,
                                                              )
                                                        : AppColors.orange
                                                              .withValues(
                                                                alpha: 0.1,
                                                              ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4.r,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    isChecked
                                                        ? 'Done'
                                                        : 'Pending',
                                                    style:
                                                        AppTextStyle.style_10_700(
                                                          color: isChecked
                                                              ? AppColors
                                                                    .successDark
                                                              : AppColors
                                                                    .orange,
                                                        ).copyWith(
                                                          fontSize: 9.sp,
                                                        ),
                                                  ),
                                                ),
                                                SizedBox(width: 4.w),
                                                // Delete icon
                                                InkWell(
                                                  onTap:
                                                      controller
                                                          .isSubtaskLoading
                                                          .value
                                                      ? null
                                                      : () {
                                                          Get.dialog(
                                                            AlertDialog(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12.r,
                                                                    ),
                                                              ),
                                                              title: Text(
                                                                'Delete Subtask',
                                                                style: AppTextStyle.style_14_700(
                                                                  color: AppColors
                                                                      .black87,
                                                                ),
                                                              ),
                                                              content: Text(
                                                                'Delete "${st.subtask}"?',
                                                                style: AppTextStyle.style_12_400(
                                                                  color: AppColors
                                                                      .black87,
                                                                ),
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Get.back(),
                                                                  child: Text(
                                                                    'Cancel',
                                                                    style: AppTextStyle.style_12_400(
                                                                      color: AppColors
                                                                          .black87,
                                                                    ),
                                                                  ),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () async {
                                                                    Get.back();
                                                                    final success =
                                                                        await controller.deleteSubtask(
                                                                          st.id,
                                                                        );
                                                                    if (success) {
                                                                      AppCommonToastMessage.show(
                                                                        message:
                                                                            'Subtask deleted successfully',
                                                                        type: ToastType
                                                                            .success,
                                                                      );
                                                                    }
                                                                  },
                                                                  child: Text(
                                                                    'Delete',
                                                                    style: AppTextStyle.style_12_700(
                                                                      color: AppColors
                                                                          .red,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                  child: Padding(
                                                    padding: EdgeInsets.all(
                                                      4.r,
                                                    ),
                                                    child: Icon(
                                                      Icons.delete_outline,
                                                      color: AppColors.red,
                                                      size: 16.r,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (!isLast)
                                            Divider(
                                              height: 1,
                                              color: AppColors.grey200,
                                            ),
                                        ],
                                      );
                                    });
                                  }).toList(),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '✓ Check a subtask to mark it as completed (esubtask)',
                                style:
                                    AppTextStyle.style_10_400(
                                      color: AppColors.grey500,
                                    ).copyWith(
                                      fontSize: 9.sp,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.r),
                  color: AppColors.white,
                  child: _buildBottomActions(controller),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _twoFieldRow({required Widget leftChild, required Widget rightChild}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SizedBox(width: double.infinity, child: leftChild),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: SizedBox(width: double.infinity, child: rightChild),
        ),
      ],
    );
  }

  Widget _readOnlyBox(String label, String text) {
    return InputDecorator(
      decoration: _pickerInputDecoration(label: label),
      child: Text(
        text,
        style: AppTextStyle.style_12_400(color: AppColors.grey900),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _buildFormGrid(
    BuildContext context,
    TicketDetailsController controller,
  ) {
    return Obx(
      () => Column(
        children: [
          _twoFieldRow(
            leftChild: MultiSelectDropdownWidget<String>(
              key: _statusKey,
              label: "Status",
              hint: "Select",
              isSingleSelect: true,
              showSearch: true,
              selectedValues: controller.selectedStatus.value != null
                  ? {controller.selectedStatus.value!}
                  : {},
              items: controller.statusOptions
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(controller.getStatusLabel(item)),
                    ),
                  )
                  .toList(),
              onChanged: (values) async {
                final v = values.isNotEmpty ? values.first : null;
                controller.selectedStatus.value = v;
                if (v != null && v != '2' && v != '3') {
                  await _selectFollowUpDateTime(context, controller);
                }
                if (v != null) {
                  _advanceToNextDropdown('status');
                }
              },
            ),
            rightChild: MultiSelectDropdownWidget<AssigneeModel>(
              key: _assigneeKey,
              label: "Assignee",
              hint: "Select",
              isSingleSelect: true,
              showSearch: true,
              selectedValues: controller.selectedAssignee.value != null
                  ? {controller.selectedAssignee.value!}
                  : {},
              items: controller.assignees
                  .map(
                    (item) =>
                        DropdownMenuItem(value: item, child: Text(item.name)),
                  )
                  .toList(),
              onChanged: (values) {
                controller.selectedAssignee.value = values.isNotEmpty
                    ? values.first
                    : null;
                if (values.isNotEmpty) {
                  _advanceToNextDropdown('assignee');
                }
              },
            ),
          ),
          SizedBox(height: 10.h),
          _twoFieldRow(
            leftChild: MultiSelectDropdownWidget<SupportCategory>(
              key: _categoryKey,
              label: "Category",
              hint: "Select",
              isSingleSelect: true,
              showSearch: true,
              selectedValues: controller.selectedCategory.value != null
                  ? {controller.selectedCategory.value!}
                  : {},
              items: controller.categories
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item.categoryName),
                    ),
                  )
                  .toList(),
              onChanged: (values) {
                final v = values.isNotEmpty ? values.first : null;
                controller.selectedCategory.value = v;
                controller.selectedSubCategory.value = null;
                if (v != null) {
                  controller.fetchSubCategories(v.categoryId);
                  _advanceToNextDropdown('category');
                }
              },
            ),
            rightChild: MultiSelectDropdownWidget<SupportSubCategory>(
              key: _subCategoryKey,
              label: "S-Category",
              hint: "Select",
              isLoading: controller.isSubCategoryLoading.value,
              isSingleSelect: true,
              showSearch: true,
              selectedValues: controller.selectedSubCategory.value != null
                  ? {controller.selectedSubCategory.value!}
                  : {},
              items: controller.subCategories
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item.subCategoryName),
                    ),
                  )
                  .toList(),
              onChanged: (values) {
                controller.selectedSubCategory.value = values.isNotEmpty
                    ? values.first
                    : null;
                if (values.isNotEmpty) {
                  _advanceToNextDropdown('subCategory');
                }
              },
            ),
          ),
          SizedBox(height: 10.h),
          _twoFieldRow(
            leftChild: MultiSelectDropdownWidget<String>(
              key: _priorityKey,
              label: "Priority",
              hint: "Select",
              isSingleSelect: true,
              showSearch: true,
              selectedValues: controller.selectedPriority.value != null
                  ? {controller.selectedPriority.value!}
                  : {},
              items: controller.priorityOptions
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(controller.getPriorityLabel(item)),
                    ),
                  )
                  .toList(),
              onChanged: (values) {
                controller.selectedPriority.value = values.isNotEmpty
                    ? values.first
                    : null;
                if (values.isNotEmpty) {
                  _advanceToNextDropdown('priority');
                }
              },
            ),
            rightChild: MultiSelectDropdownWidget<SupportProject>(
              key: _projectKey,
              label: "Project",
              hint: "Select",
              isSingleSelect: true,
              showSearch: true,
              selectedValues: controller.selectedProject.value != null
                  ? {controller.selectedProject.value!}
                  : {},
              items: controller.projects
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item.projectName),
                    ),
                  )
                  .toList(),
              onChanged: (values) {
                controller.selectedProject.value = values.isNotEmpty
                    ? values.first
                    : null;
                if (values.isNotEmpty) {
                  _advanceToNextDropdown('project');
                }
              },
            ),
          ),
          SizedBox(height: 10.h),
          _twoFieldRow(
            leftChild: MultiSelectDropdownWidget<SupportUnit>(
              key: _unitKey,
              label: "Unit",
              hint: "Select",
              isSingleSelect: true,
              showSearch: true,
              selectedValues: controller.selectedUnit.value != null
                  ? {controller.selectedUnit.value!}
                  : {},
              items: controller.units
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item.unitName),
                    ),
                  )
                  .toList(),
              onChanged: (values) {
                controller.selectedUnit.value = values.isNotEmpty
                    ? values.first
                    : null;
              },
            ),
            rightChild: _buildFollowUpField(
              context,
              controller,
              label: "Follow Up",
            ),
          ),
          SizedBox(height: 10.h),
          _twoFieldRow(
            leftChild: _buildReminderField(
              context,
              controller,
              label: "Reminder",
            ),
            rightChild: _readOnlyBox("Created By", controller.createdByName),
          ),
          SizedBox(height: 10.h),
          _twoFieldRow(
            leftChild: _readOnlyBox(
              "Created",
              controller.ticketDetail.value?.createdOn ?? "N/A",
            ),
            rightChild: _readOnlyBox(
              "Modified",
              controller.ticketDetail.value?.modifiedOn ?? "N/A",
            ),
          ),
          SizedBox(height: 10.h),
          _twoFieldRow(
            leftChild: _readOnlyBox(
              "Resolved",
              controller.ticketDetail.value?.resolvedOn ?? "-",
            ),
            rightChild: _buildTextField(
              TextEditingController(text: ""),
              label: "Linked Tkt",
              hint: "",
            ),
          ),
          SizedBox(height: 10.h),
          _twoFieldRow(
            leftChild: _buildTextField(
              TextEditingController(text: "NA"),
              label: "Fw Contact",
              hint: "NA",
            ),
            rightChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Future<void> _selectFollowUpDateTime(
    BuildContext context,
    TicketDetailsController controller,
  ) async {
    if (controller.followUpDate.value == null) {
      controller.followUpDate.value = DateTime.now();
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: controller.followUpDate.value!,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (pickedDate != null) {
      if (!context.mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        ),
      );
      if (pickedTime != null) {
        controller.followUpDate.value = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }
  }

  Widget _buildFollowUpField(
    BuildContext context,
    TicketDetailsController controller, {
    required String label,
  }) {
    return InkWell(
      onTap: () => _selectFollowUpDateTime(context, controller),
      child: InputDecorator(
        decoration: _pickerInputDecoration(label: label),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => Expanded(
                child: Text(
                  controller.followUpDate.value != null
                      ? DateFormat(
                          "dd-MMM-yyyy HH:mm",
                        ).format(controller.followUpDate.value!)
                      : "dd-mm-yyyy HH:mm",
                  style: controller.followUpDate.value == null
                      ? AppTextStyle.style_12_400(
                          color: AppColors.grey300,
                        ).copyWith(fontSize: 11.sp)
                      : AppTextStyle.style_12_400(color: AppColors.grey900),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.calendar_today_outlined,
              color: AppColors.grey300,
              size: 16.r,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderField(
    BuildContext context,
    TicketDetailsController controller, {
    required String label,
  }) {
    return InkWell(
      onTap: () {
        _showReminderDialog(context, controller);
      },
      child: InputDecorator(
        decoration: _pickerInputDecoration(label: label),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Obx(() {
                final text = controller.displayReminder.value;
                final isPlaceholder = text == 'Reminder';
                return Text(
                  text,
                  style: isPlaceholder
                      ? AppTextStyle.style_12_400(
                          color: AppColors.grey300,
                        ).copyWith(fontSize: 11.sp)
                      : AppTextStyle.style_12_400(color: AppColors.grey900),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                );
              }),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.calendar_today_outlined,
              color: AppColors.grey300,
              size: 16.r,
            ),
          ],
        ),
      ),
    );
  }

  void _showReminderDialog(
    BuildContext context,
    TicketDetailsController controller,
  ) {
    DateTime tempDate = controller.reminderDate.value ?? DateTime.now();
    TimeOfDay tempTime =
        controller.reminderTime.value ?? const TimeOfDay(hour: 9, minute: 0);
    bool tempWhatsApp = controller.whatsappNotification.value;
    bool tempApp = controller.appNotification.value;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setModalState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            backgroundColor: AppColors.white,
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(18.r),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            "Reminder / Notifications",
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.style_14_600(
                              color: AppColors.grey900,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => Get.back(),
                          borderRadius: BorderRadius.circular(20.r),
                          child: Padding(
                            padding: EdgeInsets.all(4.r),
                            child: Icon(
                              Icons.close,
                              size: 18.r,
                              color: AppColors.grey600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "Notification Type:",
                      style: AppTextStyle.style_12_500(
                        color: AppColors.grey900,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        InkWell(
                          onTap: () =>
                              setModalState(() => tempWhatsApp = !tempWhatsApp),
                          borderRadius: BorderRadius.circular(6.r),
                          child: Row(
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.whatsapp,
                                color: AppColors.green,
                                size: 18,
                              ),
                              SizedBox(width: 4.w),
                              SizedBox(
                                width: 24.w,
                                height: 24.h,
                                child: Checkbox(
                                  value: tempWhatsApp,
                                  activeColor: AppColors.primary,
                                  onChanged: (v) => setModalState(
                                    () => tempWhatsApp = v ?? false,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20.w),
                        InkWell(
                          onTap: () => setModalState(() => tempApp = !tempApp),
                          borderRadius: BorderRadius.circular(6.r),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.notifications_active,
                                color: AppColors.grey700,
                                size: 18,
                              ),
                              SizedBox(width: 4.w),
                              SizedBox(
                                width: 24.w,
                                height: 24.h,
                                child: Checkbox(
                                  value: tempApp,
                                  activeColor: AppColors.primary,
                                  onChanged: (v) =>
                                      setModalState(() => tempApp = v ?? false),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _modalPickerBox(
                            label: "Date",
                            text: DateFormat("dd MMM, yyyy").format(tempDate),
                            icon: Icons.calendar_today_outlined,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: tempDate,
                                firstDate: DateTime.now().subtract(
                                  const Duration(days: 365),
                                ),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (picked != null) {
                                setModalState(() => tempDate = picked);
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _modalPickerBox(
                            label: "Time",
                            text: tempTime.format(context),
                            icon: Icons.access_time_rounded,
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: tempTime,
                                builder: (context, child) => MediaQuery(
                                  data: MediaQuery.of(
                                    context,
                                  ).copyWith(alwaysUse24HourFormat: false),
                                  child: child!,
                                ),
                              );
                              if (picked != null) {
                                setModalState(() => tempTime = picked);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppCommonButton(
                          text: "Cancel",
                          variant: ButtonVariant.outline,
                          height: 32.h,
                          textSize: 13.sp,
                          borderRadius: 8.r,
                          textColor: AppColors.black,
                          borderColor: AppColors.borderColor,
                          onPressed: () => Get.back(),
                        ),
                        SizedBox(width: 10.w),
                        AppCommonButton(
                          text: "Apply",
                          height: 32.h,
                          textSize: 13.sp,
                          borderRadius: 8.r,
                          buttonColor: AppColors.primary,
                          useGradient: false,
                          onPressed: () {
                            controller.reminderDate.value = tempDate;
                            controller.reminderTime.value = tempTime;
                            controller.whatsappNotification.value =
                                tempWhatsApp;
                            controller.appNotification.value = tempApp;
                            controller.displayReminder.value =
                                "${DateFormat("dd MMM").format(tempDate)} ${tempTime.format(context)}";
                            Get.back();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _modalPickerBox({
    required String label,
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: _pickerInputDecoration(label: label),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.style_12_400(color: AppColors.grey900),
              ),
            ),
            SizedBox(width: 4.w),
            Icon(icon, size: 16.r, color: AppColors.grey300),
          ],
        ),
      ),
    );
  }

  InputDecoration _pickerInputDecoration({
    required String label,
    bool hasError = false,
  }) {
    return InputDecoration(
      label: RichText(
        text: TextSpan(
          text: label.replaceAll('*', ''),
          style: AppTextStyle.style_11_400(color: AppColors.grey200),
          children: label.contains('*')
              ? [
                  TextSpan(
                    text: '*',
                    style: AppTextStyle.style_11_400(color: AppColors.red),
                  ),
                ]
              : [],
        ),
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.r),
        borderSide: BorderSide(
          color: hasError ? AppColors.red : AppColors.borderColor,
          width: hasError ? 1.5 : 1.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.r),
        borderSide: BorderSide(
          color: hasError ? AppColors.red : AppColors.borderColor,
          width: hasError ? 1.5 : 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.r),
        borderSide: BorderSide(
          color: hasError ? AppColors.red : AppColors.primary,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    required String label,
    String? hint,
    int maxLines = 1,
  }) {
    return AppCommonTextField(
      controller: controller,
      labelText: label,
      hintText: hint ?? '',
      maxLines: maxLines,
    );
  }

  Widget _buildBottomActions(TicketDetailsController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Obx(
          () => AppCommonButton(
            text: "Cancel",
            variant: ButtonVariant.outline,
            height: 32.h,
            textSize: 13.sp,
            borderRadius: 8.r,
            textColor: AppColors.black,
            borderColor: AppColors.borderColor,
            onPressed: controller.isLoading.value ? null : () => Get.back(),
          ),
        ),
        SizedBox(width: 10.w),
        Obx(
          () => AppCommonButton(
            text: "Submit",
            isLoading: controller.isLoading.value,
            height: 32.h,
            textSize: 13.sp,
            borderRadius: 8.r,
            buttonColor: AppColors.primary,
            useGradient: false,
            onPressed: controller.isLoading.value
                ? null
                : () => controller.saveTicket(),
          ),
        ),
      ],
    );
  }
}
// endregion
