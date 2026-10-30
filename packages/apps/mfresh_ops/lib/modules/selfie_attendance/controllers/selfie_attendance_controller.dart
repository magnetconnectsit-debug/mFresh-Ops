// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mfresh_ops/data/models/assignee_model.dart';
import 'package:mfresh_ops/data/models/selfie_attendance/selfie_attendance_report_model.dart';
import 'package:mfresh_ops/data/models/booking/unit_model.dart';
import 'package:mfresh_ops/data/repositories/booking_repository.dart';
import 'package:mfresh_ops/data/repositories/common_repository.dart';
import 'package:mfresh_ops/data/repositories/selfie_attendance_repository.dart';
import 'package:mfresh_ops/data/repositories/support_repository.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
// endregion

// region Controller
class SelfieAttendanceController extends GetxController {
  // region Dependencies & Repositories
  final SelfieAttendanceRepository _repository =
      Get.isRegistered<SelfieAttendanceRepository>()
          ? Get.find<SelfieAttendanceRepository>()
          : Get.put(SelfieAttendanceRepository());

  final BookingRepository _bookingRepository =
      Get.isRegistered<BookingRepository>()
          ? Get.find<BookingRepository>()
          : Get.put(BookingRepository());

  final CommonRepository _commonRepository =
      Get.isRegistered<CommonRepository>()
          ? Get.find<CommonRepository>()
          : Get.put(CommonRepository());
  // endregion

  // region Observables & State Variables
  final isLoading = false.obs;
  final isLoadingFilters = false.obs;
  final items = <SelfieAttendanceItem>[].obs;
  final totalRecords = 0.obs;
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final perPage = 25.obs;
  final fromIndex = 1.obs;
  final toIndex = 0.obs;

  // Filter States
  final fromDate = RxnString();
  final toDate = RxnString();
  final dateRangeText = 'Select From - To Date'.obs;
  final selectedUserIds = <int>{}.obs;
  final selectedUnitIds = <int>{}.obs;
  final globalSearch = ''.obs;

  // Filter Options
  final usersList = <AssigneeModel>[].obs;
  final unitsList = <UnitModel>[].obs;

  // Table Sorting
  final sortColumn = ''.obs;
  final sortAscending = true.obs;
  // endregion

  // region Text Controllers & Focus Nodes
  final searchController = TextEditingController();
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    loadFilterOptions();
    fetchReport(page: 1);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
  // endregion

  // region API & Network Operations
  Future<void> loadFilterOptions() async {
    isLoadingFilters.value = true;
    try {
      final assigneesFuture = _commonRepository
          .getAllAssignees()
          .catchError((_) => <AssigneeModel>[]);
      final unitsFuture =
          _bookingRepository.getAllUnits().catchError((_) => <UnitModel>[]);

      final results = await Future.wait([assigneesFuture, unitsFuture]);

      usersList.assignAll(results[0] as List<AssigneeModel>);
      var units = results[1] as List<UnitModel>;
      if (units.isEmpty) {
        try {
          final supportRepo = Get.isRegistered<SupportRepository>()
              ? Get.find<SupportRepository>()
              : Get.put(SupportRepository());
          final supportUnits = await supportRepo.getSupportUnits();
          if (supportUnits.isNotEmpty) {
            units = supportUnits
                .map((s) => UnitModel(
                      id: s.unitId,
                      unitId: s.unitName.isNotEmpty
                          ? s.unitName
                          : 'Unit #${s.unitId}',
                      unitImage: s.unitImage,
                      unitLocation: s.unitShortform,
                      timing: '',
                    ))
                .toList();
          }
        } catch (_) {}
      }
      unitsList.assignAll(units);
    } catch (e) {
      debugPrint('SelfieAttendanceController.loadFilterOptions Error: $e');
    } finally {
      isLoadingFilters.value = false;
    }
  }

  Future<void> fetchReport({int? page}) async {
    isLoading.value = true;
    try {
      final targetPage = page ?? currentPage.value;
      final response = await _repository.getReport(
        fromDate: fromDate.value ?? '',
        toDate: toDate.value ?? '',
        unitIds: selectedUnitIds.toList(),
        userIds: selectedUserIds.toList(),
        globalSearch: globalSearch.value.trim(),
        page: targetPage,
      );

      if (response != null && response.status && response.data != null) {
        final data = response.data!;
        currentPage.value = data.currentPage;
        totalRecords.value = data.total;
        perPage.value = data.perPage;
        lastPage.value = data.lastPage;
        fromIndex.value = data.from ?? ((targetPage - 1) * data.perPage + 1);
        toIndex.value = data.to ?? (fromIndex.value + data.items.length - 1);
        items.assignAll(data.items);
      } else {
        items.clear();
        totalRecords.value = 0;
      }
    } catch (e) {
      debugPrint('SelfieAttendanceController.fetchReport Error: $e');
      AppCommonToastMessage.show(
        message: e.toString().replaceFirst('Exception: ', ''),
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
  // endregion

  // region Business Logic & Helpers
  Future<void> pickDateRange(BuildContext context) async {
    DateTime? initStart;
    DateTime? initEnd;

    if (fromDate.value != null && fromDate.value!.isNotEmpty) {
      initStart = DateTime.tryParse(fromDate.value!);
    }
    if (toDate.value != null && toDate.value!.isNotEmpty) {
      initEnd = DateTime.tryParse(toDate.value!);
    }

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: initStart != null && initEnd != null
          ? DateTimeRange(start: initStart, end: initEnd)
          : null,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.white,
            onSurface: AppColors.black,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      final formatter = DateFormat('yyyy-MM-dd');
      final displayFormatter = DateFormat('dd-MMM-yyyy');
      fromDate.value = formatter.format(picked.start);
      toDate.value = formatter.format(picked.end);
      dateRangeText.value =
          '${displayFormatter.format(picked.start)} - ${displayFormatter.format(picked.end)}';
      applyFilters();
    }
  }

  void clearDateRange() {
    fromDate.value = null;
    toDate.value = null;
    dateRangeText.value = 'Select From - To Date';
    applyFilters();
  }

  void applyFilters() {
    currentPage.value = 1;
    fetchReport(page: 1);
  }

  void resetFilters() {
    fromDate.value = null;
    toDate.value = null;
    dateRangeText.value = 'Select From - To Date';
    selectedUserIds.clear();
    selectedUnitIds.clear();
    globalSearch.value = '';
    searchController.clear();
    applyFilters();
  }

  void onUserSelectionChanged(Set<int> userIds) {
    selectedUserIds.assignAll(userIds);
    applyFilters();
  }

  void onUnitSelectionChanged(Set<int> unitIds) {
    selectedUnitIds.assignAll(unitIds);
    applyFilters();
  }

  void goToPage(int page) {
    if (page >= 1 && page <= lastPage.value && page != currentPage.value) {
      currentPage.value = page;
      fetchReport(page: page);
    }
  }

  void nextPage() {
    if (currentPage.value < lastPage.value) {
      goToPage(currentPage.value + 1);
    }
  }

  void prevPage() {
    if (currentPage.value > 1) {
      goToPage(currentPage.value - 1);
    }
  }

  void sortBy(String column) {
    if (sortColumn.value == column) {
      sortAscending.value = !sortAscending.value;
    } else {
      sortColumn.value = column;
      sortAscending.value = true;
    }

    final ascending = sortAscending.value;
    items.sort((a, b) {
      switch (column) {
        case 'employee':
          return ascending
              ? a.userName.compareTo(b.userName)
              : b.userName.compareTo(a.userName);
        case 'date':
          return ascending
              ? a.dateIso.compareTo(b.dateIso)
              : b.dateIso.compareTo(a.dateIso);
        case 'unit':
          return ascending
              ? a.units.compareTo(b.units)
              : b.units.compareTo(a.units);
        case 'first_in':
          return ascending
              ? a.firstIn.compareTo(b.firstIn)
              : b.firstIn.compareTo(a.firstIn);
        case 'last_out':
          return ascending
              ? a.lastOut.compareTo(b.lastOut)
              : b.lastOut.compareTo(a.lastOut);
        case 'total_duration':
          return ascending
              ? (a.totalDurationSeconds ?? 0)
                  .compareTo(b.totalDurationSeconds ?? 0)
              : (b.totalDurationSeconds ?? 0)
                  .compareTo(a.totalDurationSeconds ?? 0);
        case 'break':
          return ascending
              ? (a.breakSeconds ?? 0).compareTo(b.breakSeconds ?? 0)
              : (b.breakSeconds ?? 0).compareTo(a.breakSeconds ?? 0);
        case 'actual_duration':
          return ascending
              ? (a.actualDurationSeconds ?? 0)
                  .compareTo(b.actualDurationSeconds ?? 0)
              : (b.actualDurationSeconds ?? 0)
                  .compareTo(a.actualDurationSeconds ?? 0);
        case 'sessions':
          return ascending
              ? a.totalSessions.compareTo(b.totalSessions)
              : b.totalSessions.compareTo(a.totalSessions);
        default:
          return 0;
      }
    });
  }

  void openDetail(SelfieAttendanceItem item) {
    Get.toNamed(
      AppRoutes.selfieAttendanceDetail,
      arguments: {
        'user_id': item.userId,
        'user_name': item.userName,
        'date': item.date,
        'date_iso': item.dateIso,
        'units': item.units,
      },
    );
  }
  // endregion
}
// endregion
