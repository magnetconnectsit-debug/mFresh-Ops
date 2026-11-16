import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';

class AllTasksActionButtons extends StatelessWidget {
  final TasksController controller;

  const AllTasksActionButtons({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final userPermissions = Get.find<AuthRepository>().rxUserPermissions;
    final canCreateTask = userPermissions.contains('create_new_task');
    final canExportTask = userPermissions.contains('export_task');
    final canBulkDelete = userPermissions.contains('task_bulk_delete');

    return Row(
      children: [
        if (canCreateTask) ...[
          AppCommonButton(
            icon: Icons.add,
            iconColor: AppColors.white,
            text: 'Create Task',
            buttonColor: const Color(0xFF16A3B8),
            textColor: Colors.white,
            height: 21.h,
            textSize: 10.sp,
            borderRadius: 4.r,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            useGradient: false,
            onPressed: () {
              Get.find<TasksController>().formInitialized.value = false;
              Get.toNamed(AppRoutes.createTask);
            },
          ),
          SizedBox(width: 4.w),
        ],
        if (canExportTask)
          AppCommonExportButton(
            onExportExcel: () => controller.exportTasks(isPdf: false),
            onExportPdf: () => controller.exportTasks(isPdf: true),
          ),
        if (canBulkDelete)
          Obx(
            () => controller.selectedTaskInstanceIds.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: AppCommonButton(
                      text: 'Bulk Delete',
                      buttonColor: AppColors.red,
                      textColor: Colors.white,
                      height: 21.h,
                      textSize: 10.sp,
                      borderRadius: 4.r,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      useGradient: false,
                      onPressed: () => controller.bulkDeleteSelectedTasks(),
                    ),
                  )
                : const SizedBox.shrink(),
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
                icon: const SizedBox.shrink(),
                iconSize: 0.0,
                items: [10, 20, 50, 100, 500, 1000].map((int val) {
                  return DropdownMenuItem<int>(
                    value: val,
                    child: Text('$val/page'),
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
