import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import '../../controllers/item_controller.dart';

void showItemFormDialog(BuildContext context, ItemController controller, {ItemModel? item}) {
  final isEdit = item != null;
  if (isEdit) {
    controller.itemNameController.text = item.itemName;
    controller.itemIdController.text = item.itemId;
    controller.selectedMeasurement.value = item.measurement;
    controller.selectedCategory.value = item.category;
    controller.lowQuantityStoreController.text = item.lowQuantityStore;
    controller.lowQuantityUnitController.text = item.lowQuantityUnit;
  } else {
    controller.clearControllers();
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
                  _buildWhiteDropdown('Measurement', controller.selectedMeasurement, controller.measurementOptions),
                  SizedBox(height: 12.h),
                  _buildCategoryDropdown('Category', controller.selectedCategory, controller.categoryOptions),
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
                      onPressed: () {
                        if (isEdit) {
                          final updated = ItemModel(
                            siNo: item.siNo,
                            itemName: controller.itemNameController.text,
                            itemId: controller.itemIdController.text,
                            measurement: controller.selectedMeasurement.value ?? item.measurement,
                            category: controller.selectedCategory.value ?? item.category,
                            lowQuantityStore: controller.lowQuantityStoreController.text,
                            lowQuantityUnit: controller.lowQuantityUnitController.text,
                          );
                          final index = controller.allItems.indexOf(item);
                          controller.editItem(index, updated);
                        } else {
                          controller.addItem();
                        }
                        Get.back();
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
        height: 28.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.grey50),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            isDense: true,
          ),
        ),
      ),
    ],
  );
}

Widget _buildWhiteDropdown(String label, RxnString selectedValue, List<String> options) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyle.style_14_600(color: AppColors.black).copyWith(fontSize: 13.sp)),
      SizedBox(height: 6.h),
      Container(
        height: 28.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.grey50),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: DropdownButtonHideUnderline(
          child: Obx(() => DropdownButton<String>(
            isExpanded: true,
            value: selectedValue.value,
            hint: Text('Select', style: AppTextStyle.style_14_400(color: AppColors.black)),
            icon: Icon(Icons.keyboard_arrow_down, size: 18.r, color: AppColors.black),
            items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, style: AppTextStyle.style_14_400(color: AppColors.black)))).toList(),
            onChanged: (v) => selectedValue.value = v,
          )),
        ),
      ),
    ],
  );
}

Widget _buildCategoryDropdown(String label, RxnString selectedValue, List<String> options) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyle.style_14_600(color: AppColors.black).copyWith(fontSize: 13.sp)),
      SizedBox(height: 6.h),
      InkWell(
        onTap: () async {
          final opts = options.map((e) => DropdownOption(value: e, label: e)).toList();
          final selection = selectedValue.value != null ? [DropdownOption(value: selectedValue.value!, label: selectedValue.value!)] : null;
          final result = await AppCommonDropdownPage.show<String>(
            Get.context!,
            title: 'Select Category',
            options: opts,
            initialSelection: selection,
          );
          if (result != null && result.isNotEmpty) {
            selectedValue.value = result.first.value;
          }
        },
        child: Container(
          height: 28.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.grey50),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(selectedValue.value ?? 'Select', style: AppTextStyle.style_14_400(color: AppColors.black))),
              Icon(Icons.keyboard_arrow_down, size: 18.r, color: AppColors.black),
            ],
          ),
        ),
      ),
    ],
  );
}
