import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/support_tickets_controller.dart';
import 'package:mfresh_ops/data/models/support/support_ticket_model.dart';

// Column definitions: [label, width, isLast]
const List<(String, double)> _kColumns = [
  ('', 32),        // 0 Checkbox
  ('Ticket', 60),
  ('Unit No.', 80),
  ('Subject', 140),
  ('Project', 110),
  ('Category', 110),
  ('Sub-Category', 115),
  ('Status', 80),
  ('Priority', 90),
  ('Assignee', 100),
  ('Latest Comment', 160),
  ('Follow-up-on', 110),
  ('Tkt Age', 70),
  ('Date/Time Open', 130),
  ('Date/Time Close', 130),
  ('District', 90),
  ('Created By', 100),  // 16 last col
];

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

      // Touch these so Obx re-renders on change
      controller.selectedTickets.length;
      controller.expandedSubjectTickets.length;

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: Get.width - 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────
                _buildHeaderRow(controller),
                // ── Data rows ───────────────────────────────────────────
                ...controller.filteredTickets.map(
                  (ticket) => _buildDataRow(controller, ticket),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ── Header row ──────────────────────────────────────────────────────────
  Widget _buildHeaderRow(SupportTicketsController controller) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFC5D5F0),
        border: Border(
          left: BorderSide(color: Colors.transparent, width: 2.0),
          right: BorderSide(color: Colors.transparent, width: 2.0),
        ),
      ),
      child: Row(
        children: [
          // Checkbox column header
          SizedBox(
            width: _kColumns[0].$2,
            height: 28,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Transform.scale(
                scale: 0.85,
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: Checkbox(
                    value: controller.filteredTickets.isNotEmpty &&
                        controller.filteredTickets.every(
                          (t) => controller.selectedTickets.contains(t.id),
                        ),
                    onChanged: controller.selectAllTickets,
                    activeColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    side: const BorderSide(color: AppColors.white, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
          // Text header cells
          for (int i = 1; i < _kColumns.length; i++)
            SizedBox(
              width: _kColumns[i].$2,
              height: 28,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  border: Border(
                    right: i < _kColumns.length - 1
                        ? BorderSide(color: Colors.grey.shade300)
                        : BorderSide.none,
                  ),
                ),
                child: Text(
                  _kColumns[i].$1,
                  style: AppTextStyle.style_12_700(color: AppColors.grey900),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Data row ─────────────────────────────────────────────────────────────
  Widget _buildDataRow(
    SupportTicketsController controller,
    SupportTicketListItem ticket,
  ) {
    final isSelected = controller.selectedTickets.contains(ticket.id);
    final isExpanded = controller.expandedSubjectTickets.contains(ticket.id);
    final isTopPriority = ticket.priorityLabel?.toLowerCase() == 'top priority';

    void toggleRow() => controller.toggleSubjectExpansion(ticket.id);

    final rowBorderColor = isTopPriority ? Colors.red : Colors.grey.shade300;
    final rowBorderWidth = isTopPriority ? 2.0 : 1.0;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.blue.withValues(alpha: 0.1)
            : AppColors.white,
        border: Border(
          top: isTopPriority
              ? BorderSide(color: rowBorderColor, width: rowBorderWidth)
              : BorderSide.none,
          bottom: BorderSide(color: rowBorderColor, width: rowBorderWidth),
          left: BorderSide(
            color: isTopPriority ? Colors.red : Colors.transparent,
            width: 2.0,
          ),
          right: BorderSide(
            color: isTopPriority ? Colors.red : Colors.transparent,
            width: 2.0,
          ),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 0 Checkbox — selection only
            _buildCheckboxCell(controller, ticket, isSelected, isTopPriority),

            // 1 Ticket ID — navigates, no expand
            _buildCell(
              width: _kColumns[1].$2,
              isLast: false,
              isTopPriority: isTopPriority,
              isExpanded: isExpanded,
              onTap: null,
              child: InkWell(
                onTap: () => Get.toNamed(
                  AppRoutes.ticketDetails,
                  arguments: ticket.id,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    '${ticket.caseId}',
                    style: AppTextStyle.style_12_700(color: Colors.blue),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ),

            // 2 Unit No.
            _buildTextCell(
              width: _kColumns[2].$2, text: ticket.unitNo ?? '',
              isLast: false, isLeft: true,
              isTopPriority: isTopPriority,
              isExpanded: isExpanded, onTap: toggleRow,
            ),
            // 3 Subject
            _buildTextCell(
              width: _kColumns[3].$2, text: ticket.subject ?? '',
              isLast: false, isLeft: true,
              isTopPriority: isTopPriority,
              isExpanded: isExpanded, onTap: toggleRow,
            ),
            // 4 Project
            _buildTextCell(
              width: _kColumns[4].$2, text: ticket.project ?? '',
              isLast: false, isLeft: true,
              isTopPriority: isTopPriority,
              isExpanded: isExpanded, onTap: toggleRow,
            ),
            // 5 Category
            _buildTextCell(
              width: _kColumns[5].$2, text: ticket.mCategory ?? '',
              isLast: false, isLeft: true,
              isTopPriority: isTopPriority,
              isExpanded: isExpanded, onTap: toggleRow,
            ),
            // 6 Sub-Category
            _buildTextCell(
              width: _kColumns[6].$2, text: ticket.subCat ?? '',
              isLast: false, isLeft: true,
              isTopPriority: isTopPriority,
              isExpanded: isExpanded, onTap: toggleRow,
            ),

            // 7 Status
            _buildStatusCell(ticket, isTopPriority, isExpanded, toggleRow),

            // 8 Priority
            _buildPriorityCell(ticket, isTopPriority, isExpanded, toggleRow),

            // 9 Assignee
            _buildTextCell(
              width: _kColumns[9].$2,
              text: controller.getAssigneeName(ticket.assignedTo),
              isLast: false, isLeft: true,
              isTopPriority: isTopPriority,
              isExpanded: isExpanded, onTap: toggleRow,
            ),
            // 10 Latest Comment
            _buildTextCell(
              width: _kColumns[10].$2, text: ticket.latestComment ?? '',
              isLast: false, isLeft: true,
              isTopPriority: isTopPriority,
              isExpanded: isExpanded, onTap: toggleRow,
            ),
            // 11 Follow-up
            _buildTextCell(
              width: _kColumns[11].$2,
              text: _formatDateTime(ticket.followUp),
              isLast: false,
              isTopPriority: isTopPriority,
              isExpanded: isExpanded, onTap: toggleRow,
              bgColor: (ticket.followUp != null &&
                      ticket.followUp!.isNotEmpty &&
                      ticket.followUp != '-')
                  ? const Color(0xFFFFF9C4)
                  : null,
            ),
            // 12 Tkt Age
            _buildTextCell(
              width: _kColumns[12].$2,
              text: _calculateTicketAge(ticket.postedDate, ticket.resolvedOn),
              isLast: false,
              isTopPriority: isTopPriority,
              isExpanded: isExpanded, onTap: toggleRow,
            ),
            // 13 Date/Time Open
            _buildTextCell(
              width: _kColumns[13].$2,
              text: _formatDateTime(ticket.postedDate),
              isLast: false,
              isTopPriority: isTopPriority,
              isExpanded: isExpanded, onTap: toggleRow,
            ),
            // 14 Date/Time Close
            _buildTextCell(
              width: _kColumns[14].$2,
              text: _formatDateTime(ticket.resolvedOn),
              isLast: false,
              isTopPriority: isTopPriority,
              isExpanded: isExpanded, onTap: toggleRow,
            ),
            // 15 District
            _buildTextCell(
              width: _kColumns[15].$2, text: ticket.district ?? '',
              isLast: false, isLeft: true,
              isTopPriority: isTopPriority,
              isExpanded: isExpanded, onTap: toggleRow,
            ),
            // 16 Created By (last col — no right border)
            _buildTextCell(
              width: _kColumns[16].$2, text: ticket.createdBy ?? '',
              isLast: true, isLeft: true,
              isTopPriority: isTopPriority,
              isExpanded: isExpanded, onTap: toggleRow,
            ),
          ],
        ),
      ),
    );
  }

  // ── Cell builders ─────────────────────────────────────────────────────────

  Widget _buildCheckboxCell(
    SupportTicketsController controller,
    SupportTicketListItem ticket,
    bool isSelected,
    bool isTopPriority,
  ) {
    return SizedBox(
      width: _kColumns[0].$2,
      child: InkWell(
        onTap: () => controller.toggleTicketSelection(ticket.id),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.grey.shade300),
            ),
          ),
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
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextCell({
    required double width,
    required String text,
    required bool isLast,
    required bool isTopPriority,
    required bool isExpanded,
    required VoidCallback onTap,
    bool isLeft = false,
    Color? bgColor,
  }) {
    return _buildCell(
      width: width,
      isLast: isLast,
      isTopPriority: isTopPriority,
      isExpanded: isExpanded,
      onTap: onTap,
      bgColor: bgColor,
      child: Align(
        alignment: isLeft ? Alignment.centerLeft : Alignment.center,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: isExpanded ? 6.h : 4.h,
          ),
          child: Text(
            text,
            style: AppTextStyle.style_12_400(color: AppColors.grey900),
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            maxLines: isExpanded ? null : 1,
          ),
        ),
      ),
    );
  }

  Widget _buildCell({
    required double width,
    required bool isLast,
    required bool isTopPriority,
    required bool isExpanded,
    VoidCallback? onTap,
    Widget? child,
    Color? bgColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: width,
        constraints: const BoxConstraints(minHeight: 28),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            right: isLast
                ? BorderSide.none
                : BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildStatusCell(
    SupportTicketListItem ticket,
    bool isTopPriority,
    bool isExpanded,
    VoidCallback onTap,
  ) {
    final bgColor = _parseColor(ticket.statusBgColor, fallback: Colors.white);
    final textColor = _parseColor(ticket.statusTextColor, fallback: Colors.black);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: _kColumns[7].$2,
        constraints: const BoxConstraints(minHeight: 28),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            right: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          ticket.statusLabel ?? '',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityCell(
    SupportTicketListItem ticket,
    bool isTopPriority,
    bool isExpanded,
    VoidCallback onTap,
  ) {
    final bgColor = _parseColor(ticket.priorityBgColor, fallback: Colors.white);
    final textColor = _parseColor(ticket.priorityTextColor, fallback: Colors.black);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: _kColumns[8].$2,
        constraints: const BoxConstraints(minHeight: 28),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            right: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          ticket.priorityLabel ?? '',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ── Skeleton ──────────────────────────────────────────────────────────────
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

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _formatDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty || dateString == '-') {
      return dateString ?? '-';
    }
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
      final closeDate =
          (closeDateStr != null && closeDateStr.isNotEmpty && closeDateStr != '-')
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

  /// Parses a color string from the API (hex or named color).
  Color _parseColor(String? colorStr, {Color fallback = Colors.white}) {
    if (colorStr == null || colorStr.isEmpty) return fallback;
    final s = colorStr.trim().toLowerCase();
    switch (s) {
      case 'white':  return Colors.white;
      case 'black':  return Colors.black;
      case 'red':    return Colors.red;
      case 'green':  return Colors.green;
      case 'blue':   return Colors.blue;
      case 'yellow': return Colors.yellow;
      case 'orange': return Colors.orange;
      default:
        try {
          final hex = s.replaceFirst('#', '');
          if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
          if (hex.length == 8) return Color(int.parse(hex, radix: 16));
        } catch (_) {}
        return fallback;
    }
  }
}
