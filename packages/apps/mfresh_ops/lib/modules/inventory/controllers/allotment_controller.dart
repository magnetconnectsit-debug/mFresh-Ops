import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/utils/app_export_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/widgets/month_range_picker.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';
import 'package:mfresh_ops/data/models/inventory/allotment_item_model.dart';

class AllotmentController extends GetxController {
  final InventoryRepository _inventoryRepository = Get.find<InventoryRepository>();
  
  final isSearching = false.obs;
  final searchController = TextEditingController();
  final isExporting = false.obs;
  final isExportingPdf = false.obs;
  final isLoading = false.obs;
  final isReversing = false.obs;

  // Pagination states
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalEntries = 0.obs;
  final perPage = 10.obs;

  // Sorting states
  final RxString sortColumn = ''.obs;
  final RxBool sortAscending = true.obs;

  // Date filters (Year-Month format YYYY-MM)
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();

  final allAllotmentItems = <AllotmentItemModel>[];
  final allotmentItems = <AllotmentItemModel>[].obs;

  List<AllotmentItemModel> get sortedItems {
    if (sortColumn.value.isEmpty) return allotmentItems;

    final items = List<AllotmentItemModel>.from(allotmentItems);
    items.sort((a, b) {
      int compare(String v1, String v2) {
        final double? d1 = double.tryParse(v1);
        final double? d2 = double.tryParse(v2);
        if (d1 != null && d2 != null) return d1.compareTo(d2);
        return v1.compareTo(v2);
      }

      int result = 0;
      switch (sortColumn.value) {
        case 'Date Of Allotment': result = compare(a.dateOfAllotment, b.dateOfAllotment); break;
        case 'Item Name': result = compare(a.itemName, b.itemName); break;
        case 'Source': result = compare(a.source, b.source); break;
        case 'Destination': result = compare(a.destination, b.destination); break;
        case 'Quantity': result = compare(a.quantity, b.quantity); break;
        case 'M_Unit': result = compare(a.unit, b.unit); break;
        case 'Allotment By': result = compare(a.allotmentBy, b.allotmentBy); break;
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
    searchController.clear();
    isSearching.value = false;
    sortColumn.value = '';
    applyFilters();
  }

  @override
  void onInit() {
    super.onInit();
    
    // Default: no date filters selected by default
    fromDateController.clear();
    toDateController.clear();

    fetchAllotments();
  }

  Future<void> fetchAllotments() async {
    isLoading.value = true;
    try {
      final fromMonth = fromDateController.text.trim();
      final toMonth = toDateController.text.trim();

      final response = await _inventoryRepository.getAllotmentReport(
        fromMonth: fromMonth,
        toMonth: toMonth,
        page: currentPage.value,
        perPage: perPage.value,
      );

      if (response != null && response['status'] == true) {
        final Map<String, dynamic> responseData = response['data'] is Map 
            ? Map<String, dynamic>.from(response['data']) 
            : {};
        final List dataList = responseData['data'] ?? [];
        final parsedItems = dataList.map((e) => AllotmentItemModel.fromJson(e)).toList();
        
        allAllotmentItems.clear();
        allAllotmentItems.addAll(parsedItems);

        currentPage.value = responseData['current_page'] is int
            ? responseData['current_page']
            : int.tryParse(responseData['current_page']?.toString() ?? '1') ?? 1;
        totalPages.value = responseData['last_page'] is int
            ? responseData['last_page']
            : int.tryParse(responseData['last_page']?.toString() ?? '1') ?? 1;
        totalEntries.value = responseData['total'] is int
            ? responseData['total']
            : int.tryParse(responseData['total']?.toString() ?? '0') ?? 0;

        applyLocalFilters();
      } else {
        allAllotmentItems.clear();
        allotmentItems.clear();
        totalPages.value = 1;
        totalEntries.value = 0;
      }
    } catch (e) {
      debugPrint('Error fetching allotment report: $e');
      allAllotmentItems.clear();
      allotmentItems.clear();
      totalPages.value = 1;
      totalEntries.value = 0;
      AppCommonToastMessage.show(
        message: "Failed to load allotments: $e",
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    // Reset filters on pull to refresh
    fromDateController.clear();
    toDateController.clear();
    searchController.clear();
    isSearching.value = false;
    currentPage.value = 1;
    
    await fetchAllotments();
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
    fetchAllotments();
  }

  void applyLocalFilters() {
    final query = searchController.text.toLowerCase();

    allotmentItems.assignAll(
      allAllotmentItems.where((item) {
        final matchesSearch =
            query.isEmpty ||
            item.itemName.toLowerCase().contains(query) ||
            item.source.toLowerCase().contains(query) ||
            item.destination.toLowerCase().contains(query) ||
            item.allotmentBy.toLowerCase().contains(query);

        return matchesSearch;
      }).toList(),
    );
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      fetchAllotments();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchAllotments();
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      fetchAllotments();
    }
  }

  Future<void> selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showMonthRangePicker(context);
    
    if (picked != null) {
      fromDateController.text = "${picked.start.year}-${picked.start.month.toString().padLeft(2, '0')}";
      toDateController.text = "${picked.end.year}-${picked.end.month.toString().padLeft(2, '0')}";
      applyFilters();
    }
  }

  Future<void> exportToExcel() async {
    isExporting.value = true;
    await AppExportUtils.exportToExcel(
      title: 'Allotment Report',
      columns: const [
        "Date Of Allotment",
        "Item Name",
        "Source",
        "Destination",
        "Quantity",
        "M_Unit",
        "Allotment By",
      ],
      rows: allotmentItems
          .map(
            (item) => [
              item.dateOfAllotment,
              item.itemName,
              item.source,
              item.destination,
              item.quantity,
              item.unit,
              item.allotmentBy,
            ],
          )
          .toList(),
    );
    isExporting.value = false;
  }

  Future<void> exportToPdf() async {
    isExportingPdf.value = true;
    await AppExportUtils.exportToPdf(
      title: 'Allotment Report',
      columns: const [
        "Date Of Allotment",
        "Item Name",
        "Source",
        "Destination",
        "Quantity",
        "M_Unit",
        "Allotment By",
      ],
      rows: allotmentItems
          .map(
            (item) => [
              item.dateOfAllotment,
              item.itemName,
              item.source,
              item.destination,
              item.quantity,
              item.unit,
              item.allotmentBy,
            ],
          )
          .toList(),
    );
    isExportingPdf.value = false;
  }

  Future<bool> reverseAllotment(AllotmentItemModel item) async {
    isReversing.value = true;
    try {
      final response = await _inventoryRepository.reverseAllotment(item.allotmentId);
      if (response != null && response['status'] == true) {
        AppCommonToastMessage.show(
          message: response['message']?.toString() ?? "Allotment reversed successfully!",
          type: ToastType.success,
        );
        await fetchAllotments();
        return true;
      } else {
        AppCommonToastMessage.show(
          message: response?['message']?.toString() ?? "Failed to reverse allotment",
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error reversing allotment: $e');
      AppCommonToastMessage.show(
        message: "Failed to reverse allotment: $e",
        type: ToastType.error,
      );
      return false;
    } finally {
      isReversing.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    super.onClose();
  }
}
