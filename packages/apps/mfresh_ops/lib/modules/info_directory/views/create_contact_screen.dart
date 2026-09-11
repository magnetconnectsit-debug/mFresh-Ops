import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:core/core.dart';

import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/create_contact_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';

class CreateContactScreen extends StatelessWidget {
  const CreateContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateContactController());

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CommonSidebar(),
      appBar: PreferredSize(
        preferredSize: const AppCommonAppBar().preferredSize,
        child: Obx(
          () => AppCommonAppBar(
            title: Text(controller.isEdit.value ? 'Edit Contact' : 'Create Contact'),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
          child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => MultiSelectDropdownWidget<String>(
                          label: 'Contact Type',
                          isSingleSelect: true,
                          showSearch: true,
                          selectedValues: controller.selectedContactType.value == null
                              ? <String>{}
                              : {controller.selectedContactType.value!},
                          items: controller.availableContactTypes
                              .map((e) => DropdownMenuItem<String>(
                                    value: e,
                                    child: Text(
                                      e,
                                      style: AppTextStyle.style_12_400(color: AppColors.grey900),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (values) => controller.selectedContactType.value = values.isEmpty ? null : values.first,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildTextField(controller: controller.nameCtrl, label: 'Name*')),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => MultiSelectDropdownWidget<String>(
                          label: 'Brand',
                          isSingleSelect: true,
                          showSearch: true,
                          selectedValues: controller.selectedBrand.value == null
                              ? <String>{}
                              : {controller.selectedBrand.value!},
                          items: controller.availableBrands
                              .map((e) => DropdownMenuItem<String>(
                                    value: e['id'].toString(),
                                    child: Text(
                                      e['name']?.toString() ?? '',
                                      style: AppTextStyle.style_12_400(color: AppColors.grey900),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (values) => controller.selectedBrand.value = values.isEmpty ? null : values.first,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Obx(
                        () => MultiSelectDropdownWidget<String>(
                          label: 'Company',
                          isSingleSelect: true,
                          showSearch: true,
                          selectedValues: controller.selectedCompany.value == null
                              ? <String>{}
                              : {controller.selectedCompany.value!},
                          items: controller.availableCompanies
                              .map((e) => DropdownMenuItem<String>(
                                    value: e['id'].toString(),
                                    child: Text(
                                      e['name']?.toString() ?? '',
                                      style: AppTextStyle.style_12_400(color: AppColors.grey900),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (values) => controller.selectedCompany.value = values.isEmpty ? null : values.first,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controller: controller.workedOnCtrl, label: 'Worked On')),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildTextField(controller: controller.gstinCtrl, label: 'GST IN')),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controller: controller.designationCtrl, label: 'Designation')),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildTextField(controller: controller.departmentCtrl, label: 'Department')),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(child: _buildTextField(
                      controller: controller.mobile1Ctrl, 
                      label: 'Mobile 1*',
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Mobile 1 is required';
                        }
                        if (!RegExp(r'^\d{10}$').hasMatch(val.trim())) {
                          return 'Enter valid 10-digit number';
                        }
                        return null;
                      },
                    )),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildTextField(
                      controller: controller.mobile2Ctrl, 
                      label: 'Mobile 2',
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      validator: (val) {
                        if (val != null && val.trim().isNotEmpty) {
                          if (!RegExp(r'^\d{10}$').hasMatch(val.trim())) {
                            return 'Enter valid 10-digit number';
                          }
                        }
                        return null;
                      },
                    )),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controller: controller.emailCtrl, label: 'Email')),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Obx(
                        () => MultiSelectDropdownWidget<String>(
                          label: 'Level*',
                          isSingleSelect: true,
                          showSearch: true,
                          selectedValues: controller.selectedLevel.value == null
                              ? <String>{}
                              : {controller.selectedLevel.value!},
                          items: ['1', '2', '3']
                              .map((e) => DropdownMenuItem<String>(
                                    value: e,
                                    child: Text(
                                      'Level $e',
                                      style: AppTextStyle.style_12_400(color: AppColors.grey900),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (values) => controller.selectedLevel.value = values.isEmpty ? null : values.first,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                _buildTextField(controller: controller.typeServiceCtrl, label: 'Type Service*'),
                SizedBox(height: 16.h),
                _buildTextField(controller: controller.locationCtrl, label: 'Location'),
                SizedBox(height: 16.h),
                _buildTextField(controller: controller.addressCtrl, label: 'Address'),
                SizedBox(height: 16.h),
                _buildTextField(controller: controller.websiteLinksCtrl, label: 'Website Links'),
                SizedBox(height: 16.h),
                _buildTextField(controller: controller.commentCtrl, label: 'Comment/Description', maxLines: 2),
                SizedBox(height: 16.h),
                
                // Attach Files
                Text('Attach Files', style: AppTextStyle.style_12_700(color: AppColors.black)),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: controller.pickFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.grey.shade300),
                        elevation: 0,
                      ),
                      child: const Text('Choose file'),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Obx(() {
                  if (controller.selectedFiles.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: List.generate(
                          controller.selectedFiles.length,
                          (i) => _buildFileChip(controller, i),
                        ),
                      ),
                    ],
                  );
                }),
                SizedBox(height: 32.h),
                
                // Submit Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 30.h,
                      width: 80.w,
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.borderColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTextStyle.style_12_600(color: AppColors.black),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Obx(() => SizedBox(
                      height: 30.h,
                      width: 80.w,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value ? null : controller.submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D6EFD),
                          disabledBackgroundColor: const Color(0xFF0D6EFD).withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          padding: EdgeInsets.zero,
                          elevation: 0,
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Submit',
                                style: AppTextStyle.style_12_600(color: AppColors.white),
                              ),
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      keyboardType: keyboardType,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        label: RichText(
          text: TextSpan(
            text: label.replaceAll('*', ''),
            style: AppTextStyle.style_12_400(color: AppColors.grey200),
            children: label.contains('*')
                ? [
                    const TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red),
                    )
                  ]
                : [],
          ),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        counterText: '',
        contentPadding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: maxLines > 1 ? 6.h : 4.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: const BorderSide(color: Color(0xffF15A24), width: 1.5),
        ),
        isDense: true,
      ),
      style: AppTextStyle.style_12_400(color: AppColors.grey900),
    );
  }

  Widget _buildFileChip(CreateContactController controller, int index) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, size: 14.sp, color: AppColors.grey900),
          SizedBox(width: 4.w),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 120.w),
            child: Text(
              controller.selectedFileNames[index],
              style: AppTextStyle.style_12_400(color: AppColors.grey900),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: () => controller.removeFile(index),
            child: Icon(Icons.close, size: 14.sp, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
