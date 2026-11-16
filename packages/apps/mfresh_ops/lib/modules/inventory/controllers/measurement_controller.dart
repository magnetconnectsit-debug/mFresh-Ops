import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/utils/app_export_utils.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/data/models/inventory/measurement_model.dart';

class MeasurementController extends GetxController {
  final InventoryRepository _inventoryRepository = Get.find<InventoryRepository>();
  
  final isSearching = false.obs;
  final searchController = TextEditingController();
  final measurementNameController = TextEditingController();
  
  final allMeasurements = <MeasurementModel>[].obs;

  final measurements = <MeasurementModel>[].obs;
  final isExporting = false.obs;
  final isExportingPdf = false.obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMeasurements();
  }

  Future<void> fetchMeasurements() async {
    isLoading.value = true;
    try {
      final response = await _inventoryRepository.getMeasurements();
      if (response != null && response['status'] == 'success') {
        final List data = response['data'] ?? [];
        final parsed = data.map((e) => MeasurementModel.fromJson(e)).toList();
        allMeasurements.assignAll(parsed);
        applyFilters();
      }
    } catch (e) {
      debugPrint('Error fetching measurements: $e');
      AppCommonToastMessage.show(
        message: "Failed to load measurements: $e",
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    try {
      if (Get.isRegistered<AuthRepository>()) {
        await Get.find<AuthRepository>().fetchProfile();
      }
    } catch (_) {}
    await fetchMeasurements();
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
    measurements.assignAll(
      allMeasurements.where((m) {
        return query.isEmpty || m.measurementUnit.toLowerCase().contains(query);
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

  List<MeasurementModel> get sortedItems {
    final list = [...measurements];
    if (sortColumn.value.isEmpty) return list;

    final col = sortColumn.value;
    final asc = sortAscending.value;

    list.sort((a, b) {
      switch (col) {
        case 'Measurement':
          return asc
              ? a.measurementUnit.toLowerCase().compareTo(b.measurementUnit.toLowerCase())
              : b.measurementUnit.toLowerCase().compareTo(a.measurementUnit.toLowerCase());
        default:
          return 0;
      }
    });
    return list;
  }

  // Pagination
  final currentPage = 1.obs;
  final perPage = 10.obs;

  int get totalEntries => measurements.length;
  int get totalPages => (totalEntries / perPage.value).ceil().clamp(1, 999999);

  List<MeasurementModel> get paginatedItems {
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


  Future<bool> addMeasurement() async {
    final name = measurementNameController.text.trim();
    if (name.isEmpty) {
      AppCommonToastMessage.show(
        message: "Please enter measurement name",
        type: ToastType.error,
      );
      return false;
    }

    try {
      isSubmitting.value = true;
      final response = await _inventoryRepository.createMeasurement(name);
      if (response != null && response['status'] == 'success') {
        final newMes = MeasurementModel.fromJson(response['data']);
        allMeasurements.add(newMes);
        applyFilters();
        measurementNameController.clear();
        AppCommonToastMessage.show(
          message: response['message']?.toString() ?? "Measurement added successfully!",
          type: ToastType.success,
        );
        return true;
      } else {
        AppCommonToastMessage.show(
          message: response?['message']?.toString() ?? "Failed to add measurement",
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Error adding measurement: $e",
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> editMeasurement(MeasurementModel model, String newName) async {
    if (newName.isEmpty) {
      AppCommonToastMessage.show(
        message: "Please enter measurement name",
        type: ToastType.error,
      );
      return false;
    }

    try {
      isSubmitting.value = true;
      final response = await _inventoryRepository.updateMeasurement(model.id, newName);
      if (response != null && response['status'] == 'success') {
        final allIndex = allMeasurements.indexWhere((m) => m.id == model.id);
        if (allIndex != -1) {
          allMeasurements[allIndex] = MeasurementModel(id: model.id, measurementUnit: newName);
        }
        applyFilters();
        measurementNameController.clear();
        AppCommonToastMessage.show(
          message: response['message']?.toString() ?? "Measurement updated successfully!",
          type: ToastType.success,
        );
        return true;
      } else {
        AppCommonToastMessage.show(
          message: response?['message']?.toString() ?? "Failed to update measurement",
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Error updating measurement: $e",
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> deleteMeasurement(MeasurementModel model) async {
    try {
      isLoading.value = true;
      final response = await _inventoryRepository.deleteMeasurement(model.id);
      if (response != null && (response['status'] == 'success' || response['status'] == true)) {
        allMeasurements.removeWhere((m) => m.id == model.id);
        applyFilters();
        AppCommonToastMessage.show(
          message: response['message']?.toString() ?? "Measurement deleted successfully!",
          type: ToastType.success,
        );
        return true;
      } else {
        AppCommonToastMessage.show(
          message: response?['message']?.toString() ?? "Failed to delete measurement",
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Error deleting measurement: $e",
        type: ToastType.error,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportToExcel() async {
    isExporting.value = true;
    await AppExportUtils.exportToExcel(
      title: 'Measurements Report',
      columns: const ["Sl No", "Measurement"],
      rows: measurements
          .asMap()
          .entries
          .map((e) => [e.key + 1, e.value.measurementUnit])
          .toList(),
    );
    isExporting.value = false;
  }

  Future<void> exportToPdf() async {
    isExportingPdf.value = true;
    await AppExportUtils.exportToPdf(
      title: 'Measurements Report',
      columns: const ["Sl No", "Measurement"],
      rows: measurements
          .asMap()
          .entries
          .map((e) => [e.key + 1, e.value.measurementUnit])
          .toList(),
    );
    isExportingPdf.value = false;
  }

  @override
  void onClose() {
    searchController.dispose();
    measurementNameController.dispose();
    super.onClose();
  }
}
