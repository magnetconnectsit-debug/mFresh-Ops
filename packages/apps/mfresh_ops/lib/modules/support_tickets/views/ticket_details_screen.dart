import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:mfresh_ops/modules/support_tickets/controllers/ticket_details_controller.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:services/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:core/widgets/app_image_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/core/utils/app_media_compressor.dart';

class TicketDetailsScreen extends GetView<TicketDetailsController> {
  const TicketDetailsScreen({super.key});

  static const Color primaryOrange = Color(0xFFFF7043);
  static const Color secondaryOrange = Color(0xFFFFF3F0);
  static const Color scaffoldBg = Color(0xFFFAFAFA);
  static const Color timelineBlue = Color(0xFF90CAF9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Ticket Details",
          style: TextStyle(
            color: primaryOrange,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: primaryOrange),
          );
        }

        final ticket = controller.ticketDetail.value;
        if (ticket == null) {
          return const Center(child: Text("No Ticket Found"));
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchTicketDetails(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Prominent Ticket ID display with outline Edit Icon next to it
                _buildTicketIdHeader(ticket),
                const SizedBox(height: 12),

                // Ticket Info Card (Blue outline)
                _buildTicketInfoCard(ticket),

                // Timeline structure containing comments and activities
                _buildTimelineFlow(ticket),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  // --- Ticket ID Header ---
  Widget _buildTicketIdHeader(dynamic ticket) {
    return Row(
      children: [
        Text(
          "TICKET ID: ${ticket.caseId ?? ticket.id}",
          style: const TextStyle(
            color: primaryOrange,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => Get.toNamed(AppRoutes.editTicket, arguments: ticket.id),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: primaryOrange, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.edit, color: primaryOrange, size: 12),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => _showAddSubtaskDialog(Get.context!, controller),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: primaryOrange,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_task, color: Colors.white, size: 12),
                SizedBox(width: 4),
                Text(
                  "Add Subtask",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Ticket Info Card ---
  Widget _buildTicketInfoCard(dynamic ticket) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF9), // Soft warm cream card background matching mockup
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF29B6F6), width: 1.5), // Sky blue border in mockup
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Table(
            columnWidths: const {
              0: FixedColumnWidth(66),
              1: FlexColumnWidth(1.0),
              2: FixedColumnWidth(8),
              3: FixedColumnWidth(66),
              4: FlexColumnWidth(1.4),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              _tableRow(
                leftLabel: "Status",
                leftValue: _getStatusLabel(ticket.status ?? "0"),
                rightLabel: "Created By",
                rightValue: ticket.userName ?? "-",
              ),
              _tableRow(
                leftLabel: "Priority",
                leftValue: _getPriorityLabel(ticket.priorityId ?? "1"),
                rightLabel: "Created On",
                rightValue: ticket.createdOn ?? "-",
              ),
              _tableRow(
                leftLabel: "Category",
                leftValue: ticket.category ?? "-",
                rightLabel: "Modified On",
                rightValue: ticket.modifiedOn ?? "-",
                isRightOrange: true,
              ),
              _tableRow(
                leftLabel: "Sub Category",
                leftValue: ticket.subcategory ?? "-",
                rightLabel: "Resolved",
                rightValue: ticket.resolvedOn ?? "-",
              ),
              _tableRow(
                leftLabel: "Assignee",
                leftValue: ticket.assignedToName ?? "-",
                isLeftOrange: true,
                rightLabel: "Follow-up",
                rightValue: ticket.followUp ?? "-",
              ),
              _tableRow(
                leftLabel: "Unit",
                leftValue: ticket.unitNo ?? "-",
                rightLabel: "Ticket Age",
                rightValue: ticket.tktAge ?? "-",
              ),
              _tableRow(
                leftLabel: "Project",
                leftValue: ticket.project ?? "-",
                rightLabel: "Reminder",
                rightWidget: _reminderWidget(),
              ),
              _tableRow(
                leftLabel: "",
                leftValue: "",
                rightLabel: "Link Ticket",
                rightWidget: _linkTicketWidget(),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFEEEEEE), height: 1, thickness: 1),
          ),
          Table(
            columnWidths: const {
              0: FixedColumnWidth(74),
              1: FlexColumnWidth(1.0),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            children: [
              _bottomTableRow("Subject", ticket.subject ?? "-"),
              _bottomTableRow("Description", ticket.description ?? "-"),
              _bottomTableRowWidget(
                "Attachments",
                _buildAttachmentsWidget([
                  ...?ticket.cashierImages,
                  ...?ticket.attachments,
                ]),
              ),
              _bottomTableRowWidget("Interest Party", _buildInterestPartyWidget()),
            ],
          ),
          // ─── Subtasks Section ───────────────────────────────────────────
          if ((ticket.subtasks ?? []).isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Color(0xFFEEEEEE), height: 1, thickness: 1),
            ),
            const Text(
              "SUBTASKS",
              style: TextStyle(
                color: primaryOrange,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            ...(ticket.subtasks ?? []).map((st) {
              final bool isDone = st.subtaskStatus == '1';
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? const Color(0xFF4CAF50) : Colors.orange.shade100,
                        border: Border.all(
                          color: isDone ? const Color(0xFF4CAF50) : Colors.orange,
                          width: 1.5,
                        ),
                      ),
                      child: isDone
                          ? const Icon(Icons.check, color: Colors.white, size: 12)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        st.subtask ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDone ? Colors.grey : Colors.black87,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDone
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isDone ? 'Done' : 'Pending',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDone ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  TableRow _tableRow({
    required String leftLabel,
    required String leftValue,
    bool isLeftOrange = false,
    required String rightLabel,
    String? rightValue,
    Widget? rightWidget,
    bool isRightOrange = false,
  }) {
    return TableRow(
      children: [
        // Col 0: Left Label
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            leftLabel,
            style: const TextStyle(
              color: primaryOrange,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        // Col 1: Left Value
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            leftValue,
            style: TextStyle(
              color: isLeftOrange ? primaryOrange : Colors.black87,
              fontWeight: isLeftOrange ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        // Col 2: Spacer
        const SizedBox(),
        // Col 3: Right Label
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            rightLabel,
            style: const TextStyle(
              color: primaryOrange,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        // Col 4: Right Value or Widget
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: rightWidget ??
              Text(
                rightValue ?? "",
                style: TextStyle(
                  color: isRightOrange ? primaryOrange : Colors.black87,
                  fontWeight: isRightOrange ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
        ),
      ],
    );
  }

  Widget _reminderWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.calendar_today, size: 10, color: Colors.black54),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.access_time, size: 10, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _linkTicketWidget() {
    return Container(
      height: 14,
      width: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  TableRow _bottomTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            label,
            style: const TextStyle(
              color: primaryOrange,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  TableRow _bottomTableRowWidget(String label, Widget child) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            label,
            style: const TextStyle(
              color: primaryOrange,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: child,
        ),
      ],
    );
  }

  Widget _buildAttachmentsWidget(List attachments) {
    if (attachments.isEmpty) {
      return const Text(
        "No Attachments",
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: attachments.map((att) {
        final filename = att.toString().split('/').last;
        return InkWell(
          onTap: () => _showImagePreview(Get.context!, att.toString()),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.attachment_rounded, size: 10, color: primaryOrange),
                const SizedBox(width: 4),
                Text(
                  filename,
                  style: const TextStyle(
                    color: primaryOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInterestPartyWidget() {
    return Container(
      height: 24,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.centerLeft,
      child: const Text(
        "Email",
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
    );
  }

  String _getStatusLabel(String val) {
    switch (val) {
      case "0":
        return "New";
      case "1":
        return "WIP";
      case "2":
        return "Resolved";
      case "3":
        return "Closed";
      case "4":
        return "Hold";
      case "5":
        return "Awaited";
      default:
        return "Unknown";
    }
  }

  String _getPriorityLabel(String val) {
    switch (val) {
      case "1":
        return "Low";
      case "2":
        return "Medium";
      case "3":
        return "High";
      case "6":
        return "Top Priority";
      default:
        return "Unknown";
    }
  }

  Widget _buildTimelineFlow(dynamic ticket) {
    final comments = ticket.comments ?? [];
    final logs = ticket.logs ?? [];
    final bool hasHistory = logs.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Spacing & Comments header with vertical timeline segment
        Stack(
          children: [
            Positioned(
              left: 9,
              top: 0,
              bottom: 0,
              child: Container(
                width: 1.5,
                color: Colors.black87,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 32, top: 12, bottom: 8),
              child: Text(
                "Comments",
                style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),

        // Green Dot with Comments Input Area
        _timelineRow(
          dotColor: const Color(0xFF4CAF50), // Green dot
          child: _buildCommentInputArea(),
          isLast: comments.isEmpty && !hasHistory,
        ),

        // Red Dots with Comment Items
        ...comments.asMap().entries.map((entry) {
          final int idx = entry.key;
          final dynamic c = entry.value;
          final int commentId = c['id'] ?? 0;
          final bool isLast = (idx == comments.length - 1) && !hasHistory;

          return _timelineRow(
            dotColor: Colors.red,
            child: Obx(
              () => controller.editingCommentIds.contains(commentId)
                  ? _buildCommentEditForm(controller, c)
                  : _buildCommentItem(controller, c),
            ),
            isLast: isLast,
          );
        }),

        // History section header & table
        if (hasHistory) ...[
          Stack(
            children: [
              Positioned(
                left: 9,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 1.5,
                  color: Colors.black87,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 32, top: 16, bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "History",
                      style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _historyHeaderTable(),
                  ],
                ),
              ),
            ],
          ),
          _timelineRow(
            dotColor: Colors.red,
            child: _buildHistoryTable(logs),
            isLast: true,
          ),
        ],
      ],
    );
  }

  Widget _timelineRow({
    required Color dotColor,
    required Widget child,
    bool isLast = false,
  }) {
    return Stack(
      children: [
        // Vertical line segment for this row (stops at dot center if isLast)
        Positioned(
          left: 9,
          top: 0,
          bottom: isLast ? null : 0,
          height: isLast ? 24 : null, // stops exactly at y = 24 (center of dot)
          child: Container(
            width: 1.5,
            color: Colors.black87,
          ),
        ),
        // Timeline dot
        Positioned(
          left: 0,
          top: 14,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        // Child Content card padded from the left dot, with bottom margin inside stack
        Padding(
          padding: const EdgeInsets.only(left: 32, bottom: 16),
          child: child,
        ),
      ],
    );
  }

  // --- Add Subtask Dialog ---
  void _showAddSubtaskDialog(BuildContext context, TicketDetailsController controller) {
    final List<TextEditingController> controllers = [TextEditingController()];

    Get.dialog(
      StatefulBuilder(builder: (ctx, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Create Subtasks',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.close, size: 20, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Input rows (cream background) ─────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF8F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 260),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(controllers.length, (i) {
                          final isLast = i == controllers.length - 1;
                          return Padding(
                            padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
                            child: Row(
                              children: [
                                // Text field
                                Expanded(
                                  child: Container(
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFE0E0E0)),
                                    ),
                                    child: TextField(
                                      controller: controllers[i],
                                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                                      decoration: const InputDecoration(
                                        hintText: 'Enter subtask name',
                                        hintStyle: TextStyle(fontSize: 13, color: Color(0xFFBDBDBD)),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Delete icon — visible when more than 1 row
                                if (controllers.length > 1) ...[
                                  GestureDetector(
                                    onTap: () {
                                      final removed = controllers[i];
                                      setState(() {
                                        controllers.removeAt(i);
                                      });
                                      Future.delayed(const Duration(milliseconds: 300), () => removed.dispose());
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFEBEE),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.close, color: Colors.red, size: 18),
                                    ),
                                  ),
                                  if (isLast) const SizedBox(width: 8),
                                ],

                                // Green "+" button — only on the last row
                                if (isLast)
                                  GestureDetector(
                                    onTap: () {
                                      if (controllers[i].text.trim().isEmpty) {
                                        AppCommonToastMessage.show(
                                          message: 'Please enter subtask',
                                          type: ToastType.error,
                                        );
                                        return;
                                      }
                                      setState(() {
                                        controllers.add(TextEditingController());
                                      });
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF34A853),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.add, color: Colors.white, size: 22),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Save button (blue, right-aligned) ─────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: Obx(() => SizedBox(
                    width: 120,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: controller.isSubtaskLoading.value
                          ? null
                          : () async {
                              final all = controllers
                                  .map((c) => c.text.trim())
                                  .where((t) => t.isNotEmpty)
                                  .toList();
                              if (all.isEmpty) {
                                AppCommonToastMessage.show(
                                  message: 'Please add at least one subtask',
                                  type: ToastType.error,
                                );
                                return;
                              }
                              final success = await controller.createSubtasks(all);
                              if (success) {
                                Get.back();
                                AppCommonToastMessage.show(
                                  message: 'Subtasks saved successfully',
                                  type: ToastType.success,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2979FF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.zero,
                      ),
                      child: controller.isSubtaskLoading.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  )),
                ),
              ],
            ),
          ),
        );
      }),
      barrierDismissible: false,
    ).then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        for (final c in controllers) {
          c.dispose();
        }
      });
    });
  }

  // --- Comment Input Card ---
  void _showCommentMediaSourceOptions(BuildContext context, TicketDetailsController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Get.back();
                controller.captureImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose Photo from Gallery'),
              onTap: () {
                Get.back();
                controller.pickImages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Record a Video'),
              onTap: () {
                Get.back();
                controller.recordVideo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Choose Video from Gallery'),
              onTap: () {
                Get.back();
                controller.pickVideo();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF9), // Soft warm cream card background matching mockup
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF29B6F6), width: 1.5), // Sky blue border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "COMMENTS",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: primaryOrange,
                ),
              ),
              const Spacer(),
              Obx(
                () => GestureDetector(
                  onTap: () => controller.isInternal.toggle(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        controller.isInternal.value
                            ? Icons.check_box_outlined
                            : Icons.crop_square_outlined,
                        color: primaryOrange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "Mark Internal",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: primaryOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.commentController,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Write your comment...",
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFEEEEEE),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: primaryOrange, width: 1),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.link, color: Colors.blue, size: 20),
                          onPressed: () => _showCommentMediaSourceOptions(Get.context!, controller),
                        ),
                        const SizedBox(width: 8),
                        Obx(() => controller.isLoading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: primaryOrange),
                              )
                            : IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.send, color: primaryOrange, size: 20),
                                onPressed: () => controller.addComment(),
                              )),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _showCommentMediaSourceOptions(Get.context!, controller),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3F0),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryOrange.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.attachment, color: primaryOrange, size: 14),
                  const SizedBox(width: 6),
                  const Text(
                    "Upload Files",
                    style: TextStyle(
                      color: primaryOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(
            () => (controller.selectedImages.isNotEmpty || controller.selectedVideos.isNotEmpty)
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...controller.selectedImages.map(
                          (file) => Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(file.path),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: -4,
                                right: -4,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  onPressed: () =>
                                      controller.selectedImages.remove(file),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...controller.selectedVideos.map(
                          (file) => Stack(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange),
                                ),
                                child: const Center(
                                  child: Icon(Icons.videocam, color: Colors.orange, size: 24),
                                ),
                              ),
                              Positioned(
                                top: -4,
                                right: -4,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  onPressed: () =>
                                      controller.selectedVideos.remove(file),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // --- Comment Activity Item Card ---
  Widget _buildCommentItem(TicketDetailsController controller, dynamic c) {
    final int commentId = c['id'] ?? 0;
    final List images = c['ticket_images'] ?? [];
    final storage = Get.find<StorageService>();
    final user = storage.getUser();
    final bool isOwner = c['user_id']?.toString() == user?.id?.toString();

    final activityText = c['action'] ?? "${c['user_name'] ?? 'User'} updated";
    final bool hasBookmark = activityText.toLowerCase().contains("accepted");

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 12, right: 12, top: 16, bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF9), // Soft warm cream card background matching mockup
            border: Border.all(
              color: const Color(0xFF29B6F6), // Sky blue border
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 90,
                          child: Text(
                            "ACTIVITY",
                            style: TextStyle(
                              color: primaryOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            activityText,
                            style: const TextStyle(
                              color: primaryOrange, // Orange action text to match mockup
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isOwner)
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.edit, size: 16, color: Colors.grey),
                      onPressed: () => controller.toggleEditComment(commentId),
                    ),
                ],
              ),
              
              // Comment section if present
              if (c['comment'] != null && c['comment'].toString().trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 90,
                      child: Text(
                        "COMMENTS",
                        style: TextStyle(
                          color: primaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildCommentText(c['comment'].toString()),
                    ),
                  ],
                ),
              ],

              // Attachments section if present
              if (images.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 90,
                      child: Text(
                        "ATTACHMENTS",
                        style: TextStyle(
                          color: primaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: images
                            .map(
                              (img) {
                                final urlStr = img.toString();
                                final isVideo = urlStr.toLowerCase().endsWith('.mp4') ||
                                                urlStr.toLowerCase().endsWith('.mov') ||
                                                urlStr.toLowerCase().endsWith('.avi') ||
                                                urlStr.toLowerCase().endsWith('.mkv');
                                if (isVideo) {
                                  return InkWell(
                                    onTap: () {
                                      launchUrl(Uri.parse(urlStr), mode: LaunchMode.externalApplication);
                                    },
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.orange, width: 1),
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.play_circle_fill, color: Colors.orange, size: 24),
                                      ),
                                    ),
                                  );
                                }
                                return InkWell(
                                  onTap: () =>
                                      _showImagePreview(Get.context!, urlStr),
                                  child: AppImageView(
                                    imageUrl: urlStr,
                                    width: 50,
                                    height: 50,
                                    borderRadius: 6,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "Updated On: ${c['created_at'] != null ? DateFormat('dd-MM-yy, HH:mm').format(DateTime.parse(c['created_at'])) : ''}",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasBookmark)
          const Positioned(
            left: 12,
            top: 0,
            child: Icon(Icons.bookmark, color: Color(0xFF29B6F6), size: 18),
          ),
      ],
    );
  }

  Widget _buildCommentText(String text) {
    if (!text.contains('@')) {
      return Text(text, style: const TextStyle(fontSize: 12, height: 1.3));
    }
    
    final List<TextSpan> spans = [];
    final words = text.split(' ');
    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      if (word.startsWith('@')) {
        spans.add(
          TextSpan(
            text: '$word ',
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: '$word ',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
            ),
          ),
        );
      }
    }
    return RichText(
      text: TextSpan(
        children: spans,
        style: const TextStyle(height: 1.3),
      ),
    );
  }

  Widget _buildCommentEditForm(TicketDetailsController controller, dynamic c) {
    final int commentId = c['id'] ?? 0;
    final String initialComment = c['comment'] ?? '';
    final List initialImages = c['ticket_images'] ?? [];
    final bool initialInternal = c['is_internal'] == "1";

    return StatefulBuilder(
builder: (context, setState) {
        final TextEditingController editController = TextEditingController(
          text: initialComment,
        );
        List<File> newImages = [];
        List<File> newVideos = [];
        List<String> existingImages = List<String>.from(
          initialImages.map((e) => e.toString()),
        );
        bool isInternal = initialInternal;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF9),
            border: Border.all(color: const Color(0xFF29B6F6), width: 1.5),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Edit Comment',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Spacer(),
                  Checkbox(
                    value: isInternal,
                    onChanged: (val) => setState(() => isInternal = val!),
                  ),
                  const Text('Internal', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 12),
                  Obx(() => controller.isLoading.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: primaryOrange),
                        )
                      : InkWell(
                          onTap: () => controller.editComment(
                            commentId: commentId,
                            comment: editController.text,
                            newImages: newImages,
                            newVideos: newVideos,
                            internal: isInternal,
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: primaryOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        )),
                  const SizedBox(width: 12),
                  Obx(() => InkWell(
                    onTap: controller.isLoading.value
                        ? null
                        : () => controller.toggleEditComment(commentId),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: editController,
                maxLines: 3,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Enter comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
              const SizedBox(height: 12),
              if (existingImages.isNotEmpty) ...[
                const Text(
                  'Current Images:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: existingImages
                      .map(
                        (url) => Stack(
                          children: [
                             AppImageView(
                               imageUrl: url,
                               width: 50,
                               height: 50,
                               borderRadius: 8,
                               fit: BoxFit.cover,
                             ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                onPressed: () =>
                                    setState(() => existingImages.remove(url)),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],
              if (newImages.isNotEmpty) ...[
                const Text(
                  'New Images:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: newImages
                      .map(
                        (file) => Stack(
                          children: [
                             ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                file,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                onPressed: () =>
                                    setState(() => newImages.remove(file)),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],
              if (newVideos.isNotEmpty) ...[
                const Text(
                  'New Videos:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: newVideos
                      .map(
                        (file) => Stack(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange),
                              ),
                              child: const Center(
                                child: Icon(Icons.videocam, color: Colors.orange, size: 24),
                              ),
                            ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                onPressed: () =>
                                    setState(() => newVideos.remove(file)),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],
              InkWell(
                onTap: () async {
                  Get.bottomSheet(
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('Take a Photo'),
                            onTap: () async {
                              Get.back();
                              final picked = await ImagePicker().pickImage(source: ImageSource.camera);
                              if (picked != null) {
                                setState(() => newImages.add(File(picked.path)));
                              }
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('Choose Photo from Gallery'),
                            onTap: () async {
                              Get.back();
                              final picked = await ImagePicker().pickMultiImage();
                              setState(() => newImages.addAll(picked.map((e) => File(e.path))));
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.videocam),
                            title: const Text('Record a Video'),
                            onTap: () async {
                              Get.back();
                              final picked = await ImagePicker().pickVideo(source: ImageSource.camera);
                              if (picked != null) {
                                AppCommonToastMessage.show(message: 'Compressing video...', type: ToastType.info);
                                final compressed = await AppMediaCompressor.compressVideo(File(picked.path));
                                setState(() => newVideos.add(compressed));
                                AppCommonToastMessage.show(message: 'Video compressed successfully', type: ToastType.success);
                              }
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.video_library),
                            title: const Text('Choose Video from Gallery'),
                            onTap: () async {
                              Get.back();
                              final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
                              if (picked != null) {
                                AppCommonToastMessage.show(message: 'Compressing video...', type: ToastType.info);
                                final compressed = await AppMediaCompressor.compressVideo(File(picked.path));
                                setState(() => newVideos.add(compressed));
                                AppCommonToastMessage.show(message: 'Video compressed successfully', type: ToastType.success);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.attachment_rounded,
                      color: primaryOrange,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Attach Files",
                      style: TextStyle(
                        color: primaryOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- History Table Card ---
  Widget _buildHistoryTable(List logs) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF9), // Soft warm cream card background matching mockup
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF29B6F6), width: 1.5), // Sky blue border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: logs.map(
          (log) {
            final int idx = logs.indexOf(log);
            return Column(
              children: [
                _historyRowTable(log),
                if (idx != logs.length - 1)
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
              ],
            );
          },
        ).toList(),
      ),
    );
  }


  Widget _historyHeaderTable() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "Date",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              "User",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              "Action",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyRowTable(dynamic log) {
    String dateStr = log['created_at'] ?? "-";
    String datePart = "-";
    String timePart = "-";
    try {
      final dt = DateTime.parse(dateStr);
      datePart = DateFormat("dd-MM-yy").format(dt);
      timePart = DateFormat("HH:mm").format(dt);
    } catch (_) {
      datePart = dateStr;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  datePart,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: primaryOrange,
                  ),
                ),
                Text(
                  timePart,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: primaryOrange,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              log['user_name'] ?? "-",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: primaryOrange,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: _buildActionSpanText(log),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSpanText(dynamic log) {
    final String action = log['action'] ?? '';
    final String field = log['field'] ?? '';
    final String oldVal = log['old_value'] ?? '';
    final String newVal = log['new_value'] ?? '';

    // Match mockup styling where properties/fields are bolded
    if (action.toLowerCase() == 'create' || action.toLowerCase() == 'created') {
      return const Text(
        "Created.",
        style: TextStyle(fontSize: 11, color: Colors.black87),
      );
    }

    // Capitalize field name
    String fieldName = field;
    if (field == 'subcat_id') fieldName = 'Sub Category';
    if (field == 'mcat_id') fieldName = 'Category';
    if (field == 'assigned_to') fieldName = 'Assignee';
    if (field == 'priority') fieldName = 'Priority';
    if (field == 'status') fieldName = 'Status';
    if (field == 'projectid') fieldName = 'Project';

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 11, color: Colors.black87, height: 1.2),
        children: [
          const TextSpan(text: "Change "),
          TextSpan(
            text: fieldName,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          if (oldVal.isNotEmpty) ...[
            const TextSpan(text: " from "),
            TextSpan(
              text: oldVal,
              style: const TextStyle(color: Colors.black87),
            ),
          ],
          const TextSpan(text: " to "),
          TextSpan(
            text: newVal,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const TextSpan(text: "."),
        ],
      ),
    );
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: AppImageView(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                borderRadius: 12,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
