import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/routes/app_routes.dart';

class AllTasksScreen extends StatelessWidget {
  const AllTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TasksController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        title: Text(
          'All Task',
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
                  _buildFilterCard(),
                  SizedBox(height: 20.h),
                  _buildCreateTaskButton(),
                  SizedBox(height: 24.h),
                  Text(
                    'My Tasks',
                    style: AppTextStyle.style_20_600(color: AppColors.black),
                  ),
                  SizedBox(height: 12.h),
                  _buildTabs(controller),
                  SizedBox(height: 16.h),
                  Obx(() {
                    final list = controller.activeTab.value == 0 
                        ? controller.tasks 
                        : controller.completedTasks;
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      separatorBuilder: (context, index) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        return _buildTaskCard(list[index], controller.activeTab.value == 0);
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

  Widget _buildFilterCard() {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.grey50),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildFilterField('Project')),
              SizedBox(width: 10.w),
              Expanded(child: _buildFilterField('Store (Unit)')),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(child: _buildFilterField('Group')),
              SizedBox(width: 10.w),
              Expanded(child: _buildFilterField('Assignee')),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildFilterButton('Reset', AppColors.white, AppColors.black, borderColor: AppColors.grey50),
              SizedBox(width: 10.w),
              _buildFilterButton('Apply', AppColors.info, AppColors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterField(String label) {
    return Container(
      height: 28.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: AppColors.grey50),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTextStyle.style_11_500(color: AppColors.black),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, Color bgColor, Color textColor, {Color? borderColor}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.r),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Text(
        label,
        style: AppTextStyle.style_10_600(color: textColor),
      ),
    );
  }

  Widget _buildCreateTaskButton() {
    return SizedBox(
      height: 32.h,
      child: ElevatedButton(
        onPressed: () {
          Get.toNamed(AppRoutes.createTask);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.info,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
        ),
        child: Text(
          'Create Task',
          style: AppTextStyle.style_12_600(color: AppColors.white),
        ),
      ),
    );
  }

  Widget _buildTabs(TasksController controller) {
    return Container(
      height: 38.h,
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Obx(() => Row(
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
      )),
    );
  }

  Widget _buildTabItem({required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : AppColors.transparent,
          borderRadius: BorderRadius.circular(6.r),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Center(
          child: Text(
            title,
            style: isSelected 
              ? AppTextStyle.style_13_600(color: AppColors.black)
              : AppTextStyle.style_13_500(color: AppColors.grey300),
          ),
        ),
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
