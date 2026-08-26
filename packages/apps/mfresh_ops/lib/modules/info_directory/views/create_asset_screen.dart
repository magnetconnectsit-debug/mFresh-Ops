import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/create_asset_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';

class CreateAssetScreen extends StatelessWidget {
  const CreateAssetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateAssetController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const AppCommonAppBar().preferredSize,
        child: AppCommonAppBar(
          title: Obx(
            () => Text(
              controller.isEdit.value ? 'Update Asset' : 'Create Asset',
              style: AppTextStyle.style_18_700(color: AppColors.black),
            ),
          ),
          hasBackButton: true,
          showAppDrawer: false,
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
                  // Item | Item Type
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          ctrl: controller.itemCtrl,
                          label: 'Item',
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: SizedBox(
                          height: 32.h,
                          child: Obx(
                            () => MultiSelectDropdownWidget<String>(
                              label: 'Item Type',
                              isSingleSelect: true,
                              selectedValues:
                                  controller.selectedItemType.value == null
                                  ? {}
                                  : {controller.selectedItemType.value!},
                              items: controller.availableItemTypes
                                    .map(
                                      (e) => DropdownMenuItem<String>(
                                        value: e['value']!,
                                        child: Text(
                                          e['label']!,
                                          style: AppTextStyle.style_12_400(
                                            color: AppColors.grey900,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              onChanged: (v) =>
                                  controller.selectedItemType.value = v.isEmpty
                                  ? null
                                  : v.first,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Brand | Model
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          ctrl: controller.brandCtrl,
                          label: 'Brand',
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildTextField(
                          ctrl: controller.modelCtrl,
                          label: 'Model',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Serial No | Project
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 32.h,
                          child: _buildTextField(
                            ctrl: controller.serialNoCtrl,
                            label: 'Serial No',
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: SizedBox(
                          height: 32.h,
                          child: Obx(
                            () => MultiSelectDropdownWidget<String>(
                              label: 'Project',
                              isSingleSelect: true,
                              selectedValues:
                                  controller.selectedProject.value == null
                                  ? {}
                                  : {controller.selectedProject.value!},
                              items: controller.availableProjects
                                  .map(
                                    (e) => DropdownMenuItem<String>(
                                      value: e['project']?.toString() ?? '',
                                      child: Text(
                                        e['project']?.toString() ?? '',
                                        style: AppTextStyle.style_12_400(
                                          color: AppColors.grey900,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  controller.selectedProject.value = v.isEmpty
                                  ? null
                                  : v.first,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Warranty Expiry Date | Warranty Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 32.h,
                          child: Obx(
                            () => GestureDetector(
                              onTap: () => controller.selectWarrantyExpiryDate(context),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Warranty Expiry Date',
                                  labelStyle: AppTextStyle.style_12_400(
                                    color: AppColors.grey200,
                                  ),
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 4.h,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4.r),
                                    borderSide: const BorderSide(color: AppColors.borderColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4.r),
                                    borderSide: const BorderSide(color: AppColors.borderColor),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        controller.selectedWarrantyExpiry.value == null
                                            ? 'Select Date'
                                            : AppDateUtils.formatToOrdinalDate(controller.selectedWarrantyExpiry.value!),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: controller.selectedWarrantyExpiry.value != null
                                            ? AppTextStyle.style_12_400(color: AppColors.grey900).copyWith(fontSize: 11.sp)
                                            : AppTextStyle.style_12_400(color: AppColors.grey300).copyWith(fontSize: 11.sp),
                                      ),
                                    ),
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14.sp,
                                      color: AppColors.grey200,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: SizedBox(
                          height: 32.h,
                          child: Obx(
                            () => MultiSelectDropdownWidget<String>(
                              label: 'Warranty Status',
                              isSingleSelect: true,
                              selectedValues:
                                  controller.selectedWarrantyStatus.value ==
                                      null
                                  ? {}
                                  : {controller.selectedWarrantyStatus.value!},
                              items: controller.availableWarrantyStatuses
                                  .map(
                                    (e) => DropdownMenuItem<String>(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: AppTextStyle.style_12_400(
                                          color: AppColors.grey900,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  controller.selectedWarrantyStatus.value =
                                      v.isEmpty ? null : v.first,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Location | Unit
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          ctrl: controller.locationCtrl,
                          label: 'Location',
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildTextField(
                          ctrl: controller.unitCtrl,
                          label: 'Unit',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Position | Vendor
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          ctrl: controller.positionCtrl,
                          label: 'Position',
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildTextField(
                          ctrl: controller.vendorCtrl,
                          label: 'Vendor',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Qty | Invoice Attachments
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          ctrl: controller.qtyCtrl,
                          label: 'Qty',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildChooseFilesButton(
                              label: 'Invoice Attachments',
                              onTap: () => controller.pickFiles(
                                controller.invoiceFiles,
                                controller.invoiceFileNames,
                              ),
                            ),
                            Obx(
                              () => _buildFileChips(
                                controller.invoiceFiles,
                                controller.invoiceFileNames,
                                controller,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Warranty Attachments | Others Attachments
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildChooseFilesButton(
                              label: 'Warranty Attachments',
                              onTap: () => controller.pickFiles(
                                controller.warrantyFiles,
                                controller.warrantyFileNames,
                              ),
                            ),
                            Obx(
                              () => _buildFileChips(
                                controller.warrantyFiles,
                                controller.warrantyFileNames,
                                controller,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildChooseFilesButton(
                              label: 'Others Attachments',
                              onTap: () => controller.pickFiles(
                                controller.othersFiles,
                                controller.othersFileNames,
                              ),
                            ),
                            Obx(
                              () => _buildFileChips(
                                controller.othersFiles,
                                controller.othersFileNames,
                                controller,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Description
                  _buildTextField(
                    ctrl: controller.descriptionCtrl,
                    label: 'Description (Vendor Details)',
                    maxLines: 2,
                  ),
                  SizedBox(height: 10.h),

                  // Specification
                  _buildTextField(
                    ctrl: controller.specificationCtrl,
                    label: 'Specification',
                    maxLines: 2,
                  ),
                  SizedBox(height: 32.h),

                  // Cancel | Submit buttons
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 30.h,
                        width: 80.w,
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.borderColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTextStyle.style_12_600(
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Obx(
                        () => SizedBox(
                          height: 30.h,
                          width: 80.w,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B35),
                              disabledBackgroundColor: const Color(
                                0xFFFF6B35,
                              ).withValues(alpha: 0.6),
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
                                    style: AppTextStyle.style_12_600(
                                      color: AppColors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
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
    required TextEditingController ctrl,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    TextStyle? style,
  }) {
    return SizedBox(
      height: maxLines == 1 ? 32.h : null,
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        textAlignVertical: TextAlignVertical.center,
        style: style ?? AppTextStyle.style_12_400(color: AppColors.grey900),
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          suffixIconConstraints: suffixIcon != null
              ? BoxConstraints(maxHeight: 32.h, minWidth: 32.w)
              : null,
          label: RichText(
            text: TextSpan(
              text: label.replaceAll('*', ''),
              style: AppTextStyle.style_12_400(color: AppColors.grey200),
              children: label.contains('*')
                  ? [
                      const TextSpan(
                        text: '*',
                        style: TextStyle(color: Colors.red),
                      ),
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
      ),
    );
  }

  Widget _buildChooseFilesButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 32.h,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4.r),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: AppTextStyle.style_12_400(color: AppColors.grey200),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 4.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
          ),
          child: Text(
            'Choose files',
            style: AppTextStyle.style_12_400(
              color: AppColors.grey300,
            ).copyWith(fontSize: 11.sp),
          ),
        ),
      ),
    );
  }

  Widget _buildFileChips(
    RxList<File> files,
    RxList<String> names,
    CreateAssetController ctrl,
  ) {
    if (names.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 1.h),
      child: Wrap(
        spacing: 6.w,
        runSpacing: 6.h,
        children: List.generate(names.length, (i) {
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
                Icon(
                  Icons.insert_drive_file_outlined,
                  size: 14.sp,
                  color: AppColors.grey900,
                ),
                SizedBox(width: 4.w),
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 80.w),
                    child: Text(
                      names[i],
                      style: AppTextStyle.style_12_400(color: AppColors.grey900),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                GestureDetector(
                  onTap: () => ctrl.removeFile(files, names, i),
                  child: Icon(Icons.close, size: 14.sp, color: Colors.red),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
