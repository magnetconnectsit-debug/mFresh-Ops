import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:services/api_services.dart';
import '../../../../data/models/inventory/inventory_item_model.dart';
import '../../controllers/unit_inventory_controller.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';

class StoreInventoryDialogs {
  static Widget _buildGreyField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.style_12_500(color: AppColors.black300),
        ),
        SizedBox(height: 6.h),
        Container(
          height: 32.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            hint,
            style: AppTextStyle.style_12_400(color: AppColors.grey500),
          ),
        ),
      ],
    );
  }



  static Widget _buildWhiteInput(
    String label,
    String hint, {
    TextEditingController? controller,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.style_12_500(color: AppColors.black300),
        ),
        SizedBox(height: 6.h),
        Container(
          height: 28.h,
          decoration: BoxDecoration(
            color: readOnly ? const Color(0xFFF1F5F9) : AppColors.white,
            border: Border.all(color: AppColors.grey100),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            readOnly: readOnly,
            textAlignVertical: TextAlignVertical.center,
            style: AppTextStyle.style_12_400(color: AppColors.grey900),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyle.style_12_400(color: AppColors.grey500),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 4.h,
              ),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildSmallVerticalWhiteField(
    String label,
    String hint, {
    bool isInput = false,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.style_12_500(color: AppColors.black300),
        ),
        SizedBox(height: 4.h),
        Container(
          height: 28.h,
          padding: isInput
              ? EdgeInsets.zero
              : EdgeInsets.symmetric(horizontal: 8.w),
          alignment: isInput ? null : Alignment.centerLeft,
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.grey100),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: isInput
              ? TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTextStyle.style_12_400(
                      color: AppColors.grey500,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 8.h,
                    ),
                    isDense: true,
                  ),
                )
              : Text(
                  hint,
                  style: AppTextStyle.style_12_400(color: AppColors.grey500),
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ],
    );
  }

  static void showAddInventorySheet(BuildContext context) {
    final controller = Get.find<InventoryController>();
    controller.selectedAddItemName.value = null;
    controller.fetchStores('', '');

    final selectedState = RxnString();
    final selectedDistrict = RxnString();
    final selectedStore = RxnString();
    final selectedCategory = RxnString();

    final packetController = TextEditingController();
    final pieceController = TextEditingController();
    final consumptionController = TextEditingController();

    // Reset controllers and apply default values when the selected item changes
    controller.selectedAddItemName.listen((itemId) {
      packetController.clear();
      pieceController.clear();
      consumptionController.clear();
    });

    void calculateQty() {
      final selectedId = controller.selectedAddItemName.value;
      if (selectedId != null) {
        final unit = (controller.itemUnits[selectedId] ?? '').toLowerCase();
        if (unit == 'packet' || unit == 'box') {
          final pkts = double.tryParse(packetController.text) ?? 0;
          final pcs = double.tryParse(pieceController.text) ?? 0;
          final total = pkts * pcs;
          consumptionController.text = total > 0
              ? (total % 1 == 0 ? total.toInt().toString() : total.toString())
              : '';
        }
      }
    }

    packetController.addListener(calculateQty);
    pieceController.addListener(calculateQty);

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
                      child: Obx(
                        () => MultiSelectDropdownWidget<String>(
                          title: 'State',
                          isSingleSelect: true,
                          selectedValues: selectedState.value != null
                              ? {selectedState.value!}
                              : {},
                          items: controller.stateOptions
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
                            final v = values.isNotEmpty ? values.first : null;
                            selectedState.value = v;
                            selectedDistrict.value = null;
                            selectedStore.value = null;
                            if (v != null) {
                              controller.fetchDistricts(v);
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Obx(
                        () => MultiSelectDropdownWidget<String>(
                          title: 'District',
                          isSingleSelect: true,
                          selectedValues: selectedDistrict.value != null
                              ? {selectedDistrict.value!}
                              : {},
                          items: selectedState.value == null
                              ? []
                              : controller.districtOptions
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
                            final v = values.isNotEmpty ? values.first : null;
                            selectedDistrict.value = v;
                            selectedStore.value = null;
                            if (v != null && selectedState.value != null) {
                              controller.fetchStores(selectedState.value!, v);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Obx(
                        () => MultiSelectDropdownWidget<String>(
                          title: 'Store Name',
                          isSingleSelect: true,
                          selectedValues: selectedStore.value != null
                              ? {selectedStore.value!}
                              : {},
                          items: controller.storeOptions
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
                            final v = values.isNotEmpty ? values.first : null;
                            selectedStore.value = v;
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Obx(
                        () => MultiSelectDropdownWidget<String>(
                          title: 'Category',
                          isSingleSelect: true,
                          selectedValues: selectedCategory.value != null
                              ? {selectedCategory.value!}
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
                            final v = values.isNotEmpty ? values.first : null;
                            selectedCategory.value = v;
                            controller.onCategorySelected(v);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Obx(
                  () => MultiSelectDropdownWidget<String>(
                    title: 'Item Name',
                    isSingleSelect: true,
                    selectedValues: controller.selectedAddItemName.value != null
                        ? {controller.selectedAddItemName.value!}
                        : {},
                    items: controller.itemOptions
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
                      final v = values.isNotEmpty ? values.first : null;
                      controller.selectedAddItemName.value = v;
                    },
                  ),
                ),
                Obx(() {
                  final selectedId = controller.selectedAddItemName.value;
                  if (selectedId == null) {
                    return const SizedBox();
                  }
                  final unit = (controller.itemUnits[selectedId] ?? '')
                      .toLowerCase();

                  if (unit == 'litre') {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.h),
                        _buildWhiteInput(
                          'Consumption Quantity (ml)',
                          'Enter in ml',
                          controller: consumptionController,
                        ),
                      ],
                    );
                  } else if (unit == 'piece' || unit == 'pcs') {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.h),
                        _buildWhiteInput(
                          'Consumption Quantity',
                          'Enter Pieces',
                          controller: consumptionController,
                        ),
                      ],
                    );
                  } else if (unit == 'packet' || unit == 'box') {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildWhiteInput(
                                'Packets',
                                'Enter Packets',
                                controller: packetController,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              flex: 3,
                              child: _buildWhiteInput(
                                'Piece (per Pkt)',
                                'Enter pieces per packet',
                                controller: pieceController,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        _buildWhiteInput(
                          'Consumption Qty',
                          'Auto Calc (Pkt x Pcs)',
                          controller: consumptionController,
                          readOnly: true,
                        ),
                      ],
                    );
                  } else if (unit == 'pair') {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.h),
                        _buildWhiteInput(
                          'Consumption Quantity (Pair)',
                          'Enter Pairs',
                          controller: consumptionController,
                        ),
                      ],
                    );
                  } else if (unit == 'kg') {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.h),
                        _buildWhiteInput(
                          'Consumption Quantity (g)',
                          'Enter in grams',
                          controller: consumptionController,
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.h),
                        _buildWhiteInput(
                          'Consumption Qty.',
                          'Enter Qty.',
                          controller: consumptionController,
                        ),
                      ],
                    );
                  }
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
                      onPressed: () async {
                        if (selectedState.value == null) {
                          AppCommonToastMessage.show(
                            message: 'Please select state',
                            type: ToastType.error,
                          );
                          return;
                        }
                        if (selectedDistrict.value == null) {
                          AppCommonToastMessage.show(
                            message: 'Please select district',
                            type: ToastType.error,
                          );
                          return;
                        }
                        if (selectedStore.value == null) {
                          AppCommonToastMessage.show(
                            message: 'Please select store',
                            type: ToastType.error,
                          );
                          return;
                        }
                        if (selectedCategory.value == null) {
                          AppCommonToastMessage.show(
                            message: 'Please select category',
                            type: ToastType.error,
                          );
                          return;
                        }
                        if (controller.selectedAddItemName.value == null) {
                          AppCommonToastMessage.show(
                            message: 'Please select item',
                            type: ToastType.error,
                          );
                          return;
                        }

                        final itemId = controller.selectedAddItemName.value!;
                        final unit = (controller.itemUnits[itemId] ?? '')
                            .toLowerCase();

                        String packetQty = "";
                        String pieceQty = "";
                        String literQty = "";

                        if (unit == 'litre') {
                          literQty = consumptionController.text;
                          if (literQty.isEmpty) {
                            AppCommonToastMessage.show(
                              message: 'Please enter consumption quantity',
                              type: ToastType.error,
                            );
                            return;
                          }
                        } else if (unit == 'packet' || unit == 'box') {
                          packetQty = packetController.text;
                          pieceQty = pieceController.text;
                          if (packetQty.isEmpty) {
                            AppCommonToastMessage.show(
                              message: 'Please enter packets quantity',
                              type: ToastType.error,
                            );
                            return;
                          }
                          if (pieceQty.isEmpty) {
                            AppCommonToastMessage.show(
                              message:
                                  'Please enter pieces per packet quantity',
                              type: ToastType.error,
                            );
                            return;
                          }
                        } else {
                          // pcs / pieces, kg, pair, gram, etc.
                          pieceQty = consumptionController.text;
                          if (pieceQty.isEmpty) {
                            AppCommonToastMessage.show(
                              message: 'Please enter quantity',
                              type: ToastType.error,
                            );
                            return;
                          }
                        }

                        Get.back();
                        await controller.addStoreStock(
                          stateId: selectedState.value!,
                          districtId: selectedDistrict.value!,
                          storeId: selectedStore.value!,
                          categoryId: selectedCategory.value!,
                          itemId: itemId,
                          packetQty: packetQty,
                          pieceQty: pieceQty,
                          literQty: literQty,
                        );
                      },
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
    final qtyController = TextEditingController();

    final selectedState = RxnString();
    final selectedDistrict = RxnString();
    final stateOptions = <DropdownOption<String>>[].obs;
    final districtOptions = <DropdownOption<String>>[].obs;

    final repository = Get.find<InventoryRepository>();

    final String? itemStateId = item.stateId?.toString();
    final String? itemDistrictId = item.districtId?.toString();

    selectedState.value = (itemStateId != null && itemStateId.isNotEmpty) ? itemStateId : null;
    selectedDistrict.value = (itemDistrictId != null && itemDistrictId.isNotEmpty) ? itemDistrictId : null;

    Future<void> loadStates() async {
      try {
        final response = await repository.getStates();
        if (response != null && response['status'] == 'success') {
          final List data = response['data'] ?? [];
          stateOptions.assignAll(
            data.map((e) => DropdownOption<String>(
              value: e['id']?.toString() ?? '',
              label: e['state_name']?.toString() ?? '',
            )).toList()
          );
        }
      } catch (e) {
        debugPrint('Error loading states in dialog: $e');
      }
    }

    Future<void> loadDistricts(String stateId) async {
      districtOptions.clear();
      try {
        final response = await repository.getDistricts(stateId);
        if (response != null && response['status'] == 'success') {
          final List data = response['data'] ?? [];
          districtOptions.assignAll(
            data.map((e) => DropdownOption<String>(
              value: e['district_id']?.toString() ?? '',
              label: e['district_name']?.toString() ?? '',
            )).toList()
          );
        }
      } catch (e) {
        debugPrint('Error loading districts in dialog: $e');
      }
    }

    Future<void> updateDestinations(String? type) async {
      debugPrint('🔍 [dialog] updateDestinations called with type: $type');
      allocateDestination.value = null;
      destinationOptions.clear();
      if (type == null) return;

      final apiService = Get.find<ApiService>();
      if (type == 'unit') {
        try {
          debugPrint('🔍 [dialog] Fetching support-units. State: ${selectedState.value}, District: ${selectedDistrict.value}');
          final response = await apiService.post(
            'support-units',
            data: {
              'state': selectedState.value ?? '',
              'district': selectedDistrict.value ?? '',
            },
          );
          debugPrint('🔍 [dialog] support-units response: $response');
          if (response != null && (response['status'] == true || response['status'] == 'success')) {
            final List data = response['data'] ?? [];
            destinationOptions.assignAll(
              data
                  .map(
                    (e) => DropdownOption<String>(
                      value:
                          e['unitid']?.toString() ?? e['id']?.toString() ?? '',
                      label: e['unitname']?.toString() ?? '',
                    ),
                  )
                  .toList(),
            );
          }
        } catch (e) {
          debugPrint('❌ [dialog] Error fetching units in dialog: $e');
        }
      } else if (type == 'store') {
        try {
          debugPrint('🔍 [dialog] Fetching inv-stores...');
          final response = await apiService.post(
            'inv-stores',
            data: {
              'state': '',
              'district': '',
            },
          );
          debugPrint('🔍 [dialog] inv-stores response: $response');
          if (response != null && (response['status'] == 'success' || response['status'] == true)) {
            final List data = response['data'] ?? [];
            destinationOptions.assignAll(
              data
                  .map(
                    (e) => DropdownOption<String>(
                      value: e['storeid']?.toString() ?? '',
                      label: e['storeroom_name']?.toString() ?? '',
                    ),
                  )
                  .toList(),
            );
            debugPrint('🔍 [dialog] Populated destinationOptions: ${destinationOptions.map((e) => '${e.label} (${e.value})').toList()}');
          }
        } catch (e) {
          debugPrint('❌ [dialog] Error fetching stores in dialog: $e');
        }
      }
    }

    loadStates().then((_) {
      if (selectedState.value != null) {
        loadDistricts(selectedState.value!).then((_) {
          if (allocateDestinationType.value != null) {
            updateDestinations(allocateDestinationType.value!);
          }
        });
      }
    });

    ever(allocateDestinationType, (type) {
      debugPrint('🔍 [dialog] ever worker triggered for destination type: $type');
      updateDestinations(type);
    });

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
                      child: _buildGreyField(
                        'Store Name',
                        item is InventoryItemModel ? item.store : item.unitName,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildGreyField(
                        'Item Name',
                        item is InventoryItemModel ? item.item : item.itemName,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  width: 180.w,
                  child: _buildGreyField(
                    'Available Qty. (Consumption)',
                    '${item.quantity} ${item is InventoryItemModel ? item.unit : item.mUnit}',
                  ),
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
                      child: Obx(
                        () => MultiSelectDropdownWidget<String>(
                          title: 'State',
                          isSingleSelect: true,
                          height: 28.h,
                          selectedValues: selectedState.value != null
                              ? {selectedState.value!}
                              : {},
                          items: stateOptions
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
                            final v = values.isNotEmpty ? values.first : null;
                            selectedState.value = v;
                            selectedDistrict.value = null;
                            districtOptions.clear();
                            if (v != null) {
                              loadDistricts(v);
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Obx(
                        () => MultiSelectDropdownWidget<String>(
                          title: 'District',
                          isSingleSelect: true,
                          height: 28.h,
                          selectedValues: selectedDistrict.value != null
                              ? {selectedDistrict.value!}
                              : {},
                          items: selectedState.value == null
                              ? []
                              : districtOptions
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
                            final v = values.isNotEmpty ? values.first : null;
                            selectedDistrict.value = v;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Obx(
                        () => MultiSelectDropdownWidget<String>(
                          title: 'Destination Type',
                          hint: 'Select Destination Type',
                          isSingleSelect: true,
                          height: 28.h,
                          selectedValues: allocateDestinationType.value != null
                              ? {allocateDestinationType.value!}
                              : {},
                          items: [
                            DropdownMenuItem<String>(
                              value: 'unit',
                              child: Text(
                                'Unit',
                                style: AppTextStyle.style_12_400(
                                  color: AppColors.grey900,
                                ),
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: 'store',
                              child: Text(
                                'Store',
                                style: AppTextStyle.style_12_400(
                                  color: AppColors.grey900,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (values) {
                            final type = values.isNotEmpty
                                ? values.first
                                : null;
                            allocateDestinationType.value = type;
                            updateDestinations(type);
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Obx(
                        () => MultiSelectDropdownWidget<String>(
                          title: 'Destination',
                          hint: 'Choose Destination',
                          isSingleSelect: true,
                          height: 28.h,
                          selectedValues: allocateDestination.value != null
                              ? {allocateDestination.value!}
                              : {},
                          items: destinationOptions
                              .map(
                                (opt) => DropdownMenuItem<String>(
                                  value: opt.value,
                                  child: Text(
                                    opt.label,
                                    style: AppTextStyle.style_12_400(
                                      color: AppColors.grey900,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (values) => allocateDestination.value =
                              values.isNotEmpty ? values.first : null,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  width: 180.w,
                  child: (() {
                    final unit =
                        (item is InventoryItemModel
                                ? item.unit
                                : (item as UnitInventoryModel).mUnit)
                            .toLowerCase();
                    if (unit == 'litre') {
                      return _buildWhiteInput(
                        'Allocate Quantity (ml)',
                        'Enter in ml',
                        controller: qtyController,
                      );
                    } else if (unit == 'piece' || unit == 'pcs') {
                      return _buildWhiteInput(
                        'Allocate Quantity',
                        'Enter Pieces',
                        controller: qtyController,
                      );
                    } else if (unit == 'pair') {
                      return _buildWhiteInput(
                        'Allocate Quantity (Pair)',
                        'Enter Pairs',
                        controller: qtyController,
                      );
                    } else if (unit == 'kg') {
                      return _buildWhiteInput(
                        'Allocate Quantity (g)',
                        'Enter in grams',
                        controller: qtyController,
                      );
                    } else if (unit == 'packet' || unit == 'box') {
                      return _buildWhiteInput(
                        'Allocate Quantity (Packet)',
                        'Enter Packets',
                        controller: qtyController,
                      );
                    } else {
                      return _buildWhiteInput(
                        'Allocate Qty. (Consumption)',
                        'Enter Qty.',
                        controller: qtyController,
                      );
                    }
                  })(),
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
                      onPressed: () async {
                        final qty = qtyController.text;
                        if (qty.isEmpty) {
                          AppCommonToastMessage.show(
                            message: 'Please enter quantity',
                            type: ToastType.error,
                          );
                          return;
                        }
                        final enteredQty = double.tryParse(qty) ?? 0;
                        final availableQty =
                            double.tryParse(item.quantity?.toString() ?? '0') ??
                            0;
                        if (enteredQty <= 0) {
                          AppCommonToastMessage.show(
                            message:
                                'Please enter a valid quantity greater than 0',
                            type: ToastType.error,
                          );
                          return;
                        }
                        if (enteredQty > availableQty) {
                          AppCommonToastMessage.show(
                            message:
                                'Not enough quantity available. Maximum: $availableQty',
                            type: ToastType.error,
                          );
                          return;
                        }
                        if (allocateDestinationType.value == null ||
                            allocateDestination.value == null) {
                          AppCommonToastMessage.show(
                            message: 'Please select destination',
                            type: ToastType.error,
                          );
                          return;
                        }
                        Get.back();
                        if (item is InventoryItemModel) {
                          final controller = Get.find<InventoryController>();
                          await controller.allocateStock(
                            item,
                            qty,
                            allocateDestinationType.value!,
                            allocateDestination.value!,
                            destStateId: selectedState.value,
                            destDistrictId: selectedDistrict.value,
                          );
                        } else {
                          try {
                            final controller =
                                Get.find<UnitInventoryController>();
                            await controller.allocateStock(
                              item,
                              qty,
                              allocateDestinationType.value!,
                              allocateDestination.value!,
                              destStateId: selectedState.value,
                              destDistrictId: selectedDistrict.value,
                            );
                          } catch (e) {
                            AppCommonToastMessage.show(
                              message: 'Controller not found',
                              type: ToastType.error,
                            );
                          }
                        }
                      },
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
    final qtyController = TextEditingController();
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
                      child: _buildSmallVerticalWhiteField(
                        'Store',
                        item is InventoryItemModel ? item.store : item.unitName,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildSmallVerticalWhiteField(
                        'Item Name',
                        item is InventoryItemModel ? item.item : item.itemName,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _buildSmallVerticalWhiteField(
                        'Available Qty.',
                        '${item.quantity}',
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: (() {
                        final unit =
                            (item is InventoryItemModel
                                    ? item.unit
                                    : (item as UnitInventoryModel).mUnit)
                                .toLowerCase();
                        if (unit == 'litre') {
                          return _buildSmallVerticalWhiteField(
                            'Consumption Quantity (ml)',
                            'Enter in ml',
                            isInput: true,
                            controller: qtyController,
                          );
                        } else if (unit == 'piece' || unit == 'pcs') {
                          return _buildSmallVerticalWhiteField(
                            'Consumption Quantity',
                            'Enter Pieces',
                            isInput: true,
                            controller: qtyController,
                          );
                        } else if (unit == 'pair') {
                          return _buildSmallVerticalWhiteField(
                            'Consumption Quantity (Pair)',
                            'Enter Pairs',
                            isInput: true,
                            controller: qtyController,
                          );
                        } else if (unit == 'kg') {
                          return _buildSmallVerticalWhiteField(
                            'Consumption Quantity (g)',
                            'Enter in grams',
                            isInput: true,
                            controller: qtyController,
                          );
                        } else if (unit == 'packet' || unit == 'box') {
                          return _buildSmallVerticalWhiteField(
                            'Consumption Quantity (Packet)',
                            'Enter Packets',
                            isInput: true,
                            controller: qtyController,
                          );
                        } else {
                          return _buildSmallVerticalWhiteField(
                            'Consumption Qty.',
                            'Enter Qty.',
                            isInput: true,
                            controller: qtyController,
                          );
                        }
                      })(),
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
                      onPressed: () async {
                        final qty = qtyController.text;
                        if (qty.isEmpty) {
                          AppCommonToastMessage.show(
                            message: 'Please enter quantity',
                            type: ToastType.error,
                          );
                          return;
                        }
                        final enteredQty = double.tryParse(qty) ?? 0;
                        final availableQty =
                            double.tryParse(item.quantity?.toString() ?? '0') ??
                            0;
                        if (enteredQty <= 0) {
                          AppCommonToastMessage.show(
                            message:
                                'Please enter a valid quantity greater than 0',
                            type: ToastType.error,
                          );
                          return;
                        }
                        if (enteredQty > availableQty) {
                          AppCommonToastMessage.show(
                            message:
                                'Not enough quantity available. Maximum: $availableQty',
                            type: ToastType.error,
                          );
                          return;
                        }
                        Get.back(); // Close dialog first to avoid Get.back() hitting the snackbar overlay
                        if (item is InventoryItemModel) {
                          final controller = Get.find<InventoryController>();
                          await controller.consumeStock(item, qty);
                        } else {
                          try {
                            final controller =
                                Get.find<UnitInventoryController>();
                            await controller.consumeStock(item, qty);
                          } catch (e) {
                            AppCommonToastMessage.show(
                              message: 'Controller not found',
                              type: ToastType.error,
                            );
                          }
                        }
                      },
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
