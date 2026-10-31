// region Imports
import 'package:core/utils/app_export_utils.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:core/constants/app_colors.dart';
import 'package:mfresh_ops/data/models/inventory/audit_report_model.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';
import 'package:mfresh_ops/widgets/month_range_picker.dart';
// endregion

// region Controller
class AuditReportController extends GetxController {
  // region Dependencies & Repositories
  final InventoryRepository _repository = Get.find<InventoryRepository>();
  // endregion

  // region Observables & State Variables
  // State for List
  final isLoading = false.obs;
  final isExporting = false.obs;
  final auditList = <AuditReportEntry>[].obs;
  final filteredList = <AuditReportEntry>[].obs;
  final unitOptions = <UnitOption>[].obs;
  final auditorOptions = <AuditorOption>[].obs;

  // Pagination
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final perPage = 25.obs;
  final totalCount = 0.obs;

  // Filters
  final selectedUnitIds = <int>{}.obs;
  final selectedAuditorIds = <int>{}.obs;

  final fromDate = RxnString();
  final toDate = RxnString();

  final selectedYear = RxnInt();
  final selectedFromMonth = RxnInt();
  final selectedToMonth = RxnInt();

  // Search
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

  // Detail Sorting & Filtering
  final detailSortColumn = 'slno'.obs;
  final detailSortAscending = true.obs;
  final detailSearchController = TextEditingController();
  final detailSearchQuery = ''.obs;
  // endregion

  // region Text Controllers & Focus Nodes
  final monthYearController = TextEditingController();
  final searchController = TextEditingController();
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    fetchAuditReport();
  }

  @override
  void onClose() {
    searchController.dispose();
    monthYearController.dispose();
    detailSearchController.dispose();
    super.onClose();
  }
  // endregion

  // region API & Network Operations
  Future<void> fetchAuditReport({int? page}) async {
    isLoading.value = true;
    try {
      final targetPage = page ?? currentPage.value;
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
        page: targetPage,
      );

      if (response != null && response['status'] == true) {
        // Unit options
        if (response['unit_options'] is List) {
          final opts = (response['unit_options'] as List)
              .map((e) => UnitOption.fromJson(e as Map<String, dynamic>))
              .toList();
          unitOptions.assignAll(opts);
        }

        // Auditor options
        if (response['auditor_options'] is List) {
          final opts = (response['auditor_options'] as List)
              .map((e) => AuditorOption.fromJson(e as Map<String, dynamic>))
              .toList();
          auditorOptions.assignAll(opts);
        }

        // Pagination
        final pag = response['pagination'];
        if (pag is Map) {
          currentPage.value = pag['current_page'] ?? targetPage;
          totalPages.value = pag['last_page'] ?? 1;
          totalCount.value = pag['total'] ?? 0;
          perPage.value = pag['per_page'] ?? 25;
        }

        // Data entries
        final List data = response['data'] ?? [];
        final entries = data
            .map((e) => AuditReportEntry.fromJson(e as Map<String, dynamic>))
            .toList();
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

  Future<void> loadAuditDetail(int auditId, {AuditReportEntry? entry}) async {
    if (entry != null) {
      selectedAuditEntry.value = entry;
    }
    isDetailLoading.value = true;
    selectedAuditDetail.value = null;
    detailSortColumn.value = 'slno';
    detailSortAscending.value = true;
    detailSearchQuery.value = '';
    detailSearchController.clear();

    try {
      final response = await _repository.getAuditDetail(auditId);
      if (response != null &&
          response['status'] == true &&
          response['data'] != null) {
        selectedAuditDetail.value =
            AuditDetailData.fromJson(response['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('AuditReportController: loadAuditDetail error: $e');
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    searchController.clear();
    isSearching.value = false;
    await fetchAuditReport();
  }
  // endregion

  // region Business Logic & Helpers
  // Filter Helpers
  List<UnitOption> get selectedUnitOptions {
    return unitOptions
        .where((opt) => selectedUnitIds.contains(opt.id))
        .toList();
  }

  void removeUnitFilter(int unitId) {
    selectedUnitIds.remove(unitId);
    currentPage.value = 1;
    fetchAuditReport(page: 1);
  }

  void clearUnitFilters() {
    selectedUnitIds.clear();
    currentPage.value = 1;
    fetchAuditReport(page: 1);
  }

  List<AuditorOption> get selectedAuditorOptions {
    return auditorOptions
        .where((opt) => selectedAuditorIds.contains(opt.id))
        .toList();
  }

  void removeAuditorFilter(int auditorId) {
    selectedAuditorIds.remove(auditorId);
    currentPage.value = 1;
    fetchAuditReport(page: 1);
  }

  void clearAuditorFilters() {
    selectedAuditorIds.clear();
    currentPage.value = 1;
    fetchAuditReport(page: 1);
  }

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
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
    if (fromDate.value != null &&
        toDate.value != null &&
        fromDate.value!.isNotEmpty &&
        toDate.value!.isNotEmpty) {
      try {
        final d1 =
            DateFormat('dd MMM yyyy').format(DateTime.parse(fromDate.value!));
        final d2 =
            DateFormat('dd MMM yyyy').format(DateTime.parse(toDate.value!));
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 340.w),
            child: Container(
              width: double.infinity,
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
                        style: AppTextStyle.style_13_600(
                          color: AppColors.grey900,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Icon(
                          Icons.close,
                          size: 18.r,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.h,
                        horizontal: 10.w,
                      ),
                      side: const BorderSide(color: AppColors.primaryOrange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    icon: Icon(
                      Icons.calendar_month_outlined,
                      color: AppColors.primaryOrange,
                      size: 18.r,
                    ),
                    label: Text(
                      'Select Month',
                      style: AppTextStyle.style_12_600(
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      openMonthRangePicker(context);
                    },
                  ),
                  SizedBox(height: 8.h),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.h,
                        horizontal: 10.w,
                      ),
                      side: const BorderSide(color: AppColors.primaryOrange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    icon: Icon(
                      Icons.date_range_outlined,
                      color: AppColors.primaryOrange,
                      size: 18.r,
                    ),
                    label: Text(
                      'Select Date',
                      style: AppTextStyle.style_12_600(
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      openDateRangePicker(context);
                    },
                  ),
                ],
              ),
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
      currentPage.value = 1;
      fetchAuditReport(page: 1);
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
      currentPage.value = 1;
      fetchAuditReport(page: 1);
    }
  }

  void clearDateRangeFilter() {
    fromDate.value = null;
    toDate.value = null;
    currentPage.value = 1;
    fetchAuditReport(page: 1);
  }

  void clearMonthRangeFilter() {
    selectedYear.value = null;
    selectedFromMonth.value = null;
    selectedToMonth.value = null;
    fromDate.value = null;
    toDate.value = null;
    currentPage.value = 1;
    fetchAuditReport(page: 1);
  }

  // Search Logic (List Screen)
  void applySearch() {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      filteredList.assignAll(auditList);
    } else {
      filteredList.assignAll(
        auditList.where(
          (e) =>
              e.auditNumber.toLowerCase().contains(query) ||
              e.auditDateDisplay.toLowerCase().contains(query) ||
              e.unitNames.toLowerCase().contains(query) ||
              e.auditorName.toLowerCase().contains(query),
        ),
      );
    }
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      applySearch();
    }
  }

  // Table Sorting (List Screen)
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
      case 'Audit No':
      case 'Audit Number':
      case 'Audit No.':
        list.sort((a, b) => isAsc
            ? a.auditNumber.compareTo(b.auditNumber)
            : b.auditNumber.compareTo(a.auditNumber));
        break;
      case 'Sl No.':
      case 'SI No.':
        list.sort((a, b) => isAsc ? a.id.compareTo(b.id) : b.id.compareTo(a.id));
        break;
      case 'Audit Date':
      case 'Date':
        list.sort((a, b) => isAsc
            ? a.auditDateDisplay.compareTo(b.auditDateDisplay)
            : b.auditDateDisplay.compareTo(a.auditDateDisplay));
        break;
      case 'Units':
        list.sort((a, b) => isAsc
            ? a.unitNames.compareTo(b.unitNames)
            : b.unitNames.compareTo(a.unitNames));
        break;
      case 'Total Units':
        list.sort((a, b) => isAsc
            ? a.unitCount.compareTo(b.unitCount)
            : b.unitCount.compareTo(a.unitCount));
        break;
      case 'Audit Records':
        list.sort((a, b) => isAsc
            ? a.auditCount.compareTo(b.auditCount)
            : b.auditCount.compareTo(a.auditCount));
        break;
      default:
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

  // Detail Sorting & Matrix Items Access
  void sortDetailBy(String columnKey) {
    final key = columnKey.toLowerCase();
    if (detailSortColumn.value == key) {
      detailSortAscending.value = !detailSortAscending.value;
    } else {
      detailSortColumn.value = key;
      detailSortAscending.value = true;
    }
  }

  List<AuditMatrixItem> get sortedMatrixItems {
    final matrix = selectedAuditDetail.value?.matrix;
    if (matrix == null || matrix.isEmpty) return [];

    final list = List<AuditMatrixItem>.from(matrix);
    final q = detailSearchQuery.value.trim().toLowerCase();
    final filtered = q.isEmpty
        ? list
        : list.where((m) =>
            m.name.toLowerCase().contains(q) ||
            m.category.toLowerCase().contains(q) ||
            m.unit.toLowerCase().contains(q)).toList();

    final activeColumn = detailSortColumn.value;
    final isAsc = detailSortAscending.value;

    filtered.sort((a, b) {
      int cmp = 0;
      switch (activeColumn) {
        case 'item':
          cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case 'category':
          cmp = a.category.toLowerCase().compareTo(b.category.toLowerCase());
          break;
        case 'unit':
        case 'measurement unit':
          cmp = a.unit.toLowerCase().compareTo(b.unit.toLowerCase());
          break;
        case 'slno':
        default:
          cmp = a.itemId.compareTo(b.itemId);
          break;
      }
      return isAsc ? cmp : -cmp;
    });

    return filtered;
  }

  // Excel Export
  Future<void> exportDetailToExcel() async {
    final detail = selectedAuditDetail.value;
    if (detail == null) return;

    isExporting.value = true;
    try {
      final unitList = detail.unitList;

      // Build header row
      final headers = <String>[
        'SI No',
        'Item',
        'Category',
        'Measurement Unit',
      ];

      for (var u in unitList) {
        headers.addAll([
          '${u.unitName} System Qty',
          '${u.unitName} Actual Qty',
          '${u.unitName} Difference',
          '${u.unitName} Result',
        ]);
      }

      headers.addAll([
        'Total System Qty',
        'Total Actual Qty',
        'Total Difference',
        'Overall Result',
      ]);

      // Build data rows
      final rows = detail.matrix.asMap().entries.map((e) {
        final idx = e.key + 1;
        final item = e.value;

        final row = <dynamic>[
          idx,
          item.name,
          item.category,
          item.unit,
        ];

        for (var u in unitList) {
          final cell = item.cells[u.auditId.toString()] ??
              item.cells[u.id.toString()] ??
              item.cells[u.unitId.toString()];
          row.addAll([
            cell?.system ?? 0,
            cell?.actual ?? 0,
            cell?.diff ?? 0,
            cell?.result ?? '-',
          ]);
        }

        row.addAll([
          item.overallTotal.system,
          item.overallTotal.actual,
          item.overallTotal.diff,
          item.overallTotal.result,
        ]);

        return row;
      }).toList();

      final title = 'Audit_Comparison_${detail.auditNumber}_${detail.dateDisplay}';

      await AppExportUtils.exportToExcel(
        title: title,
        columns: headers,
        rows: rows,
      );
    } catch (e) {
      debugPrint('exportDetailToExcel error: $e');
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
    currentPage.value = 1;
    fetchAuditReport(page: 1);
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      final next = currentPage.value + 1;
      fetchAuditReport(page: next);
    }
  }

  void prevPage() {
    if (currentPage.value > 1) {
      final prev = currentPage.value - 1;
      fetchAuditReport(page: prev);
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value && page != currentPage.value) {
      fetchAuditReport(page: page);
    }
  }
  // endregion
}
// endregion
