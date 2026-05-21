import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:core/widgets/app_common_media_source.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/ticket_details_controller.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:core/utils/app_common_toast_message.dart';

class EditTicketScreen extends StatelessWidget {
  const EditTicketScreen({super.key});

  static const Color primaryOrange = Color(0xFFFF7043);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TicketDetailsController>();

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      body: SafeArea(
        child: Center(
          child: Container(
            width: Get.width > 700 ? Get.width * 0.7 : Get.width * 0.95,
            margin: const EdgeInsets.symmetric(vertical: 20),
            constraints: BoxConstraints(
              maxHeight: Get.height * 0.9,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Update Ticket",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.black54, size: 20),
                    )
                  ],
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormGrid(context, controller),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFE0E0E0)),
                        const SizedBox(height: 12),

                        const Text("Subject",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        _buildTextField(controller.subjectController, "Subject Line"),
                        
                        const SizedBox(height: 12),

                        const Text("Description",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        _buildTextField(controller.descriptionController, "Description here", maxLines: 4),


                        // ─── Subtasks Section ─────────────────────────────
                        Obx(() {
                          final subtasks = controller.ticketDetail.value?.subtasks ?? [];
                          if (subtasks.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              const Text("Subtasks",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: subtasks.asMap().entries.map((entry) {
                                    final st = entry.value;
                                    final isLast = entry.key == subtasks.length - 1;
                                    return Obx(() {
                                      final isChecked = controller.isSubtaskChecked(st.id);
                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            child: Row(
                                              children: [
                                                Checkbox(
                                                  value: isChecked,
                                                  activeColor: primaryOrange,
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  visualDensity: VisualDensity.compact,
                                                  onChanged: (v) => controller.toggleSubtaskCheck(st.id),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    st.subtask ?? '',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: isChecked ? Colors.grey : Colors.black87,
                                                      decoration: isChecked ? TextDecoration.lineThrough : null,
                                                    ),
                                                  ),
                                                ),
                                                // Status badge
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: isChecked
                                                        ? const Color(0xFFE8F5E9)
                                                        : const Color(0xFFFFF3E0),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    isChecked ? 'Done' : 'Pending',
                                                    style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                      color: isChecked
                                                          ? const Color(0xFF2E7D32)
                                                          : const Color(0xFFE65100),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                // Delete icon
                                                InkWell(
                                                  onTap: controller.isSubtaskLoading.value
                                                      ? null
                                                      : () {
                                                          Get.dialog(
                                                            AlertDialog(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(12),
                                                              ),
                                                              title: const Text(
                                                                'Delete Subtask',
                                                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                                              ),
                                                              content: Text(
                                                                'Delete "${st.subtask}"?',
                                                                style: const TextStyle(fontSize: 12),
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () => Get.back(),
                                                                  child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () async {
                                                                    Get.back(); // Close dialog first
                                                                    final success = await controller.deleteSubtask(st.id);
                                                                    if (success) {
                                                                      AppCommonToastMessage.show(
                                                                        message: 'Subtask deleted successfully',
                                                                        type: ToastType.success,
                                                                      );
                                                                    }
                                                                  },
                                                                  child: const Text(
                                                                    'Delete',
                                                                    style: TextStyle(
                                                                      fontSize: 12,
                                                                      color: Colors.red,
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(4),
                                                    child: Icon(Icons.delete_outline, color: Colors.red, size: 16),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (!isLast)
                                            const Divider(height: 1, color: Color(0xFFEEEEEE)),
                                        ],
                                      );
                                    });
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '✓ Check a subtask to mark it as completed (esubtask)',
                                style: TextStyle(fontSize: 9, color: Colors.grey, fontStyle: FontStyle.italic),
                              ),
                            ],
                          );
                        }),

                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildBottomActions(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormGrid(BuildContext context, TicketDetailsController controller) {
    return Obx(() => Column(
      children: [
        _twoFieldRow(
          leftLabel: "Status",
          leftChild: _buildDropdown<String>(
            controller.selectedStatus.value,
            controller.statusOptions,
            (v) => controller.selectedStatus.value = v,
            (item) => controller.getStatusLabel(item),
          ),
          rightLabel: "Created By",
          rightChild: _readOnlyBox(controller.ticketDetail.value?.userName ?? "N/A"),
        ),
        const SizedBox(height: 5),
        _twoFieldRow(
          leftLabel: "Priority",
          leftChild: _buildDropdown<String>(
            controller.selectedPriority.value,
            controller.priorityOptions,
            (v) => controller.selectedPriority.value = v,
            (item) => controller.getPriorityLabel(item),
          ),
          rightLabel: "Created On",
          rightChild: _readOnlyBox(controller.ticketDetail.value?.createdOn ?? "N/A", Icons.calendar_today),
        ),
        const SizedBox(height: 5),
        _twoFieldRow(
          leftLabel: "Category",
          leftChild: _buildDropdown<SupportCategory>(
            controller.selectedCategory.value,
            controller.categories,
            (v) {
              controller.selectedCategory.value = v;
              if (v != null) controller.fetchSubCategories(v.categoryId);
            },
            (item) => item.categoryName,
          ),
          rightLabel: "Modified On",
          rightChild: _readOnlyBox(controller.ticketDetail.value?.modifiedOn ?? "N/A", Icons.edit_calendar),
        ),
        const SizedBox(height: 5),
        _twoFieldRow(
          leftLabel: "Sub Category",
          leftChild: _buildDropdown<SupportSubCategory>(
            controller.selectedSubCategory.value,
            controller.subCategories,
            (v) => controller.selectedSubCategory.value = v,
            (item) => item.subCategoryName,
          ),
          rightLabel: "Resolved",
          rightChild: _readOnlyBox(controller.ticketDetail.value?.resolvedOn ?? "N/A", Icons.check_circle_outline),
        ),
        const SizedBox(height: 5),
        _twoFieldRow(
          leftLabel: "Assignee",
          leftChild: _buildDropdown<AssigneeModel>(
            controller.selectedAssignee.value,
            controller.assignees,
            (v) => controller.selectedAssignee.value = v,
            (item) => item.name,
          ),
          rightLabel: "Ticket Age",
          rightChild: _readOnlyBox(controller.ticketDetail.value?.tktAge ?? "N/A"),
        ),
        const SizedBox(height: 5),
        _twoFieldRow(
          leftLabel: "Unit",
          leftChild: _buildDropdown<SupportUnit>(
            controller.selectedUnit.value,
            controller.units,
            (v) => controller.selectedUnit.value = v,
            (item) => item.unitName,
          ),
          rightLabel: "Reminder",
          rightChild: _buildReminderField(context, controller),
        ),
        const SizedBox(height: 5),
        _twoFieldRow(
          leftLabel: "Project",
          leftChild: _buildDropdown<SupportProject>(
            controller.selectedProject.value,
            controller.projects,
            (v) => controller.selectedProject.value = v,
            (item) => item.projectName,
          ),
          rightLabel: "Link Ticket",
          rightChild: _buildTextField(TextEditingController(text: "NA"), "Link Ticket", verticalPadding: 13),
        ),
      ],
    ));
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
              Text(leftLabel,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              SizedBox(width: double.infinity, child: leftChild),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rightLabel,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              SizedBox(width: double.infinity, child: rightChild),
            ],
          ),
        ),
      ],
    );
  }

  Widget _readOnlyBox(String text, [IconData? icon]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xffF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (icon != null) Icon(icon, size: 14, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _buildReminderField(BuildContext context, TicketDetailsController controller) {
    return InkWell(
      onTap: () => _showReminderDialog(context, controller),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xffF5F5F5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() => Expanded(
              child: Text(
                controller.displayReminder.value,
                style: TextStyle(
                  fontSize: 12,
                  color: controller.displayReminder.value == 'Reminder' ? Colors.grey : Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            )),
            const Icon(Icons.calendar_today_outlined, size: 12),
          ],
        ),
      ),
    );
  }

  void _showReminderDialog(BuildContext context, TicketDetailsController controller) {
    DateTime tempDate = controller.reminderDate.value ?? DateTime.now();
    TimeOfDay tempTime = controller.reminderTime.value ?? const TimeOfDay(hour: 9, minute: 0);
    bool tempWhatsApp = controller.whatsappNotification.value;
    bool tempApp = controller.appNotification.value;

    Get.dialog(
      StatefulBuilder(builder: (context, setModalState) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFFF7F2EE),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text("Reminder/ Notifications",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Get.back(), 
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Notification Type:",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryOrange)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 18),
                      const SizedBox(width: 4),
                      Checkbox(
                        value: tempWhatsApp,
                        activeColor: primaryOrange,
                        onChanged: (v) => setModalState(() => tempWhatsApp = v!),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.notifications, color: Colors.black54, size: 18),
                      const SizedBox(width: 4),
                      Checkbox(
                        value: tempApp,
                        activeColor: primaryOrange,
                        onChanged: (v) => setModalState(() => tempApp = v!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text("Date & Time:",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryOrange)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: _modalPickerBox(
                          text: DateFormat("dd MMM, yyyy").format(tempDate),
                          icon: Icons.calendar_today_outlined,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: tempDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) setModalState(() => tempDate = picked);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _modalPickerBox(
                          text: tempTime.format(context),
                          icon: Icons.access_time,
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: tempTime,
                            );
                            if (picked != null) setModalState(() => tempTime = picked);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => Get.back(),
                          child: const Text("Cancel", style: TextStyle(color: Colors.black87, fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff4CAF50), // Green Apply!
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            controller.reminderDate.value = tempDate;
                            controller.reminderTime.value = tempTime;
                            controller.whatsappNotification.value = tempWhatsApp;
                            controller.appNotification.value = tempApp;
                            controller.displayReminder.value = 
                              "${DateFormat("dd MMM").format(tempDate)} ${tempTime.format(context)}";
                            Get.back();
                          },
                          child: const Text("Apply", style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _modalPickerBox({required String text, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xffF5F5F5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11))),
            Icon(icon, size: 12, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>(T? value, List<T> options, Function(T?) onChanged, String Function(T) labelBuilder) {
    List<T> safeOptions = List.from(options);
    if (value != null && !safeOptions.contains(value)) {
      safeOptions.insert(0, value);
    }
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      icon: const SizedBox.shrink(),
      decoration: _inputDecoration("Select"),
      items: safeOptions.map((e) => DropdownMenuItem(value: e, child: Text(labelBuilder(e), style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))).toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _inputDecoration(String hint, {double verticalPadding = 10}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12),
      filled: true,
      fillColor: const Color(0xffF5F5F5),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: verticalPadding),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      isDense: true,
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, double verticalPadding = 10}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 12),
      decoration: _inputDecoration(hint, verticalPadding: verticalPadding),
    );
  }

  void _showMediaSourceOptions(BuildContext context, TicketDetailsController controller) {
    AppCommonMediaSource.show(
      onTakePhoto: controller.captureImage,
      onChoosePhoto: controller.pickImages,
      onRecordVideo: controller.recordVideo,
      onChooseVideo: controller.pickVideo,
    );
  }

  Widget _buildAttachmentsContent(BuildContext context, TicketDetailsController controller) {
    return Obx(() => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        InkWell(
          onTap: () => _showMediaSourceOptions(context, controller),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3F0),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryOrange.withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_a_photo, size: 12, color: primaryOrange),
                SizedBox(width: 4),
                Text(
                  "Choose files",
                  style: TextStyle(
                    color: primaryOrange,
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (controller.ticketDetail.value?.attachments != null)
          ...controller.ticketDetail.value!.attachments!.map((att) {
            final filename = att.split('/').last;
            final isVideo = filename.toLowerCase().endsWith('.mp4') ||
                            filename.toLowerCase().endsWith('.mov') ||
                            filename.toLowerCase().endsWith('.avi') ||
                            filename.toLowerCase().endsWith('.mkv');
            return Chip(
              label: Text(filename, style: const TextStyle(fontSize: 10, color: primaryOrange, fontWeight: FontWeight.bold)),
              avatar: Icon(
                isVideo ? Icons.videocam : Icons.attach_file,
                size: 12,
                color: primaryOrange,
              ),
              backgroundColor: const Color(0xFFE0E0E0),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          }),
        ...controller.selectedImages.map((file) {
          final filename = file.path.split('/').last;
          return Chip(
            label: Text(filename, style: const TextStyle(fontSize: 10, color: primaryOrange, fontWeight: FontWeight.bold)),
            avatar: const Icon(Icons.attach_file, size: 12, color: primaryOrange),
            backgroundColor: const Color(0xFFE0E0E0),
            onDeleted: () => controller.selectedImages.remove(file),
            deleteIconColor: Colors.black54,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        }),
        ...controller.selectedVideos.map((file) {
          final filename = file.path.split('/').last;
          return Chip(
            label: Text(filename, style: const TextStyle(fontSize: 10, color: primaryOrange, fontWeight: FontWeight.bold)),
            avatar: const Icon(Icons.videocam, size: 12, color: primaryOrange),
            backgroundColor: const Color(0xFFE0E0E0),
            onDeleted: () => controller.selectedVideos.remove(file),
            deleteIconColor: Colors.black54,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        }),
      ],
    ));
  }

  Widget _buildBottomActions(TicketDetailsController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Obx(() => OutlinedButton(
          onPressed: controller.isLoading.value ? null : () => Get.back(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            side: BorderSide(color: Colors.grey[300]!),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        )),
        const SizedBox(width: 16),
        Obx(() => ElevatedButton(
          onPressed: controller.isLoading.value ? null : () => controller.saveTicket(),
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.isLoading.value ? Colors.grey : const Color(0xff4CAF50), // Green Save button!
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text(
                  "Save",
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
        )),
      ],
    );
  }
}
