// region Imports
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mfresh_ops/data/models/master/unit_master_model.dart';
import 'package:mfresh_ops/data/repositories/master_repository.dart';
// endregion

// region UnitController
class UnitController extends GetxController {
  // region Dependencies & Repositories
  final MasterRepository _repository = Get.find<MasterRepository>();
  final ImagePicker _imagePicker = ImagePicker();
  // endregion

  // region Observables & State Variables
  final units = <UnitMasterItem>[].obs;
  final filteredUnits = <UnitMasterItem>[].obs;
  final unitOptions = Rxn<UnitOptionsData>();

  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final isLocating = false.obs;
  final isExporting = false.obs;
  final searchQuery = ''.obs;

  // Sorting
  final sortColumn = Rxn<String>();
  final sortOrder = AppTableSortOrder.none.obs;

  // Pagination
  final currentPage = 1.obs;
  final perPage = 50.obs;
  final totalRecords = 0.obs;

  // Unit Manager Details Edit State
  final selectedUnitForManager = Rxn<UnitMasterItem>();
  final preferredCtrl = '0'.obs;

  // Full Unit Edit State
  final selectedUnitForEdit = Rxn<UnitMasterItem>();
  final editCategory = ''.obs;
  final editServiceType = 'Movable'.obs;
  final editUnitType = '1'.obs;
  final editYearOfDelivery = '26'.obs;
  final editStateId = ''.obs;
  final editDistrictId = ''.obs;
  final editIngDate = Rxn<DateTime>();
  final selectedUnitImg = Rxn<File>();
  final existingUnitImgUrl = RxnString();
  final selectedMultiImgs = <File>[].obs;
  final existingGalleryUrls = <String>[].obs;
  final amenitySelections = <int, RxBool>{}.obs;
  final amenityQuantities = <int, TextEditingController>{}.obs;
  // endregion

  // region Text Controllers & Focus Nodes
  final searchCtrl = TextEditingController();

  // Unit Manager Details Text Controllers
  final timingCtrl = TextEditingController();
  final unitAddrCtrl = TextEditingController();
  final fullAddrCtrl = TextEditingController();
  final latCtrl = TextEditingController();
  final lngCtrl = TextEditingController();

  // Full Unit Edit Text Controllers
  final editLocationCtrl = TextEditingController();
  final editTimingCtrl = TextEditingController();
  final editFullAddrCtrl = TextEditingController();
  final editDescCtrl = TextEditingController();
  final editSpecCtrl = TextEditingController();
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    fetchUnits();
    fetchUnitOptions();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    timingCtrl.dispose();
    unitAddrCtrl.dispose();
    fullAddrCtrl.dispose();
    latCtrl.dispose();
    lngCtrl.dispose();

    editLocationCtrl.dispose();
    editTimingCtrl.dispose();
    editFullAddrCtrl.dispose();
    editDescCtrl.dispose();
    editSpecCtrl.dispose();

    for (final ctrl in amenityQuantities.values) {
      ctrl.dispose();
    }
    super.onClose();
  }
  // endregion

  // region API & Network Operations
  Future<void> fetchUnits() async {
    try {
      isLoading.value = true;
      final response = await _repository.getUnits();
      if (response.status) {
        units.assignAll(response.data);
        totalRecords.value = response.count > 0 ? response.count : response.data.length;
        _applySearchFilter();
      } else {
        AppCommonToastMessage.show(
          message: response.message.isNotEmpty
              ? response.message
              : 'Failed to fetch units.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error fetching units: $e',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUnitOptions() async {
    try {
      final response = await _repository.getUnitOptions();
      if (response.status && response.data != null) {
        unitOptions.value = response.data;
      }
    } catch (e) {
      debugPrint('Error fetching unit options: $e');
    }
  }

  Future<bool> updateUnitDetailsSubmit() async {
    final unit = selectedUnitForManager.value;
    if (unit == null) return false;

    try {
      isSubmitting.value = true;
      final result = await _repository.updateUnitDetails(
        id: unit.id,
        highprefer: preferredCtrl.value,
        opentime: timingCtrl.text.trim(),
        fulluAddress: fullAddrCtrl.text.trim(),
        uadd: unitAddrCtrl.text.trim(),
        latitude: latCtrl.text.trim(),
        longitude: lngCtrl.text.trim(),
      );

      if (result['status'] == true) {
        AppCommonToastMessage.show(
          message: result['message']?.toString() ??
              'Unit details updated successfully.',
          type: ToastType.success,
        );
        await fetchUnits();
        return true;
      } else {
        AppCommonToastMessage.show(
          message: result['message']?.toString() ??
              'Failed to update unit details.',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error updating unit details: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateUnitSubmit() async {
    final unit = selectedUnitForEdit.value;
    if (unit == null) return false;

    try {
      isSubmitting.value = true;

      final List<String> activeAmenities = [];
      final List<String> activeQuantities = [];

      final allOptionsAmenities = unitOptions.value?.amenities ?? [];
      for (final item in allOptionsAmenities) {
        final isSelected = amenitySelections[item.id]?.value ?? false;
        if (isSelected) {
          activeAmenities.add(item.amenityName);
          final qty = amenityQuantities[item.id]?.text.trim();
          activeQuantities.add((qty != null && qty.isNotEmpty) ? qty : '1');
        }
      }

      final ingdStr = editIngDate.value != null
          ? DateFormat('yyyy-MM-dd').format(editIngDate.value!)
          : (unit.ingDate ?? '');

      final result = await _repository.updateUnit(
        id: unit.id,
        unitCategory: editCategory.value.isNotEmpty
            ? editCategory.value
            : unit.unitcategory,
        unitType: editUnitType.value,
        serviceType: editServiceType.value,
        yearOfDelivery: editYearOfDelivery.value,
        unitState: editStateId.value.isNotEmpty
            ? editStateId.value
            : (unit.stateId ?? ''),
        unitDist: editDistrictId.value.isNotEmpty
            ? editDistrictId.value
            : (unit.districtId ?? ''),
        unitLocation: editLocationCtrl.text.trim(),
        oprnTiming: editTimingCtrl.text.trim(),
        fullAddress: editFullAddrCtrl.text.trim(),
        unitDesc: editDescCtrl.text.trim(),
        unitSpec: editSpecCtrl.text.trim(),
        ingd: ingdStr,
        amenities: activeAmenities,
        amenityQuantities: activeQuantities,
        unitImg: selectedUnitImg.value,
        multiImages: selectedMultiImgs.isNotEmpty ? selectedMultiImgs : null,
      );

      if (result['status'] == true) {
        AppCommonToastMessage.show(
          message: result['message']?.toString() ??
              'Unit updated successfully.',
          type: ToastType.success,
        );
        await fetchUnits();
        return true;
      } else {
        AppCommonToastMessage.show(
          message: result['message']?.toString() ?? 'Failed to update unit.',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error updating unit: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> createUnitSubmit() async {
    try {
      isSubmitting.value = true;

      final List<String> activeAmenities = [];
      final List<String> activeQuantities = [];

      final allOptionsAmenities = unitOptions.value?.amenities ?? [];
      for (final item in allOptionsAmenities) {
        final isSelected = amenitySelections[item.id]?.value ?? false;
        if (isSelected) {
          activeAmenities.add(item.amenityName);
          final qty = amenityQuantities[item.id]?.text.trim();
          activeQuantities.add((qty != null && qty.isNotEmpty) ? qty : '1');
        }
      }

      final ingdStr = editIngDate.value != null
          ? DateFormat('yyyy-MM-dd').format(editIngDate.value!)
          : '';

      final result = await _repository.createUnit(
        unitCategory: editCategory.value,
        unitType: editUnitType.value,
        serviceType: editServiceType.value,
        yearOfDelivery: editYearOfDelivery.value,
        unitState: editStateId.value,
        unitDist: editDistrictId.value,
        unitLocation: editLocationCtrl.text.trim(),
        oprnTiming: editTimingCtrl.text.trim(),
        fullAddress: editFullAddrCtrl.text.trim(),
        unitDesc: editDescCtrl.text.trim(),
        unitSpec: editSpecCtrl.text.trim(),
        ingd: ingdStr,
        amenities: activeAmenities,
        amenityQuantities: activeQuantities,
        unitImg: selectedUnitImg.value,
        multiImages: selectedMultiImgs.isNotEmpty ? selectedMultiImgs : null,
      );

      if (result['status'] == true) {
        AppCommonToastMessage.show(
          message: result['message']?.toString() ??
              'Unit created successfully.',
          type: ToastType.success,
        );
        await fetchUnits();
        return true;
      } else {
        AppCommonToastMessage.show(
          message: result['message']?.toString() ?? 'Failed to create unit.',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error creating unit: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> submitUnit() async {
    if (selectedUnitForEdit.value == null) {
      return await createUnitSubmit();
    } else {
      return await updateUnitSubmit();
    }
  }
  // endregion

  // region Business Logic & Helpers
  void onSearchChanged(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
    _applySearchFilter();
  }

  void _applySearchFilter() {
    final query = searchQuery.value.trim().toLowerCase();
    List<UnitMasterItem> result = List.from(units);

    if (query.isNotEmpty) {
      result = result.where((u) {
        final matchesQrcode = u.qrcodeId.toLowerCase().contains(query);
        final matchesCategory = u.unitcategory.toLowerCase().contains(query);
        final matchesCity = u.unitLocation.toLowerCase().contains(query);
        final matchesTiming = u.openTiming.toLowerCase().contains(query);
        final matchesAddress = u.fullAdd.toLowerCase().contains(query);
        return matchesQrcode ||
            matchesCategory ||
            matchesCity ||
            matchesTiming ||
            matchesAddress;
      }).toList();
    }

    // Apply Sorting
    if (sortColumn.value != null &&
        sortOrder.value != AppTableSortOrder.none) {
      final isAsc = sortOrder.value == AppTableSortOrder.ascending;
      result.sort((a, b) {
        int comparison = 0;
        switch (sortColumn.value) {
          case 'unit':
          case 'Unit':
            comparison = a.qrcodeId.compareTo(b.qrcodeId);
            break;
          case 'model':
          case 'Model':
            comparison = a.unitcategory.compareTo(b.unitcategory);
            break;
          case 'city':
          case 'City':
            comparison = a.unitLocation.compareTo(b.unitLocation);
            break;
          case 'operating_hrs':
          case 'Operating Hrs':
            comparison = a.openTiming.compareTo(b.openTiming);
            break;
          case 'inauguration_date':
          case 'Inauguration Date':
            comparison = (a.ingDate ?? '').compareTo(b.ingDate ?? '');
            break;
          default:
            comparison = a.id.compareTo(b.id);
        }
        return isAsc ? comparison : -comparison;
      });
    }

    filteredUnits.assignAll(result);
    totalRecords.value = result.length;
  }

  void onSort(String column, AppTableSortOrder order) {
    sortColumn.value = column;
    sortOrder.value = order;
    _applySearchFilter();
  }

  void onPageChanged(int page) {
    currentPage.value = page;
  }

  void onRowsPerPageChanged(int rows) {
    perPage.value = rows;
    currentPage.value = 1;
  }

  List<UnitMasterItem> get paginatedUnits {
    final startIndex = (currentPage.value - 1) * perPage.value;
    if (startIndex >= filteredUnits.length) {
      return [];
    }
    final endIndex = startIndex + perPage.value;
    return filteredUnits.sublist(
      startIndex,
      endIndex > filteredUnits.length ? filteredUnits.length : endIndex,
    );
  }

  /// Initialize Unit Manager Details dialog state
  void initManagerDetails(UnitMasterItem unit) {
    selectedUnitForManager.value = unit;
    preferredCtrl.value = unit.highlyPrefered == 1 ? '1' : '0';
    timingCtrl.text = unit.openTiming;
    unitAddrCtrl.text = unit.unitLocation;
    fullAddrCtrl.text = unit.fullAdd;
    latCtrl.text = unit.latitude;
    lngCtrl.text = unit.longitude;
  }

  /// Fetch current GPS location via Geolocator
  Future<void> getCurrentLocation() async {
    try {
      isLocating.value = true;
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppCommonToastMessage.show(
          message: 'Location services are disabled. Please turn on GPS.',
          type: ToastType.warning,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          AppCommonToastMessage.show(
            message: 'Location permission denied.',
            type: ToastType.warning,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        AppCommonToastMessage.show(
          message:
              'Location permissions permanently denied. Please enable in app settings.',
          type: ToastType.warning,
        );
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      latCtrl.text = position.latitude.toStringAsFixed(7);
      lngCtrl.text = position.longitude.toStringAsFixed(7);

      AppCommonToastMessage.show(
        message: 'Current location fetched successfully.',
        type: ToastType.success,
      );
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to get location: $e',
        type: ToastType.error,
      );
    } finally {
      isLocating.value = false;
    }
  }

  /// Initialize Unit Form for creating a new Unit
  void initCreateUnit() {
    selectedUnitForEdit.value = null;
    final options = unitOptions.value;
    editCategory.value = (options?.unitCategories.isNotEmpty ?? false)
        ? options!.unitCategories.first.unitcategory
        : '';
    editServiceType.value = 'Movable';
    editUnitType.value = '1';
    editYearOfDelivery.value = '26';
    editStateId.value = '';
    editDistrictId.value = '';

    editLocationCtrl.clear();
    editTimingCtrl.clear();
    editFullAddrCtrl.clear();
    editDescCtrl.clear();
    editSpecCtrl.clear();
    editIngDate.value = null;

    selectedUnitImg.value = null;
    existingUnitImgUrl.value = null;
    selectedMultiImgs.clear();
    existingGalleryUrls.clear();

    final optionsAmenities = unitOptions.value?.amenities ?? [];
    for (final opt in optionsAmenities) {
      amenitySelections[opt.id] = false.obs;
      if (amenityQuantities.containsKey(opt.id)) {
        amenityQuantities[opt.id]!.text = '1';
      } else {
        amenityQuantities[opt.id] = TextEditingController(text: '1');
      }
    }
  }

  /// Initialize Full Unit Edit Screen state
  void initUnitEdit(UnitMasterItem unit) {
    selectedUnitForEdit.value = unit;
    editCategory.value = unit.unitcategory;
    editServiceType.value =
        unit.servicetype.isNotEmpty ? unit.servicetype : 'Movable';
    editUnitType.value = (unit.unitType ?? '1').toString();
    editYearOfDelivery.value = unit.yearOfDelivery.isNotEmpty
        ? unit.yearOfDelivery
        : '26';
    editStateId.value = unit.stateId ?? '';
    editDistrictId.value = unit.districtId ?? '';

    editLocationCtrl.text = unit.unitLocation;
    editTimingCtrl.text = unit.openTiming;
    editFullAddrCtrl.text = unit.fullAdd;
    editDescCtrl.text = (unit.unitDesc ?? '').replaceAll(RegExp(r'<[^>]*>'), '');
    editSpecCtrl.text =
        (unit.specification ?? '').replaceAll(RegExp(r'<[^>]*>'), '');

    if (unit.ingDate != null && unit.ingDate!.isNotEmpty && unit.ingDate != 'NA') {
      editIngDate.value = DateTime.tryParse(unit.ingDate!);
    } else {
      editIngDate.value = null;
    }

    selectedUnitImg.value = null;
    existingUnitImgUrl.value = unit.unitImgUrl;
    selectedMultiImgs.clear();
    existingGalleryUrls.assignAll(unit.galleryUrls);

    // Parse existing amenities string (e.g. "Male Toilet (2),Urinals (4),...")
    final Map<String, String> existingAmenitiesMap = {};
    if (unit.amenities != null && unit.amenities!.isNotEmpty) {
      final parts = unit.amenities!.split(',');
      for (final p in parts) {
        final trimmed = p.trim();
        final match = RegExp(r'^(.*?)\s*\((\d+)\)$').firstMatch(trimmed);
        if (match != null) {
          final name = match.group(1)?.trim() ?? '';
          final qty = match.group(2)?.trim() ?? '1';
          if (name.isNotEmpty) {
            existingAmenitiesMap[name.toLowerCase()] = qty;
          }
        } else if (trimmed.isNotEmpty) {
          existingAmenitiesMap[trimmed.toLowerCase()] = '1';
        }
      }
    }

    // Populate amenity selections & quantity controllers from options
    final optionsAmenities = unitOptions.value?.amenities ?? [];
    for (final opt in optionsAmenities) {
      final key = opt.amenityName.trim().toLowerCase();
      final hasExisting = existingAmenitiesMap.containsKey(key);
      amenitySelections[opt.id] = (hasExisting).obs;

      final existingQty = existingAmenitiesMap[key] ?? '1';
      if (amenityQuantities.containsKey(opt.id)) {
        amenityQuantities[opt.id]!.text = existingQty;
      } else {
        amenityQuantities[opt.id] = TextEditingController(text: existingQty);
      }
    }
  }

  Future<void> pickSingleImage() async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (file != null) {
        selectedUnitImg.value = File(file.path);
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to pick image: $e',
        type: ToastType.error,
      );
    }
  }

  Future<void> pickMultiImages() async {
    try {
      final List<XFile> files = await _imagePicker.pickMultiImage(
        imageQuality: 80,
      );
      if (files.isNotEmpty) {
        selectedMultiImgs.addAll(files.map((x) => File(x.path)));
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to pick images: $e',
        type: ToastType.error,
      );
    }
  }

  void removeSelectedMultiImage(int index) {
    if (index >= 0 && index < selectedMultiImgs.length) {
      selectedMultiImgs.removeAt(index);
    }
  }

  void removeExistingGalleryImage(int index) {
    if (index >= 0 && index < existingGalleryUrls.length) {
      existingGalleryUrls.removeAt(index);
    }
  }

  Future<void> exportExcel() async {
    try {
      isExporting.value = true;
      final headers = [
        'SI No.',
        'Unit',
        'Model',
        'City',
        'Operating Hrs',
        'Inauguration Date',
        'Full Address',
        'Latitude',
        'Longitude',
        'Highly Preferred',
      ];

      final data = filteredUnits.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final u = entry.value;
        return [
          index.toString(),
          u.qrcodeId,
          u.unitcategory,
          u.unitLocation,
          u.openTiming,
          u.formattedInaugurationDate,
          u.fullAdd,
          u.latitude,
          u.longitude,
          u.isHighlyPreferred ? 'Yes' : 'No',
        ];
      }).toList();

      await AppExportUtils.exportToExcel(
        title: 'All Units',
        columns: headers,
        rows: data,
        fileName:
            'all_units_${DateTime.now().millisecondsSinceEpoch}',
      );

      AppCommonToastMessage.show(
        message: 'Exported units successfully.',
        type: ToastType.success,
      );
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Export failed: $e',
        type: ToastType.error,
      );
    } finally {
      isExporting.value = false;
    }
  }
  // endregion
}
// endregion

