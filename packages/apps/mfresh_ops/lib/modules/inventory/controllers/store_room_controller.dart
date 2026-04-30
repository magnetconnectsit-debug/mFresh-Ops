import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/utils/app_export_utils.dart';

class StoreRoomController extends GetxController {
  final isSearching = false.obs;
  final searchController = TextEditingController();
  final storeNameController = TextEditingController();
  final isExporting = false.obs;
  final isExportingPdf = false.obs;

  final allStores = <StoreRoomModel>[
    StoreRoomModel(siNo: 1, storeName: 'Store_Puri'),
    StoreRoomModel(siNo: 2, storeName: 'Store_Bbsr'),
  ].obs;

  final filteredStores = <StoreRoomModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    filteredStores.assignAll(allStores);
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
    filteredStores.assignAll(
      allStores.where((store) {
        return query.isEmpty ||
            store.storeName.toLowerCase().contains(query);
      }).toList(),
    );
  }

  Future<void> exportToExcel() async {
    isExporting.value = true;
    await AppExportUtils.exportToExcel(
      title: 'Store Rooms Report',
      columns: const ["SI No", "Store Name"],
      rows: filteredStores.map((store) => [store.siNo, store.storeName]).toList(),
    );
    isExporting.value = false;
  }

  Future<void> exportToPdf() async {
    isExportingPdf.value = true;
    await AppExportUtils.exportToPdf(
      title: 'Store Rooms Report',
      columns: const ["SI No", "Store Name"],
      rows: filteredStores.map((store) => [store.siNo, store.storeName]).toList(),
    );
    isExportingPdf.value = false;
  }

  void addStore() {
    if (storeNameController.text.isNotEmpty) {
      final newStore = StoreRoomModel(
        siNo: allStores.length + 1,
        storeName: storeNameController.text,
      );
      allStores.add(newStore);
      applyFilters();
      storeNameController.clear();
      Get.back();
      AppCommonToastMessage.show(message: "Store added successfully!", type: ToastType.success);
    } else {
      AppCommonToastMessage.show(message: "Please enter store name", type: ToastType.error);
    }
  }

  void editStore(int index, String newName) {
    if (newName.isNotEmpty) {
      allStores[index] = StoreRoomModel(siNo: allStores[index].siNo, storeName: newName);
      applyFilters();
      Get.back();
      AppCommonToastMessage.show(message: "Store updated successfully!", type: ToastType.success);
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    storeNameController.dispose();
    super.onClose();
  }
}

class StoreRoomModel {
  final int siNo;
  final String storeName;

  StoreRoomModel({required this.siNo, required this.storeName});
}
