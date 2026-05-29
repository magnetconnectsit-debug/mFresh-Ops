import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:core/widgets/app_common_app_bar.dart';
import 'dart:io';
import 'package:core/widgets/app_common_media_source.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/create_ticket_controller.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'widgets/multi_select_dropdown.dart';

class CreateTicketScreen extends StatelessWidget {
  const CreateTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateTicketController>();

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppCommonAppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Create Ticket',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        hasBackButton: true,
      ),
      body: Obx(
        () => Stack(
          children: [
            SafeArea(
              child: Center(
          child: Container(
            width: Get.width * 0.95,
            margin: EdgeInsets.symmetric(vertical: 20.h),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Create Ticket",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.black54,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  _buildFormGrid(context, controller),
                  SizedBox(height: 12.h),

                  _buildLabel("Subject*"),
                  SizedBox(height: 4.h),
                  Obx(
                    () => _buildTextField(
                      controller.subjectController,
                      "Subject Line",
                      maxLines: 2,
                      hasError: controller.showValidationErrors.value &&
                          controller.subjectController.text.trim().isEmpty,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 4.h),
                  _buildTextField(
                    controller.descriptionController,
                    "Description here",
                    maxLines: 4,
                  ),

                  SizedBox(height: 12.h),

                  Obx(
                    () => _twoFieldRow(
                      leftLabel: "Attach Files",
                      leftChild: InkWell(
                        onTap: () => _showImageSourceOptions(controller),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffF5F5F5),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  (controller.selectedImages.isEmpty &&
                                          controller.selectedVideos.isEmpty)
                                      ? "Choose files"
                                      : "${controller.selectedImages.length + controller.selectedVideos.length} file(s) selected",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        (controller.selectedImages.isEmpty &&
                                            controller.selectedVideos.isEmpty)
                                        ? Colors.grey
                                        : Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.attach_file, size: 16),
                            ],
                          ),
                        ),
                      ),
                      rightLabel: "Template",
                      rightChild: MultiSelectDropdownWidget<SupportTemplateModel>(
                        hint: "Select",
                        isSingleSelect: true,
                        showSearch: true,
                        height: 32.h,
                        selectedValues: controller.selectedTemplate.value != null
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
                  SizedBox(height: 8.h),
                  _buildAttachmentList(controller),


                  SizedBox(height: 20.h),

                  _buildBottomActions(controller),
                ],
              ),
            ),
          ),
                ),
              ),
            if (controller.isCompressingMedia.value || controller.isLoading.value)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(child: CustomAppLoader()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormGrid(
    BuildContext context,
    CreateTicketController controller,
  ) {
    return Obx(
      () => Column(
        children: [
          _twoFieldRow(
            leftLabel: "Occurred*",
            leftChild: _buildOccurredField(context, controller),
            rightLabel: "Unit*",
            rightChild: MultiSelectDropdownWidget<SupportUnit>(
              hint: "Select",
              isSingleSelect: true,
              showSearch: true,
              height: 32.h,
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
                controller.selectedUnit.value =
                    values.isNotEmpty ? values.first : null;
              },
              hasError: controller.showValidationErrors.value &&
                  controller.selectedUnit.value == null,
            ),
          ),
          SizedBox(height: 5.h),
          _twoFieldRow(
            leftLabel: "Category*",
            leftChild: MultiSelectDropdownWidget<SupportCategory>(
              hint: "Select",
              isSingleSelect: true,
              showSearch: true,
              height: 32.h,
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
              },
              hasError: controller.showValidationErrors.value &&
                  controller.selectedCategory.value == null,
            ),
            rightLabel: "S-Category",
            rightChild: MultiSelectDropdownWidget<SupportSubCategory>(
              hint: "Select",
              isSingleSelect: true,
              showSearch: true,
              height: 32.h,
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
                controller.selectedSubCategory.value =
                    values.isNotEmpty ? values.first : null;
              },
            ),
          ),
          SizedBox(height: 5.h),
          _twoFieldRow(
            leftLabel: "Priority",
            leftChild: MultiSelectDropdownWidget<String>(
              hint: "Select",
              isSingleSelect: true,
              showSearch: true,
              height: 32.h,
              selectedValues: controller.selectedPriority.value != null
                  ? {controller.selectedPriority.value!}
                  : {},
              items: controller.priorities
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: (values) {
                controller.selectedPriority.value =
                    values.isNotEmpty ? values.first : null;
              },
            ),
            rightLabel: "Project*",
            rightChild: MultiSelectDropdownWidget<SupportProject>(
              hint: "Select",
              isSingleSelect: true,
              showSearch: true,
              height: 32.h,
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
                controller.selectedProject.value =
                    values.isNotEmpty ? values.first : null;
              },
              hasError: controller.showValidationErrors.value &&
                  controller.selectedProject.value == null,
            ),
          ),
          SizedBox(height: 5.h),
          _twoFieldRow(
            leftLabel: "Assignee*",
            leftChild: MultiSelectDropdownWidget<AssigneeModel>(
              hint: "Select",
              isSingleSelect: true,
              showSearch: true,
              height: 32.h,
              selectedValues: controller.selectedAssignee.value != null
                  ? {controller.selectedAssignee.value!}
                  : {},
              items: controller.assignees
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item.name),
                    ),
                  )
                  .toList(),
              onChanged: (values) {
                controller.selectedAssignee.value =
                    values.isNotEmpty ? values.first : null;
              },
              hasError: controller.showValidationErrors.value &&
                  controller.selectedAssignee.value == null,
            ),
            rightLabel: "Reminder",
            rightChild: _buildReminderField(context, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    if (text.endsWith('*')) {
      final labelText = text.substring(0, text.length - 1);
      return Text.rich(
        TextSpan(
          text: labelText,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          children: const [
            TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }

  Widget _twoFieldRow({
    required String leftLabel,
    required Widget leftChild,
    required String rightLabel,
    required Widget rightChild,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(leftLabel),
              SizedBox(height: 4.h),
              SizedBox(width: double.infinity, child: leftChild),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(rightLabel),
              SizedBox(height: 4.h),
              SizedBox(width: double.infinity, child: rightChild),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOccurredField(
    BuildContext context,
    CreateTicketController controller,
  ) {
    return InkWell(
      onTap: () => controller.selectDate(context),
      child: Container(
        height: 32.h,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xffF5F5F5),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => Text(
                DateFormat("dd/MM/yyyy").format(controller.occurredDate.value),
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderField(
    BuildContext context,
    CreateTicketController controller,
  ) {
    return InkWell(
      onTap: () => _showReminderDialog(context, controller),
      child: Container(
        height: 32.h,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xffF5F5F5),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => Expanded(
                child: Text(
                  controller.displayReminder.value,
                  style: TextStyle(
                    fontSize: 12,
                    color: controller.displayReminder.value == 'Reminder'
                        ? Colors.grey
                        : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 16),
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
            backgroundColor: const Color(0xFFF7F2EE),
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
                        const Flexible(
                          child: Text(
                            "Reminder/ Notifications",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
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
                    const Text(
                      "Notification Type:",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Icon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.green,
                          size: 20,
                        ),
                        Checkbox(
                          value: tempWhatsApp,
                          activeColor: const Color(0xffF15A24),
                          onChanged: (v) =>
                              setModalState(() => tempWhatsApp = v!),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.notifications_active,
                          color: Colors.black,
                          size: 20,
                        ),
                        Checkbox(
                          value: tempApp,
                          activeColor: const Color(0xffF15A24),
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
                              backgroundColor: Colors.black.withValues(
                                alpha: 0.05,
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            onPressed: () => Get.back(),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff4CAF50),
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
                            child: const Text(
                              "Apply",
                              style: TextStyle(color: Colors.white),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            Icon(icon, size: 14, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {bool hasError = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
      filled: true,
      fillColor: const Color(0xffF5F5F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: hasError
            ? const BorderSide(color: Colors.red, width: 1.5)
            : BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: hasError
            ? const BorderSide(color: Colors.red, width: 1.5)
            : BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(
          color: hasError ? Colors.red : const Color(0xffF15A24),
          width: 1.5,
        ),
      ),
      isDense: true,
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    bool hasError = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 12),
      decoration: _inputDecoration(hint, hasError: hasError),
    );
  }

  Widget _buildAttachmentList(CreateTicketController controller) {
    return Obx(() {
      if (controller.selectedImages.isEmpty &&
          controller.selectedVideos.isEmpty) {
        return const Text(
          "No files chosen",
          style: TextStyle(fontSize: 12, color: Colors.grey),
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
                      border: Border.all(color: Colors.grey.shade300),
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
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, size: 8, color: Colors.white),
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
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.videocam,
                        size: 12,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: Text(
                          fileName,
                          style: const TextStyle(fontSize: 11),
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
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, size: 8, color: Colors.white),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 10),
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
                  ? Colors.grey
                  : const Color(0xffF15A24),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text("Submit", style: TextStyle(fontSize: 14)),
          ),
        ),
      ],
    );
  }
}
