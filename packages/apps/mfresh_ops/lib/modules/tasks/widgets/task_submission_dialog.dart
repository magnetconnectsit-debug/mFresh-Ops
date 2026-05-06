import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:core/widgets/custom_app_loader.dart';

class TaskSubmissionDialog extends StatelessWidget {
  final TaskItem task;
  final bool isReview;

  const TaskSubmissionDialog({
    super.key,
    required this.task,
    this.isReview = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TasksController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.transparent,
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Task: ${task.title}',
                    style: AppTextStyle.style_16_700(color: AppColors.black),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(Icons.close, size: 22.r, color: AppColors.black),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            
            Text('Attachments', style: AppTextStyle.style_14_700(color: AppColors.black)),
            SizedBox(height: 10.h),
            Obx(() => Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: [
                ...controller.attachments.asMap().entries.map((entry) {
                  return Stack(
                    children: [
                      Container(
                        width: 65.w,
                        height: 75.h,
                        decoration: BoxDecoration(
                          color: AppColors.grey50.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(color: AppColors.borderColor, style: BorderStyle.solid),
                          image: DecorationImage(
                            image: FileImage(entry.value),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (!isReview)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => controller.removeAttachment(entry.key),
                            child: CircleAvatar(
                              radius: 9.r,
                              backgroundColor: AppColors.error,
                              child: Icon(Icons.close, size: 10.r, color: AppColors.white),
                            ),
                          ),
                        ),
                    ],
                  );
                }),
                // Optionally show upload button even in review if that's what the image implies, 
                // but usually review is read-only. The image shows it, so I'll keep it.
                GestureDetector(
                  onTap: () => controller.pickImage(),
                  child: _buildUploadPlaceholder(),
                ),
              ],
            )),
            
            SizedBox(height: 16.h),
            Text('Comments', style: AppTextStyle.style_14_700(color: AppColors.black)),
            SizedBox(height: 8.h),
            _buildCommentField(
              controller: controller.commentController,
              hintText: 'Enter Comments',
              enabled: !isReview,
              backgroundColor: isReview ? AppColors.grey50.withValues(alpha: 0.5) : AppColors.white,
            ),
            
            if (isReview) ...[
              SizedBox(height: 16.h),
              Text('Approver Comments', style: AppTextStyle.style_14_700(color: AppColors.black)),
              SizedBox(height: 8.h),
              _buildCommentField(
                controller: controller.approverCommentController,
                hintText: 'Enter Comments',
                enabled: true,
                backgroundColor: AppColors.white,
              ),
            ],
            
            SizedBox(height: 20.h),
            Obx(() => isReview ? _buildReviewActions(controller) : _buildSubmissionActions(controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentField({
    required TextEditingController controller,
    required String hintText,
    bool enabled = true,
    Color backgroundColor = AppColors.white,
  }) {
    return Container(
      height: 36.h,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: AppTextStyle.style_12_400(color: AppColors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyle.style_12_400(color: AppColors.grey300),
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.r),
            borderSide: const BorderSide(color: AppColors.borderColor),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.r),
            borderSide: const BorderSide(color: AppColors.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.r),
            borderSide: const BorderSide(color: AppColors.borderColor),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return Container(
      width: 65.w,
      height: 75.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, color: AppColors.grey300, size: 24.r),
          Text(
            'Upload', 
            style: AppTextStyle.style_10_400(color: AppColors.grey300),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionActions(TasksController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(child: _buildOutlinedButton('Delete', () => controller.deleteTaskInstance(task), loading: controller.isLoading.value)),
        SizedBox(width: 4.w),
        Flexible(child: _buildOutlinedButton('Cancel', () => Get.back())),
        SizedBox(width: 4.w),
        Flexible(child: _buildButton('Update', const Color(0xFFFF5252), () => controller.submitTask(task, isUpdate: true), loading: controller.isLoading.value)),
        SizedBox(width: 4.w),
        Flexible(child: _buildButton('Submit', const Color(0xFF28A9E0), () => controller.submitTask(task), loading: controller.isLoading.value)),
      ],
    );
  }

  Widget _buildReviewActions(TasksController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(child: _buildButton('Reject', const Color(0xFFFF5252), () => controller.rejectTask(task.taskInstanceId), loading: controller.isLoading.value)),
        SizedBox(width: 12.w),
        Flexible(child: _buildButton('Approve', const Color(0xFF00D100), () => controller.approveTask(task.taskInstanceId), loading: controller.isLoading.value)),
      ],
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onTap, {bool loading = false}) {
    return SizedBox(
      height: 34.h,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          elevation: 0,
        ),
        child: loading 
          ? SizedBox(width: 14.r, height: 14.r, child: const CustomAppLoader(size: 14, color: AppColors.white))
          : FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text, 
                style: AppTextStyle.style_10_700(color: AppColors.white),
              ),
            ),
      ),
    );
  }

  Widget _buildOutlinedButton(String text, VoidCallback onTap, {bool loading = false}) {
    return SizedBox(
      height: 34.h,
      child: OutlinedButton(
        onPressed: loading ? null : onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          side: const BorderSide(color: AppColors.black),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
        ),
        child: loading
          ? SizedBox(width: 14.r, height: 14.r, child: const CustomAppLoader(size: 14, color: AppColors.primary))
          : FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text, 
                style: AppTextStyle.style_10_600(color: AppColors.black),
              ),
            ),
      ),
    );
  }
}
