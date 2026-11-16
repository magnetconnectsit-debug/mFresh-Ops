// region Imports
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/utils/app_image_compressor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/home/models/attendance_unit_item.dart';
import 'package:mfresh_ops/modules/home/views/employee_selection_screen.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:services/api_services.dart';
import 'package:services/storage_service.dart';
// endregion

// region UnitSelectionController
class UnitSelectionController extends GetxController {
  // region Dependencies & Repositories
  late final ApiService _apiService;
  late final AuthRepository _authRepo;
  // endregion

  // region Constructor
  final bool isSelfieAttendance;
  UnitSelectionController({this.isSelfieAttendance = false});
  // endregion

  // region Observables & State Variables
  final isLoading = false.obs;
  final isLoadingEmployees = false.obs;
  final isSubmitting = false.obs;
  final searchQuery = ''.obs;
  final unitList = <AttendanceUnitItem>[].obs;
  final employeeList = <AttendanceEmployeeItem>[].obs;
  final selectedEmployee = Rxn<AttendanceEmployeeItem>();
  final selectedUnit = Rxn<AttendanceUnitItem>();
  // endregion

  // region Text Controllers & Focus Nodes
  final searchController = TextEditingController();
  // endregion

  // region Computed Properties
  List<AttendanceUnitItem> get filteredUnits {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return unitList;
    return unitList.where((u) {
      return u.name.toLowerCase().contains(query) ||
          u.location.toLowerCase().contains(query) ||
          u.id.toLowerCase().contains(query);
    }).toList();
  }

  Map<String, List<AttendanceUnitItem>> get groupedUnits {
    final Map<String, List<AttendanceUnitItem>> grouped = {};
    for (final unit in filteredUnits) {
      final locationKey = unit.location.isNotEmpty ? unit.location : 'Other';
      grouped.putIfAbsent(locationKey, () => []).add(unit);
    }
    return grouped;
  }
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    _apiService = Get.find<ApiService>();
    _authRepo = Get.find<AuthRepository>();
    fetchUnits();
    if (isSelfieAttendance) {
      fetchEmployees();
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
  // endregion

  // region API & Data Operations
  Future<void> fetchUnits() async {
    isLoading.value = true;
    try {
      final response =
          await _apiService.post(AppConstants.supportUnits, data: {});
      if (response != null && response['status'] == true) {
        final List data = response['data'] ?? [];
        unitList.assignAll(data.map((e) {
          final id =
              (e['unitid'] ?? e['id'] ?? e['Unit_Id'])?.toString() ?? '';
          final name =
              (e['unitname'] ?? e['unit_name'] ?? e['Unit_Name'])?.toString() ??
                  id;
          final location = (e['district_name'] ??
                  e['unit_location'] ??
                  e['location'] ??
                  e['Unit_location'])
              ?.toString() ??
              '';
          var img = (e['unit_image'] ?? e['image'] ?? e['Unit_Image'])
                  ?.toString() ??
              '';
          if (img.isNotEmpty && !img.startsWith('http')) {
            img = 'https://$img';
          }
          return AttendanceUnitItem(
            id: id,
            name: name,
            location: location,
            image: img,
          );
        }));
      }
    } catch (e) {
      debugPrint('Error loading units in UnitSelectionController: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchEmployees() async {
    isLoadingEmployees.value = true;
    try {
      final response = await _apiService.post(AppConstants.staffEmployees);
      if (response != null && response is Map && response['status'] == true) {
        final List emps = response['employees'] ?? [];
        final list = emps
            .whereType<Map>()
            .map((e) =>
                AttendanceEmployeeItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        employeeList.assignAll(list);

        // Pre-select currently logged-in user if found in employee list
        if (Get.isRegistered<StorageService>()) {
          final currentUser = Get.find<StorageService>().getUser();
          if (currentUser != null) {
            final match = list.firstWhereOrNull((e) => e.id == currentUser.id);
            if (match != null) {
              selectedEmployee.value = match.copyWith(
                isCheckedIn: _authRepo.rxIsCheckedIn.value,
              );
            } else if (list.isNotEmpty) {
              selectedEmployee.value = list.first;
            }
          } else if (list.isNotEmpty) {
            selectedEmployee.value = list.first;
          }
        } else if (list.isNotEmpty) {
          selectedEmployee.value = list.first;
        }
      }
    } catch (e) {
      debugPrint('Error loading employees in UnitSelectionController: $e');
    } finally {
      isLoadingEmployees.value = false;
    }
  }
  // endregion

  // region Business Logic & Helpers
  bool isEmployeeCheckedIn(AttendanceEmployeeItem employee) {
    if (Get.isRegistered<StorageService>()) {
      final currentUser = Get.find<StorageService>().getUser();
      if (currentUser != null && currentUser.id == employee.id) {
        return _authRepo.rxIsCheckedIn.value;
      }
    }
    return employee.isCheckedIn;
  }

  void onSearchChanged(String val) {
    searchQuery.value = val;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void selectEmployee(int? id) {
    if (id == null) {
      selectedEmployee.value = null;
    } else {
      selectedEmployee.value = employeeList.firstWhereOrNull((e) => e.id == id);
    }
    selectedUnit.value = null;
  }

  Future<void> onUnitCardTap(
    AttendanceUnitItem unit,
    BuildContext context,
  ) async {
    if (!isSelfieAttendance) {
      Navigator.of(context).pop(unit);
      return;
    }

    selectedUnit.value = unit;
    final employee = selectedEmployee.value;
    final isCheckedIn = employee != null
        ? isEmployeeCheckedIn(employee)
        : _authRepo.rxIsCheckedIn.value;

    final capturedPath = await Get.toNamed(
      AppRoutes.camera,
      arguments: {'confirmButtonText': isCheckedIn ? 'Check Out' : 'Check In'},
    );
    if (capturedPath != null &&
        capturedPath is String &&
        capturedPath.isNotEmpty) {
      isSubmitting.value = true;
      try {
        final compressedPath = await AppImageCompressor.compressPath(
              capturedPath,
              quality: 50,
            ) ??
            capturedPath;

        bool success = false;
        if (isCheckedIn) {
          success = await _authRepo.attendanceCheckOut(
            imagePath: compressedPath,
            userId: employee?.id.toString(),
          );
        } else {
          success = await _authRepo.attendanceCheckIn(
            imagePath: compressedPath,
            unitId: unit.id,
            userId: employee?.id.toString(),
          );
        }

        if (success) {
          if (employee != null) {
            final updated = employee.copyWith(isCheckedIn: !isCheckedIn);
            selectedEmployee.value = updated;
            final idx = employeeList.indexWhere((e) => e.id == employee.id);
            if (idx != -1) {
              employeeList[idx] = updated;
            }
          }
          selectedUnit.value = null;
          Get.back(result: true);
        }
      } catch (e) {
        debugPrint('Error during unit attendance: $e');
      } finally {
        isSubmitting.value = false;
      }
    }
  }

  Future<void> handleCheckIn(AttendanceEmployeeItem employee) async {
    if (selectedUnit.value == null) {
      AppCommonToastMessage.show(
        message: 'Please select a unit to check in',
        type: ToastType.warning,
      );
      return;
    }

    final capturedPath = await Get.toNamed(
      AppRoutes.camera,
      arguments: {'confirmButtonText': 'Check In'},
    );
    if (capturedPath != null &&
        capturedPath is String &&
        capturedPath.isNotEmpty) {
      isSubmitting.value = true;
      try {
        final compressedPath = await AppImageCompressor.compressPath(
              capturedPath,
              quality: 50,
            ) ??
            capturedPath;

        final success = await _authRepo.attendanceCheckIn(
          imagePath: compressedPath,
          unitId: selectedUnit.value!.id,
          userId: employee.id.toString(),
        );

        if (success) {
          final updated = employee.copyWith(isCheckedIn: true);
          selectedEmployee.value = updated;
          final idx = employeeList.indexWhere((e) => e.id == employee.id);
          if (idx != -1) {
            employeeList[idx] = updated;
          }
          selectedUnit.value = null;
          Get.back(result: true);
        }
      } catch (e) {
        debugPrint('Error during check in: $e');
      } finally {
        isSubmitting.value = false;
      }
    }
  }

  Future<void> handleCheckOut(AttendanceEmployeeItem employee) async {
    final capturedPath = await Get.toNamed(
      AppRoutes.camera,
      arguments: {'confirmButtonText': 'Check Out'},
    );
    if (capturedPath != null &&
        capturedPath is String &&
        capturedPath.isNotEmpty) {
      isSubmitting.value = true;
      try {
        final compressedPath = await AppImageCompressor.compressPath(
              capturedPath,
              quality: 50,
            ) ??
            capturedPath;

        final success = await _authRepo.attendanceCheckOut(
          imagePath: compressedPath,
          userId: employee.id.toString(),
        );

        if (success) {
          final updated = employee.copyWith(isCheckedIn: false);
          selectedEmployee.value = updated;
          final idx = employeeList.indexWhere((e) => e.id == employee.id);
          if (idx != -1) {
            employeeList[idx] = updated;
          }
          selectedUnit.value = null;
          Get.back(result: true);
        }
      } catch (e) {
        debugPrint('Error during check out: $e');
      } finally {
        isSubmitting.value = false;
      }
    }
  }
  // endregion
}
// endregion

