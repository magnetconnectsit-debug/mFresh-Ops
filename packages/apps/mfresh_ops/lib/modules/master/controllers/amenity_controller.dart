// region Imports
import 'dart:io';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mfresh_ops/data/models/master/amenity_model.dart';
import 'package:mfresh_ops/data/repositories/master_repository.dart';
// endregion

// region AmenityController
class AmenityController extends GetxController {
  // region Dependencies & Repositories
  final MasterRepository _repository = Get.find<MasterRepository>();
  final ImagePicker _picker = ImagePicker();
  // endregion

  // region Observables & State Variables
  final amenities = <AmenityItem>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final isExporting = false.obs;
  final searchQuery = ''.obs;

  // Sorting
  final sortColumn = Rxn<String>();
  final sortOrder = AppTableSortOrder.none.obs;

  // Pagination
  final currentPage = 1.obs;
  final perPage = 50.obs;
  final totalRecords = 0.obs;

  // Form State
  final selectedIconFile = Rxn<File>();
  final currentIconUrl = RxnString();
  // endregion

  // region Text Controllers & Focus Nodes
  final searchCtrl = TextEditingController();
  final amenityNameCtrl = TextEditingController();
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    fetchAmenities();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    amenityNameCtrl.dispose();
    super.onClose();
  }
  // endregion

  // region API & Network Operations
  Future<void> fetchAmenities() async {
    try {
      isLoading.value = true;
      final response = await _repository.getAmenities();
      if (response.status) {
        amenities.assignAll(response.data);
        totalRecords.value = response.data.length;
      } else {
        AppCommonToastMessage.show(
          message: response.message.isNotEmpty
              ? response.message
              : 'Failed to fetch amenities.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error fetching amenities: $e',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createAmenity({
    required String amenityName,
    File? iconFile,
  }) async {
    try {
      isSubmitting.value = true;
      final success = await _repository.createAmenity(
        amenityName: amenityName,
        amenityIcon: iconFile,
      );
      if (success) {
        AppCommonToastMessage.show(
          message: 'Amenity created successfully.',
          type: ToastType.success,
        );
        await fetchAmenities();
        return true;
      } else {
        AppCommonToastMessage.show(
          message: 'Failed to create amenity.',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error creating amenity: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateAmenity({
    required int id,
    required String amenityName,
    File? iconFile,
  }) async {
    try {
      isSubmitting.value = true;
      final success = await _repository.updateAmenity(
        id: id,
        amenityName: amenityName,
        amenityIcon: iconFile,
      );
      if (success) {
        AppCommonToastMessage.show(
          message: 'Amenity updated successfully.',
          type: ToastType.success,
        );
        await fetchAmenities();
        return true;
      } else {
        AppCommonToastMessage.show(
          message: 'Failed to update amenity.',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error updating amenity: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> deleteAmenity(int id) async {
    try {
      isSubmitting.value = true;
      final success = await _repository.deleteAmenity(id);
      if (success) {
        AppCommonToastMessage.show(
          message: 'Amenity deleted successfully.',
          type: ToastType.success,
        );
        await fetchAmenities();
        return true;
      } else {
        AppCommonToastMessage.show(
          message: 'Failed to delete amenity.',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error deleting amenity: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
  // endregion

  // region Business Logic & Helpers
  List<AmenityItem> get filteredAmenities {
    var list = amenities.toList();

    // 1. Search Query Filter
    if (searchQuery.value.trim().isNotEmpty) {
      final q = searchQuery.value.trim().toLowerCase();
      list = list.where((item) {
        return item.amenityName.toLowerCase().contains(q) ||
            item.id.toString().contains(q);
      }).toList();
    }

    // 2. Sorting
    final column = sortColumn.value;
    final order = sortOrder.value;
    if (column != null && order != AppTableSortOrder.none) {
      final isAsc = order == AppTableSortOrder.ascending;
      list.sort((a, b) {
        switch (column) {
          case 'si_no':
            return isAsc ? a.id.compareTo(b.id) : b.id.compareTo(a.id);
          case 'amenity':
            return isAsc
                ? a.amenityName.toLowerCase().compareTo(b.amenityName.toLowerCase())
                : b.amenityName.toLowerCase().compareTo(a.amenityName.toLowerCase());
          default:
            return 0;
        }
      });
    }

    return list;
  }

  List<AmenityItem> get paginatedAmenities {
    final list = filteredAmenities;
    final start = (currentPage.value - 1) * perPage.value;
    if (start >= list.length) {
      return [];
    }
    final end = (start + perPage.value).clamp(0, list.length);
    return list.sublist(start, end);
  }

  int get totalPages {
    final total = filteredAmenities.length;
    if (total == 0) return 1;
    return (total / perPage.value).ceil();
  }

  void onSearchChanged(String val) {
    searchQuery.value = val;
    currentPage.value = 1;
  }

  void resetSearch() {
    searchCtrl.clear();
    searchQuery.value = '';
    currentPage.value = 1;
  }

  void onSort(String columnKey, AppTableSortOrder order) {
    sortColumn.value = order == AppTableSortOrder.none ? null : columnKey;
    sortOrder.value = order;
  }

  void setPage(int page) {
    currentPage.value = page;
  }

  void setPerPage(int count) {
    perPage.value = count;
    currentPage.value = 1;
  }

  Future<void> pickIcon(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked != null) {
        selectedIconFile.value = File(picked.path);
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to pick image: $e',
        type: ToastType.error,
      );
    }
  }

  void clearIcon() {
    selectedIconFile.value = null;
    currentIconUrl.value = null;
  }

  Future<void> exportToExcel() async {
    try {
      isExporting.value = true;
      final data = filteredAmenities;
      if (data.isEmpty) {
        AppCommonToastMessage.show(
          message: 'No amenities available to export.',
          type: ToastType.warning,
        );
        return;
      }

      final columns = ['SI No.', 'Amenity Name', 'Icon URL'];
      final rows = List<List<dynamic>>.generate(data.length, (index) {
        final item = data[index];
        return [
          index + 1,
          item.amenityName,
          item.iconUrl ?? 'NA',
        ];
      });

      await AppExportUtils.exportToExcel(
        title: 'All Amenities',
        columns: columns,
        rows: rows,
        fileName: 'all_amenities_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error exporting amenities: $e',
        type: ToastType.error,
      );
    } finally {
      isExporting.value = false;
    }
  }
  // endregion
}
// endregion

