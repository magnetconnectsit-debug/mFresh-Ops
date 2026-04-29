import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/routes/app_routes.dart';

class DailyTasksScreen extends StatelessWidget {
  const DailyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TasksController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        title: Text(
          'Daily Task',
          style: AppTextStyle.style_18_700(color: AppColors.white),
        ),
        backgroundColor: AppColors.primary,
        showAppDrawer: true,
        hasBackButton: false,
      ),
      drawer: const CommonSidebar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Task Overview',
                    style: AppTextStyle.style_20_600(color: AppColors.black),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 16.w,
                    runSpacing: 8.h,
                    children: [
                      _buildStatItem('105', 'Active', AppColors.orange),
                      _buildStatItem('5', 'Completed', AppColors.success),
                      _buildStatItem('2', 'Overdue', AppColors.red),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Today\'s Tasks',
                    style: AppTextStyle.style_20_600(color: AppColors.black),
                  ),
                  SizedBox(height: 12.h),
                  Obx(() {
                    final list = controller.tasks; // Showing active tasks for daily view
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      separatorBuilder: (context, index) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        return _buildTaskCard(list[index], true);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label, Color color) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$count ',
            style: AppTextStyle.style_12_700(color: color),
          ),
          TextSpan(
            text: label,
            style: AppTextStyle.style_12_500(color: AppColors.grey300),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task, bool isActive) {
    Color statusColor;
    String statusText = task.status;
    bool showTimer = isActive;

    switch (task.status) {
      case 'Overdue': statusColor = AppColors.red; break;
      case 'Due': statusColor = AppColors.red; break;
      case 'Upcoming': statusColor = AppColors.orange; break;
      case 'Review': statusColor = AppColors.orange; break;
      case 'Completed': statusColor = AppColors.success; break;
      default: statusColor = AppColors.grey300;
    }

    return GestureDetector(
      onTap: () {
        if (task.status == 'Review' || task.status == 'Completed') {
          Get.toNamed(AppRoutes.taskReview, arguments: task);
        } else {
          Get.toNamed(AppRoutes.createTask, arguments: task);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.grey50),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
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
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4.w,
                    children: [
                      Text(
                        task.title,
                        style: AppTextStyle.style_12_700(color: AppColors.black),
                      ),
                      Text(
                        '• ${task.subtitle}',
                        style: AppTextStyle.style_10_400(color: AppColors.grey200),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 4.h,
                    children: [
                      _buildIconText(Icons.access_time, task.time),
                      _buildIconText(Icons.calendar_today, task.date),
                      _buildIconText(Icons.person_outline, task.assignee),
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
                  width: 80.w,
                  height: 22.h,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(
                    child: Text(
                      statusText,
                      style: AppTextStyle.style_10_700(color: AppColors.white),
                    ),
                  ),
                ),
                if (showTimer)
                  Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Text(
                      '00:59',
                      style: AppTextStyle.style_9_400(color: AppColors.success),
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
        Icon(icon, size: 10.r, color: AppColors.grey200),
        SizedBox(width: 4.w),
        Text(
          text,
          style: AppTextStyle.style_9_400(color: AppColors.grey200),
        ),
      ],
    );
  }
}
