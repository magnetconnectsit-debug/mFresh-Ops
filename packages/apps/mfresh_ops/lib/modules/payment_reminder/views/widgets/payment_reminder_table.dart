import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:mfresh_ops/modules/payment_reminder/controllers/payment_reminder_controller.dart';
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
    'Sl No',
    'For',
    'Costumer ID',
    'Assignee Name',
    'Expense Head',
    'Sub-Head',
    'Cost Center',
    'Due Date',
    'Due In',
    'Action',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(() {
              final reminders = widget.controller.displayedReminders;
              
              if (reminders.isEmpty && !widget.controller.isLoading.value) {
                return Center(
                  child: Text(
                    'No payment reminders found',
                    style: AppTextStyle.style_14_500(color: AppColors.grey300),
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
                          0: FixedColumnWidth(50.w), // Sl No
                          1: FixedColumnWidth(100.w), // For
                          2: FixedColumnWidth(100.w), // Customer ID
                          3: FixedColumnWidth(140.w), // Assignee Name
                          4: FixedColumnWidth(130.w), // Expense Head
                          5: FixedColumnWidth(100.w), // Sub-Head
                          6: FixedColumnWidth(100.w), // Cost Center
                          7: FixedColumnWidth(100.w), // Due Date
                          8: FixedColumnWidth(125.w), // Due In
                          9: FixedColumnWidth(70.w), // Action
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
                                isSorted: widget.controller.sortColumn.value == col,
                                sortAscending: widget.controller.sortAscending.value,
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

                          final dueInStatus = widget.controller.getDueInStatus(item.dueDate);

                          return TableRow(
                            children: [
                              AllTasksDataCell(
                                text: '${(widget.controller.currentPage.value - 1) * widget.controller.perPage.value + index + 1}',
                                isExpanded: isExpanded,
                                onTap: toggleRow,
                              ),
                              AllTasksDataCell(
                                text: item.forDesc ?? '-',
                                isExpanded: isExpanded,
                                onTap: toggleRow,
                              ),
                              AllTasksDataCell(
                                text: item.customerId ?? '-',
                                isExpanded: isExpanded,
                                onTap: toggleRow,
                              ),
                              AllTasksDataCell(
                                text: widget.controller.getAssigneeName(item.notificationTo),
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
                                text: item.dueDate != null ? AppDateUtils.formatToOrdinalDate(item.dueDate) : '-',
                                isExpanded: isExpanded,
                                onTap: toggleRow,
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: dueInStatus['isOverdue'] ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    dueInStatus['text'],
                                    style: AppTextStyle.style_11_600(
                                      color: dueInStatus['isOverdue'] ? Colors.red : Colors.green,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {},
                                      child: Icon(Icons.edit_outlined, size: 18.sp, color: Colors.blue),
                                    ),
                                    SizedBox(width: 8.w),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Icon(Icons.delete_outline, size: 18.sp, color: Colors.red),
                                    ),
                                  ],
                                ),
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
        
        // Pagination Footer
        Obx(() {
          if (widget.controller.paymentReminders.isEmpty || widget.controller.isLoading.value) {
            return const SizedBox.shrink();
          }
          return Column(
            children: [
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AllTasksPaginationButton(
                            text: '←',
                            isActive: false,
                            onTap: () {
                              if (widget.controller.currentPage.value > 1) {
                                widget.controller.currentPage.value--;
                              }
                            },
                          ),
                          ...List.generate(
                            widget.controller.totalPages,
                            (index) {
                              final pageNumber = index + 1;
                              return AllTasksPaginationButton(
                                text: pageNumber.toString(),
                                isActive: widget.controller.currentPage.value == pageNumber,
                                onTap: () => widget.controller.currentPage.value = pageNumber,
                              );
                            },
                          ),
                          AllTasksPaginationButton(
                            text: '→',
                            isActive: false,
                            onTap: () {
                              if (widget.controller.currentPage.value < widget.controller.totalPages) {
                                widget.controller.currentPage.value++;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Showing ${widget.controller.paymentReminders.isEmpty ? 0 : (widget.controller.currentPage.value - 1) * widget.controller.perPage.value + 1} to ${(widget.controller.currentPage.value * widget.controller.perPage.value).clamp(0, widget.controller.paymentReminders.length)} of ${widget.controller.paymentReminders.length} entries',
                      style: AppTextStyle.style_12_400(
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
