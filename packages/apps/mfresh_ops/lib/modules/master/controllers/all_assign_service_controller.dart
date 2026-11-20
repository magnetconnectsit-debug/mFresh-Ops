// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_permissions.dart';
import 'package:mfresh_ops/data/models/master/assign_service_model.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/data/repositories/master_repository.dart';
import 'package:mfresh_ops/modules/master/controllers/assign_service_controller.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
// endregion

// region AllAssignServiceController
class AllAssignServiceController extends GetxController {
  // region Dependencies & Repositories
  final MasterRepository _repository = Get.find<MasterRepository>();
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  // endregion

  // region Observables & State Variables
  final assignedServices = <AllAssignServiceItem>[].obs;
  final filteredServices = <AllAssignServiceItem>[].obs;

  final isLoading = false.obs;
  final isExporting = false.obs;
  final isToggling = false.obs;

  final searchQuery = ''.obs;
  final searchCtrl = TextEditingController();

  final currentPage = 1.obs;
  final perPage = 10.obs;

  final Rxn<String> sortColumn = Rxn<String>();
  final Rx<AppTableSortOrder> sortOrder = AppTableSortOrder.none.obs;

  // Selected quick filter
  final selectedUnitFilter = ''.obs;
  final selectedStatusFilter = ''.obs;
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    fetchAllAssignServices();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }
  // endregion

  // region API & Network Operations
  Future<void> fetchAllAssignServices() async {
    try {
      isLoading.value = true;
      final response = await _repository.getAllAssignServices();
      if (response.status) {
        assignedServices.assignAll(response.data);
        _applySearchAndFilter();
      } else {
        AppCommonToastMessage.show(
          message: response.message ?? 'Failed to fetch assigned services.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error fetching assigned services: $e',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle Active / Inactive Status
  Future<void> toggleServiceStatus(AllAssignServiceItem item) async {
    if (!_checkPermission()) return;

    try {
      isToggling.value = true;
      final newStatus = item.status == 1 ? 0 : 1;
      item.status = newStatus;
      item.statusLabel = newStatus == 1 ? 'Active' : 'Inactive';

      assignedServices.refresh();
      filteredServices.refresh();

      AppCommonToastMessage.show(
        message: 'Status updated to ${item.statusLabel} successfully.',
        type: ToastType.success,
      );
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error updating status: $e',
        type: ToastType.error,
      );
    } finally {
      isToggling.value = false;
    }
  }
  // endregion

  // region Business Logic & Helpers
  bool _checkPermission() {
    if (!_authRepo.rxUserPermissions.contains(AppPermissions.masterPanel)) {
      AppCommonToastMessage.show(
        message: 'You do not have permission to perform this action.',
        type: ToastType.warning,
      );
      return false;
    }
    return true;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
    _applySearchAndFilter();
  }

  void onUnitFilterChanged(String unit) {
    selectedUnitFilter.value = unit;
    currentPage.value = 1;
    _applySearchAndFilter();
  }

  void onStatusFilterChanged(String status) {
    selectedStatusFilter.value = status;
    currentPage.value = 1;
    _applySearchAndFilter();
  }

  void resetFilters() {
    searchCtrl.clear();
    searchQuery.value = '';
    selectedUnitFilter.value = '';
    selectedStatusFilter.value = '';
    currentPage.value = 1;
    _applySearchAndFilter();
  }

  List<String> get availableUnits {
    final set = assignedServices
        .map((s) => s.assqrcodeId)
        .where((u) => u.isNotEmpty)
        .toSet()
        .toList();
    set.sort();
    return set;
  }

  void _applySearchAndFilter() {
    final query = searchQuery.value.trim().toLowerCase();
    final unitFilter = selectedUnitFilter.value.trim().toLowerCase();
    final statusFilter = selectedStatusFilter.value.trim().toLowerCase();

    List<AllAssignServiceItem> list = List.from(assignedServices);

    if (unitFilter.isNotEmpty) {
      list = list.where((s) => s.assqrcodeId.toLowerCase() == unitFilter).toList();
    }

    if (statusFilter.isNotEmpty) {
      if (statusFilter == 'active') {
        list = list.where((s) => s.status == 1).toList();
      } else if (statusFilter == 'inactive') {
        list = list.where((s) => s.status == 0).toList();
      }
    }

    if (query.isNotEmpty) {
      list = list.where((s) {
        final unit = s.assqrcodeId.toLowerCase();
        final name = (s.servicesName ?? '').toLowerCase();
        final sFor = (s.serviceFor ?? '').toLowerCase();
        final pType = (s.payType ?? '').toLowerCase();
        final price = (s.price ?? '').toLowerCase();
        final net = (s.netPrice ?? '').toLowerCase();
        final uses = (s.uses ?? '').toLowerCase();
        final status = (s.statusLabel ?? '').toLowerCase();

        return unit.contains(query) ||
            name.contains(query) ||
            sFor.contains(query) ||
            pType.contains(query) ||
            price.contains(query) ||
            net.contains(query) ||
            uses.contains(query) ||
            status.contains(query);
      }).toList();
    }

    if (sortColumn.value != null && sortOrder.value != AppTableSortOrder.none) {
      final isAsc = sortOrder.value == AppTableSortOrder.ascending;
      list.sort((a, b) {
        dynamic valA;
        dynamic valB;
        switch (sortColumn.value) {
          case 'unit':
            valA = a.assqrcodeId.toLowerCase();
            valB = b.assqrcodeId.toLowerCase();
            break;
          case 'service_name':
            valA = (a.servicesName ?? '').toLowerCase();
            valB = (b.servicesName ?? '').toLowerCase();
            break;
          case 'service_for':
            valA = (a.serviceFor ?? '').toLowerCase();
            valB = (b.serviceFor ?? '').toLowerCase();
            break;
          case 'pay_type':
            valA = (a.payType ?? '').toLowerCase();
            valB = (b.payType ?? '').toLowerCase();
            break;
          case 'price':
            valA = double.tryParse(a.price ?? '') ?? 0.0;
            valB = double.tryParse(b.price ?? '') ?? 0.0;
            break;
          case 'gst':
            valA = a.gstpercent ?? 0;
            valB = b.gstpercent ?? 0;
            break;
          case 'net_price':
            valA = double.tryParse(a.netPrice ?? '') ?? 0.0;
            valB = double.tryParse(b.netPrice ?? '') ?? 0.0;
            break;
          case 'uses':
            valA = (a.uses ?? '').toLowerCase();
            valB = (b.uses ?? '').toLowerCase();
            break;
          case 'status':
            valA = a.status;
            valB = b.status;
            break;
          default:
            valA = a.id;
            valB = b.id;
        }
        if (valA == null && valB == null) return 0;
        if (valA == null) return isAsc ? -1 : 1;
        if (valB == null) return isAsc ? 1 : -1;
        return isAsc ? valA.compareTo(valB) : valB.compareTo(valA);
      });
    }

    filteredServices.assignAll(list);
  }

  void sort(String columnKey, AppTableSortOrder order) {
    sortColumn.value = columnKey;
    sortOrder.value = order;
    _applySearchAndFilter();
  }

  void changePage(int page) {
    currentPage.value = page;
  }

  List<AllAssignServiceItem> get paginatedServices {
    if (filteredServices.isEmpty) return [];
    final start = (currentPage.value - 1) * perPage.value;
    if (start >= filteredServices.length) return [];
    final end = (start + perPage.value > filteredServices.length)
        ? filteredServices.length
        : start + perPage.value;
    return filteredServices.sublist(start, end);
  }

  int get totalPages {
    if (filteredServices.isEmpty) return 1;
    return (filteredServices.length / perPage.value).ceil();
  }

  /// Open create assign service screen
  void openCreateAssignService() {
    if (!_checkPermission()) return;

    final assignCtrl = Get.isRegistered<AssignServiceController>()
        ? Get.find<AssignServiceController>()
        : Get.put(AssignServiceController());

    assignCtrl.initForCreate();
    Get.toNamed(AppRoutes.masterAssignServiceCreateEdit);
  }

  /// Open edit assign service screen for the unit of the clicked row
  void editUnitAssignService(AllAssignServiceItem item) {
    if (!_checkPermission()) return;

    final assignCtrl = Get.isRegistered<AssignServiceController>()
        ? Get.find<AssignServiceController>()
        : Get.put(AssignServiceController());

    // 1. Check if unit exists in assignCtrl.units with parsed assignments
    final foundUnit = assignCtrl.units.firstWhereOrNull(
      (u) =>
          u.qrcodeId.trim().toLowerCase() ==
          item.assqrcodeId.trim().toLowerCase(),
    );

    if (foundUnit != null && foundUnit.assignments.isNotEmpty) {
      assignCtrl.initForEditFromUnitAssignments(foundUnit);
    } else {
      // 2. Use the already loaded assignedServices in memory for this unit (0ms)
      final unitRows = assignedServices
          .where(
            (s) =>
                s.assqrcodeId.trim().toLowerCase() ==
                item.assqrcodeId.trim().toLowerCase(),
          )
          .toList();

      final unit = foundUnit ??
          AssignUnitItem(
            id: item.id,
            qrcodeId: item.assqrcodeId,
            unitcategory: 'Vehicle',
          );

      assignCtrl.initForEditFromAllAssignServiceItems(unit, unitRows);
    }

    // 3. Navigate instantly without network delay
    Get.toNamed(AppRoutes.masterAssignServiceCreateEdit);
  }

  /// Export All Assigned Services to Excel
  Future<void> exportToExcel() async {
    try {
      isExporting.value = true;
      final headers = [
        'SI No.',
        'Unit ID\'s',
        'Service name',
        'Service For',
        'Pay Type',
        'Price',
        'GST (%)',
        'Net Price',
        'Uses',
        'Status',
      ];

      final rows = filteredServices.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final s = entry.value;
        return [
          index.toString(),
          s.assqrcodeId,
          s.servicesName ?? '',
          s.serviceFor ?? '',
          s.payType ?? '',
          s.price ?? '',
          s.gstpercent?.toString() ?? '0',
          s.netPrice ?? '',
          s.uses ?? '',
          s.statusLabel ?? (s.status == 1 ? 'Active' : 'Inactive'),
        ];
      }).toList();

      await AppExportUtils.exportToExcel(
        title: 'All Assign Services',
        columns: headers,
        rows: rows,
        fileName: 'All_Assign_Services_${DateTime.now().millisecondsSinceEpoch}',
      );

      AppCommonToastMessage.show(
        message: 'All Assign Services exported successfully.',
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
