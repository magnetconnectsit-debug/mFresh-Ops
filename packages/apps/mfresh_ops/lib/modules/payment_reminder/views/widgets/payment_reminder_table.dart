import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/data/models/payment_reminder/payment_reminder_model.dart';
import 'package:mfresh_ops/modules/payment_reminder/controllers/payment_reminder_controller.dart';
import 'package:mfresh_ops/modules/payment_reminder/views/create_payment_reminder_screen.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/all_tasks_table_elements.dart';

class PaymentReminderTable extends StatefulWidget {
  final PaymentReminderController controller;

  const PaymentReminderTable({super.key, required this.controller});

  @override
  State<PaymentReminderTable> createState() => _PaymentReminderTableState();
}

class _PaymentReminderTableState extends State<PaymentReminderTable> {
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
    'Customer ID',
    'Assignee',
    'Expense Head',
    'Cost Center',
    'Due Date',
    'Reminder End Date',
    'Notification Date',
    'Time',
    'Due In',
    'Status',
    'Action',
  ];

  String _formatStatusText(String? status) {
    if (status == null || status.isEmpty) return '-';
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

  Widget _buildDueInCell(
    Map<String, dynamic> dueInStatus,
    bool isExpanded,
    VoidCallback onTap,
  ) {
    final text = dueInStatus['text'] as String;
    if (text == '-') {
      return AllTasksDataCell(text: '-', isExpanded: isExpanded, onTap: onTap);
    }
    final isOverdue = dueInStatus['isOverdue'] as bool;
    final isToday = text.toLowerCase().contains('today');

    Color bgColor = isOverdue
        ? const Color(0xFFDC3545)
        : (isToday ? const Color(0xFFFD7E14) : const Color(0xFF1E7E34));

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            text,
            style: AppTextStyle.style_10_700(color: Colors.white),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCell(String? status, bool isExpanded, VoidCallback onTap) {
    if (status == null || status.isEmpty) {
      return AllTasksDataCell(text: '-', isExpanded: isExpanded, onTap: onTap);
    }

    final formattedText = _formatStatusText(status);
    final s = status.toLowerCase();

    Color bgColor;
    Color borderColor;
    Color textColor;

    if (s == 'upcoming') {
      bgColor = const Color(0xFFEBF3FF);
      borderColor = const Color(0xFF70A1F0);
      textColor = const Color(0xFF2563EB);
    } else if (s == 'overdue') {
      bgColor = const Color(0xFFFDE8E8);
      borderColor = const Color(0xFFF87171);
      textColor = const Color(0xFFDC3545);
    } else if (s == 'completed') {
      bgColor = const Color(0xFFE6F4EA);
      borderColor = const Color(0xFF34A853);
      textColor = const Color(0xFF1E7E34);
    } else {
      bgColor = const Color(0xFFF1F5F9);
      borderColor = const Color(0xFFCBD5E1);
      textColor = const Color(0xFF475569);
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            formattedText,
            style: AppTextStyle.style_10_600(color: textColor),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildActionCell(PaymentReminderItem item) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            icon: Icons.edit_outlined,
            iconColor: AppColors.black300,
            onTap: () {
              Get.to(() => CreatePaymentReminderScreen(reminderItem: item));
            },
          ),
          SizedBox(width: 4.w),
          _buildActionButton(
            icon: Icons.delete_outline,
            iconColor: const Color(0xFFDC3545),
            onTap: () => _showDeleteConfirmation(item),
          ),
          SizedBox(width: 4.w),
          _buildActionButton(
            icon: Icons.check_circle_outline,
            iconColor: const Color(0xFF28A745),
            onTap: () => _showCompleteConfirmation(item),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(PaymentReminderItem item) {
    if (item.recurrenceId != null || item.parentId != null) {
      _showDeleteRecurringConfirmation(item);
    } else {
      _showStandardDeleteConfirmation(item);
    }
  }

  void _showDeleteRecurringConfirmation(PaymentReminderItem item) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          width: 420.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC3545).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: const Color(0xFFDC3545),
                  size: 28.r,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Delete this Payment Reminder',
                style: AppTextStyle.style_16_700(color: AppColors.black),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'What do you want to delete?',
                style: AppTextStyle.style_14_400(color: AppColors.grey900),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        widget.controller.deleteReminder(
                          item.parentId ?? item.id,
                          recurrenceId: item.recurrenceId,
                          recurrenceScope: "only_this",
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFDC3545),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                      ),
                      child: Text(
                        'Only This',
                        style: AppTextStyle.style_12_600(
                          color: const Color(0xFFDC3545),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        widget.controller.deleteReminder(
                          item.parentId ?? item.id,
                          recurrenceId: item.recurrenceId,
                          recurrenceScope: "entire_schedule",
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC3545),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                      ),
                      child: Text(
                        'All Recurrences',
                        style: AppTextStyle.style_12_600(color: Colors.white),
                        textAlign: TextAlign.center,
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
  }

  void _showStandardDeleteConfirmation(PaymentReminderItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        titlePadding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 12.h),
        contentPadding: EdgeInsets.symmetric(horizontal: 24.w),
        actionsPadding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: const Color(0xFFDC3545).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: const Color(0xFFDC3545),
                size: 20.r,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'Delete Reminder',
              style: AppTextStyle.style_16_700(color: AppColors.black),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this payment reminder?\nThis action cannot be undone.',
          style: AppTextStyle.style_14_400(color: AppColors.grey900),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            ),
            child: Text(
              'Cancel',
              style: AppTextStyle.style_14_500(color: AppColors.black),
            ),
          ),
          SizedBox(width: 8.w),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.controller.deleteReminder(
                item.parentId ?? item.id,
                recurrenceId: item.recurrenceId,
                recurrenceScope: "entire_schedule",
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC3545),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              elevation: 0,
            ),
            child: Text(
              'Delete',
              style: AppTextStyle.style_14_600(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompleteConfirmation(PaymentReminderItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: const Color(0xFF28A745),
              size: 22.r,
            ),
            SizedBox(width: 8.w),
            Text(
              'Mark as Complete',
              style: AppTextStyle.style_14_700(color: AppColors.black),
            ),
          ],
        ),
        content: Text(
          'Mark this payment reminder as completed?',
          style: AppTextStyle.style_12_400(color: AppColors.grey900),
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            ),
            child: Text(
              'Cancel',
              style: AppTextStyle.style_12_500(color: AppColors.black),
            ),
          ),
          SizedBox(width: 8.w),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.controller.markComplete(
                item.parentId ?? item.id,
                recurrenceId: item.recurrenceId,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF28A745),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              elevation: 0,
            ),
            child: Text(
              'Confirm',
              style: AppTextStyle.style_12_600(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        padding: EdgeInsets.all(2.5.r),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Icon(icon, size: 12.5.sp, color: iconColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(() {
          final reminders = widget.controller.displayedReminders;

          if (reminders.isEmpty && !widget.controller.isLoading.value) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Text(
                  'No payment reminders found',
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
                      2: FixedColumnWidth(105.w), // Customer ID
                      3: FixedColumnWidth(110.w), // Assignee
                      4: FixedColumnWidth(115.w), // Expense Head
                      5: FixedColumnWidth(90.w), // Cost Center
                      6: FixedColumnWidth(80.w), // Due Date
                      7: FixedColumnWidth(130.w), // Reminder End Date
                      8: FixedColumnWidth(120.w), // Notification Date
                      9: FixedColumnWidth(80.w), // Time
                      10: FixedColumnWidth(110.w), // Due In
                      11: FixedColumnWidth(72.w), // Status
                      12: FixedColumnWidth(90.w), // Action
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
                              onTap: col == 'Action'
                                  ? null
                                  : () => widget.controller.toggleSort(col),
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
                        final rowKey = "${item.id}";
                        final isExpanded = _expandedRows.contains(rowKey);
                        void toggleRow() => _toggleRow(rowKey);

                        final dueInStatus = widget.controller.getDueInStatus(
                          item.dueDate,
                          serverDueIn: item.dueIn,
                        );
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
                            _buildDueInCell(dueInStatus, isExpanded, toggleRow),
                            _buildStatusCell(
                              item.status,
                              isExpanded,
                              toggleRow,
                            ),
                            _buildActionCell(item),
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
