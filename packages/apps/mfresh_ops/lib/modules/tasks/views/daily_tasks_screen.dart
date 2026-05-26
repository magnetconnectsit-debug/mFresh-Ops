import 'package:core/widgets/app_common_drop_down.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/modules/tasks/widgets/create_task_dialog.dart';
import 'package:mfresh_ops/modules/tasks/widgets/task_submission_dialog.dart';
import 'package:mfresh_ops/data/models/models.dart';

class DailyTasksScreen extends StatelessWidget {
  const DailyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensuring we get the same controller instance and refresh it
    final controller = Get.put(TasksController());

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Daily Task',
          style: AppTextStyle.style_18_700(color: AppColors.black),
        ),
        showAppDrawer: true,
        hasBackButton: false,
        iconColor: AppColors.black,
      ),
      drawer: const CommonSidebar(),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshData(),
        child: Obx(() {
          if (controller.isLoading.value && controller.tasks.isEmpty) {
            return ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: 5,
              separatorBuilder: (context, index) => SizedBox(height: 10.h),
              itemBuilder: (context, index) => _buildLoadingCard(),
            );
          }

          final displayTasks = controller.tasks.where((task) {
            final status = task.status.toLowerCase();
            if (controller.activeTab.value == 0) {
              // Active: Everything except completed and review
              return status != 'completed' &&
                  status != 'approved' &&
                  status != 'review' &&
                  status != 'under_review';
            } else {
              // Completed: Only completed and review
              return status == 'completed' ||
                  status == 'approved' ||
                  status == 'review' ||
                  status == 'under_review';
            }
          }).toList();

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            children: [
              Wrap(
                spacing: 12.w,
                runSpacing: 4.h,
                children: [
                  _buildStatItem(
                    '${controller.taskCounts['active'] ?? 0}',
                    'Active',
                    AppColors.orange1,
                  ),
                  _buildStatItem(
                    '${controller.taskCounts['completed'] ?? 0}',
                    'Completed',
                    AppColors.green,
                  ),
                  _buildStatItem(
                    '${controller.taskCounts['overdue'] ?? 0}',
                    'Overdue',
                    AppColors.error,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _buildFilterCard(controller),
              SizedBox(height: 12.h),
              _buildCreateTaskButton(),
              SizedBox(height: 16.h),
              Text(
                'My Tasks',
                style: AppTextStyle.style_16_700(color: AppColors.black),
              ),
              SizedBox(height: 8.h),
              _buildTabs(controller),
              SizedBox(height: 12.h),

              if (displayTasks.isEmpty && !controller.isLoading.value)
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50.h),
                    child: Text(
                      'No tasks found',
                      style: AppTextStyle.style_12_400(
                        color: AppColors.grey200,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayTasks.length,
                  separatorBuilder: (context, index) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    return _buildTaskCard(displayTasks[index]);
                  },
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFilterCard(TasksController controller) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => AppCommonDropdown<TaskProject>(
                    hintText: 'Project',
                    options: controller.projects
                        .map(
                          (e) => DropdownOption(value: e, label: e.projectName),
                        )
                        .toList(),
                    selectedValues: controller.selectedProjects,
                    onMultiSelectChanged: (val) =>
                        controller.selectedProjects.assignAll(val),
                    isMultiSelect: true,
                    style: AppTextStyle.style_10_600(color: AppColors.black),
                    hintStyle: AppTextStyle.style_10_600(
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Obx(
                  () => AppCommonDropdown<SupportUnit>(
                    hintText: 'Store (Unit)',
                    options: controller.units
                        .map((e) => DropdownOption(value: e, label: e.unitName))
                        .toList(),
                    selectedValues: controller.selectedUnits,
                    onMultiSelectChanged: (val) =>
                        controller.selectedUnits.assignAll(val),
                    isMultiSelect: true,
                    style: AppTextStyle.style_10_600(color: AppColors.black),
                    hintStyle: AppTextStyle.style_10_600(
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => AppCommonDropdown<TaskGroup>(
                    hintText: 'Group',
                    options: controller.groups
                        .map((e) => DropdownOption(value: e, label: e.roleName))
                        .toList(),
                    selectedValues: controller.selectedGroups,
                    onMultiSelectChanged: (val) =>
                        controller.selectedGroups.assignAll(val),
                    isMultiSelect: true,
                    style: AppTextStyle.style_10_600(color: AppColors.black),
                    hintStyle: AppTextStyle.style_10_600(
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Obx(
                  () => AppCommonDropdown<AssigneeModel>(
                    hintText: 'Assignee',
                    options: controller.assignees
                        .map((e) => DropdownOption(value: e, label: e.name))
                        .toList(),
                    selectedValues: controller.selectedAssignees,
                    onMultiSelectChanged: (val) =>
                        controller.selectedAssignees.assignAll(val),
                    isMultiSelect: true,
                    style: AppTextStyle.style_10_600(color: AppColors.black),
                    hintStyle: AppTextStyle.style_10_600(
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildFilterButton(
                'Reset',
                AppColors.white,
                AppColors.black,
                onTap: () {
                  controller.selectedProjects.clear();
                  controller.selectedGroups.clear();
                  controller.selectedUnits.clear();
                  controller.selectedAssignees.clear();
                  controller.refreshData();
                },
                borderColor: AppColors.borderColor,
              ),
              SizedBox(width: 8.w),
              _buildFilterButton(
                'Apply',
                AppColors.info,
                AppColors.white,
                onTap: () {
                  controller.refreshData();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(
    String label,
    Color bgColor,
    Color textColor, {
    required VoidCallback onTap,
    Color? borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4.r),
          border: borderColor != null ? Border.all(color: borderColor) : null,
        ),
        child: Text(label, style: AppTextStyle.style_9_400(color: textColor)),
      ),
    );
  }

  Widget _buildCreateTaskButton() {
    return SizedBox(
      height: 28.h,
      width: 90.w,
      child: ElevatedButton(
        onPressed: () {
          Get.dialog(const CreateTaskDialog());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.info,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          'Create Task',
          style: AppTextStyle.style_10_600(color: AppColors.white),
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(count, style: AppTextStyle.style_12_700(color: color)),
        SizedBox(width: 3.w),
        Text(label, style: AppTextStyle.style_10_500(color: AppColors.black)),
      ],
    );
  }

  Widget _buildTabs(TasksController controller) {
    return Container(
      height: 36.h,
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        color: AppColors.toggleColorTab,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _buildTabItem(
                title: 'Active',
                isSelected: controller.activeTab.value == 0,
                onTap: () => controller.changeTab(0),
              ),
            ),
            Expanded(
              child: _buildTabItem(
                title: 'Completed',
                isSelected: controller.activeTab.value == 1,
                onTap: () => controller.changeTab(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : AppColors.transparent,
          borderRadius: BorderRadius.circular(4.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: isSelected
                ? AppTextStyle.style_11_600(color: AppColors.black)
                : AppTextStyle.style_11_500(color: AppColors.black2),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(TaskItem task) {
    Color statusBg;
    String statusText = task.status;

    switch (task.status.toLowerCase()) {
      case 'overdue':
        statusBg = AppColors.error;
        statusText = 'Overdue';
        break;
      case 'pending':
      case 'due':
        statusBg = AppColors.red;
        statusText = 'Due';
        break;
      case 'upcoming':
        statusBg = AppColors.orange1;
        statusText = 'Upcoming';
        break;
      case 'review':
      case 'under_review':
        statusBg = AppColors.orange900;
        statusText = 'Review';
        break;
      case 'completed':
      case 'approved':
        statusBg = AppColors.green;
        statusText = 'Completed';
        break;
      case 'rejected':
        statusBg = AppColors.black;
        statusText = 'Rejected';
        break;
      default:
        statusBg = AppColors.black2;
    }

    return GestureDetector(
      onTap: () {
        final status = task.status.toLowerCase();
        if (status == 'review' || status == 'under_review') {
          Get.dialog(TaskSubmissionDialog(task: task, isReview: true));
        } else if (status == 'due' ||
            status == 'overdue' ||
            status == 'pending' ||
            status == 'rejected') {
          Get.dialog(TaskSubmissionDialog(task: task, isReview: false));
        } else if (status != 'completed' && status != 'approved') {
          Get.dialog(CreateTaskDialog(task: task));
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: task.title,
                          style: AppTextStyle.style_12_700(
                            color: AppColors.black,
                          ),
                        ),
                        if (task.project != null ||
                            task.groupNames != null) ...[
                          TextSpan(
                            text: '  •  ',
                            style: AppTextStyle.style_10_400(
                              color: AppColors.black2,
                            ),
                          ),
                          TextSpan(
                            text: task.project ?? task.groupNames ?? '',
                            style: AppTextStyle.style_10_400(
                              color: AppColors.black2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 3.h,
                    children: [
                      _buildIconText(
                        Icons.access_time,
                        '${task.startTime} - ${task.endTime}',
                      ),
                      _buildIconText(
                        Icons.calendar_today,
                        task.scheduleDateTime,
                      ),
                      if (task.assigneeName != null &&
                          task.assigneeName!.isNotEmpty)
                        _buildIconText(
                          Icons.person_outline,
                          task.assigneeName!,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 75.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Center(
                    child: Text(
                      statusText,
                      style: AppTextStyle.style_10_700(color: AppColors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 9.r, color: AppColors.black2),
        SizedBox(width: 3.w),
        Flexible(
          child: Text(
            text,
            style: AppTextStyle.style_8_400(color: AppColors.black2),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 150.w, height: 12.h, color: AppColors.grey50),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Container(
                      width: 60.w,
                      height: 8.h,
                      color: AppColors.grey50,
                    ),
                    SizedBox(width: 10.w),
                    Container(
                      width: 60.w,
                      height: 8.h,
                      color: AppColors.grey50,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 75.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ],
      ),
    );
  }
}
