import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:core/widgets/app_common_app_bar.dart';

class CreateTaskScreen extends GetView<TasksController> {
  const CreateTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskModel? task = Get.arguments;
    final isEdit = task != null;

    if (isEdit) {
      controller.titleController.text = task.title;
      controller.descriptionController.clear();
      controller.securityGroupController.text = 'Samir Prasad Padhy';
    } else {
      controller.titleController.clear();
      controller.descriptionController.clear();
      controller.securityGroupController.clear();
    }
    
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          isEdit ? 'Edit Task' : 'Create New Task',
          style: AppTextStyle.style_18_700(color: AppColors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCommonTextField(
              controller: controller.titleController,
              hintText: 'Task Title',
              titleText: 'Task Title',
            ),
            SizedBox(height: 16.h),
            AppCommonTextField(
              controller: controller.descriptionController,
              hintText: 'Description',
              titleText: 'Description',
              maxLines: 4,
              height: 100.h,
            ),
            SizedBox(height: 16.h),
            
            Row(
              children: [
                Expanded(child: _buildDropdownField(label: 'Project', value: isEdit ? 'mFresh Operations' : null)),
                SizedBox(width: 12.w),
                Expanded(child: _buildDropdownField(label: 'Store (Unit)', value: isEdit ? 'Units_Puri' : null)),
              ],
            ),
            SizedBox(height: 16.h),
            
            Row(
              children: [
                Expanded(
                  child: AppCommonTextField(
                    controller: controller.securityGroupController,
                    hintText: 'Security Group',
                    titleText: 'Security Group',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(child: _buildDropdownField(label: 'Assignee')),
              ],
            ),
            SizedBox(height: 16.h),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Start Date', style: AppTextStyle.style_11_600(color: AppColors.grey300)),
                      SizedBox(height: 4.h),
                      _buildDateTimeField(label: 'Date', icon: Icons.calendar_today, value: isEdit ? '12-Sep-25' : 'Select Date'),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Start Time', style: AppTextStyle.style_11_600(color: AppColors.grey300)),
                      SizedBox(height: 4.h),
                      _buildDateTimeField(label: 'Time', value: isEdit ? '08:00 AM' : 'Select Time'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('End Date', style: AppTextStyle.style_11_600(color: AppColors.grey300)),
                      SizedBox(height: 4.h),
                      _buildDateTimeField(label: 'Date', value: isEdit ? '12-Sep-25' : 'Select Date'),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('End Time', style: AppTextStyle.style_11_600(color: AppColors.grey300)),
                      SizedBox(height: 4.h),
                      _buildDateTimeField(label: 'Time', value: isEdit ? '09:00 AM' : 'Select Time'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Photo Required', style: AppTextStyle.style_13_600(color: AppColors.black)),
                Row(
                  children: [
                    Obx(() => _buildSwitch(
                      controller.photoRequired.value, 
                      (val) => controller.photoRequired.value = val
                    )),
                    SizedBox(width: 12.w),
                    _buildRecurringTask(),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Completion approval required', style: AppTextStyle.style_13_600(color: AppColors.black)),
                Obx(() => _buildSwitch(
                  controller.approvalRequired.value, 
                  (val) => controller.approvalRequired.value = val
                )),
              ],
            ),
            SizedBox(height: 20.h),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Approver Name/ Team', style: AppTextStyle.style_14_500(color: AppColors.black300)),
                SizedBox(height: 8.h),
                _buildDropdownField(label: 'Approver Name/ Team', value: isEdit ? 'Operations Manager' : null),
              ],
            ),
            SizedBox(height: 32.h),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.grey100),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text('Cancel', style: AppTextStyle.style_15_600(color: AppColors.black)),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEdit ? AppColors.info : AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      elevation: 0,
                    ),
                    child: Text(
                      isEdit ? 'Submit' : 'Create Task', 
                      style: AppTextStyle.style_15_600(color: AppColors.white),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({required String label, String? value}) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.grey50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              value ?? label,
              style: AppTextStyle.style_14_500(color: value != null ? AppColors.black : AppColors.grey300),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: AppColors.grey300, size: 24.r),
        ],
      ),
    );
  }

  Widget _buildDateTimeField({required String label, IconData? icon, String? value}) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.grey50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              value ?? label,
              style: AppTextStyle.style_14_500(color: value != null ? AppColors.black : AppColors.grey300),
            ),
          ),
          Icon(icon ?? Icons.keyboard_arrow_down, color: AppColors.grey300, size: 20.r),
        ],
      ),
    );
  }

  Widget _buildSwitch(bool value, Function(bool) onChanged) {
    return Transform.scale(
      scale: 0.8,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.white,
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.grey100,
        inactiveThumbColor: AppColors.white,
      ),
    );
  }

  Widget _buildRecurringTask() {
    return Obx(() => GestureDetector(
      onTap: () => controller.isRecurring.value = !controller.isRecurring.value,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sync, 
            size: 20.r, 
            color: controller.isRecurring.value ? AppColors.primary : AppColors.grey300
          ),
          SizedBox(width: 4.w),
          Text(
            'Recurring Task', 
            style: AppTextStyle.style_12_600(
              color: controller.isRecurring.value ? AppColors.black : AppColors.grey300
            ),
          ),
        ],
      ),
    ));
  }
}
