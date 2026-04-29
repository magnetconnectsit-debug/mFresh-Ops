import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/create_ticket_controller.dart';
import 'package:models/common/assignee_model.dart';
import 'package:models/models.dart';
import 'package:core/widgets/app_common_drop_down.dart';

class CreateTicketScreen extends StatelessWidget {
  const CreateTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateTicketController());

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Create Ticket',
          style: AppTextStyle.style_18_700(color: AppColors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormGrid(context, controller),
              SizedBox(height: 16.h),
              _buildLabel('Subject'),
              SizedBox(height: 8.h),
              AppCommonTextField(
                controller: controller.subjectController,
                hintText: 'Subject Line',
                height: 44.h,
              ),
              SizedBox(height: 16.h),
              _buildLabel('Description'),
              SizedBox(height: 8.h),
              AppCommonTextField(
                controller: controller.descriptionController,
                hintText: 'Description here',
                maxLines: 4,
                height: 100.h,
              ),
              SizedBox(height: 20.h),
              _buildLabel('Attachments'),
              SizedBox(height: 12.h),
              _buildAttachmentsSection(controller),
              SizedBox(height: 40.h),
              _buildBottomActions(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: AppTextStyle.style_14_700(color: AppColors.black),
    );
  }

  Widget _buildFormGrid(BuildContext context, CreateTicketController controller) {
    return Obx(() => GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16.h,
      crossAxisSpacing: 20.w,
      childAspectRatio: 2.0, // Adjusted for dropdown title
      children: [
        _buildDateFormField(context, controller),
        AppCommonDropdown<SupportUnit>(
          title: 'Unit No.',
          hintText: 'Select Unit',
          value: controller.selectedUnit.value,
          items: controller.units.map((e) => DropdownMenuItem(value: e, child: Text(e.unitName))).toList(),
          onChanged: (val) => controller.selectedUnit.value = val,
          height: 36.h,
        ),
        AppCommonDropdown<SupportCategory>(
          title: 'Category',
          hintText: 'Select Category',
          value: controller.selectedCategory.value,
          items: controller.categories.map((e) => DropdownMenuItem(value: e, child: Text(e.categoryName))).toList(),
          onChanged: (val) => controller.onCategorySelected(val),
          height: 36.h,
        ),
        AppCommonDropdown<SupportSubCategory>(
          title: 'Sub-Category',
          hintText: 'Select Sub-Category',
          value: controller.selectedSubCategory.value,
          items: controller.subCategories.map((e) => DropdownMenuItem(value: e, child: Text(e.subCategoryName))).toList(),
          onChanged: (val) => controller.selectedSubCategory.value = val,
          height: 36.h,
        ),
        AppCommonDropdown<String>(
          title: 'Priority',
          hintText: 'Select Priority',
          value: controller.selectedPriority.value,
          items: controller.priorities.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => controller.selectedPriority.value = val,
          height: 36.h,
        ),
        AppCommonDropdown<SupportProject>(
          title: 'Project',
          hintText: 'Select Project',
          value: controller.selectedProject.value,
          items: controller.projects.map((e) => DropdownMenuItem(value: e, child: Text(e.projectName))).toList(),
          onChanged: (val) => controller.selectedProject.value = val,
          height: 36.h,
        ),
        AppCommonDropdown<AssigneeModel>(
          title: 'Assignee',
          hintText: 'Select Assignee',
          value: controller.selectedAssignee.value,
          items: controller.assignees.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
          onChanged: (val) => controller.selectedAssignee.value = val,
          height: 36.h,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reminder', style: AppTextStyle.style_12_500(color: AppColors.black300)),
            SizedBox(height: 8.h),
            AppCommonTextField(
              controller: controller.reminderController,
              hintText: 'Reminder',
              height: 36.h,
            ),
          ],
        ),
      ],
    ));
  }

  Widget _buildDateFormField(BuildContext context, CreateTicketController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Occurred', style: AppTextStyle.style_12_500(color: AppColors.black300)),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => controller.selectDate(context),
          child: Container(
            height: 36.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey100, width: 1.5),
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${controller.occurredDate.value.day}/${controller.occurredDate.value.month}/${controller.occurredDate.value.year}',
                  style: AppTextStyle.style_12_400(color: AppColors.black1),
                ),
                Icon(Icons.calendar_today_outlined, size: 16.r, color: AppColors.grey300),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildAttachmentsSection(CreateTicketController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => controller.selectedImages.isEmpty 
          ? _buildUploadPlaceholder(controller)
          : SizedBox(
              height: 100.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.selectedImages.length + 1,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (context, index) {
                  if (index == 0) return _buildUploadPlaceholder(controller, compact: true);
                  final imageIndex = index - 1;
                  return Stack(
                    children: [
                      Container(
                        width: 90.w,
                        height: 90.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          image: DecorationImage(
                            image: FileImage(File(controller.selectedImages[imageIndex].path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4.r,
                        right: 4.r,
                        child: GestureDetector(
                          onTap: () => controller.removeImage(imageIndex),
                          child: CircleAvatar(
                            radius: 10.r,
                            backgroundColor: AppColors.black.withValues(alpha: 0.5),
                            child: Icon(Icons.close, size: 12.r, color: AppColors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            )),
      ],
    );
  }

  Widget _buildUploadPlaceholder(CreateTicketController controller, {bool compact = false}) {
    return GestureDetector(
      onTap: () => _showImageSourceOptions(controller),
      child: Container(
        width: compact ? 90.w : double.infinity,
        height: 90.h,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.grey50, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, size: compact ? 24.r : 32.r, color: AppColors.grey300),
            SizedBox(height: 4.h),
            Text('Add Photos', style: AppTextStyle.style_11_600(color: AppColors.grey300)),
          ],
        ),
      ),
    );
  }

  void _showImageSourceOptions(CreateTicketController controller) {
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
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Get.back();
                controller.takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                controller.pickImages();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(CreateTicketController controller) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              side: BorderSide(color: AppColors.grey50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: Text('Cancel', style: AppTextStyle.style_14_600(color: AppColors.black)),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: ElevatedButton(
            onPressed: () => controller.createTicket(),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              elevation: 0,
            ),
            child: Text('Create', style: AppTextStyle.style_14_600(color: AppColors.white)),
          ),
        ),
      ],
    );
  }
}
