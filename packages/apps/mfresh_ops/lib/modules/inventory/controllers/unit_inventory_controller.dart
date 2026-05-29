import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:core/utils/app_export_utils.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';

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

  final allUnitInventoryItems = <UnitInventoryModel>[];
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
          value: e['unitname'].toString(), 
          label: e['unitname'].toString()
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
          value: e['invcatgeoryname'].toString(), 
          label: e['invcatgeoryname'].toString()
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
          value: e['item_name'].toString(), 
          label: e['item_name'].toString()
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
      final response = await _inventoryRepository.getUnitInventoryStock();

      if (response != null && response['status'] == true) {
        final List data = response['data'] ?? [];
        allUnitInventoryItems.clear();
        for (var e in data.reversed) {
          final model = UnitInventoryModel.fromJson(e);
          allUnitInventoryItems.add(model);
        }

        applyFilters();
      }
    } catch (e) {
      debugPrint('Error fetching unit inventory: $e');
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
    await Future.wait([
      fetchSupportUnits(),
      fetchSupportCategories(),
      fetchSupportItems(),
      fetchUnitInventory(),
    ]);
  }

  void applyFilters() {
    final query = searchController.text.toLowerCase();

    unitInventoryItems.assignAll(
      allUnitInventoryItems.where((item) {
        final matchesSearch =
            query.isEmpty ||
            item.itemName.toLowerCase().contains(query) ||
            item.unitName.toLowerCase().contains(query);

        final matchesUnit = selectedUnits.isEmpty || selectedUnits.contains(item.unitName);
        final matchesItem = selectedItems.isEmpty || selectedItems.contains(item.itemName);
        final matchesCategory = selectedCategories.isEmpty || selectedCategories.contains(item.categoryName);

        return matchesSearch && matchesUnit && matchesItem && matchesCategory;
      }).toList(),
    );
    currentPage.value = 1;
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

  Future<void> allocateStock(UnitInventoryModel item, String qty, String destType, String destId) async {
    try {
      final response = await _inventoryRepository.allocateStock({
        "source_type": "unit",
        "source_id": int.tryParse(item.unitId) ?? 0,
        "item_id": int.tryParse(item.itemId) ?? 0,
        "destination_type": destType,
        "destination_id": int.tryParse(destId) ?? 0,
        "state_id": int.tryParse(item.stateId) ?? 0,
        "district_id": int.tryParse(item.districtId) ?? 0,
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

class UnitInventoryModel {
  final int id;
  final String unitName;
  final String itemName;
  final String categoryName;
  final String quantity;
  final String lowQntyUnit;
  final String mUnit;
  final String stateId;
  final String districtId;
  final String categoryId;
  final String itemId;
  final String measurementUnitId;
  final String unitId;

  UnitInventoryModel({
    required this.id,
    required this.unitName,
    required this.itemName,
    required this.categoryName,
    required this.quantity,
    required this.lowQntyUnit,
    required this.mUnit,
    this.stateId = '',
    this.districtId = '',
    this.categoryId = '',
    this.itemId = '',
    this.measurementUnitId = '',
    this.unitId = '',
  });

  bool get isQntyLow {
    if (lowQntyUnit == 'NA') return false;
    final q = double.tryParse(quantity) ?? 0;
    final lq = double.tryParse(lowQntyUnit) ?? 0;
    return q < lq;
  }

  static String _mapMeasurementUnit(dynamic id) {
    switch (id.toString()) {
      case '1': return 'Litre';
      case '2': return 'Packet';
      case '3': return 'pcs';
      case '4': return 'Box';
      case '6': return 'Pair';
      case '7': return 'Kg';
      default: return 'pcs';
    }
  }

  factory UnitInventoryModel.fromJson(Map<String, dynamic> json) {
    return UnitInventoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      unitName: json['unit_name']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      categoryName: json['invcatgeoryname']?.toString() ?? '',
      quantity: json['allotment_qty']?.toString() ?? '0',
      lowQntyUnit: json['low_qnty_unit']?.toString() ?? '0',
      mUnit: json['m_unit']?.toString() ?? json['measurement_unit_name']?.toString() ?? _mapMeasurementUnit(json['measurement_unit_id']),
      stateId: json['state_id']?.toString() ?? '',
      districtId: json['district_id']?.toString() ?? '',
      categoryId: json['categoryID']?.toString() ?? '',
      itemId: json['item_id']?.toString() ?? '',
      measurementUnitId: json['measurement_unit_id']?.toString() ?? '',
      unitId: json['destination_id']?.toString() ?? '',
    );
  }
}
