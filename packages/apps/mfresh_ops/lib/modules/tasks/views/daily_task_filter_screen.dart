// region Imports
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import '../controllers/daily_task_filter_controller.dart';
import '../controllers/tasks_controller.dart';
import 'widgets/daily_task_filter_bar.dart';
import 'widgets/daily_task_filter_card.dart';
import 'widgets/task_stat_item.dart';
import 'widgets/task_tabs.dart';
// endregion

// region DailyTaskFilterScreen
class DailyTaskFilterScreen extends StatelessWidget {
  const DailyTaskFilterScreen({super.key});

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DailyTaskFilterController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        showAppDrawer: true,
        hasBackButton: false,
        topHeader: const CommonShortcutHeader(),
        title: Text(
          'Daily Task By Month',
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
                  child: AppCommonButton(
                    text: 'Create Task',
                    buttonColor: const Color(0xFF16A3B8),
                    textColor: Colors.white,
                    height: 24.h,
                    textSize: 12.sp,
                    borderRadius: 4.r,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    useGradient: false,
                    onPressed: () async {
                      if (Get.isRegistered<TasksController>()) {
                        Get.find<TasksController>().formInitialized.value =
                            false;
                      }
                      await Get.toNamed(AppRoutes.createTask);
                      controller.fetchFilterData();
                    },
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      drawer: const CommonSidebar(),
      body: AppRefreshIndicator(
        onRefresh: () => controller.fetchFilterData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(12.w),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Obx(() {
                    return Wrap(
                      spacing: 12.w,
                      runSpacing: 2.h,
                      children: [
                        TaskStatItem(
                          count: '${controller.activeCount.value}',
                          label: 'Active',
                          color: AppColors.orange1,
                        ),
                        TaskStatItem(
                          count: '${controller.upcomingCount.value}',
                          label: 'Upcoming',
                          color: const Color(0xFFFFB822),
                        ),
                        TaskStatItem(
                          count: '${controller.completedCount.value}',
                          label: 'Completed',
                          color: AppColors.green,
                        ),
                        TaskStatItem(
                          count: '${controller.overdueCount.value}',
                          label: 'Overdue',
                          color: AppColors.error,
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: 2.h),
                  DailyTaskFilterBar(controller: controller),
                  SizedBox(height: 6.h),
                  TaskTabs(filterController: controller),
                  SizedBox(height: 8.h),
                  _buildMonthWiseContentCard(controller),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  // endregion

  // region Month Wise Content Card
  Widget _buildMonthWiseContentCard(DailyTaskFilterController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Obx(() {
        if (controller.isLoading.value) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: const Center(
              child: CustomAppLoader(),
            ),
          );
        }
        return DailyTaskMonthWiseSection(controller: controller);
      }),
    );
  }
  // endregion
}
// endregion

// region DailyTaskMonthWiseSection Widget
class DailyTaskMonthWiseSection extends StatefulWidget {
  final DailyTaskFilterController controller;

  const DailyTaskMonthWiseSection({super.key, required this.controller});

  @override
  State<DailyTaskMonthWiseSection> createState() => _DailyTaskMonthWiseSectionState();
}

class _DailyTaskMonthWiseSectionState extends State<DailyTaskMonthWiseSection> {
  // region State Variables & Properties
  final Map<String, bool> _expandedMonths = {};
  final Map<String, bool> _expandedWeeks = {};

  int get _headerTabCount {
    final currentTab = widget.controller.selectedTab.value;
    final tabCount = currentTab == 'completed'
        ? widget.controller.tabCompletedCount.value
        : widget.controller.tabActiveCount.value;

    if (tabCount > 0) return tabCount;

    int sum = 0;
    for (final month in widget.controller.taskDataList) {
      final mCount = int.tryParse('${month['count']}') ?? 0;
      if (mCount > 0) {
        sum += mCount;
      } else if (month['weeks'] is List) {
        for (final w in (month['weeks'] as List)) {
          final wCount = int.tryParse('${w['count']}') ?? 0;
          if (wCount > 0) {
            sum += wCount;
          } else if (w['tasks'] is List) {
            sum += (w['tasks'] as List).length;
          }
        }
      }
    }
    return sum > 0 ? sum : widget.controller.totalCount.value;
  }
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final taskDataList = widget.controller.taskDataList;

      // Fallback to legacy monthWiseData if new format is empty
      if (taskDataList.isEmpty) {
        return _buildLegacyMonthWise();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          InkWell(
            onTap: () => widget.controller.isMonthWiseExpanded.value =
                !widget.controller.isMonthWiseExpanded.value,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        size: 18.r, color: AppColors.black),
                    SizedBox(width: 8.w),
                    Text(
                      'Month Wise',
                      style: AppTextStyle.style_14_700(color: AppColors.black),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '$_headerTabCount',
                        style: AppTextStyle.style_11_600(color: AppColors.grey800),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      widget.controller.isMonthWiseExpanded.value
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 20.r,
                      color: AppColors.grey500,
                    ),
                  ],
                ),
              ),
            ),
            if (widget.controller.isMonthWiseExpanded.value) ...[
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: taskDataList.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(12.r),
                        child: Text(
                          'No month-wise data available',
                          style: AppTextStyle.style_12_400(color: AppColors.grey500),
                        ),
                      )
                    : Column(
                        children: taskDataList.asMap().entries.map((monthEntry) {
                          return _buildMonthBlock(monthEntry.value);
                        }).toList(),
                      ),
              ),
            ],
          ],
        );
      });
  }
  // endregion

  // region Section Builders
  Widget _buildMonthBlock(Map<String, dynamic> monthData) {
    final monthKey = monthData['month_key']?.toString() ?? '';
    final monthLabel = monthData['month_label'] ?? monthData['month_name'] ?? 'Month';
    final isCurrentMonth = monthData['is_current_month'] == true;
    final defaultOpen = monthData['default_open'] == true;
    final weeks = (monthData['weeks'] as List? ?? [])
        .map((w) => Map<String, dynamic>.from(w as Map))
        .toList();

    int monthCount = int.tryParse('${monthData['count']}') ?? 0;
    if (monthCount == 0 && weeks.isNotEmpty) {
      for (final w in weeks) {
        int wc = int.tryParse('${w['count']}') ?? 0;
        if (wc == 0 && w['tasks'] is List) {
          wc = (w['tasks'] as List).length;
        }
        monthCount += wc;
      }
    }

    _expandedMonths.putIfAbsent(monthKey, () => defaultOpen);
    final isMonthExpanded = _expandedMonths[monthKey] ?? defaultOpen;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: isCurrentMonth
                ? AppColors.primary.withValues(alpha: 0.3)
                : Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            // Month header
            InkWell(
              onTap: () => setState(() => _expandedMonths[monthKey] = !isMonthExpanded),
              borderRadius: BorderRadius.circular(6.r),
              child: Container(
                decoration: BoxDecoration(
                  color: isCurrentMonth
                      ? AppColors.primary.withValues(alpha: 0.06)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 9.h),
                child: Row(
                  children: [
                    Icon(
                      isMonthExpanded
                          ? Icons.keyboard_arrow_down_rounded
                          : Icons.keyboard_arrow_right_rounded,
                      size: 18.r,
                      color: isCurrentMonth ? AppColors.primary : AppColors.grey500,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        monthLabel.toString(),
                        style: AppTextStyle.style_12_700(
                          color: isCurrentMonth ? AppColors.primary : AppColors.black,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: isCurrentMonth
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isCurrentMonth
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        '$monthCount',
                        style: AppTextStyle.style_10_700(
                          color: isCurrentMonth ? AppColors.primary : AppColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Weeks
            if (isMonthExpanded) ...[
              Divider(
                height: 1,
                color: isCurrentMonth
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : const Color(0xFFE2E8F0),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
                child: Column(
                  children: weeks.asMap().entries.map((weekEntry) {
                    return _buildWeekBlock(monthKey, weekEntry.value);
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeekBlock(String monthKey, Map<String, dynamic> weekData) {
    final weekNo = weekData['week_no']?.toString() ?? '';
    final weekKey = '${monthKey}_week$weekNo';
    final weekLabel = weekData['week_label'] ?? 'Week $weekNo';
    final isCurrentWeek = weekData['is_current_week'] == true;
    final defaultOpen = weekData['default_open'] == true;
    final rawTasks = weekData['tasks'] as List? ?? [];
    final tasks = rawTasks
        .map((t) => TaskItem.fromJson(Map<String, dynamic>.from(t as Map)))
        .toList();

    int weekCount = int.tryParse('${weekData['count']}') ?? 0;
    if (weekCount == 0 && tasks.isNotEmpty) {
      weekCount = tasks.length;
    }

    _expandedWeeks.putIfAbsent(weekKey, () => defaultOpen);
    final isWeekExpanded = _expandedWeeks[weekKey] ?? defaultOpen;

    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(
            color: isCurrentWeek
                ? const Color(0xFF0EA5E9).withValues(alpha: 0.35)
                : Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            // Week header
            InkWell(
              onTap: () => setState(() => _expandedWeeks[weekKey] = !isWeekExpanded),
              borderRadius: BorderRadius.circular(5.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                child: Row(
                  children: [
                    Icon(
                      isWeekExpanded
                          ? Icons.keyboard_arrow_down_rounded
                          : Icons.keyboard_arrow_right_rounded,
                      size: 18.r,
                      color: isCurrentWeek
                          ? const Color(0xFF0EA5E9)
                          : AppColors.grey500,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        weekLabel.toString(),
                        style: AppTextStyle.style_11_600(
                          color: isCurrentWeek
                              ? const Color(0xFF0369A1)
                              : AppColors.grey800,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: isCurrentWeek
                            ? const Color(0xFFE0F2FE)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '$weekCount',
                        style: AppTextStyle.style_10_600(
                          color: isCurrentWeek
                              ? const Color(0xFF0369A1)
                              : AppColors.grey600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Tasks
            if (isWeekExpanded) ...[
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
                child: tasks.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: Center(
                          child: Text(
                            'No tasks in this week',
                            style: AppTextStyle.style_11_400(
                                color: AppColors.grey400),
                          ),
                        ),
                      )
                    : Column(
                        children: tasks
                            .map((t) => Padding(
                                  padding: EdgeInsets.only(bottom: 6.h),
                                  child: DailyTaskFilterCard(task: t),
                                ))
                            .toList(),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  // endregion

  // region Legacy Fallback Builder
  /// Fallback rendering using legacy monthWiseData map structure
  Widget _buildLegacyMonthWise() {
    return Obx(() {
      final monthWiseData = widget.controller.monthWiseData;
      final totalCount = _headerTabCount.toString();

      Map<String, dynamic> monthsMap = {};
      final rawGroups = monthWiseData['groups'];
      final rawMonths = monthWiseData['months'];
      if (rawGroups is List) {
        for (var item in rawGroups) {
          if (item is Map) {
            final label = item['label'] ?? item['month_key'] ?? 'Month';
            monthsMap[label.toString()] = item;
          }
        }
      } else if (rawMonths is Map) {
        monthsMap = Map<String, dynamic>.from(rawMonths);
      } else if (rawMonths is List) {
        for (var item in rawMonths) {
          if (item is Map) {
            final label = item['label'] ?? item['month_key'] ?? item['name'] ?? 'Month';
            monthsMap[label.toString()] = item;
          }
        }
      } else {
        monthWiseData.forEach((key, value) {
          if (key != 'total_count' && key != 'groups' && value is Map) {
            monthsMap[key] = value;
          }
        });
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => widget.controller.isMonthWiseExpanded.value =
                !widget.controller.isMonthWiseExpanded.value,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        size: 18.r, color: AppColors.black),
                    SizedBox(width: 6.w),
                    Text('Month Wise',
                        style: AppTextStyle.style_14_700(color: AppColors.black)),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(totalCount,
                          style: AppTextStyle.style_11_600(color: AppColors.grey800)),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      widget.controller.isMonthWiseExpanded.value
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 20.r,
                      color: AppColors.grey500,
                    ),
                  ],
                ),
              ),
            ),
            if (widget.controller.isMonthWiseExpanded.value) ...[
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              Padding(
                padding: EdgeInsets.all(10.w),
                child: monthsMap.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(12.r),
                        child: Text('No month-wise data available',
                            style: AppTextStyle.style_12_400(
                                color: AppColors.grey500)),
                      )
                    : Column(
                        children: monthsMap.entries.map((entry) {
                          final monthTitle = entry.key;
                          final monthObj = entry.value is Map
                              ? Map<String, dynamic>.from(entry.value as Map)
                              : <String, dynamic>{};
                          final count = monthObj['count'] ?? 0;
                          final rawTasks = monthObj['tasks'] as List? ?? [];
                          final tasks = rawTasks
                              .map((e) => TaskItem.fromJson(
                                  Map<String, dynamic>.from(e as Map)))
                              .toList();
                          final isExpanded = _expandedMonths[monthTitle] ?? false;

                          return Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () => setState(() {
                                      _expandedMonths[monthTitle] = !isExpanded;
                                    }),
                                    borderRadius: BorderRadius.circular(6.r),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.w, vertical: 8.h),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isExpanded
                                                ? Icons.keyboard_arrow_down_rounded
                                                : Icons.keyboard_arrow_right_rounded,
                                            size: 18.r,
                                            color: AppColors.grey500,
                                          ),
                                          SizedBox(width: 4.w),
                                          Expanded(
                                            child: Text(monthTitle,
                                                style: AppTextStyle.style_12_600(
                                                    color: AppColors.black)),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.w, vertical: 2.h),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                            ),
                                            child: Text('$count',
                                                style: AppTextStyle.style_10_700(
                                                    color: AppColors.black)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isExpanded) ...[
                                    const Divider(
                                        height: 1, color: Color(0xFFE2E8F0)),
                                    Padding(
                                      padding: EdgeInsets.all(8.w),
                                      child: tasks.isEmpty
                                          ? Padding(
                                              padding:
                                                  EdgeInsets.symmetric(vertical: 12.h),
                                              child: Text(
                                                'No tasks available',
                                                style: AppTextStyle.style_12_400(
                                                    color: AppColors.grey400),
                                              ),
                                            )
                                          : Column(
                                              children: tasks.map((task) {
                                                return Padding(
                                                  padding:
                                                      EdgeInsets.only(bottom: 6.h),
                                                  child: DailyTaskFilterCard(task: task),
                                                );
                                              }).toList(),
                                            ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ],
        );
      });
  }
  // endregion
}
// endregion

