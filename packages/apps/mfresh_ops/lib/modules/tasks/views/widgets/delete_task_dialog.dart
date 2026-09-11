import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';

class DeleteTaskDialog extends StatefulWidget {
  final TaskItem task;

  const DeleteTaskDialog({super.key, required this.task});

  @override
  State<DeleteTaskDialog> createState() => _DeleteTaskDialogState();
}

class _DeleteTaskDialogState extends State<DeleteTaskDialog> {
  String _deleteLevel = "0"; // "0" for This Task Only, "1" for Entire Task Series

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delete Task',
                  style: AppTextStyle.style_16_700(color: const Color(0xFFE25C5C)),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(
                    Icons.close,
                    size: 20.r,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'Select delete level:',
              style: AppTextStyle.style_12_600(color: AppColors.black),
            ),
            SizedBox(height: 10.h),
            
            // Radio Buttons
            Theme(
              data: Theme.of(context).copyWith(
                unselectedWidgetColor: Colors.grey.shade300,
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: Text(
                      'This Task Only',
                      style: AppTextStyle.style_12_500(color: AppColors.black),
                    ),
                    value: "0",
                    groupValue: _deleteLevel,
                    activeColor: const Color(0xFF0066FF),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _deleteLevel = value;
                        });
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(
                      'Entire Task Series.',
                      style: AppTextStyle.style_12_500(color: AppColors.black),
                    ),
                    value: "1",
                    groupValue: _deleteLevel,
                    activeColor: const Color(0xFF0066FF),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _deleteLevel = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 12.h),
            Divider(color: Colors.grey.shade300, height: 1),
            SizedBox(height: 12.h),
            
            Text(
              'Are you sure you want to delete?',
              style: AppTextStyle.style_12_600(color: const Color(0xFFE25C5C)),
            ),
            SizedBox(height: 20.h),
            
            // Actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    backgroundColor: Colors.grey.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  child: Text(
                    'No',
                    style: AppTextStyle.style_12_500(color: AppColors.black),
                  ),
                ),
                SizedBox(width: 12.w),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.find<TasksController>().deleteTaskInstance(
                      widget.task,
                      deleteLevel: _deleteLevel,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC3545),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  child: Text(
                    'Yes, Delete',
                    style: AppTextStyle.style_12_500(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
