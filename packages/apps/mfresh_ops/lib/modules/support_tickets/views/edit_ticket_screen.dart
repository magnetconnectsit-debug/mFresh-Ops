import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/ticket_details_controller.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'widgets/multi_select_dropdown.dart';

class EditTicketScreen extends StatelessWidget {
  const EditTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TicketDetailsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF9),
      appBar: AppCommonAppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        hasBackButton: true,
        title: Obx(
          () => RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: "Edit Ticket ",
                  style: TextStyle(
                    color: AppColors.primaryOrange,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text:
                      "# ${controller.ticketDetail.value?.caseId ?? controller.ticketDetail.value?.id ?? ''}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormGrid(context, controller),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFE0E0E0)),
                    const SizedBox(height: 12),

                    const Text(
                      "Subject",
                      style: TextStyle(
                        color: AppColors.primaryOrange,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildTextField(
                      controller.subjectController,
                      "Subject Line",
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Description",
                      style: TextStyle(
                        color: AppColors.primaryOrange,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildTextField(
                      controller.descriptionController,
                      "Description here",
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
                          const SizedBox(height: 12),
                          const Text(
                            "Sub Tasks",
                            style: TextStyle(
                              color: AppColors.primaryOrange,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                                  final isChecked = controller.isSubtaskChecked(
                                    st.id,
                                  );
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
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
                                                  .toggleSubtaskCheck(st.id),
                                            ),
                                            Expanded(
                                              child: Text(
                                                st.subtask ?? '',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isChecked
                                                      ? Colors.grey
                                                      : Colors.black87,
                                                  decoration: isChecked
                                                      ? TextDecoration
                                                            .lineThrough
                                                      : null,
                                                ),
                                              ),
                                            ),
                                            // Status badge
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isChecked
                                                    ? const Color(0xFFE8F5E9)
                                                    : const Color(0xFFFFF3E0),
                                                borderRadius:
                                                    BorderRadius.circular(4),
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
                                                                  12,
                                                                ),
                                                          ),
                                                          title: const Text(
                                                            'Delete Subtask',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          content: Text(
                                                            'Delete "${st.subtask}"?',
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 12,
                                                                ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Get.back(),
                                                              child: const Text(
                                                                'Cancel',
                                                                style:
                                                                    TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () async {
                                                                Get.back(); // Close dialog first
                                                                final success =
                                                                    await controller
                                                                        .deleteSubtask(
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
                                                              child: const Text(
                                                                'Delete',
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .red,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                              child: const Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!isLast)
                                        const Divider(
                                          height: 1,
                                          color: Color(0xFFEEEEEE),
                                        ),
                                    ],
                                  );
                                });
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '✓ Check a subtask to mark it as completed (esubtask)',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
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
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: _buildBottomActions(controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormGrid(
    BuildContext context,
    TicketDetailsController controller,
  ) {
    return Obx(
      () => Table(
        columnWidths: const {
          0: FlexColumnWidth(1.4),
          1: FlexColumnWidth(1.5),
          2: FixedColumnWidth(8),
          3: FlexColumnWidth(1.4),
          4: FlexColumnWidth(1.5),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          _tableRow(
            leftLabel: "Status",
            leftChild: _buildDropdown<String>(
              controller.selectedStatus.value,
              controller.statusOptions,
              (v) {
                controller.selectedStatus.value = v;
                if (v != null && v != '2' && v != '3') {
                  _selectFollowUpDateTime(context, controller);
                }
              },
              (item) => controller.getStatusLabel(item),
            ),
            rightLabel: "Created By",
            rightChild: _readOnlyBox(
              controller.ticketDetail.value?.userName ?? "N/A",
            ),
          ),
          _tableRow(
            leftLabel: "Priority",
            leftChild: _buildDropdown<String>(
              controller.selectedPriority.value,
              controller.priorityOptions,
              (v) => controller.selectedPriority.value = v,
              (item) => controller.getPriorityLabel(item),
            ),
            rightLabel: "Created",
            rightChild: _readOnlyBox(
              controller.ticketDetail.value?.createdOn ?? "N/A",
            ),
          ),
          _tableRow(
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
            rightLabel: "Modified",
            rightChild: _readOnlyBox(
              controller.ticketDetail.value?.modifiedOn ?? "N/A",
            ),
          ),
          _tableRow(
            leftLabel: "S-Category",
            leftChild: _buildDropdown<SupportSubCategory>(
              controller.selectedSubCategory.value,
              controller.subCategories,
              (v) => controller.selectedSubCategory.value = v,
              (item) => item.subCategoryName,
            ),
            rightLabel: "Resolved",
            rightChild: _readOnlyBox(
              controller.ticketDetail.value?.resolvedOn ?? "-",
            ),
          ),
          _tableRow(
            leftLabel: "Assignee",
            leftChild: _buildDropdown<AssigneeModel>(
              controller.selectedAssignee.value,
              controller.assignees,
              (v) => controller.selectedAssignee.value = v,
              (item) => item.name,
            ),
            rightLabel: "Follow Up",
            rightChild: _buildFollowUpField(context, controller),
          ),
          _tableRow(
            leftLabel: "Units",
            leftChild: _buildDropdown<SupportUnit>(
              controller.selectedUnit.value,
              controller.units,
              (v) => controller.selectedUnit.value = v,
              (item) => item.unitName,
            ),
            rightLabel: "Reminder",
            rightChild: _buildReminderField(context, controller),
          ),
          _tableRow(
            leftLabel: "Projects",
            leftChild: _buildDropdown<SupportProject>(
              controller.selectedProject.value,
              controller.projects,
              (v) => controller.selectedProject.value = v,
              (item) => item.projectName,
            ),
            rightLabel: "Linked Tkt",
            rightChild: _buildTextField(TextEditingController(text: ""), ""),
          ),
          _tableRow(
            leftLabel: "",
            leftChild: const SizedBox.shrink(),
            rightLabel: "Fw_Contact",
            rightChild: _buildTextField(
              TextEditingController(text: "NA"),
              "NA",
            ),
          ),
        ],
      ),
    );
  }

  TableRow _tableRow({
    required String leftLabel,
    required Widget leftChild,
    required String rightLabel,
    required Widget rightChild,
  }) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            leftLabel,
            style: const TextStyle(
              color: AppColors.primaryOrange,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: leftChild,
        ),
        const SizedBox(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            rightLabel,
            style: const TextStyle(
              color: AppColors.primaryOrange,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: rightChild,
        ),
      ],
    );
  }

  Widget _readOnlyBox(String text, [IconData? icon]) {
    return Container(
      height: 30,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (icon != null) Icon(icon, size: 14, color: Colors.black54),
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
    TicketDetailsController controller,
  ) {
    return InkWell(
      onTap: () => _selectFollowUpDateTime(context, controller),
      child: Container(
        height: 30,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey[300]!),
        ),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: controller.followUpDate.value == null
                        ? Colors.grey
                        : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 12,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderField(
    BuildContext context,
    TicketDetailsController controller,
  ) {
    return InkWell(
      onTap: () {
        _showReminderDialog(context, controller);
      },
      child: Container(
        height: 30,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const FaIcon(
              FontAwesomeIcons.whatsapp,
              size: 18,
              color: Colors.green,
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
              borderRadius: BorderRadius.circular(20),
            ),
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
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Notification Type:",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.green,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Checkbox(
                          value: tempWhatsApp,
                          activeColor: AppColors.primaryOrange,
                          onChanged: (v) =>
                              setModalState(() => tempWhatsApp = v!),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.notifications,
                          color: Colors.black54,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Checkbox(
                          value: tempApp,
                          activeColor: AppColors.primaryOrange,
                          onChanged: (v) => setModalState(() => tempApp = v!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Date & Time:",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryOrange,
                      ),
                    ),
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
                              if (picked != null) {
                                setModalState(() => tempTime = picked);
                              }
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => Get.back(),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xff4CAF50,
                              ), // Green Apply!
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xffF5F5F5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11),
              ),
            ),
            Icon(icon, size: 12, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>(
    T? value,
    List<T> options,
    Function(T?) onChanged,
    String Function(T) labelBuilder,
  ) {
    return MultiSelectDropdownWidget<T>(
      hint: "Select",
      isSingleSelect: true,
      showSearch: true,
      height: 30,
      selectedValues: value != null ? {value} : {},
      selectedTextStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      items: options
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                labelBuilder(item),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (values) {
        onChanged(values.isNotEmpty ? values.first : null);
      },
    );
  }

  InputDecoration _inputDecoration(String hint, {double verticalPadding = 8}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: verticalPadding,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      isDense: true,
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    double verticalPadding = 8,
  }) {
    if (maxLines == 1) {
      return Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: TextField(
          controller: controller,
          maxLines: 1,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          decoration: InputDecoration.collapsed(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      decoration: _inputDecoration(hint, verticalPadding: verticalPadding),
    );
  }

  Widget _buildBottomActions(TicketDetailsController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF78828A),
            minimumSize: const Size(100, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => Get.back(),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        const SizedBox(width: 12),
        Obx(
          () => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF168B50),
              minimumSize: const Size(100, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: controller.isLoading.value
                ? null
                : () => controller.saveTicket(),
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Save",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
          ),
        ),
      ],
    );
  }
}
