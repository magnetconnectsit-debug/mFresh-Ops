import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';

class CreateTaskDialog extends GetView<TasksController> {
  final TaskModel? task;
  const CreateTaskDialog({super.key, this.task});

  @override
  Widget build(BuildContext context) {
    final isEdit = task != null;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      backgroundColor: AppColors.white,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.r),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Task' : 'Create New Task',
                    style: AppTextStyle.style_18_700(color: AppColors.black),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, color: AppColors.grey400, size: 24.r),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              
              _buildTextField(label: 'Task Title', initialValue: task?.title),
              SizedBox(height: 12.h),
              _buildTextField(label: 'Description', initialValue: 'Water Spillage Signage for Interior in All Units.', maxLines: 3),
              SizedBox(height: 12.h),
              
              Row(
                children: [
                  Expanded(child: _buildDropdownField(label: 'Project', value: isEdit ? 'mFresh Operations' : null)),
                  SizedBox(width: 12.w),
                  Expanded(child: _buildDropdownField(label: 'Store (Unit)', value: isEdit ? 'Units_Puri' : null)),
                ],
              ),
              SizedBox(height: 12.h),
              
              Row(
                children: [
                  Expanded(child: _buildTextField(label: 'Security Group', initialValue: isEdit ? 'Samir Prasad Padhy' : null)),
                  SizedBox(width: 12.w),
                  Expanded(child: _buildDropdownField(label: 'Assignee')),
                ],
              ),
              SizedBox(height: 12.h),
              
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
              SizedBox(height: 12.h),
              
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
              SizedBox(height: 16.h),
              
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
              SizedBox(height: 8.h),
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
              SizedBox(height: 12.h),
              
              _buildTextField(label: 'Approver Name/ Team', initialValue: isEdit ? 'Operations Manager' : null),
              SizedBox(height: 20.h),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.grey100),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text('Cancel', style: AppTextStyle.style_14_600(color: AppColors.black)),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEdit ? AppColors.primaryVariant : AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        elevation: 0,
                      ),
                      child: Text(
                        isEdit ? 'Submit' : 'Create Task', 
                        style: AppTextStyle.style_14_600(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, String? initialValue, int maxLines = 1}) {
    return Container(
      height: maxLines > 1 ? null : 36.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.grey50),
      ),
      child: TextFormField(
        initialValue: initialValue,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: AppTextStyle.style_12_400(color: AppColors.grey300),
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: maxLines > 1 ? 10.h : 0),
          border: InputBorder.none,
        ),
        style: AppTextStyle.style_12_500(color: AppColors.black),
      ),
    );
  }

  Widget _buildDropdownField({required String label, String? value}) {
    return Container(
      height: 36.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
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
              style: AppTextStyle.style_12_500(color: value != null ? AppColors.black : AppColors.grey300),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: AppColors.grey300, size: 20.r),
        ],
      ),
    );
  }

  Widget _buildDateTimeField({required String label, IconData? icon, String? value}) {
    return Container(
      height: 36.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
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
              style: AppTextStyle.style_12_500(color: value != null ? AppColors.black : AppColors.grey300),
            ),
          ),
          Icon(icon ?? Icons.keyboard_arrow_down, color: AppColors.grey300, size: 18.r),
        ],
      ),
    );
  }

  Widget _buildSwitch(bool value, Function(bool) onChanged) {
    return Transform.scale(
      scale: 0.7,
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
            size: 16.r, 
            color: controller.isRecurring.value ? AppColors.primary : AppColors.grey300
          ),
          SizedBox(width: 4.w),
          Text(
            'Recurring Task', 
            style: AppTextStyle.style_11_600(
              color: controller.isRecurring.value ? AppColors.black : AppColors.grey300
            ),
          ),
        ],
      ),
    ));
  }
}
