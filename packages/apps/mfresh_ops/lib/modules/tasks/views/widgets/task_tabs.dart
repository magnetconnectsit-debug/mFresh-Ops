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
      height: 36.h,
      padding: EdgeInsets.all(3.r),
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
