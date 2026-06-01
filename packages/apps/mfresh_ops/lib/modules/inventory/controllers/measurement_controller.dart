import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/utils/app_export_utils.dart';

class MeasurementController extends GetxController {
  final isSearching = false.obs;
  final searchController = TextEditingController();
  final measurementNameController = TextEditingController();
  final allMeasurements = <String>['Litre', 'Packet', 'Piece', 'Pair', 'Kg'].obs;
  final measurements = <String>[].obs;
  final isExporting = false.obs;
  final isExportingPdf = false.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    measurements.assignAll(allMeasurements);
  }

  Future<void> onRefresh() async {
    isLoading.value = true;
    // Mock refresh delay
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
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
        return query.isEmpty || m.toLowerCase().contains(query);
      }).toList(),
    );
  }

  void addMeasurement() {
    final name = measurementNameController.text.trim();
    if (name.isNotEmpty) {
      allMeasurements.add(name);
      applyFilters();
      measurementNameController.clear();
      Get.back();
      AppCommonToastMessage.show(
        message: "Measurement added successfully!",
        type: ToastType.success,
      );
    } else {
      AppCommonToastMessage.show(
        message: "Please enter measurement name",
        type: ToastType.error,
      );
    }
  }

  void editMeasurement(int index, String newName) {
    if (newName.isNotEmpty) {
      final oldName = measurements[index];
      final allIndex = allMeasurements.indexOf(oldName);
      if (allIndex != -1) {
        allMeasurements[allIndex] = newName;
      }
      applyFilters();
      measurementNameController.clear();
      Get.back();
      AppCommonToastMessage.show(
        message: "Measurement updated successfully!",
        type: ToastType.success,
      );
    }
  }

  void deleteMeasurement(int index) {
    final oldName = measurements[index];
    allMeasurements.remove(oldName);
    applyFilters();
    AppCommonToastMessage.show(
      message: "Measurement deleted successfully!",
      type: ToastType.success,
    );
  }

  Future<void> exportToExcel() async {
    isExporting.value = true;
    await AppExportUtils.exportToExcel(
      title: 'Measurements Report',
      columns: const ["SI No", "Measurement Name"],
      rows: measurements
          .asMap()
          .entries
          .map((e) => [e.key + 1, e.value])
          .toList(),
    );
    isExporting.value = false;
  }

  Future<void> exportToPdf() async {
    isExportingPdf.value = true;
    await AppExportUtils.exportToPdf(
      title: 'Measurements Report',
      columns: const ["SI No", "Measurement Name"],
      rows: measurements
          .asMap()
          .entries
          .map((e) => [e.key + 1, e.value])
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
