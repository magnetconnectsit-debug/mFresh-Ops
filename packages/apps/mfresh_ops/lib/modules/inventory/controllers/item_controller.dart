import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/utils/app_export_utils.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';

class ItemController extends GetxController {
  final InventoryRepository _inventoryRepository = Get.find<InventoryRepository>();
  final isSearching = false.obs;
  final searchController = TextEditingController();
  final isExporting = false.obs;
  final isExportingPdf = false.obs;
  final isLoading = false.obs;

  final itemNameController = TextEditingController();
  final itemIdController = TextEditingController();
  final lowQuantityStoreController = TextEditingController();
  final lowQuantityUnitController = TextEditingController();

  final selectedMeasurement = RxnString();
  final selectedCategory = RxnString();

  final measurementOptions = <DropdownOption<String>>[
    DropdownOption(value: '1', label: 'Litre'),
    DropdownOption(value: '2', label: 'Packet'),
    DropdownOption(value: '3', label: 'Piece'),
    DropdownOption(value: '4', label: 'Kg'),
    DropdownOption(value: '5', label: 'Gram'),
    DropdownOption(value: '6', label: 'Pair'),
  ].obs;

  final categoryOptions = <DropdownOption<String>>[].obs;

  final allItems = <ItemModel>[].obs;
  final filteredItems = <ItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    initController();
  }

  Future<void> initController() async {
    isLoading.value = true;
    await fetchCategories();
    await fetchItems();
    isLoading.value = false;
  }

  Future<void> onRefresh() async {
    await fetchCategories();
    await fetchItems();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await _inventoryRepository.getCategories();
      if (response != null && response['status'] == 'success') {
        final List data = response['data'] ?? [];
        categoryOptions.assignAll(data.map((e) => DropdownOption<String>(
          value: e['categoryID'].toString(), 
          label: e['invcatgeoryname']?.toString() ?? '',
        )).toList());
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> fetchItems() async {
    try {
      final response = await _inventoryRepository.getAllItems();
      if (response != null && response['status'] == true) {
        final List data = response['data'] ?? [];
        final parsed = data.map((e) => ItemModel.fromJson(e)).toList();
        allItems.assignAll(parsed);
        applyFilters();
      }
    } catch (e) {
      debugPrint('Error fetching items: $e');
      AppCommonToastMessage.show(
        message: "Failed to load items: $e",
        type: ToastType.error,
      );
    }
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      applyFilters();
    }
  }

  void applyFilters() {
    final query = searchController.text.toLowerCase();
    filteredItems.assignAll(
      allItems.where((item) {
        return query.isEmpty ||
            item.itemName.toLowerCase().contains(query) ||
            item.itemId.toLowerCase().contains(query);
      }).toList(),
    );
  }

  String getMeasurementName(String unitId) {
    final match = measurementOptions.firstWhereOrNull((opt) => opt.value == unitId);
    return match?.label ?? 'Unit $unitId';
  }

  String getCategoryName(String catId) {
    final option = categoryOptions.firstWhereOrNull((opt) => opt.value == catId);
    return option?.label ?? 'Category $catId';
  }

  Future<void> exportToExcel() async {
    isExporting.value = true;
    await AppExportUtils.exportToExcel(
      title: 'Items Report',
      columns: const ["SI No", "Item Name", "Item Id", "Measurement", "Category"],
      rows: filteredItems.asMap().entries
          .map(
            (entry) => [
              entry.key + 1,
              entry.value.itemName,
              entry.value.itemId,
              getMeasurementName(entry.value.measurementUnitId),
              getCategoryName(entry.value.categoryInv),
            ],
          )
          .toList(),
    );
    isExporting.value = false;
  }

  Future<void> exportToPdf() async {
    isExportingPdf.value = true;
    await AppExportUtils.exportToPdf(
      title: 'Items Report',
      columns: const ["SI No", "Item Name", "Item Id", "Measurement", "Category"],
      rows: filteredItems.asMap().entries
          .map(
            (entry) => [
              entry.key + 1,
              entry.value.itemName,
              entry.value.itemId,
              getMeasurementName(entry.value.measurementUnitId),
              getCategoryName(entry.value.categoryInv),
            ],
          )
          .toList(),
    );
    isExportingPdf.value = false;
  }

  Future<bool> addItem() async {
    if (itemNameController.text.isEmpty ||
        itemIdController.text.isEmpty ||
        selectedMeasurement.value == null ||
        selectedCategory.value == null) {
      AppCommonToastMessage.show(
        message: "Please fill all required fields",
        type: ToastType.error,
      );
      return false;
    }

    isLoading.value = true;
    try {
      final response = await _inventoryRepository.createItem(
        itemName: itemNameController.text.trim(),
        itemId: itemIdController.text.trim(),
        measurementUnitId: int.parse(selectedMeasurement.value!),
        categoryId: int.parse(selectedCategory.value!),
        lowQtyStore: int.tryParse(lowQuantityStoreController.text) ?? 0,
        lowQtyUnit: lowQuantityUnitController.text.trim(),
      );

      if (response != null && response['status'] == 'success') {
        AppCommonToastMessage.show(
          message: response['message']?.toString() ?? "Item created successfully",
          type: ToastType.success,
        );
        await fetchItems();
        return true;
      } else {
        AppCommonToastMessage.show(
          message: response?['message']?.toString() ?? "Failed to create item",
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Error creating item: $e",
        type: ToastType.error,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clearControllers() {
    itemNameController.clear();
    itemIdController.clear();
    lowQuantityStoreController.clear();
    lowQuantityUnitController.clear();
    selectedMeasurement.value = null;
    selectedCategory.value = null;
  }

  void prepareAddDialog() {
    clearControllers();
    if (allItems.isNotEmpty) {
      int maxId = 0;
      for (var item in allItems) {
        final idVal = int.tryParse(item.itemId) ?? 0;
        if (idVal > maxId) {
          maxId = idVal;
        }
      }
      if (maxId > 0) {
        itemIdController.text = (maxId + 1).toString();
      }
    }
  }

  Future<bool> editItem(int primaryId) async {
    if (itemNameController.text.isEmpty ||
        itemIdController.text.isEmpty ||
        selectedMeasurement.value == null ||
        selectedCategory.value == null) {
      AppCommonToastMessage.show(
        message: "Please fill all required fields",
        type: ToastType.error,
      );
      return false;
    }

    isLoading.value = true;
    try {
      final response = await _inventoryRepository.updateItem(
        primaryId: primaryId,
        itemName: itemNameController.text.trim(),
        itemId: itemIdController.text.trim(),
        measurementUnitId: int.parse(selectedMeasurement.value!),
        categoryId: int.parse(selectedCategory.value!),
        lowQtyStore: int.tryParse(lowQuantityStoreController.text) ?? 0,
        lowQtyUnit: lowQuantityUnitController.text.trim(),
      );

      if (response != null && response['status'] == 'success') {
        AppCommonToastMessage.show(
          message: response['message']?.toString() ?? "Item updated successfully",
          type: ToastType.success,
        );
        await fetchItems();
        return true;
      } else {
        AppCommonToastMessage.show(
          message: response?['message']?.toString() ?? "Failed to update item",
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Error updating item: $e",
        type: ToastType.error,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    itemNameController.dispose();
    itemIdController.dispose();
    lowQuantityStoreController.dispose();
    lowQuantityUnitController.dispose();
    super.onClose();
  }
}

class ItemModel {
  final int id;
  final String itemName;
  final String itemId;
  final String measurementUnitId;
  final String categoryInv;
  final String lowQnty;
  final String lowQntyUnit;

  ItemModel({
    required this.id,
    required this.itemName,
    required this.itemId,
    required this.measurementUnitId,
    required this.categoryInv,
    required this.lowQnty,
    required this.lowQntyUnit,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] is int 
          ? json['id'] 
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      itemName: json['item_name']?.toString() ?? '',
      itemId: json['item_id']?.toString() ?? '',
      measurementUnitId: json['measurement_unit_id']?.toString() ?? '',
      categoryInv: json['category_inv']?.toString() ?? '',
      lowQnty: json['low_qnty']?.toString() ?? '',
      lowQntyUnit: json['low_qnty_unit']?.toString() ?? '',
    );
  }
}
