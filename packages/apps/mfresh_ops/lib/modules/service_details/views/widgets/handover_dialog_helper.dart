// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/assignee_model.dart';
import 'package:mfresh_ops/data/models/booking/booking_models.dart';
import 'package:mfresh_ops/data/repositories/booking_repository.dart';
import 'package:mfresh_ops/data/repositories/common_repository.dart';
import 'package:mfresh_ops/modules/booking/controllers/booking_unit_selection_controller.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:pinput/pinput.dart';
// endregion

// region Handover Dialog Helper
class HandoverDialogHelper {
  HandoverDialogHelper._();

  // region Main Handover Dialog
  static void showHandoverDialog({
    required BuildContext context,
    required String unitNo,
    int? cashierSessionId,
    VoidCallback? onSuccess,
  }) {
    final bookingRepo = Get.find<BookingRepository>();
    if (!Get.isRegistered<CommonRepository>()) {
      Get.put(CommonRepository());
    }

    final isCtodTab = false.obs; // false = Handover Cash, true = Cash C TO D
    final isLoading = false.obs;
    final isSubmitting = false.obs;

    // Overview data
    final activeDateText = AppDateUtils.formatToShortOrdinalDate(DateTime.now()).obs;
    final receivedHandovers = <ReceivedCashEntry>[].obs;
    final totalReceivedCash = 0.0.obs;
    final collectionGroups = <HandoverCollectionGroup>[].obs;
    final cashDue = 0.0.obs;
    final cashBalance = 0.0.obs;

    // User options
    final handoverUserList = <AssigneeModel>[].obs;
    final ctodUserList = <AssigneeModel>[].obs;
    final selectedUser = Rxn<AssigneeModel>();

    // Handover Cash tab: Date-wise own cash controllers
    final ownCashControllers = <String, TextEditingController>{};
    final handoverTotalGiven = 0.0.obs;

    double calculateHandoverTotal() {
      double sum = totalReceivedCash.value;
      for (var group in collectionGroups) {
        if (group.hasOwnBookingCash) {
          final c = ownCashControllers[group.date];
          if (c != null) {
            final val = double.tryParse(c.text.trim()) ?? 0.0;
            sum += val;
          }
        }
      }
      return sum;
    }

    // Cash C TO D tab
    final ctodDateEntries = <CtodDateEntryModel>[].obs;
    final allCtodDateEntries = <CtodDateEntryModel>[].obs;
    final ctodAmountControllers = <String, TextEditingController>{};
    final dateRangeController = TextEditingController();
    final selectedDateRange = Rxn<DateTimeRange>();

    double calculateCtodTotal() {
      double sum = 0.0;
      for (var entry in ctodDateEntries) {
        final controller = ctodAmountControllers[entry.date];
        if (controller != null) {
          final val = double.tryParse(controller.text.trim()) ?? 0.0;
          sum += val;
        }
      }
      return sum;
    }

    final ctodTotalGiven = 0.0.obs;

    void filterCtodEntries() {
      if (selectedDateRange.value == null) {
        ctodDateEntries.assignAll(allCtodDateEntries);
      } else {
        final start = DateTime(
          selectedDateRange.value!.start.year,
          selectedDateRange.value!.start.month,
          selectedDateRange.value!.start.day,
        );

        final generatedDates = <String>[];
        var curr = start;
        while (!curr.isAfter(selectedDateRange.value!.end)) {
          final y = curr.year.toString();
          final m = curr.month.toString().padLeft(2, '0');
          final d = curr.day.toString().padLeft(2, '0');
          generatedDates.add('$y-$m-$d');
          curr = curr.add(const Duration(days: 1));
        }

        final existingMap = {
          for (var e in allCtodDateEntries) e.date.trim(): e,
        };

        final List<CtodDateEntryModel> merged = [];
        for (final dateStr in generatedDates) {
          if (existingMap.containsKey(dateStr)) {
            merged.add(existingMap[dateStr]!);
          } else {
            final matched = allCtodDateEntries.firstWhereOrNull((e) {
              final parsed = DateTime.tryParse(e.date);
              if (parsed != null) {
                return parsed.year == int.parse(dateStr.substring(0, 4)) &&
                    parsed.month == int.parse(dateStr.substring(5, 7)) &&
                    parsed.day == int.parse(dateStr.substring(8, 10));
              }
              return false;
            });
            if (matched != null) {
              merged.add(matched);
            } else {
              merged.add(
                CtodDateEntryModel(
                  date: dateStr,
                  bookingCash: 0,
                  completedCtod: 0,
                  pendingCtod: 0,
                  remainingAmount: 0,
                  collectionActual: 0,
                ),
              );
            }
          }
        }

        ctodDateEntries.assignAll(merged);

        for (var entry in merged) {
          if (!ctodAmountControllers.containsKey(entry.date)) {
            final c = TextEditingController();
            c.addListener(() {
              ctodTotalGiven.value = calculateCtodTotal();
            });
            ctodAmountControllers[entry.date] = c;
          }
        }
      }
      ctodTotalGiven.value = calculateCtodTotal();
    }

    // Load initial user list, overview & C-to-D dates
    Future<void> loadInitialData() async {
      try {
        isLoading.value = true;
        selectedDateRange.value = null;
        dateRangeController.text = '';

        final results = await Future.wait([
          bookingRepo.getHandoverUsers(),
          bookingRepo.getCtodDates(
            unitId: unitNo,
            sessionId: cashierSessionId,
          ),
          bookingRepo.getHandoverOverview(
            unitId: unitNo,
            sessionId: cashierSessionId,
          ),
        ]);

        final usersResult = results[0] as HandoverUsersResult;
        handoverUserList.assignAll(usersResult.handoverUsers);
        ctodUserList.assignAll(usersResult.ctodUsers);

        final ctodDates = results[1] as List<CtodDateEntryModel>;
        allCtodDateEntries.assignAll(ctodDates);
        ctodDateEntries.assignAll(ctodDates);

        for (var entry in ctodDates) {
          if (!ctodAmountControllers.containsKey(entry.date)) {
            final c = TextEditingController();
            c.addListener(() {
              ctodTotalGiven.value = calculateCtodTotal();
            });
            ctodAmountControllers[entry.date] = c;
          }
        }

        final overview = results[2] as HandoverOverviewResult;
        cashDue.value = overview.cashDue;
        cashBalance.value = overview.cashBalance;
        activeDateText.value = AppDateUtils.formatToShortOrdinalDate(overview.activeDate);
        receivedHandovers.assignAll(overview.receivedHandovers);
        totalReceivedCash.value = overview.totalReceivedCash;
        for (var group in overview.collectionGroups) {
          if (group.hasOwnBookingCash) {
            if (!ownCashControllers.containsKey(group.date)) {
              final c = TextEditingController();
              c.addListener(() {
                handoverTotalGiven.value = calculateHandoverTotal();
              });
              ownCashControllers[group.date] = c;
            }
          }
        }
        collectionGroups.assignAll(overview.collectionGroups);
        handoverTotalGiven.value = calculateHandoverTotal();

        if (overview.receivers.isNotEmpty) {
          final existingIds = handoverUserList.map((u) => u.id).toSet();
          for (var r in overview.receivers) {
            if (!existingIds.contains(r.id)) {
              handoverUserList.add(r);
            }
          }
        }

        if (overview.ctodUsers.isNotEmpty) {
          final existingIds = ctodUserList.map((u) => u.id).toSet();
          for (var r in overview.ctodUsers) {
            if (!existingIds.contains(r.id)) {
              ctodUserList.add(r);
            }
          }
        }
      } catch (e) {
        debugPrint('Error loading handover initial data: $e');
      } finally {
        isLoading.value = false;
      }
    }

    loadInitialData();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
        final dialogWidth = isTablet ? 640.w : 480.w;

        return Dialog(
          backgroundColor: AppColors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32.w : 16.w,
            vertical: isTablet ? 18.h : 12.h,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              maxHeight: MediaQuery.of(context).size.height * 0.92,
            ),
            child: Obx(() {
              if (isLoading.value) {
                return Container(
                  height: 200.h,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: const Center(child: CustomAppLoader(size: 32)),
                );
              }

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  isTablet ? 16.w : 12.w,
                  isTablet ? 12.h : 10.h,
                  isTablet ? 16.w : 12.w,
                  isTablet ? 12.h : 10.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row with Title and Close Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Handover Cash',
                          style: isTablet
                              ? AppTextStyle.style_15_700(
                                  color: const Color(0xFF1E293B),
                                )
                              : AppTextStyle.style_14_700(
                                  color: const Color(0xFF1E293B),
                                ),
                        ),
                        IconButton(
                          onPressed: () =>
                              Navigator.of(dialogCtx).pop(),
                          icon: Icon(
                            Icons.close,
                            size: isTablet ? 18.sp : 16.sp,
                            color: AppColors.grey500,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 10.h : 8.h),

                    // Clean Segmented Tabs (matches Web UI)
                    Container(
                      height: isTablet ? 30.h : 26.h,
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                if (isCtodTab.value) {
                                  isCtodTab.value = false;
                                  selectedUser.value = null;
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !isCtodTab.value
                                      ? AppColors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5.r),
                                  border: !isCtodTab.value
                                      ? Border.all(
                                          color: const Color(0xFFEA5455),
                                          width: 1.w,
                                        )
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Handover Cash',
                                  style: !isCtodTab.value
                                      ? (isTablet
                                          ? AppTextStyle.style_12_600(
                                              color: const Color(0xFFEA5455),
                                            )
                                          : AppTextStyle.style_11_700(
                                              color: const Color(0xFFEA5455),
                                            ))
                                      : (isTablet
                                          ? AppTextStyle.style_12_600(
                                              color: const Color(0xFF64748B),
                                            )
                                          : AppTextStyle.style_11_500(
                                              color: const Color(0xFF64748B),
                                            )),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                if (!isCtodTab.value) {
                                  isCtodTab.value = true;
                                  selectedUser.value = null;
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isCtodTab.value
                                      ? AppColors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5.r),
                                  border: isCtodTab.value
                                      ? Border.all(
                                          color: const Color(0xFFEA5455),
                                          width: 1.w,
                                        )
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Cash C TO D',
                                  style: isCtodTab.value
                                      ? (isTablet
                                          ? AppTextStyle.style_12_600(
                                              color: const Color(0xFFEA5455),
                                            )
                                          : AppTextStyle.style_11_700(
                                              color: const Color(0xFFEA5455),
                                            ))
                                      : (isTablet
                                          ? AppTextStyle.style_12_600(
                                              color: const Color(0xFF64748B),
                                            )
                                          : AppTextStyle.style_11_500(
                                              color: const Color(0xFF64748B),
                                            )),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isTablet ? 12.h : 10.h),

                    // Handover To (Choose User) Dropdown - Fixed at top, no clipping
                    Obx(() {
                      final currentUsers = isCtodTab.value
                          ? ctodUserList
                          : handoverUserList;
                      return AppCommonMultiSelectDropdown<AssigneeModel>(
                        label: 'Handover To',
                        hint: 'Choose User',
                        isSingleSelect: true,
                        selectedValues: selectedUser.value != null
                            ? {selectedUser.value!}
                            : {},
                        items: currentUsers.map((u) {
                          return DropdownMenuItem<AssigneeModel>(
                            value: u,
                            child: Text(
                              u.name,
                              style: isTablet
                                  ? AppTextStyle.style_12_400(
                                      color: AppColors.grey900,
                                    )
                                  : AppTextStyle.style_11_400(
                                      color: AppColors.grey900,
                                    ),
                            ),
                          );
                        }).toList(),
                        onChanged: (values) {
                          selectedUser.value = values.isNotEmpty
                              ? values.first
                              : null;
                        },
                      );
                    }),
                    SizedBox(height: isTablet ? 12.h : 10.h),

                    // Scrollable Collection List / Date Entries
                    Flexible(
                      child: SingleChildScrollView(
                        clipBehavior: Clip.none,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tab Specific Content
                            if (!isCtodTab.value) ...[
                              // Date-wise Collection Groups 
                              Obx(() {
                                if (collectionGroups.isEmpty) {
                                  return Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                      vertical: isTablet ? 10.h : 8.h,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'No collection records or pending handovers found.',
                                        style: isTablet
                                            ? AppTextStyle.style_12_400(
                                                color: AppColors.grey600,
                                              )
                                            : AppTextStyle.style_11_400(
                                                color: AppColors.grey600,
                                              ),
                                      ),
                                    ),
                                  );
                                }

                                return Column(
                                  children: collectionGroups.map((group) {
                                    return _buildCollectionGroupCard(
                                      group: group,
                                      controller:
                                          ownCashControllers[group.date],
                                      isTablet: isTablet,
                                    );
                                  }).toList(),
                                );
                              }),
                            ] else ...[
                              // Cash C TO D Tab: Sequential From & To Date pickers
                              GestureDetector(
                                onTap: () async {
                                  final now = DateTime.now();
                                  final today =
                                      DateTime(now.year, now.month, now.day);
                                  final initialFrom =
                                      selectedDateRange.value?.start ?? today;
                                  final fromDate = await showDatePicker(
                                    context: context,
                                    initialDate: initialFrom.isAfter(today)
                                        ? today
                                        : initialFrom,
                                    firstDate: DateTime(2020),
                                    lastDate: now.add(
                                      const Duration(days: 365),
                                    ),
                                    currentDate: today,
                                    helpText: 'Select From Date',
                                  );

                                  if (fromDate == null) return;
                                  if (!context.mounted) return;

                                  final initialTo =
                                      (selectedDateRange.value?.end != null &&
                                              !selectedDateRange.value!.end
                                                  .isBefore(fromDate))
                                          ? selectedDateRange.value!.end
                                          : (today.isBefore(fromDate)
                                              ? fromDate
                                              : today);

                                  final toDate = await showDatePicker(
                                    context: context,
                                    initialDate: initialTo.isBefore(fromDate)
                                        ? fromDate
                                        : initialTo,
                                    firstDate: fromDate,
                                    lastDate: now.add(
                                      const Duration(days: 365),
                                    ),
                                    currentDate: today,
                                    helpText: 'Select To Date',
                                  );

                                  if (toDate == null) return;

                                  final picked = DateTimeRange(
                                    start: fromDate,
                                    end: toDate,
                                  );
                                  selectedDateRange.value = picked;
                                  final sStr =
                                      '${picked.start.year}-${picked.start.month.toString().padLeft(2, '0')}-${picked.start.day.toString().padLeft(2, '0')}';
                                  final eStr =
                                      '${picked.end.year}-${picked.end.month.toString().padLeft(2, '0')}-${picked.end.day.toString().padLeft(2, '0')}';
                                  dateRangeController.text =
                                      AppDateUtils.formatDateRangeOrdinal(
                                        picked.start,
                                        picked.end,
                                      );
                                  filterCtodEntries();

                                  try {
                                    final remoteDates = await bookingRepo
                                        .getCtodDates(
                                          unitId: unitNo,
                                          sessionId: cashierSessionId,
                                          fromDate: sStr,
                                          toDate: eStr,
                                        );
                                    if (remoteDates.isNotEmpty) {
                                      for (final r in remoteDates) {
                                        allCtodDateEntries.removeWhere(
                                          (e) => e.date == r.date,
                                        );
                                        allCtodDateEntries.add(r);
                                      }
                                      filterCtodEntries();
                                    }
                                  } catch (_) {}
                                },
                                child: AbsorbPointer(
                                  child: AppCommonTextField(
                                    controller: dateRangeController,
                                    labelText: 'Collection Dates',
                                    hintText: 'Select date range',
                                    useFloatingLabel: true,
                                    suffixIcon: Icon(
                                      Icons.calendar_today_outlined,
                                      size: 14.sp,
                                      color: AppColors.grey500,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 2.h,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: isTablet ? 10.h : 8.h),

                              // Date entries cards
                              Obx(() {
                                if (ctodDateEntries.isEmpty) {
                                  return Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                      vertical: isTablet ? 10.h : 8.h,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'No collection records or pending handovers found.',
                                        style: isTablet
                                            ? AppTextStyle.style_12_400(
                                                color: AppColors.grey600,
                                              )
                                            : AppTextStyle.style_11_400(
                                                color: AppColors.grey600,
                                              ),
                                      ),
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: ctodDateEntries.length,
                                  separatorBuilder: (context, index) => Divider(
                                    color: AppColors.grey200,
                                    height: 6.h,
                                    thickness: 0.8,
                                  ),
                                  itemBuilder: (context, index) {
                                    final entry = ctodDateEntries[index];
                                    final c =
                                        ctodAmountControllers[entry.date]!;
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 2.h,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              AppDateUtils.formatToShortOrdinalDate(
                                                    entry.date,
                                                  ).isNotEmpty
                                                  ? AppDateUtils.formatToShortOrdinalDate(
                                                      entry.date,
                                                    )
                                                  : entry.date,
                                              style: isTablet
                                                  ? AppTextStyle.style_12_600(
                                                      color: AppColors.black,
                                                    )
                                                  : AppTextStyle.style_11_600(
                                                      color: AppColors.black,
                                                    ),
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          SizedBox(
                                            width: isTablet ? 120.w : 95.w,
                                            child: AppCommonTextField(
                                              controller: c,
                                              labelText: 'Amount',
                                              hintText: 'Enter amount',
                                              useFloatingLabel: true,
                                              keyboardType:
                                                  const TextInputType.numberWithOptions(
                                                    decimal: true,
                                                  ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(
                                                  RegExp(r'^\d+\.?\d{0,2}'),
                                                ),
                                              ],
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 8.w,
                                                    vertical: 2.h,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 12.h : 10.h),

                    // Total Physical Cash Given Card (Alice Blue) - Fixed at bottom
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 12.w : 10.w,
                        vertical: isTablet ? 6.h : 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F4FD),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(
                          color: const Color(0xFFB6D4FE),
                          width: 1.w,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Physical Cash Given',
                            style: isTablet
                                ? AppTextStyle.style_12_600(
                                    color: const Color(0xFF0D6EFD),
                                  )
                                : AppTextStyle.style_11_600(
                                    color: const Color(0xFF0D6EFD),
                                  ),
                          ),
                          Obx(() {
                            final totalVal = !isCtodTab.value
                                ? handoverTotalGiven.value
                                : ctodTotalGiven.value;
                            return Text(
                              '₹${totalVal.toStringAsFixed(2)}',
                              style: isTablet
                                  ? AppTextStyle.style_14_700(
                                      color: const Color(0xFF0D6EFD),
                                    )
                                  : AppTextStyle.style_13_600(
                                      color: const Color(0xFF0D6EFD),
                                    ),
                            );
                          }),
                        ],
                      ),
                    ),
                    SizedBox(height: isTablet ? 12.h : 10.h),

                    // Action Buttons: Cancel | Continue Handover (or Continue Cash C TO D)
                    Row(
                      children: [
                        AppCommonButton(
                          text: 'Cancel',
                          height: isTablet ? 32.h : 28.h,
                          textSize: isTablet ? 12.sp : 11.sp,
                          variant: ButtonVariant.outline,
                          onPressed: () =>
                              Navigator.of(dialogCtx).pop(),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Obx(
                            () => AppCommonButton(
                              text: isSubmitting.value
                                  ? 'Processing...'
                                  : (!isCtodTab.value
                                        ? 'Continue Handover'
                                        : 'Continue Cash C TO D'),
                              height: isTablet ? 32.h : 28.h,
                              textSize: isTablet ? 12.sp : 11.sp,
                              width: double.infinity,
                              buttonColor: AppColors.green,
                              useGradient: false,
                                      onPressed: isSubmitting.value
                                          ? null
                                          : () async {
                                              // Validate User
                                              if (selectedUser.value == null) {
                                                AppCommonToastMessage.show(
                                                  message:
                                                      'Please choose a user to handover to',
                                                  type: ToastType.error,
                                                );
                                                return;
                                              }

                                              final effectiveSessionId =
                                                  cashierSessionId ??
                                                  bookingRepo
                                                      .rxActiveCashierSessionId
                                                      .value ??
                                                  0;

                                              if (effectiveSessionId <= 0) {
                                                AppCommonToastMessage.show(
                                                  message:
                                                      'No active cashier session found',
                                                  type: ToastType.error,
                                                );
                                                return;
                                              }

                                              if (!isCtodTab.value) {
                                                // Normal Cash Handover: Gather date-wise collection entries
                                                // Mandatory Rule 1: Submit EVERY pending collection date together, even if own cash is 0
                                                final entries =
                                                    <Map<String, dynamic>>[];
                                                double totalOwnCash = 0.0;
                                                for (var group
                                                    in collectionGroups) {
                                                  double val = 0.0;
                                                  if (group.hasOwnBookingCash) {
                                                    final c =
                                                        ownCashControllers[group
                                                            .date];
                                                    val =
                                                        double.tryParse(
                                                          c?.text.trim() ?? '0',
                                                        ) ??
                                                        0.0;
                                                  }
                                                  totalOwnCash += val;
                                                  entries.add({
                                                    'date': group.rawDate,
                                                    'own_cash_amount': val,
                                                    'amount': val,
                                                  });
                                                }

                                                final grandTotal =
                                                    totalOwnCash +
                                                    totalReceivedCash.value;
                                                if (grandTotal <= 0) {
                                                  AppCommonToastMessage.show(
                                                    message:
                                                        'Please enter a valid handover amount',
                                                    type: ToastType.error,
                                                  );
                                                  return;
                                                }

                                                try {
                                                  isSubmitting.value = true;
                                                  final createRes =
                                                      await bookingRepo
                                                          .createHandover(
                                                            currentUnit: unitNo,
                                                            sessionId:
                                                                effectiveSessionId,
                                                            nextCashier:
                                                                selectedUser
                                                                    .value!
                                                                    .id,
                                                            handoverAction:
                                                                'LOGOUT',
                                                            amount:
                                                                grandTotal,
                                                            collectionEntries:
                                                                entries
                                                                    .isNotEmpty
                                                                ? entries
                                                                : null,
                                                          );
                                                  isSubmitting.value = false;

                                                  if (createRes.actionCode ==
                                                      'CTOD_HANDOVER_PENDING') {
                                                    if (context.mounted) {
                                                      _showPendingHandoverDialog(
                                                        context: context,
                                                        cashier: createRes
                                                            .pendingCashier,
                                                        date:
                                                            createRes.pendingDate,
                                                        reason:
                                                            createRes.reason ??
                                                            createRes.message,
                                                      );
                                                    }
                                                    return;
                                                  }

                                                  if (createRes.actionCode ==
                                                      'SESSION_NOT_ACTIVE') {
                                                    bookingRepo
                                                            .rxActiveCashierSessionId
                                                            .value =
                                                        null;
                                                    if (context.mounted) {
                                                      _showSessionNotActiveDialog(
                                                        context,
                                                      );
                                                    }
                                                    return;
                                                  }

                                                  if (createRes.actionCode ==
                                                      'ALREADY_COMPLETED') {
                                                    if (dialogCtx.mounted) {
                                                      Navigator.of(
                                                        dialogCtx,
                                                      ).pop();
                                                    }
                                                    AppCommonToastMessage.show(
                                                      message:
                                                          'Handover is already completed.',
                                                      type: ToastType.info,
                                                    );
                                                    bookingRepo
                                                            .rxActiveCashierSessionId
                                                            .value =
                                                        null;
                                                    bookingRepo
                                                            .rxSelectedUnitId
                                                            .value =
                                                        '';
                                                    Get.offAllNamed(
                                                      AppRoutes.bookingUnitSelection,
                                                    );
                                                    if (Get.isRegistered<BookingUnitSelectionController>()) {
                                                      Get.find<BookingUnitSelectionController>().fetchUnits();
                                                    }
                                                    return;
                                                  }

                                                  if (createRes.otpSent ||
                                                      createRes.actionCode ==
                                                          'HANDOVER_OTP' ||
                                                      (createRes.status &&
                                                          createRes
                                                                  .handoverId !=
                                                              null)) {
                                                    if (dialogCtx.mounted) {
                                                      Navigator.of(
                                                        dialogCtx,
                                                      ).pop();
                                                    }
                                                    if (context.mounted) {
                                                      _showReceiverOtpBottomSheet(
                                                        context: context,
                                                        handoverId:
                                                            createRes
                                                                .handoverId ??
                                                            0,
                                                        receiverName:
                                                            selectedUser
                                                                .value!
                                                                .name,
                                                        isCtod: false,
                                                        totalAmount: grandTotal,
                                                        unitNo: unitNo,
                                                        onSuccess: onSuccess,
                                                      );
                                                    }
                                                  } else {
                                                    AppCommonToastMessage.show(
                                                      message:
                                                          createRes
                                                              .message
                                                              .isNotEmpty
                                                          ? createRes.message
                                                          : 'Failed to initiate handover',
                                                      type: ToastType.error,
                                                    );
                                                  }
                                                } catch (e) {
                                                  isSubmitting.value = false;
                                                  AppCommonToastMessage.show(
                                                    message:
                                                        'Handover error: $e',
                                                    type: ToastType.error,
                                                  );
                                                }
                                              } else {
                                                // C-to-D Handover
                                                final entries =
                                                    <Map<String, dynamic>>[];
                                                for (var e in ctodDateEntries) {
                                                  final c =
                                                      ctodAmountControllers[e
                                                          .date];
                                                  final val =
                                                      double.tryParse(
                                                        c?.text.trim() ?? '0',
                                                      ) ??
                                                      0.0;
                                                  if (val > 0) {
                                                    entries.add({
                                                      'date': e.date,
                                                      'amount': val,
                                                    });
                                                  }
                                                }

                                                if (entries.isEmpty) {
                                                  AppCommonToastMessage.show(
                                                    message:
                                                        'Please enter at least one date amount for C-to-D',
                                                    type: ToastType.error,
                                                  );
                                                  return;
                                                }

                                                try {
                                                  isSubmitting.value = true;
                                                  final createRes =
                                                      await bookingRepo
                                                          .createHandover(
                                                            currentUnit: unitNo,
                                                            sessionId:
                                                                effectiveSessionId,
                                                            nextCashier:
                                                                selectedUser
                                                                    .value!
                                                                    .id,
                                                            handoverAction:
                                                                'CASH_C_TO_D',
                                                            collectionEntries:
                                                                entries,
                                                          );
                                                  isSubmitting.value = false;

                                                  if (createRes.actionCode ==
                                                      'CTOD_HANDOVER_PENDING') {
                                                    if (context.mounted) {
                                                      _showPendingHandoverDialog(
                                                        context: context,
                                                        cashier: createRes
                                                            .pendingCashier,
                                                        date:
                                                            createRes.pendingDate,
                                                        reason:
                                                            createRes.reason ??
                                                            createRes.message,
                                                      );
                                                    }
                                                    return;
                                                  }

                                                  if (createRes.actionCode ==
                                                      'SESSION_NOT_ACTIVE') {
                                                    bookingRepo
                                                            .rxActiveCashierSessionId
                                                            .value =
                                                        null;
                                                    if (context.mounted) {
                                                      _showSessionNotActiveDialog(
                                                        context,
                                                      );
                                                    }
                                                    return;
                                                  }

                                                  if (createRes.otpSent ||
                                                      createRes.actionCode ==
                                                          'HANDOVER_OTP' ||
                                                      (createRes.status &&
                                                          createRes
                                                                  .handoverId !=
                                                              null)) {
                                                    if (dialogCtx.mounted) {
                                                      Navigator.of(
                                                        dialogCtx,
                                                      ).pop();
                                                    }
                                                    if (context.mounted) {
                                                      _showReceiverOtpBottomSheet(
                                                        context: context,
                                                        handoverId:
                                                            createRes
                                                                .handoverId ??
                                                            0,
                                                        receiverName:
                                                            selectedUser
                                                                .value!
                                                                .name,
                                                        isCtod: true,
                                                        totalAmount:
                                                            ctodTotalGiven
                                                                .value,
                                                        unitNo: unitNo,
                                                        onSuccess: onSuccess,
                                                      );
                                                    }
                                                  } else {
                                                    AppCommonToastMessage.show(
                                                      message:
                                                          createRes
                                                              .message
                                                              .isNotEmpty
                                                          ? createRes.message
                                                          : 'Failed to initiate C-to-D handover',
                                                      type: ToastType.error,
                                                    );
                                                  }
                                                } catch (e) {
                                                  isSubmitting.value = false;
                                                  AppCommonToastMessage.show(
                                                    message: 'C-to-D error: $e',
                                                    type: ToastType.error,
                                                  );
                                                }
                                              }
                                            },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                );
      },
    );
  }
  // endregion

  // region Collection Group Card Builder
  static Widget _buildCollectionGroupCard({
    required HandoverCollectionGroup group,
    required TextEditingController? controller,
    required bool isTablet,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 6.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: const Color(0xFFDEE2E6), width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar: "Collection DD-MM-YYYY" (Formatted with AppDateUtils)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 10.w : 8.w,
              vertical: isTablet ? 4.h : 3.h,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5.r),
                topRight: Radius.circular(5.r),
              ),
              border: Border(
                bottom: BorderSide(color: const Color(0xFFDEE2E6), width: 1.w),
              ),
            ),
            child: Text(
              'Collection ${AppDateUtils.formatToShortOrdinalDate(group.rawDate).isNotEmpty ? AppDateUtils.formatToShortOrdinalDate(group.rawDate) : group.date}',
              style: isTablet
                  ? AppTextStyle.style_12_600(color: const Color(0xFF212529))
                  : AppTextStyle.style_11_600(color: const Color(0xFF212529)),
            ),
          ),

          // Group Body: Received items and/or Own booking cash
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 10.w : 8.w,
              vertical: isTablet ? 5.h : 4.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Received items
                if (group.receivedItems.isNotEmpty) ...[
                  for (int i = 0; i < group.receivedItems.length; i++) ...[
                    if (i > 0)
                      Divider(
                        color: const Color(0xFFE9ECEF),
                        height: 6.h,
                        thickness: 0.8,
                      ),
                    _buildReceivedItemRow(group.receivedItems[i], isTablet),
                  ],
                ],

                // Divider before own booking cash if received items exist
                if (group.receivedItems.isNotEmpty && group.hasOwnBookingCash)
                  Divider(
                    color: const Color(0xFFE9ECEF),
                    height: 6.h,
                    thickness: 0.8,
                  ),

                // Own booking cash
                if (group.hasOwnBookingCash) ...[
                  _buildOwnBookingCashRow(
                    group: group,
                    controller: controller ?? TextEditingController(),
                    isTablet: isTablet,
                  ),
                ] else ...[
                  Padding(
                    padding: EdgeInsets.only(
                      top: group.receivedItems.isNotEmpty ? 4.h : 0,
                    ),
                    child: Text(
                      'No own booking cash input required',
                      style: isTablet
                          ? AppTextStyle.style_10_400(
                              color: AppColors.grey500,
                            )
                          : AppTextStyle.style_9_400(
                              color: AppColors.grey500,
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildReceivedItemRow(ReceivedCashEntry item, bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.senderName.isNotEmpty
                    ? item.senderName
                    : 'Cashier Handover',
                style: isTablet
                    ? AppTextStyle.style_12_600(color: AppColors.black)
                    : AppTextStyle.style_11_600(color: AppColors.black),
              ),
              if (item.createdAt.isNotEmpty) ...[
                SizedBox(height: 1.h),
                Text(
                  AppDateUtils.formatToDateTimeAmPm(item.createdAt).isNotEmpty
                      ? AppDateUtils.formatToDateTimeAmPm(item.createdAt)
                      : item.createdAt,
                  style: isTablet
                      ? AppTextStyle.style_10_400(
                          color: const Color(0xFF6C757D),
                        )
                      : AppTextStyle.style_9_400(
                          color: const Color(0xFF6C757D),
                        ),
                ),
              ],
              if (item.pendingNote.isNotEmpty) ...[
                SizedBox(height: 1.h),
                Text(
                  item.pendingNote,
                  style: isTablet
                      ? AppTextStyle.style_10_400(
                          color: const Color(0xFF6C757D),
                        )
                      : AppTextStyle.style_9_400(
                          color: const Color(0xFF6C757D),
                        ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '₹${item.amount.toStringAsFixed(2)}',
          style: isTablet
              ? AppTextStyle.style_13_600(color: const Color(0xFF198754))
              : AppTextStyle.style_11_700(color: const Color(0xFF198754)),
        ),
      ],
    );
  }

  static Widget _buildOwnBookingCashRow({
    required HandoverCollectionGroup group,
    required TextEditingController controller,
    required bool isTablet,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Own booking cash',
                style: isTablet
                    ? AppTextStyle.style_12_600(color: AppColors.black)
                    : AppTextStyle.style_11_600(color: AppColors.black),
              ),
              SizedBox(height: 1.h),
              Text(
                'Enter only your own cash; received cash is separate',
                style: isTablet
                    ? AppTextStyle.style_10_400(color: const Color(0xFF6C757D))
                    : AppTextStyle.style_9_400(color: const Color(0xFF6C757D)),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        SizedBox(
          width: isTablet ? 120.w : 95.w,
          child: AppCommonTextField(
            controller: controller,
            hintText: '₹ Amount',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            contentPadding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 2.h,
            ),
          ),
        ),
      ],
    );
  }
  // endregion

  // region Receiver OTP Bottom Sheet
  static void _showReceiverOtpBottomSheet({
    required BuildContext context,
    required int handoverId,
    required String receiverName,
    required bool isCtod,
    required double totalAmount,
    required String unitNo,
    VoidCallback? onSuccess,
  }) {
    final bookingRepo = Get.find<BookingRepository>();
    final otpController = TextEditingController();
    final isVerifying = false.obs;
    final isResending = false.obs;

    final defaultPinTheme = PinTheme(
      width: 44.w,
      height: 48.h,
      textStyle: AppTextStyle.style_18_700(color: AppColors.black),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey200),
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.grey50,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primary),
        color: AppColors.white,
      ),
    );

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull Handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),

              Text(
                'Receiver OTP Verification',
                style: AppTextStyle.style_16_700(color: AppColors.primary),
              ),
              SizedBox(height: 6.h),
              Text(
                'Enter the 6-digit OTP sent to receiver ($receiverName) to complete this handover.',
                textAlign: TextAlign.center,
                style: AppTextStyle.style_12_400(color: AppColors.grey500),
              ),
              SizedBox(height: 20.h),

              // Pinput OTP Input
              Obx(
                () => Pinput(
                  length: 6,
                  controller: otpController,
                  readOnly: isVerifying.value,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  onCompleted: (pin) async {
                    if (isVerifying.value) return;
                    await _verifyOtp(
                      context: context,
                      handoverId: handoverId,
                      otp: pin,
                      isCtod: isCtod,
                      totalAmount: totalAmount,
                      unitNo: unitNo,
                      isVerifying: isVerifying,
                      onSuccess: onSuccess,
                    );
                  },
                ),
              ),
              SizedBox(height: 20.h),

              // Verify & Proceed Button
              Obx(
                () => AppCommonButton(
                  text: isVerifying.value
                      ? 'Verifying...'
                      : 'VERIFY & COMPLETE',
                  buttonColor: AppColors.green,
                  useGradient: false,
                  width: double.infinity,
                  onPressed: isVerifying.value
                      ? null
                      : () async {
                          final pin = otpController.text.trim();
                          if (pin.length < 6) {
                            AppCommonToastMessage.show(
                              message: 'Please enter 6-digit OTP',
                              type: ToastType.error,
                            );
                            return;
                          }
                          await _verifyOtp(
                            context: context,
                            handoverId: handoverId,
                            otp: pin,
                            isCtod: isCtod,
                            totalAmount: totalAmount,
                            unitNo: unitNo,
                            isVerifying: isVerifying,
                            onSuccess: onSuccess,
                          );
                        },
                ),
              ),
              SizedBox(height: 10.h),

              // Resend OTP Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive OTP? ",
                    style: AppTextStyle.style_12_400(color: AppColors.grey500),
                  ),
                  Obx(
                    () => GestureDetector(
                      onTap: isResending.value
                          ? null
                          : () async {
                              isResending.value = true;
                              final sent = await bookingRepo.resendHandoverOtp(
                                handoverId: handoverId,
                              );
                              isResending.value = false;
                              if (sent) {
                                AppCommonToastMessage.show(
                                  message: 'OTP resent successfully',
                                  type: ToastType.success,
                                );
                              } else {
                                AppCommonToastMessage.show(
                                  message: 'Failed to resend OTP',
                                  type: ToastType.error,
                                );
                              }
                            },
                      child: Text(
                        isResending.value ? 'Resending...' : 'Resend OTP',
                        style: AppTextStyle.style_12_600(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      barrierColor: AppColors.black.withValues(alpha: 0.5),
    );
  }
  // endregion

  // region OTP Verification Logic
  static Future<void> _verifyOtp({
    required BuildContext context,
    required int handoverId,
    required String otp,
    required bool isCtod,
    required double totalAmount,
    required String unitNo,
    required RxBool isVerifying,
    VoidCallback? onSuccess,
  }) async {
    final bookingRepo = Get.find<BookingRepository>();
    try {
      isVerifying.value = true;
      final res = await bookingRepo.verifyHandoverOtp(
        handoverId: handoverId,
        otp: otp,
      );
      isVerifying.value = false;

      // Section 4 OTP Action Matrix:
      if (res.actionCode == 'INVALID_OTP' || res.isInvalidOtp) {
        AppCommonToastMessage.show(
          message: res.message.isNotEmpty
              ? res.message
              : 'Invalid OTP. Please check and re-enter.',
          type: ToastType.error,
        );
        // Keep popup open
        return;
      }

      if (res.actionCode == 'OTP_EXPIRED' || res.isOtpExpired) {
        AppCommonToastMessage.show(
          message: res.message.isNotEmpty
              ? res.message
              : 'OTP has expired. Please use the Resend OTP option.',
          type: ToastType.warning,
        );
        // Keep popup open
        return;
      }

      if (res.actionCode == 'CTOD_HANDOVER_PENDING' || res.isCtodPending) {
        Get.back(); // close bottomsheet
        _showPendingHandoverDialog(
          context: context,
          cashier: res.pendingCashier,
          date: res.pendingDate,
          reason: res.reason ?? res.message,
        );
        return;
      }

      if (res.actionCode == 'SESSION_NOT_ACTIVE' || res.isSessionNotActive) {
        Get.back(); // close bottomsheet
        bookingRepo.rxActiveCashierSessionId.value = null;
        _showSessionNotActiveDialog(context);
        return;
      }

      if (res.actionCode == 'ALREADY_COMPLETED' || res.isAlreadyCompleted) {
        Get.back(); // close bottomsheet
        AppCommonToastMessage.show(
          message: 'Handover was already completed.',
          type: ToastType.info,
        );
        if (!isCtod) {
          bookingRepo.rxActiveCashierSessionId.value = null;
          bookingRepo.rxSelectedUnitId.value = '';
          Get.offAllNamed(AppRoutes.bookingUnitSelection);
          if (Get.isRegistered<BookingUnitSelectionController>()) {
            Get.find<BookingUnitSelectionController>().fetchUnits();
          }
        } else {
          onSuccess?.call();
        }
        return;
      }

      if (res.actionCode == 'HANDOVER_COMPLETED' ||
          (!isCtod && res.handoverCompleted)) {
        Get.back(); // close bottomsheet
        // Discard old session
        bookingRepo.rxActiveCashierSessionId.value = null;
        bookingRepo.rxSelectedUnitId.value = '';

        if (res.shortfall != null && res.shortfall! > 0) {
          AppCommonToastMessage.show(
            message:
                'Shortfall of ₹${res.shortfall!.toStringAsFixed(2)} reported.',
            type: ToastType.warning,
          );
        } else {
          AppCommonToastMessage.show(
            message: res.message.isNotEmpty
                ? res.message
                : 'Cash Handover completed successfully.',
            type: ToastType.success,
          );
        }

        Get.offAllNamed(AppRoutes.bookingUnitSelection);
        if (Get.isRegistered<BookingUnitSelectionController>()) {
          Get.find<BookingUnitSelectionController>().fetchUnits();
        }
        onSuccess?.call();
        return;
      }

      if (res.actionCode == 'CASH_C_TO_D_COMPLETED' ||
          (isCtod && res.handoverCompleted)) {
        Get.back(); // close bottomsheet
        // Same session retained!
        AppCommonToastMessage.show(
          message: res.message.isNotEmpty
              ? res.message
              : 'Cash C to D completed successfully.',
          type: ToastType.success,
        );
        onSuccess?.call();
        return;
      }

      if (res.status && res.handoverCompleted) {
        Get.back();
        if (!isCtod) {
          bookingRepo.rxActiveCashierSessionId.value = null;
          bookingRepo.rxSelectedUnitId.value = '';
          AppCommonToastMessage.show(
            message: res.message.isNotEmpty
                ? res.message
                : 'Cash Handover completed successfully.',
            type: ToastType.success,
          );
          Get.offAllNamed(AppRoutes.bookingUnitSelection);
          if (Get.isRegistered<BookingUnitSelectionController>()) {
            Get.find<BookingUnitSelectionController>().fetchUnits();
          }
        } else {
          AppCommonToastMessage.show(
            message: res.message.isNotEmpty
                ? res.message
                : 'Cash C to D completed successfully.',
            type: ToastType.success,
          );
        }
        onSuccess?.call();
        return;
      }

      AppCommonToastMessage.show(
        message: res.message.isNotEmpty
            ? res.message
            : 'Invalid OTP or transfer failed',
        type: ToastType.error,
      );
    } catch (e) {
      isVerifying.value = false;
      AppCommonToastMessage.show(
        message: 'OTP Verification Error: $e',
        type: ToastType.error,
      );
    }
  }
  // endregion

  // region Success & Alert Dialogs
  static void _showPendingHandoverDialog({
    required BuildContext context,
    String? cashier,
    String? date,
    String? reason,
  }) {
    AppCommonDialogBox.showInfo(
      context,
      title: 'Pending Handover Detected',
      message:
          'Cannot initiate transfer. A handover is currently pending.\n\n'
          'Cashier: ${cashier?.isNotEmpty == true ? cashier : "Pending Cashier"}\n'
          'Date: ${date?.isNotEmpty == true ? date : "N/A"}\n'
          'Reason: ${reason?.isNotEmpty == true ? reason : "C to D clearance pending"}',
      buttonText: 'UNDERSTOOD',
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFF15A24),
    );
  }

  static void _showSessionNotActiveDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 380.w),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: const Color(0xFFDC3545),
                  size: 38.sp,
                ),
                SizedBox(height: 12.h),
                Text(
                  'Session Not Active',
                  style: AppTextStyle.style_16_700(color: AppColors.black),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Your cashier session has expired or is no longer active. Please enter the unit again to start a new shift.',
                  style: AppTextStyle.style_12_400(color: AppColors.grey600),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 18.h),
                AppCommonButton(
                  text: 'ENTER UNIT',
                  width: double.infinity,
                  height: 36.h,
                  textSize: 12.sp,
                  buttonColor: AppColors.primary,
                  useGradient: false,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Get.offAllNamed(AppRoutes.bookingUnitSelection);
                    if (Get.isRegistered<BookingUnitSelectionController>()) {
                      Get.find<BookingUnitSelectionController>().fetchUnits();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // endregion
}
// endregion
