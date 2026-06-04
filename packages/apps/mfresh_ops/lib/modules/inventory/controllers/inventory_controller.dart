import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:core/utils/app_export_utils.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';
import '../../../../data/models/inventory/inventory_item_model.dart';

class InventoryController extends GetxController {
  final InventoryRepository _inventoryRepository = Get.find<InventoryRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final isSearching = false.obs;
  final searchController = TextEditingController();
  final selectedAddItemName = RxnString();
  final isExporting = false.obs;
  final isExportingPdf = false.obs;

  // Filter states
  final selectedState = RxnString();
  final selectedDistrict = RxnString();
  final selectedStoreRoom = <String>[].obs;
  final selectedStore = <String>[].obs;
  final selectedCategories = <String>[].obs;
  final selectedItems = <String>[].obs;

  // Filter options
  final stateOptions = <DropdownOption>[].obs;
  final districtOptions = <DropdownOption>[].obs;
  final storeOptions = <DropdownOption>[].obs;
  final storeRoomOptions = <DropdownOption>[].obs;
  final categoryOptions = <DropdownOption>[].obs;
  final itemOptions = <DropdownOption>[].obs;
  final itemUnits = <String, String>{}.obs;
  final measurementsMap = <String, String>{}.obs;

  final inventoryItems = <InventoryItemModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    isLoading.value = true;
    await fetchMeasurements();
    await Future.wait([
      fetchStates(),
      fetchCategories(),
      fetchItems(),
      fetchStores('', ''),
      fetchStoreRooms('', ''),
    ]);
    await fetchInventoryStock();
    isLoading.value = false;
  }

  Future<void> fetchStates() async {
    try {
      final response = await _inventoryRepository.getStates();
      if (response != null && response['status'] == 'success') {
        final List data = response['data'] ?? [];
        stateOptions.assignAll(data.map((e) => DropdownOption(
          value: e['id'].toString(), 
          label: e['state_name']?.toString() ?? '',
        )).toList());
      }
    } catch (e) {
      debugPrint('Error fetching states: $e');
    }
  }

  Future<void> fetchDistricts(String stateId) async {
    try {
      final response = await _inventoryRepository.getDistricts(stateId);
      if (response != null && response['status'] == 'success') {
        final List data = response['data'] ?? [];
        districtOptions.assignAll(data.map((e) => DropdownOption(
          value: e['district_id'].toString(), 
          label: e['district_name']?.toString() ?? '',
        )).toList());
      }
    } catch (e) {
      debugPrint('Error fetching districts: $e');
    }
  }

  Future<void> fetchStores(String stateId, String districtId) async {
    try {
      final response = await _inventoryRepository.getStores(stateId, districtId);
      if (response != null && response['status'] == 'success') {
        final List data = response['data'] ?? [];
        storeOptions.assignAll(data.map((e) => DropdownOption(
          value: e['storeid'].toString(), 
          label: e['storeroom_name']?.toString() ?? '',
        )).toList());
      }
    } catch (e) {
      debugPrint('Error fetching stores: $e');
    }
  }

  Future<void> fetchStoreRooms(String stateId, String districtId) async {
    try {
      final response = await _inventoryRepository.getStores(stateId, districtId);
      if (response != null && response['status'] == 'success') {
        final List data = response['data'] ?? [];
        final parsed = data.map((e) => DropdownOption(
          value: e['storeid'].toString(), 
          label: e['storeroom_name']?.toString() ?? '',
        )).toList();

        if ((stateId.isNotEmpty || districtId.isNotEmpty) && 
            storeOptions.isNotEmpty && 
            parsed.length == storeOptions.length) {
          storeRoomOptions.clear();
        } else {
          storeRoomOptions.assignAll(parsed);
        }
      } else {
        storeRoomOptions.clear();
      }
    } catch (e) {
      debugPrint('Error fetching store rooms: $e');
      storeRoomOptions.clear();
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await _inventoryRepository.getCategories();
      if (response != null && response['status'] == 'success') {
        final List data = response['data'] ?? [];
        categoryOptions.assignAll(data.map((e) => DropdownOption(
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
      if (response != null && (response['status'] == 'success' || response['status'] == true)) {
        final List data = response['data'] ?? [];
        itemOptions.assignAll(data.map((e) => DropdownOption(
          value: e['id'].toString(), 
          label: e['item_name']?.toString() ?? '',
        )).toList());

        itemUnits.clear();
        for (var e in data) {
          final id = e['id']?.toString() ?? '';
          final unitId = e['measurement_unit_id']?.toString() ?? '';
          final unitName = e['measurement_unit_name']?.toString() ?? 
                           e['m_unit']?.toString() ?? 
                           e['display_unit']?.toString() ?? 
                           _mapMeasurementUnit(unitId);
          itemUnits[id] = unitName;
        }
      }
    } catch (e) {
      debugPrint('Error fetching items: $e');
    }
  }

  Future<void> fetchItemsByCategory(String categoryId) async {
    try {
      final response = await _inventoryRepository.getItemsByCategory(categoryId);
      if (response != null && (response['status'] == 'success' || response['status'] == true)) {
        final List data = response['data'] ?? [];
        itemOptions.assignAll(data.map((e) => DropdownOption(
          value: e['id'].toString(), 
          label: e['item_name']?.toString() ?? '',
        )).toList());

        for (var e in data) {
          final id = e['id']?.toString() ?? '';
          final unitId = e['measurement_unit_id']?.toString() ?? '';
          final unitName = e['measurement_unit_name']?.toString() ?? 
                           e['m_unit']?.toString() ?? 
                           e['display_unit']?.toString() ?? 
                           (unitId.isNotEmpty ? _mapMeasurementUnit(unitId) : '');
          if (unitName.isNotEmpty) {
            itemUnits[id] = unitName;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching items by category: $e');
    }
  }

  Future<void> fetchItemsForSelectedCategories() async {
    if (selectedCategories.isEmpty) {
      await fetchItems();
      return;
    }
    
    try {
      final List<DropdownOption> allCategoryItems = [];
      final results = await Future.wait(
        selectedCategories.map((catId) => _inventoryRepository.getItemsByCategory(catId))
      );

      for (var response in results) {
        if (response != null && (response['status'] == 'success' || response['status'] == true)) {
          final List data = response['data'] ?? [];
          for (var e in data) {
            final option = DropdownOption(
              value: e['id'].toString(), 
              label: e['item_name']?.toString() ?? '',
            );
            if (!allCategoryItems.any((item) => item.value == option.value)) {
              allCategoryItems.add(option);
            }

            final id = e['id']?.toString() ?? '';
            final unitId = e['measurement_unit_id']?.toString() ?? '';
            final unitName = e['measurement_unit_name']?.toString() ?? 
                             e['m_unit']?.toString() ?? 
                             e['display_unit']?.toString() ?? 
                             (unitId.isNotEmpty ? _mapMeasurementUnit(unitId) : '');
            if (unitName.isNotEmpty) {
              itemUnits[id] = unitName;
            }
          }
        }
      }
      itemOptions.assignAll(allCategoryItems);
    } catch (e) {
      debugPrint('Error fetching category-wise items: $e');
    }
  }

  void onCategorySelected(String? categoryId) {
    selectedAddItemName.value = null;
    if (categoryId != null && categoryId.isNotEmpty) {
      fetchItemsByCategory(categoryId);
    } else {
      fetchItems();
    }
  }

  Future<void> fetchMeasurements() async {
    try {
      final response = await _inventoryRepository.getMeasurements();
      if (response != null && response['status'] == 'success') {
        final List data = response['data'] ?? [];
        measurementsMap.assignAll({
          for (var e in data) 
            e['id'].toString(): e['measurement_unit']?.toString() ?? ''
        });
      }
    } catch (e) {
      debugPrint('Error fetching measurements: $e');
    }
  }

  String _mapMeasurementUnit(dynamic id) {
    return measurementsMap[id.toString()] ?? '';
  }

  Future<void> fetchInventoryStock() async {
    isLoading.value = true;
    try {
      final List<int> combinedStoreIds = {
        ...selectedStore.map((e) => int.tryParse(e)).whereType<int>(),
        ...selectedStoreRoom.map((e) => int.tryParse(e)).whereType<int>(),
      }.toList();

      final response = await _inventoryRepository.getInventoryStock(
        itemId: selectedItems.map((e) => int.tryParse(e)).whereType<int>().toList(),
        storeId: combinedStoreIds,
        categoryId: selectedCategories.map((e) => int.tryParse(e)).whereType<int>().toList(),
        stateId: selectedState.value ?? '',
        districtId: selectedDistrict.value ?? '',
      );
      
      if (response != null && response['status'] == true) {
        final List data = response['data'] ?? [];
        final items = data.map((e) => InventoryItemModel.fromJson(e)).toList();
        
        // Reverse items to show in opposite order (newest first)
        final reversedItems = items.reversed.toList();
        
        // Apply client-side search filtering if active
        final query = searchController.text.toLowerCase();
        if (query.isNotEmpty) {
          inventoryItems.assignAll(reversedItems.where((item) => 
            item.item.toLowerCase().contains(query) ||
            item.store.toLowerCase().contains(query) ||
            item.category.toLowerCase().contains(query)
          ).toList());
        } else {
          inventoryItems.assignAll(reversedItems);
        }
      } else {
        inventoryItems.clear();
      }
    } catch (e) {
      debugPrint('Error fetching stock: $e');
      inventoryItems.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportToExcel() async {
    isExporting.value = true;
    await AppExportUtils.exportToExcel(
      title: 'Inventory Stock Report',
      columns: [
        'Store',
        'Item',
        'Category',
        'Quantity',
        'Unit',
        'Low Stock',
      ],
      rows: inventoryItems.map((item) => [
        item.store,
        item.item,
        item.category,
        item.quantity,
        item.unit,
        item.isLowStock ? 'Yes' : 'No',
      ]).toList(),
      fileName: 'Inventory_Stock_Report',
    );
    isExporting.value = false;
  }

  Future<void> exportToPdf() async {
    isExportingPdf.value = true;
    await AppExportUtils.exportToPdf(
      title: 'Inventory Stock Report',
      columns: [
        'Store',
        'Item',
        'Category',
        'Quantity',
        'Unit',
        'Low Stock',
      ],
      rows: inventoryItems.map((item) => [
        item.store,
        item.item,
        item.category,
        item.quantity,
        item.unit,
        item.isLowStock ? 'Yes' : 'No',
      ]).toList(),
      fileName: 'Inventory_Stock_Report',
    );
    isExportingPdf.value = false;
  }

  // Pagination and UI logic
  final currentPage = 1.obs;
  final itemsPerPage = 10.obs;

  int get totalPages => (inventoryItems.length / itemsPerPage.value).ceil();

  List<InventoryItemModel> get paginatedItems {
    final startIndex = (currentPage.value - 1) * itemsPerPage.value;
    final endIndex = startIndex + itemsPerPage.value;
    if (startIndex >= inventoryItems.length) return [];
    return inventoryItems.sublist(
        startIndex, endIndex > inventoryItems.length ? inventoryItems.length : endIndex);
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

  void applyFilters() {
    currentPage.value = 1;
    fetchInventoryStock();
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
      await _authRepository.fetchProfile();
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }

    // Reset filters
    selectedState.value = null;
    selectedDistrict.value = null;
    selectedStoreRoom.clear();
    selectedStore.clear();
    selectedCategories.clear();
    selectedItems.clear();
    searchController.clear();
    currentPage.value = 1;

    await _fetchInitialData();
  }

  Future<void> allocateStock(
    InventoryItemModel item,
    String qty,
    String destType,
    String destId, {
    String? destStateId,
    String? destDistrictId,
  }) async {
    try {
      // e.g., destination_type = "unit", destination_id = "1"
      final response = await _inventoryRepository.allocateStock({
        "source_type": "storeroom",
        "source_id": int.tryParse(item.sourceId) ?? 1,
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
        await fetchInventoryStock();
      } else {
        AppCommonToastMessage.show(message: response?['message'] ?? 'Failed to allocate inventory.', type: ToastType.error);
      }
    } catch (e) {
      debugPrint('Error allocating stock: $e');
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

  Future<void> consumeStock(InventoryItemModel item, String qty) async {
    try {
      final response = await _inventoryRepository.consumeStock({
        "source_type": "store", // Based on curl
        "source_id": int.tryParse(item.sourceId) ?? 1,
        "item_id": int.tryParse(item.itemId) ?? 0,
        "consumption_qty": int.tryParse(qty) ?? 0,
        "state_id": int.tryParse(item.stateId) ?? 0,
        "district_id": int.tryParse(item.districtId) ?? 0,
        "measurement_unit_id": int.tryParse(item.measurementUnitId) ?? 0,
        "category_id": int.tryParse(item.categoryId) ?? 0,
      });
      if (response != null && (response['status'] == true || response['status'] == 'success')) {
        AppCommonToastMessage.show(message: response['message'] ?? 'Inventory consumed successfully.', type: ToastType.success);
        await fetchInventoryStock();
      } else {
        AppCommonToastMessage.show(message: response?['message'] ?? 'Failed to consume inventory.', type: ToastType.error);
      }
    } catch (e) {
      debugPrint('Error consuming stock: $e');
      AppCommonToastMessage.show(message: 'An error occurred during consumption.', type: ToastType.error);
    }
  }

  Future<bool> addStoreStock({
    required String stateId,
    required String districtId,
    required String storeId,
    required String categoryId,
    required String itemId,
    required String packetQty,
    required String pieceQty,
    required String literQty,
  }) async {
    try {
      final response = await _inventoryRepository.addStoreStock({
        "unit_state": int.tryParse(stateId) ?? 0,
        "unit_dist": int.tryParse(districtId) ?? 0,
        "str_room_id": int.tryParse(storeId) ?? 0,
        "categeoryval": int.tryParse(categoryId) ?? 0,
        "item_id": int.tryParse(itemId) ?? 0,
        "packet_qty": packetQty,
        "piece_qty": pieceQty,
        "liter_qty": literQty,
      });
      if (response != null && (response['status'] == 'success' || response['status'] == true)) {
        AppCommonToastMessage.show(message: response['message'] ?? 'Stock updated successfully', type: ToastType.success);
        await fetchInventoryStock();
        return true;
      } else {
        AppCommonToastMessage.show(message: response?['message'] ?? 'Failed to update stock', type: ToastType.error);
        return false;
      }
    } catch (e) {
      debugPrint('Error updating stock: $e');
      AppCommonToastMessage.show(message: 'An error occurred while updating stock.', type: ToastType.error);
      return false;
    }
  }
}
