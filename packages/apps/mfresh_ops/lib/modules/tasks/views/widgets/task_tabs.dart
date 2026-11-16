// region Imports
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:mfresh_ops/modules/tasks/controllers/daily_task_filter_controller.dart';
// endregion

// region TaskTabs Widget
class TaskTabs extends StatelessWidget {
  // region Properties
  final TasksController? controller;
  final DailyTaskFilterController? filterController;
  final Widget? trailing;
  // endregion

  // region Constructor
  const TaskTabs({
    super.key,
    this.controller,
    this.filterController,
    this.trailing,
  }) : assert(controller != null || filterController != null,
            'Either controller or filterController must be provided');
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    if (controller != null) {
      return _buildForTasksController(controller!);
    } else {
      return _buildForFilterController(filterController!);
    }
  }
  // endregion

  // region TasksController Builder
  Widget _buildForTasksController(TasksController tc) {
    return Obx(() {
      final activeCount = tc.taskCounts['active'] ?? 0;
      final completedCount = tc.taskCounts['completed'] ?? 0;
      final tabActiveText =
          activeCount > 0 ? 'Active ($activeCount)' : 'Active';
      final tabCompletedText =
          completedCount > 0 ? 'Completed ($completedCount)' : 'Completed';

      return Row(
        children: [
          // ── TAB SWITCHER (Using AppCommonConnectedTabBar with fluid sliding animation) ──
          Expanded(
            child: AppCommonConnectedTabBar(
              tabs: [tabActiveText, tabCompletedText],
              selectedIndex: tc.activeTab.value,
              height: 28.h,
              isPillStyle: true,
              borderColor: AppColors.borderColor,
              backgroundColor: const Color(0xFFF1F5F9),
              activeTabColor: AppColors.white,
              activeTextColor: AppColors.primary,
              inactiveTextColor: const Color(0xFF64748B),
              activeTextStyle:
                  AppTextStyle.style_12_600(color: AppColors.primary),
              inactiveTextStyle:
                  AppTextStyle.style_12_500(color: const Color(0xFF64748B)),
              borderRadius: BorderRadius.circular(6.r),
              onTabChanged: (index) => tc.changeTab(index),
            ),
          ),
          SizedBox(width: 8.w),
          _buildViewModeSwitcher(
            isListView: tc.isListView.value,
            onChanged: (val) => tc.isListView.value = val,
          ),
          if (trailing != null) ...[
            SizedBox(width: 8.w),
            trailing!,
          ],
        ],
      );
    });
  }
  // endregion

  // region FilterController Builder
  Widget _buildForFilterController(DailyTaskFilterController fc) {
    return Obx(() {
      final tabActiveText = fc.tabActiveCount.value > 0
          ? 'Active (${fc.tabActiveCount.value})'
          : 'Active';
      final tabCompletedText = fc.tabCompletedCount.value > 0
          ? 'Completed (${fc.tabCompletedCount.value})'
          : 'Completed';
      final isCompleted = fc.selectedTab.value == 'completed';

      return Row(
        children: [
          // ── TAB SWITCHER (Using AppCommonConnectedTabBar with fluid sliding animation) ──
          Expanded(
            child: AppCommonConnectedTabBar(
              tabs: [tabActiveText, tabCompletedText],
              selectedIndex: isCompleted ? 1 : 0,
              height: 28.h,
              isPillStyle: true,
              borderColor: AppColors.borderColor,
              backgroundColor: const Color(0xFFF1F5F9),
              activeTabColor: AppColors.white,
              activeTextColor: AppColors.primary,
              inactiveTextColor: const Color(0xFF64748B),
              activeTextStyle:
                  AppTextStyle.style_12_600(color: AppColors.primary),
              inactiveTextStyle:
                  AppTextStyle.style_12_500(color: const Color(0xFF64748B)),
              borderRadius: BorderRadius.circular(6.r),
              onTabChanged: (index) {
                fc.changeTab(index == 0 ? 'active' : 'completed');
              },
            ),
          ),
          SizedBox(width: 8.w),

          // ── VIEW MODE SWITCHER (Detail View vs List View) ──
          _buildViewModeSwitcher(
            isListView: fc.isListView.value,
            onChanged: (val) => fc.isListView.value = val,
          ),

          if (trailing != null) ...[
            SizedBox(width: 8.w),
            trailing!,
          ],
        ],
      );
    });
  }
  // endregion

  // region View Mode Switcher
  Widget _buildViewModeSwitcher({
    required bool isListView,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      height: 28.h,
      padding: EdgeInsets.all(2.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewModeButton(
            isSelected: !isListView,
            icon: Icons.view_day_outlined,
            onTap: () => onChanged(false),
          ),
          SizedBox(width: 2.w),
          _buildViewModeButton(
            isSelected: isListView,
            icon: Icons.format_list_bulleted_rounded,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeButton({
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(4.r),
          border: isSelected
              ? Border.all(
                  color: AppColors.borderColor.withValues(alpha: 0.3),
                  width: 0.5,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 14.r,
          color: isSelected
              ? AppColors.primary
              : const Color(0xFF64748B),
        ),
      ),
    );
  }
  // endregion
}
// endregion
