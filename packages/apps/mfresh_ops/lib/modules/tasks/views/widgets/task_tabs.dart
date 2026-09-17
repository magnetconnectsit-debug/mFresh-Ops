import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';

class TaskTabs extends StatelessWidget {
  final TasksController controller;

  const TaskTabs({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.h,
      padding: EdgeInsets.all(2.r),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E5E9),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: const Color(0xFFDEE2E6)),
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
            SizedBox(width: 6.w),
            Container(
              height: 28.h,
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(color: const Color(0xFFCED4DA)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Tooltip(
                    message: 'Detail View',
                    child: InkWell(
                      onTap: () => controller.isListView.value = false,
                      borderRadius: BorderRadius.circular(3.r),
                      child: Container(
                        padding: EdgeInsets.all(3.r),
                        decoration: BoxDecoration(
                          color: !controller.isListView.value
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                        child: Icon(
                          Icons.view_day_outlined,
                          size: 15.r,
                          color: !controller.isListView.value
                              ? AppColors.primary
                              : const Color(0xFF6C757D),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Tooltip(
                    message: 'List View',
                    child: InkWell(
                      onTap: () => controller.isListView.value = true,
                      borderRadius: BorderRadius.circular(3.r),
                      child: Container(
                        padding: EdgeInsets.all(3.r),
                        decoration: BoxDecoration(
                          color: controller.isListView.value
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                        child: Icon(
                          Icons.format_list_bulleted_rounded,
                          size: 15.r,
                          color: controller.isListView.value
                              ? AppColors.primary
                              : const Color(0xFF6C757D),
                        ),
                      ),
                    ),
                  ),
                ],
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
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(4.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
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
                : AppTextStyle.style_11_500(color: const Color(0xFF6C757D)),
          ),
        ),
      ),
    );
  }
}
