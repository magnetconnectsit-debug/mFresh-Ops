import 'package:core/core.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/data/repositories/dashboard_repository.dart';
import 'package:mfresh_ops/data/repositories/support_repository.dart';
import 'package:mfresh_ops/data/models/revenue_report/dashboard_data_model.dart';
import 'package:mfresh_ops/data/models/revenue_report/comparison_model.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repository = Get.put(DashboardRepository());
  final SupportRepository _supportRepository = Get.find<SupportRepository>();

  final rxIsLoading = false.obs;
  final rxDashboardData = Rxn<DashboardDataModel>();

  // Filters
  final rxDateFilter = RxnString('today');
  final rxStartDate = RxnString();
  final rxEndDate = RxnString();
  final rxPaymentMode = RxnString();
  final rxSelectedUnitIds = <String>{}.obs;
  final rxMonthFilter = RxnString();
  final rxFromMonth = RxnString();
  final rxToMonth = RxnString();
  final rxGrowthFilter = RxnString();

  final rxClearTooltipsTrigger = 0.obs;

  final units = <SupportUnit>[].obs;

  // ── Comparison tab ──
  final rxDashboardTab = 0.obs; // 0 = Revenue, 1 = Comparison
  final rxComparisonIsLoading = false.obs;
  final rxComparisonResult = Rxn<ComparisonResponse>();

  // Up to 4 comparison slots (Data A–D)
  static const int maxComparisonSlots = 3;
  final comparisonSlots = List.generate(
    maxComparisonSlots,
    (_) => ComparisonSlot(),
  ).obs;

  @override
  void onInit() {
    super.onInit();
    fetchUnits();
    fetchDashboardData();
  }

  Future<void> fetchUnits() async {
    try {
      final result = await _supportRepository.getSupportUnits();
      units.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching units in dashboard: $e');
    }
  }

  Future<void> fetchComparisonData() async {
    final filledSlots = comparisonSlots.where((s) => s.isComplete).toList();
    if (filledSlots.isEmpty) {
      AppCommonToastMessage.show(
        message: 'Please fill at least one comparison slot completely.',
        type: ToastType.warning,
      );
      return;
    }
    try {
      rxComparisonIsLoading.value = true;
      final payload = filledSlots.map((s) => s.toPayload()).toList();
      final response = await _repository.getComparisonData(payload);
      if (response != null) {
        rxComparisonResult.value = ComparisonResponse.fromJson(
          Map<String, dynamic>.from(response as Map),
        );
      }
    } catch (e) {
      debugPrint('Error fetching comparison data: $e');
      AppCommonToastMessage.show(
        message: 'Failed to load comparison data.',
        type: ToastType.error,
      );
    } finally {
      rxComparisonIsLoading.value = false;
    }
  }


  Future<void> pullToRefresh() async {
    // A swipe-to-refresh should reload the dashboard and clear all filters.
    await resetFilters();
  }

  Future<void> resetFilters() async {
    rxDateFilter.value = null;
    rxStartDate.value = null;
    rxEndDate.value = null;
    rxPaymentMode.value = null;
    rxSelectedUnitIds.clear();
    rxMonthFilter.value = null;
    rxFromMonth.value = null;
    rxToMonth.value = null;
    rxGrowthFilter.value = null;

    // Explicitly notify the filter UI before loading the unfiltered dashboard.
    // This clears any highlighted date/month tile immediately on pull-to-refresh.
    rxDateFilter.refresh();
    rxStartDate.refresh();
    rxEndDate.refresh();
    rxPaymentMode.refresh();
    rxSelectedUnitIds.refresh();
    rxMonthFilter.refresh();
    rxFromMonth.refresh();
    rxToMonth.refresh();
    rxGrowthFilter.refresh();

    await fetchDashboardData();
  }

  String? _formatMonthForApi(String? month) {
    if (month == null || month.isEmpty) return null;
    try {
      // If already in yyyy-MM format, return as is
      if (RegExp(r'^\d{4}-\d{2}$').hasMatch(month)) return month;
      
      final parsed = DateFormat('MMM-yyyy').parse(month);
      return DateFormat('yyyy-MM').format(parsed);
    } catch (e) {
      debugPrint('Error formatting month for API: $e');
      return month;
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      rxIsLoading.value = true;
      final filters = <String, dynamic>{
        'date_filter': rxDateFilter.value,
        'startDate': rxStartDate.value,
        'endDate': rxEndDate.value,
        'payment_mode': rxPaymentMode.value != null ? int.tryParse(rxPaymentMode.value!) : null,
        'selectedUnitId': rxSelectedUnitIds.isEmpty
            ? null
            : rxSelectedUnitIds.join(','),
        'month_filter': rxMonthFilter.value,
        'fromMonth': _formatMonthForApi(rxFromMonth.value),
        'toMonth': _formatMonthForApi(rxToMonth.value),
        'growth_filter': rxGrowthFilter.value,
      };

      // Remove null entries so the server doesn't get confused
      filters.removeWhere((key, value) => value == null);

      debugPrint('Dashboard filters payload: $filters');

      final response = await _repository.getDashboardData(filters);

      if (response != null &&
          response['status'] == true &&
          response['data'] != null) {
        rxDashboardData.value = DashboardDataModel.fromJson(response['data']);
      } else {
        debugPrint('Failed to fetch dashboard data: ${response['message']}');
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to load dashboard',
          backgroundColor: Colors.red.withAlpha(204),
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching dashboard data: $e\n$stackTrace');
      Get.snackbar(
        'Error',
        'An unexpected error occurred while loading dashboard.',
        backgroundColor: Colors.red.withAlpha(204),
        colorText: Colors.white,
      );
    } finally {
      rxIsLoading.value = false;
    }
  }

  void setDateFilter(String? filter) {
    // Toggle off if same filter tapped again
    if (filter != null && rxDateFilter.value == filter) {
      rxDateFilter.value = null;
    } else {
      rxDateFilter.value = filter;
    }
    rxStartDate.value = null;
    rxEndDate.value = null;
    rxMonthFilter.value = null;
    rxFromMonth.value = null;
    rxToMonth.value = null;
    rxGrowthFilter.value = null;
    fetchDashboardData();
  }

  void setCustomFromMonth(String? month) {
    rxFromMonth.value = month;
    if (month != null) {
      rxDateFilter.value = null;
      rxStartDate.value = null;
      rxEndDate.value = null;
      rxMonthFilter.value = null;
      rxGrowthFilter.value = null;
    }
    fetchDashboardData();
  }

  void setCustomToMonth(String? month) {
    rxToMonth.value = month;
    if (month != null) {
      rxDateFilter.value = null;
      rxStartDate.value = null;
      rxEndDate.value = null;
      rxMonthFilter.value = null;
      rxGrowthFilter.value = null;
    }
    fetchDashboardData();
  }

  void setMonthFilter(String? filter) {
    // Toggle off if same filter tapped again
    if (filter != null && rxMonthFilter.value == filter) {
      rxMonthFilter.value = null;
    } else {
      rxMonthFilter.value = filter;
    }
    rxDateFilter.value = null;
    rxStartDate.value = null;
    rxEndDate.value = null;
    rxFromMonth.value = null;
    rxToMonth.value = null;
    rxGrowthFilter.value = null;
    fetchDashboardData();
  }

  void setGrowthFilter(String? filter) {

    // Toggle off if same filter tapped again
    if (filter != null && rxGrowthFilter.value == filter) {
      rxGrowthFilter.value = null;
    } else {
      rxGrowthFilter.value = filter;
    }
    rxDateFilter.value = null;
    rxStartDate.value = null;
    rxEndDate.value = null;
    rxMonthFilter.value = null;
    rxFromMonth.value = null;
    rxToMonth.value = null;
    fetchDashboardData();
  }

  void setPaymentMode(String mode) {
    // Toggle off if same mode tapped again
    if (rxPaymentMode.value == mode) {
      rxPaymentMode.value = null;
    } else {
      rxPaymentMode.value = mode;
    }
    fetchDashboardData();
  }

  void clearPaymentMode() {
    rxPaymentMode.value = null;
    fetchDashboardData();
  }

  void setUnitFilters(Set<String> unitIds) {
    rxSelectedUnitIds.assignAll(unitIds);
    fetchDashboardData();
  }

  void clearCustomDateFilter() {
    rxStartDate.value = null;
    rxEndDate.value = null;
    fetchDashboardData();
  }

  Future<void> showCustomDateRangePicker() async {
    final context = Get.context;
    if (context == null) return;

    DateTime? selectedStart;
    DateTime? selectedEnd;

    await Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            backgroundColor: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Date Range',
                    style: AppTextStyle.style_16_700(color: AppColors.primary),
                  ),
                  SizedBox(height: 20.h),

                  // From Date
                  Text(
                    'From',
                    style: AppTextStyle.style_12_500(color: AppColors.grey700),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      // From Date Picker
                      Expanded(
                        flex: 3,
                        child: InkWell(
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedStart ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                              builder: (context, child) => Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFFE84C3D),
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                final time = selectedStart != null
                                    ? TimeOfDay.fromDateTime(selectedStart!)
                                    : const TimeOfDay(hour: 0, minute: 0);
                                selectedStart = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.grey300),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    selectedStart != null
                                        ? AppDateUtils.formatToOrdinalDate(
                                            selectedStart!.toIso8601String(),
                                          )
                                        : 'Date',
                                    style: AppTextStyle.style_12_400(
                                      color: AppColors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(
                                  Icons.calendar_today,
                                  size: 14.r,
                                  color: AppColors.grey500,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // From Time Picker
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: () async {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: selectedStart != null
                                  ? TimeOfDay.fromDateTime(selectedStart!)
                                  : const TimeOfDay(hour: 0, minute: 0),
                              builder: (context, child) => Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFFE84C3D),
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                final date = selectedStart ?? DateTime.now();
                                selectedStart = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.grey300),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    selectedStart != null
                                        ? "${selectedStart!.hour > 12 ? selectedStart!.hour - 12 : (selectedStart!.hour == 0 ? 12 : selectedStart!.hour).toString().padLeft(2, '0')}:${selectedStart!.minute.toString().padLeft(2, '0')} ${selectedStart!.hour >= 12 ? 'PM' : 'AM'}"
                                        : 'Time',
                                    style: AppTextStyle.style_12_400(
                                      color: AppColors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(
                                  Icons.access_time,
                                  size: 14.r,
                                  color: AppColors.grey500,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // To Date
                  Text(
                    'To',
                    style: AppTextStyle.style_12_500(color: AppColors.grey700),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      // To Date Picker
                      Expanded(
                        flex: 3,
                        child: InkWell(
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate:
                                  selectedEnd ??
                                  selectedStart ??
                                  DateTime.now(),
                              firstDate: selectedStart ?? DateTime(2020),
                              lastDate: DateTime(2030),
                              builder: (context, child) => Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFFE84C3D),
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                final time = selectedEnd != null
                                    ? TimeOfDay.fromDateTime(selectedEnd!)
                                    : const TimeOfDay(hour: 23, minute: 59);
                                selectedEnd = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.grey300),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    selectedEnd != null
                                        ? AppDateUtils.formatToOrdinalDate(
                                            selectedEnd!.toIso8601String(),
                                          )
                                        : 'Date',
                                    style: AppTextStyle.style_12_400(
                                      color: AppColors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(
                                  Icons.calendar_today,
                                  size: 14.r,
                                  color: AppColors.grey500,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // To Time Picker
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: () async {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: selectedEnd != null
                                  ? TimeOfDay.fromDateTime(selectedEnd!)
                                  : const TimeOfDay(hour: 23, minute: 59),
                              builder: (context, child) => Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFFE84C3D),
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                final date =
                                    selectedEnd ??
                                    selectedStart ??
                                    DateTime.now();
                                selectedEnd = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.grey300),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    selectedEnd != null
                                        ? "${selectedEnd!.hour > 12 ? selectedEnd!.hour - 12 : (selectedEnd!.hour == 0 ? 12 : selectedEnd!.hour).toString().padLeft(2, '0')}:${selectedEnd!.minute.toString().padLeft(2, '0')} ${selectedEnd!.hour >= 12 ? 'PM' : 'AM'}"
                                        : 'Time',
                                    style: AppTextStyle.style_12_400(
                                      color: AppColors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(
                                  Icons.access_time,
                                  size: 14.r,
                                  color: AppColors.grey500,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'Cancel',
                          style: AppTextStyle.style_14_500(
                            color: AppColors.grey500,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      ElevatedButton(
                        onPressed: () {
                          if (selectedStart != null && selectedEnd != null) {
                            Get.back(result: true);
                          } else {
                            Get.snackbar(
                              'Error',
                              'Please select both dates',
                              backgroundColor: Colors.red.withAlpha(200),
                              colorText: Colors.white,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Apply',
                          style: AppTextStyle.style_14_500(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).then((applied) {
      if (applied == true && selectedStart != null && selectedEnd != null) {
        final start = selectedStart!;
        final end = selectedEnd!;

        // Format to YYYY-MM-DD HH:MM using the precise selected hours and minutes
        final startStr =
            "${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')} ${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}";
        final endStr =
            "${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')} ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}";

        rxDateFilter.value = null;
        rxMonthFilter.value = null;
        rxFromMonth.value = null;
        rxToMonth.value = null;
        rxGrowthFilter.value = null;

        rxStartDate.value = startStr;
        rxEndDate.value = endStr;
        fetchDashboardData();
      }
    });
  }
}
