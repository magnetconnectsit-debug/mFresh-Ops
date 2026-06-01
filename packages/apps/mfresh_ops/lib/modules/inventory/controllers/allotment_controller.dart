import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/utils/app_export_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllotmentController extends GetxController {
  final isSearching = false.obs;
  final searchController = TextEditingController();
  final isExporting = false.obs;
  final isExportingPdf = false.obs;
  final isLoading = false.obs;

  Future<void> onRefresh() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
  }

  // Date filters
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();

  // Full list of mock data for allotments
  final allAllotmentItems = <AllotmentItemModel>[
    AllotmentItemModel(
      dateOfAllotment: '28-Apr-26 05:04 PM',
      itemName: 'Garbage Bag - Small',
      source: 'Store_Puri (Storeroom)',
      destination: 'MM25005 (Unit)',
      quantity: '20',
      unit: 'pcs',
      allotmentBy: 'Asutosh Jena',
    ),
    AllotmentItemModel(
      dateOfAllotment: '28-Apr-26 05:04 PM',
      itemName: 'Printing Roll - 3in',
      source: 'Store_Puri (Storeroom)',
      destination: 'MM25005 (Unit)',
      quantity: '1',
      unit: 'pcs',
      allotmentBy: 'Asutosh Jena',
    ),
    AllotmentItemModel(
      dateOfAllotment: '28-Apr-26 05:03 PM',
      itemName: 'Shampoo - Liquid',
      source: 'Store_Puri (Storeroom)',
      destination: 'MM25003 (Unit)',
      quantity: '1,000',
      unit: 'ml',
      allotmentBy: 'Asutosh Jena',
    ),
    AllotmentItemModel(
      dateOfAllotment: '28-Apr-26 05:02 PM',
      itemName: 'Glass Cleaner',
      source: 'Store_Puri (Storeroom)',
      destination: 'MM25003 (Unit)',
      quantity: '1,000',
      unit: 'ml',
      allotmentBy: 'Asutosh Jena',
    ),
    AllotmentItemModel(
      dateOfAllotment: '28-Apr-26 05:02 PM',
      itemName: 'Body Wash',
      source: 'Store_Puri (Storeroom)',
      destination: 'MM25003 (Unit)',
      quantity: '1,000',
      unit: 'ml',
      allotmentBy: 'Asutosh Jena',
    ),
  ];

  final allotmentItems = <AllotmentItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    allotmentItems.assignAll(allAllotmentItems);
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      applyFilters();
    }
  }

  void applyFilters() {
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
      controller.text =
          "${picked.day.toString().padLeft(2, '0')}-${_getMonthName(picked.month)}-${picked.year}";
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

  void reverseAllotment(AllotmentItemModel item) {
    allotmentItems.remove(item);
    allAllotmentItems.remove(item);
    AppCommonToastMessage.show(
      message: "Allotment reversed successfully!",
      type: ToastType.success,
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    super.onClose();
  }
}

class AllotmentItemModel {
  final String dateOfAllotment;
  final String itemName;
  final String source;
  final String destination;
  final String quantity;
  final String unit;
  final String allotmentBy;

  AllotmentItemModel({
    required this.dateOfAllotment,
    required this.itemName,
    required this.source,
    required this.destination,
    required this.quantity,
    required this.unit,
    required this.allotmentBy,
  });
}
