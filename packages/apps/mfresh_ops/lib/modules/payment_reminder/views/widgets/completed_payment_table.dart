import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/data/models/payment_reminder/payment_reminder_model.dart';
import 'package:mfresh_ops/modules/payment_reminder/controllers/completed_payment_controller.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/all_tasks_table_elements.dart';

class CompletedPaymentTable extends StatefulWidget {
  final CompletedPaymentController controller;

  const CompletedPaymentTable({super.key, required this.controller});

  @override
  State<CompletedPaymentTable> createState() => _CompletedPaymentTableState();
}

class _CompletedPaymentTableState extends State<CompletedPaymentTable> {
  final RxSet<String> _expandedRows = <String>{}.obs;

  void _toggleRow(String key) {
    if (_expandedRows.contains(key)) {
      _expandedRows.remove(key);
    } else {
      _expandedRows.add(key);
    }
  }

  static const _kColumns = [
    'SI No',
    'For',
    'To',
    'Assignee',
    'Expense Head',
    'Sub-Head',
    'Cost Center',
    'Due Date',
    'Reminder End Date',
    'Notification Date',
    'Time',
    'Completed At',
    'Status',
  ];

  String _formatStatusText(String? status) {
    if (status == null || status.isEmpty) return 'Completed';
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  String _formatDate(String? rawDateStr) {
    if (rawDateStr == null || rawDateStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(rawDateStr);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final day = dt.day.toString().padLeft(2, '0');
      final month = months[dt.month - 1];
      final year = (dt.year % 100).toString().padLeft(2, '0');
      return '$day-$month-$year';
    } catch (e) {
      return rawDateStr;
    }
  }

  String _formatTime(String? rawTimeStr) {
    if (rawTimeStr == null || rawTimeStr.isEmpty) return '-';
    try {
      final parts = rawTimeStr.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        final period = hour >= 12 ? 'PM' : 'AM';
        hour = hour % 12;
        if (hour == 0) hour = 12;
        final mStr = minute.toString().padLeft(2, '0');
        return '$hour:$mStr $period';
      }
      return rawTimeStr;
    } catch (e) {
      return rawTimeStr;
    }
  }

  String _formatCompletedAt(String? rawStr) {
    if (rawStr == null || rawStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(rawStr);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final day = dt.day.toString().padLeft(2, '0');
      final month = months[dt.month - 1];
      final year = (dt.year % 100).toString().padLeft(2, '0');

      int hour = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final ampm = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      final hStr = hour.toString().padLeft(2, '0');

      return '$day-$month-$year $hStr:$minute $ampm';
    } catch (e) {
      return rawStr;
    }
  }

  Widget _buildStatusCell(String? status, bool isExpanded, VoidCallback onTap) {
    final formattedText = _formatStatusText(status);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F4EA),
            border: Border.all(color: const Color(0xFF34A853), width: 1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            formattedText,
            style: AppTextStyle.style_10_600(color: const Color(0xFF1E7E34)),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(() {
          final reminders = widget.controller.displayedPayments;

          if (reminders.isEmpty && !widget.controller.isLoading.value) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Text(
                  'No completed payments found',
                  style: AppTextStyle.style_14_500(color: AppColors.grey300),
                ),
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    border: TableBorder.symmetric(
                      inside: BorderSide(color: Colors.grey.shade300),
                    ),
                    columnWidths: {
                      0: FixedColumnWidth(42.w), // SI No
                      1: FixedColumnWidth(85.w), // For
                      2: FixedColumnWidth(75.w), // To
                      3: FixedColumnWidth(110.w), // Assignee
                      4: FixedColumnWidth(115.w), // Expense Head
                      5: FixedColumnWidth(80.w), // Sub-Head
                      6: FixedColumnWidth(90.w), // Cost Center
                      7: FixedColumnWidth(80.w), // Due Date
                      8: FixedColumnWidth(125.w), // Reminder End Date
                      9: FixedColumnWidth(110.w), // Notification Date
                      10: FixedColumnWidth(80.w), // Time
                      11: FixedColumnWidth(135.w), // Completed At
                      12: FixedColumnWidth(85.w), // Status
                    },
                    children: [
                      // Header row
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color(0xFFC5D5F0),
                        ),
                        children: [
                          for (final col in _kColumns)
                            AllTasksHeaderCell(
                              text: col,
                              onTap: () => widget.controller.toggleSort(col),
                              isSorted:
                                  widget.controller.sortColumn.value == col,
                              sortAscending:
                                  widget.controller.sortAscending.value,
                            ),
                        ],
                      ),
                      // Data rows
                      ...reminders.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final rowKey =
                            "${item.id}_${item.recurrenceId ?? index}";
                        final isExpanded = _expandedRows.contains(rowKey);
                        void toggleRow() => _toggleRow(rowKey);

                        final assigneeDisplay =
                            item.assigneeName != null &&
                                item.assigneeName!.isNotEmpty
                            ? item.assigneeName!
                            : widget.controller.getAssigneeName(
                                item.assigneeId,
                              );

                        return TableRow(
                          children: [
                            AllTasksDataCell(
                              text:
                                  '${(widget.controller.currentPage.value - 1) * widget.controller.perPage.value + index + 1}',
                              isExpanded: isExpanded,
                              onTap: toggleRow,
                            ),
                            AllTasksDataCell(
                              text: item.forDesc ?? '-',
                              isExpanded: isExpanded,
                              onTap: toggleRow,
                            ),
                            AllTasksDataCell(
                              text: item.to ?? '-',
                              isExpanded: isExpanded,
                              onTap: toggleRow,
                            ),
                            AllTasksDataCell(
                              text: assigneeDisplay,
                              isExpanded: isExpanded,
                              onTap: toggleRow,
                            ),
                            AllTasksDataCell(
                              text: item.expenseHead ?? '-',
                              isExpanded: isExpanded,
                              onTap: toggleRow,
                            ),
                            AllTasksDataCell(
                              text: item.subHead ?? '-',
                              isExpanded: isExpanded,
                              onTap: toggleRow,
                            ),
                            AllTasksDataCell(
                              text: item.costCenter ?? '-',
                              isExpanded: isExpanded,
                              onTap: toggleRow,
                            ),
                            AllTasksDataCell(
                              text: _formatDate(item.dueDate),
                              isExpanded: isExpanded,
                              onTap: toggleRow,
                            ),
                            AllTasksDataCell(
                              text: _formatDate(item.endDate),
                              isExpanded: isExpanded,
                              onTap: toggleRow,
                            ),
                            AllTasksDataCell(
                              text: _formatDate(item.notificationDate),
                              isExpanded: isExpanded,
                              onTap: toggleRow,
                            ),
                            AllTasksDataCell(
                              text: _formatTime(item.notificationTime),
                              isExpanded: isExpanded,
                              onTap: toggleRow,
                            ),
                            AllTasksDataCell(
                              text: _formatCompletedAt(item.completedAt),
                              isExpanded: isExpanded,
                              onTap: toggleRow,
                            ),
                            _buildStatusCell(
                              item.status,
                              isExpanded,
                              toggleRow,
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
