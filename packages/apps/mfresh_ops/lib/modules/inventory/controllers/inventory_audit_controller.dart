import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:services/services.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';

class AuditItem {
  final int itemId;
  final String itemName;
  final String categoryName;
  final String systemQtyStr; // EXACT string returned from backend (e.g. "2 pcs" or "294 ml")
  final double systemQtyNum;  // Numeric value extracted for calculation
  final String unitSuffix;   // Unit suffix for calculation
  String? auditQty;

  AuditItem({
    required this.itemId,
    required this.itemName,
    required this.categoryName,
    required this.systemQtyStr,
    required this.systemQtyNum,
    required this.unitSuffix,
    this.auditQty,
  });
}

class AdditionalAuditItem {
  final String itemName;
  final int measurementUnitId;
  final String measurementUnitName;
  final double actualQty;

  AdditionalAuditItem({
    required this.itemName,
    required this.measurementUnitId,
    required this.measurementUnitName,
    required this.actualQty,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_name': itemName,
      'measurement_unit_id': measurementUnitId,
      'actual_qty': actualQty,
    };
  }
}

class EditableAdditionalItem {
  final int id;
  final TextEditingController nameController;
  final TextEditingController qtyController;
  final RxString selectedUnitId;
  final RxString selectedUnitName;

  EditableAdditionalItem({
    required this.id,
    String initialName = '',
    String initialQty = '',
    String initialUnitId = '',
    String initialUnitName = '',
  })  : nameController = TextEditingController(text: initialName),
        qtyController = TextEditingController(text: initialQty),
        selectedUnitId = initialUnitId.obs,
        selectedUnitName = initialUnitName.obs;

  void dispose() {
    nameController.dispose();
    qtyController.dispose();
  }
}

class InventoryAuditController extends GetxController {
  final InventoryRepository _repository = Get.find<InventoryRepository>();

  // Unit dropdown options (reused from unit inventory)
  final unitOptions = <DropdownOption>[].obs;

  // Measurement unit dropdown options
  final measurementOptions = <DropdownOption>[].obs;

  // Selected units (multiselect, but audit operates one unit at a time)
  final selectedUnitIds = <String>[].obs;

  // Items for selected unit
  final auditItems = <AuditItem>[].obs;

  // Additional items added dynamically at top of table
  final editableAdditionalItems = <EditableAdditionalItem>[].obs;

  // Additional items added during audit
  final additionalAuditItems = <AdditionalAuditItem>[].obs;

  final isLoadingUnits = false.obs;
  final isLoadingItems = false.obs;
  final isSubmitting = false.obs;

  // Per-item qty controllers keyed by itemId
  final Map<int, TextEditingController> qtyControllers = {};

  // Reactive quantity map — used by Obx in the table widget
  final auditQtys = <int, String>{}.obs;

  // Search controller & observables
  final searchController = TextEditingController();
  final isSearching = false.obs;
  final searchQuery = ''.obs;

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      searchQuery.value = '';
    }
  }

  // Sorting observables (Default: Category ascending)
  final sortColumn = 'category'.obs;
  final sortAscending = true.obs;
  final categorySortAscending = true.obs; // Remembers category sort direction (increasing/decreasing)

  void toggleSort(String columnKey) {
    if (columnKey == 'category') {
      if (sortColumn.value == 'category') {
        categorySortAscending.value = !categorySortAscending.value;
        sortAscending.value = categorySortAscending.value;
      } else {
        sortColumn.value = 'category';
        sortAscending.value = categorySortAscending.value;
      }
    } else {
      if (sortColumn.value == columnKey) {
        if (sortAscending.value) {
          sortAscending.value = false;
        } else {
          // Reset column sort back to category
          sortColumn.value = 'category';
          sortAscending.value = categorySortAscending.value;
        }
      } else {
        sortColumn.value = columnKey;
        sortAscending.value = true;
      }
    }
  }

  List<AuditItem> get sortedAuditItems {
    final query = searchQuery.value.trim().toLowerCase();

    List<AuditItem> list;
    if (query.isNotEmpty) {
      list = auditItems.where((item) {
        return item.itemName.toLowerCase().contains(query) ||
            item.categoryName.toLowerCase().contains(query);
      }).toList();
    } else {
      list = List<AuditItem>.from(auditItems);
    }

    final activeColumn = sortColumn.value.isEmpty ? 'category' : sortColumn.value;

    list.sort((a, b) {
      // 1. Primary Category Comparison respecting current category direction (increasing or decreasing)
      int catCmp = a.categoryName.toLowerCase().compareTo(b.categoryName.toLowerCase());
      if (catCmp != 0) {
        return categorySortAscending.value ? catCmp : -catCmp;
      }

      // 2. Within the same Category:
      if (activeColumn == 'category') {
        int itemCmp = a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase());
        return categorySortAscending.value ? itemCmp : -itemCmp;
      }

      int secCmp = 0;
      switch (activeColumn) {
        case 'item':
          secCmp = a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase());
          break;
        case 'slNo':
          secCmp = a.itemId.compareTo(b.itemId);
          break;
        case 'actualQty':
          final qtyA = double.tryParse(auditQtys[a.itemId] ?? '') ?? -1.0;
          final qtyB = double.tryParse(auditQtys[b.itemId] ?? '') ?? -1.0;
          secCmp = qtyA.compareTo(qtyB);
          break;
        default:
          secCmp = a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase());
      }
      return sortAscending.value ? secCmp : -secCmp;
    });
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    fetchUnits();
    fetchMeasurements();
  }

  // Active Tab: 'Daily', 'Consumable', 'Non-Consumable', 'All'
  final selectedTab = 'Daily'.obs;

  // Inline form controllers for additional items
  final inlineItemNameController = TextEditingController();
  final inlineActualQtyController = TextEditingController();
  final inlineSelectedMeasurementId = ''.obs;
  final showAdditionalForm = false.obs;

  final rxCountDaily = 0.obs;
  final rxCountConsumable = 0.obs;
  final rxCountNonConsumable = 0.obs;
  final rxCountAll = 0.obs;

  int get countDaily => rxCountDaily.value;
  int get countConsumable => rxCountConsumable.value;
  int get countNonConsumable => rxCountNonConsumable.value;
  int get countAll => rxCountAll.value;

  List<AuditItem> get filteredTabAuditItems => sortedAuditItems;

  dynamic _getAuditRankForTab(String tabName) {
    switch (tabName) {
      case 'Daily':
      case 'Audit Daily':
        return 1;
      case 'Consumable':
      case 'Audit Consumable':
        return 2;
      case 'Non-Consumable':
      case 'Audit Non-Consumable':
        return 3;
      case 'All':
      case 'Audit All':
        return 'all';
      default:
        return 1;
    }
  }

  Future<void> selectTab(String tabName) async {
    selectedTab.value = tabName;
    if (selectedUnitIds.isNotEmpty) {
      final unitId = int.parse(selectedUnitIds.first);
      final rank = _getAuditRankForTab(tabName);
      await fetchAuditUnitItems(unitId: unitId, auditRank: rank);
    }
  }

  String calculateDifferenceText(AuditItem item) {
    final qtyInput = auditQtys[item.itemId]?.trim() ?? '';
    final suffix = item.unitSuffix.isNotEmpty ? ' ${item.unitSuffix}' : '';
    if (qtyInput.isEmpty) {
      return '-$suffix';
    }
    final actualNum = double.tryParse(qtyInput);
    if (actualNum == null) {
      return '-$suffix';
    }
    final diff = actualNum - item.systemQtyNum;
    final formattedNum = diff % 1 == 0 ? diff.toInt().toString() : diff.toStringAsFixed(2);
    if (diff > 0) {
      return '+$formattedNum$suffix';
    }
    return '$formattedNum$suffix';
  }

  void addInlineAdditionalItem() {
    final name = inlineItemNameController.text.trim();
    if (name.isEmpty) {
      AppCommonToastMessage.show(message: 'Please enter item name.', type: ToastType.error);
      return;
    }
    if (inlineSelectedMeasurementId.value.isEmpty) {
      AppCommonToastMessage.show(message: 'Please select a measurement unit.', type: ToastType.error);
      return;
    }
    final qtyStr = inlineActualQtyController.text.trim();
    final qty = double.tryParse(qtyStr);
    if (qtyStr.isEmpty || qty == null) {
      AppCommonToastMessage.show(message: 'Please enter actual quantity.', type: ToastType.error);
      return;
    }

    final unitIdInt = int.tryParse(inlineSelectedMeasurementId.value) ?? 0;
    final unitOpt = measurementOptions.firstWhereOrNull((opt) => opt.value == inlineSelectedMeasurementId.value);
    final unitName = unitOpt?.label ?? '';

    addAdditionalItem(AdditionalAuditItem(
      itemName: name,
      measurementUnitId: unitIdInt,
      measurementUnitName: unitName,
      actualQty: qty,
    ));

    inlineItemNameController.clear();
    inlineActualQtyController.clear();
    inlineSelectedMeasurementId.value = '';
  }

  @override
  void onClose() {
    searchController.dispose();
    inlineItemNameController.dispose();
    inlineActualQtyController.dispose();
    for (final ctrl in qtyControllers.values) {
      ctrl.dispose();
    }
    super.onClose();
  }

  Future<void> fetchUnits() async {
    isLoadingUnits.value = true;
    try {
      final response = await _repository.getSupportUnits();
      if (response != null && response['status'] == true) {
        final List data = response['data'] ?? [];
        unitOptions.assignAll(data.map((e) => DropdownOption(
              value: (e['unitid'] ?? e['id'])?.toString() ?? '',
              label: e['unitname']?.toString() ?? '',
            )));
      }
    } catch (e) {
      debugPrint('InventoryAuditController: fetchUnits error: $e');
    } finally {
      isLoadingUnits.value = false;
    }
  }

  Future<void> fetchMeasurements() async {
    try {
      final response = await _repository.getMeasurements();
      if (response != null &&
          (response['status'] == true || response['status'] == 'success')) {
        final List data = response['data'] ?? [];
        measurementOptions.assignAll(data.map((e) => DropdownOption(
              value: (e['id'])?.toString() ?? '',
              label: (e['measurement_unit'])?.toString() ?? '',
            )));
      }
    } catch (e) {
      debugPrint('InventoryAuditController: fetchMeasurements error: $e');
    }
  }

  void addAdditionalItem(AdditionalAuditItem item) {
    additionalAuditItems.add(item);
  }

  void removeAdditionalItem(int index) {
    if (index >= 0 && index < additionalAuditItems.length) {
      additionalAuditItems.removeAt(index);
    }
  }

  Future<void> onUnitChanged(Set<String> selectedIds) async {
    selectedUnitIds.assignAll(selectedIds);
    auditItems.clear();
    additionalAuditItems.clear();
    _disposeQtyControllers();

    if (selectedIds.isEmpty) return;

    selectedTab.value = 'Daily';
    final unitId = selectedIds.first;
    await fetchAuditUnitItems(unitId: int.parse(unitId), auditRank: 1);
  }

  Future<void> fetchAuditUnitItems({
    required int unitId,
    required dynamic auditRank,
  }) async {
    isLoadingItems.value = true;
    try {
      final response = await _repository.getAuditUnitItems(
        unitId: unitId,
        auditRank: auditRank,
      );
      if (response != null && response['status'] == true) {
        final data = response['data'] ?? {};

        // Update tab counts
        if (data['counts'] != null) {
          final counts = data['counts'];
          rxCountDaily.value = int.tryParse(counts['daily']?.toString() ?? '0') ?? 0;
          rxCountConsumable.value = int.tryParse(counts['consumable']?.toString() ?? '0') ?? 0;
          rxCountNonConsumable.value = int.tryParse(counts['non_consumable']?.toString() ?? '0') ?? 0;
          rxCountAll.value = int.tryParse(counts['all']?.toString() ?? '0') ?? 0;
        }

        final List rawItems = data['items'] ?? [];
        final items = rawItems.map((e) {
          final id = int.tryParse(e['item_id']?.toString() ?? '0') ?? 0;
          final name = e['item_name']?.toString() ?? '-';
          final category = e['category_name']?.toString() ?? '-';
          final mUnit = e['measurement_unit']?.toString() ?? '';
          final sysQtyNum = double.tryParse(e['system_qty']?.toString() ?? '0') ?? 0.0;

          final formattedSysNum = sysQtyNum % 1 == 0 ? sysQtyNum.toInt().toString() : sysQtyNum.toStringAsFixed(2);
          final sysStr = mUnit.isNotEmpty ? "$formattedSysNum $mUnit" : formattedSysNum;

          final actualQtyVal = e['actual_qty']?.toString();

          return AuditItem(
            itemId: id,
            itemName: name,
            categoryName: category,
            systemQtyStr: sysStr,
            systemQtyNum: sysQtyNum,
            unitSuffix: mUnit,
            auditQty: actualQtyVal,
          );
        }).toList();

        auditItems.assignAll(items);

        for (final item in items) {
          if (!qtyControllers.containsKey(item.itemId)) {
            final ctrl = TextEditingController();
            if (item.auditQty != null && item.auditQty!.isNotEmpty) {
              ctrl.text = item.auditQty!;
              auditQtys[item.itemId] = item.auditQty!;
            }
            qtyControllers[item.itemId] = ctrl;
          }
        }
      }
    } catch (e) {
      debugPrint('InventoryAuditController: fetchAuditUnitItems error: $e');
    } finally {
      isLoadingItems.value = false;
    }
  }

  void addAdditionalItemRow() {
    final newItem = EditableAdditionalItem(
      id: DateTime.now().millisecondsSinceEpoch,
    );
    editableAdditionalItems.insert(0, newItem);
  }

  void removeAdditionalItemRow(int id) {
    final index = editableAdditionalItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      editableAdditionalItems[index].dispose();
      editableAdditionalItems.removeAt(index);
    }
  }

  void _clearAdditionalItemRows() {
    for (final item in editableAdditionalItems) {
      item.dispose();
    }
    editableAdditionalItems.clear();
  }

  bool get isSubmitEnabled {
    if (selectedUnitIds.isEmpty) return false;
    if (isSubmitting.value) return false;
    if (auditItems.isEmpty && editableAdditionalItems.isEmpty) return false;

    for (final item in auditItems) {
      final val = auditQtys[item.itemId]?.trim();
      if (val == null || val.isEmpty) {
        return false;
      }
    }

    for (final item in editableAdditionalItems) {
      if (item.nameController.text.trim().isEmpty) return false;
      if (item.qtyController.text.trim().isEmpty) return false;
      if (item.selectedUnitId.value.isEmpty) return false;
    }

    return true;
  }

  void _disposeQtyControllers() {
    for (final ctrl in qtyControllers.values) {
      ctrl.dispose();
    }
    qtyControllers.clear();
    auditQtys.clear();
    _clearAdditionalItemRows();
  }

  /// Called when quantity changes in textfield
  void setQty(int itemId, String qty) {
    if (qty.trim().isEmpty) {
      auditQtys.remove(itemId);
    } else {
      auditQtys[itemId] = qty.trim();
    }
    // Keep the TextEditingController in sync so submitAudit can read it
    qtyControllers[itemId]?.text = qty;
  }

  Future<void> submitAudit() async {
    if (selectedUnitIds.isEmpty) {
      AppCommonToastMessage.show(
          message: 'Please select a unit.', type: ToastType.error);
      return;
    }

    final items = <Map<String, dynamic>>[];
    for (final item in auditItems) {
      final qty = qtyControllers[item.itemId]?.text.trim() ?? '';
      if (qty.isEmpty) continue;
      final parsedQty = double.tryParse(qty);
      if (parsedQty == null) {
        AppCommonToastMessage.show(
            message: 'Invalid quantity for "${item.itemName}".',
            type: ToastType.error);
        return;
      }
      items.add({
        'item_id': item.itemId,
        'system_qty': item.systemQtyNum,
        'actual_qty': parsedQty,
      });
    }

    final additionalItems = <Map<String, dynamic>>[];
    for (final item in editableAdditionalItems) {
      final name = item.nameController.text.trim();
      final qtyStr = item.qtyController.text.trim();
      final unitIdStr = item.selectedUnitId.value;
      if (name.isNotEmpty && qtyStr.isNotEmpty && unitIdStr.isNotEmpty) {
        final unitIdInt = int.tryParse(unitIdStr) ?? 0;
        final actualQty = double.tryParse(qtyStr) ?? 0.0;
        additionalItems.add({
          'item_name': name,
          'measurement_unit_id': unitIdInt,
          'actual_qty': actualQty,
        });
      }
    }
    for (final add in additionalAuditItems) {
      additionalItems.add(add.toJson());
    }

    if (items.isEmpty && additionalItems.isEmpty) {
      AppCommonToastMessage.show(
          message: 'Please enter at least one item quantity or add an additional item.',
          type: ToastType.error);
      return;
    }

    final user = Get.find<StorageService>().getUser();
    final auditedBy = user?.id ?? 0;
    final auditDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    isSubmitting.value = true;
    try {
      final response = await _repository.submitInventoryAudit(
        unitId: int.parse(selectedUnitIds.first),
        auditedBy: auditedBy,
        auditDate: auditDate,
        items: items,
        additionalItems: additionalItems.isNotEmpty ? additionalItems : null,
      );
      if (response != null &&
          (response['status'] == true || response['status'] == 'success')) {
        AppCommonToastMessage.show(
            message: response['message'] ?? 'Inventory audit saved successfully.',
            type: ToastType.success);
        // Reset
        selectedUnitIds.clear();
        auditItems.clear();
        auditQtys.clear();
        additionalAuditItems.clear();
        _disposeQtyControllers();
      } else {
        AppCommonToastMessage.show(
            message: response?['message'] ?? 'Failed to submit audit.',
            type: ToastType.error);
      }
    } catch (e) {
      debugPrint('InventoryAuditController: submitAudit error: $e');
      AppCommonToastMessage.show(
          message: 'An error occurred while submitting.', type: ToastType.error);
    } finally {
      isSubmitting.value = false;
    }
  }
}

