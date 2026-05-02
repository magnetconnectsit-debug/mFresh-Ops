import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/ticket_details_controller.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:core/widgets/app_common_drop_down.dart';

class EditTicketScreen extends StatelessWidget {
  const EditTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TicketDetailsController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        title: Text(
          'Edit Ticket #101',
          style: AppTextStyle.style_18_700(color: AppColors.primary),
        ),
        elevation: 0.5,
        backgroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('TICKET INFORMATION'),
                    _buildInformationCard(controller),
                    SizedBox(height: 20.h),
                    _buildSectionHeader('TICKET DETAILS'),
                    _buildDetailsCard(controller),
                    SizedBox(height: 20.h),
                    _buildSectionHeader('ATTACHMENTS'),
                    _buildAttachmentsCard(controller),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            _buildBottomActionButton(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
      child: Text(
        title,
        style: AppTextStyle.style_10_700(color: AppColors.grey200),
      ),
    );
  }

  Widget _buildInformationCard(TicketDetailsController controller) {
    return Obx(() {
      final detail = controller.ticketDetail.value;
      return Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(color: AppColors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            _buildRow(
              AppCommonDropdown<String>(
                title: 'Status',
                hintText: 'Select',
                value: controller.selectedStatus.value,
                items: controller.statusOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => controller.selectedStatus.value = v,
                height: 36.h,
              ),
              _buildReadOnlyField('Created By', detail?.createdBy.toString() ?? '-'),
            ),
            SizedBox(height: 12.h),
            _buildRow(
              AppCommonDropdown<String>(
                title: 'Priority',
                hintText: 'Select',
                value: controller.selectedPriority.value,
                items: controller.priorityOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => controller.selectedPriority.value = v,
                height: 36.h,
              ),
              _buildReadOnlyField('Created On', detail?.createdOn ?? '-'),
            ),
            SizedBox(height: 12.h),
            _buildRow(
              AppCommonDropdown<SupportCategory>(
                title: 'Category',
                hintText: 'Select',
                value: controller.selectedCategory.value,
                items: controller.categories.map((e) => DropdownMenuItem(value: e, child: Text(e.categoryName))).toList(),
                onChanged: (v) {
                  controller.selectedCategory.value = v;
                  if (v != null) controller.fetchSubCategories(v.categoryId);
                },
                height: 36.h,
              ),
              _buildReadOnlyField('Modified On', detail?.modifiedOn ?? '-'),
            ),
            SizedBox(height: 12.h),
            _buildRow(
              AppCommonDropdown<SupportSubCategory>(
                title: 'Sub Category',
                hintText: 'Select',
                value: controller.selectedSubCategory.value,
                items: controller.subCategories.map((e) => DropdownMenuItem(value: e, child: Text(e.subCategoryName))).toList(),
                onChanged: (v) => controller.selectedSubCategory.value = v,
                height: 36.h,
              ),
              _buildReadOnlyField('Resolved Status', detail?.status ?? '-'),
            ),
            SizedBox(height: 12.h),
            _buildRow(
              AppCommonDropdown<AssigneeModel>(
                title: 'Assignee',
                hintText: 'Select',
                value: controller.selectedAssignee.value,
                items: controller.assignees.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                onChanged: (v) => controller.selectedAssignee.value = v,
                height: 36.h,
              ),
              _buildReadOnlyField('Follow-up', detail?.followUp ?? '-'),
            ),
            SizedBox(height: 12.h),
            _buildRow(
              AppCommonDropdown<SupportUnit>(
                title: 'Unit',
                hintText: 'Select',
                value: controller.selectedUnit.value,
                items: controller.units.map((e) => DropdownMenuItem(value: e, child: Text(e.unitName))).toList(),
                onChanged: (v) => controller.selectedUnit.value = v,
                height: 36.h,
              ),
              _buildReadOnlyField('Ticket Age', detail?.tktAge ?? '-'),
            ),
            SizedBox(height: 12.h),
            _buildRow(
              AppCommonDropdown<SupportProject>(
                title: 'Project',
                hintText: 'Select',
                value: controller.selectedProject.value,
                items: controller.projects.map((e) => DropdownMenuItem(value: e, child: Text(e.projectName))).toList(),
                onChanged: (v) => controller.selectedProject.value = v,
                height: 36.h,
              ),
              _buildInputField('Link Ticket', TextEditingController()),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRow(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        SizedBox(width: 12.w),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildDetailsCard(TicketDetailsController controller) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: AppColors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          _buildInputField('Subject', controller.subjectController),
          SizedBox(height: 12.h),
          _buildInputField('Description', controller.descriptionController, maxLines: 5),
        ],
      ),
    );
  }

  Widget _buildAttachmentsCard(TicketDetailsController controller) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: AppColors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: controller.selectedImages.asMap().entries.map((entry) {
              return _buildAttachmentItem(
                entry.value.path.split('/').last, 
                onDelete: () => controller.removeImage(entry.key),
              );
            }).toList(),
          )),
          Obx(() => controller.selectedImages.isNotEmpty ? SizedBox(height: 12.h) : const SizedBox.shrink()),
          OutlinedButton.icon(
            onPressed: () => _showImagePickerOptions(controller),
            icon: Icon(Icons.add_photo_alternate, size: 18.r, color: AppColors.primary),
            label: Text('Add More Attachments', style: AppTextStyle.style_11_600(color: AppColors.primary)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePickerOptions(TicketDetailsController controller) {
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
            Container(
              width: 32.w,
              height: 3.h,
              decoration: BoxDecoration(color: AppColors.grey100, borderRadius: BorderRadius.circular(10.r)),
            ),
            SizedBox(height: 20.h),
            Text('Upload Attachment', style: AppTextStyle.style_16_700(color: AppColors.black)),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(Icons.camera_alt_rounded, 'Camera', () {
                  Get.back();
                  controller.captureImage();
                }),
                _buildPickerOption(Icons.photo_library_rounded, 'Gallery', () {
                  Get.back();
                  controller.pickImages();
                }),
              ],
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28.r, color: AppColors.primary),
          ),
          SizedBox(height: 10.h),
          Text(label, style: AppTextStyle.style_12_600(color: AppColors.black)),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem(String name, {required VoidCallback onDelete}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.link, size: 12.r, color: AppColors.primary),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              name, 
              style: AppTextStyle.style_9_400(color: AppColors.black),
              overflow: TextOverflow.visible,
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close, size: 14.r, color: AppColors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        label,
        style: AppTextStyle.style_11_500(color: AppColors.black300),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        AppCommonTextField(
          controller: ctrl,
          hintText: 'Enter $label',
          maxLines: maxLines,
          height: maxLines > 1 ? null : 36.h,
          style: AppTextStyle.style_11_400(color: AppColors.black1),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        Container(
          width: double.infinity,
          height: 36.h,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              value,
              style: AppTextStyle.style_11_400(color: AppColors.grey400),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildBottomActionButton(TicketDetailsController controller) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                side: const BorderSide(color: AppColors.black12),
              ),
              child: Text('Cancel', style: AppTextStyle.style_12_600(color: AppColors.black)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () => controller.saveTicket(),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                backgroundColor: AppColors.success,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                elevation: 0,
              ),
              child: Text('Update Ticket', style: AppTextStyle.style_12_600(color: AppColors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
