import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:core/utils/app_export_utils.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/data/models/inventory/unit_inventory_model.dart';

class UnitInventoryController extends GetxController {
  final InventoryRepository _inventoryRepository = Get.find<InventoryRepository>();

  final isSearching = false.obs;
  final isLoading = false.obs;
  final searchController = TextEditingController();
  final isExporting = false.obs;

  // Filter states
  final selectedUnits = <String>[].obs;
  final selectedItems = <String>[].obs;
  final selectedCategories = <String>[].obs;

  // Filter options (populated dynamically from the data)
  final unitOptions = <DropdownOption>[].obs;
  final itemOptions = <DropdownOption>[].obs;
  final categoryOptions = <DropdownOption>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSupportUnits();
    fetchSupportCategories();
    fetchSupportItems();
    fetchUnitInventory();
  }

  Future<void> fetchSupportUnits() async {
    try {
      final response = await _inventoryRepository.getSupportUnits();
      if (response != null && response['status'] == true) {
        final List data = response['data'] ?? [];
        final units = data.map((e) => DropdownOption(
          value: (e['unitid'] ?? e['id'])?.toString() ?? '',
          label: e['unitname']?.toString() ?? ''
        )).toList();
        unitOptions.assignAll(units);
      }
    } catch (e) {
      debugPrint('Error fetching support units: $e');
    }
  }

  Future<void> fetchSupportCategories() async {
    try {
      final response = await _inventoryRepository.getCategories();
      if (response != null && response['status'] == 'success') {
        final List data = response['data'] ?? [];
        final categories = data.map((e) => DropdownOption(
          value: e['categoryID']?.toString() ?? '',
          label: e['invcatgeoryname']?.toString() ?? ''
        )).toList();
        categoryOptions.assignAll(categories);
      }
    } catch (e) {
      debugPrint('Error fetching support categories: $e');
    }
  }

  Future<void> fetchSupportItems() async {
    try {
      final response = await _inventoryRepository.getAllItems();
      if (response != null && response['status'] == true) {
        final List data = response['data'] ?? [];
        final items = data.map((e) => DropdownOption(
          value: e['id']?.toString() ?? '',
          label: e['item_name']?.toString() ?? ''
        )).toList();
        itemOptions.assignAll(items);
      }
    } catch (e) {
      debugPrint('Error fetching support items: $e');
    }
  }

  Future<void> fetchUnitInventory() async {
    isLoading.value = true;
    try {
      final response = await _inventoryRepository.getUnitInventoryStock(
        itemId: selectedItems.map((e) => int.tryParse(e)).whereType<int>().toList(),
        unitId: selectedUnits.map((e) => int.tryParse(e)).whereType<int>().toList(),
        categoryId: selectedCategories.map((e) => int.tryParse(e)).whereType<int>().toList(),
        stateId: '',
        districtId: '',
      );

      if (response != null && response['status'] == true) {
        final List data = response['data'] ?? [];
        final items = data.map((e) => UnitInventoryModel.fromJson(e)).toList();
        final reversedItems = items.reversed.toList();

        final query = searchController.text.toLowerCase();
        if (query.isNotEmpty) {
          unitInventoryItems.assignAll(reversedItems.where((item) => 
            item.itemName.toLowerCase().contains(query) ||
            item.unitName.toLowerCase().contains(query) ||
            item.categoryName.toLowerCase().contains(query)
          ).toList());
        } else {
          unitInventoryItems.assignAll(reversedItems);
        }
      } else {
        unitInventoryItems.clear();
      }
    } catch (e) {
      debugPrint('Error fetching unit inventory: $e');
      unitInventoryItems.clear();
    } finally {
      isLoading.value = false;
    }
  }

  final unitInventoryItems = <UnitInventoryModel>[].obs;

  // Pagination
  final currentPage = 1.obs;
  final itemsPerPage = 10.obs;

  int get totalPages => (unitInventoryItems.length / itemsPerPage.value).ceil();

  List<UnitInventoryModel> get paginatedItems {
    final startIndex = (currentPage.value - 1) * itemsPerPage.value;
    final endIndex = startIndex + itemsPerPage.value;
    if (startIndex >= unitInventoryItems.length) return [];
    return unitInventoryItems.sublist(
        startIndex, endIndex > unitInventoryItems.length ? unitInventoryItems.length : endIndex);
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

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      applyFilters();
    }
  }

  Future<void> onRefresh() async {
    try {
      await Get.find<AuthRepository>().fetchProfile();
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }

    // Reset filters
    selectedUnits.clear();
    selectedItems.clear();
    selectedCategories.clear();
    searchController.clear();
    currentPage.value = 1;

    await Future.wait([
      fetchSupportUnits(),
      fetchSupportCategories(),
      fetchSupportItems(),
      fetchUnitInventory(),
    ]);
  }

  void applyFilters() {
    currentPage.value = 1;
    fetchUnitInventory();
  }

  Future<void> exportToExcel() async {
    isExporting.value = true;
    await AppExportUtils.exportToExcel(
      title: 'Unit Inventory Report',
      columns: const ["Unit", "Item", "Category", "Quantity", "M_Unit"],
      rows: unitInventoryItems
          .map((item) => [item.unitName, item.itemName, item.categoryName, item.quantity, item.mUnit])
          .toList(),
    );
    isExporting.value = false;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> allocateStock(
    UnitInventoryModel item,
    String qty,
    String destType,
    String destId, {
    String? destStateId,
    String? destDistrictId,
  }) async {
    try {
      final response = await _inventoryRepository.allocateStock({
        "source_type": "unit",
        "source_id": int.tryParse(item.unitId) ?? 0,
        "item_id": int.tryParse(item.itemId) ?? 0,
        "destination_type": destType,
        "destination_id": int.tryParse(destId) ?? 0,
        "state_id": int.tryParse(destStateId ?? item.stateId) ?? 0,
        "district_id": int.tryParse(destDistrictId ?? item.districtId) ?? 0,
        "allotment_qty": int.tryParse(qty) ?? 0,
        "measurement_unit_id": int.tryParse(item.measurementUnitId) ?? 0,
        "categoryID": int.tryParse(item.categoryId) ?? 0,
      });
      if (response != null && response['status'] == true) {
        AppCommonToastMessage.show(message: response['message'] ?? 'Inventory allocated successfully.', type: ToastType.success);
        await fetchUnitInventory();
      } else {
        AppCommonToastMessage.show(message: response?['message'] ?? 'Failed to allocate inventory.', type: ToastType.error);
      }
    } catch (e) {
      debugPrint('Error allocating unit stock: $e');
      String errorMsg = 'An error occurred during allocation.';
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          errorMsg = data['message']?.toString() ?? errorMsg;
        }
      }
      AppCommonToastMessage.show(message: errorMsg, type: ToastType.error);
    }
  }

  Future<void> consumeStock(UnitInventoryModel item, String qty) async {
    try {
      final response = await _inventoryRepository.consumeStock({

        "source_type": "unit",
        "source_id": int.tryParse(item.unitId) ?? 0,
        "item_id": int.tryParse(item.itemId) ?? 0,
        "consumption_qty": int.tryParse(qty) ?? 0,
        "state_id": int.tryParse(item.stateId) ?? 0,
        "district_id": int.tryParse(item.districtId) ?? 0,
        "measurement_unit_id": int.tryParse(item.measurementUnitId) ?? 0,
        "category_id": int.tryParse(item.categoryId) ?? 0,
      });
      if (response != null && (response['status'] == true || response['status'] == 'success')) {
        AppCommonToastMessage.show(message: response['message'] ?? 'Inventory consumed successfully.', type: ToastType.success);
        await fetchUnitInventory();
      } else {
        AppCommonToastMessage.show(message: response?['message'] ?? 'Failed to consume inventory.', type: ToastType.error);
      }
    } catch (e) {
      debugPrint('Error consuming unit stock: $e');
      AppCommonToastMessage.show(message: 'An error occurred during consumption.', type: ToastType.error);
    }
  }
}
