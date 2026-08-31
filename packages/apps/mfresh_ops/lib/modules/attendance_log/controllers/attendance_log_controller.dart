import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mfresh_ops/data/models/tracking/attendance_log_model.dart';
import 'package:mfresh_ops/data/models/tracking/attendance_breakdown_model.dart';
import 'package:mfresh_ops/data/repositories/tracking_repository.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/routes/app_routes.dart';

class AttendanceLogController extends GetxController {
  final TrackingRepository _repository = Get.find<TrackingRepository>();

  final RxBool isLoadingEmployees = true.obs;
  final RxList<Map<String, dynamic>> allEmployees = <Map<String, dynamic>>[].obs;
  
  final RxSet<int> selectedEmployeeIds = <int>{}.obs;
  final RxSet<int> expandedRows = <int>{}.obs;

  final RxString sortColumn = ''.obs;
  final RxBool sortAscending = true.obs;

  final RxString startDate = ''.obs;
  final RxString endDate = ''.obs;

  final RxBool isLoadingData = false.obs;
  final Rx<AttendanceLogResponse?> responseData = Rx<AttendanceLogResponse?>(null);


  // Breakdown Dialog State
  final RxBool isLoadingBreakdown = false.obs;
  final Rx<AttendanceBreakdownResponse?> breakdownData = Rx<AttendanceBreakdownResponse?>(null);
  final RxString selectedBreakdownFilter = 'All'.obs;
  
  List<BreakdownTimeline> get filteredTimeline {
    final timeline = breakdownData.value?.timeline ?? [];
    if (selectedBreakdownFilter.value == 'All') return timeline;
    return timeline.where((t) => t.type.toLowerCase() == selectedBreakdownFilter.value.toLowerCase()).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _setDefaultDates();
    fetchEmployees();
  }

  void _setDefaultDates() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    
    startDate.value = formatter.format(firstDayOfMonth);
    endDate.value = formatter.format(now);
  }

  Future<void> fetchEmployees() async {
    isLoadingEmployees.value = true;
    try {
      final response = await _repository.getCurrentStatus();
      if (response != null && response['status'] == true) {
        final List emps = response['employees'] ?? [];
        allEmployees.value = emps.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        AppCommonToastMessage.show(
          message: response['message'] ?? 'Failed to load staff',
          type: ToastType.error,
        );
      }
    } catch (e) {
      debugPrint('Error fetching employees: $e');
      AppCommonToastMessage.show(
        message: 'Failed to load staff list',
        type: ToastType.error,
      );
    } finally {
      isLoadingEmployees.value = false;
    }
  }

  Future<void> fetchAttendanceLog() async {
    if (selectedEmployeeIds.isEmpty) {
      responseData.value = null;
      AppCommonToastMessage.show(
        message: 'Please select at least one employee',
        type: ToastType.error,
      );
      return;
    }

    isLoadingData.value = true;
    responseData.value = null;

    try {
      final request = {
        "employee_id": selectedEmployeeIds.toList(),
        "from_date": startDate.value,
        "to_date": endDate.value,
      };

      final result = await _repository.getAttendanceLog(request);

      if (result != null && result['status'] == true) {
        responseData.value = AttendanceLogResponse.fromJson(result);
      } else {
        AppCommonToastMessage.show(
          message: result['message'] ?? 'Failed to fetch attendance log',
          type: ToastType.error,
        );
      }
    } catch (e) {
      debugPrint('Error fetching attendance log: $e');
      AppCommonToastMessage.show(
        message: 'Failed to load attendance data',
        type: ToastType.error,
      );
    } finally {
      isLoadingData.value = false;
    }
  }

  List<AttendanceRow> get sortedRows {
    final rows = responseData.value?.rows ?? [];
    if (sortColumn.value.isEmpty) return rows;

    final col = sortColumn.value;
    final asc = sortAscending.value;

    int compare(String a, String b) {
      final dateA = DateTime.tryParse(a);
      final dateB = DateTime.tryParse(b);
      if (dateA != null && dateB != null) {
        return asc ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      }
      return asc ? a.compareTo(b) : b.compareTo(a);
    }

    final sorted = [...rows];
    sorted.sort((a, b) {
      switch (col) {
        case 'Date':                  return compare(a.rawDate, b.rawDate);
        case 'Day':                   return compare(a.day, b.day);
        case 'Employee Name':         return compare(a.employeeName, b.employeeName);
        case 'Shift Start':           return compare(a.shiftStart, b.shiftStart);
        case 'Shift End':             return compare(a.shiftEnd, b.shiftEnd);
        case 'Duration':              return compare(a.shiftDuration, b.shiftDuration);
        case 'Shift Location':        return compare(a.shiftLocation, b.shiftLocation);
        case 'Live In (First)':       return compare(a.liveIn, b.liveIn);
        case 'Live Out (Last)':       return compare(a.liveOut, b.liveOut);
        case 'Live (Total)':          return compare(a.liveTotal, b.liveTotal);
        case 'Live (Shift)':          return compare(a.liveShift, b.liveShift);
        case 'Duty Shortage':         return compare(a.dutyShortage, b.dutyShortage);
        case 'Late For (Duration)':   return compare(a.lateDuration, b.lateDuration);
        case 'Actual Location':       return compare(a.actualLocation, b.actualLocation);
        case 'Location\nmismatch':    return compare(a.locationMismatch, b.locationMismatch);
        case 'Status':                return compare(a.attendanceStatus, b.attendanceStatus);
        default: return 0;
      }
    });
    return sorted;
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

  Future<void> fetchAttendanceBreakdown(int employeeId, String date, String employeeName) async {
    isLoadingBreakdown.value = true;
    breakdownData.value = null;
    selectedBreakdownFilter.value = 'All';
    
    Get.toNamed(
      AppRoutes.attendanceBreakdown,
      arguments: {'employeeName': employeeName, 'date': date},
    );

    try {
      final request = {
        "employee_id": employeeId,
        "date": date,
      };

      final result = await _repository.getAttendanceBreakdown(request);

      if (result != null && result['status'] == true) {
        breakdownData.value = AttendanceBreakdownResponse.fromJson(result);
      } else {
        Get.back(); // close dialog on error
        AppCommonToastMessage.show(
          message: result['message'] ?? 'Failed to fetch attendance breakdown',
          type: ToastType.error,
        );
      }
    } catch (e) {
      debugPrint('Error fetching attendance breakdown: $e');
      Get.back(); // close dialog on error
      AppCommonToastMessage.show(
        message: 'Failed to load breakdown data',
        type: ToastType.error,
      );
    } finally {
      isLoadingBreakdown.value = false;
    }
  }

  Future<void> showCustomDateRangePicker() async {
    final context = Get.context;
    if (context == null) return;

    final initialStart = startDate.value.isNotEmpty ? DateTime.tryParse(startDate.value) : null;
    final initialEnd = endDate.value.isNotEmpty ? DateTime.tryParse(endDate.value) : null;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: initialStart != null && initialEnd != null
          ? DateTimeRange(start: initialStart, end: initialEnd)
          : null,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFE84C3D),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      startDate.value = formatter.format(picked.start);
      endDate.value = formatter.format(picked.end);
      fetchAttendanceLog();
    }
  }
}
