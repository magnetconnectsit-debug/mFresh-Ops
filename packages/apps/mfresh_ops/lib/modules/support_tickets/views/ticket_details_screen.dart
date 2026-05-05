import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:mfresh_ops/modules/support_tickets/controllers/ticket_details_controller.dart';
import 'package:mfresh_ops/routes/app_pages.dart';
import 'package:mfresh_ops/routes/app_routes.dart';

class TicketDetailsScreen extends GetView<TicketDetailsController> {
  const TicketDetailsScreen({super.key});

  // Design Theme Colors from legacy
  static const Color primaryOrange = Color(0xFFFF7043);
  static const Color secondaryOrange = Color(0xFFFFF3F0);
  static const Color webBlueBorder = Color(0xFF2196F3);
  static const Color scaffoldBg = Color(0xFFFDFDFD);
  static const Color lightGrey = Color(0xFFEEEEEE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Ticket Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: primaryOrange));
        }

        final ticket = controller.ticketDetail.value;
        if (ticket == null) {
          return const Center(child: Text("No Ticket Found"));
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchTicketDetails(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top action header
                _buildActionHeader(ticket),
                const SizedBox(height: 16),

                // Prominent Ticket ID display
                _buildTicketIdContainer(ticket),
                const SizedBox(height: 16),

                // Ticket Info Card
                _buildTicketInfoCard(ticket),
                const SizedBox(height: 16),

                // Attachments
                if (ticket.attachments != null && ticket.attachments!.isNotEmpty) ...[
                  _buildImageSection("Attachments", ticket.attachments!),
                  const SizedBox(height: 16),
                ],

                // Action Buttons for Status Update
                _buildStatusActionButtons(),
                const SizedBox(height: 16),

                // Comment input area
                _buildCommentInputArea(),
                const SizedBox(height: 24),

                // Comment history
                _buildCommentHistory(ticket.comments ?? []),
                const SizedBox(height: 16),

                // History table
                _buildHistoryTable(ticket.logs ?? []),
              ],
            ),
          ),
        );
      }),
    );
  }

  // --- Action Header ---
  Widget _buildActionHeader(dynamic ticket) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            label: "List",
            icon: Icons.cancel_outlined,
            color: Colors.redAccent,
            onTap: () => Get.back(),
            isSecondary: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            label: "Edit Ticket",
            icon: Icons.edit_note_rounded,
            color: primaryOrange,
            onTap: () => Get.toNamed(AppRoutes.editTicket, arguments: ticket.id),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            label: "WhatsApp",
            icon: FontAwesomeIcons.whatsapp,
            color: Colors.green,
            onTap: () => controller.shareToWhatsApp(),
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isSecondary = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSecondary ? Colors.white : color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
          boxShadow: [
            if (!isSecondary)
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSecondary ? color : Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSecondary ? color : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Ticket ID Container ---
  Widget _buildTicketIdContainer(dynamic ticket) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: primaryOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryOrange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.confirmation_number, color: primaryOrange, size: 20),
          const SizedBox(width: 8),
          const Text(
            "Ticket ID:",
            style: TextStyle(
              color: primaryOrange,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "#${ticket.caseId ?? ticket.id}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Ticket Info Card ---
  Widget _buildTicketInfoCard(dynamic ticket) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: secondaryOrange,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            runSpacing: 10,
            spacing: 0,
            children: [
              _infoTile(
                "Status",
                valueWidget: Align(
                  alignment: Alignment.centerLeft,
                  child: _buildStatusBadge(ticket.status ?? "0"),
                ),
              ),
              _infoTile("Created By", value: ticket.userName ?? "-"),
              _infoTile(
                "Priority",
                valueWidget: Align(
                  alignment: Alignment.centerLeft,
                  child: _buildPriorityBadge(ticket.priorityId ?? "1"),
                ),
              ),
              _infoTile("Created On", value: ticket.createdOn ?? "-"),
              _infoTile("Category", value: ticket.category ?? "-"),
              _infoTile("Modified On", value: ticket.modifiedOn ?? "-"),
              _infoTile("S-Category", value: ticket.subcategory ?? "-"),
              _infoTile("Resolved", value: ticket.resolvedOn ?? "-"),
              _infoTile("Assignee", value: ticket.assignedToName ?? "-"),
              _infoTile("Follow-Up", value: ticket.followUp ?? "-"),
              _infoTile("Unit No", value: ticket.unitNo ?? "-"),
              _infoTile("Ticket Age", value: ticket.tktAge ?? "-"),
              _infoTile("Project", value: ticket.project ?? "-"),
              _infoTile("Reminder", value: ticket.reminder?.reminderDate ?? "-"),
              _infoTile("Linked Tkt", value: "NA"),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.black12, height: 1),
          ),
          _textBlock("Subject", ticket.subject ?? "-"),
          const SizedBox(height: 12),
          _textBlock("Description", ticket.description ?? "-"),
        ],
      ),
    );
  }

  Widget _infoTile(String label, {String? value, Widget? valueWidget}) {
    return SizedBox(
      width: Get.width * 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 11),
          ),
          const SizedBox(height: 2),
          if (valueWidget != null)
            valueWidget
          else
            Text(
              value ?? "-",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _textBlock(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryOrange,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: const TextStyle(height: 1.4, fontSize: 12),
          ),
        ),
      ],
    );
  }

  // --- Badges ---
  Widget _buildStatusBadge(String statusValue) {
    String label = _getStatusLabel(statusValue);
    Color textColor = Colors.black87;
    Color? bgColor;

    switch (statusValue) {
      case "0": textColor = Colors.red; bgColor = Colors.red.withOpacity(0.1); break;
      case "1": textColor = Colors.black; bgColor = Colors.grey.withOpacity(0.2); break;
      case "5": textColor = Colors.black; bgColor = const Color(0x9496F1EF); break;
      case "4": textColor = Colors.black; bgColor = const Color(0x9607B8FF); break;
      case "2": textColor = Colors.black; bgColor = Colors.green.withOpacity(0.2); break;
      case "3": textColor = Colors.black; bgColor = Colors.grey.withOpacity(0.3); break;
      default: textColor = Colors.black; bgColor = Colors.grey.withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: textColor.withOpacity(0.5), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 8),
      ),
    );
  }

  Widget _buildPriorityBadge(String priorityValue) {
    String label = _getPriorityLabel(priorityValue);
    Color textColor = Colors.black;
    Color? bgColor;

    switch (priorityValue) {
      case "1": textColor = Colors.black; bgColor = Colors.grey.shade200; break;
      case "2": textColor = Colors.black; bgColor = const Color(0xFFFFC000); break;
      case "3": textColor = Colors.white; bgColor = const Color(0xFFFF0000); break;
      case "6": textColor = Colors.white; bgColor = const Color(0xFFC00000); break;
      default: textColor = Colors.black; bgColor = Colors.grey.shade200;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: bgColor == Colors.grey.shade200 ? Border.all(color: Colors.grey.shade400) : null,
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 8),
      ),
    );
  }

  String _getStatusLabel(String val) {
    switch (val) {
      case "0": return "New";
      case "1": return "WIP";
      case "2": return "Resolved";
      case "3": return "Closed";
      case "4": return "Hold";
      case "5": return "Awaited";
      default: return "Unknown";
    }
  }

  String _getPriorityLabel(String val) {
    switch (val) {
      case "1": return "Low";
      case "2": return "Medium";
      case "3": return "High";
      case "6": return "Top Priority";
      default: return "Unknown";
    }
  }

  // --- Status Action Buttons ---
  Widget _buildStatusActionButtons() {
    return Row(
      children: [
        Expanded(child: _headerAction("Resolve", Icons.check_circle_outline, () => controller.updateStatus("Resolved"))),
        const SizedBox(width: 8),
        Expanded(child: _headerAction("Awaited", Icons.pause_circle_outline, () => controller.updateStatus("Awaited"))),
        const SizedBox(width: 8),
        Expanded(child: _headerAction("Hold", Icons.stop_circle_outlined, () => controller.updateStatus("Hold"))),
      ],
    );
  }

  Widget _headerAction(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: primaryOrange,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // --- Comment Input ---
  Widget _buildCommentInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: webBlueBorder.withOpacity(0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("Comments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              Obx(() => Row(
                children: [
                  Checkbox(
                    value: controller.isInternal.value,
                    activeColor: primaryOrange,
                    onChanged: (val) => controller.isInternal.value = val!,
                  ),
                  const Text("Mark Internal", style: TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              )),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => controller.addComment(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: primaryOrange, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.commentController,
            maxLines: 2,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              filled: true,
              fillColor: lightGrey.withOpacity(0.3),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              hintText: "Write comment...",
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => controller.pickImages(),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.attachment_rounded, color: primaryOrange, size: 18),
                SizedBox(width: 4),
                Text("Upload Images", style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          Obx(() => controller.selectedImages.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Wrap(
                  spacing: 8,
                  children: controller.selectedImages.map((file) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(file.path), width: 60, height: 60, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: -4,
                        right: -4,
                        child: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                          onPressed: () => controller.selectedImages.remove(file),
                        ),
                      )
                    ],
                  )).toList(),
                ),
              )
            : const SizedBox.shrink()),
        ],
      ),
    );
  }

  // --- Comment History ---
  Widget _buildCommentHistory(List comments) {
    if (comments.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Comment History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        ...comments.map((c) => _buildCommentItem(c)),
      ],
    );
  }

  Widget _buildCommentItem(dynamic c) {
    final bool isInternal = c['is_internal'] == "1";
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 10),
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isInternal ? const Color(0xFFFFF9C4) : Colors.white,
              border: Border.all(color: isInternal ? Colors.orange : webBlueBorder, width: 1.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(c['user_name'] ?? "Unknown", style: const TextStyle(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 13)),
                    if (isInternal) _buildInternalBadge(),
                  ],
                ),
                const SizedBox(height: 6),
                Text(c['comment'] ?? "", style: const TextStyle(fontSize: 12, height: 1.3)),
                const SizedBox(height: 12),
                Text("Updated On : ${c['created_at']}", style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 12,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isInternal ? Colors.orange : const Color(0xFF4CAF50),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInternalBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
      child: const Text("INTERNAL", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }

  // --- History Table ---
  Widget _buildHistoryTable(List logs) {
    if (logs.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Activity Log", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        _historyHeaderTable(),
        const Divider(height: 1, color: Colors.black12),
        ...logs.map((log) => Column(
          children: [
            _historyRowTable(log),
            const Divider(height: 1, color: Colors.black12),
          ],
        )),
      ],
    );
  }

  Widget _historyHeaderTable() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text("Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54))),
          Expanded(flex: 3, child: Text("User", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54))),
          Expanded(flex: 4, child: Text("Action", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54))),
        ],
      ),
    );
  }

  Widget _historyRowTable(dynamic log) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(log['created_at'] ?? "-", style: const TextStyle(fontSize: 11))),
          Expanded(flex: 3, child: Text(log['user_name'] ?? "-", style: const TextStyle(fontSize: 11))),
          Expanded(flex: 4, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Changed ${log['action']}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              Text("From ${log['old_value']} to ${log['new_value']}", style: const TextStyle(fontSize: 10, color: Colors.black54)),
            ],
          )),
        ],
      ),
    );
  }

  // --- Image Section ---
  Widget _buildImageSection(String title, List<String> images) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: secondaryOrange, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: primaryOrange, fontSize: 12)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: images.map((img) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(img, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: Colors.white, child: const Icon(Icons.broken_image, color: Colors.grey))),
            )).toList(),
          )
        ],
      ),
    );
  }
}
