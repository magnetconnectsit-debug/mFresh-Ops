import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/utils/app_export_utils.dart';

class MeasurementController extends GetxController {
  final measurementNameController = TextEditingController();
  final measurements = <String>['Litre', 'Packet', 'Piece', 'Pair', 'Kg'].obs;
  final isExporting = false.obs;
  final isExportingPdf = false.obs;

  void addMeasurement() {
    final name = measurementNameController.text.trim();
    if (name.isNotEmpty) {
      measurements.add(name);
      measurementNameController.clear();
      Get.back();
      AppCommonToastMessage.show(message: "Measurement added successfully!", type: ToastType.success);
    } else {
      AppCommonToastMessage.show(message: "Please enter measurement name", type: ToastType.error);
    }
  }

  void editMeasurement(int index, String newName) {
    if (newName.isNotEmpty) {
      measurements[index] = newName;
      measurementNameController.clear();
      Get.back();
      AppCommonToastMessage.show(message: "Measurement updated successfully!", type: ToastType.success);
    }
  }

  void deleteMeasurement(int index) {
    measurements.removeAt(index);
    AppCommonToastMessage.show(message: "Measurement deleted successfully!", type: ToastType.success);
  }

  Future<void> exportToExcel() async {
    isExporting.value = true;
    await AppExportUtils.exportToExcel(
      title: 'Measurements Report',
      columns: const ["SI No", "Measurement Name"],
      rows: measurements.asMap().entries.map((e) => [e.key + 1, e.value]).toList(),
    );
    isExporting.value = false;
  }

  Future<void> exportToPdf() async {
    isExportingPdf.value = true;
    await AppExportUtils.exportToPdf(title: 'Measurements Report');
    isExportingPdf.value = false;
  }

  @override
  void onClose() {
    measurementNameController.dispose();
    super.onClose();
  }
}
