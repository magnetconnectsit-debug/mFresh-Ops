import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';
import '../../controllers/item_controller.dart';

void showItemFormDialog(BuildContext context, ItemController controller, {ItemModel? item}) {
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

  Get.dialog(
    Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.r),
        side: const BorderSide(color: AppColors.grey50, width: 1),
      ),
      insetPadding: EdgeInsets.all(20.r),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
                border: const Border(bottom: BorderSide(color: AppColors.grey50)),
              ),
              child: Text(
                'Inventory Form',
                style: AppTextStyle.style_14_500(color: AppColors.black),
              ),
            ),
            // Body
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWhiteInput('Item Name', controller.itemNameController),
                  SizedBox(height: 12.h),
                  _buildWhiteInput('Item Id', controller.itemIdController),
                  SizedBox(height: 12.h),
                  Obx(
                    () => MultiSelectDropdownWidget<String>(
                      title: 'Measurement',
                      isSingleSelect: true,
                      selectedValues: controller.selectedMeasurement.value != null
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
                        controller.selectedMeasurement.value = values.isNotEmpty ? values.first : null;
                      },
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Obx(
                    () => MultiSelectDropdownWidget<String>(
                      title: 'Category',
                      isSingleSelect: true,
                      selectedValues: controller.selectedCategory.value != null
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
                        controller.selectedCategory.value = values.isNotEmpty ? values.first : null;
                      },
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildWhiteInput('Low quantity(Store Room)', controller.lowQuantityStoreController),
                  SizedBox(height: 12.h),
                  _buildWhiteInput('Low quantity(Unit)', controller.lowQuantityUnitController),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 32.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D6EFD),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final success = isEdit
                            ? await controller.editItem(item.id)
                            : await controller.addItem();
                        if (success && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text('Submit', style: AppTextStyle.style_14_600(color: AppColors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildWhiteInput(String label, TextEditingController controller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyle.style_14_600(color: AppColors.black).copyWith(fontSize: 13.sp)),
      SizedBox(height: 6.h),
      Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.grey50),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: TextFormField(
          controller: controller,
          textAlignVertical: TextAlignVertical.center,
          style: AppTextStyle.style_12_400(color: AppColors.black),
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            isDense: true,
          ),
        ),
      ),
    ],
  );
}
