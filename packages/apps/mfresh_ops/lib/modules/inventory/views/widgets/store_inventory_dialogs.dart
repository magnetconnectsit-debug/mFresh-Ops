import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import '../../../../data/models/inventory/inventory_item_model.dart';

class StoreInventoryDialogs {
  static Widget _buildGreyField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyle.style_12_500(color: AppColors.black300)),
        SizedBox(height: 6.h),
        Container(
          height: 32.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(hint, style: AppTextStyle.style_12_400(color: AppColors.grey500)),
        ),
      ],
    );
  }

  static Widget _buildGreyDropdown(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyle.style_12_500(color: AppColors.black300)),
        SizedBox(height: 6.h),
        Container(
          height: 28.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(hint, style: AppTextStyle.style_12_400(color: AppColors.grey500), overflow: TextOverflow.ellipsis)),
              Icon(Icons.keyboard_arrow_down, size: 16.r, color: AppColors.grey500),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildWhiteInput(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyle.style_12_500(color: AppColors.black300)),
        SizedBox(height: 6.h),
        Container(
          height: 28.h,
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.grey100),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: TextFormField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyle.style_12_400(color: AppColors.grey500),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildSmallVerticalWhiteField(String label, String hint, {bool isInput = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyle.style_12_500(color: AppColors.black300)),
        SizedBox(height: 4.h),
        Container(
          height: 28.h,
          padding: isInput ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 8.w),
          alignment: isInput ? null : Alignment.centerLeft,
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.grey100),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: isInput 
            ? TextFormField(
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: AppTextStyle.style_12_400(color: AppColors.grey500),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  isDense: true,
                ),
              )
            : Text(hint, style: AppTextStyle.style_12_400(color: AppColors.grey500), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  static void showAddInventorySheet(BuildContext context) {
    final controller = Get.find<InventoryController>();
    controller.selectedAddItemName.value = null;

    final selectedState = RxnString();
    final selectedDistrict = RxnString();
    final selectedStore = RxnString();
    final selectedCategory = RxnString();

    final packetController = TextEditingController(text: '2');
    final pieceController = TextEditingController(text: '10');
    final consumptionController = TextEditingController(text: '20');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        insetPadding: EdgeInsets.all(20.r),
        child: Container(
          padding: EdgeInsets.all(20.r),
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
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Add ',
                          style: AppTextStyle.style_18_700(
                            color: AppColors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'Stock Inventory',
                          style: AppTextStyle.style_18_700(
                            color: AppColors.red,
                          ),
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
              SizedBox(height: 12.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Obx(() => MultiSelectDropdownWidget<String>(
                      title: 'State',
                      isSingleSelect: true,
                      selectedValues: selectedState.value != null ? {selectedState.value!} : {},
                      items: controller.stateOptions
                          .map<DropdownMenuItem<String>>((e) => DropdownMenuItem<String>(
                                value: e.value,
                                child: Text(e.label, style: AppTextStyle.style_12_400(color: AppColors.grey900)),
                              ))
                          .toList(),
                      onChanged: (values) {
                        final v = values.isNotEmpty ? values.first : null;
                        selectedState.value = v;
                        selectedDistrict.value = null;
                        selectedStore.value = null;
                        if (v != null) {
                          controller.fetchDistricts(v);
                        }
                      },
                    )),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Obx(() => MultiSelectDropdownWidget<String>(
                      title: 'District',
                      isSingleSelect: true,
                      selectedValues: selectedDistrict.value != null ? {selectedDistrict.value!} : {},
                      items: selectedState.value == null ? [] : controller.districtOptions
                          .map<DropdownMenuItem<String>>((e) => DropdownMenuItem<String>(
                                value: e.value,
                                child: Text(e.label, style: AppTextStyle.style_12_400(color: AppColors.grey900)),
                              ))
                          .toList(),
                      onChanged: (values) {
                        final v = values.isNotEmpty ? values.first : null;
                        selectedDistrict.value = v;
                        selectedStore.value = null;
                        if (v != null && selectedState.value != null) {
                          controller.fetchStores(selectedState.value!, v);
                        }
                      },
                    )),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Obx(() => MultiSelectDropdownWidget<String>(
                      title: 'Store Name',
                      isSingleSelect: true,
                      selectedValues: selectedStore.value != null ? {selectedStore.value!} : {},
                      items: selectedState.value == null ? [] : controller.storeOptions
                          .map<DropdownMenuItem<String>>((e) => DropdownMenuItem<String>(
                                value: e.value,
                                child: Text(e.label, style: AppTextStyle.style_12_400(color: AppColors.grey900)),
                              ))
                          .toList(),
                      onChanged: (values) {
                        final v = values.isNotEmpty ? values.first : null;
                        selectedStore.value = v;
                      },
                    )),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Obx(() => MultiSelectDropdownWidget<String>(
                      title: 'Category',
                      isSingleSelect: true,
                      selectedValues: selectedCategory.value != null ? {selectedCategory.value!} : {},
                      items: controller.categoryOptions
                          .map<DropdownMenuItem<String>>((e) => DropdownMenuItem<String>(
                                value: e.value,
                                child: Text(e.label, style: AppTextStyle.style_12_400(color: AppColors.grey900)),
                              ))
                          .toList(),
                      onChanged: (values) {
                        final v = values.isNotEmpty ? values.first : null;
                        selectedCategory.value = v;
                        controller.selectedAddItemName.value = null;
                      },
                    )),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Obx(
                () => MultiSelectDropdownWidget<String>(
                  title: 'Item Name',
                  isSingleSelect: true,
                  selectedValues: controller.selectedAddItemName.value != null ? {controller.selectedAddItemName.value!} : {},
                  items: controller.itemOptions
                      .map<DropdownMenuItem<String>>(
                        (e) => DropdownMenuItem<String>(
                          value: e.value,
                          child: Text(e.label, style: AppTextStyle.style_12_400(color: AppColors.grey900)),
                        ),
                      )
                      .toList(),
                  onChanged: (values) {
                    final v = values.isNotEmpty ? values.first : null;
                    controller.selectedAddItemName.value = v;
                  },
                ),
              ),
              Obx(() {
                if (controller.selectedAddItemName.value == null) {
                  return const SizedBox();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
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
                    height: 28.h,
                    variant: ButtonVariant.outline,
                    onPressed: () => Get.back(),
                  ),
                  SizedBox(width: 12.w),
                  AppCommonButton(
                    text: 'Submit',
                    width: 100.w,
                    height: 28.h,
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
    ),
  );
  }

  static void showAllocateSheet(BuildContext context, dynamic item) {
    final allocateDestinationType = RxnString();
    final allocateDestination = RxnString();
    final destinationOptions = <DropdownOption<String>>[].obs;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        insetPadding: EdgeInsets.all(20.r),
        child: Container(
          padding: EdgeInsets.all(20.r),
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

              Text(
                'From',
                style: AppTextStyle.style_12_700(color: AppColors.red),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: _buildGreyField('Store Name', item is InventoryItemModel ? item.store : item.unitName),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildGreyField('Item Name', item is InventoryItemModel ? item.item : item.itemName),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: 180.w,
                child: _buildGreyField('Available Qty. (Consumption)', '${item.quantity} ${item is InventoryItemModel ? item.unit : item.mUnit}'),
              ),

              SizedBox(height: 16.h),
              Text(
                'To',
                style: AppTextStyle.style_12_700(color: AppColors.red),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: _buildGreyDropdown('State', 'Odisha'),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildGreyDropdown('District', 'Puri'),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Obx(() => MultiSelectDropdownWidget<String>(
                      title: 'Destination Type',
                      hint: 'Select Destination Type',
                      isSingleSelect: true,
                      height: 28.h,
                      selectedValues: allocateDestinationType.value != null ? {allocateDestinationType.value!} : {},
                      items: [
                        DropdownMenuItem(value: 'unit', child: Text('Unit', style: AppTextStyle.style_12_400(color: AppColors.grey900))),
                        DropdownMenuItem(value: 'store', child: Text('Store', style: AppTextStyle.style_12_400(color: AppColors.grey900))),
                      ],
                      onChanged: (values) => allocateDestinationType.value = values.isNotEmpty ? values.first : null,
                    )),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Obx(() => MultiSelectDropdownWidget<String>(
                      title: 'Destination',
                      hint: 'Choose Destination',
                      isSingleSelect: true,
                      height: 28.h,
                      selectedValues: allocateDestination.value != null ? {allocateDestination.value!} : {},
                      items: destinationOptions.map((opt) => DropdownMenuItem(value: opt.value, child: Text(opt.label, style: AppTextStyle.style_12_400(color: AppColors.grey900)))).toList(),
                      onChanged: (values) => allocateDestination.value = values.isNotEmpty ? values.first : null,
                    )),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: 180.w,
                child: _buildWhiteInput('Allocate Qty. (Consumption)', 'Enter Qty.'),
              ),

              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppCommonButton(
                    text: 'Cancel',
                    width: 100.w,
                    height: 28.h,
                    variant: ButtonVariant.outline,
                    onPressed: () => Get.back(),
                  ),
                  SizedBox(width: 12.w),
                  AppCommonButton(
                    text: 'Submit',
                    width: 100.w,
                    height: 28.h,
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
      ),
    );
  }

  static void showConsumptionSheet(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        insetPadding: EdgeInsets.all(20.r),
        child: Container(
          padding: EdgeInsets.all(20.r),
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
                    child: _buildSmallVerticalWhiteField('Store', item is InventoryItemModel ? item.store : item.unitName),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildSmallVerticalWhiteField('Item Name', item is InventoryItemModel ? item.item : item.itemName),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: _buildSmallVerticalWhiteField('Available Qty.', '${item.quantity}'),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildSmallVerticalWhiteField('Consumption Qty.', 'Enter Qty.', isInput: true),
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
                    height: 28.h,
                    variant: ButtonVariant.outline,
                    onPressed: () => Get.back(),
                  ),
                  SizedBox(width: 12.w),
                  AppCommonButton(
                    text: 'Submit',
                    width: 100.w,
                    height: 28.h,
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
      ),
    );
  }
}
