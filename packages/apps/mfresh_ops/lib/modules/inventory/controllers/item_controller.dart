import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/utils/app_export_utils.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/data/models/inventory/item_model.dart';

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

  final measurementOptions = <DropdownOption<String>>[].obs;

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
    await fetchMeasurements();
    await fetchCategories();
    await fetchItems();
    isLoading.value = false;
  }

  Future<void> onRefresh() async {
    try {
      if (Get.isRegistered<AuthRepository>()) {
        await Get.find<AuthRepository>().fetchProfile();
      }
    } catch (_) {}
    await fetchMeasurements();
    await fetchCategories();
    await fetchItems();
  }

  Future<void> fetchMeasurements() async {
    try {
      final response = await _inventoryRepository.getMeasurements();
      if (response != null && response['status'] == 'success') {
        final List data = response['data'] ?? [];
        measurementOptions.assignAll(data.map((e) => DropdownOption<String>(
          value: e['id'].toString(), 
          label: e['measurement_unit']?.toString() ?? '',
        )).toList());
      }
    } catch (e) {
      debugPrint('Error fetching measurements: $e');
    }
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
    currentPage.value = 1;
  }

  // Sorting logic
  final sortColumn = ''.obs;
  final sortAscending = true.obs;

  void sortBy(String column) {
    if (sortColumn.value == column) {
      if (sortAscending.value) {
        sortAscending.value = false;
      } else {
        sortColumn.value = '';
        sortAscending.value = true;
      }
    } else {
      sortColumn.value = column;
      sortAscending.value = true;
    }
  }

  List<ItemModel> get sortedItems {
    final list = [...filteredItems];
    if (sortColumn.value.isEmpty) return list;

    final col = sortColumn.value;
    final asc = sortAscending.value;

    int compareStr(String a, String b) {
      return asc
          ? a.toLowerCase().compareTo(b.toLowerCase())
          : b.toLowerCase().compareTo(a.toLowerCase());
    }

    list.sort((a, b) {
      switch (col) {
        case 'Item Name':
          return compareStr(a.itemName, b.itemName);
        case 'Item ID':
          return compareStr(a.itemId, b.itemId);
        case 'Measurement':
          return compareStr(
            getMeasurementName(a.measurementUnitId),
            getMeasurementName(b.measurementUnitId),
          );
        default:
          return 0;
      }
    });
    return list;
  }

  // Pagination
  final currentPage = 1.obs;
  final perPage = 10.obs;

  int get totalEntries => filteredItems.length;
  int get totalPages => (totalEntries / perPage.value).ceil().clamp(1, 999999);

  List<ItemModel> get paginatedItems {
    final list = sortedItems;
    final startIndex = (currentPage.value - 1) * perPage.value;
    final endIndex = startIndex + perPage.value;
    if (startIndex >= list.length) return [];
    return list.sublist(
      startIndex,
      endIndex > list.length ? list.length : endIndex,
    );
  }

  void nextPage() {
    if (currentPage.value < totalPages) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
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
      columns: const ["Sl No", "Item Name", "Item ID", "Measurement"],
      rows: filteredItems.asMap().entries
          .map(
            (entry) => [
              entry.key + 1,
              entry.value.itemName,
              entry.value.itemId,
              getMeasurementName(entry.value.measurementUnitId),
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
      columns: const ["Sl No", "Item Name", "Item ID", "Measurement"],
      rows: filteredItems.asMap().entries
          .map(
            (entry) => [
              entry.key + 1,
              entry.value.itemName,
              entry.value.itemId,
              getMeasurementName(entry.value.measurementUnitId),
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
