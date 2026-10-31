import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/item_controller.dart';
import 'package:mfresh_ops/data/models/inventory/item_model.dart';

void showItemFormDialog(
  BuildContext context,
  ItemController controller, {
  ItemModel? item,
}) {
  final isEdit = item != null;
  if (isEdit) {
    controller.itemNameController.text = item.itemName;
    controller.itemIdController.text = item.itemId;
    controller.selectedMeasurement.value = item.measurementUnitId;
    controller.selectedCategory.value = item.categoryInv;
    controller.lowQuantityStoreController.text = item.lowQnty;
    controller.lowQuantityUnitController.text = item.lowQntyUnit;
  } else {
    controller.prepareAddDialog();
  }

  showDialog(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      insetPadding: EdgeInsets.all(20.r),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          padding: EdgeInsets.all(20.r),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Item' : 'Add Item',
                    style: AppTextStyle.style_18_700(color: AppColors.black),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: Icon(
                      Icons.close,
                      color: AppColors.grey500,
                      size: 20.r,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Form fields
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppCommonTextField(
                      labelText: 'Item Name',
                      controller: controller.itemNameController,
                      hintText: 'Enter item name',
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: AppCommonTextField(
                      labelText: 'Item ID',
                      controller: controller.itemIdController,
                      readOnly: true,
                      hintText: 'Item ID',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Dropdowns Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Obx(
                      () => MultiSelectDropdownWidget<String>(
                        label: 'Measurement',
                        isSingleSelect: true,
                        selectedValues:
                            controller.selectedMeasurement.value != null
                            ? {controller.selectedMeasurement.value!}
                            : {},
                        items: controller.measurementOptions
                            .map<DropdownMenuItem<String>>(
                              (e) => DropdownMenuItem<String>(
                                value: e.value,
                                child: Text(
                                  e.label,
                                  style: AppTextStyle.style_12_400(
                                    color: AppColors.grey900,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (values) {
                          controller.selectedMeasurement.value =
                              values.isNotEmpty ? values.first : null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Obx(
                      () => MultiSelectDropdownWidget<String>(
                        label: 'Category',
                        isSingleSelect: true,
                        selectedValues:
                            controller.selectedCategory.value != null
                            ? {controller.selectedCategory.value!}
                            : {},
                        items: controller.categoryOptions
                            .map<DropdownMenuItem<String>>(
                              (e) => DropdownMenuItem<String>(
                                value: e.value,
                                child: Text(
                                  e.label,
                                  style: AppTextStyle.style_12_400(
                                    color: AppColors.grey900,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (values) {
                          controller.selectedCategory.value = values.isNotEmpty
                              ? values.first
                              : null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Low Quantities Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppCommonTextField(
                      labelText: 'Low Qty (Store)',
                      controller: controller.lowQuantityStoreController,
                      hintText: 'Enter quantity',
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: AppCommonTextField(
                      labelText: 'Low Qty (Unit)',
                      controller: controller.lowQuantityUnitController,
                      hintText: 'Enter quantity',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppCommonButton(
                    text: 'Cancel',
                    buttonColor: AppColors.black200,
                    height: 26.h,
                    width: 90.w,
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                  SizedBox(width: 12.w),
                  Obx(
                    () => AppCommonButton(
                      text: isEdit ? 'Update' : 'Submit',
                      buttonColor: AppColors.primaryBlue,
                      width: 100.w,
                      height: 26.h,
                      isLoading: controller.isLoading.value,
                      onPressed: () async {
                        final success = isEdit
                            ? await controller.editItem(item.id)
                            : await controller.addItem();
                        if (success && dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                      },
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
