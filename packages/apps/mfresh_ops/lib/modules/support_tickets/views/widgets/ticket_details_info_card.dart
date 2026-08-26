import 'package:core/constants/app_colors.dart';
import 'package:core/widgets/app_image_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/ticket_details_controller.dart';

import 'ticket_attachment_preview.dart';

class TicketDetailsInfoCard extends StatelessWidget {
  final dynamic ticket;
  final TicketDetailsController controller;

  const TicketDetailsInfoCard({
    super.key,
    required this.ticket,
    required this.controller,
  });

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
      case "Low":
        return "Low";
      case "2":
      case "Medium":
        return "Medium";
      case "3":
      case "High":
        return "High";
      case "6":
      case "Top Priority":
        return "Top Priority";
      default:
        return val.isNotEmpty ? val : "Unknown";
    }
  }

  Widget _statusBlock(String statusVal) {
    String label = _getStatusLabel(statusVal);
    Color bgColor = Colors.transparent;
    Color textColor = Colors.black;

    switch (label) {
      case "New":
        bgColor = const Color(0xFFFFC000);
        textColor = Colors.white;
        break;
      case "WIP":
        bgColor = Colors.white;
        textColor = Colors.black;
        break;
      case "Resolved":
        bgColor = const Color(0xFF00B050);
        textColor = Colors.white;
        break;
      case "Closed":
        bgColor = const Color(0xFFC00000);
        textColor = Colors.white;
        break;
      case "Hold":
        bgColor = const Color(0x9607B8FF);
        textColor = Colors.black;
        break;
      case "Awaited":
        bgColor = const Color(0x9496F1EF);
        textColor = Colors.black;
        break;
      default:
        bgColor = Colors.transparent;
        textColor = Colors.black;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: bgColor == Colors.white
            ? Border.all(color: Colors.grey.shade300)
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _priorityBlock(String priorityVal) {
    String label = _getPriorityLabel(priorityVal);
    Color bgColor = Colors.transparent;
    Color textColor = Colors.black;

    switch (label) {
      case "Low":
        bgColor = Colors.white;
        textColor = Colors.black;
        break;
      case "Normal":
      case "Medium":
        bgColor = const Color(0xFFFF7A45);
        textColor = Colors.white;
        break;
      case "High":
        bgColor = const Color(0xFFFF0000);
        textColor = Colors.white;
        break;
      case "Top Priority":
        bgColor = const Color(0xFFC00000);
        textColor = Colors.white;
        break;
      default:
        bgColor = Colors.transparent;
        textColor = Colors.black;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: bgColor == Colors.white
            ? Border.all(color: Colors.grey.shade300)
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  String _getAssigneeName(dynamic ticket) {
    if (ticket.assignedToName != null && ticket.assignedToName!.isNotEmpty) {
      return ticket.assignedToName!;
    }
    if (ticket.assignedTo == null || ticket.assignedTo!.isEmpty) {
      return "-";
    }

    final matchedAssignee = controller.assignees.firstWhereOrNull(
      (a) => a.id.toString() == ticket.assignedTo,
    );
    if (matchedAssignee != null && matchedAssignee.name.isNotEmpty) {
      return matchedAssignee.name;
    }

    if (ticket.logs != null) {
      for (var log in ticket.logs) {
        if (log['user_id']?.toString() == ticket.assignedTo &&
            log['user_name'] != null &&
            log['user_name'].toString().isNotEmpty) {
          return log['user_name'].toString();
        }
      }
    }

    if (ticket.comments != null) {
      for (var c in ticket.comments) {
        if (c['user_id']?.toString() == ticket.assignedTo) {
          final String? name = c['commented_by'] ?? c['user_name'];
          if (name != null && name.isNotEmpty && name.toLowerCase() != 'user') {
            return name;
          }
        }
      }
    }

    if (ticket.assignedTo == ticket.createdBy?.toString() ||
        ticket.assignedTo == ticket.createdById?.toString()) {
      if (ticket.userName != null && ticket.userName!.isNotEmpty) {
        return ticket.userName!;
      }
    }

    return "-";
  }

  String _getCreatorName(dynamic ticket) {
    if (ticket.userName != null && ticket.userName!.isNotEmpty) {
      return ticket.userName!;
    }

    final String? creatorIdStr =
        ticket.createdBy?.toString() ?? ticket.createdById?.toString();
    if (creatorIdStr == null || creatorIdStr.isEmpty) {
      return "-";
    }

    final matchedAssignee = controller.assignees.firstWhereOrNull(
      (a) => a.id.toString() == creatorIdStr,
    );
    if (matchedAssignee != null && matchedAssignee.name.isNotEmpty) {
      return matchedAssignee.name;
    }

    if (ticket.logs != null) {
      for (var log in ticket.logs) {
        if (log['user_id']?.toString() == creatorIdStr &&
            log['user_name'] != null &&
            log['user_name'].toString().isNotEmpty) {
          return log['user_name'].toString();
        }
      }
    }

    if (ticket.comments != null) {
      for (var c in ticket.comments) {
        if (c['user_id']?.toString() == creatorIdStr) {
          final String? name = c['commented_by'] ?? c['user_name'];
          if (name != null && name.isNotEmpty && name.toLowerCase() != 'user') {
            return name;
          }
        }
      }
    }

    return "-";
  }

  String _getReminderText(dynamic ticket) {
    final rem = ticket.reminder;
    if (rem != null &&
        rem.reminderDate != null &&
        rem.reminderDate.toString().isNotEmpty) {
      String dateStr = rem.reminderDate!;
      try {
        final parsed = DateTime.parse(dateStr);
        dateStr = DateFormat('dd-MMM-yy').format(parsed);
      } catch (e) {
        // use as is
      }

      final timeStr = "${rem.reminderTime ?? ''} ${rem.timeType ?? ''}".trim();

      if (timeStr.isNotEmpty) {
        return "$dateStr | $timeStr";
      }
      return dateStr;
    }
    return "-";
  }

  TableRow _tableRow({
    required String leftLabel,
    String? leftValue,
    Widget? leftWidget,
    required String rightLabel,
    String? rightValue,
    Widget? rightWidget,
  }) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            leftLabel,
            style: const TextStyle(
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child:
              leftWidget ??
              Tooltip(
                message: leftValue ?? "",
                triggerMode: TooltipTriggerMode.tap,
                child: Text(
                  leftValue ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ),
        ),
        const SizedBox(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            rightLabel,
            style: const TextStyle(
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child:
              rightWidget ??
              Tooltip(
                message: rightValue ?? "",
                triggerMode: TooltipTriggerMode.tap,
                child: Text(
                  rightValue ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ),
        ),
      ],
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
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
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
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: child),
      ],
    );
  }

  Widget _buildAttachmentsWidget(BuildContext context, List attachments) {
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
    final List<String> urls = attachments.map((e) => e.toString()).toList();
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: attachments.map((att) {
        final urlStr = att.toString();
        final isVideo =
            urlStr.toLowerCase().endsWith('.mp4') ||
            urlStr.toLowerCase().endsWith('.mov') ||
            urlStr.toLowerCase().endsWith('.avi') ||
            urlStr.toLowerCase().endsWith('.mkv');

        if (isVideo) {
          return InkWell(
            onTap: () {
              TicketAttachmentPreview.show(context, urls, urls.indexOf(urlStr));
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
            ),
          );
        }

        return InkWell(
          onTap: () =>
              TicketAttachmentPreview.show(context, urls, urls.indexOf(urlStr)),
          child: AppImageView(
            imageUrl: urlStr,
            width: 50,
            height: 50,
            borderRadius: 6,
            fit: BoxFit.cover,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF29B6F6), width: 1.5),
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
              0: FlexColumnWidth(1.5),
              1: FlexColumnWidth(1.5),
              2: FixedColumnWidth(12),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(1.5),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              _tableRow(
                leftLabel: "Status",
                leftWidget: Align(
                  alignment: Alignment.centerLeft,
                  child: _statusBlock(ticket.status ?? "0"),
                ),
                rightLabel: "Created By",
                rightValue: _getCreatorName(ticket),
              ),
              _tableRow(
                leftLabel: "Priority",
                leftWidget: Align(
                  alignment: Alignment.centerLeft,
                  child: _priorityBlock(
                    ticket.priorityId ?? ticket.priority ?? "1",
                  ),
                ),
                rightLabel: "Created On",
                rightValue: ticket.createdOn ?? "-",
              ),
              _tableRow(
                leftLabel: "Category",
                leftValue: ticket.category ?? "-",
                rightLabel: "Modified On",
                rightValue: ticket.modifiedOn ?? "-",
              ),
              _tableRow(
                leftLabel: "S-Category",
                leftValue: ticket.subcategory ?? "-",
                rightLabel: "Resolved",
                rightValue: ticket.resolvedOn ?? "-",
              ),
              _tableRow(
                leftLabel: "Assignee",
                leftValue: _getAssigneeName(ticket),
                rightLabel: "Follow-Up",
                rightValue: ticket.followUp ?? "-",
              ),
              _tableRow(
                leftLabel: "Unit No",
                leftValue: ticket.unitNo ?? "-",
                rightLabel: "Ticket Age",
                rightValue: ticket.tktAge ?? "-",
              ),
              _tableRow(
                leftLabel: "Project",
                leftValue: ticket.project ?? "-",
                rightLabel: "Reminder",
                rightValue: _getReminderText(ticket),
              ),
              _tableRow(
                leftLabel: "Linked Tkt",
                leftValue: "NA",
                rightLabel: "FW Contacts",
                rightValue: "NA",
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFEEEEEE), height: 1, thickness: 1),
          ),
          Table(
            columnWidths: const {
              0: FixedColumnWidth(100),
              1: FlexColumnWidth(1.0),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            children: [
              _bottomTableRow("Subject", ticket.subject ?? "-"),
              _bottomTableRow("Description", ticket.description ?? "-"),
              _bottomTableRowWidget(
                "Attachments (Before)",
                _buildAttachmentsWidget(context, [
                  ...?ticket.cashierImages,
                  ...?ticket.attachments,
                ]),
              ),
            ],
          ),
          if ((ticket.subtasks ?? []).isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Color(0xFFEEEEEE), height: 1, thickness: 1),
            ),
            const Text(
              "SUBTASKS",
              style: TextStyle(
                color: AppColors.primaryOrange,
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
                        color: isDone
                            ? const Color(0xFF4CAF50)
                            : Colors.orange.shade100,
                        border: Border.all(
                          color: isDone
                              ? const Color(0xFF4CAF50)
                              : Colors.orange,
                          width: 1.5,
                        ),
                      ),
                      child: isDone
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        st.subtask ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDone ? Colors.grey : Colors.black87,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
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
                          color: isDone
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFE65100),
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
}
