import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
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

class AuditUnitCardItem {
  final String id;
  final String name;
  final String shortForm;
  final String location;
  final String image;
  final String timing;

  AuditUnitCardItem({
    required this.id,
    required this.name,
    this.shortForm = '',
    required this.location,
    required this.image,
    required this.timing,
  });
}

class AdditionalAuditItem {
  final String itemName;
  final int measurementUnitId;
  final String measurementUnitName;
  final double actualQty;
  final List<File> images;

  AdditionalAuditItem({
    required this.itemName,
    required this.measurementUnitId,
    required this.measurementUnitName,
    required this.actualQty,
    this.images = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'item_name': itemName,
      'measurement_unit_id': measurementUnitId,
      'actual_qty': actualQty,
      if (images.isNotEmpty) ...{
        'image_path': images.first.path,
        'image_paths': images.map((f) => f.path).toList(),
      },
    };
  }
}

class EditableAdditionalItem {
  final int id;
  final TextEditingController nameController;
  final TextEditingController qtyController;
  final RxString selectedUnitId;
  final RxString selectedUnitName;
  final Rx<File?> selectedImage = Rx<File?>(null);

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

  // Reactive image map — keyed by itemId
  final itemImages = <int, List<File>>{}.obs;

  Future<void> pickImageForAuditItem(int itemId, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final currentList = List<File>.from(itemImages[itemId] ?? []);
      if (source == ImageSource.gallery) {
        final List<XFile> pickedFiles = await picker.pickMultiImage(imageQuality: 50);
        if (pickedFiles.isNotEmpty) {
          for (final f in pickedFiles) {
            currentList.add(File(f.path));
          }
          itemImages[itemId] = currentList;
        }
      } else {
        final XFile? image = await picker.pickImage(
          source: source,
          imageQuality: 50,
        );
        if (image != null) {
          currentList.add(File(image.path));
          itemImages[itemId] = currentList;
        }
      }
    } catch (e) {
      debugPrint('InventoryAuditController: pickImageForAuditItem error: $e');
      AppCommonToastMessage.show(
        message: 'Failed to pick image.',
        type: ToastType.error,
      );
    }
  }

  void removeImageForAuditItemAt(int itemId, int index) {
    if (itemImages.containsKey(itemId)) {
      final list = List<File>.from(itemImages[itemId]!);
      if (index >= 0 && index < list.length) {
        list.removeAt(index);
        if (list.isEmpty) {
          itemImages.remove(itemId);
        } else {
          itemImages[itemId] = list;
        }
      }
    }
  }

  void removeImageForAuditItem(int itemId) {
    itemImages.remove(itemId);
  }

  Future<void> pickImageForAdditionalItem(
    EditableAdditionalItem item,
    ImageSource source,
  ) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 50,
      );
      if (image != null) {
        item.selectedImage.value = File(image.path);
        editableAdditionalItems.refresh();
      }
    } catch (e) {
      debugPrint('InventoryAuditController: pickImageForAdditionalItem error: $e');
      AppCommonToastMessage.show(
        message: 'Failed to pick image.',
        type: ToastType.error,
      );
    }
  }

  void removeImageForAdditionalItem(EditableAdditionalItem item) {
    item.selectedImage.value = null;
    editableAdditionalItems.refresh();
  }

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

  final unitCardItems = <AuditUnitCardItem>[].obs;
  final unitSearchQuery = ''.obs;

  List<AuditUnitCardItem> get filteredUnitCards {
    final query = unitSearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return unitCardItems;
    return unitCardItems.where((u) {
      return u.name.toLowerCase().contains(query) ||
          u.shortForm.toLowerCase().contains(query) ||
          u.location.toLowerCase().contains(query) ||
          u.id.toLowerCase().contains(query);
    }).toList();
  }

  Map<String, List<AuditUnitCardItem>> get groupedUnitCards {
    final Map<String, List<AuditUnitCardItem>> grouped = {};
    for (final unit in filteredUnitCards) {
      final locationKey = unit.location.isNotEmpty ? unit.location : 'Other';
      grouped.putIfAbsent(locationKey, () => []).add(unit);
    }
    return grouped;
  }

  void clearSelectedUnit() {
    selectedUnitIds.clear();
    auditItems.clear();
    additionalAuditItems.clear();
    _disposeQtyControllers();
  }

  Future<void> fetchUnits() async {
    isLoadingUnits.value = true;
    try {
      final response = await _repository.getSupportUnits();
      if (response != null && response['status'] == true) {
        final List data = response['data'] ?? [];
        unitOptions.assignAll(data.map((e) {
          final name = (e['unitname'] ?? e['unit_name'] ?? e['Unit_Name'])?.toString() ?? '';
          final shortForm = (e['unit_shortform'] ?? e['unit_short_form'])?.toString();
          final label = (shortForm != null && shortForm.isNotEmpty) ? shortForm : name;
          return DropdownOption(
            value: (e['unitid'] ?? e['id'] ?? e['Unit_Id'])?.toString() ?? '',
            label: label,
          );
        }));
        unitCardItems.assignAll(data.map((e) {
          final id = (e['unitid'] ?? e['id'] ?? e['Unit_Id'])?.toString() ?? '';
          final name = (e['unitname'] ?? e['unit_name'] ?? e['Unit_Name'])?.toString() ?? id;
          final shortForm = (e['unit_shortform'] ?? e['unit_short_form'] ?? e['unitshortform'])?.toString() ?? '';
          final location = (e['district_name'] ?? e['unit_location'] ?? e['location'] ?? e['Unit_location'])?.toString() ?? '';
          var img = (e['unit_image'] ?? e['image'] ?? e['Unit_Image'])?.toString() ?? '';
          if (img.isNotEmpty && !img.startsWith('http')) {
            img = 'https://$img';
          }
          final timing = (e['timing'] ?? e['time'])?.toString() ?? '';
          return AuditUnitCardItem(
            id: id,
            name: name,
            shortForm: shortForm,
            location: location,
            image: img,
            timing: timing,
          );
        }));
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
        measurementOptions.assignAll(data.map((e) {
          final idVal = (e['id'] ?? e['mes_id'] ?? e['measurement_unit_id'])?.toString() ?? '';
          final nameVal = (e['measurement_unit'] ?? e['mesNm'] ?? e['measurement_name'] ?? e['unit_name'] ?? e['name'])?.toString() ?? idVal;
          return DropdownOption(
            value: idVal,
            label: nameVal,
          );
        }).toList());
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
      final parsedQty = double.tryParse(val) ?? 0.0;
      if (parsedQty > 0) {
        final images = itemImages[item.itemId];
        if (images == null || images.isEmpty) {
          return false;
        }
      }
    }

    for (final item in editableAdditionalItems) {
      if (item.nameController.text.trim().isEmpty) return false;
      final qtyStr = item.qtyController.text.trim();
      if (qtyStr.isEmpty) return false;
      if (item.selectedUnitId.value.isEmpty) return false;
      final parsedQty = double.tryParse(qtyStr) ?? 0.0;
      if (parsedQty > 0 && item.selectedImage.value == null) {
        return false;
      }
    }

    return true;
  }

  void _disposeQtyControllers() {
    for (final ctrl in qtyControllers.values) {
      ctrl.dispose();
    }
    qtyControllers.clear();
    auditQtys.clear();
    itemImages.clear();
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

    final itemsList = <Map<String, dynamic>>[];
    final itemFilesMap = <int, List<File>>{};

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

      if (parsedQty > 0) {
        final images = itemImages[item.itemId];
        if (images == null || images.isEmpty) {
          AppCommonToastMessage.show(
              message: 'Please add at least one photo for "${item.itemName}" as quantity is greater than 0.',
              type: ToastType.error);
          return;
        }
      }

      final itemIndex = itemsList.length;
      itemsList.add({
        'item_id': item.itemId,
        'system_qty': item.systemQtyNum,
        'actual_qty': parsedQty,
      });

      if (itemImages.containsKey(item.itemId) &&
          itemImages[item.itemId]!.isNotEmpty) {
        itemFilesMap[itemIndex] = itemImages[item.itemId]!;
      }
    }

    final additionalItemsList = <Map<String, dynamic>>[];
    final additionalItemFilesMap = <int, List<File>>{};

    for (final item in editableAdditionalItems) {
      final name = item.nameController.text.trim();
      final qtyStr = item.qtyController.text.trim();
      final unitIdStr = item.selectedUnitId.value;
      if (name.isNotEmpty && qtyStr.isNotEmpty && unitIdStr.isNotEmpty) {
        final unitIdInt = int.tryParse(unitIdStr) ?? 0;
        final actualQty = double.tryParse(qtyStr) ?? 0.0;

        if (actualQty > 0 && item.selectedImage.value == null) {
          AppCommonToastMessage.show(
              message: 'Please add at least one photo for "$name" as quantity is greater than 0.',
              type: ToastType.error);
          return;
        }

        final addIndex = additionalItemsList.length;
        additionalItemsList.add({
          'item_name': name,
          'measurement_unit_id': unitIdInt,
          'actual_qty': actualQty,
        });
        if (item.selectedImage.value != null) {
          additionalItemFilesMap[addIndex] = [item.selectedImage.value!];
        }
      }
    }

    for (final add in additionalAuditItems) {
      if (add.actualQty > 0 && add.images.isEmpty) {
        AppCommonToastMessage.show(
            message: 'Please add at least one photo for "${add.itemName}" as quantity is greater than 0.',
            type: ToastType.error);
        return;
      }

      final addIndex = additionalItemsList.length;
      additionalItemsList.add({
        'item_name': add.itemName,
        'measurement_unit_id': add.measurementUnitId,
        'actual_qty': add.actualQty,
      });
      if (add.images.isNotEmpty) {
        additionalItemFilesMap[addIndex] = add.images;
      }
    }

    if (itemsList.isEmpty && additionalItemsList.isEmpty) {
      AppCommonToastMessage.show(
          message:
              'Please enter at least one item quantity or add an additional item.',
          type: ToastType.error);
      return;
    }

    final user = Get.find<StorageService>().getUser();
    final auditedBy = user?.id ?? 0;
    final auditDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    isSubmitting.value = true;
    try {
      final formData = dio.FormData();
      formData.fields
          .add(MapEntry('unit_id', selectedUnitIds.first.toString()));
      formData.fields.add(MapEntry('audited_by', auditedBy.toString()));
      formData.fields.add(MapEntry('audit_date', auditDate));
      formData.fields.add(MapEntry('items', jsonEncode(itemsList)));

      if (additionalItemsList.isNotEmpty) {
        formData.fields.add(
            MapEntry('additional_items', jsonEncode(additionalItemsList)));
      }

      for (final entry in itemFilesMap.entries) {
        final itemIndex = entry.key;
        final files = entry.value;
        for (final file in files) {
          final fileName = file.path.split('/').last;
          formData.files.add(
            MapEntry(
              'item_images[$itemIndex][]',
              await dio.MultipartFile.fromFile(file.path, filename: fileName),
            ),
          );
        }
      }

      for (final entry in additionalItemFilesMap.entries) {
        final addIndex = entry.key;
        final files = entry.value;
        for (final file in files) {
          final fileName = file.path.split('/').last;
          formData.files.add(
            MapEntry(
              'additional_item_images[$addIndex][]',
              await dio.MultipartFile.fromFile(file.path, filename: fileName),
            ),
          );
        }
      }

      final response = await _repository.submitInventoryAudit(formData);

      if (response != null &&
          (response['status'] == true || response['status'] == 'success')) {
        AppCommonToastMessage.show(
            message:
                response['message'] ?? 'Inventory audit saved successfully.',
            type: ToastType.success);
        // Reset
        selectedUnitIds.clear();
        auditItems.clear();
        auditQtys.clear();
        itemImages.clear();
        additionalAuditItems.clear();
        _clearAdditionalItemRows();
        _disposeQtyControllers();
      } else {
        AppCommonToastMessage.show(
            message: response?['message'] ?? 'Failed to submit audit.',
            type: ToastType.error);
      }
    } catch (e) {
      debugPrint('InventoryAuditController: submitAudit error: $e');
      AppCommonToastMessage.show(
          message: 'An error occurred while submitting.',
          type: ToastType.error);
    } finally {
      isSubmitting.value = false;
    }
  }
}

