import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/utils/app_export_utils.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';

class StoreRoomController extends GetxController {
  final InventoryRepository _inventoryRepository = Get.find<InventoryRepository>();

  final isSearching = false.obs;
  final searchController = TextEditingController();
  final storeNameController = TextEditingController();
  final isExporting = false.obs;
  final isExportingPdf = false.obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  // State & District selection for dialogs
  final selectedStateId = RxnString();
  final selectedDistrictId = RxnString();

  final stateOptions = <DropdownOption<String>>[].obs;
  final districtOptions = <DropdownOption<String>>[].obs;

  final allStores = <StoreRoomModel>[].obs;
  final filteredStores = <StoreRoomModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchStoreRooms();
  }

  Future<void> onRefresh() async {
    await fetchStoreRooms();
  }

  Future<void> fetchStoreRooms() async {
    isLoading.value = true;
    try {
      final storesRes = await _inventoryRepository.getStores('', '');
      if (storesRes != null && storesRes['status'] == 'success') {
        final List stores = storesRes['data'] ?? [];
        allStores.assignAll(stores.map((e) => StoreRoomModel.fromJson(e)).toList());
      } else {
        allStores.clear();
      }
      applyFilters();
    } catch (e) {
      debugPrint('Error fetching store rooms: $e');
      AppCommonToastMessage.show(
        message: "Failed to load store rooms: $e",
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStatesForDialog() async {
    try {
      final statesRes = await _inventoryRepository.getStates();
      if (statesRes != null && statesRes['status'] == 'success') {
        final List states = statesRes['data'] ?? [];
        stateOptions.assignAll(states.map((e) => DropdownOption<String>(
          value: e['id'].toString(),
          label: e['state_name']?.toString() ?? '',
        )).toList());
      }
    } catch (e) {
      debugPrint('Error fetching states: $e');
    }
  }

  Future<void> fetchDistrictsForState(String stateId) async {
    try {
      districtOptions.clear();
      final distRes = await _inventoryRepository.getDistricts(stateId);
      if (distRes != null && distRes['status'] == 'success') {
        final List districts = distRes['data'] ?? [];
        districtOptions.assignAll(districts.map((e) => DropdownOption<String>(
          value: e['district_id'].toString(),
          label: e['district_name']?.toString() ?? '',
        )).toList());
      }
    } catch (e) {
      debugPrint('Error fetching districts: $e');
    }
  }

  void onStateSelected(String? stateId) {
    selectedStateId.value = stateId;
    selectedDistrictId.value = null;
    districtOptions.clear();
    if (stateId != null) {
      fetchDistrictsForState(stateId);
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
      rows: filteredStores.asMap().entries
          .map((entry) => [entry.key + 1, entry.value.storeName])
          .toList(),
    );
    isExporting.value = false;
  }

  Future<void> exportToPdf() async {
    isExportingPdf.value = true;
    await AppExportUtils.exportToPdf(
      title: 'Store Rooms Report',
      columns: const ["SI No", "Store Name"],
      rows: filteredStores.asMap().entries
          .map((entry) => [entry.key + 1, entry.value.storeName])
          .toList(),
    );
    isExportingPdf.value = false;
  }

  Future<bool> addStore() async {
    if (storeNameController.text.isEmpty) {
      AppCommonToastMessage.show(
        message: "Please enter store name",
        type: ToastType.error,
      );
      return false;
    }
    if (selectedStateId.value == null) {
      AppCommonToastMessage.show(
        message: "Please select state",
        type: ToastType.error,
      );
      return false;
    }
    if (selectedDistrictId.value == null) {
      AppCommonToastMessage.show(
        message: "Please select district",
        type: ToastType.error,
      );
      return false;
    }

    isSubmitting.value = true;
    try {
      final response = await _inventoryRepository.createStoreRoom(
        stateId: int.parse(selectedStateId.value!),
        districtId: int.parse(selectedDistrictId.value!),
        storeName: storeNameController.text.trim(),
      );

      if (response != null && response['status'] == 'success') {
        AppCommonToastMessage.show(
          message: response['message']?.toString() ?? "Store Room created successfully",
          type: ToastType.success,
        );
        return true;
      } else {
        AppCommonToastMessage.show(
          message: response?['message']?.toString() ?? "Failed to create store room",
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Error creating store room: $e",
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> editStore(int storeId) async {
    if (storeNameController.text.isEmpty) {
      AppCommonToastMessage.show(
        message: "Please enter store name",
        type: ToastType.error,
      );
      return false;
    }
    if (selectedStateId.value == null) {
      AppCommonToastMessage.show(
        message: "Please select state",
        type: ToastType.error,
      );
      return false;
    }
    if (selectedDistrictId.value == null) {
      AppCommonToastMessage.show(
        message: "Please select district",
        type: ToastType.error,
      );
      return false;
    }

    isSubmitting.value = true;
    try {
      final response = await _inventoryRepository.updateStoreRoom(
        id: storeId,
        stateId: int.parse(selectedStateId.value!),
        districtId: int.parse(selectedDistrictId.value!),
        storeName: storeNameController.text.trim(),
      );

      if (response != null && response['status'] == 'success') {
        AppCommonToastMessage.show(
          message: response['message']?.toString() ?? "Store Room updated successfully",
          type: ToastType.success,
        );
        return true;
      } else {
        AppCommonToastMessage.show(
          message: response?['message']?.toString() ?? "Failed to update store room",
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Error updating store room: $e",
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void prepareEditDialog(StoreRoomModel store) {
    storeNameController.text = store.storeName;
    selectedStateId.value = null;
    selectedDistrictId.value = null;
    districtOptions.clear();
    fetchStatesForDialog();
  }

  void prepareAddDialog() {
    storeNameController.clear();
    selectedStateId.value = null;
    selectedDistrictId.value = null;
    districtOptions.clear();
    fetchStatesForDialog();
  }

  @override
  void onClose() {
    searchController.dispose();
    storeNameController.dispose();
    super.onClose();
  }
}

class StoreRoomModel {
  final int id;
  final String storeName;

  StoreRoomModel({
    required this.id,
    required this.storeName,
  });

  factory StoreRoomModel.fromJson(Map<String, dynamic> json) {
    return StoreRoomModel(
      id: json['storeid'] is int
          ? json['storeid']
          : int.tryParse(json['storeid']?.toString() ?? '0') ?? 0,
      storeName: json['storeroom_name']?.toString() ?? '',
    );
  }
}
