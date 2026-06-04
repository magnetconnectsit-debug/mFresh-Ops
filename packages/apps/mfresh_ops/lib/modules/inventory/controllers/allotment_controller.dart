import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/utils/app_export_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  // Date filters (Year-Month format YYYY-MM)
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();

  final allAllotmentItems = <AllotmentItemModel>[];
  final allotmentItems = <AllotmentItemModel>[].obs;

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

  Future<void> selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
      controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}";
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
