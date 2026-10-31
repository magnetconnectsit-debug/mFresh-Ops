// region Imports
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/data/models/assignee_model.dart';
import 'package:mfresh_ops/data/models/info_directory/asset_category_model.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/create_asset_controller.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
// endregion

// region CreateAssetScreen Class
class CreateAssetScreen extends StatelessWidget {
  const CreateAssetScreen({super.key});

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateAssetController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(controller),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
              child: Container(
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildItemAndTypeRow(context, controller),
                      SizedBox(height: 8.h),
                      _buildBrandAndModelRow(context, controller),
                      SizedBox(height: 8.h),
                      _buildCategoryAndAssigneeRow(context, controller),
                      SizedBox(height: 8.h),
                      _buildSerialNoAndProjectRow(context, controller),
                      SizedBox(height: 8.h),
                      _buildWarrantyExpiryAndStatusRow(context, controller),
                      SizedBox(height: 8.h),
                      _buildLocationAndUnitRow(context, controller),
                      SizedBox(height: 8.h),
                      _buildPositionAndVendorRow(context, controller),
                      SizedBox(height: 8.h),
                      _buildQtyAndInvoiceRow(controller),
                      SizedBox(height: 8.h),
                      _buildWarrantyAndOthersAttachmentRow(controller),
                      SizedBox(height: 8.h),
                      _buildDescriptionField(context, controller),
                      SizedBox(height: 10.h),
                      _buildSpecificationField(context, controller),
                      SizedBox(height: 32.h),
                      _buildActionButtons(controller),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  // endregion

  // region App Bar
  PreferredSizeWidget _buildAppBar(CreateAssetController controller) {
    return AppCommonAppBar(
      topHeader: const CommonShortcutHeader(),
      title: Obx(
        () => Text(
          controller.isEdit.value ? 'Update Asset' : 'Create Asset',
          style: AppTextStyle.style_18_700(color: AppColors.black),
        ),
      ),
      hasBackButton: true,
      showAppDrawer: false,
    );
  }
  // endregion

  // region Form Field Rows
  Widget _buildItemAndTypeRow(
    BuildContext context,
    CreateAssetController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 0: Item *
        Expanded(
          child: AppCommonTextField(
            controller: controller.itemCtrl,
            focusNode: controller.itemFocus,
            labelText: 'Item',
            isRequired: true,
            hintText: 'Enter Item',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(0, context),
          ),
        ),
        SizedBox(width: 16.w),
        // 1: Item Type
        Expanded(
          child: SizedBox(
            height: 32.h,
            child: Obx(
              () => AppCommonMultiSelectDropdown<String>(
                key: controller.itemTypeKey,
                label: 'Item Type',
                isSingleSelect: true,
                selectedValues: controller.selectedItemType.value == null
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
                onChanged: (v) {
                  controller.selectedItemType.value =
                      v.isEmpty ? null : v.first;
                  if (v.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.focusNextUnfilledField(1, context);
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandAndModelRow(
    BuildContext context,
    CreateAssetController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 2: Brand
        Expanded(
          child: AppCommonTextField(
            controller: controller.brandCtrl,
            focusNode: controller.brandFocus,
            labelText: 'Brand',
            hintText: 'Enter Brand',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(2, context),
          ),
        ),
        SizedBox(width: 16.w),
        // 3: Model
        Expanded(
          child: AppCommonTextField(
            controller: controller.modelCtrl,
            focusNode: controller.modelFocus,
            labelText: 'Model',
            hintText: 'Enter Model',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(3, context),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryAndAssigneeRow(
    BuildContext context,
    CreateAssetController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 4: Category
        Expanded(
          child: SizedBox(
            height: 32.h,
            child: Obx(
              () => AppCommonMultiSelectDropdown<AssetCategoryModel>(
                key: controller.categoryKey,
                label: 'Category',
                isSingleSelect: true,
                selectedValues: controller.selectedAssetCategory.value == null
                    ? {}
                    : {controller.selectedAssetCategory.value!},
                items: controller.availableCategories
                    .map(
                      (c) => DropdownMenuItem<AssetCategoryModel>(
                        value: c,
                        child: Text(
                          c.assetCatName,
                          style: AppTextStyle.style_12_400(
                            color: AppColors.grey900,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  controller.selectedAssetCategory.value =
                      v.isEmpty ? null : v.first;
                  if (v.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.focusNextUnfilledField(4, context);
                    });
                  }
                },
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        // 5: Assigned To
        Expanded(
          child: SizedBox(
            height: 32.h,
            child: Obx(
              () => AppCommonMultiSelectDropdown<AssigneeModel>(
                key: controller.assigneeKey,
                label: 'Assigned To',
                isSingleSelect: true,
                selectedValues: controller.selectedAssignee.value == null
                    ? {}
                    : {controller.selectedAssignee.value!},
                items: controller.availableAssignees
                    .map(
                      (a) => DropdownMenuItem<AssigneeModel>(
                        value: a,
                        child: Text(
                          a.name,
                          style: AppTextStyle.style_12_400(
                            color: AppColors.grey900,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  controller.selectedAssignee.value =
                      v.isEmpty ? null : v.first;
                  if (v.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.focusNextUnfilledField(5, context);
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSerialNoAndProjectRow(
    BuildContext context,
    CreateAssetController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 6: Serial No
        Expanded(
          child: AppCommonTextField(
            controller: controller.serialNoCtrl,
            focusNode: controller.serialNoFocus,
            labelText: 'Serial No',
            hintText: 'Enter Serial No',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(6, context),
          ),
        ),
        SizedBox(width: 16.w),
        // 7: Project
        Expanded(
          child: SizedBox(
            height: 32.h,
            child: Obx(
              () => AppCommonMultiSelectDropdown<String>(
                key: controller.projectKey,
                label: 'Project',
                isSingleSelect: true,
                selectedValues: controller.selectedProject.value == null
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
                onChanged: (v) {
                  controller.selectedProject.value =
                      v.isEmpty ? null : v.first;
                  if (v.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.focusNextUnfilledField(7, context);
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarrantyExpiryAndStatusRow(
    BuildContext context,
    CreateAssetController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 8: Warranty Expiry Date
        Expanded(
          child: Obx(
            () => AppCommonDateField(
              key: controller.warrantyExpiryKey,
              focusNode: controller.warrantyExpiryFocus,
              labelText: 'Warranty Expiry Date',
              hintText: 'Select Date',
              height: 32.h,
              selectedDate: controller.warrantyExpiryDateTime,
              onDateSelected: (date) {
                final formatted =
                    "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                controller.selectedWarrantyExpiry.value = formatted;
                controller.warrantyExpiryDisplayCtrl.text =
                    AppDateUtils.formatToOrdinalDate(formatted);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.focusNextUnfilledField(8, context);
                });
              },
            ),
          ),
        ),
        SizedBox(width: 16.w),
        // 9: Warranty Status
        Expanded(
          child: SizedBox(
            height: 32.h,
            child: Obx(
              () => AppCommonMultiSelectDropdown<String>(
                key: controller.warrantyStatusKey,
                label: 'Warranty Status',
                isSingleSelect: true,
                selectedValues: controller.selectedWarrantyStatus.value == null
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
                onChanged: (v) {
                  controller.selectedWarrantyStatus.value =
                      v.isEmpty ? null : v.first;
                  if (v.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.focusNextUnfilledField(9, context);
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationAndUnitRow(
    BuildContext context,
    CreateAssetController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 10: Installed At (Location)
        Expanded(
          child: AppCommonTextField(
            controller: controller.locationCtrl,
            focusNode: controller.locationFocus,
            labelText: 'Installed At (Location)',
            hintText: 'Enter Location',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(10, context),
          ),
        ),
        SizedBox(width: 16.w),
        // 11: Unit
        Expanded(
          child: AppCommonTextField(
            controller: controller.unitCtrl,
            focusNode: controller.unitFocus,
            labelText: 'Unit',
            hintText: 'Enter Unit',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(11, context),
          ),
        ),
      ],
    );
  }

  Widget _buildPositionAndVendorRow(
    BuildContext context,
    CreateAssetController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 12: Position
        Expanded(
          child: AppCommonTextField(
            controller: controller.positionCtrl,
            focusNode: controller.positionFocus,
            labelText: 'Position',
            hintText: 'Enter Position',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(12, context),
          ),
        ),
        SizedBox(width: 16.w),
        // 13: Vendor
        Expanded(
          child: AppCommonTextField(
            controller: controller.vendorCtrl,
            focusNode: controller.vendorFocus,
            labelText: 'Vendor',
            hintText: 'Enter Vendor',
            height: 32.h,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                controller.focusNextUnfilledField(13, context),
          ),
        ),
      ],
    );
  }

  Widget _buildQtyAndInvoiceRow(CreateAssetController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 14: Qty
        Expanded(
          child: AppCommonTextField(
            controller: controller.qtyCtrl,
            focusNode: controller.qtyFocus,
            labelText: 'Qty',
            hintText: 'Enter Qty',
            height: 32.h,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => controller.focusNextUnfilledField(14),
          ),
        ),
        SizedBox(width: 16.w),
        // Invoice Attachment
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChooseFilesButton(
                label: 'Invoice Attachment',
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
    );
  }

  Widget _buildWarrantyAndOthersAttachmentRow(
    CreateAssetController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Warranty Attachment
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChooseFilesButton(
                label: 'Warranty Attachment',
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
        // Others Attachment
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
    );
  }

  Widget _buildDescriptionField(
    BuildContext context,
    CreateAssetController controller,
  ) {
    // 15: Description
    return AppCommonTextField(
      controller: controller.descriptionCtrl,
      focusNode: controller.descriptionFocus,
      labelText: 'Description (Vendor Details)',
      hintText: 'Enter Description',
      maxLines: 2,
      height: 56.h,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => controller.focusNextUnfilledField(15, context),
    );
  }

  Widget _buildSpecificationField(
    BuildContext context,
    CreateAssetController controller,
  ) {
    // 16: Specification
    return AppCommonTextField(
      controller: controller.specificationCtrl,
      focusNode: controller.specificationFocus,
      labelText: 'Specification',
      hintText: 'Enter Specification',
      maxLines: 2,
      height: 56.h,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => controller.focusNextUnfilledField(16, context),
    );
  }
  // endregion

  // region Action Handlers & Submit Buttons
  Widget _buildActionButtons(CreateAssetController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AppCommonButton(
          text: 'Cancel',
          variant: ButtonVariant.outline,
          borderColor: AppColors.borderColor,
          textColor: AppColors.black,
          height: 30.h,
          width: 80.w,
          borderRadius: 4.r,
          padding: EdgeInsets.zero,
          onPressed: () => Get.back(),
        ),
        SizedBox(width: 12.w),
        Obx(
          () => AppCommonButton(
            text: 'Submit',
            buttonColor: AppColors.primary,
            useGradient: false,
            textColor: AppColors.white,
            height: 30.h,
            width: 80.w,
            borderRadius: 4.r,
            padding: EdgeInsets.zero,
            isLoading: controller.isLoading.value,
            onPressed:
                controller.isLoading.value ? null : controller.saveAsset,
          ),
        ),
      ],
    );
  }
  // endregion

  // region Helper Widgets
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
      padding: EdgeInsets.only(top: 4.h),
      child: Wrap(
        spacing: 6.w,
        runSpacing: 6.h,
        children: List.generate(names.length, (i) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              border: Border.all(color: AppColors.borderColor),
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
                      style: AppTextStyle.style_12_400(
                        color: AppColors.grey900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                GestureDetector(
                  onTap: () => ctrl.removeFile(files, names, i),
                  child: Icon(Icons.close, size: 14.sp, color: AppColors.red),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
  // endregion
}
// endregion
