import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/support_tickets_controller.dart';

class SupportTicketsTable extends StatelessWidget {
  final SupportTicketsController controller;

  const SupportTicketsTable({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return _buildTicketsTable(controller);
  }

  Widget _buildTicketsTable(SupportTicketsController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.tickets.isEmpty) {
        return _buildSkeletonTable();
      }

      if (controller.filteredTickets.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Text(
              'No tickets found',
              style: AppTextStyle.style_14_400(color: AppColors.grey400),
            ),
          ),
        );
      }

      final Map<int, TableColumnWidth> columnWidths = {
        for (int i = 0; i <= 16; i++) i: const IntrinsicColumnWidth(),
      };

      // Ensure Obx watches for selection and expansion changes
      controller.selectedTickets.length;
      controller.expandedSubjectTickets.length;

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: Get.width - 40),
            child: Table(
              columnWidths: columnWidths,
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                // Header Row
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFC5D5F0)),
                  children: [
                    TableCell(
                      child: Container(
                        height: 28,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.grey.shade300),
                            left: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Transform.scale(
                          scale: 0.85,
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: Checkbox(
                              value:
                                  controller.filteredTickets.isNotEmpty &&
                                  controller.filteredTickets.every(
                                    (t) => controller.selectedTickets.contains(
                                      t.id,
                                    ),
                                  ),
                              onChanged: (val) =>
                                  controller.selectAllTickets(val),
                              activeColor: AppColors.primary,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              side: const BorderSide(
                                color: AppColors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: _buildHeaderCell("Ticket", hasRight: true),
                    ),
                    TableCell(
                      child: _buildHeaderCell("Unit No.", hasRight: true),
                    ),
                    TableCell(
                      child: _buildHeaderCell("Subject", hasRight: true),
                    ),
                    TableCell(
                      child: _buildHeaderCell("Project", hasRight: true),
                    ),
                    TableCell(
                      child: _buildHeaderCell("Category", hasRight: true),
                    ),
                    TableCell(
                      child: _buildHeaderCell("Sub-Category", hasRight: true),
                    ),
                    TableCell(
                      child: _buildHeaderCell("Status", hasRight: true),
                    ),
                    TableCell(
                      child: _buildHeaderCell("Priority", hasRight: true),
                    ),
                    TableCell(
                      child: _buildHeaderCell("Assignee", hasRight: true),
                    ),
                    TableCell(
                      child: _buildHeaderCell("Comment", hasRight: true),
                    ),
                    TableCell(
                      child: _buildHeaderCell("Follow-up-on", hasRight: true),
                    ),
                    TableCell(
                      child: _buildHeaderCell("Tkt Age", hasRight: true),
                    ),
                    TableCell(
                      child: _buildHeaderCell("Date/Time Open", hasRight: true),
                    ),
                    TableCell(
                      child: _buildHeaderCell(
                        "Date/Time Close",
                        hasRight: true,
                      ),
                    ),
                    TableCell(
                      child: _buildHeaderCell("District", hasRight: true),
                    ),
                    TableCell(
                      child: _buildHeaderCell("Created By", hasRight: true),
                    ),
                  ],
                ),
                // Data Rows
                ...controller.filteredTickets.map((ticket) {
                  final isSelected = controller.selectedTickets.contains(
                    ticket.id,
                  );

                  return TableRow(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.blue.withValues(alpha: 0.1)
                          : AppColors.white,
                    ),
                    children: [
                      TableCell(
                        child: InkWell(
                          onTap: () =>
                              controller.toggleTicketSelection(ticket.id),
                          child: Container(
                            height: 28,
                            decoration: BoxDecoration(
                              border: _cellBorder(0, ticket.priorityLabel),
                            ),
                            alignment: Alignment.center,
                            child: IgnorePointer(
                              child: Transform.scale(
                                scale: 0.85,
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Checkbox(
                                    value: isSelected,
                                    onChanged: (val) {},
                                    activeColor: AppColors.primary,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      _buildDataCell(
                        child: InkWell(
                          onTap: () => Get.toNamed(
                            AppRoutes.ticketDetails,
                            arguments: ticket.id,
                          ),
                          child: Text(
                            "${ticket.caseId}",
                            style: AppTextStyle.style_12_700(
                              color: Colors.blue,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        priority: ticket.priorityLabel,
                        isCenter: true,
                        index: 1,
                      ),
                      _buildDataCell(
                        text: ticket.unitNo ?? '',
                        priority: ticket.priorityLabel,
                        isLeft: true,
                        index: 2,
                      ),
                      _buildDataCell(
                        text: ticket.subject ?? '',
                        priority: ticket.priorityLabel,
                        isLeft: true,
                        index: 3,
                      ),
                      _buildDataCell(
                        text: ticket.project ?? '',
                        priority: ticket.priorityLabel,
                        isLeft: true,
                        index: 4,
                      ),
                      _buildDataCell(
                        text: ticket.mCategory ?? '',
                        priority: ticket.priorityLabel,
                        isLeft: true,
                        index: 5,
                      ),
                      _buildDataCell(
                        text: ticket.subCat ?? '',
                        priority: ticket.priorityLabel,
                        isLeft: true,
                        index: 6,
                      ),
                      TableCell(
                        child: Container(
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: _cellBorder(7, ticket.priorityLabel),
                          ),
                          child: _statusBlock(ticket.statusLabel ?? ''),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: _cellBorder(8, ticket.priorityLabel),
                          ),
                          child: _priorityBlock(ticket.priorityLabel ?? ''),
                        ),
                      ),
                      _buildDataCell(
                        text: controller.getAssigneeName(ticket.assignedTo),
                        priority: ticket.priorityLabel,
                        isLeft: true,
                        index: 9,
                      ),
                      _buildDataCell(
                        text: ticket.comment ?? '',
                        priority: ticket.priorityLabel,
                        isLeft: true,
                        index: 10,
                      ),
                      _buildDataCell(
                        text: _formatDateTime(ticket.followUp),
                        priority: ticket.priorityLabel,
                        isCenter: true,
                        index: 11,
                        bgColor: (ticket.followUp != null && ticket.followUp!.isNotEmpty && ticket.followUp != '-') 
                            ? const Color(0xFFFFF9C4) // Light yellow
                            : null,
                      ),
                      _buildDataCell(
                        text: _calculateTicketAge(ticket.postedDate, ticket.resolvedOn),
                        priority: ticket.priorityLabel,
                        isCenter: true,
                        index: 12,
                      ),
                      _buildDataCell(
                        text: _formatDateTime(ticket.postedDate),
                        priority: ticket.priorityLabel,
                        isCenter: true,
                        index: 13,
                      ),
                      _buildDataCell(
                        text: _formatDateTime(ticket.resolvedOn),
                        priority: ticket.priorityLabel,
                        isCenter: true,
                        index: 14,
                      ),
                      _buildDataCell(
                        text: ticket.district ?? '',
                        priority: ticket.priorityLabel,
                        isLeft: true,
                        index: 15,
                      ),
                      _buildDataCell(
                        text: ticket.createdBy ?? '',
                        priority: ticket.priorityLabel,
                        isLeft: true,
                        index: 16,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeaderCell(String title, {bool hasRight = false}) {
    return Container(
      alignment: Alignment.center,
      height: 28,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        border: Border(
          right: hasRight
              ? BorderSide(color: Colors.grey.shade300)
              : BorderSide.none,
        ),
      ),
      child: Text(
        title,
        style: AppTextStyle.style_12_700(color: AppColors.grey900),
      ),
    );
  }

  Widget _buildDataCell({
    String? text,
    Widget? child,
    bool isLeft = false,
    bool isCenter = false,
    String? priority,
    required int index,
    Color? bgColor,
  }) {
    return TableCell(
      child: Container(
        height: 28,
        alignment: isLeft
            ? Alignment.centerLeft
            : (isCenter ? Alignment.center : Alignment.center),
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: bgColor,
          border: _cellBorder(index, priority),
        ),
        child:
            child ??
            Text(
              text ?? '',
              style: AppTextStyle.style_12_400(color: AppColors.grey900),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
      ),
    );
  }

  Widget _buildSkeletonTable() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 3000.w),
            child: Container(height: 30.h, color: const Color(0xFFC5D5F0)),
          ),
        ),
        Expanded(
          child: Skeletonizer(
            enabled: true,
            child: ListView.builder(
              itemCount: 15,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) => Container(
                height: 30.h,
                margin: EdgeInsets.symmetric(vertical: 1.h),
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty || dateString == '-') return dateString ?? '-';
    try {
      final parsed = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
    } catch (e) {
      return dateString;
    }
  }

  String _calculateTicketAge(String? openDateStr, String? closeDateStr) {
    if (openDateStr == null || openDateStr.isEmpty || openDateStr == '-') return '-';
    try {
      final openDate = DateTime.parse(openDateStr);
      final closeDate = (closeDateStr != null && closeDateStr.isNotEmpty && closeDateStr != '-')
          ? DateTime.parse(closeDateStr)
          : DateTime.now();

      final duration = closeDate.difference(openDate);
      if (duration.inMinutes < 0) return '-';

      final days = duration.inDays;
      final hours = duration.inHours % 24;

      if (days == 0 && hours == 0) return '< 1h';
      if (days == 0) return '${hours}h';
      return '${days}d, ${hours}h';
    } catch (e) {
      return '-';
    }
  }

  BorderSide _rowBorder(String? priority) {
    if (priority?.toLowerCase() == "top priority") {
      return const BorderSide(color: Colors.red, width: 2.0);
    }
    return BorderSide(color: Colors.grey.shade300, width: 1);
  }

  Border _cellBorder(int index, String? priority) {
    final isTopPriority = priority?.toLowerCase() == "top priority";
    return Border(
      top: isTopPriority ? const BorderSide(color: Colors.red, width: 2.0) : BorderSide.none,
      bottom: _rowBorder(priority),
      left: (index == 0 && isTopPriority) ? const BorderSide(color: Colors.red, width: 2.0) : BorderSide.none,
      right: (index == 15 && isTopPriority) 
          ? const BorderSide(color: Colors.red, width: 2.0) 
          : (index != 15 ? BorderSide(color: Colors.grey.shade300) : BorderSide.none),
    );
  }

  Widget _statusBlock(String status) {
    Color bgColor;
    Color textColor = Colors.black;

    switch (status) {
      case "New":
        bgColor = Colors.white;
        textColor = Colors.red;
        break;
      case "WIP":
        bgColor = Colors.white;
        textColor = Colors.black;
        break;
      case "Awaited":
        bgColor = const Color(0x9496F1EF);
        textColor = Colors.black;
        break;
      case "Hold":
        bgColor = const Color(0x9607B8FF);
        textColor = Colors.black;
        break;
      default:
        bgColor = Colors.white;
        textColor = Colors.black;
    }
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      color: bgColor,
      child: Text(status,
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _priorityBlock(String priority) {
    Color bgColor;
    Color textColor = Colors.black;

    switch (priority) {
      case "Low":
        bgColor = Colors.white;
        textColor = Colors.black;
        break;
      case "Normal":
      case "Medium":
        bgColor = const Color(0xFFFFC000);
        textColor = Colors.black;
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
        bgColor = Colors.white;
        textColor = Colors.black;
    }
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      color: bgColor,
      child: Text(priority,
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}
