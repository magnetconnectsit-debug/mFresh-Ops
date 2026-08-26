import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_image_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:mfresh_ops/data/models/models.dart';

class TaskSubmissionDialog extends StatelessWidget {
  final TaskItem task;
  final bool isReview;
  final bool isReadOnly;

  const TaskSubmissionDialog({
    super.key,
    required this.task,
    this.isReview = false,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TasksController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 30.w),
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.transparent,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Block
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Task: ',
                                  style: AppTextStyle.style_12_700(color: const Color(0xFF0066FF)),
                                ),
                                TextSpan(
                                  text: task.title,
                                  style: AppTextStyle.style_12_700(color: AppColors.black),
                                ),
                              ],
                            ),
                          ),
                          if (task.description.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              task.description,
                              style: AppTextStyle.style_10_400(color: const Color(0xFF6C757D)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Padding(
                        padding: EdgeInsets.all(4.r),
                        child: Icon(Icons.close, size: 24.r, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),

              // Status indicator
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  task.status,
                  style: AppTextStyle.style_10_400(color: const Color(0xFF495057)),
                ),
              ),
              SizedBox(height: 12.h),

              // Attachments Section
              Text(
                'Attachments',
                style: AppTextStyle.style_12_700(color: AppColors.black),
              ),
              SizedBox(height: 8.h),
              Obx(
                () => Wrap(
                  spacing: 12.w,
                  runSpacing: 12.h,
                  children: [
                    ...controller.attachments.asMap().entries.map((entry) {
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.dialog(
                                Dialog(
                                  backgroundColor: Colors.transparent,
                                  surfaceTintColor: Colors.transparent,
                                  insetPadding: EdgeInsets.zero,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      GestureDetector(
                                        onTap: () => Get.back(),
                                        child: Container(color: Colors.black87),
                                      ),
                                      InteractiveViewer(
                                        child: Center(
                                          child: entry.value is String
                                              ? AppImageView(
                                                  imageUrl: entry.value,
                                                  fit: BoxFit.contain,
                                                )
                                              : Image.file(
                                                  entry.value is File ? entry.value : File(entry.value.path),
                                                  fit: BoxFit.contain,
                                                ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 40.h,
                                        right: 20.w,
                                        child: GestureDetector(
                                          onTap: () => Get.back(),
                                          child: CircleAvatar(
                                            backgroundColor: Colors.black45,
                                            child: Icon(Icons.close, color: Colors.white, size: 24.r),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 55.w,
                              height: 65.h,
                              decoration: BoxDecoration(
                                color: AppColors.grey50.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(4.r),
                                border: Border.all(
                                  color: AppColors.borderColor,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4.r),
                                child: entry.value is String
                                    ? AppImageView(
                                        imageUrl: entry.value,
                                        width: 55.w,
                                        height: 65.h,
                                        fit: BoxFit.cover,
                                        borderRadius: 4.r,
                                      )
                                    : Image.file(
                                        entry.value is File ? entry.value : File(entry.value.path),
                                        width: 55.w,
                                        height: 65.h,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                          if (!isReview && !isReadOnly)
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () => controller.removeAttachment(entry.key),
                                child: CircleAvatar(
                                  radius: 9.r,
                                  backgroundColor: AppColors.error,
                                  child: Icon(
                                    Icons.close,
                                    size: 10.r,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                    if (!isReview && !isReadOnly)
                      GestureDetector(
                        onTap: () => controller.pickImage(),
                        child: _buildUploadPlaceholder(),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),
              Text(
                'Comments',
                style: AppTextStyle.style_12_700(color: AppColors.black),
              ),
              SizedBox(height: 6.h),
              _buildCommentField(
                controller: controller.commentController,
                hintText: 'Enter Comments',
                enabled: !isReview && !isReadOnly,
                backgroundColor: (isReview || isReadOnly)
                    ? AppColors.grey50.withValues(alpha: 0.5)
                    : AppColors.white,
              ),

              SizedBox(height: 12.h),
              Text(
                'Approver Comments',
                style: AppTextStyle.style_12_700(color: AppColors.black),
              ),
              SizedBox(height: 6.h),
              _buildCommentField(
                controller: controller.approverCommentController,
                hintText: '',
                enabled: isReview && !isReadOnly,
                backgroundColor: (isReview && !isReadOnly) ? AppColors.white : const Color(0xFFF8F9FA),
              ),

              SizedBox(height: 16.h),
              if (!isReadOnly)
                Obx(
                  () => controller.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : (isReview
                          ? _buildReviewActions(controller)
                          : _buildSubmissionActions(controller)),
                ),
            ],
          ),
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
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: 2,
        style: AppTextStyle.style_10_400(color: AppColors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyle.style_10_400(color: AppColors.grey300),
          contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
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
    return CustomPaint(
      painter: DashedRectPainter(
        color: const Color(0xFFCED4DA),
        strokeWidth: 1.5,
        gap: 3,
      ),
      child: Container(
        width: 55.w,
        height: 65.h,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: const Color(0xFF6C757D), size: 16.r),
            SizedBox(height: 2.h),
            Text(
              'Upload',
              style: AppTextStyle.style_10_500(color: const Color(0xFF6C757D)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionActions(TasksController controller) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 32.h,
            child: ElevatedButton(
              onPressed: () => controller.submitTask(task, isUpdate: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC3545), // Red
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              child: Text(
                'Update',
                style: AppTextStyle.style_12_600(color: Colors.white),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: SizedBox(
            height: 32.h,
            child: ElevatedButton(
              onPressed: () => controller.submitTask(task),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF198754), // Green
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              child: Text(
                'Submit',
                style: AppTextStyle.style_12_600(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewActions(TasksController controller) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 32.h,
            child: ElevatedButton(
              onPressed: () => controller.rejectTask(task.taskInstanceId),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC3545), // Red
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              child: Text(
                'Reject',
                style: AppTextStyle.style_12_600(color: Colors.white),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: SizedBox(
            height: 32.h,
            child: ElevatedButton(
              onPressed: () => controller.approveTask(task.taskInstanceId),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF198754), // Green
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              child: Text(
                'Approve',
                style: AppTextStyle.style_12_600(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    this.color = const Color(0xFFADB5BD),
    this.strokeWidth = 1,
    this.gap = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double width = size.width;
    final double height = size.height;

    final Path path = Path();
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width, height),
      Radius.circular(6.r),
    ));

    final Path dashPath = Path();
    double distance = 0;
    for (final PathMetric measurePath in path.computeMetrics()) {
      while (distance < measurePath.length) {
        dashPath.addPath(
          measurePath.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
