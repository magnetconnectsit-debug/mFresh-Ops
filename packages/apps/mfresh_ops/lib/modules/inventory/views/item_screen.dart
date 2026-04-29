import 'package:core/widgets/app_common_drop_down.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:core/widgets/app_common_export_button.dart';
import '../controllers/item_controller.dart';
import '../../../widgets/common_sidebar.dart';

class ItemScreen extends StatelessWidget {
  const ItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ItemController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        hasBackButton: false,
        showAppDrawer: true,
        title: Text(
          'Items',
          style: AppTextStyle.style_18_700(color: AppColors.black),
        ),
        actions: [
          AppCommonExportButton(
            onExportExcel: () => controller.exportToExcel(),
            onExportPdf: () => controller.exportToPdf(),
            height: 32.h,
          ),
          SizedBox(width: 8.w),
          AppCommonButton(
            text: 'Add Item',
            onPressed: () => _showAddDialog(context, controller),
            height: 32.h,
            width: 90.w,
            textSize: 12.sp,
          ),
          SizedBox(width: 16.w),
        ],
      ),
      drawer: const CommonSidebar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                itemCount: controller.filteredItems.length,
                itemBuilder: (context, index) {
                  final item = controller.filteredItems[index];
                  return _buildItemCard(context, controller, item);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    ItemController controller,
    ItemModel item,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  item.siNo.toString(),
                  style: AppTextStyle.style_12_700(color: AppColors.primary),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      style: AppTextStyle.style_14_700(color: AppColors.black),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        _buildInfoChip(Icons.tag, 'ID: ${item.itemId}'),
                        SizedBox(width: 8.w),
                        _buildInfoChip(Icons.straighten, item.measurement),
                      ],
                    ),
                  ],
                ),
              ),
              _buildEditButton(context, controller, item),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 10.r, color: AppColors.grey300),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppTextStyle.style_10_500(color: AppColors.black1),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton(
    BuildContext context,
    ItemController controller,
    ItemModel item,
  ) {
    return AppCommonButton(
      text: 'Edit',
      onPressed: () => _showEditDialog(context, controller, item),
      height: 28.h,
      width: 60.w,
      textSize: 10.sp,
      buttonColor: AppColors.primary,
    );
  }

  void _showAddDialog(BuildContext context, ItemController controller) {
    controller.clearControllers();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create Item',
                    style: AppTextStyle.style_18_700(color: AppColors.black),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                'Inventory Form',
                style: AppTextStyle.style_12_600(color: AppColors.grey300),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: AppCommonTextField(
                      controller: controller.itemNameController,
                      titleText: 'Item Name',
                      hintText: 'Enter item name',
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: AppCommonTextField(
                      controller: controller.itemIdController,
                      titleText: 'Item Id',
                      hintText: 'Enter item id',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => AppCommonDropdown<String>(
                        title: 'Measurement',
                        hintText: 'Select',
                        value: controller.selectedMeasurement.value,
                        items: controller.measurementOptions
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: AppTextStyle.style_14_400(),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            controller.selectedMeasurement.value = v,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Obx(
                      () => AppCommonDropdown<String>(
                        title: 'Category',
                        hintText: 'Select',
                        value: controller.selectedCategory.value,
                        items: controller.categoryOptions
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: AppTextStyle.style_14_400(),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => controller.selectedCategory.value = v,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'Low quantity(Store Room)',
                      style:
                          AppTextStyle.style_12_500(color: AppColors.black300),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Low quantity(Unit)',
                      style:
                          AppTextStyle.style_12_500(color: AppColors.black300),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: AppCommonTextField(
                      controller: controller.lowQuantityStoreController,
                      hintText: 'Enter qty',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: AppCommonTextField(
                      controller: controller.lowQuantityUnitController,
                      hintText: 'Enter qty',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              AppCommonButton(
                text: 'Submit',
                width: double.infinity,
                height: 44.h,
                buttonColor: AppColors.primary,
                onPressed: () => controller.addItem(),
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    ItemController controller,
    ItemModel item,
  ) {
    controller.itemNameController.text = item.itemName;
    controller.itemIdController.text = item.itemId;
    controller.selectedMeasurement.value = item.measurement;
    controller.selectedCategory.value = item.category;
    controller.lowQuantityStoreController.text = item.lowQuantityStore;
    controller.lowQuantityUnitController.text = item.lowQuantityUnit;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Item',
                    style: AppTextStyle.style_18_700(color: AppColors.black),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: AppCommonTextField(
                      controller: controller.itemNameController,
                      titleText: 'Item Name',
                      hintText: 'Enter item name',
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: AppCommonTextField(
                      controller: controller.itemIdController,
                      titleText: 'Item Id',
                      hintText: 'Enter item id',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => AppCommonDropdown<String>(
                        title: 'Measurement',
                        hintText: 'Select',
                        value: controller.selectedMeasurement.value,
                        items: controller.measurementOptions
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: AppTextStyle.style_14_400(),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            controller.selectedMeasurement.value = v,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Obx(
                      () => AppCommonDropdown<String>(
                        title: 'Category',
                        hintText: 'Select',
                        value: controller.selectedCategory.value,
                        items: controller.categoryOptions
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: AppTextStyle.style_14_400(),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => controller.selectedCategory.value = v,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'Low quantity(Store Room)',
                      style:
                          AppTextStyle.style_12_500(color: AppColors.black300),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Low quantity(Unit)',
                      style:
                          AppTextStyle.style_12_500(color: AppColors.black300),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: AppCommonTextField(
                      controller: controller.lowQuantityStoreController,
                      hintText: 'Enter qty',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: AppCommonTextField(
                      controller: controller.lowQuantityUnitController,
                      hintText: 'Enter qty',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              AppCommonButton(
                text: 'Update',
                width: double.infinity,
                height: 44.h,
                buttonColor: AppColors.primary,
                onPressed: () {
                  final updated = ItemModel(
                    siNo: item.siNo,
                    itemName: controller.itemNameController.text,
                    itemId: controller.itemIdController.text,
                    measurement: controller.selectedMeasurement.value ??
                        item.measurement,
                    category:
                        controller.selectedCategory.value ?? item.category,
                    lowQuantityStore:
                        controller.lowQuantityStoreController.text,
                    lowQuantityUnit: controller.lowQuantityUnitController.text,
                  );
                  final index = controller.allItems.indexOf(item);
                  controller.editItem(index, updated);
                },
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }
}
