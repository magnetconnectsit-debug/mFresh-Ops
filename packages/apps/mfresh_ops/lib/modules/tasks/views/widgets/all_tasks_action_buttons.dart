import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:mfresh_ops/routes/app_routes.dart';

class AllTasksActionButtons extends StatelessWidget {
  final TasksController controller;

  const AllTasksActionButtons({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 24.h,
          child: ElevatedButton(
            onPressed: () {
              Get.find<TasksController>().formInitialized.value = false;
              Get.toNamed(AppRoutes.createTask);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A3B8),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
              elevation: 1,
            ),
            child: Text('Create Task', style: AppTextStyle.style_12_500(color: Colors.white)),
          ),
        ),
        SizedBox(width: 8.w),
        SizedBox(
          height: 24.h,
          child: ElevatedButton(
            onPressed: () => controller.exportTasks(isPdf: false),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF389D6A),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
              elevation: 1,
            ),
            child: Text('Export Excel', style: AppTextStyle.style_12_500(color: Colors.white)),
          ),
        ),
        const Spacer(),
        Obx(
          () => Container(
            height: 24.h,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: controller.perPage.value,
                dropdownColor: Colors.white,
                style: AppTextStyle.style_12_500(color: AppColors.black),
                icon: Icon(
                  Icons.arrow_drop_down,
                  size: 16.r,
                  color: Colors.grey.shade600,
                ),
                items: [10, 20, 50, 100].map((int val) {
                  return DropdownMenuItem<int>(
                    value: val,
                    child: Text('$val per page'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    controller.setPerPage(val);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
