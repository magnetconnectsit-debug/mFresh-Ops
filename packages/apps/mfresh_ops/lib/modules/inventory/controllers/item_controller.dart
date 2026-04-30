import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/utils/app_export_utils.dart';

class ItemController extends GetxController {
  final isSearching = false.obs;
  final searchController = TextEditingController();
  final isExporting = false.obs;
  final isExportingPdf = false.obs;

  final itemNameController = TextEditingController();
  final itemIdController = TextEditingController();
  final lowQuantityStoreController = TextEditingController();
  final lowQuantityUnitController = TextEditingController();

  final selectedMeasurement = RxnString();
  final selectedCategory = RxnString();

  final measurementOptions = ['Litre', 'Piece', 'Packet', 'Kg', 'Gram'].obs;
  final categoryOptions = ['Cleaning', 'Toiletries', 'Stationery', 'Others'].obs;

  final allItems = <ItemModel>[
    ItemModel(siNo: 1, itemName: 'Hand Wash', itemId: '2001', measurement: 'Litre', category: 'Toiletries', lowQuantityStore: '10', lowQuantityUnit: '2'),
    ItemModel(siNo: 2, itemName: 'Body Wash', itemId: '2002', measurement: 'Litre', category: 'Toiletries', lowQuantityStore: '5', lowQuantityUnit: '1'),
    ItemModel(siNo: 3, itemName: 'Shampoo - Sachet', itemId: '2003', measurement: 'Piece', category: 'Toiletries', lowQuantityStore: '100', lowQuantityUnit: '20'),
    ItemModel(siNo: 4, itemName: 'Floor Cleaner', itemId: '2004', measurement: 'Litre', category: 'Cleaning', lowQuantityStore: '20', lowQuantityUnit: '5'),
    ItemModel(siNo: 5, itemName: 'Toilet Cleaner', itemId: '2005', measurement: 'Litre', category: 'Cleaning', lowQuantityStore: '15', lowQuantityUnit: '3'),
    ItemModel(siNo: 6, itemName: 'Glass Cleaner', itemId: '2006', measurement: 'Litre', category: 'Cleaning', lowQuantityStore: '10', lowQuantityUnit: '2'),
    ItemModel(siNo: 7, itemName: 'Phenyl', itemId: '2007', measurement: 'Litre', category: 'Cleaning', lowQuantityStore: '50', lowQuantityUnit: '10'),
    ItemModel(siNo: 8, itemName: 'Garbage Bag - Small', itemId: '2009', measurement: 'Packet', category: 'Cleaning', lowQuantityStore: '30', lowQuantityUnit: '5'),
  ].obs;

  final filteredItems = <ItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    filteredItems.assignAll(allItems);
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

  Future<void> exportToExcel() async {
    isExporting.value = true;
    await AppExportUtils.exportToExcel(
      title: 'Items Report',
      columns: const ["SI No", "Item Name", "Item Id", "Measurement"],
      rows: filteredItems.map((item) => [item.siNo, item.itemName, item.itemId, item.measurement]).toList(),
    );
    isExporting.value = false;
  }

  Future<void> exportToPdf() async {
    isExportingPdf.value = true;
    await AppExportUtils.exportToPdf(
      title: 'Items Report',
      columns: const ["SI No", "Item Name", "Item Id", "Measurement"],
      rows: filteredItems.map((item) => [item.siNo, item.itemName, item.itemId, item.measurement]).toList(),
    );
    isExportingPdf.value = false;
  }

  void addItem() {
    if (itemNameController.text.isNotEmpty && 
        itemIdController.text.isNotEmpty && 
        selectedMeasurement.value != null && 
        selectedCategory.value != null) {
      final newItem = ItemModel(
        siNo: allItems.length + 1,
        itemName: itemNameController.text,
        itemId: itemIdController.text,
        measurement: selectedMeasurement.value!,
        category: selectedCategory.value!,
        lowQuantityStore: lowQuantityStoreController.text,
        lowQuantityUnit: lowQuantityUnitController.text,
      );
      allItems.add(newItem);
      applyFilters();
      clearControllers();
      Get.back();
      AppCommonToastMessage.show(message: "Item added successfully!", type: ToastType.success);
    } else {
      AppCommonToastMessage.show(message: "Please fill all required fields", type: ToastType.error);
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

  void editItem(int index, ItemModel updatedItem) {
    allItems[index] = updatedItem;
    applyFilters();
    Get.back();
    AppCommonToastMessage.show(message: "Item updated successfully!", type: ToastType.success);
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
  final int siNo;
  final String itemName;
  final String itemId;
  final String measurement;
  final String category;
  final String lowQuantityStore;
  final String lowQuantityUnit;

  ItemModel({
    required this.siNo,
    required this.itemName,
    required this.itemId,
    required this.measurement,
    required this.category,
    required this.lowQuantityStore,
    required this.lowQuantityUnit,
  });
}
