import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_export_utils.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import 'package:services/api_services.dart';
import '../../../../data/models/inventory/inventory_item_model.dart';

class InventoryController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final isSearching = false.obs;
  final searchController = TextEditingController();
  final selectedAddItemName = RxnString();
  final isExporting = false.obs;
  final isExportingPdf = false.obs;

  // Filter states
  final selectedState = RxnString();
  final selectedDistrict = RxnString();
  final selectedStoreRoom = RxnString();
  final selectedStore = RxnString();
  final selectedCategories = <String>[].obs;
  final selectedItems = <String>[].obs;

  // Filter options
  final stateOptions = <DropdownOption>[].obs;
  final districtOptions = <DropdownOption>[].obs;
  final storeOptions = <DropdownOption>[].obs;
  final categoryOptions = <DropdownOption>[].obs;
  final itemOptions = <DropdownOption>[].obs;

  final inventoryItems = <InventoryItemModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    isLoading.value = true;
    await Future.wait([
      fetchStates(),
      fetchCategories(),
      fetchItems(),
    ]);
    await fetchInventoryStock();
    isLoading.value = false;
  }

  Future<void> fetchStates() async {
    try {
      final response = await _apiService.post('inv-get-states');
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
      final response = await _apiService.post('inv-states-Wise-District', data: {'state': stateId});
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
      final response = await _apiService.post('inv-stores', data: {
        'state': stateId,
        'district': districtId,
      });
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

  Future<void> fetchCategories() async {
    try {
      final response = await _apiService.post('inv-Category');
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
      final response = await _apiService.post('inventory/all-items');
      if (response != null && (response['status'] == 'success' || response['status'] == true)) {
        final List data = response['data'] ?? [];
        itemOptions.assignAll(data.map((e) => DropdownOption(
          value: e['id'].toString(), 
          label: e['item_name']?.toString() ?? '',
        )).toList());
      }
    } catch (e) {
      debugPrint('Error fetching items: $e');
    }
  }

  Future<void> fetchInventoryStock() async {
    isLoading.value = true;
    try {
      final response = await _apiService.post('inv-Store-stock-View', data: {
        "item_id": selectedItems.join(','),
        "store_id": selectedStore.value ?? '',
        "category_id": selectedCategories.join(','),
        "state_id": selectedState.value ?? '',
        "district_id": selectedDistrict.value ?? '',
      });
      
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
    await _fetchInitialData();
  }
}
