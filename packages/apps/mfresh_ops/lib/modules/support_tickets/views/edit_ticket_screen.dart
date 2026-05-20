import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:core/widgets/app_common_media_source.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/ticket_details_controller.dart';
import 'package:mfresh_ops/data/models/models.dart';

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
            width: Get.width * 0.95,
            constraints: BoxConstraints(
              maxHeight: Get.height * 0.9,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                      "TICKET # ${controller.ticketDetail.value?.caseId ?? controller.ticketDetail.value?.id ?? ''}",
                      style: const TextStyle(
                        color: primaryOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )),
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

                        const Text(
                          "Subject",
                          style: TextStyle(
                            color: primaryOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildTextField(controller.subjectController, "Subject Line"),

                        const SizedBox(height: 12),

                        const Text(
                          "Description",
                          style: TextStyle(
                            color: primaryOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildTextField(controller.descriptionController, "Description here", maxLines: 3),

                        const SizedBox(height: 12),
                        _buildAttachmentsSection(context, controller),
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
    return Obx(() => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldWrapper("Status", _buildDropdown<String>(
                controller.selectedStatus.value,
                controller.statusOptions,
                (v) => controller.selectedStatus.value = v,
                (item) => item,
              )),
              _fieldWrapper("Priority", _buildDropdown<String>(
                controller.selectedPriority.value,
                controller.priorityOptions,
                (v) => controller.selectedPriority.value = v,
                (item) => item,
              )),
              _fieldWrapper("Category", _buildDropdown<SupportCategory>(
                controller.selectedCategory.value,
                controller.categories,
                (v) {
                  controller.selectedCategory.value = v;
                  if (v != null) controller.fetchSubCategories(v.categoryId);
                },
                (item) => item.categoryName,
              )),
              _fieldWrapper("Sub Category", _buildDropdown<SupportSubCategory>(
                controller.selectedSubCategory.value,
                controller.subCategories,
                (v) => controller.selectedSubCategory.value = v,
                (item) => item.subCategoryName,
              )),
              _fieldWrapper("Assignee", _buildDropdown<AssigneeModel>(
                controller.selectedAssignee.value,
                controller.assignees,
                (v) => controller.selectedAssignee.value = v,
                (item) => item.name,
              )),
              _fieldWrapper("Unit", _buildDropdown<SupportUnit>(
                controller.selectedUnit.value,
                controller.units,
                (v) => controller.selectedUnit.value = v,
                (item) => item.unitName,
              )),
              _fieldWrapper("Project", _buildDropdown<SupportProject>(
                controller.selectedProject.value,
                controller.projects,
                (v) => controller.selectedProject.value = v,
                (item) => item.projectName,
              )),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Right Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldWrapper("Created By", _readOnlyBox(controller.ticketDetail.value?.userName ?? "N/A")),
              _fieldWrapper("Created On", _readOnlyBox(controller.ticketDetail.value?.createdOn ?? "N/A")),
              _fieldWrapper("Modified On", _readOnlyBox(controller.ticketDetail.value?.modifiedOn ?? "N/A")),
              _fieldWrapper("Resolved", _readOnlyBox(controller.ticketDetail.value?.resolvedOn ?? "N/A")),
              _fieldWrapper("Ticket Age", _readOnlyBox(controller.ticketDetail.value?.tktAge ?? "N/A")),
              _fieldWrapper("Reminder", _buildReminderField(context, controller)),
              _fieldWrapper("Link Ticket", _buildTextField(TextEditingController(text: "NA"), "Link Ticket")),
            ],
          ),
        ),
      ],
    ));
  }

  Widget _fieldWrapper(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 75,
            child: Text(
              label,
              style: const TextStyle(
                color: primaryOrange,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _readOnlyBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xffF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: Colors.black87),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildReminderField(BuildContext context, TicketDetailsController controller) {
    return InkWell(
      onTap: () => _showReminderDialog(context, controller),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xffF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() => Expanded(
              child: Text(
                controller.displayReminder.value,
                style: TextStyle(
                  fontSize: 10,
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
                      const Icon(Icons.notifications_active, color: Colors.black, size: 18),
                      const SizedBox(width: 4),
                      Checkbox(
                        value: tempApp,
                        activeColor: primaryOrange,
                        onChanged: (v) => setModalState(() => tempApp = v!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                                  lastDate: DateTime(2100));
                              if (p != null) setModalState(() => tempDate = p);
                            }),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _modalPickerBox(
                            text: tempTime.format(context),
                            icon: Icons.arrow_drop_down,
                            onTap: () async {
                              final t = await showTimePicker(
                                  context: context, initialTime: tempTime);
                              if (t != null) setModalState(() => tempTime = t);
                            }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade400,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => Get.back(),
                          child: const Text("Cancel", style: TextStyle(color: Colors.white, fontSize: 12)),
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
                  )
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
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
    T? safeValue = value;
    if (value != null && !options.contains(value)) {
      safeValue = null;
    }
    return DropdownButtonFormField<T>(
      value: safeValue,
      isExpanded: true,
      icon: const SizedBox.shrink(),
      decoration: _inputDecoration("Select"),
      items: options.map((e) => DropdownMenuItem(value: e, child: Text(labelBuilder(e), style: const TextStyle(fontSize: 10)))).toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 10),
      filled: true,
      fillColor: const Color(0xffF5F5F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      isDense: true,
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 11),
      decoration: _inputDecoration(hint),
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

  Widget _buildAttachmentsSection(BuildContext context, TicketDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 75,
              child: Text(
                "Attachments",
                style: TextStyle(
                  color: primaryOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
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
                    Icon(Icons.description, size: 12, color: primaryOrange),
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
          ],
        ),
        Obx(() {
          if (controller.selectedImages.isEmpty &&
              controller.selectedVideos.isEmpty &&
              (controller.ticketDetail.value?.attachments == null ||
                  controller.ticketDetail.value!.attachments!.isEmpty)) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(left: 75, top: 6),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (controller.ticketDetail.value?.attachments != null)
                  ...controller.ticketDetail.value!.attachments!.map((att) {
                    final filename = att.split('/').last;
                    final isVideo = filename.toLowerCase().endsWith('.mp4') ||
                                    filename.toLowerCase().endsWith('.mov') ||
                                    filename.toLowerCase().endsWith('.avi') ||
                                    filename.toLowerCase().endsWith('.mkv');
                    return Chip(
                      label: Text(filename, style: const TextStyle(fontSize: 8)),
                      avatar: Icon(
                        isVideo ? Icons.videocam : Icons.description,
                        size: 10,
                        color: primaryOrange,
                      ),
                      backgroundColor: const Color(0xFFFFF3F0),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }),
                ...controller.selectedImages.map((file) {
                  final filename = file.path.split('/').last;
                  return Chip(
                    label: Text(filename, style: const TextStyle(fontSize: 8)),
                    avatar: const Icon(Icons.description, size: 10, color: primaryOrange),
                    backgroundColor: const Color(0xFFFFF3F0),
                    onDeleted: () => controller.selectedImages.remove(file),
                    deleteIconColor: Colors.red,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }),
                ...controller.selectedVideos.map((file) {
                  final filename = file.path.split('/').last;
                  return Chip(
                    label: Text(filename, style: const TextStyle(fontSize: 8)),
                    avatar: const Icon(Icons.videocam, size: 10, color: primaryOrange),
                    backgroundColor: const Color(0xFFFFF3F0),
                    onDeleted: () => controller.selectedVideos.remove(file),
                    deleteIconColor: Colors.red,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
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
