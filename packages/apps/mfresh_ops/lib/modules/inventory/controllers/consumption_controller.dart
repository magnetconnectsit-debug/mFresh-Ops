import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import 'package:core/utils/app_export_utils.dart';

class ConsumptionController extends GetxController {
  final isSearching = false.obs;
  final searchController = TextEditingController();
  final isExporting = false.obs;
  final isExportingPdf = false.obs;

  // Date filters
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();

  // Multi-select filter states
  final selectedUnits = <String>[].obs;
  final selectedItems = <String>[].obs;
  final selectedStores = <String>[].obs;

  // Filter options
  final unitOptions = <DropdownOption<String>>[
    const DropdownOption(value: 'MM25002', label: 'MM25002'),
    const DropdownOption(value: 'MM25003', label: 'MM25003'),
    const DropdownOption(value: 'MM25005', label: 'MM25005'),
  ];

  final itemOptions = <DropdownOption<String>>[
    const DropdownOption(value: 'Hand Wash', label: 'Hand Wash'),
    const DropdownOption(value: 'Body Wash', label: 'Body Wash'),
    const DropdownOption(value: 'Floor Cleaner', label: 'Floor Cleaner'),
  ];

  final storeOptions = <DropdownOption<String>>[
    const DropdownOption(value: 'Store_Puri', label: 'Store_Puri'),
    const DropdownOption(value: 'Store_Khurda', label: 'Store_Khurda'),
  ];

  // Full list of mock data for consumption items
  final allConsumptionItems = <ConsumptionItemModel>[
    ConsumptionItemModel(
      consumedOn: '29-apr-2026',
      state: 'Odisha',
      district: 'Puri',
      sourceType: 'Unit',
      source: 'MM25002',
      category: 'C_Cleaning Items',
      item: 'Floor Cleaner',
      quantity: '500 ml',
    ),
    ConsumptionItemModel(
      consumedOn: '29-apr-2026',
      state: 'Odisha',
      district: 'Puri',
      sourceType: 'Unit',
      source: 'MM25003',
      category: 'Other Consumption',
      item: 'Waste Bin',
      quantity: '1 pcs',
    ),
    ConsumptionItemModel(
      consumedOn: '29-apr-2026',
      state: 'Odisha',
      district: 'Puri',
      sourceType: 'Unit',
      source: 'MM25003',
      category: 'C_Personal Care',
      item: 'Hand Wash',
      quantity: '300 ml',
    ),
    ConsumptionItemModel(
      consumedOn: '29-apr-2026',
      state: 'Odisha',
      district: 'Puri',
      sourceType: 'Unit',
      source: 'MM25005',
      category: 'Other Consumption',
      item: 'Mop',
      quantity: '1 pcs',
    ),
    ConsumptionItemModel(
      consumedOn: '29-apr-2026',
      state: 'Odisha',
      district: 'Puri',
      sourceType: 'Unit',
      source: 'MM25002',
      category: 'Other Consumption',
      item: 'Bucket',
      quantity: '2 pcs',
    ),
    ConsumptionItemModel(
      consumedOn: '29-apr-2026',
      state: 'Odisha',
      district: 'Puri',
      sourceType: 'Unit',
      source: 'MM25003',
      category: 'C_Cleaning Tools',
      item: 'Broom',
      quantity: '1 pcs',
    ),
  ];

  final consumptionItems = <ConsumptionItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    consumptionItems.assignAll(allConsumptionItems);
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
    
    consumptionItems.assignAll(
      allConsumptionItems.where((item) {
        // Search filter
        final matchesSearch = query.isEmpty ||
            item.item.toLowerCase().contains(query) ||
            item.source.toLowerCase().contains(query) ||
            item.category.toLowerCase().contains(query);
            
        // Unit filter
        final matchesUnit = selectedUnits.isEmpty || selectedUnits.contains(item.source);
        
        // Item filter
        final matchesItem = selectedItems.isEmpty || selectedItems.contains(item.item);
        
        return matchesSearch && matchesUnit && matchesItem;
      }).toList(),
    );
  }

  Future<void> exportToExcel() async {
    isExporting.value = true;
    await AppExportUtils.exportToExcel(
      title: 'Consumption Report',
      columns: const ["Consumed On", "State", "District", "Source Type", "Source", "Category", "Item", "Quantity"],
      rows: consumptionItems.map((item) => [item.consumedOn, item.state, item.district, item.sourceType, item.source, item.category, item.item, item.quantity]).toList(),
    );
    isExporting.value = false;
  }

  Future<void> exportToPdf() async {
    isExportingPdf.value = true;
    await AppExportUtils.exportToPdf(title: 'Consumption Report');
    isExportingPdf.value = false;
  }

  Future<void> selectDate(BuildContext context, TextEditingController controller) async {
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
      controller.text = "${picked.day.toString().padLeft(2, '0')}-${_getMonthName(picked.month)}-${picked.year}";
      applyFilters();
    }
  }

  String _getMonthName(int month) {
    const months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
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

class ConsumptionItemModel {
  final String consumedOn;
  final String state;
  final String district;
  final String sourceType;
  final String source;
  final String category;
  final String item;
  final String quantity;

  ConsumptionItemModel({
    required this.consumedOn,
    required this.state,
    required this.district,
    required this.sourceType,
    required this.source,
    required this.category,
    required this.item,
    required this.quantity,
  });
}
