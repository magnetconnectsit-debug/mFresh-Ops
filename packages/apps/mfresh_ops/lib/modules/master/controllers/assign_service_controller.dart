// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/master/assign_service_model.dart';
import 'package:mfresh_ops/data/models/master/service_model.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/data/repositories/master_repository.dart';
import 'package:mfresh_ops/core/constants/app_permissions.dart';
// endregion

// region AssignServiceController
class AssignServiceController extends GetxController {
  // region Dependencies & Repositories
  final MasterRepository _repository = Get.find<MasterRepository>();
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  // endregion

  // region Observables & State Variables
  final units = <AssignUnitItem>[].obs;
  final filteredUnits = <AssignUnitItem>[].obs;
  final services = <ServiceItem>[].obs;

  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final isExporting = false.obs;
  final searchQuery = ''.obs;

  // Sorting
  final sortColumn = Rxn<String>();
  final sortOrder = AppTableSortOrder.none.obs;

  // Pagination
  final currentPage = 1.obs;
  final perPage = 25.obs;
  final totalRecords = 0.obs;

  // Form State for Create / Edit
  final isEditMode = false.obs;
  final selectedUnitQr = ''.obs;
  final selectedUnit = Rxn<AssignUnitItem>();
  final serviceGroups = <AssignedServiceGroup>[].obs;
  // endregion

  // region Text Controllers & Focus Nodes
  final searchCtrl = TextEditingController();

  // Dynamic cell text editing controllers: key = "${groupIndex}_${rowIndex}_${fieldName}"
  final Map<String, TextEditingController> _matrixControllers = {};
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    fetchAssignsIndex();
    fetchServices();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    _disposeMatrixControllers();
    super.onClose();
  }

  void _disposeMatrixControllers() {
    for (final ctrl in _matrixControllers.values) {
      ctrl.dispose();
    }
    _matrixControllers.clear();
  }
  // endregion

  // region API & Network Operations
  /// Fetch unit assigns index
  Future<void> fetchAssignsIndex() async {
    try {
      isLoading.value = true;
      final response = await _repository.getAssignsIndex();
      if (response.status) {
        units.assignAll(response.data);
        totalRecords.value = response.count > 0
            ? response.count
            : response.data.length;
        _applySearchFilter();
      } else {
        AppCommonToastMessage.show(
          message: response.message != null && response.message!.isNotEmpty
              ? response.message!
              : 'Failed to fetch assigned units.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error fetching assigned units: $e',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch all master services for dropdown
  Future<void> fetchServices() async {
    try {
      final response = await _repository.getServices();
      if (response.status) {
        services.assignAll(response.data);
      }
    } catch (_) {}
  }

  /// Submit Create Assign Service
  Future<bool> submitCreate() async {
    if (!_checkPermission()) return false;

    if (selectedUnitQr.value.trim().isEmpty) {
      AppCommonToastMessage.show(
        message: 'Please select a unit.',
        type: ToastType.warning,
      );
      return false;
    }

    if (serviceGroups.isEmpty) {
      AppCommonToastMessage.show(
        message: 'Please add at least one service.',
        type: ToastType.warning,
      );
      return false;
    }

    for (int i = 0; i < serviceGroups.length; i++) {
      if (serviceGroups[i].serviceId == null ||
          serviceGroups[i].serviceId == 0) {
        AppCommonToastMessage.show(
          message: 'Please select a valid service for Group #${i + 1}.',
          type: ToastType.warning,
        );
        return false;
      }
    }

    try {
      isSubmitting.value = true;

      final List<int> serviceIds = [];
      final List<int> servicesFor = [];
      final List<int> payTypes = [];
      final List<num> grossPrices = [];
      final List<num> gsts = [];
      final List<dynamic> uses = [];
      final List<dynamic> orders = [];

      for (int g = 0; g < serviceGroups.length; g++) {
        final group = serviceGroups[g];
        serviceIds.add(group.serviceId!);

        for (int r = 0; r < group.rows.length; r++) {
          final row = group.rows[r];
          _syncRowFromControllers(g, r, row);

          servicesFor.add(row.servicesFor);
          payTypes.add(row.payType);
          grossPrices.add(row.grossPrice);
          gsts.add(row.gst);
          uses.add(
              row.usesText ?? (row.uses == 1 ? 'Use' : row.uses.toString()));
          orders.add(row.order.toString());
        }
      }

      final response = await _repository.createAssignService(
        assignqrId: selectedUnitQr.value.trim(),
        serviceIds: serviceIds,
        servicesFor: servicesFor,
        payTypes: payTypes,
        grossPrices: grossPrices,
        gsts: gsts,
        uses: uses,
        orders: orders,
      );

      final isSuccess = response['status'] == true;
      if (isSuccess) {
        AppCommonToastMessage.show(
          message:
              response['message']?.toString() ??
              'Assigned services created successfully.',
          type: ToastType.success,
        );
        fetchAssignsIndex();
        Get.back();
        return true;
      } else {
        AppCommonToastMessage.show(
          message:
              response['message']?.toString() ??
              'Failed to create assigned services.',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error creating assigned services: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Submit Update Assign Service
  Future<bool> submitUpdate() async {
    if (!_checkPermission()) return false;

    if (selectedUnitQr.value.trim().isEmpty) {
      AppCommonToastMessage.show(
        message: 'Unit QR code is required for update.',
        type: ToastType.warning,
      );
      return false;
    }

    if (serviceGroups.isEmpty) {
      AppCommonToastMessage.show(
        message: 'Please add at least one service.',
        type: ToastType.warning,
      );
      return false;
    }

    try {
      isSubmitting.value = true;

      final List<int> serviceIds = [];
      final List<int> rowsPerService = [];
      final List<int> rowIds = [];
      final List<int> servicesFor = [];
      final List<int> payTypes = [];
      final List<num> grossPrices = [];
      final List<num> gsts = [];
      final List<num> netAmounts = [];
      final List<dynamic> uses = [];
      final List<dynamic> orders = [];
      final List<int> statuses = [];

      for (int g = 0; g < serviceGroups.length; g++) {
        final group = serviceGroups[g];
        serviceIds.add(group.serviceId ?? 0);
        rowsPerService.add(group.rows.length);

        for (int r = 0; r < group.rows.length; r++) {
          final row = group.rows[r];
          _syncRowFromControllers(g, r, row);

          rowIds.add(row.rowId ?? (r + 1));
          servicesFor.add(row.servicesFor);
          payTypes.add(row.payType);
          grossPrices.add(row.grossPrice);
          gsts.add(row.gst);
          netAmounts.add(row.netAmount);
          uses.add(
              row.usesText ?? (row.uses == 1 ? 'Use' : row.uses.toString()));
          orders.add(row.order.toString());
          statuses.add(row.status);
        }
      }

      final response = await _repository.updateAssignService(
        assignqrId: selectedUnitQr.value.trim(),
        serviceIds: serviceIds,
        rowsPerService: rowsPerService,
        rowIds: rowIds,
        servicesFor: servicesFor,
        payTypes: payTypes,
        grossPrices: grossPrices,
        gsts: gsts,
        netAmounts: netAmounts,
        uses: uses,
        orders: orders,
        statuses: statuses,
      );

      final isSuccess = response['status'] == true;
      if (isSuccess) {
        AppCommonToastMessage.show(
          message:
              response['message']?.toString() ??
              'Assigned services updated successfully.',
          type: ToastType.success,
        );
        fetchAssignsIndex();
        Get.back();
        return true;
      } else {
        AppCommonToastMessage.show(
          message:
              response['message']?.toString() ??
              'Failed to update assigned services.',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error updating assigned services: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
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
    _applySearchFilter();
  }

  void _applySearchFilter() {
    final query = searchQuery.value.trim().toLowerCase();
    List<AssignUnitItem> list = List.from(units);

    if (query.isNotEmpty) {
      list = list.where((u) {
        final qrcode = u.qrcodeId.toLowerCase();
        final model = (u.unitcategory ?? '').toLowerCase();
        final city = (u.unitLocation ?? '').toLowerCase();
        final addr = (u.fullAdd ?? '').toLowerCase();
        final date = (u.ingDate ?? '').toLowerCase();
        return qrcode.contains(query) ||
            model.contains(query) ||
            city.contains(query) ||
            addr.contains(query) ||
            date.contains(query);
      }).toList();
    }

    if (sortColumn.value != null && sortOrder.value != AppTableSortOrder.none) {
      final isAsc = sortOrder.value == AppTableSortOrder.ascending;
      list.sort((a, b) {
        dynamic valA;
        dynamic valB;
        switch (sortColumn.value) {
          case 'unit':
            valA = a.qrcodeId.toLowerCase();
            valB = b.qrcodeId.toLowerCase();
            break;
          case 'model':
            valA = (a.unitcategory ?? '').toLowerCase();
            valB = (b.unitcategory ?? '').toLowerCase();
            break;
          case 'city':
            valA = (a.unitLocation ?? '').toLowerCase();
            valB = (b.unitLocation ?? '').toLowerCase();
            break;
          case 'inauguration_date':
            valA = a.ingDate ?? '';
            valB = b.ingDate ?? '';
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

    filteredUnits.assignAll(list);
  }

  void sort(String columnKey, AppTableSortOrder order) {
    sortColumn.value = columnKey;
    sortOrder.value = order;
    _applySearchFilter();
  }

  void changePage(int page) {
    currentPage.value = page;
  }

  List<AssignUnitItem> get paginatedUnits {
    if (filteredUnits.isEmpty) return [];
    final start = (currentPage.value - 1) * perPage.value;
    if (start >= filteredUnits.length) return [];
    final end = (start + perPage.value > filteredUnits.length)
        ? filteredUnits.length
        : start + perPage.value;
    return filteredUnits.sublist(start, end);
  }

  int get totalPages {
    if (filteredUnits.isEmpty) return 1;
    return (filteredUnits.length / perPage.value).ceil();
  }

  /// Initialize state for Create Screen
  void initForCreate() {
    isLoading.value = false;
    isSubmitting.value = false;
    isEditMode.value = false;
    selectedUnitQr.value = '';
    selectedUnit.value = null;
    _disposeMatrixControllers();
    serviceGroups.clear();
    // Start with 1 default service block
    addServiceGroup();
  }

  /// Initialize state for Edit Screen
  void initForEdit(
    AssignUnitItem unit, [
    List<AssignedServiceGroup>? existingGroups,
  ]) {
    isLoading.value = false;
    isSubmitting.value = false;
    isEditMode.value = true;
    selectedUnitQr.value = unit.qrcodeId;
    selectedUnit.value = unit;
    _disposeMatrixControllers();
    serviceGroups.clear();

    if (existingGroups != null && existingGroups.isNotEmpty) {
      serviceGroups.assignAll(existingGroups);
    } else {
      // Provide default service blocks matching typical assignment or 1 default block
      addServiceGroup();
    }
  }

  /// Initialize state for Edit Screen synchronously from unit's embedded assignments
  void initForEditFromUnitAssignments(AssignUnitItem unit) {
    final List<AssignedServiceGroup> groups = [];
    for (final asgn in unit.assignments) {
      final sId = asgn.serviceId;
      final sName = asgn.serviceName;
      final foundService = services.firstWhereOrNull((s) => s.id == sId);

      final group = AssignedServiceGroup(
        serviceId: sId > 0 ? sId : null,
        serviceName: sName ?? foundService?.servicesName,
        iconUrl: foundService?.imgIconUrl,
      );

      for (final row in asgn.rows) {
        final gross = double.tryParse(row.grossPrice) ?? 0.0;
        final gstVal = row.gst.toDouble();
        final netVal = double.tryParse(row.netAmount) ?? 0.0;
        final orderVal = int.tryParse(row.order) ?? 0;
        final parsedUses = int.tryParse(row.uses) ??
            (row.uses.toLowerCase() == 'use' ? 1 : 1);

        group.rows.add(
          AssignedServiceRow(
            rowId: row.rowId,
            serviceId: sId,
            servicesFor: row.servicesFor,
            payType: row.payType,
            grossPrice: gross,
            gst: gstVal,
            netAmount: netVal,
            uses: parsedUses,
            usesText: row.uses,
            order: orderVal,
            status: row.status,
          ),
        );
      }
      groups.add(group);
    }

    initForEdit(unit, groups);
  }

  /// Initialize state for Edit Screen synchronously from preloaded AllAssignServiceItem rows
  void initForEditFromAllAssignServiceItems(
    AssignUnitItem unit,
    List<AllAssignServiceItem> unitServices,
  ) {
    if (unitServices.isEmpty) {
      initForEdit(unit);
      return;
    }

    final Map<int, List<AllAssignServiceItem>> serviceMap = {};
    for (final item in unitServices) {
      final sId = int.tryParse(item.serviceId) ?? 0;
      serviceMap.putIfAbsent(sId, () => []).add(item);
    }

    final List<AssignedServiceGroup> groups = [];
    for (final entry in serviceMap.entries) {
      final sId = entry.key;
      final items = entry.value;
      final sName = items.first.servicesName;
      final foundService = services.firstWhereOrNull((s) => s.id == sId);

      final group = AssignedServiceGroup.createDefault(
        serviceId: sId > 0 ? sId : null,
        serviceName: sName ?? foundService?.servicesName,
        iconUrl: foundService?.imgIconUrl,
      );

      for (final item in items) {
        final isMember = item.memStatus == 1 ||
            (item.serviceFor?.toLowerCase().contains('mem') ?? false);
        final isOnline = item.paytype == 2 ||
            (item.payType?.toLowerCase() == 'online');
        final targetFor = isMember ? 1 : 0;
        final targetPay = isOnline ? 2 : 1;

        final matchingRow = group.rows.firstWhereOrNull(
          (r) => r.servicesFor == targetFor && r.payType == targetPay,
        );

        if (matchingRow != null) {
          final p = double.tryParse(item.price ?? '') ?? 0.0;
          final g = item.gstpercent?.toDouble() ?? 0.0;
          final n = double.tryParse(item.netPrice ?? '') ??
              (g > 0 ? (p / (1 + (g / 100))) : p);
          final u = int.tryParse(item.uses ?? '') ??
              (item.uses?.toLowerCase() == 'use' ? 1 : 1);

          matchingRow.rowId = item.id > 0 ? item.id : matchingRow.rowId;
          matchingRow.grossPrice = p;
          matchingRow.gst = g;
          matchingRow.netAmount = n;
          matchingRow.uses = u;
          matchingRow.usesText = item.uses;
          matchingRow.status = item.status;
        }
      }
      groups.add(group);
    }

    initForEdit(unit, groups);
  }

  /// Load existing services from unit data or API and initialize for Edit Screen
  Future<void> loadAndInitForEdit(AssignUnitItem unit) async {
    if (unit.assignments.isNotEmpty) {
      initForEditFromUnitAssignments(unit);
      return;
    }

    try {
      isLoading.value = true;
      final response = await _repository.getAllAssignServices();
      if (response.status && response.data.isNotEmpty) {
        final unitServices = response.data.where(
          (s) =>
              s.assqrcodeId.trim().toLowerCase() ==
              unit.qrcodeId.trim().toLowerCase(),
        ).toList();

        if (unitServices.isNotEmpty) {
          initForEditFromAllAssignServiceItems(unit, unitServices);
          return;
        }
      }
    } catch (_) {
      // Fallback to default
    } finally {
      isLoading.value = false;
    }

    initForEdit(unit);
  }

  /// Add a new service group block
  void addServiceGroup({int? serviceId}) {
    final newGroup = AssignedServiceGroup.createDefault(
      serviceId: serviceId,
      defaultOrder: 0,
    );

    if (serviceId != null) {
      final found = services.firstWhereOrNull((s) => s.id == serviceId);
      if (found != null) {
        newGroup.serviceName = found.servicesName;
        newGroup.iconUrl = found.imgIconUrl;
      }
    }

    serviceGroups.add(newGroup);
    final groupIndex = serviceGroups.length - 1;

    for (int r = 0; r < newGroup.rows.length; r++) {
      getGrossPriceController(groupIndex, r, initialValue: '');
      getGstController(groupIndex, r, initialValue: '');
      getNetAmountController(groupIndex, r, initialValue: '');
      getChargeTypeController(groupIndex, r, initialValue: '');
      getOrderController(groupIndex, r, initialValue: '');
    }
  }

  /// Remove a service group block
  void removeServiceGroup(int groupIndex) {
    if (serviceGroups.length <= 1) {
      AppCommonToastMessage.show(
        message: 'At least one service is required.',
        type: ToastType.warning,
      );
      return;
    }
    serviceGroups.removeAt(groupIndex);
    // Refresh controllers mapping
    _rebuildControllersFromGroups();
  }

  void _rebuildControllersFromGroups() {
    _disposeMatrixControllers();
    for (int g = 0; g < serviceGroups.length; g++) {
      final grp = serviceGroups[g];
      for (int r = 0; r < grp.rows.length; r++) {
        final row = grp.rows[r];
        getGrossPriceController(
          g,
          r,
          initialValue: row.grossPrice > 0 ? _formatNum(row.grossPrice) : '',
        );
        getGstController(
          g,
          r,
          initialValue: row.gst > 0 ? _formatNum(row.gst) : '',
        );
        getNetAmountController(
          g,
          r,
          initialValue: row.netAmount > 0 ? _formatNum(row.netAmount) : '',
        );
        getChargeTypeController(
          g,
          r,
          initialValue: isEditMode.value
              ? (row.usesText ??
                  (row.uses > 0
                      ? (row.uses == 1 ? 'Use' : row.uses.toString())
                      : ''))
              : '',
        );
        getOrderController(
          g,
          r,
          initialValue: isEditMode.value && row.order > 0
              ? row.order.toString()
              : '',
        );
      }
    }
  }

  void onServiceSelected(int groupIndex, int? serviceId) {
    if (groupIndex >= serviceGroups.length) return;
    final group = serviceGroups[groupIndex];
    group.serviceId = serviceId;

    if (serviceId != null) {
      final found = services.firstWhereOrNull((s) => s.id == serviceId);
      if (found != null) {
        group.serviceName = found.servicesName;
        group.iconUrl = found.imgIconUrl;
      }
    } else {
      group.serviceName = null;
      group.iconUrl = null;
    }

    for (final row in group.rows) {
      row.serviceId = serviceId ?? 0;
    }
    serviceGroups.refresh();
  }

  /// Matrix cell controllers getters
  TextEditingController getGrossPriceController(
    int groupIndex,
    int rowIndex, {
    String initialValue = '',
  }) {
    final key = '${groupIndex}_${rowIndex}_gross';
    return _matrixControllers.putIfAbsent(
      key,
      () => TextEditingController(text: initialValue),
    );
  }

  TextEditingController getGstController(
    int groupIndex,
    int rowIndex, {
    String initialValue = '',
  }) {
    final key = '${groupIndex}_${rowIndex}_gst';
    return _matrixControllers.putIfAbsent(
      key,
      () => TextEditingController(text: initialValue),
    );
  }

  TextEditingController getNetAmountController(
    int groupIndex,
    int rowIndex, {
    String initialValue = '',
  }) {
    final key = '${groupIndex}_${rowIndex}_net';
    return _matrixControllers.putIfAbsent(
      key,
      () => TextEditingController(text: initialValue),
    );
  }

  TextEditingController getChargeTypeController(
    int groupIndex,
    int rowIndex, {
    String initialValue = '',
  }) {
    final key = '${groupIndex}_${rowIndex}_charge';
    return _matrixControllers.putIfAbsent(
      key,
      () => TextEditingController(text: initialValue),
    );
  }

  TextEditingController getOrderController(
    int groupIndex,
    int rowIndex, {
    String initialValue = '',
  }) {
    final key = '${groupIndex}_${rowIndex}_order';
    return _matrixControllers.putIfAbsent(
      key,
      () => TextEditingController(text: initialValue),
    );
  }

  /// Recalculate Net Amount: Net Amount = Gross / (1 + (GST / 100))
  void calculateNetAmount(int groupIndex, int rowIndex) {
    final grossStr = getGrossPriceController(groupIndex, rowIndex).text.trim();
    final gstStr = getGstController(groupIndex, rowIndex).text.trim();

    if (grossStr.isEmpty) {
      getNetAmountController(groupIndex, rowIndex).text = '';
      if (groupIndex < serviceGroups.length &&
          rowIndex < serviceGroups[groupIndex].rows.length) {
        final row = serviceGroups[groupIndex].rows[rowIndex];
        row.grossPrice = 0.0;
        row.gst = double.tryParse(gstStr) ?? 0.0;
        row.netAmount = 0.0;
      }
      return;
    }

    final gross = double.tryParse(grossStr) ?? 0.0;
    final gst = double.tryParse(gstStr) ?? 0.0;

    double net = gross;
    if (gst > 0) {
      net = gross / (1.0 + (gst / 100.0));
    }

    final formattedNet = _formatNum(net);
    getNetAmountController(groupIndex, rowIndex).text = formattedNet;

    if (groupIndex < serviceGroups.length &&
        rowIndex < serviceGroups[groupIndex].rows.length) {
      final row = serviceGroups[groupIndex].rows[rowIndex];
      row.grossPrice = gross;
      row.gst = gst;
      row.netAmount = double.tryParse(formattedNet) ?? net;
    }
  }

  void _syncRowFromControllers(
    int groupIndex,
    int rowIndex,
    AssignedServiceRow row,
  ) {
    final gross =
        double.tryParse(
          getGrossPriceController(groupIndex, rowIndex).text.trim(),
        ) ??
        0.0;
    final gst =
        double.tryParse(getGstController(groupIndex, rowIndex).text.trim()) ??
        0.0;
    final netStr = getNetAmountController(groupIndex, rowIndex).text.trim();
    final net =
        double.tryParse(netStr) ??
        (gross > 0
            ? (gst > 0 ? (gross / (1.0 + (gst / 100.0))) : gross)
            : 0.0);
    final orderText = getOrderController(groupIndex, rowIndex).text.trim();
    final order =
        int.tryParse(orderText) ??
        (orderText.isNotEmpty
            ? 0
            : (row.order > 0 ? row.order : (rowIndex + 1)));

    final chargeText = getChargeTypeController(groupIndex, rowIndex).text.trim();
    final uses = int.tryParse(chargeText) ??
        (chargeText.toLowerCase() == 'use' ? 1 : (row.uses > 0 ? row.uses : 1));

    row.grossPrice = gross;
    row.gst = gst;
    row.netAmount = net;
    row.order = order;
    row.uses = uses;
    row.usesText = chargeText.isNotEmpty ? chargeText : (row.usesText ?? 'Use');
  }

  String formatNum(double val) => _formatNum(val);
  String _formatNum(double val) {
    if (val == val.roundToDouble()) {
      return val.toInt().toString();
    }
    return val.toStringAsFixed(2);
  }

  /// Export Assign Units to Excel
  Future<void> exportToExcel() async {
    try {
      isExporting.value = true;
      final headers = [
        'SI No.',
        'Unit',
        'Model',
        'City',
        'Operating Hrs / Address',
        'Inauguration Date',
      ];

      final rows = filteredUnits.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final u = entry.value;
        return [
          index.toString(),
          u.qrcodeId,
          u.unitcategory ?? '',
          u.unitLocation ?? '',
          u.fullAdd ?? '',
          u.ingDate ?? '',
        ];
      }).toList();

      await AppExportUtils.exportToExcel(
        title: 'Assign Services',
        columns: headers,
        rows: rows,
        fileName: 'Assign_Services_${DateTime.now().millisecondsSinceEpoch}',
      );

      AppCommonToastMessage.show(
        message: 'Assign Services exported successfully.',
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
