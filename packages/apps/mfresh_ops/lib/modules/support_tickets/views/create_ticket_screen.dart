import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'dart:io';
import 'package:core/widgets/app_common_media_source.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/create_ticket_controller.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'widgets/multi_select_dropdown.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final GlobalKey<MultiSelectDropdownWidgetState> _unitKey =
      GlobalKey<MultiSelectDropdownWidgetState>();
  final GlobalKey<MultiSelectDropdownWidgetState> _categoryKey =
      GlobalKey<MultiSelectDropdownWidgetState>();
  final GlobalKey<MultiSelectDropdownWidgetState> _subCategoryKey =
      GlobalKey<MultiSelectDropdownWidgetState>();
  final GlobalKey<MultiSelectDropdownWidgetState> _priorityKey =
      GlobalKey<MultiSelectDropdownWidgetState>();
  final GlobalKey<MultiSelectDropdownWidgetState> _projectKey =
      GlobalKey<MultiSelectDropdownWidgetState>();
  final GlobalKey<MultiSelectDropdownWidgetState> _assigneeKey =
      GlobalKey<MultiSelectDropdownWidgetState>();
  final GlobalKey<MultiSelectDropdownWidgetState> _templateKey =
      GlobalKey<MultiSelectDropdownWidgetState>();

  final FocusNode _subjectFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  @override
  void dispose() {
    _subjectFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateTicketController>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        topHeader: const CommonShortcutHeader(),
        title: Text(
          'Create Ticket',
          style: AppTextStyle.style_18_700(color: AppColors.black),
        ),
        hasBackButton: true,
      ),
      body: Obx(
        () => Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormGrid(context, controller),
                    SizedBox(height: 14.h),

                    // ── Fading Divider from both sides ──
                    Container(
                      height: 0.5.h,
                      color: AppColors.borderColor,
                    ),
                    SizedBox(height: 14.h),

                    Obx(
                      () => _buildTextField(
                        controller.subjectController,
                        label: "Subject*",
                        hint: "",
                        maxLines: 2,
                        focusNode: _subjectFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            _descriptionFocusNode.requestFocus(),
                        hasError:
                            controller.showValidationErrors.value &&
                            controller.subjectController.text
                                .trim()
                                .isEmpty,
                      ),
                    ),

                    SizedBox(height: 10.h),

                    _buildTextField(
                      controller.descriptionController,
                      label: "Description",
                      hint: "",
                      maxLines: 4,
                      focusNode: _descriptionFocusNode,
                      textInputAction: TextInputAction.done,
                    ),

                    SizedBox(height: 10.h),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Obx(
                            () => MultiSelectDropdownWidget<SupportTemplateModel>(
                              key: _templateKey,
                              label: "Template",
                              hint: "Select",
                              isSingleSelect: true,
                              showSearch: true,
                              selectedValues:
                                  controller.selectedTemplate.value != null
                                      ? {controller.selectedTemplate.value!}
                                      : {},
                              items: controller.templates
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(item.templateName),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (values) {
                                controller.onTemplateSelected(
                                  values.isNotEmpty ? values.first : null,
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        InkWell(
                          onTap: () => _showImageSourceOptions(controller),
                          borderRadius: BorderRadius.circular(4.r),
                          child: Container(
                            height: 20.h,
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              border: Border.all(color: AppColors.borderColor),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.attach_file,
                                  color: AppColors.grey900,
                                  size: 16.r,
                                ),
                                Obx(() {
                                  final count = controller.selectedImages.length +
                                      controller.selectedVideos.length;
                                  if (count == 0) return const SizedBox.shrink();
                                  return Padding(
                                    padding: EdgeInsets.only(left: 4.w),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 5.w,
                                        vertical: 1.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                      child: Text(
                                        '$count',
                                        style: AppTextStyle.style_10_600(
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    _buildAttachmentList(controller),

                    SizedBox(height: 12.h),
                    _buildSubtasksSection(controller),

                    SizedBox(height: 20.h),

                    _buildBottomActions(controller),
                  ],
                ),
              ),
            ),
            if (controller.isCompressingMedia.value ||
                controller.isLoading.value)
              Container(
                color: AppColors.black.withValues(alpha: 0.3),
                child: const Center(child: CustomAppLoader()),
              ),
          ],
        ),
      ),
    );
  }

  void _advanceToNextUnselectedField(String currentField) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<CreateTicketController>();

      if (currentField == 'category') {
        if (controller.selectedSubCategory.value == null) {
          _subCategoryKey.currentState?.openMenu();
          return;
        }
      }

      if (currentField == 'category' || currentField == 'subCategory') {
        if (controller.selectedPriority.value == null) {
          _priorityKey.currentState?.openMenu();
          return;
        }
      }

      if (currentField == 'category' ||
          currentField == 'subCategory' ||
          currentField == 'priority') {
        if (controller.selectedAssignee.value == null) {
          _assigneeKey.currentState?.openMenu();
          return;
        }
      }

      if (currentField == 'category' ||
          currentField == 'subCategory' ||
          currentField == 'priority' ||
          currentField == 'assignee') {
        if (controller.selectedUnit.value == null) {
          _unitKey.currentState?.openMenu();
          return;
        }
      }

      if (currentField == 'category' ||
          currentField == 'subCategory' ||
          currentField == 'priority' ||
          currentField == 'assignee' ||
          currentField == 'unit') {
        if (controller.selectedProject.value == null) {
          _projectKey.currentState?.openMenu();
          return;
        }
      }

      if (controller.subjectController.text.trim().isEmpty) {
        _subjectFocusNode.requestFocus();
      }
    });
  }

  Widget _buildFormGrid(
    BuildContext context,
    CreateTicketController controller,
  ) {
    return Obx(
      () => Column(
        children: [
          // Row 1: Category* | S-Category*
          _twoFieldRow(
            leftChild: MultiSelectDropdownWidget<SupportCategory>(
              key: _categoryKey,
              label: "Category*",
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
                controller.onCategorySelected(
                  values.isNotEmpty ? values.first : null,
                );
                if (values.isNotEmpty) {
                  _advanceToNextUnselectedField('category');
                }
              },
              hasError:
                  controller.showValidationErrors.value &&
                  controller.selectedCategory.value == null,
            ),
            rightChild: MultiSelectDropdownWidget<SupportSubCategory>(
              key: _subCategoryKey,
              label: "S-Category*",
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
                  _advanceToNextUnselectedField('subCategory');
                }
              },
              hasError:
                  controller.showValidationErrors.value &&
                  controller.selectedSubCategory.value == null,
            ),
          ),
          SizedBox(height: 10.h),

          // Row 2: Priority | Assignee*
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
              items: controller.priorities
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (values) {
                controller.selectedPriority.value = values.isNotEmpty
                    ? values.first
                    : null;
                if (values.isNotEmpty) {
                  _advanceToNextUnselectedField('priority');
                }
              },
            ),
            rightChild: MultiSelectDropdownWidget<AssigneeModel>(
              key: _assigneeKey,
              label: "Assignee*",
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
                  _advanceToNextUnselectedField('assignee');
                }
              },
              hasError:
                  controller.showValidationErrors.value &&
                  controller.selectedAssignee.value == null,
            ),
          ),
          SizedBox(height: 10.h),

          // Row 3: Unit* | Project*
          _twoFieldRow(
            leftChild: MultiSelectDropdownWidget<SupportUnit>(
              key: _unitKey,
              label: "Unit*",
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
                if (values.isNotEmpty) {
                  _advanceToNextUnselectedField('unit');
                }
              },
              hasError:
                  controller.showValidationErrors.value &&
                  controller.selectedUnit.value == null,
            ),
            rightChild: MultiSelectDropdownWidget<SupportProject>(
              key: _projectKey,
              label: "Project*",
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
                  _advanceToNextUnselectedField('project');
                }
              },
              hasError:
                  controller.showValidationErrors.value &&
                  controller.selectedProject.value == null,
            ),
          ),
          SizedBox(height: 10.h),

          // Row 4: Reminder
          _twoFieldRow(
            leftChild: _buildReminderField(
              context,
              controller,
              label: "Reminder",
            ),
            rightChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _twoFieldRow({
    required Widget leftChild,
    required Widget rightChild,
  }) {
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

  Widget _buildReminderField(
    BuildContext context,
    CreateTicketController controller, {
    required String label,
  }) {
    return InkWell(
      onTap: () => _showReminderDialog(context, controller),
      child: InputDecorator(
        decoration: _pickerInputDecoration(label: label),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Obx(
                () {
                  final text = controller.displayReminder.value;
                  final isPlaceholder = text == 'Reminder';
                  return Text(
                    text,
                    style: isPlaceholder
                        ? AppTextStyle.style_12_400(color: AppColors.grey300)
                            .copyWith(fontSize: 11.sp)
                        : AppTextStyle.style_12_400(color: AppColors.grey900),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  );
                },
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

  Widget _buildAttachFilesField(
    BuildContext context,
    CreateTicketController controller, {
    required String label,
  }) {
    return InkWell(
      onTap: () => _showImageSourceOptions(controller),
      child: InputDecorator(
        decoration: _pickerInputDecoration(label: label),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Obx(
                () {
                  final count = controller.selectedImages.length +
                      controller.selectedVideos.length;
                  final text =
                      count == 0 ? "Choose files" : "$count file(s) selected";
                  return Text(
                    text,
                    style: count == 0
                        ? AppTextStyle.style_12_400(color: AppColors.grey300)
                            .copyWith(fontSize: 11.sp)
                        : AppTextStyle.style_12_400(color: AppColors.grey900),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  );
                },
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.attach_file,
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
    CreateTicketController controller,
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
              borderRadius: BorderRadius.circular(25.r),
            ),
            backgroundColor: AppColors.background,
            child: Padding(
              padding: EdgeInsets.all(20.r),
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
                            "Reminder/ Notifications",
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.style_14_700(
                              color: AppColors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      "Notification Type:",
                      style: AppTextStyle.style_12_500(
                        color: AppColors.black87,
                      ),
                    ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: AppColors.green,
                          size: 20,
                        ),
                        Checkbox(
                          value: tempWhatsApp,
                          activeColor: AppColors.primary,
                          onChanged: (v) =>
                              setModalState(() => tempWhatsApp = v!),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.notifications_active,
                          color: AppColors.black,
                          size: 20,
                        ),
                        Checkbox(
                          value: tempApp,
                          activeColor: AppColors.primary,
                          onChanged: (v) => setModalState(() => tempApp = v!),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(
                          child: _modalPickerBox(
                            text: DateFormat("dd/MM/yyyy").format(tempDate),
                            icon: Icons.calendar_today,
                            onTap: () async {
                              final p = await showDatePicker(
                                context: context,
                                initialDate: tempDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (p != null) setModalState(() => tempDate = p);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _modalPickerBox(
                            text: tempTime.format(context),
                            icon: Icons.arrow_drop_down,
                            onTap: () async {
                              final t = await showTimePicker(
                                context: context,
                                initialTime: tempTime,
                                builder: (context, child) => MediaQuery(
                                  data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                                  child: child!,
                                ),
                              );
                              if (t != null) setModalState(() => tempTime = t);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.black.withValues(
                                alpha: 0.05,
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            onPressed: () => Get.back(),
                            child: Text(
                              "Cancel",
                              style: AppTextStyle.style_14_600(color: AppColors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.clockIn,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
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
                            child: Text(
                              "Apply",
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
        },
      ),
    );
  }

  Widget _modalPickerBox({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.style_12_400(color: AppColors.black87),
              ),
            ),
            Icon(icon, size: 14, color: AppColors.black.withValues(alpha: 0.54)),
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
                  )
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

  InputDecoration _inputDecoration(
    String label, {
    String? hint,
    bool hasError = false,
    int maxLines = 1,
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
                  )
                ]
              : [],
        ),
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintText: hint,
      hintStyle: AppTextStyle.style_12_400(color: AppColors.grey300).copyWith(fontSize: 11.sp),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 6.w,
        vertical: maxLines == 1 ? 3.h : 6.h,
      ),
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
      isDense: true,
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    required String label,
    String? hint,
    int maxLines = 1,
    bool hasError = false,
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
      style: AppTextStyle.style_12_400(color: AppColors.black),
      decoration: _inputDecoration(
        label,
        hint: hint,
        hasError: hasError,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildAttachmentList(CreateTicketController controller) {
    return Obx(() {
      if (controller.selectedImages.isEmpty &&
          controller.selectedVideos.isEmpty) {
        return Text(
          "No files chosen",
          style: AppTextStyle.style_12_400(color: AppColors.grey200),
        );
      }
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ...controller.selectedImages.asMap().entries.map((entry) {
            int index = entry.key;
            return Stack(
              children: [
                Container(
                  width: 60.w,
                  height: 60.h,
                  margin: const EdgeInsets.only(top: 4, right: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.file(
                      File(entry.value.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: InkWell(
                    onTap: () => controller.removeImage(index),
                    child: const CircleAvatar(
                      radius: 7,
                      backgroundColor: AppColors.red,
                      child: Icon(Icons.close, size: 8, color: AppColors.white),
                    ),
                  ),
                ),
              ],
            );
          }),
          ...controller.selectedVideos.asMap().entries.map((entry) {
            int index = entry.key;
            String fileName = entry.value.path.split('/').last;
            return Stack(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  margin: const EdgeInsets.only(top: 4, right: 4),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.videocam,
                        size: 12,
                        color: AppColors.orange,
                      ),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: Text(
                          fileName,
                          style: AppTextStyle.style_11_400(color: AppColors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: InkWell(
                    onTap: () => controller.removeVideo(index),
                    child: const CircleAvatar(
                      radius: 7,
                      backgroundColor: AppColors.red,
                      child: Icon(Icons.close, size: 8, color: AppColors.white),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      );
    });
  }

  Widget _buildSubtasksSection(CreateTicketController controller) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtasks',
                style: AppTextStyle.style_12_500(color: AppColors.grey900),
              ),
              InkWell(
                onTap: () => controller.addSubtaskField(),
                borderRadius: BorderRadius.circular(4.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 14.r,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Add Subtask',
                        style: AppTextStyle.style_11_600(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (controller.subtaskControllers.isNotEmpty) SizedBox(height: 6.h),
          ...controller.subtaskControllers.asMap().entries.map((entry) {
            final index = entry.key;
            final subController = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      subController,
                      label: 'Subtask ${index + 1}',
                      hint: 'Enter subtask details',
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  InkWell(
                    onTap: () => controller.removeSubtaskField(index),
                    child: Padding(
                      padding: EdgeInsets.all(4.r),
                      child: Icon(
                        Icons.remove_circle_outline,
                        color: AppColors.red,
                        size: 18.r,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    });
  }

  void _showImageSourceOptions(CreateTicketController controller) {
    AppCommonMediaSource.show(
      onTakePhoto: controller.takePhoto,
      onChoosePhoto: controller.pickImages,
      onRecordVideo: controller.recordVideo,
      onChooseVideo: controller.pickVideo,
    );
  }

  Widget _buildBottomActions(CreateTicketController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Obx(
          () => TextButton(
            onPressed:
                (controller.isLoading.value ||
                    controller.isCompressingMedia.value)
                ? null
                : () => Get.back(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
              minimumSize: Size(0, 32.h),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
                side: BorderSide(color: AppColors.borderColor),
              ),
            ),
            child: Text(
              "Cancel",
              style: AppTextStyle.style_13_400(color: AppColors.black),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Obx(
          () => ElevatedButton(
            onPressed:
                (controller.isLoading.value ||
                    controller.isCompressingMedia.value)
                ? null
                : () => controller.createTicket(),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  (controller.isLoading.value ||
                      controller.isCompressingMedia.value)
                  ? AppColors.grey200
                  : AppColors.primary,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 6.h),
              minimumSize: Size(0, 32.h),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: controller.isLoading.value
                ? SizedBox(
                    width: 14.r,
                    height: 14.r,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Text("Submit", style: AppTextStyle.style_13_600(color: AppColors.white)),
          ),
        ),
      ],
    );
  }
}
