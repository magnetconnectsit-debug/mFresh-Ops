// region Imports
import 'dart:io';
import 'dart:ui';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:core/widgets/app_image_view.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
// endregion

// region TaskSubmissionDialog Widget
class TaskSubmissionDialog extends StatelessWidget {
  // region Properties & Constructor
  final TaskItem task;
  final bool isReview;
  final bool isReadOnly;

  const TaskSubmissionDialog({
    super.key,
    required this.task,
    this.isReview = false,
    this.isReadOnly = false,
  });
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TasksController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 30.w),
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
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
                    border: Border.all(color: AppColors.grey200),
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
                                    style: AppTextStyle.style_12_700(
                                      color: const Color(0xFF0066FF),
                                    ),
                                  ),
                                  TextSpan(
                                    text: task.title,
                                    style: AppTextStyle.style_12_700(
                                      color: AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (task.description.isNotEmpty) ...[
                              SizedBox(height: 4.h),
                              Text(
                                task.description,
                                style: AppTextStyle.style_10_400(
                                  color: const Color(0xFF6C757D),
                                ),
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
                          child: Icon(
                            Icons.close,
                            size: 24.r,
                            color: AppColors.grey700,
                          ),
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
                    border: Border.all(color: AppColors.grey200),
                  ),
                  child: Text(
                    task.status,
                    style: AppTextStyle.style_10_400(
                      color: const Color(0xFF495057),
                    ),
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
                  () => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...controller.attachments.asMap().entries.map((entry) {
                          return Padding(
                            padding: EdgeInsets.only(right: 12.w),
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    final pageController = PageController(
                                      initialPage: entry.key,
                                    );
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
                                              child: Container(
                                                color: Colors.black87,
                                              ),
                                            ),
                                            PageView.builder(
                                              controller: pageController,
                                              itemCount: controller.attachments.length,
                                              itemBuilder: (context, index) {
                                                final attachment =
                                                    controller.attachments[index];
                                                return InteractiveViewer(
                                                  child: Center(
                                                    child: attachment is String
                                                        ? AppImageView(
                                                            imageUrl: attachment,
                                                            fit: BoxFit.contain,
                                                          )
                                                        : Image.file(
                                                            attachment is File
                                                                ? attachment
                                                                : File(attachment.path),
                                                            fit: BoxFit.contain,
                                                          ),
                                                  ),
                                                );
                                              },
                                            ),
                                            Positioned(
                                              top: 40.h,
                                              right: 20.w,
                                              child: GestureDetector(
                                                onTap: () => Get.back(),
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.black45,
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 24.r,
                                                  ),
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
                                              entry.value is File
                                                  ? entry.value
                                                  : File(entry.value.path),
                                              width: 55.w,
                                              height: 65.h,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                ),
                                if (!isReadOnly &&
                                    (entry.value is! String || !isReview))
                                  Positioned(
                                    top: 2.r,
                                    right: 2.r,
                                    child: GestureDetector(
                                      onTap: () =>
                                          controller.removeAttachment(entry.key),
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
                            ),
                          );
                        }),
                        if (!isReadOnly)
                          GestureDetector(
                            onTap: () => controller.pickImage(ImageSource.camera),
                            child: _buildUploadPlaceholder(),
                          ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 14.h),
                _buildCommentField(
                  controller: controller.commentController,
                  label: 'Comments',
                  enabled: !isReview && !isReadOnly,
                ),

                SizedBox(height: 14.h),
                _buildCommentField(
                  controller: controller.approverCommentController,
                  label: 'Approver Comments',
                  enabled: isReview && !isReadOnly,
                ),

                SizedBox(height: 16.h),
                if (!isReadOnly)
                  Obx(
                    () => controller.isLoading.value
                        ? const Center(child: CustomAppLoader())
                        : (isReview
                            ? _buildReviewActions(controller)
                            : _buildSubmissionActions(controller)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // endregion

  // region Helper Widgets & Sections
  Widget _buildCommentField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
  }) {
    return AppCommonTextField(
      controller: controller,
      labelText: label,
      hintText: 'Enter $label',
      enabled: enabled,
      maxLines: 4,
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
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AppCommonButton(
          text: 'Update',
          height: 26.h,
          width: 84.w,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          useGradient: false,
          buttonColor: const Color(0xFFDC3545),
          onPressed: () => controller.submitTask(task, isUpdate: true),
        ),
        SizedBox(width: 12.w),
        AppCommonButton(
          text: 'Submit',
          height: 26.h,
          width: 84.w,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          useGradient: false,
          buttonColor: const Color(0xFF198754),
          onPressed: () => controller.submitTask(task),
        ),
      ],
    );
  }

  Widget _buildReviewActions(TasksController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AppCommonButton(
          text: 'Reject',
          height: 26.h,
          width: 84.w,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          useGradient: false,
          buttonColor: const Color(0xFFDC3545),
          onPressed: () => controller.rejectTask(task.taskInstanceId),
        ),
        SizedBox(width: 12.w),
        AppCommonButton(
          text: 'Approve',
          height: 26.h,
          width: 84.w,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          useGradient: false,
          buttonColor: const Color(0xFF198754),
          onPressed: () => controller.approveTask(task.taskInstanceId),
        ),
      ],
    );
  }
  // endregion
}
// endregion

// region DashedRectPainter
class DashedRectPainter extends CustomPainter {
  // region Properties & Constructor
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    this.color = const Color(0xFFADB5BD),
    this.strokeWidth = 1,
    this.gap = 4,
  });
  // endregion

  // region Paint & Repaint Methods
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double width = size.width;
    final double height = size.height;

    final Path path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width, height),
        Radius.circular(6.r),
      ),
    );

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
  // endregion
}
// endregion
