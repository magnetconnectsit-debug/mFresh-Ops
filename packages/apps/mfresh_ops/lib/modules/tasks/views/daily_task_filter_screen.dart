import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import '../controllers/daily_task_filter_controller.dart';
import 'widgets/daily_task_filter_bar.dart';
import 'widgets/daily_task_filter_card.dart';

class DailyTaskFilterScreen extends StatelessWidget {
  const DailyTaskFilterScreen({super.key});

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
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Obx(() {
              return Row(
                children: [
                  _buildStatusCount(
                    icon: Icons.check_circle_rounded,
                    color: const Color(0xFF10B981),
                    count: controller.completedCount.value,
                  ),
                  SizedBox(width: 8.w),
                  _buildStatusCount(
                    icon: Icons.hourglass_bottom_rounded,
                    color: const Color(0xFFF59E0B),
                    count: controller.activeCount.value,
                  ),
                  SizedBox(width: 8.w),
                  _buildStatusCount(
                    icon: Icons.cancel_rounded,
                    color: const Color(0xFFEF4444),
                    count: controller.overdueCount.value,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
      drawer: const CommonSidebar(),
      body: AppRefreshIndicator(
        onRefresh: () => controller.fetchFilterData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DailyTaskFilterBar(controller: controller),
              SizedBox(height: 12.h),
              _buildTabSelector(controller),
              SizedBox(height: 12.h),
              Obx(() {
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
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCount({
    required IconData icon,
    required Color color,
    required int count,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.r, color: color),
        SizedBox(width: 2.w),
        Text(
          '$count',
          style: AppTextStyle.style_12_700(color: color),
        ),
      ],
    );
  }

  Widget _buildTabSelector(DailyTaskFilterController controller) {
    return Container(
      height: 34.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Obx(() {
        final isActive = controller.selectedTab.value == 'active';
        return Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              alignment: isActive ? Alignment.centerLeft : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 1.0,
                child: Container(
                  margin: EdgeInsets.all(2.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => controller.changeTab('active'),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: isActive
                            ? AppTextStyle.style_13_600(color: AppColors.black)
                            : AppTextStyle.style_13_500(color: AppColors.grey500),
                        child: Text(
                          controller.tabActiveCount.value > 0
                              ? 'Active (${controller.tabActiveCount.value})'
                              : 'Active',
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => controller.changeTab('completed'),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: !isActive
                            ? AppTextStyle.style_13_600(color: AppColors.black)
                            : AppTextStyle.style_13_500(color: AppColors.grey500),
                        child: Text(
                          controller.tabCompletedCount.value > 0
                              ? 'Completed (${controller.tabCompletedCount.value})'
                              : 'Completed',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class DailyTaskMonthWiseSection extends StatefulWidget {
  final DailyTaskFilterController controller;

  const DailyTaskMonthWiseSection({super.key, required this.controller});

  @override
  State<DailyTaskMonthWiseSection> createState() => _DailyTaskMonthWiseSectionState();
}

class _DailyTaskMonthWiseSectionState extends State<DailyTaskMonthWiseSection> {
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final taskDataList = widget.controller.taskDataList;

      // Fallback to legacy monthWiseData if new format is empty
      if (taskDataList.isEmpty) {
        return _buildLegacyMonthWise();
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: () => widget.controller.isMonthWiseExpanded.value =
                  !widget.controller.isMonthWiseExpanded.value,
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
        ),
      );
    });
  }

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

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => widget.controller.isMonthWiseExpanded.value =
                  !widget.controller.isMonthWiseExpanded.value,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
        ),
      );
    });
  }
}

