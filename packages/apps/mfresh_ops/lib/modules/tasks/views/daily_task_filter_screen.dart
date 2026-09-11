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
          'Daily Task Filter',
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
                return Column(
                  children: [
                    DailyTaskQuickViewSection(controller: controller),
                    SizedBox(height: 12.h),
                    DailyTaskMonthWiseSection(controller: controller),
                  ],
                );
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
                        child: const Text('Active'),
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
                        child: const Text('Completed'),
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

class DailyTaskQuickViewSection extends StatefulWidget {
  final DailyTaskFilterController controller;

  const DailyTaskQuickViewSection({super.key, required this.controller});

  @override
  State<DailyTaskQuickViewSection> createState() => _DailyTaskQuickViewSectionState();
}

class _DailyTaskQuickViewSectionState extends State<DailyTaskQuickViewSection> {
  final Map<String, bool> _expandedCards = {
    'yesterday': false,
    'today': false,
    'tomorrow': false,
    'last_week': false,
    'this_week': false,
    'next_week': false,
  };

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final totalCount =
          widget.controller.quickViewData['total_count']?.toString() ?? '0';

      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFE5E5E5)),
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
            InkWell(
              onTap: () => widget.controller.isQuickViewExpanded.value =
                  !widget.controller.isQuickViewExpanded.value,
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Row(
                  children: [
                    Icon(Icons.bolt_rounded,
                        size: 18.r, color: const Color(0xFF212529)),
                    SizedBox(width: 8.w),
                    Text(
                      'Quick View',
                      style: AppTextStyle.style_14_700(color: AppColors.black),
                    ),
                    const Spacer(),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        totalCount,
                        style: AppTextStyle.style_11_600(
                            color: AppColors.grey800),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      widget.controller.isQuickViewExpanded.value
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 20.r,
                      color: AppColors.grey500,
                    ),
                  ],
                ),
              ),
            ),
            if (widget.controller.isQuickViewExpanded.value) ...[
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  children: [
                    _buildSubCard('yesterday', Icons.replay_outlined, 'Yesterday'),
                    SizedBox(height: 8.h),
                    _buildSubCard('today', Icons.today_outlined, 'Today'),
                    SizedBox(height: 8.h),
                    _buildSubCard('tomorrow', Icons.east_outlined, 'Tomorrow'),
                    SizedBox(height: 8.h),
                    _buildSubCard('last_week', Icons.calendar_view_week_outlined, 'Last Week'),
                    SizedBox(height: 8.h),
                    _buildSubCard('this_week', Icons.date_range_outlined, 'This Week'),
                    SizedBox(height: 8.h),
                    _buildSubCard('next_week', Icons.next_week_outlined, 'Next Week'),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildSubCard(String key, IconData icon, String label) {
    int count = 0;
    List<TaskItem> tasks = [];
    if (widget.controller.quickViewData[key] != null) {
      count = widget.controller.quickViewData[key]['count'] ?? 0;
      if (widget.controller.quickViewData[key]['tasks'] is List) {
        tasks = (widget.controller.quickViewData[key]['tasks'] as List)
            .map((e) => TaskItem.fromJson(e))
            .toList();
      }
    }
    final isExpanded = _expandedCards[key] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expandedCards[key] = !isExpanded),
            borderRadius: BorderRadius.circular(6.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  Icon(icon, size: 16.r, color: AppColors.grey800),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyle.style_12_600(color: AppColors.black),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      '$count',
                      style: AppTextStyle.style_10_700(color: AppColors.black),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 18.r,
                    color: AppColors.grey500,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
              child: tasks.isEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Center(
                        child: Text(
                          'No tasks',
                          style: AppTextStyle.style_12_400(color: AppColors.grey400),
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final monthWiseData = widget.controller.monthWiseData;
      final totalCount = monthWiseData['total_count']?.toString() ?? '0';

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

      if (monthsMap.isEmpty && widget.controller.quickViewData.isNotEmpty) {
        final Map<String, List<Map<String, dynamic>>> groupedMonths = {};
        final monthsNames = [
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];

        widget.controller.quickViewData.forEach((sectionKey, sectionValue) {
          if (sectionValue is Map && sectionValue['tasks'] is List) {
            final tasksList = sectionValue['tasks'] as List;
            for (var rawTask in tasksList) {
              if (rawTask is Map) {
                final taskMap = Map<String, dynamic>.from(rawTask);
                final dtStr = taskMap['schedule_date_time'] ?? taskMap['schedule_date'] ?? taskMap['schedule_date_formatted'] ?? taskMap['start_date_time'];
                if (dtStr != null && dtStr.toString().isNotEmpty) {
                  try {
                    DateTime? dt;
                    final s = dtStr.toString().trim();
                    if (s.contains('-') && s.length >= 10) {
                      dt = DateTime.tryParse(s.replaceAll(' ', 'T'));
                    }
                    if (dt == null) {
                      final parts = s.replaceAll(',', '').split(RegExp(r'[-\s]+'));
                      if (parts.length >= 3) {
                        int? day = int.tryParse(parts[0]);
                        int? year = int.tryParse(parts[2]);
                        final monthStr = parts[1].toLowerCase();
                        int? month;
                        final monthsList = [
                          'jan', 'feb', 'mar', 'apr', 'may', 'jun',
                          'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
                        ];
                        for (int i = 0; i < monthsList.length; i++) {
                          if (monthStr.startsWith(monthsList[i])) {
                            month = i + 1;
                            break;
                          }
                        }
                        if (day != null && month != null && year != null) {
                          dt = DateTime(year, month, day);
                        }
                      }
                    }
                    if (dt != null) {
                      final monthGroupKey = "${monthsNames[dt.month - 1]} ${dt.year}";
                      groupedMonths.putIfAbsent(monthGroupKey, () => []).add(taskMap);
                    }
                  } catch (_) {}
                }
              }
            }
          }
        });

        groupedMonths.forEach((monthTitle, taskList) {
          monthsMap[monthTitle] = {
            'count': taskList.length,
            'tasks': taskList,
          };
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
                    Text(
                      'Month Wise',
                      style: AppTextStyle.style_14_700(color: AppColors.black),
                    ),
                    const Spacer(),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        totalCount,
                        style: AppTextStyle.style_11_600(
                            color: AppColors.grey800),
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
                              .map((e) => TaskItem.fromJson(Map<String, dynamic>.from(e as Map)))
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
                                    onTap: () {
                                      setState(() {
                                        _expandedMonths[monthTitle] = !isExpanded;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(6.r),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.w, vertical: 8.h),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isExpanded
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            size: 18.r,
                                            color: AppColors.grey500,
                                          ),
                                          SizedBox(width: 6.w),
                                          Expanded(
                                            child: Text(
                                              monthTitle,
                                              style: AppTextStyle.style_12_600(
                                                  color: AppColors.black),
                                            ),
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
                                            child: Text(
                                              '$count',
                                              style: AppTextStyle.style_10_700(
                                                  color: AppColors.black),
                                            ),
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
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 12.h),
                                              child: Text(
                                                'No tasks available for this month',
                                                style: AppTextStyle.style_12_400(
                                                    color: AppColors.grey400),
                                              ),
                                            )
                                          : Column(
                                              children: tasks.map((task) {
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 6.h),
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
