import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import 'package:core/utils/app_export_utils.dart';
import 'package:services/api_services.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';
import 'package:mfresh_ops/data/models/inventory/consumption_item_model.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'dart:developer' as developer;

class ConsumptionController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final InventoryRepository _inventoryRepository =
      Get.find<InventoryRepository>();

  final isSearching = false.obs;
  final searchController = TextEditingController();
  final isExporting = false.obs;
  final isExportingPdf = false.obs;
  final isLoading = false.obs;

  // Pagination states
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalEntries = 0.obs;
  final perPage = 20.obs;

  // Sorting states
  final RxString sortColumn = ''.obs;
  final RxBool sortAscending = true.obs;

  // Date filters
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();

  // Multi-select filter states
  final selectedUnits = <String>[].obs;
  final selectedItems = <String>[].obs;
  final selectedStores = <String>[].obs;

  // Filter options
  final unitOptions = <DropdownOption<String>>[].obs;
  final itemOptions = <DropdownOption<String>>[].obs;
  final storeOptions = <DropdownOption<String>>[].obs;

  final consumptionItems = <ConsumptionItemModel>[].obs;

  List<ConsumptionItemModel> get sortedItems {
    if (sortColumn.value.isEmpty) return consumptionItems;

    final items = List<ConsumptionItemModel>.from(consumptionItems);
    items.sort((a, b) {
      int compare(String v1, String v2) {
        final double? d1 = double.tryParse(v1);
        final double? d2 = double.tryParse(v2);
        if (d1 != null && d2 != null) return d1.compareTo(d2);
        return v1.compareTo(v2);
      }

      int result = 0;
      switch (sortColumn.value) {
        case 'Consumed On': result = compare(a.consumedOn, b.consumedOn); break;
        case 'State': result = compare(a.state, b.state); break;
        case 'District': result = compare(a.district, b.district); break;
        case 'Source Type': result = compare(a.sourceType, b.sourceType); break;
        case 'Source': result = compare(a.source, b.source); break;
        case 'Category': result = compare(a.category, b.category); break;
        case 'Item': result = compare(a.item, b.item); break;
        case 'Consumed Qty': result = compare(a.consumedQty, b.consumedQty); break;
        case 'M_Unit': result = compare(a.mUnit, b.mUnit); break;
        case 'Created By': result = compare(a.createdBy, b.createdBy); break;
      }
      return sortAscending.value ? result : -result;
    });
    return items;
  }

  void sortBy(String column) {
    if (sortColumn.value == column) {
      if (sortAscending.value) {
        sortAscending.value = false;
      } else {
        sortColumn.value = '';
        sortAscending.value = true;
      }
    } else {
      sortColumn.value = column;
      sortAscending.value = true;
    }
  }

  void resetFilters() {
    fromDateController.clear();
    toDateController.clear();
    selectedUnits.clear();
    selectedItems.clear();
    selectedStores.clear();
    searchController.clear();
    isSearching.value = false;
    sortColumn.value = '';
    applyFilters();
  }

  @override
  void onInit() {
    super.onInit();
    fetchFilterOptions();
    fetchConsumptionReport();
  }

  Future<void> onRefresh() async {
    isLoading.value = true;

    // Reset filters
    fromDateController.clear();
    toDateController.clear();
    selectedUnits.clear();
    selectedItems.clear();
    selectedStores.clear();
    searchController.clear();
    currentPage.value = 1;
    perPage.value = 50;

    await fetchConsumptionReport();
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
    currentPage.value = 1;
    fetchConsumptionReport();
  }

  // Formatting date dd-MMM-yyyy -> yyyy-MM-dd
  String _formatDateForApi(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return '';
      final day = parts[0];
      final monthStr = parts[1].toLowerCase();
      final year = parts[2];
      const months = [
        'jan',
        'feb',
        'mar',
        'apr',
        'may',
        'jun',
        'jul',
        'aug',
        'sep',
        'oct',
        'nov',
        'dec',
      ];
      final monthIndex = months.indexOf(monthStr) + 1;
      if (monthIndex == 0) return '';
      final month = monthIndex.toString().padLeft(2, '0');
      return '$year-$month-$day';
    } catch (e) {
      return '';
    }
  }

  Future<void> fetchFilterOptions() async {
    try {
      // 1. Fetch support units
      final unitRes = await _inventoryRepository.getSupportUnits();
      if (unitRes != null && unitRes['status'] == true) {
        final List data = unitRes['data'] ?? [];
        unitOptions.assignAll(
          data
              .map(
                (e) => DropdownOption<String>(
                  value: (e['unitid'] ?? e['id'])?.toString() ?? '',
                  label: e['unitname']?.toString() ?? '',
                ),
              )
              .toList(),
        );
      }

      // 2. Fetch items
      final itemRes = await _inventoryRepository.getAllItems();
      if (itemRes != null &&
          (itemRes['status'] == 'success' || itemRes['status'] == true)) {
        final List data = itemRes['data'] ?? [];
        itemOptions.assignAll(
          data
              .map(
                (e) => DropdownOption<String>(
                  value: e['id']?.toString() ?? '',
                  label: e['item_name']?.toString() ?? '',
                ),
              )
              .toList(),
        );
      }

      // 3. Fetch stores dynamically
      final statesRes = await _inventoryRepository.getStates();
      if (statesRes != null && statesRes['status'] == 'success') {
        final List states = statesRes['data'] ?? [];
        final List<DropdownOption<String>> allStores = [];
        for (var state in states) {
          final stateId = state['id'].toString();
          final distRes = await _inventoryRepository.getDistricts(stateId);
          if (distRes != null && distRes['status'] == 'success') {
            final List districts = distRes['data'] ?? [];
            for (var dist in districts) {
              final distId = dist['district_id'].toString();
              final storeRes = await _inventoryRepository.getStores(
                stateId,
                distId,
              );
              if (storeRes != null && storeRes['status'] == 'success') {
                final List stores = storeRes['data'] ?? [];
                for (var store in stores) {
                  final storeName = store['storeroom_name']?.toString() ?? '';
                  final storeId = store['storeid']?.toString() ?? '';
                  if (storeName.isNotEmpty && storeId.isNotEmpty &&
                      !allStores.any((element) => element.value == storeId)) {
                    allStores.add(
                      DropdownOption<String>(
                        value: storeId,
                        label: storeName,
                      ),
                    );
                  }
                }
              }
            }
          }
        }
        if (allStores.isNotEmpty) {
          storeOptions.assignAll(allStores);
        }
      }
    } catch (e) {
      debugPrint('Error fetching filter options: $e');
    }
  }

  Future<void> fetchConsumptionReport() async {
    isLoading.value = true;
    try {
      final fromDate = _formatDateForApi(fromDateController.text);
      final toDate = _formatDateForApi(toDateController.text);
      final data = {
        if (fromDate.isNotEmpty) "from_date": fromDate,
        if (toDate.isNotEmpty) "to_date": toDate,
        "units": selectedUnits,
        "items": selectedItems,
        "stores": selectedStores,
        "include_reversed": true,
        "per_page": perPage.value,
      };

      final response = await _apiService.post(
        AppConstants.consumptionReport,
        query: {'page': currentPage.value},
        data: data,
      );

      if (response != null && response['status'] == true) {
        final Map<String, dynamic> reportData = response['data'] ?? {};
        final List rawItems = reportData['data'] ?? [];

        // Parse items
        final itemsList = rawItems
            .map((json) => ConsumptionItemModel.fromJson(json))
            .toList();

        // Local search filter if search is active (since search field filters locally)
        final query = searchController.text.toLowerCase();
        if (query.isNotEmpty) {
          consumptionItems.assignAll(
            itemsList
                .where(
                  (item) =>
                      item.item.toLowerCase().contains(query) ||
                      item.source.toLowerCase().contains(query) ||
                      item.category.toLowerCase().contains(query),
                )
                .toList(),
          );
        } else {
          consumptionItems.assignAll(itemsList);
        }

        // Update pagination details
        currentPage.value = reportData['current_page'] is int
            ? reportData['current_page']
            : int.tryParse(reportData['current_page']?.toString() ?? '1') ?? 1;
        final lastPage = reportData['last_page'] is int
            ? reportData['last_page']
            : int.tryParse(reportData['last_page']?.toString() ?? '1') ?? 1;
        totalPages.value = lastPage;
        final total = reportData['total'] is int
            ? reportData['total']
            : int.tryParse(reportData['total']?.toString() ?? '0') ?? 0;
        totalEntries.value = total;
      } else {
        consumptionItems.clear();
        totalPages.value = 1;
        totalEntries.value = 0;
      }
    } catch (e) {
      debugPrint('Error fetching consumption report: $e');
      consumptionItems.clear();
      totalPages.value = 1;
      totalEntries.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reverseConsumption(ConsumptionItemModel item) async {
    debugPrint('Reverse consumption triggered for item ID: ${item.id}');
    developer.log('Reverse consumption triggered for item ID: ${item.id}');
    isLoading.value = true;
    try {
      debugPrint('Sending POST request to ${AppConstants.consumptionReverse} with body: {"consume_id": ${item.id}}');
      developer.log('Sending POST request to ${AppConstants.consumptionReverse} with body: {"consume_id": ${item.id}}');
      final response = await _apiService.post(
        AppConstants.consumptionReverse,
        data: {'consume_id': item.id},
      );
      debugPrint('Response received from consumption/reverse: $response');
      developer.log('Response received from consumption/reverse: $response');

      if (response != null && response['status'] == true) {
        AppCommonToastMessage.show(
          message: response['message']?.toString() ?? "Consumption reversed successfully!",
          type: ToastType.success,
        );
        debugPrint('Reversal succeeded, refreshing consumption report...');
        developer.log('Reversal succeeded, refreshing consumption report...');
        await fetchConsumptionReport();
      } else {
        debugPrint('Reversal API responded with failure: ${response?['message']}');
        developer.log('Reversal API responded with failure: ${response?['message']}');
        AppCommonToastMessage.show(
          message: response?['message']?.toString() ?? "Failed to reverse consumption",
          type: ToastType.error,
        );
      }
    } catch (e, stack) {
      debugPrint('Error reversing consumption: $e');
      debugPrint('Stack trace: $stack');
      developer.log('Error reversing consumption: $e', error: e, stackTrace: stack);
      AppCommonToastMessage.show(
        message: "An error occurred: $e",
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      fetchConsumptionReport();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchConsumptionReport();
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      fetchConsumptionReport();
    }
  }

  Future<void> exportToExcel() async {
    isExporting.value = true;
    await AppExportUtils.exportToExcel(
      title: 'Consumption Report',
      columns: const [
        "Consumed On",
        "State",
        "District",
        "Source Type",
        "Source",
        "Category",
        "Item",
        "Consumed Qty",
        "M_Unit",
        "Created By",
      ],
      rows: consumptionItems
          .map(
            (item) => [
              item.consumedOn,
              item.state,
              item.district,
              item.sourceType,
              item.source,
              item.category,
              item.item,
              item.consumedQty,
              item.mUnit,
              item.createdBy,
            ],
          )
          .toList(),
    );
    isExporting.value = false;
  }

  Future<void> exportToPdf() async {
    isExportingPdf.value = true;
    await AppExportUtils.exportToPdf(
      title: 'Consumption Report',
      columns: const [
        "Consumed On",
        "State",
        "District",
        "Source Type",
        "Source",
        "Category",
        "Item",
        "Consumed Qty",
        "M_Unit",
        "Created By",
      ],
      rows: consumptionItems
          .map(
            (item) => [
              item.consumedOn,
              item.state,
              item.district,
              item.sourceType,
              item.source,
              item.category,
              item.item,
              item.consumedQty,
              item.mUnit,
              item.createdBy,
            ],
          )
          .toList(),
    );
    isExportingPdf.value = false;
  }

  Future<void> selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      fromDateController.text =
          "${picked.start.day.toString().padLeft(2, '0')}-${_getMonthName(picked.start.month)}-${picked.start.year}";
      toDateController.text =
          "${picked.end.day.toString().padLeft(2, '0')}-${_getMonthName(picked.end.month)}-${picked.end.year}";
      applyFilters();
    }
  }

  String _getMonthName(int month) {
    const months = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec',
    ];
    return months[month - 1];
  }

  @override
  void onClose() {
    searchController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    super.onClose();
  }
}
