import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/ticket_details_controller.dart';
import 'package:mfresh_ops/data/models/models.dart';

class EditTicketScreen extends StatelessWidget {
  const EditTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TicketDetailsController>();

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppCommonAppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Obx(() => Text(
          "Update Ticket #${controller.ticketDetail.value?.caseId ?? controller.ticketDetail.value?.ticketId ?? ''}",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        )),
        hasBackButton: true,
      ),
      body: SafeArea(
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
                      const Text("Update Ticket",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close, color: Colors.black54, size: 20),
                      )
                    ],
                  ),
                  SizedBox(height: 12.h),

                  _buildFormGrid(context, controller),
                  SizedBox(height: 12.h),

                  const Text("Subject",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  SizedBox(height: 4.h),
                  _buildTextField(controller.subjectController, "Subject Line", maxLines: 2),

                  SizedBox(height: 12.h),

                  const Text("Description",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  SizedBox(height: 4.h),
                  _buildTextField(controller.descriptionController, "Description here", maxLines: 4),

                  SizedBox(height: 20.h),

                  _buildBottomActions(controller),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormGrid(BuildContext context, TicketDetailsController controller) {
    return Obx(() => Column(
      children: [
        /// Row 1: Status & Created By
        _twoFieldRow(
          leftLabel: "Status",
          leftChild: _buildDropdown<String>(
            controller.selectedStatus.value,
            controller.statusOptions,
            (v) => controller.selectedStatus.value = v,
            (item) => item,
          ),
          rightLabel: "Created By",
          rightChild: _readOnlyBox(controller.ticketDetail.value?.userName ?? "N/A", Icons.person_outline),
        ),
        SizedBox(height: 5.h),

        /// Row 2: Priority & Created Date
        _twoFieldRow(
          leftLabel: "Priority",
          leftChild: _buildDropdown<String>(
            controller.selectedPriority.value,
            controller.priorityOptions,
            (v) => controller.selectedPriority.value = v,
            (item) => item,
          ),
          rightLabel: "Created Date",
          rightChild: _readOnlyBox(controller.ticketDetail.value?.createdAt ?? "N/A", Icons.calendar_today),
        ),
        SizedBox(height: 5.h),

        /// Row 3: Category & Modified Date
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
          rightLabel: "Modified Date",
          rightChild: _readOnlyBox(controller.ticketDetail.value?.updatedAt ?? "N/A", Icons.edit_calendar),
        ),
        SizedBox(height: 5.h),

        /// Row 4: Sub Category & Resolved Date
        _twoFieldRow(
          leftLabel: "Sub Category",
          leftChild: _buildDropdown<SupportSubCategory>(
            controller.selectedSubCategory.value,
            controller.subCategories,
            (v) => controller.selectedSubCategory.value = v,
            (item) => item.subCategoryName,
          ),
          rightLabel: "Resolved Date",
          rightChild: _readOnlyBox(controller.ticketDetail.value?.resolvedOn ?? "N/A", Icons.check_circle_outline),
        ),
        SizedBox(height: 5.h),

        /// Row 5: Assigned To & Follow Up Date
        _twoFieldRow(
          leftLabel: "Assigned To",
          leftChild: _buildDropdown<AssigneeModel>(
            controller.selectedAssignee.value,
            controller.assignees,
            (v) => controller.selectedAssignee.value = v,
            (item) => item.name,
          ),
          rightLabel: "Follow Up Date",
          rightChild: _buildDatePickerField(context, controller),
        ),
        SizedBox(height: 5.h),

        /// Row 6: Unit & Reminder
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
        SizedBox(height: 5.h),

        /// Row 7: Project & Linked Ticket
        _twoFieldRow(
          leftLabel: "Project",
          leftChild: _buildDropdown<SupportProject>(
            controller.selectedProject.value,
            controller.projects,
            (v) => controller.selectedProject.value = v,
            (item) => item.projectName,
          ),
          rightLabel: "Linked Ticket",
          rightChild: _buildTextField(TextEditingController(text: "NA"), "Enter Ticket #"),
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
              Text(leftLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
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
              Text(rightLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              SizedBox(height: 4.h),
              SizedBox(width: double.infinity, child: rightChild),
            ],
          ),
        ),
      ],
    );
  }

  Widget _readOnlyBox(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xffF5F5F5),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87), overflow: TextOverflow.ellipsis)),
          Icon(icon, size: 16, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context, TicketDetailsController controller) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: controller.followUpDate.value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          if (!context.mounted) return;
          final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
          if (time != null) {
              controller.followUpDate.value = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
           }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xffF5F5F5),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() => Text(
              controller.followUpDate.value != null 
                ? DateFormat("dd/MM/yyyy HH:mm").format(controller.followUpDate.value!) 
                : "Follow Up Date & Time",
              style: const TextStyle(fontSize: 12),
            )),
            const Icon(Icons.calendar_today_outlined, size: 16),
          ],
        ),
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
          borderRadius: BorderRadius.circular(10.r),
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
            const Icon(Icons.calendar_today_outlined, size: 16),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
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
                        child: Text("Reminder/ Notifications",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  const Text("Notification Type:",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Icon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 20),
                      Checkbox(
                        value: tempWhatsApp,
                        activeColor: const Color(0xffF15A24),
                        onChanged: (v) => setModalState(() => tempWhatsApp = v!),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.notifications_active, color: Colors.black, size: 20),
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
                  SizedBox(height: 30.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade400,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          onPressed: () => Get.back(),
                          child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff4CAF50),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
                          child: const Text("Apply", style: TextStyle(color: Colors.white)),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
            Icon(icon, size: 14, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>(T? value, List<T> options, Function(T?) onChanged, String Function(T) labelBuilder) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      icon: const SizedBox.shrink(),
      decoration: _inputDecoration("Select"),
      items: options.map((e) => DropdownMenuItem(value: e, child: Text(labelBuilder(e), style: const TextStyle(fontSize: 12)))).toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12),
      filled: true,
      fillColor: const Color(0xffF5F5F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide.none,
      ),
      isDense: true,
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 12),
      decoration: _inputDecoration(hint),
    );
  }

  Widget _buildBottomActions(TicketDetailsController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Get.back(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r), side: BorderSide(color: Colors.grey.shade300)),
          ),
          child: const Text("Cancel", style: TextStyle(color: Colors.black, fontSize: 14)),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () => controller.saveTicket(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffF15A24),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
          child: const Text("Update", style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}
