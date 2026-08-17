import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/daily_task_card.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/task_filter_card.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/task_stat_item.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/task_tabs.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';

class DailyTasksScreen extends StatefulWidget {
  const DailyTasksScreen({super.key});

  @override
  State<DailyTasksScreen> createState() => _DailyTasksScreenState();
}

class _DailyTasksScreenState extends State<DailyTasksScreen> {
  late final TasksController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TasksController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Daily Task',
          style: AppTextStyle.style_18_700(color: AppColors.black),
        ),
        actions: [
          Obx(() {
            if (Get.find<AuthRepository>().rxUserPermissions.contains(
              'create_new_task',
            )) {
              return Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Center(
                  child: SizedBox(
                    height: 24.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.find<TasksController>().formInitialized.value =
                            false;
                        Get.toNamed(AppRoutes.createTask);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A3B8),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        elevation: 1,
                      ),
                      child: Text(
                        'Create Task',
                        style: AppTextStyle.style_12_500(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
        showAppDrawer: true,
        hasBackButton: false,
        iconColor: AppColors.black,
        topHeader: const CommonShortcutHeader(),
      ),
      drawer: const CommonSidebar(),
      body: RefreshIndicator(
        onRefresh: () => controller.pullToRefresh(),
        child: Obx(() {
          final bool isInitialLoading =
              controller.isLoading.value && controller.tasks.isEmpty;

          final displayTasks = isInitialLoading
              ? List.generate(
                  5,
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
                    startTime: '10:00 AM',
                    endTime: '11:00 AM',
                    createdAt: '2026-06-04T10:00:00Z',
                    updatedAt: '2026-06-04T10:00:00Z',
                    taskInstanceId: index,
                    scheduleDateTime: '27-Feb-2026',
                    status: 'pending',
                    project: 'mFresh',
                    assigneeName: 'Loading Assignee',
                    approverName: 'Loading Approver',
                    createdByName: 'Loading Creator',
                    completedByName: 'Loading Completer',
                  ),
                )
              : (controller.isFiltered
                        ? controller.tasks
                        : controller.allDailyTasks)
                    .where((task) {
                      final status = task.status.toLowerCase();
                      if (controller.activeTab.value == 0) {
                        return status != 'completed' &&
                            status != 'approved' &&
                            status != 'review' &&
                            status != 'under_review';
                      } else {
                        return status == 'completed' ||
                            status == 'approved' ||
                            status == 'review' ||
                            status == 'under_review';
                      }
                    })
                    .toList();

          final List<TaskItem> overdueTasks = [];
          final List<TaskItem> todayTasks = [];
          final List<TaskItem> tomorrowTasks = [];

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final tomorrowStart = today.add(const Duration(days: 1));

          if (isInitialLoading) {
            todayTasks.addAll(displayTasks);
          } else {
            for (final task in displayTasks) {
              final dt = _parseDateTime(task.scheduleDateTime);
              if (dt != null) {
                final taskDate = DateTime(dt.year, dt.month, dt.day);
                if (taskDate.isBefore(today)) {
                  overdueTasks.add(task);
                } else if (taskDate.isAtSameMomentAs(today)) {
                  todayTasks.add(task);
                } else {
                  tomorrowTasks.add(task);
                }
              } else {
                todayTasks.add(task);
              }
            }
          }

          return Skeletonizer(
            enabled: isInitialLoading,
            child: CustomScrollView(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Wrap(
                        spacing: 12.w,
                        runSpacing: 4.h,
                        children: [
                          TaskStatItem(
                            count: '${controller.taskCounts['active'] ?? 0}',
                            label: 'Active',
                            color: AppColors.orange1,
                          ),
                          TaskStatItem(
                            count: '${controller.taskCounts['upcoming'] ?? 0}',
                            label: 'Upcoming',
                            color: const Color(0xFFFFB822),
                          ),
                          TaskStatItem(
                            count: '${controller.taskCounts['completed'] ?? 0}',
                            label: 'Completed',
                            color: AppColors.green,
                          ),
                          TaskStatItem(
                            count: '${controller.taskCounts['overdue'] ?? 0}',
                            label: 'Overdue',
                            color: AppColors.error,
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      TaskFilterCard(controller: controller),
                      SizedBox(height: 6.h),
                      Text(
                        'My Tasks',
                        style: AppTextStyle.style_14_600(
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      TaskTabs(controller: controller),
                      SizedBox(height: 12.h),
                    ]),
                  ),
                ),
                if (displayTasks.isEmpty && !controller.isLoading.value)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 50.h),
                        child: Text(
                          'No tasks found',
                          style: AppTextStyle.style_12_400(
                            color: AppColors.grey200,
                          ),
                        ),
                      ),
                    ),
                  )
                else ...[
                  if (overdueTasks.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, size: 18.r, color: const Color(0xFFE25C5C)),
                                SizedBox(width: 8.w),
                                Text(
                                  'Overdue Tasks',
                                  style: AppTextStyle.style_14_700(color: const Color(0xFFE25C5C)),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 6.h),
                            child: DailyTaskCard(task: overdueTasks[index]),
                          );
                        }, childCount: overdueTasks.length),
                      ),
                    ),
                  ],
                  if (todayTasks.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (overdueTasks.isNotEmpty) ...[
                              const DashedDivider(
                                height: 1.5,
                                color: Color(0xFF90CAF9),
                                dashWidth: 4,
                                dashSpace: 3,
                              ),
                              SizedBox(height: 8.h),
                            ],
                            Row(
                              children: [
                                Icon(Icons.today, size: 18.r, color: AppColors.primary),
                                SizedBox(width: 8.w),
                                Text(
                                  'Today\'s Tasks',
                                  style: AppTextStyle.style_14_700(color: AppColors.primary),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 6.h),
                            child: DailyTaskCard(task: todayTasks[index]),
                          );
                        }, childCount: todayTasks.length),
                      ),
                    ),
                  ],
                  if (tomorrowTasks.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 6.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const DashedDivider(
                              height: 1.5,
                              color: Color(0xFF90CAF9),
                              dashWidth: 4,
                              dashSpace: 3,
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_outlined,
                                  size: 18.r,
                                  color: const Color(0xFF0D6EFD),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Tomorrow – Upcoming Tasks',
                                  style: AppTextStyle.style_14_700(
                                    color: const Color(0xFF0D6EFD),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 6.h),
                            child: DailyTaskCard(task: tomorrowTasks[index]),
                          );
                        }, childCount: tomorrowTasks.length),
                      ),
                    ),
                  ],
                  if (controller.isLoading.value && controller.tasks.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 24.h,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  DateTime? _parseDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr).toLocal();
    } catch (_) {}

    String cleaned = dateStr.replaceAll(',', '').trim();
    try {
      List<String> parts;
      if (cleaned.contains('-')) {
        parts = cleaned.split(RegExp(r'[-\s]+'));
      } else {
        parts = cleaned.split(RegExp(r'\s+'));
      }
      if (parts.length >= 3) {
        int? day = int.tryParse(parts[0]);
        int? year = int.tryParse(parts[2]);
        final monthStr = parts[1].toLowerCase();
        int? month;
        final monthsList = [
          'jan',
          'feb',
          'mar',
          'apr',
          'may',
          'jun',
          'jul',
          'aug',
          'sep',
          'oct',
          'nov',
          'dec',
        ];
        for (int i = 0; i < monthsList.length; i++) {
          if (monthStr.startsWith(monthsList[i])) {
            month = i + 1;
            break;
          }
        }
        if (day != null && month != null && year != null) {
          int hour = 0;
          int minute = 0;
          if (parts.length >= 4) {
            final timeParts = parts[3].split(':');
            if (timeParts.isNotEmpty) {
              hour = int.tryParse(timeParts[0]) ?? 0;
              if (timeParts.length > 1) {
                minute = int.tryParse(timeParts[1]) ?? 0;
              }
            }
            if (parts.length >= 5) {
              final marker = parts[4].toLowerCase();
              if (marker == 'pm' && hour < 12) {
                hour += 12;
              } else if (marker == 'am' && hour == 12) {
                hour = 0;
              }
            }
          }
          return DateTime(year, month, day, hour, minute).toLocal();
        }
      }
    } catch (_) {}
    return null;
  }
}

class DashedDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double dashWidth;
  final double dashSpace;

  const DashedDivider({
    super.key,
    this.height = 1,
    this.color = Colors.blue,
    this.dashWidth = 5,
    this.dashSpace = 3,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
        );
      },
    );
  }
}
