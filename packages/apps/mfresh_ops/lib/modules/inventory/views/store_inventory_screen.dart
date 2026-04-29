import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_drop_down.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:core/widgets/app_common_export_button.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_controller.dart';

class StoreInventoryScreen extends StatelessWidget {
  const StoreInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InventoryController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        showAppDrawer: true,
        hasBackButton: false,
        title: Obx(
          () => controller.isSearching.value
              ? AppCommonSearchBar(
                  controller: controller.searchController,
                  hintText: 'Search items...',
                  onChanged: (v) => controller.applyFilters(),
                )
              : Text(
                  'Store Inventory',
                  style: AppTextStyle.style_18_700(color: AppColors.black),
                ),
        ),
        actions: [
          Obx(
            () => IconButton(
              onPressed: () => controller.toggleSearch(),
              icon: Icon(
                controller.isSearching.value ? Icons.close : Icons.search,
                color: AppColors.black,
                size: 24.r,
              ),
            ),
          ),
        ],
      ),
      drawer: const CommonSidebar(),
      body: Column(
        children: [
          _buildFiltersSection(),
          _buildActionButtons(context),
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                itemCount: controller.inventoryItems.length,
                itemBuilder: (context, index) {
                  final item = controller.inventoryItems[index];
                  return _buildInventoryCard(context, item);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard(BuildContext context, InventoryItemModel item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.item,
                      style: AppTextStyle.style_14_700(color: AppColors.black),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        _buildTagChip(Icons.store, item.store, AppColors.primary),
                        SizedBox(width: 8.w),
                        _buildTagChip(Icons.category, item.category, AppColors.info),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.quantity,
                    style: AppTextStyle.style_16_700(color: AppColors.primary),
                  ),
                  Text(
                    item.unit,
                    style: AppTextStyle.style_10_600(
                      color: item.isPcs ? AppColors.red : AppColors.grey300,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(height: 24.h, color: AppColors.grey50),
          Row(
            children: [
              Expanded(
                child: AppCommonButton(
                  text: 'Allocate',
                  onPressed: () => _showAllocateSheet(context, item),
                  height: 32.h,
                  buttonColor: AppColors.info,
                  textSize: 11.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AppCommonButton(
                  text: 'Consume',
                  onPressed: () => _showConsumptionSheet(context, item),
                  height: 32.h,
                  buttonColor: AppColors.red,
                  textSize: 11.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.r, color: color),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              label,
              style: AppTextStyle.style_10_600(color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildActionButtons(BuildContext context) {
    final controller = Get.find<InventoryController>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              'Add Item',
              AppColors.primary,
              Icons.add,
              () => _showAddInventorySheet(context),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: AppCommonExportButton(
              onExportExcel: () => controller.exportToExcel(),
              onExportPdf: () => controller.exportToPdf(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, Color color, IconData icon, VoidCallback onTap) {
    return SizedBox(
      height: 36.h,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16.r),
        label: Text(
          label,
          style: AppTextStyle.style_12_600(color: AppColors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
        ),
      ),
    );
  }



  void _showAddInventorySheet(BuildContext context) {
    final controller = Get.find<InventoryController>();
    controller.selectedAddItemName.value = null;

    final packetController = TextEditingController(text: '2');
    final pieceController = TextEditingController(text: '10');
    final consumptionController = TextEditingController(text: '20');

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
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Add ',
                          style:
                              AppTextStyle.style_18_700(color: AppColors.black),
                        ),
                        TextSpan(
                          text: 'Stock Inventory',
                          style:
                              AppTextStyle.style_18_700(color: AppColors.red),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppCommonDropdown<String>(
                      title: 'State',
                      hintText: 'Choose State',
                      items: const [],
                      onChanged: (v) {},
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: AppCommonDropdown<String>(
                      title: 'District',
                      hintText: 'Choose District',
                      items: const [],
                      onChanged: (v) {},
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppCommonDropdown<String>(
                      title: 'Store Name',
                      hintText: 'Choose Store',
                      items: const [],
                      onChanged: (v) {},
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: AppCommonDropdown<String>(
                      title: 'Category',
                      hintText: 'Choose Category',
                      items: const [],
                      onChanged: (v) {},
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Obx(() => AppCommonDropdown<String>(
                    title: 'Item Name',
                    hintText: 'Select Item',
                    value: controller.selectedAddItemName.value,
                    items: ['Garbage Bag', 'Hand Wash', 'Body Wash']
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e, style: AppTextStyle.style_14_400()),
                            ))
                        .toList(),
                    onChanged: (v) => controller.selectedAddItemName.value = v,
                  )),
              Obx(() {
                if (controller.selectedAddItemName.value == null) {
                  return const SizedBox();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: AppCommonTextField(
                            controller: packetController,
                            titleText: 'Packet',
                            hintText: '2',
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          flex: 3,
                          child: AppCommonTextField(
                            controller: pieceController,
                            titleText: 'Piece (per Packet)',
                            hintText: '10',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    AppCommonTextField(
                      controller: consumptionController,
                      titleText: 'Consumption Qty.',
                      hintText: '20',
                    ),
                  ],
                );
              }),
              SizedBox(height: 24.h),
              Row(
                children: [
                  const Spacer(),
                  AppCommonButton(
                    text: 'Cancel',
                    width: 100.w,
                    variant: ButtonVariant.outline,
                    onPressed: () => Get.back(),
                  ),
                  SizedBox(width: 12.w),
                  AppCommonButton(
                    text: 'Submit',
                    width: 100.w,
                    buttonColor: AppColors.info,
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    final controller = Get.find<InventoryController>();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: AppTextStyle.style_14_700(color: AppColors.black),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: Obx(() => AppCommonDropdown<String>(
                  title: 'State',
                  hintText: 'Select State',
                  isMultiSelect: true,
                  options: controller.stateOptions,
                  selectedValues: controller.selectedStates.toList(),
                  onMultiSelectChanged: (values) {
                    controller.selectedStates.assignAll(values);
                    controller.applyFilters();
                  },
                  height: 32.h,
                )),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Obx(() => AppCommonDropdown<String>(
                  title: 'District',
                  hintText: 'Select District',
                  isMultiSelect: true,
                  options: controller.districtOptions,
                  selectedValues: controller.selectedDistricts.toList(),
                  onMultiSelectChanged: (values) {
                    controller.selectedDistricts.assignAll(values);
                    controller.applyFilters();
                  },
                  height: 32.h,
                )),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: Obx(() => AppCommonDropdown<String>(
                  title: 'StoreRoom',
                  hintText: 'Select StoreRoom',
                  isMultiSelect: true,
                  options: controller.storeOptions,
                  selectedValues: controller.selectedStores.toList(),
                  onMultiSelectChanged: (values) {
                    controller.selectedStores.assignAll(values);
                    controller.applyFilters();
                  },
                  height: 32.h,
                )),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Obx(() => AppCommonDropdown<String>(
                  title: 'Category',
                  hintText: 'Select Category',
                  isMultiSelect: true,
                  options: controller.categoryOptions,
                  selectedValues: controller.selectedCategories.toList(),
                  onMultiSelectChanged: (values) {
                    controller.selectedCategories.assignAll(values);
                    controller.applyFilters();
                  },
                  height: 32.h,
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAllocateSheet(BuildContext context, InventoryItemModel item) {
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
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Allocate to Unit',
                    style: AppTextStyle.style_18_700(color: AppColors.black),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              
              Text('From', style: AppTextStyle.style_12_700(color: AppColors.red)),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: AppCommonTextField(
                      controller: TextEditingController(text: item.store),
                      titleText: 'Store Name',
                      hintText: item.store,
                      enabled: false,
                      height: 32.h,
                      style: AppTextStyle.style_12_400(color: AppColors.black1),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: AppCommonTextField(
                      controller: TextEditingController(text: item.item),
                      titleText: 'Item Name',
                      hintText: item.item,
                      enabled: false,
                      height: 32.h,
                      style: AppTextStyle.style_12_400(color: AppColors.black1),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: 180.w,
                child: AppCommonTextField(
                  controller: TextEditingController(text: '${item.quantity} ${item.unit}'),
                  titleText: 'Available Qty. (Consumption)',
                  hintText: '${item.quantity} ${item.unit}',
                  enabled: false,
                  height: 32.h,
                  style: AppTextStyle.style_12_400(color: AppColors.black1),
                ),
              ),
              
              SizedBox(height: 16.h),
              Text('To', style: AppTextStyle.style_12_700(color: AppColors.red)),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: AppCommonDropdown<String>(
                      title: 'State',
                      hintText: 'Odisha',
                      items: const [],
                      onChanged: (v) {},
                      height: 32.h,
                      style: AppTextStyle.style_12_400(color: AppColors.black1),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: AppCommonDropdown<String>(
                      title: 'District',
                      hintText: 'Puri',
                      items: const [],
                      onChanged: (v) {},
                      height: 32.h,
                      style: AppTextStyle.style_12_400(color: AppColors.black1),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: AppCommonDropdown<String>(
                      title: 'Destination Type',
                      hintText: 'Unit',
                      items: const [],
                      onChanged: (v) {},
                      height: 32.h,
                      style: AppTextStyle.style_12_400(color: AppColors.black1),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: AppCommonDropdown<String>(
                      title: 'Destination',
                      hintText: 'MM25002',
                      items: const [],
                      onChanged: (v) {},
                      height: 32.h,
                      style: AppTextStyle.style_12_400(color: AppColors.black1),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: 180.w,
                child: AppCommonTextField(
                  controller: TextEditingController(),
                  titleText: 'Allocate Qty. (Consumption)',
                  hintText: 'Enter Qty.',
                  height: 32.h,
                  style: AppTextStyle.style_12_400(color: AppColors.black1),
                ),
              ),
              
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppCommonButton(
                    text: 'Cancel',
                    width: 100.w,
                    variant: ButtonVariant.outline,
                    onPressed: () => Get.back(),
                  ),
                  SizedBox(width: 12.w),
                  AppCommonButton(
                    text: 'Submit',
                    width: 100.w,
                    buttonColor: AppColors.info,
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showConsumptionSheet(BuildContext context, InventoryItemModel item) {
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
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Consumption',
                    style: AppTextStyle.style_18_700(color: AppColors.black),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              
              Row(
                children: [
                  Expanded(
                    child: AppCommonTextField(
                      controller: TextEditingController(text: item.store),
                      titleText: 'Store',
                      hintText: item.store,
                      enabled: false,
                      height: 32.h,
                      style: AppTextStyle.style_12_400(color: AppColors.black1),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: AppCommonTextField(
                      controller: TextEditingController(text: item.item),
                      titleText: 'Item Name',
                      hintText: item.item,
                      enabled: false,
                      height: 32.h,
                      style: AppTextStyle.style_12_400(color: AppColors.black1),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: AppCommonTextField(
                      controller: TextEditingController(text: item.quantity),
                      titleText: 'Available Qty.',
                      hintText: item.quantity,
                      enabled: false,
                      height: 32.h,
                      style: AppTextStyle.style_12_400(color: AppColors.black1),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: AppCommonTextField(
                      controller: TextEditingController(),
                      titleText: 'Consumption Qty.',
                      hintText: 'Enter Qty.',
                      height: 32.h,
                      style: AppTextStyle.style_12_400(color: AppColors.black1),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppCommonButton(
                    text: 'Cancel',
                    width: 100.w,
                    variant: ButtonVariant.outline,
                    onPressed: () => Get.back(),
                  ),
                  SizedBox(width: 12.w),
                  AppCommonButton(
                    text: 'Submit',
                    width: 100.w,
                    buttonColor: AppColors.info,
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
