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

class InventoryAuditController extends GetxController {
  final InventoryRepository _repository = Get.find<InventoryRepository>();

  // Unit dropdown options (reused from unit inventory)
  final unitOptions = <DropdownOption>[].obs;

  // Selected units (multiselect, but audit operates one unit at a time)
  final selectedUnitIds = <String>[].obs;

  // Items for selected unit
  final auditItems = <AuditItem>[].obs;

  final isLoadingUnits = false.obs;
  final isLoadingItems = false.obs;
  final isSubmitting = false.obs;

  // Per-item qty controllers keyed by itemId
  final Map<int, TextEditingController> qtyControllers = {};

  // Reactive quantity map — used by Obx in the table widget
  final auditQtys = <int, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUnits();
  }

  @override
  void onClose() {
    for (final ctrl in qtyControllers.values) {
      ctrl.dispose();
    }
    super.onClose();
  }

  static String _mapMeasurementUnit(dynamic id) {
    switch (id?.toString()) {
      case '1': return 'Litre';
      case '2': return 'Packet';
      case '3': return 'pcs';
      case '4': return 'Box';
      case '6': return 'Pair';
      case '7': return 'Kg';
      default: return '';
    }
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

  Future<void> onUnitChanged(Set<String> selectedIds) async {
    selectedUnitIds.assignAll(selectedIds);
    auditItems.clear();
    _disposeQtyControllers();

    if (selectedIds.isEmpty) return;

    // Use the first selected unit to load items
    final unitId = selectedIds.first;
    await _fetchItemsForUnit(unitId);
  }

  Future<void> _fetchItemsForUnit(String unitId) async {
    isLoadingItems.value = true;
    try {
      final response = await _repository.getUnitInventoryStock(
        itemId: [],
        unitId: [int.parse(unitId)],
        categoryId: [],
        stateId: '',
        districtId: '',
      );
      if (response != null && response['status'] == true) {
        final List data = response['data'] ?? [];
        final items = data.map((e) {
          final id = int.tryParse(e['item_id']?.toString() ?? '0') ?? 0;
          final category = (e['invcatgeoryname'] ??
                  e['category_name'] ??
                  e['category'] ??
                  e['cat_name'] ??
                  '-')
              .toString();

          // Show EXACTLY what backend sends in response for allotment_qty / quantity
          final rawAllotmentQty = (e['allotment_qty'] ??
                  e['quantity'] ??
                  e['current_quantity'] ??
                  e['system_qty'] ??
                  '0')
              .toString()
              .trim();

          final sysNum = double.tryParse(
                  rawAllotmentQty.replaceAll(RegExp(r'[^0-9.-]'), '')) ??
              0.0;

          final fallbackUnit = e['m_unit']?.toString() ??
              e['measurement_unit_name']?.toString() ??
              e['measurement_unit']?.toString() ??
              _mapMeasurementUnit(e['measurement_unit_id']);

          final extractedSuffix =
              rawAllotmentQty.replaceAll(RegExp(r'^[0-9.\s]+'), '').trim();
          final unitSuffix =
              extractedSuffix.isNotEmpty ? extractedSuffix : fallbackUnit;

          return AuditItem(
            itemId: id,
            itemName: e['item_name']?.toString() ?? '-',
            categoryName: category,
            systemQtyStr: rawAllotmentQty,
            systemQtyNum: sysNum,
            unitSuffix: unitSuffix,
          );
        }).toList();
        auditItems.assignAll(items);
        // Create qty controllers
        for (final item in items) {
          qtyControllers[item.itemId] = TextEditingController();
        }
      }
    } catch (e) {
      debugPrint('InventoryAuditController: fetchItems error: $e');
    } finally {
      isLoadingItems.value = false;
    }
  }

  void _disposeQtyControllers() {
    for (final ctrl in qtyControllers.values) {
      ctrl.dispose();
    }
    qtyControllers.clear();
    auditQtys.clear();
  }

  /// Called when quantity changes in textfield
  void setQty(int itemId, String qty) {
    auditQtys[itemId] = qty;
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

    if (items.isEmpty) {
      AppCommonToastMessage.show(
          message: 'Please enter at least one item quantity.',
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

