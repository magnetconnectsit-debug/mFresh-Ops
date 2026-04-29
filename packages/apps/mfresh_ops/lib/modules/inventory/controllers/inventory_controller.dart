import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_export_utils.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';

class InventoryController extends GetxController {
  final isSearching = false.obs;
  final searchController = TextEditingController();
  final selectedAddItemName = RxnString();
  final isExporting = false.obs;
  final isExportingPdf = false.obs;

  // Multi-select filter states
  final selectedStates = <String>[].obs;
  final selectedDistricts = <String>[].obs;
  final selectedStores = <String>[].obs;
  final selectedCategories = <String>[].obs;
  final selectedItems = <String>[].obs;

  // Filter options
  final stateOptions = [
    const DropdownOption(value: 'Odisha', label: 'Odisha'),
    const DropdownOption(value: 'Bihar', label: 'Bihar'),
  ];

  final districtOptions = [
    const DropdownOption(value: 'Puri', label: 'Puri'),
    const DropdownOption(value: 'Khurda', label: 'Khurda'),
  ];

  final storeOptions = [
    const DropdownOption(value: 'Store_Puri', label: 'Store_Puri'),
    const DropdownOption(value: 'Store_Khurda', label: 'Store_Khurda'),
  ];

  final categoryOptions = [
    const DropdownOption(value: 'C_Personal Care', label: 'C_Personal Care'),
    const DropdownOption(value: 'C_Cleaning Care', label: 'C_Cleaning Care'),
  ];

  final itemOptions = [
    const DropdownOption(value: 'Hand Wash', label: 'Hand Wash'),
    const DropdownOption(value: 'Body Wash', label: 'Body Wash'),
    const DropdownOption(value: 'Floor Cleaner', label: 'Floor Cleaner'),
  ];

  // Full list of mock data for inventory items
  final allInventoryItems = <InventoryItemModel>[
    InventoryItemModel(
      store: 'Store_Puri',
      item: 'Hand Wash',
      category: 'C_Personal Care',
      quantity: '9,000',
      unit: 'ml',
    ),
    InventoryItemModel(
      store: 'Store_Puri',
      item: 'Body Wash',
      category: 'C_Personal Care',
      quantity: '1,500',
      unit: 'ml',
    ),
    InventoryItemModel(
      store: 'Store_Puri',
      item: 'Shampoo - Sachet',
      category: 'C_Personal Care',
      quantity: '58',
      unit: 'pcs',
      isPcs: true,
    ),
    InventoryItemModel(
      store: 'Store_Puri',
      item: 'Tissue Paper',
      category: 'C_Personal Care',
      quantity: '24',
      unit: 'pcs',
      isPcs: true,
    ),
    InventoryItemModel(
      store: 'Store_Puri',
      item: 'Toilet Roll',
      category: 'C_Personal Care',
      quantity: '70',
      unit: 'pcs',
      isPcs: true,
    ),
    InventoryItemModel(
      store: 'Store_Puri',
      item: 'Dental Kit',
      category: 'C_Personal Care',
      quantity: '176',
      unit: 'pcs',
      isPcs: true,
    ),
    InventoryItemModel(
      store: 'Store_Puri',
      item: 'Floor Cleaner',
      category: 'C_Cleaning Care',
      quantity: '2,000',
      unit: 'ml',
    ),
    InventoryItemModel(
      store: 'Store_Puri',
      item: 'Toilet Cleaner',
      category: 'C_Cleaning Care',
      quantity: '8,500',
      unit: 'ml',
    ),
    InventoryItemModel(
      store: 'Store_Khurda',
      item: 'Hand Wash',
      category: 'C_Personal Care',
      quantity: '2,200',
      unit: 'ml',
    ),
    InventoryItemModel(
      store: 'Store_Puri',
      item: 'Mop',
      category: 'C_Cleaning Tools',
      quantity: '6',
      unit: 'pcs',
    ),
  ];

  final inventoryItems = <InventoryItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    inventoryItems.assignAll(allInventoryItems);
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
    
    inventoryItems.assignAll(
      allInventoryItems.where((item) {
        final matchesSearch = query.isEmpty ||
            item.item.toLowerCase().contains(query) ||
            item.store.toLowerCase().contains(query) ||
            item.category.toLowerCase().contains(query);
            
        final matchesStore = selectedStores.isEmpty || selectedStores.contains(item.store);
        final matchesItem = selectedItems.isEmpty || selectedItems.contains(item.item);
        final matchesCategory = selectedCategories.isEmpty || selectedCategories.contains(item.category);
        
        return matchesSearch && matchesStore && matchesItem && matchesCategory;
      }).toList(),
    );
  }

  Future<void> exportToExcel() async {
    isExporting.value = true;
    await AppExportUtils.exportToExcel(
      title: 'Store Inventory Report',
      columns: const ["Store", "Item", "Category", "Quantity", "Unit"],
      rows: inventoryItems.map((item) => [item.store, item.item, item.category, item.quantity, item.unit]).toList(),
    );
    isExporting.value = false;
  }

  Future<void> exportToPdf() async {
    isExportingPdf.value = true;
    await AppExportUtils.exportToPdf(title: 'Store Inventory Report');
    isExportingPdf.value = false;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

class InventoryItemModel {
  final String store;
  final String item;
  final String category;
  final String quantity;
  final String unit;
  final bool isPcs;

  InventoryItemModel({
    required this.store,
    required this.item,
    required this.category,
    required this.quantity,
    required this.unit,
    this.isPcs = false,
  });
}
