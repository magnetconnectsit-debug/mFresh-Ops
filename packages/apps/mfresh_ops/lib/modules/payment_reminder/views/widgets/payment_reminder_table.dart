import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_table.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:mfresh_ops/data/models/payment_reminder/payment_reminder_model.dart';
import 'package:mfresh_ops/modules/payment_reminder/controllers/payment_reminder_controller.dart';
import 'package:mfresh_ops/modules/payment_reminder/views/create_payment_reminder_screen.dart';

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
      return _buildDataCell('-', isExpanded: isExpanded, onTap: onTap);
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
      return _buildDataCell('-', isExpanded: isExpanded, onTap: onTap);
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

  Widget _buildDataCell(
    String text, {
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Text(
          text,
          style: AppTextStyle.style_12_400(color: AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
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
                  color: const Color(0xFFDC3545).withValues(alpha: 0.1),
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
                    child: AppCommonButton(
                      text: 'Only This',
                      variant: ButtonVariant.outline,
                      textColor: const Color(0xFFDC3545),
                      borderColor: const Color(0xFFDC3545),
                      height: 36.h,
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        widget.controller.deleteReminder(
                          item.parentId ?? item.id,
                          recurrenceId: item.recurrenceId,
                          recurrenceScope: "only_this",
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: AppCommonButton(
                      text: 'All Recurrences',
                      buttonColor: const Color(0xFFDC3545),
                      useGradient: false,
                      height: 36.h,
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        widget.controller.deleteReminder(
                          item.parentId ?? item.id,
                          recurrenceId: item.recurrenceId,
                          recurrenceScope: "entire_schedule",
                        );
                      },
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
                color: const Color(0xFFDC3545).withValues(alpha: 0.1),
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
          AppCommonButton(
            text: 'Cancel',
            variant: ButtonVariant.outline,
            textColor: AppColors.black,
            borderColor: Colors.grey.shade400,
            height: 36.h,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          SizedBox(width: 8.w),
          AppCommonButton(
            text: 'Delete',
            buttonColor: const Color(0xFFDC3545),
            useGradient: false,
            height: 36.h,
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.controller.deleteReminder(
                item.parentId ?? item.id,
                recurrenceId: item.recurrenceId,
                recurrenceScope: "entire_schedule",
              );
            },
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
          AppCommonButton(
            text: 'Cancel',
            variant: ButtonVariant.outline,
            textColor: AppColors.black,
            borderColor: Colors.grey.shade400,
            height: 34.h,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          SizedBox(width: 8.w),
          AppCommonButton(
            text: 'Confirm',
            buttonColor: const Color(0xFF28A745),
            useGradient: false,
            height: 34.h,
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.controller.markComplete(
                item.parentId ?? item.id,
                recurrenceId: item.recurrenceId,
              );
            },
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
          final bool isLoading = widget.controller.isLoading.value;

          final columns = [
            AppTableColumn<PaymentReminderItem>(
              key: 'SI No',
              title: 'SI No',
              width: 42.w,
              cellBuilder: (context, item, index, isExpanded) {
                final rowKey = "${item.id}";
                final isRowExpanded = _expandedRows.contains(rowKey);
                return _buildDataCell(
                  '${(widget.controller.currentPage.value - 1) * widget.controller.perPage.value + index + 1}',
                  isExpanded: isRowExpanded,
                  onTap: () => _toggleRow(rowKey),
                );
              },
            ),
            AppTableColumn<PaymentReminderItem>(
              key: 'For',
              title: 'For',
              width: 85.w,
              cellBuilder: (context, item, index, isExpanded) {
                final rowKey = "${item.id}";
                final isRowExpanded = _expandedRows.contains(rowKey);
                return _buildDataCell(
                  item.forDesc ?? '-',
                  isExpanded: isRowExpanded,
                  onTap: () => _toggleRow(rowKey),
                );
              },
            ),
            AppTableColumn<PaymentReminderItem>(
              key: 'Customer ID',
              title: 'Customer ID',
              width: 105.w,
              cellBuilder: (context, item, index, isExpanded) {
                final rowKey = "${item.id}";
                final isRowExpanded = _expandedRows.contains(rowKey);
                return _buildDataCell(
                  item.to ?? '-',
                  isExpanded: isRowExpanded,
                  onTap: () => _toggleRow(rowKey),
                );
              },
            ),
            AppTableColumn<PaymentReminderItem>(
              key: 'Assignee',
              title: 'Assignee',
              width: 110.w,
              cellBuilder: (context, item, index, isExpanded) {
                final rowKey = "${item.id}";
                final isRowExpanded = _expandedRows.contains(rowKey);
                final assigneeDisplay = item.assigneeName != null &&
                        item.assigneeName!.isNotEmpty
                    ? item.assigneeName!
                    : widget.controller.getAssigneeName(item.assigneeId);
                return _buildDataCell(
                  assigneeDisplay,
                  isExpanded: isRowExpanded,
                  onTap: () => _toggleRow(rowKey),
                );
              },
            ),
            AppTableColumn<PaymentReminderItem>(
              key: 'Expense Head',
              title: 'Expense Head',
              width: 115.w,
              cellBuilder: (context, item, index, isExpanded) {
                final rowKey = "${item.id}";
                final isRowExpanded = _expandedRows.contains(rowKey);
                return _buildDataCell(
                  item.expenseHead ?? '-',
                  isExpanded: isRowExpanded,
                  onTap: () => _toggleRow(rowKey),
                );
              },
            ),
            AppTableColumn<PaymentReminderItem>(
              key: 'Cost Center',
              title: 'Cost Center',
              width: 90.w,
              cellBuilder: (context, item, index, isExpanded) {
                final rowKey = "${item.id}";
                final isRowExpanded = _expandedRows.contains(rowKey);
                return _buildDataCell(
                  item.costCenter ?? '-',
                  isExpanded: isRowExpanded,
                  onTap: () => _toggleRow(rowKey),
                );
              },
            ),
            AppTableColumn<PaymentReminderItem>(
              key: 'Due Date',
              title: 'Due Date',
              width: 80.w,
              cellBuilder: (context, item, index, isExpanded) {
                final rowKey = "${item.id}";
                final isRowExpanded = _expandedRows.contains(rowKey);
                return _buildDataCell(
                  _formatDate(item.dueDate),
                  isExpanded: isRowExpanded,
                  onTap: () => _toggleRow(rowKey),
                );
              },
            ),
            AppTableColumn<PaymentReminderItem>(
              key: 'Reminder End Date',
              title: 'Reminder End Date',
              width: 130.w,
              cellBuilder: (context, item, index, isExpanded) {
                final rowKey = "${item.id}";
                final isRowExpanded = _expandedRows.contains(rowKey);
                return _buildDataCell(
                  _formatDate(item.endDate),
                  isExpanded: isRowExpanded,
                  onTap: () => _toggleRow(rowKey),
                );
              },
            ),
            AppTableColumn<PaymentReminderItem>(
              key: 'Notification Date',
              title: 'Notification Date',
              width: 120.w,
              cellBuilder: (context, item, index, isExpanded) {
                final rowKey = "${item.id}";
                final isRowExpanded = _expandedRows.contains(rowKey);
                return _buildDataCell(
                  _formatDate(item.notificationDate),
                  isExpanded: isRowExpanded,
                  onTap: () => _toggleRow(rowKey),
                );
              },
            ),
            AppTableColumn<PaymentReminderItem>(
              key: 'Time',
              title: 'Time',
              width: 80.w,
              cellBuilder: (context, item, index, isExpanded) {
                final rowKey = "${item.id}";
                final isRowExpanded = _expandedRows.contains(rowKey);
                return _buildDataCell(
                  _formatTime(item.notificationTime),
                  isExpanded: isRowExpanded,
                  onTap: () => _toggleRow(rowKey),
                );
              },
            ),
            AppTableColumn<PaymentReminderItem>(
              key: 'Due In',
              title: 'Due In',
              width: 110.w,
              cellBuilder: (context, item, index, isExpanded) {
                final rowKey = "${item.id}";
                final isRowExpanded = _expandedRows.contains(rowKey);
                final dueInStatus = widget.controller.getDueInStatus(
                  item.dueDate,
                  serverDueIn: item.dueIn,
                );
                return _buildDueInCell(
                  dueInStatus,
                  isRowExpanded,
                  () => _toggleRow(rowKey),
                );
              },
            ),
            AppTableColumn<PaymentReminderItem>(
              key: 'Status',
              title: 'Status',
              width: 72.w,
              cellBuilder: (context, item, index, isExpanded) {
                final rowKey = "${item.id}";
                final isRowExpanded = _expandedRows.contains(rowKey);
                return _buildStatusCell(
                  item.status,
                  isRowExpanded,
                  () => _toggleRow(rowKey),
                );
              },
            ),
            AppTableColumn<PaymentReminderItem>(
              key: 'Action',
              title: 'Action',
              width: 90.w,
              cellBuilder: (context, item, index, isExpanded) {
                return _buildActionCell(item);
              },
            ),
          ];

          if (reminders.isEmpty && !isLoading) {
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

          return AppCommonTable<PaymentReminderItem>(
            items: reminders,
            columns: columns,
            currentSortColumn: widget.controller.sortColumn.value,
            currentSortOrder: widget.controller.sortAscending.value
                ? AppTableSortOrder.ascending
                : AppTableSortOrder.descending,
            onSort: (columnKey, sortOrder) {
              if (columnKey != 'Action' && columnKey != 'SI No') {
                widget.controller.toggleSort(columnKey);
              }
            },
            headingRowColor: const Color(0xFFC5D5F0),
            headingBorderColor: Colors.grey.shade300,
            headingTextStyle: AppTextStyle.style_12_700(
              color: AppColors.grey900,
            ),
            borderColor: Colors.grey.shade300,
            isLoading: isLoading,
            emptyText: 'No payment reminders found',
          );
        }),
      ],
    );
  }
}
