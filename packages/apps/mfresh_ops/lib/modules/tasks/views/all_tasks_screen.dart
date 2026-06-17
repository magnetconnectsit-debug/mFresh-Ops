import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/task_filter_card.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/all_tasks_action_buttons.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/all_tasks_table_elements.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:core/core.dart';

class AllTasksScreen extends StatefulWidget {
  const AllTasksScreen({super.key});

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> {
  late final TasksController controller;
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

  @override
  void initState() {
    super.initState();
    controller = Get.put(TasksController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshData();
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
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
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
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppCommonAppBar(
        title: Text(
          'All Task',
          style: AppTextStyle.style_18_700(color: AppColors.black),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        showAppDrawer: true,
        hasBackButton: false,
        iconColor: AppColors.black,
      ),
      drawer: const CommonSidebar(),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.selectedProjects.clear();
          controller.selectedGroups.clear();
          controller.selectedUnits.clear();
          controller.selectedAssignees.clear();
          await controller.refreshData();
        },
        child: Obx(() {
          final tasksList = controller.tasks;
          final bool isInitialLoading =
              controller.isLoading.value && tasksList.isEmpty;

          final itemsToRender = isInitialLoading
              ? List.generate(
                  10,
                  (index) => TaskItem(
                    id: index,
                    taskCode: 'TSK00$index',
                    projectId: '1',
                    groupId: '1',
                    taskType: 'Type',
                    unitId: '1',
                    assignTo: '1',
                    assigneeRole: '1',
                    title: 'Dummy Task Title $index',
                    description: '',
                    frequency: 'Daily',
                    createdBy: '1',
                    startDate: '2026-06-04',
                    endDate: '2026-06-04',
                    repeatInterval: '1',
                    photoRequired: '0',
                    approvalRequired: '0',
                    approverId: '1',
                    selectedDays: '',
                    monthDays: '',
                    yearDays: '',
                    occurrences: '',
                    startTime: '10:00',
                    endTime: '11:00',
                    createdAt: '2026-06-04T10:00:00Z',
                    updatedAt: '2026-06-04T10:00:00Z',
                    taskInstanceId: index,
                    scheduleDateTime: '2026-06-04T10:00:00Z',
                    status: 'pending',
                    project: 'mFresh',
                    assigneeName: 'Loading Assignee',
                    approverName: 'Loading Approver',
                    createdByName: 'Loading Creator',
                    completedByName: 'Loading Completer',
                  ),
                )
              : tasksList;

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              TaskFilterCard(controller: controller),
              SizedBox(height: 12.h),
              AllTasksActionButtons(controller: controller),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.w),
                child: tasksList.isEmpty && !controller.isLoading.value && !isInitialLoading
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 50.h),
                          child: Text(
                            'No tasks found',
                            style: AppTextStyle.style_14_500(
                              color: AppColors.grey300,
                            ),
                          ),
                        ),
                      )
                    : Skeletonizer(
                        enabled: isInitialLoading,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(4.r),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4.r),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Table(
                                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                    border: TableBorder.symmetric(
                                      inside: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    columnWidths: {
                                      0: FixedColumnWidth(100.w),
                                      1: FixedColumnWidth(80.w),
                                      2: FixedColumnWidth(200.w),
                                      3: FixedColumnWidth(140.w),
                                      4: FixedColumnWidth(120.w),
                                      5: FixedColumnWidth(80.w),
                                      6: FixedColumnWidth(120.w),
                                      7: FixedColumnWidth(140.w),
                                      8: FixedColumnWidth(120.w),
                                      9: FixedColumnWidth(90.w),
                                      10: FixedColumnWidth(120.w),
                                    },
                                    children: [
                                      TableRow(
                                        decoration: BoxDecoration(color: Colors.grey.shade100),
                                        children: const [
                                          AllTasksHeaderCell(text: 'Task ID'),
                                          AllTasksHeaderCell(text: 'Project'),
                                          AllTasksHeaderCell(text: 'Task'),
                                          AllTasksHeaderCell(text: 'Created On'),
                                          AllTasksHeaderCell(text: 'Created By'),
                                          AllTasksHeaderCell(text: 'Task Type'),
                                          AllTasksHeaderCell(text: 'Assignee'),
                                          AllTasksHeaderCell(text: 'Started From'),
                                          AllTasksHeaderCell(text: 'Completed By'),
                                          AllTasksHeaderCell(text: 'Status'),
                                          AllTasksHeaderCell(text: 'Approver Name'),
                                        ],
                                      ),
                                      ...itemsToRender.map((task) {
                                        final rowKey = "${task.taskCode}_${task.taskInstanceId}";
                                        final isExpanded = _expandedRows.contains(rowKey);
                                        void toggleRow() => _toggleRow(rowKey);

                                        return TableRow(
                                          children: [
                                            AllTasksDataCell(
                                              text: "${task.taskCode}_${task.taskInstanceId}",
                                              isExpanded: isExpanded,
                                              onTap: () {
                                                final status = task.status.toLowerCase();
                                                if (status == 'completed' || status == 'approved') {
                                                  controller.fetchTaskSubmissionDetails(task, isReview: true, readOnly: true);
                                                } else {
                                                  if (Get.find<AuthRepository>().rxUserPermissions.contains('Task_Edit')) {
                                                    controller.editTaskDetails(task);
                                                  }
                                                }
                                              },
                                              textColor: AppColors.blue500,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            AllTasksDataCell(text: _sanitize(task.project ?? 'mFresh'), isExpanded: isExpanded, onTap: toggleRow),
                                            AllTasksDataCell(text: task.title, isExpanded: isExpanded, onTap: toggleRow),
                                            AllTasksDataCell(text: _formatDateTime(task.createdAt), isExpanded: isExpanded, onTap: toggleRow),
                                            AllTasksDataCell(text: _sanitize(task.createdByName ?? task.approverName ?? 'NA'), isExpanded: isExpanded, onTap: toggleRow),
                                            AllTasksDataCell(text: _sanitize(task.taskType.capitalizeFirst ?? 'NA'), isExpanded: isExpanded, onTap: toggleRow),
                                            AllTasksDataCell(text: _sanitize(task.assigneeName ?? ''), isExpanded: isExpanded, onTap: toggleRow),
                                            AllTasksDataCell(text: _formatDateTime(task.scheduleDateTime), isExpanded: isExpanded, onTap: toggleRow),
                                            AllTasksDataCell(text: _sanitize(task.completedByName ?? ''), isExpanded: isExpanded, onTap: toggleRow),
                                            GestureDetector(
                                              onTap: toggleRow,
                                              behavior: HitTestBehavior.opaque,
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                                child: AllTasksStatusBadge(status: task.status, isExpanded: isExpanded),
                                              ),
                                            ),
                                            AllTasksDataCell(text: _sanitize(task.approverName ?? ''), isExpanded: isExpanded, onTap: toggleRow),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (!isInitialLoading && controller.totalRecords.value > 0) ...[
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
                                            onTap: controller.previousPage,
                                          ),
                                          ...List.generate(controller.totalPages.value, (index) {
                                            final pageNumber = index + 1;
                                            return AllTasksPaginationButton(
                                              text: pageNumber.toString(),
                                              isActive: controller.currentPage.value == pageNumber,
                                              onTap: () => controller.goToPage(pageNumber),
                                            );
                                          }),
                                          AllTasksPaginationButton(
                                            text: '→',
                                            isActive: false,
                                            onTap: controller.nextPage,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    Text(
                                      'Showing ${controller.totalRecords.value == 0 ? 0 : (controller.currentPage.value - 1) * controller.perPage.value + 1} to ${(controller.currentPage.value * controller.perPage.value).clamp(0, controller.totalRecords.value)} of ${controller.totalRecords.value} entries',
                                      style: AppTextStyle.style_12_400(color: AppColors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 24.h),
            ],
          );
        }),
      ),
    );
  }
}
