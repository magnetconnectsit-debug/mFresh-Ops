import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_table.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/support_tickets_controller.dart';
import 'package:mfresh_ops/data/models/support/support_ticket_model.dart';

class SupportTicketsTable extends StatelessWidget {
  final SupportTicketsController controller;

  const SupportTicketsTable({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final filteredList = controller.filteredTickets;

      if (controller.isLoading.value && controller.tickets.isEmpty) {
        return _buildSkeletonTable();
      }

      if (filteredList.isEmpty) {
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

      // Touch reactive sets so Obx re-renders on selection or expansion changes
      controller.selectedTickets.length;
      controller.expandedSubjectTickets.length;

      final expandedIndices = <int>{};
      for (int i = 0; i < filteredList.length; i++) {
        if (controller.expandedSubjectTickets.contains(filteredList[i].id)) {
          expandedIndices.add(i);
        }
      }

      final columns = [
        // 0. Checkbox Column
        AppTableColumn<SupportTicketListItem>(
          key: 'checkbox',
          title: '',
          width: 32.w,
          sortable: false,
          headerWidget: Transform.scale(
            scale: 0.85,
            child: SizedBox(
              height: 20,
              width: 20,
              child: Checkbox(
                value:
                    filteredList.isNotEmpty &&
                    filteredList.every(
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
          cellBuilder: (context, ticket, index, isExpanded) {
            final isSelected = controller.selectedTickets.contains(ticket.id);
            return _buildCheckboxCell(controller, ticket, isSelected);
          },
        ),

        // 1. Ticket Case ID Column
        AppTableColumn<SupportTicketListItem>(
          key: 'Ticket',
          title: 'Tkt',
          width: 47.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, ticket, index, isExpanded) {
            return InkWell(
              onTap: () =>
                  Get.toNamed(AppRoutes.ticketDetails, arguments: ticket.id),
              child: Text(
                '${ticket.caseId}',
                style: AppTextStyle.style_12_700(color: AppColors.blue300),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          },
        ),

        // 2. Unit No.
        AppTableColumn<SupportTicketListItem>(
          key: 'Unit No.',
          title: 'Unit No.',
          width: 78.w,
          valueGetter: (ticket) => ticket.unitNo ?? '',
        ),

        // 3. Subject
        AppTableColumn<SupportTicketListItem>(
          key: 'Subject',
          title: 'Subject',
          width: 200.w,
          valueGetter: (ticket) => ticket.subject ?? '',
        ),

        // 4. Project
        AppTableColumn<SupportTicketListItem>(
          key: 'Project',
          title: 'Project',
          width: 75.w,
          valueGetter: (ticket) => ticket.project ?? '',
        ),

        // 5. Category
        AppTableColumn<SupportTicketListItem>(
          key: 'Category',
          title: 'Category',
          width: 90.w,
          valueGetter: (ticket) => ticket.mCategory ?? '',
        ),

        // 6. Sub-Category
        AppTableColumn<SupportTicketListItem>(
          key: 'Sub-Category',
          title: 'Sub-Category',
          width: 120.w,
          valueGetter: (ticket) => ticket.subCat ?? '',
        ),

        // 7. Status
        AppTableColumn<SupportTicketListItem>(
          key: 'Status',
          title: 'Status',
          width: 70.w,
          cellColorGetter: (ticket) => _getStatusBgColor(ticket),
          cellBuilder: (context, ticket, index, isExpanded) {
            final cellBg = _getStatusBgColor(ticket);
            final textColor = _getStatusTextColor(ticket, cellBg);
            return Text(
              ticket.statusLabel ?? '',
              style: AppTextStyle.style_12_700(color: textColor),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            );
          },
        ),

        // 8. Priority
        AppTableColumn<SupportTicketListItem>(
          key: 'Priority',
          title: 'Priority',
          width: 90.w,
          cellColorGetter: (ticket) => _getPriorityBgColor(ticket),
          cellBuilder: (context, ticket, index, isExpanded) {
            final cellBg = _getPriorityBgColor(ticket) ?? AppColors.transparent;
            final textColor = _getPriorityTextColor(ticket, cellBg);
            return Text(
              ticket.priorityLabel ?? '',
              style: AppTextStyle.style_12_700(color: textColor),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            );
          },
        ),

        // 9. Assignee
        AppTableColumn<SupportTicketListItem>(
          key: 'Assignee',
          title: 'Assignee',
          width: 140.w,
          valueGetter: (ticket) =>
              controller.getAssigneeName(ticket.assignedTo),
        ),

        // 10. Latest Comment
        AppTableColumn<SupportTicketListItem>(
          key: 'Latest Comment',
          title: 'Latest Comment',
          width: 160.w,
          valueGetter: (ticket) => ticket.latestComment ?? '',
        ),

        // 11. Follow-up-on
        AppTableColumn<SupportTicketListItem>(
          key: 'Follow-up-on',
          title: 'Follow-up-on',
          width: 115.w,
          alignment: Alignment.center,
          cellColorGetter: (ticket) => _isFollowUpOverdue(ticket.followUp)
              ? const Color(0xFFFFF9C4)
              : null,
          cellBuilder: (context, ticket, index, isExpanded) {
            return Text(
              _formatDateTime(ticket.followUp),
              style: AppTextStyle.style_12_400(color: AppColors.grey900),
              overflow: isExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              maxLines: isExpanded ? null : 1,
            );
          },
        ),

        // 12. Tkt Age
        AppTableColumn<SupportTicketListItem>(
          key: 'Tkt Age',
          title: 'Tkt Age',
          width: 75.w,
          valueGetter: (ticket) => _calculateTicketAge(
            ticket.createdAt ?? ticket.postedDate,
            ticket.resolvedOn,
          ),
        ),

        // 13. Date/Time Open
        AppTableColumn<SupportTicketListItem>(
          key: 'Date/Time Open',
          title: 'Date/Time Open',
          width: 135.w,
          valueGetter: (ticket) =>
              _formatDateTime(ticket.createdAt ?? ticket.postedDate),
        ),

        // 14. Date/Time Resolved
        AppTableColumn<SupportTicketListItem>(
          key: 'Date/Time Resolved',
          title: 'Date/Time Resolved',
          width: 155.w,
          valueGetter: (ticket) => _getDateTimeClose(ticket),
        ),

        // 15. District
        AppTableColumn<SupportTicketListItem>(
          key: 'District',
          title: 'District',
          width: 90.w,
          valueGetter: (ticket) => ticket.district ?? '',
        ),

        // 16. Created By
        AppTableColumn<SupportTicketListItem>(
          key: 'Created By',
          title: 'Created By',
          width: 140.w,
          valueGetter: (ticket) => ticket.createdBy ?? '',
        ),
      ];

      return AppCommonTable<SupportTicketListItem>(
        items: filteredList,
        columns: columns,
        currentSortColumn: controller.sortColumn.value,
        currentSortOrder: controller.sortAscending.value
            ? AppTableSortOrder.ascending
            : AppTableSortOrder.descending,
        onSort: (columnKey, sortOrder) {
          controller.toggleSort(columnKey);
        },
        expandedRowIndices: expandedIndices,
        onRowExpandToggle: (index, isExpanded) {
          if (index >= 0 && index < filteredList.length) {
            controller.toggleSubjectExpansion(filteredList[index].id);
          }
        },
        rowDecorationBuilder: (ticket, index) {
          final isSelected = controller.selectedTickets.contains(ticket.id);
          final isTopPriority =
              ticket.priorityLabel?.toLowerCase() == 'top priority';

          return BoxDecoration(
            color: isSelected
                ? AppColors.blue.withValues(alpha: 0.1)
                : AppColors.white,
            border: isTopPriority
                ? Border.all(color: AppColors.red, width: 2.0)
                : Border(bottom: BorderSide(color: AppColors.borderColor)),
          );
        },
        headingRowColor: const Color(0xFFC5D5F0),
        headingBorderColor: AppColors.borderColor,
        headingTextStyle: AppTextStyle.style_12_700(color: AppColors.grey900),
        borderColor: AppColors.borderColor,
      );
    });
  }

  // Cell builders

  Widget _buildCheckboxCell(
    SupportTicketsController controller,
    SupportTicketListItem ticket,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () => controller.toggleTicketSelection(ticket.id),
      child: Container(
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
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
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

  // Helpers
  static final Map<String, bool> _followUpOverdueCache = {};

  bool _isFollowUpOverdue(String? followUpStr) {
    if (followUpStr == null || followUpStr.isEmpty || followUpStr == '-') {
      return false;
    }
    final cached = _followUpOverdueCache[followUpStr];
    if (cached != null) return cached;

    try {
      final followUpDate = DateTime.parse(followUpStr).toLocal();
      final now = DateTime.now();
      final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
      final result = followUpDate.isBefore(endOfToday);
      _followUpOverdueCache[followUpStr] = result;
      return result;
    } catch (_) {
      _followUpOverdueCache[followUpStr] = false;
      return false;
    }
  }

  static final Map<String, String> _dateFormatterCache = {};
  static final Map<String, Color> _colorCache = {};

  String _formatDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty || dateString == '-') {
      return dateString ?? '-';
    }
    final cached = _dateFormatterCache[dateString];
    if (cached != null) return cached;

    try {
      final parsed = DateTime.parse(dateString);
      final formatted = DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
      _dateFormatterCache[dateString] = formatted;
      return formatted;
    } catch (e) {
      _dateFormatterCache[dateString] = dateString;
      return dateString;
    }
  }

  String _getDateTimeClose(SupportTicketListItem ticket) {
    final status = ticket.resolvedStatus ?? '';
    if (status != '0' && status != '1' && status != '4' && status != '5') {
      return _formatDateTime(ticket.updatedAt);
    } else {
      return '-';
    }
  }

  static final Map<String, String> _ageCache = {};

  String _calculateTicketAge(String? openDateStr, String? closeDateStr) {
    if (openDateStr == null || openDateStr.isEmpty || openDateStr == '-') {
      return '-';
    }
    final key = '${openDateStr}_${closeDateStr ?? ''}';
    final cached = _ageCache[key];
    if (cached != null) return cached;

    try {
      final openDate = DateTime.parse(openDateStr);
      final closeDate =
          (closeDateStr != null &&
              closeDateStr.isNotEmpty &&
              closeDateStr != '-')
          ? DateTime.parse(closeDateStr)
          : DateTime.now();
      final duration = closeDate.difference(openDate);
      String result;
      if (duration.inMinutes < 0) {
        result = '-';
      } else {
        final days = duration.inDays;
        final hours = duration.inHours % 24;
        if (days == 0 && hours == 0) {
          result = '< 1h';
        } else if (days == 0) {
          result = '${hours}h';
        } else {
          result = '${days}d, ${hours}h';
        }
      }
      _ageCache[key] = result;
      return result;
    } catch (e) {
      _ageCache[key] = '-';
      return '-';
    }
  }

  Color? _getStatusBgColor(SupportTicketListItem ticket) {
    final label = ticket.statusLabel?.toLowerCase().trim() ?? '';
    if (label.contains('hold')) {
      return const Color(0xFF4FC3F7);
    } else if (label.contains('await')) {
      return const Color(0xFFB2EBF2);
    }
    final bg = _parseColor(ticket.statusBgColor, fallback: Colors.transparent);
    if (bg != Colors.transparent && bg != Colors.white) {
      if (!label.contains('new') &&
          !label.contains('wip') &&
          !label.contains('open')) {
        return bg;
      }
    }
    return null;
  }

  Color _getStatusTextColor(SupportTicketListItem ticket, Color? cellBg) {
    final label = ticket.statusLabel?.toLowerCase().trim() ?? '';
    if (label.contains('hold') || label.contains('await')) {
      return AppColors.black;
    }
    if (cellBg != null &&
        cellBg != Colors.transparent &&
        cellBg != Colors.white) {
      if (cellBg.computeLuminance() < 0.5) {
        return Colors.white;
      }
      return Colors.black;
    }
    return _parseColor(ticket.statusTextColor, fallback: AppColors.black);
  }

  Color? _getPriorityBgColor(SupportTicketListItem ticket) {
    final label = ticket.priorityLabel?.toLowerCase().trim() ?? '';
    if (label.contains('low')) {
      return null;
    }

    final bg = _parseColor(
      ticket.priorityBgColor,
      fallback: Colors.transparent,
    );
    if (bg != Colors.transparent && bg != Colors.white) {
      if (bg == Colors.blue && label.contains('low')) {
        return null;
      }
      return bg;
    }
    final textCol = _parseColor(
      ticket.priorityTextColor,
      fallback: Colors.transparent,
    );
    if (textCol != Colors.transparent &&
        textCol != Colors.black &&
        textCol != Colors.white) {
      if (textCol == Colors.blue && label.contains('low')) {
        return null;
      }
      return textCol;
    }
    if (label.contains('high') ||
        label.contains('top') ||
        label.contains('urgent')) {
      return Colors.red;
    } else if (label.contains('medium')) {
      return Colors.orange;
    }
    return null;
  }

  Color _getPriorityTextColor(SupportTicketListItem ticket, Color cellBg) {
    if (cellBg == Colors.transparent || cellBg == Colors.white) {
      final label = ticket.priorityLabel?.toLowerCase().trim() ?? '';
      if (label.contains('low')) {
        return AppColors.black;
      }
      return _parseColor(ticket.priorityTextColor, fallback: Colors.black);
    }
    if (cellBg.computeLuminance() < 0.5) {
      return Colors.white;
    }
    return Colors.black;
  }

  Color _parseColor(String? colorStr, {Color fallback = Colors.white}) {
    if (colorStr == null || colorStr.isEmpty) return fallback;
    final cached = _colorCache[colorStr];
    if (cached != null) return cached;

    final s = colorStr.trim().toLowerCase();
    Color result;
    switch (s) {
      case 'white':
        result = Colors.white;
        break;
      case 'black':
        result = Colors.black;
        break;
      case 'red':
        result = Colors.red;
        break;
      case 'green':
        result = Colors.green;
        break;
      case 'blue':
        result = Colors.blue;
        break;
      case 'yellow':
        result = Colors.yellow;
        break;
      case 'orange':
        result = Colors.orange;
        break;
      default:
        try {
          final hex = s.replaceFirst('#', '');
          if (hex.length == 6) {
            result = Color(int.parse('FF$hex', radix: 16));
          } else if (hex.length == 8) {
            result = Color(int.parse(hex, radix: 16));
          } else {
            result = fallback;
          }
        } catch (_) {
          result = fallback;
        }
        break;
    }
    _colorCache[colorStr] = result;
    return result;
  }
}
