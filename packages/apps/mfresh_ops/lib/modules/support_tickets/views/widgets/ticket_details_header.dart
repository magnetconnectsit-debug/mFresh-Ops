import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/constants/app_colors.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/ticket_details_controller.dart';

class TicketDetailsHeader extends StatelessWidget {
  final dynamic ticket;
  final TicketDetailsController controller;

  const TicketDetailsHeader({
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

  Future<void> _shareToWhatsApp(dynamic ticket) async {
    final text =
        "Ticket ID: ${ticket.caseId ?? ticket.id}\n"
        "Status: ${_getStatusLabel(ticket.status ?? "0")}\n"
        "Priority: ${_getPriorityLabel(ticket.priorityId ?? ticket.priority ?? "1")}\n"
        "Subject: ${ticket.subject ?? "-"}\n"
        "Description: ${ticket.description ?? "-"}";

    final Uri whatsappUri = Uri.parse(
      "whatsapp://send?text=${Uri.encodeComponent(text)}",
    );

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        AppCommonToastMessage.show(
          message: 'WhatsApp is not installed on the device',
          type: ToastType.error,
        );
      }
    } catch (e) {
      debugPrint("WhatsApp Error: $e");
      AppCommonToastMessage.show(
        message: 'Could not open WhatsApp',
        type: ToastType.error,
      );
    }
  }

  void _showAddSubtaskDialog(
    BuildContext context,
    TicketDetailsController controller,
  ) {
    final List<TextEditingController> controllers = [TextEditingController()];

    Get.dialog(
      StatefulBuilder(
        builder: (ctx, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 40,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
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
                                  Expanded(
                                    child: Container(
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: const Color(0xFFE0E0E0),
                                        ),
                                      ),
                                      child: TextField(
                                        controller: controllers[i],
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: 'Enter subtask name',
                                          hintStyle: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFFBDBDBD),
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (controllers.length > 1) ...[
                                    GestureDetector(
                                      onTap: () {
                                        final removed = controllers[i];
                                        setState(() {
                                          controllers.removeAt(i);
                                        });
                                        Future.delayed(
                                          const Duration(milliseconds: 300),
                                          () => removed.dispose(),
                                        );
                                      },
                                      child: Container(
                                        width: 40,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFEBEE),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    if (isLast) const SizedBox(width: 8),
                                  ],
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
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 22,
                                        ),
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: Obx(
                      () => SizedBox(
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: controller.isSubtaskLoading.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      barrierDismissible: false,
    ).then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        for (final c in controllers) {
          c.dispose();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            "TICKET ID: ${ticket.caseId ?? ticket.id}",
            style: const TextStyle(
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        InkWell(
          onTap: () => Get.toNamed(AppRoutes.editTicket, arguments: ticket.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryOrange, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              "Edit Ticket",
              style: TextStyle(
                color: AppColors.primaryOrange,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        InkWell(
          onTap: () => _shareToWhatsApp(ticket),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF25D366),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 10),
                SizedBox(width: 4),
                Text(
                  "WhatsApp",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        InkWell(
          onTap: () => _showAddSubtaskDialog(context, controller),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_task, color: Colors.white, size: 10),
                SizedBox(width: 2),
                Text(
                  "Subtask",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
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
}
