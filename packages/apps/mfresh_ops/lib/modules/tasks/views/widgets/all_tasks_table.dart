import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_table.dart';
import 'package:core/widgets/app_table_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';

class AllTasksTableWidget extends StatefulWidget {
  final TasksController controller;

  const AllTasksTableWidget({
    super.key,
    required this.controller,
  });

  @override
  State<AllTasksTableWidget> createState() => _AllTasksTableWidgetState();
}

class _AllTasksTableWidgetState extends State<AllTasksTableWidget> {
  final Set<String> _expandedRows = {};

  void _toggleRow(String key) {
    setState(() {
      if (_expandedRows.contains(key)) {
        _expandedRows.remove(key);
      } else {
        _expandedRows.add(key);
      }
    });
  }

  String _sanitize(String text) {
    return text.replaceAll('_', ' ');
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'NA') return 'NA';
    try {
      DateTime dt = DateTime.parse(dateStr).toLocal();
      List<String> months = [
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
      String day = dt.day.toString().padLeft(2, '0');
      String month = months[dt.month - 1];
      String year = dt.year.toString();

      int hour = dt.hour;
      String ampm = 'AM';
      if (hour >= 12) {
        ampm = 'PM';
        if (hour > 12) hour -= 12;
      }
      if (hour == 0) hour = 12;

      String minute = dt.minute.toString().padLeft(2, '0');
      return "$day $month $year, ${hour.toString().padLeft(2, '0')}:$minute $ampm";
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Obx(() {
      final itemsToRender = controller.sortedTasks;
      final bool isLoading = controller.isLoading.value;

      final columns = [
        AppTableColumn<TaskItem>(
          key: 'Task ID',
          title: 'Task ID',
          width: 100.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, task, index, isExpanded) {
            final rowKey = "${task.taskCode}_${task.taskInstanceId}";
            final isRowExpanded = _expandedRows.contains(rowKey);
            return _AllTasksDataCell(
              text: "${task.taskCode}_${task.taskInstanceId}",
              isExpanded: isRowExpanded,
              onTap: () {
                final status = task.status.toLowerCase();
                if (status == 'completed' || status == 'approved') {
                  controller.fetchTaskSubmissionDetails(
                    task,
                    isReview: true,
                    readOnly: true,
                  );
                } else {
                  if (Get.find<AuthRepository>()
                      .rxUserPermissions
                      .contains('Task_Edit')) {
                    controller.editTaskDetails(task);
                  }
                }
              },
              textColor: AppColors.blue500,
              fontWeight: FontWeight.bold,
            );
          },
        ),
        AppTableColumn<TaskItem>(
          key: 'Project',
          title: 'Project',
          width: 80.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, task, index, isExpanded) {
            final rowKey = "${task.taskCode}_${task.taskInstanceId}";
            final isRowExpanded = _expandedRows.contains(rowKey);
            return _AllTasksDataCell(
              text: _sanitize(task.project ?? 'mFresh'),
              isExpanded: isRowExpanded,
              onTap: () => _toggleRow(rowKey),
            );
          },
        ),
        AppTableColumn<TaskItem>(
          key: 'Task',
          title: 'Task',
          width: 200.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, task, index, isExpanded) {
            final rowKey = "${task.taskCode}_${task.taskInstanceId}";
            final isRowExpanded = _expandedRows.contains(rowKey);
            return _AllTasksDataCell(
              text: task.title,
              isExpanded: isRowExpanded,
              onTap: () => _toggleRow(rowKey),
            );
          },
        ),
        AppTableColumn<TaskItem>(
          key: 'Created On',
          title: 'Created On',
          width: 140.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, task, index, isExpanded) {
            final rowKey = "${task.taskCode}_${task.taskInstanceId}";
            final isRowExpanded = _expandedRows.contains(rowKey);
            return _AllTasksDataCell(
              text: _formatDateTime(task.createdAt),
              isExpanded: isRowExpanded,
              onTap: () => _toggleRow(rowKey),
            );
          },
        ),
        AppTableColumn<TaskItem>(
          key: 'Created By',
          title: 'Created By',
          width: 120.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, task, index, isExpanded) {
            final rowKey = "${task.taskCode}_${task.taskInstanceId}";
            final isRowExpanded = _expandedRows.contains(rowKey);
            return _AllTasksDataCell(
              text: _sanitize(
                task.createdByName ?? task.approverName ?? 'NA',
              ),
              isExpanded: isRowExpanded,
              onTap: () => _toggleRow(rowKey),
            );
          },
        ),
        AppTableColumn<TaskItem>(
          key: 'Task Type',
          title: 'Task Type',
          width: 85.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, task, index, isExpanded) {
            final rowKey = "${task.taskCode}_${task.taskInstanceId}";
            final isRowExpanded = _expandedRows.contains(rowKey);
            return _AllTasksDataCell(
              text: _sanitize(task.taskType.capitalizeFirst ?? 'NA'),
              isExpanded: isRowExpanded,
              onTap: () => _toggleRow(rowKey),
            );
          },
        ),
        AppTableColumn<TaskItem>(
          key: 'Assignee',
          title: 'Assignee',
          width: 120.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, task, index, isExpanded) {
            final rowKey = "${task.taskCode}_${task.taskInstanceId}";
            final isRowExpanded = _expandedRows.contains(rowKey);
            return _AllTasksDataCell(
              text: _sanitize(
                (task.assigneeName ?? '').replaceAll('_', ' '),
              ),
              isExpanded: isRowExpanded,
              onTap: () => _toggleRow(rowKey),
            );
          },
        ),
        AppTableColumn<TaskItem>(
          key: 'Started From',
          title: 'Started From',
          width: 140.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, task, index, isExpanded) {
            final rowKey = "${task.taskCode}_${task.taskInstanceId}";
            final isRowExpanded = _expandedRows.contains(rowKey);
            return _AllTasksDataCell(
              text: _formatDateTime(task.scheduleDateTime),
              isExpanded: isRowExpanded,
              onTap: () => _toggleRow(rowKey),
            );
          },
        ),
        AppTableColumn<TaskItem>(
          key: 'Completed By',
          title: 'Completed By',
          width: 120.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, task, index, isExpanded) {
            final rowKey = "${task.taskCode}_${task.taskInstanceId}";
            final isRowExpanded = _expandedRows.contains(rowKey);
            return _AllTasksDataCell(
              text: _sanitize(task.completedByName ?? ''),
              isExpanded: isRowExpanded,
              onTap: () => _toggleRow(rowKey),
            );
          },
        ),
        AppTableColumn<TaskItem>(
          key: 'Status',
          title: 'Status',
          width: 90.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, task, index, isExpanded) {
            final rowKey = "${task.taskCode}_${task.taskInstanceId}";
            final isRowExpanded = _expandedRows.contains(rowKey);
            return GestureDetector(
              onTap: () => _toggleRow(rowKey),
              behavior: HitTestBehavior.opaque,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _AllTasksStatusBadge(
                  status: task.status,
                  isExpanded: isRowExpanded,
                ),
              ),
            );
          },
        ),
        AppTableColumn<TaskItem>(
          key: 'Approver Name',
          title: 'Approver Name',
          width: 120.w,
          alignment: Alignment.centerLeft,
          cellBuilder: (context, task, index, isExpanded) {
            final rowKey = "${task.taskCode}_${task.taskInstanceId}";
            final isRowExpanded = _expandedRows.contains(rowKey);
            return _AllTasksDataCell(
              text: _sanitize(task.approverName ?? ''),
              isExpanded: isRowExpanded,
              onTap: () => _toggleRow(rowKey),
            );
          },
        ),
      ];

      final currentSortCol = controller.sortColumn.value;
      final currentSortAsc = controller.sortAscending.value;

      final startItem = controller.totalRecords.value == 0
          ? 0
          : (controller.currentPage.value - 1) * controller.perPage.value + 1;
      final endItem = (controller.currentPage.value * controller.perPage.value)
          .clamp(0, controller.totalRecords.value);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCommonTable<TaskItem>(
            items: itemsToRender,
            columns: columns,
            currentSortColumn: currentSortCol,
            currentSortOrder: currentSortAsc
                ? AppTableSortOrder.ascending
                : AppTableSortOrder.descending,
            onSort: (columnKey, sortOrder) {
              controller.toggleSort(columnKey);
            },
            headingRowColor: const Color(0xFFC5D5F0),
            headingBorderColor: Colors.grey.shade300,
            headingTextStyle: AppTextStyle.style_12_700(
              color: AppColors.grey900,
            ),
            borderColor: Colors.grey.shade300,
            isLoading: isLoading,
            emptyText: 'No tasks found',
          ),
          if (!isLoading && controller.totalRecords.value > 0) ...[
            SizedBox(height: 12.h),
            AppTablePagination(
              startItem: startItem,
              endItem: endItem,
              totalItems: controller.totalRecords.value,
              currentPage: controller.currentPage.value,
              totalPages: controller.totalPages.value,
              onPageChanged: (page) => controller.goToPage(page),
              onPreviousPage: controller.previousPage,
              onNextPage: controller.nextPage,
            ),
          ],
        ],
      );
    });
  }
}

class _AllTasksDataCell extends StatelessWidget {
  final String text;
  final bool isExpanded;
  final VoidCallback onTap;
  final Color? textColor;
  final FontWeight? fontWeight;

  const _AllTasksDataCell({
    required this.text,
    required this.isExpanded,
    required this.onTap,
    this.textColor,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          textAlign: TextAlign.left,
          style: AppTextStyle.style_12_400(color: textColor ?? AppColors.black).copyWith(
            fontWeight: fontWeight,
          ),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _AllTasksStatusBadge extends StatelessWidget {
  final String status;
  final bool isExpanded;

  const _AllTasksStatusBadge({
    required this.status,
    required this.isExpanded,
  });

  String _sanitize(String text) {
    return text.replaceAll('_', ' ');
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'in_progress':
        return AppColors.info;
      case 'completed':
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.red;
      case 'review':
      case 'under_review':
        return Colors.purple;
      default:
        return AppColors.grey300;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        _sanitize(status.toUpperCase()),
        style: AppTextStyle.style_10_700(color: color),
        textAlign: TextAlign.left,
        maxLines: isExpanded ? null : 1,
        overflow: isExpanded ? null : TextOverflow.ellipsis,
      ),
    );
  }
}
