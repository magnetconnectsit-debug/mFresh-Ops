import 'package:core/utils/app_export_utils.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:core/constants/app_colors.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';
import 'package:mfresh_ops/widgets/month_range_picker.dart';

class AuditorOption {
  final int id;
  final String name;

  AuditorOption({
    required this.id,
    required this.name,
  });

  factory AuditorOption.fromJson(Map<String, dynamic> json) {
    return AuditorOption(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class UnitOption {
  final int id;
  final String name;
  final String districtName;

  UnitOption({
    required this.id,
    required this.name,
    required this.districtName,
  });

  factory UnitOption.fromJson(Map<String, dynamic> json) {
    return UnitOption(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      districtName: json['district_name']?.toString() ?? '',
    );
  }
}

class AuditReportEntry {
  final int id;
  final String auditNumber;
  final int unitId;
  final String unitName;
  final String districtName;
  final String imageUrl;
  final int auditorId;
  final String auditorName;
  final String auditDate;
  final String auditDateDisplay;
  final String auditDay;
  final String createdAt;

  AuditReportEntry({
    required this.id,
    required this.auditNumber,
    required this.unitId,
    required this.unitName,
    required this.districtName,
    required this.imageUrl,
    required this.auditorId,
    required this.auditorName,
    required this.auditDate,
    required this.auditDateDisplay,
    required this.auditDay,
    required this.createdAt,
  });

  factory AuditReportEntry.fromJson(Map<String, dynamic> json) {
    final unit = json['unit'] is Map ? json['unit'] : {};
    final auditor = json['auditor'] is Map ? json['auditor'] : {};
    final rawDate = json['audit_date']?.toString() ??
        json['audited_at']?.toString() ??
        json['created_at']?.toString() ??
        '';

    final formattedDate = AppDateUtils.formatToShortOrdinalDate(rawDate);

    return AuditReportEntry(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      auditNumber: json['audit_number']?.toString() ?? json['audit_no']?.toString() ?? '-',
      unitId: unit['id'] is int ? unit['id'] : int.tryParse(unit['id']?.toString() ?? '') ?? 0,
      unitName: unit['name']?.toString() ?? json['unit_name']?.toString() ?? '-',
      districtName: unit['district_name']?.toString() ?? '',
      imageUrl: unit['image_url']?.toString() ?? '',
      auditorId: auditor['id'] is int ? auditor['id'] : int.tryParse(auditor['id']?.toString() ?? '') ?? 0,
      auditorName: auditor['name']?.toString() ?? json['audited_by_name']?.toString() ?? '-',
      auditDate: rawDate,
      auditDateDisplay: formattedDate.isNotEmpty
          ? formattedDate
          : (json['audit_date_display']?.toString() ?? rawDate),
      auditDay: json['audit_day']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class AuditDetailData {
  final int id;
  final String auditNumber;
  final String unitName;
  final String districtName;
  final String imageUrl;
  final String auditorName;
  final String auditDateDisplay;
  final int existingItemsCount;
  final int additionalItemsCount;
  final int totalItemsCount;
  final List<AuditItemDetail> items;
  final List<AdditionalAuditItemDetail> additionalItems;

  AuditDetailData({
    required this.id,
    required this.auditNumber,
    required this.unitName,
    required this.districtName,
    required this.imageUrl,
    required this.auditorName,
    required this.auditDateDisplay,
    required this.existingItemsCount,
    required this.additionalItemsCount,
    required this.totalItemsCount,
    required this.items,
    required this.additionalItems,
  });

  factory AuditDetailData.fromJson(Map<String, dynamic> json) {
    final unit = json['unit'] is Map ? json['unit'] : {};
    final auditor = json['auditor'] is Map ? json['auditor'] : {};

    final itemsList = (json['items'] as List? ?? [])
        .map((e) => AuditItemDetail.fromJson(e))
        .toList();
    final additionalList = (json['additional_items'] as List? ?? [])
        .map((e) => AdditionalAuditItemDetail.fromJson(e))
        .toList();

    final rawDate = json['audit_date']?.toString() ?? json['audited_at']?.toString() ?? '';
    final formattedDate = AppDateUtils.formatToShortOrdinalDate(rawDate);

    return AuditDetailData(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      auditNumber: json['audit_number']?.toString() ?? '-',
      unitName: unit['name']?.toString() ?? '-',
      districtName: unit['district_name']?.toString() ?? '',
      imageUrl: unit['image_url']?.toString() ?? '',
      auditorName: auditor['name']?.toString() ?? '-',
      auditDateDisplay: formattedDate.isNotEmpty
          ? formattedDate
          : (json['audit_date_display']?.toString() ?? rawDate),
      existingItemsCount: json['existing_items_count'] is int ? json['existing_items_count'] : int.tryParse(json['existing_items_count']?.toString() ?? '') ?? itemsList.length,
      additionalItemsCount: json['additional_items_count'] is int ? json['additional_items_count'] : int.tryParse(json['additional_items_count']?.toString() ?? '') ?? additionalList.length,
      totalItemsCount: json['total_items_count'] is int ? json['total_items_count'] : int.tryParse(json['total_items_count']?.toString() ?? '') ?? (itemsList.length + additionalList.length),
      items: itemsList,
      additionalItems: additionalList,
    );
  }
}

class AuditItemDetail {
  final int id;
  final int itemId;
  final String itemName;
  final int categoryId;
  final String categoryName;
  final int measurementUnitId;
  final String measurementUnit;
  final num systemQty;
  final num actualQty;
  final num differenceQty;
  final String systemQtyLabel;
  final String actualQtyLabel;
  final String differenceQtyLabel;
  final num? actualPercentage;
  final String actualPercentageLabel;
  final String actualPercentageColor;
  final bool percentageAvailable;
  final num? variancePercentage;
  final String variancePercentageLabel;
  final String varianceStatus;
  final String varianceColor;
  final List<String> imageUrls;

  AuditItemDetail({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.categoryId,
    required this.categoryName,
    required this.measurementUnitId,
    required this.measurementUnit,
    required this.systemQty,
    required this.actualQty,
    required this.differenceQty,
    required this.systemQtyLabel,
    required this.actualQtyLabel,
    required this.differenceQtyLabel,
    this.actualPercentage,
    this.actualPercentageLabel = '-',
    this.actualPercentageColor = 'normal',
    this.percentageAvailable = false,
    this.variancePercentage,
    this.variancePercentageLabel = '-',
    required this.varianceStatus,
    required this.varianceColor,
    this.imageUrls = const [],
  });

  factory AuditItemDetail.fromJson(Map<String, dynamic> json) {
    final rawUrls = json['audit_item_img'] ??
        json['image_urls'] ??
        json['images'] ??
        json['image_url'] ??
        json['item_images'] ??
        json['photos'] ??
        json['attachments'];

    List<String> urls = [];
    if (rawUrls is List) {
      for (var e in rawUrls) {
        if (e is String && e.isNotEmpty) {
          urls.add(e);
        } else if (e is Map) {
          final url = e['image_url']?.toString() ??
              e['url']?.toString() ??
              e['image']?.toString() ??
              e['path']?.toString() ??
              '';
          if (url.isNotEmpty) urls.add(url);
        }
      }
    } else if (rawUrls is String && rawUrls.isNotEmpty) {
      urls.add(rawUrls);
    }

    return AuditItemDetail(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      itemId: json['item_id'] is int ? json['item_id'] : int.tryParse(json['item_id']?.toString() ?? '') ?? 0,
      itemName: json['item_name']?.toString() ?? '-',
      categoryId: json['category_id'] is int ? json['category_id'] : int.tryParse(json['category_id']?.toString() ?? '') ?? 0,
      categoryName: json['category_name']?.toString() ?? '-',
      measurementUnitId: json['measurement_unit_id'] is int ? json['measurement_unit_id'] : int.tryParse(json['measurement_unit_id']?.toString() ?? '') ?? 0,
      measurementUnit: json['measurement_unit']?.toString() ?? '',
      systemQty: num.tryParse(json['system_qty']?.toString() ?? '0') ?? 0,
      actualQty: num.tryParse(json['actual_qty']?.toString() ?? '0') ?? 0,
      differenceQty: num.tryParse(json['difference_qty']?.toString() ?? '0') ?? 0,
      systemQtyLabel: json['system_qty_label']?.toString() ?? '${json['system_qty']} ${json['measurement_unit']}',
      actualQtyLabel: json['actual_qty_label']?.toString() ?? '${json['actual_qty']} ${json['measurement_unit']}',
      differenceQtyLabel: json['difference_qty_label']?.toString() ?? '${json['difference_qty']} ${json['measurement_unit']}',
      actualPercentage: num.tryParse(json['actual_percentage']?.toString() ?? ''),
      actualPercentageLabel: json['actual_percentage_label']?.toString() ?? '-',
      actualPercentageColor: json['actual_percentage_color']?.toString() ?? 'normal',
      percentageAvailable: json['percentage_available'] == true,
      variancePercentage: num.tryParse(json['variance_percentage']?.toString() ?? ''),
      variancePercentageLabel: json['variance_percentage_label']?.toString() ?? '-',
      varianceStatus: json['variance_status']?.toString() ?? 'Matched',
      varianceColor: json['variance_color']?.toString() ?? 'normal',
      imageUrls: urls,
    );
  }
}

class AdditionalAuditItemDetail {
  final int id;
  final String itemName;
  final num actualQty;
  final String measurementUnit;
  final String type;
  final num? actualPercentage;
  final String actualPercentageLabel;
  final String actualPercentageColor;
  final bool percentageAvailable;
  final List<String> imageUrls;

  AdditionalAuditItemDetail({
    required this.id,
    required this.itemName,
    required this.actualQty,
    required this.measurementUnit,
    this.type = 'Unlisted Item',
    this.actualPercentage,
    this.actualPercentageLabel = '-',
    this.actualPercentageColor = 'normal',
    this.percentageAvailable = false,
    this.imageUrls = const [],
  });

  factory AdditionalAuditItemDetail.fromJson(Map<String, dynamic> json) {
    final rawUrls = json['audit_add_item_img'] ??
        json['image_urls'] ??
        json['images'] ??
        json['image_url'] ??
        json['item_images'] ??
        json['photos'] ??
        json['attachments'];

    List<String> urls = [];
    if (rawUrls is List) {
      for (var e in rawUrls) {
        if (e is String && e.isNotEmpty) {
          urls.add(e);
        } else if (e is Map) {
          final url = e['image_url']?.toString() ??
              e['url']?.toString() ??
              e['image']?.toString() ??
              e['path']?.toString() ??
              '';
          if (url.isNotEmpty) urls.add(url);
        }
      }
    } else if (rawUrls is String && rawUrls.isNotEmpty) {
      urls.add(rawUrls);
    }

    return AdditionalAuditItemDetail(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      itemName: json['item_name']?.toString() ?? '-',
      actualQty: num.tryParse(json['actual_qty']?.toString() ?? '0') ?? 0,
      measurementUnit: json['measurement_unit']?.toString() ?? json['measurement_unit_name']?.toString() ?? 'pcs',
      type: json['type']?.toString() ?? 'Unlisted Item',
      actualPercentage: num.tryParse(json['actual_percentage']?.toString() ?? ''),
      actualPercentageLabel: json['actual_percentage_label']?.toString() ?? '-',
      actualPercentageColor: json['actual_percentage_color']?.toString() ?? 'normal',
      percentageAvailable: json['percentage_available'] == true,
      imageUrls: urls,
    );
  }
}

class AuditReportController extends GetxController {
  final InventoryRepository _repository = Get.find<InventoryRepository>();

  // State for List
  final isLoading = false.obs;
  final isExporting = false.obs;
  final auditList = <AuditReportEntry>[].obs;
  final filteredList = <AuditReportEntry>[].obs;
  final unitOptions = <UnitOption>[].obs;

  // Pagination
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final perPage = 25.obs;
  final totalCount = 0.obs;

  // Filters
  final selectedUnitIds = <int>{}.obs;
  final monthYearController = TextEditingController();

  final auditorOptions = <AuditorOption>[].obs;
  final selectedAuditorIds = <int>{}.obs;

  final fromDate = RxnString();
  final toDate = RxnString();

  final selectedYear = RxnInt();
  final selectedFromMonth = RxnInt();
  final selectedToMonth = RxnInt();

  List<UnitOption> get selectedUnitOptions {
    return unitOptions.where((opt) => selectedUnitIds.contains(opt.id)).toList();
  }

  void removeUnitFilter(int unitId) {
    selectedUnitIds.remove(unitId);
    fetchAuditReport();
  }

  void clearUnitFilters() {
    selectedUnitIds.clear();
    fetchAuditReport();
  }

  List<AuditorOption> get selectedAuditorOptions {
    return auditorOptions.where((opt) => selectedAuditorIds.contains(opt.id)).toList();
  }

  void removeAuditorFilter(int auditorId) {
    selectedAuditorIds.remove(auditorId);
    fetchAuditReport();
  }

  void clearAuditorFilters() {
    selectedAuditorIds.clear();
    fetchAuditReport();
  }

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _getMonthName(int? monthValue) {
    if (monthValue != null && monthValue >= 1 && monthValue <= 12) {
      return _monthNames[monthValue - 1];
    }
    return '';
  }

  String get monthRangeDisplayText {
    final fromName = _getMonthName(selectedFromMonth.value);
    final toName = _getMonthName(selectedToMonth.value);
    final yearStr = selectedYear.value != null ? '${selectedYear.value}' : '';

    if (fromName.isNotEmpty && toName.isNotEmpty) {
      if (selectedFromMonth.value == selectedToMonth.value) {
        return yearStr.isNotEmpty ? '$fromName $yearStr' : fromName;
      }
      return yearStr.isNotEmpty
          ? '$fromName - $toName $yearStr'
          : '$fromName - $toName';
    } else if (fromName.isNotEmpty) {
      return yearStr.isNotEmpty ? '$fromName $yearStr' : fromName;
    } else if (toName.isNotEmpty) {
      return yearStr.isNotEmpty ? '$toName $yearStr' : toName;
    }
    return yearStr;
  }

  String get dateRangeDisplayText {
    if (fromDate.value != null && toDate.value != null && fromDate.value!.isNotEmpty && toDate.value!.isNotEmpty) {
      try {
        final d1 = DateFormat('dd MMM yyyy').format(DateTime.parse(fromDate.value!));
        final d2 = DateFormat('dd MMM yyyy').format(DateTime.parse(toDate.value!));
        return '$d1 - $d2';
      } catch (_) {
        return '${fromDate.value} - ${toDate.value}';
      }
    }
    return '';
  }

  String get customDateDisplayText {
    if (selectedFromMonth.value != null) {
      return monthRangeDisplayText;
    }
    if (fromDate.value != null && fromDate.value!.isNotEmpty) {
      return dateRangeDisplayText;
    }
    return '';
  }

  void showCustomDateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          child: Container(
            width: 260.w,
            padding: EdgeInsets.all(16.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Custom Date',
                      style: AppTextStyle.style_13_600(color: AppColors.grey900),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Icon(Icons.close, size: 18.r, color: AppColors.grey500),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                    side: const BorderSide(color: AppColors.primaryOrange),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                  ),
                  icon: Icon(Icons.calendar_month_outlined, color: AppColors.primaryOrange, size: 18.r),
                  label: Text(
                    'Select Month',
                    style: AppTextStyle.style_12_600(color: AppColors.primaryOrange),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    openMonthRangePicker(context);
                  },
                ),
                SizedBox(height: 8.h),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                    side: const BorderSide(color: AppColors.primaryOrange),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                  ),
                  icon: Icon(Icons.date_range_outlined, color: AppColors.primaryOrange, size: 18.r),
                  label: Text(
                    'Select Date',
                    style: AppTextStyle.style_12_600(color: AppColors.primaryOrange),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    openDateRangePicker(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> openDateRangePicker(BuildContext context) async {
    DateTime initialStart = DateTime.now();
    DateTime initialEnd = DateTime.now();
    if (fromDate.value != null && fromDate.value!.isNotEmpty) {
      try {
        initialStart = DateTime.parse(fromDate.value!);
      } catch (_) {}
    }
    if (toDate.value != null && toDate.value!.isNotEmpty) {
      try {
        initialEnd = DateTime.parse(toDate.value!);
      } catch (_) {}
    }

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryOrange,
              onPrimary: AppColors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedYear.value = null;
      selectedFromMonth.value = null;
      selectedToMonth.value = null;

      fromDate.value = DateFormat('yyyy-MM-dd').format(picked.start);
      toDate.value = DateFormat('yyyy-MM-dd').format(picked.end);
      fetchAuditReport();
    }
  }

  Future<void> openMonthRangePicker(BuildContext context) async {
    final DateTime? initialStart = selectedFromMonth.value != null
        ? DateTime(
            selectedYear.value ?? DateTime.now().year,
            selectedFromMonth.value!,
          )
        : null;
    final DateTime? initialEnd = selectedToMonth.value != null
        ? DateTime(
            selectedYear.value ?? DateTime.now().year,
            selectedToMonth.value!,
          )
        : null;

    final DateTimeRange? picked = await showMonthRangePicker(
      context,
      initialStartMonth: initialStart,
      initialEndMonth: initialEnd,
    );

    if (picked != null) {
      selectedYear.value = picked.start.year;
      selectedFromMonth.value = picked.start.month;
      selectedToMonth.value = picked.end.month;

      final startDate = DateTime(picked.start.year, picked.start.month, 1);
      final endDate = DateTime(picked.end.year, picked.end.month + 1, 0);

      fromDate.value = DateFormat('yyyy-MM-dd').format(startDate);
      toDate.value = DateFormat('yyyy-MM-dd').format(endDate);
      fetchAuditReport();
    }
  }

  void clearDateRangeFilter() {
    fromDate.value = null;
    toDate.value = null;
    fetchAuditReport();
  }

  void clearMonthRangeFilter() {
    selectedYear.value = null;
    selectedFromMonth.value = null;
    selectedToMonth.value = null;
    fromDate.value = null;
    toDate.value = null;
    fetchAuditReport();
  }

  // Search
  final searchController = TextEditingController();
  final isSearching = false.obs;

  // Table Sorting (List Screen)
  final sortColumn = ''.obs;
  final sortAscending = true.obs;

  // Expanded Row IDs (Mobile UI)
  final expandedRowIds = <int>{}.obs;

  // State for Audit Detail
  final isDetailLoading = false.obs;
  final selectedAuditEntry = Rxn<AuditReportEntry>();
  final selectedAuditDetail = Rxn<AuditDetailData>();

  // Detail Sorting (Default: Category ascending matching AuditTableWidget)
  final detailSortColumn = 'category'.obs;
  final detailSortAscending = true.obs;
  final detailCategorySortAscending = true.obs;
  final expandedDetailRowIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAuditReport();
  }

  @override
  void onClose() {
    searchController.dispose();
    monthYearController.dispose();
    super.onClose();
  }

  Future<void> fetchAuditReport() async {
    isLoading.value = true;
    try {
      final unitIdsParam = selectedUnitIds.isEmpty
          ? null
          : selectedUnitIds.toList();
      final auditorIdsParam = selectedAuditorIds.isEmpty
          ? null
          : selectedAuditorIds.toList();

      final response = await _repository.getAuditReport(
        unitId: unitIdsParam,
        auditedBy: auditorIdsParam,
        fromDate: fromDate.value,
        toDate: toDate.value,
      );

      if (response != null && response['status'] == true) {
        // Unit options
        if (response['unit_options'] is List) {
          final opts = (response['unit_options'] as List)
              .map((e) => UnitOption.fromJson(e))
              .toList();
          unitOptions.assignAll(opts);
        }

        // Auditor options
        if (response['auditor_options'] is List) {
          final opts = (response['auditor_options'] as List)
              .map((e) => AuditorOption.fromJson(e))
              .toList();
          auditorOptions.assignAll(opts);
        }

        // Pagination
        final pag = response['pagination'];
        if (pag is Map) {
          currentPage.value = pag['current_page'] ?? 1;
          totalPages.value = pag['last_page'] ?? 1;
          totalCount.value = pag['total'] ?? 0;
        }

        // Data entries
        final List data = response['data'] ?? [];
        final entries = data.map((e) => AuditReportEntry.fromJson(e)).toList();
        auditList.assignAll(entries);
        applySearch();
      } else {
        auditList.clear();
        filteredList.clear();
      }
    } catch (e) {
      debugPrint('AuditReportController: fetchAuditReport error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void applySearch() {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      filteredList.assignAll(auditList);
    } else {
      filteredList.assignAll(auditList.where((e) =>
          e.auditNumber.toLowerCase().contains(query) ||
          e.auditorName.toLowerCase().contains(query) ||
          e.unitName.toLowerCase().contains(query) ||
          e.districtName.toLowerCase().contains(query)));
    }
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      applySearch();
    }
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

  List<AuditReportEntry> get sortedAuditList {
    if (sortColumn.value.isEmpty) {
      return filteredList;
    }
    final list = List<AuditReportEntry>.from(filteredList);
    final isAsc = sortAscending.value;
    switch (sortColumn.value) {
      case 'Audit Number':
      case 'Audit No':
        list.sort((a, b) => isAsc ? a.auditNumber.compareTo(b.auditNumber) : b.auditNumber.compareTo(a.auditNumber));
        break;
      case 'Unit':
        list.sort((a, b) => isAsc ? a.unitName.compareTo(b.unitName) : b.unitName.compareTo(a.unitName));
        break;
      case 'Audit Date':
      case 'Date':
        list.sort((a, b) => isAsc ? a.auditDate.compareTo(b.auditDate) : b.auditDate.compareTo(a.auditDate));
        break;
      case 'Audited By':
        list.sort((a, b) => isAsc ? a.auditorName.compareTo(b.auditorName) : b.auditorName.compareTo(a.auditorName));
        break;
    }
    return list;
  }

  void toggleRowExpansion(int id) {
    if (expandedRowIds.contains(id)) {
      expandedRowIds.remove(id);
    } else {
      expandedRowIds.add(id);
    }
  }

  // Details logic
  Future<void> loadAuditDetail(int auditId, {AuditReportEntry? entry}) async {
    if (entry != null) {
      selectedAuditEntry.value = entry;
    }
    isDetailLoading.value = true;
    selectedAuditDetail.value = null;
    expandedDetailRowIds.clear();
    detailSortColumn.value = 'category';
    detailSortAscending.value = true;
    detailCategorySortAscending.value = true;
    try {
      final response = await _repository.getAuditDetail(auditId);
      if (response != null && response['status'] == true && response['data'] != null) {
        selectedAuditDetail.value = AuditDetailData.fromJson(response['data']);
      }
    } catch (e) {
      debugPrint('AuditReportController: loadAuditDetail error: $e');
    } finally {
      isDetailLoading.value = false;
    }
  }

  void sortByDetail(String columnKey) {
    final key = columnKey.toLowerCase();
    if (key == 'category') {
      if (detailSortColumn.value == 'category') {
        detailCategorySortAscending.value = !detailCategorySortAscending.value;
        detailSortAscending.value = detailCategorySortAscending.value;
      } else {
        detailSortColumn.value = 'category';
        detailSortAscending.value = detailCategorySortAscending.value;
      }
    } else {
      if (detailSortColumn.value == key) {
        if (detailSortAscending.value) {
          detailSortAscending.value = false;
        } else {
          // Reset column sort back to category
          detailSortColumn.value = 'category';
          detailSortAscending.value = detailCategorySortAscending.value;
        }
      } else {
        detailSortColumn.value = key;
        detailSortAscending.value = true;
      }
    }
  }

  List<AuditItemDetail> get sortedDetailItems {
    final items = selectedAuditDetail.value?.items;
    if (items == null || items.isEmpty) return [];

    final list = List<AuditItemDetail>.from(items);
    final activeColumn = detailSortColumn.value.isEmpty ? 'category' : detailSortColumn.value;

    list.sort((a, b) {
      // 1. Primary Category Comparison respecting current category direction
      int catCmp = a.categoryName.toLowerCase().compareTo(b.categoryName.toLowerCase());
      if (catCmp != 0) {
        return detailCategorySortAscending.value ? catCmp : -catCmp;
      }

      // 2. Within the same Category:
      if (activeColumn == 'category') {
        int itemCmp = a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase());
        return detailCategorySortAscending.value ? itemCmp : -itemCmp;
      }

      int secCmp = 0;
      switch (activeColumn) {
        case 'item':
        case 'item name':
          secCmp = a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase());
          break;
        case 'slno':
        case 'si no.':
        case 'sl no.':
          secCmp = a.id.compareTo(b.id);
          break;
        case 'system qty':
        case 'systemqty':
          secCmp = a.systemQty.compareTo(b.systemQty);
          break;
        case 'actual qty':
        case 'actualqty':
          secCmp = a.actualQty.compareTo(b.actualQty);
          break;
        case 'difference':
          secCmp = a.differenceQty.compareTo(b.differenceQty);
          break;
        case 'result':
        case 'variance':
          secCmp = a.varianceStatus.compareTo(b.varianceStatus);
          break;
        default:
          secCmp = a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase());
      }
      return detailSortAscending.value ? secCmp : -secCmp;
    });
    return list;
  }

  void toggleDetailRowExpansion(int id) {
    if (expandedDetailRowIds.contains(id)) {
      expandedDetailRowIds.remove(id);
    } else {
      expandedDetailRowIds.add(id);
    }
  }

  Future<void> onRefresh() async {
    searchController.clear();
    isSearching.value = false;
    await fetchAuditReport();
  }

  Future<void> exportDetailToExcel() async {
    final detail = selectedAuditDetail.value;
    if (detail == null) return;

    isExporting.value = true;
    try {
      // Build rows for main items
      final mainRows = detail.items.asMap().entries.map((e) {
        final i = e.value;
        return [
          e.key + 1,
          i.categoryName,
          i.itemName,
          i.measurementUnit,
          i.systemQty,
          i.actualQty,
          i.differenceQty,
          i.varianceStatus,
        ];
      }).toList();

      // Build rows for additional items
      final additionalRows = detail.additionalItems.asMap().entries.map((e) {
        final i = e.value;
        return [
          e.key + 1,
          '-',
          i.itemName,
          i.measurementUnit,
          '-',
          i.actualQty,
          '-',
          i.type,
        ];
      }).toList();

      final allRows = [...mainRows, ...additionalRows];

      final titleParts = <String>['Audit Report Detail'];
      if (detail.auditNumber.isNotEmpty && detail.auditNumber != '-') {
        titleParts.add('#${detail.auditNumber}');
      }
      if (detail.unitName.isNotEmpty && detail.unitName != '-') {
        titleParts.add(detail.unitName);
      }

      await AppExportUtils.exportToExcel(
        title: titleParts.join(' - '),
        columns: const [
          'SI No',
          'Category',
          'Item',
          'Unit',
          'System Qty',
          'Actual Qty',
          'Difference',
          'Status / Type',
        ],
        rows: allRows,
      );
    } catch (e) {
      debugPrint('exportDetailToExcel error: \$e');
    } finally {
      isExporting.value = false;
    }
  }

  void resetFilters() {
    selectedUnitIds.clear();
    selectedAuditorIds.clear();
    fromDate.value = null;
    toDate.value = null;
    selectedYear.value = null;
    selectedFromMonth.value = null;
    selectedToMonth.value = null;
    monthYearController.clear();
    searchController.clear();
    fetchAuditReport();
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      fetchAuditReport();
    }
  }

  void prevPage() {
    if (currentPage.value > 1) {
      fetchAuditReport();
    }
  }
}
