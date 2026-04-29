import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_export_utils.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';

class UnitInventoryController extends GetxController {
  final isSearching = false.obs;
  final searchController = TextEditingController();
  final isExporting = false.obs;
  final isExportingPdf = false.obs;

  // Multi-select filter states
  final selectedUnits = <String>[].obs;
  final selectedItems = <String>[].obs;

  // Filter options
  final unitOptions = [
    const DropdownOption(value: 'MM25002', label: 'MM25002'),
    const DropdownOption(value: 'MM25003', label: 'MM25003'),
    const DropdownOption(value: 'MM25005', label: 'MM25005'),
  ];

  final itemOptions = [
    const DropdownOption(value: 'Hand Wash', label: 'Hand Wash'),
    const DropdownOption(value: 'Body Wash', label: 'Body Wash'),
    const DropdownOption(value: 'Floor Cleaner', label: 'Floor Cleaner'),
  ];

  // Full list of mock data for unit inventory items
  final allUnitInventoryItems = <UnitInventoryModel>[
    UnitInventoryModel(
      unitName: 'MM25002',
      itemName: 'Floor Cleaner',
      openingBalance: '5,000 ml',
      receipt: '1,000 ml',
      consumption: '500 ml',
      closingBalance: '5,500 ml',
    ),
    UnitInventoryModel(
      unitName: 'MM25003',
      itemName: 'Hand Wash',
      openingBalance: '2,000 ml',
      receipt: '500 ml',
      consumption: '300 ml',
      closingBalance: '2,200 ml',
    ),
    UnitInventoryModel(
      unitName: 'MM25005',
      itemName: 'Mop',
      openingBalance: '5 pcs',
      receipt: '2 pcs',
      consumption: '1 pcs',
      closingBalance: '6 pcs',
    ),
  ];

  final unitInventoryItems = <UnitInventoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    unitInventoryItems.assignAll(allUnitInventoryItems);
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
    
    unitInventoryItems.assignAll(
      allUnitInventoryItems.where((item) {
        final matchesSearch = query.isEmpty ||
            item.itemName.toLowerCase().contains(query) ||
            item.unitName.toLowerCase().contains(query);
            
        final matchesUnit = selectedUnits.isEmpty || selectedUnits.contains(item.unitName);
        final matchesItem = selectedItems.isEmpty || selectedItems.contains(item.itemName);
        
        return matchesSearch && matchesUnit && matchesItem;
      }).toList(),
    );
  }

  Future<void> exportToExcel() async {
    isExporting.value = true;
    await AppExportUtils.exportToExcel(
      title: 'Unit Inventory Report',
      columns: const ["Unit Name", "Item Name", "Opening Balance", "Receipt", "Consumption", "Closing Balance"],
      rows: unitInventoryItems.map((item) => [item.unitName, item.itemName, item.openingBalance, item.receipt, item.consumption, item.closingBalance]).toList(),
    );
    isExporting.value = false;
  }

  Future<void> exportToPdf() async {
    isExportingPdf.value = true;
    await AppExportUtils.exportToPdf(title: 'Unit Inventory Report');
    isExportingPdf.value = false;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

class UnitInventoryModel {
  final String unitName;
  final String itemName;
  final String openingBalance;
  final String receipt;
  final String consumption;
  final String closingBalance;

  UnitInventoryModel({
    required this.unitName,
    required this.itemName,
    required this.openingBalance,
    required this.receipt,
    required this.consumption,
    required this.closingBalance,
  });
}
