import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_image_view.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mfresh_ops/data/models/models.dart';

class TaskReviewScreen extends GetView<TasksController> {
  const TaskReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskItem task = Get.arguments;
    final bool isApproverView =
        task.status.toLowerCase() == 'review' ||
        task.status.toLowerCase() == 'pending';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Task: ${task.title}',
          style: AppTextStyle.style_18_700(color: AppColors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attachments',
              style: AppTextStyle.style_14_600(color: AppColors.black),
            ),
            SizedBox(height: 12.h),
            Obx(
              () => Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children: [
                  ...controller.attachments.asMap().entries.map((entry) {
                    return _buildImageItem(
                      entry.value,
                      () => controller.removeAttachment(entry.key),
                    );
                  }),
                  if (controller.attachments.length < 5)
                    _buildUploadPlaceholder(),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            AppCommonTextField(
              controller: TextEditingController(
                text: isApproverView ? 'Both Mirror are cleaned.' : '',
              ),
              hintText: 'Enter Comments',
              titleText: 'Comments',
              maxLines: 3,
              height: 80.h,
              style: isApproverView
                  ? AppTextStyle.style_14_400(color: AppColors.grey400)
                  : null,
            ),
            SizedBox(height: 24.h),

            if (isApproverView) ...[
              AppCommonTextField(
                controller: TextEditingController(),
                hintText: 'Enter Comments',
                titleText: 'Approver Comments',
                maxLines: 3,
                height: 80.h,
              ),
              SizedBox(height: 40.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        elevation: 0,
                      ),
                      child: Text(
                        'Reject',
                        style: AppTextStyle.style_15_600(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        elevation: 0,
                      ),
                      child: Text(
                        'Approve',
                        style: AppTextStyle.style_15_600(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(height: 24.h),
              Row(
                children: [
                  _buildSmallButton(
                    'Delete',
                    AppColors.grey50,
                    AppColors.black,
                    () {},
                  ),
                  SizedBox(width: 8.w),
                  _buildSmallButton(
                    'Cancel',
                    AppColors.grey50,
                    AppColors.black,
                    () => Get.back(),
                  ),
                  SizedBox(width: 8.w),
                  _buildSmallButton(
                    'Update',
                    AppColors.red,
                    AppColors.white,
                    () {},
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        elevation: 0,
                      ),
                      child: Text(
                        'Submit',
                        style: AppTextStyle.style_14_600(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(dynamic item, VoidCallback onDelete) {
    final bool isUrl = item is String;
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: SizedBox(
            width: 80.w,
            height: 80.w,
            child: isUrl
                ? AppImageView(
                    imageUrl: item,
                    width: 80.w,
                    height: 80.w,
                    fit: BoxFit.cover,
                    borderRadius: 8.r,
                  )
                : Image.file(
                    item is File ? item : File(item.path),
                    width: 80.w,
                    height: 80.w,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        Positioned(
          top: 4.r,
          right: 4.r,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: EdgeInsets.all(2.r),
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 12.r, color: AppColors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPlaceholder() {
    return GestureDetector(
      onTap: () => _showImagePickerOptions(),
      child: Container(
        width: 80.w,
        height: 80.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: AppColors.grey100,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.grey300, size: 24.r),
            SizedBox(height: 4.h),
            Text(
              'Upload',
              style: AppTextStyle.style_10_400(color: AppColors.grey300),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Image Source',
              style: AppTextStyle.style_16_600(color: AppColors.black),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  Icons.camera_alt,
                  'Camera',
                  ImageSource.camera,
                ),
                _buildPickerOption(
                  Icons.photo_library,
                  'Gallery',
                  ImageSource.gallery,
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption(IconData icon, String label, ImageSource source) {
    return InkWell(
      onTap: () {
        Get.back();
        controller.pickImage(source);
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 30.r),
          ),
          SizedBox(height: 8.h),
          Text(label, style: AppTextStyle.style_14_500(color: AppColors.black)),
        ],
      ),
    );
  }

  Widget _buildSmallButton(
    String text,
    Color bgColor,
    Color textColor,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        minimumSize: Size(0, 44.h),
      ),
      child: Text(text, style: AppTextStyle.style_12_600(color: textColor)),
    );
  }
}
