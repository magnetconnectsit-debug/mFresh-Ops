import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import '../controllers/support_template_controller.dart';

import 'package:core/widgets/app_common_textfield.dart';

class CreateTemplateScreen extends StatelessWidget {
  const CreateTemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SupportTemplateController>();

    return Obx(() {
      final isEditing = controller.isEditing.value;
      final titleText = isEditing ? 'Edit Template' : 'Add Template';

      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppCommonAppBar(
          backgroundColor: AppColors.white,
          hasBackButton: true,
          topHeader: const CommonShortcutHeader(),
          onBackButtonPressed: () {
            controller.isFormScreenOpen.value = false;
            controller.clearControllers();
            Get.back();
          },
          title: Text(
            titleText,
            style: AppTextStyle.style_18_700(color: AppColors.black),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller.templateNameController,
                label: 'Template Name*',
                hint: 'Enter Template Name',
              ),
              SizedBox(height: 10.h),
              _buildTextField(
                controller.descriptionController,
                label: 'Description*',
                hint: 'Enter Description',
                maxLines: 4,
              ),
              SizedBox(height: 14.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtasks',
                    style: AppTextStyle.style_12_600(color: AppColors.grey900),
                  ),
                  InkWell(
                    onTap: () => controller.addSubtaskField(),
                    borderRadius: BorderRadius.circular(4.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add, size: 14.r, color: AppColors.primary),
                          SizedBox(width: 2.w),
                          Text(
                            'Add Subtask',
                            style: AppTextStyle.style_12_500(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Obx(
                () => Column(
                  children: controller.subtaskControllers.asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final subController = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              subController,
                              label: 'Subtask ${index + 1}',
                              hint: 'Enter subtask',
                            ),
                          ),
                          SizedBox(width: 6.w),
                          InkWell(
                            onTap: () => controller.removeSubtaskField(index),
                            child: Padding(
                              padding: EdgeInsets.all(4.r),
                              child: Icon(
                                Icons.delete_outline,
                                color: AppColors.red,
                                size: 18.r,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppCommonButton(
                    text: 'Cancel',
                    buttonColor: Colors.transparent,
                    textColor: AppColors.grey300,
                    borderColor: AppColors.grey300,
                    onPressed: () {
                      controller.isFormScreenOpen.value = false;
                      controller.clearControllers();
                      Get.back();
                    },
                  ),
                  SizedBox(width: 8.w),
                  AppCommonButton(
                    text: 'Submit',
                    onPressed: () async {
                      final success = await controller.submitForm();
                      if (success) {
                        Get.back();
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    ),
  );
});
}

  Widget _buildTextField(
    TextEditingController controller, {
    required String label,
    String? hint,
    int maxLines = 1,
    bool hasError = false,
  }) {
    return AppCommonTextField(
      controller: controller,
      labelText: label,
      hintText: hint ?? '',
      maxLines: maxLines,
      isRequired: label.contains('*'),
      style: AppTextStyle.style_12_500(color: AppColors.grey900),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 6.w,
        vertical: maxLines == 1 ? 3.h : 6.h,
      ),
      borderRadius: 4.r,
    );
  }
}
