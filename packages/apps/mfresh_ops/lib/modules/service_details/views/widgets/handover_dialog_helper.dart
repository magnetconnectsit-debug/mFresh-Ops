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
    final commonRepo = Get.isRegistered<CommonRepository>()
        ? Get.find<CommonRepository>()
        : Get.put(CommonRepository());

    final isCtodTab = false.obs; // false = Handover Cash, true = Cash C TO D
    final isLoading = false.obs;
    final isSubmitting = false.obs;

    // Overview data
    final cashDue = 0.0.obs;
    final cashBalance = 0.0.obs;

    // User options
    final handoverUserList = <AssigneeModel>[].obs;
    final ctodUserList = <AssigneeModel>[].obs;
    final selectedUser = Rxn<AssigneeModel>();

    // Handover Cash tab
    final handoverAmount = ''.obs;
    final handoverAmountController = TextEditingController();

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

        // Generate full list of days within the selected date range
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
            // Find if date matches in DD-MM-YYYY or other format
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

    // Load initial user list & C-to-D dates
    Future<void> loadInitialData() async {
      try {
        isLoading.value = true;
        final results = await Future.wait([
          bookingRepo.getHandoverUsers(),
          bookingRepo.getCtodDates(
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32.w : 16.w,
            vertical: 20.h,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              maxHeight: MediaQuery.of(context).size.height * 0.90,
            ),
            child: Obx(() {
              final int selectedIndex = isCtodTab.value ? 1 : 0;
              final double tabHeight = isTablet ? 54.h : 46.h;

              if (isLoading.value) {
                return Container(
                  height: 220.h,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: const Center(
                    child: CustomAppLoader(size: 36),
                  ),
                );
              }

              return CustomPaint(
                painter: _HandoverElevatedTabCardPainter(
                  selectedIndex: selectedIndex,
                  tabHeight: tabHeight,
                  cornerRadius: 16.r,
                  junctionRadius: 14.r,
                  borderColor: AppColors.borderColor,
                  inactiveTabColor: const Color(0xFFF1F5F9),
                  cardColor: AppColors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Unified Elevated Tabs Header
                    SizedBox(
                      height: tabHeight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                              child: Center(
                                child: Text(
                                  'Handover Cash',
                                  style: isTablet
                                      ? AppTextStyle.style_15_600(
                                          color: !isCtodTab.value
                                              ? AppColors.primary
                                              : const Color(0xFF64748B),
                                        )
                                      : AppTextStyle.style_13_600(
                                          color: !isCtodTab.value
                                              ? AppColors.primary
                                              : const Color(0xFF64748B),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                if (!isCtodTab.value) {
                                  isCtodTab.value = true;
                                  selectedUser.value = null;
                                }
                              },
                              child: Center(
                                child: Text(
                                  'Cash C TO D',
                                  style: isTablet
                                      ? AppTextStyle.style_15_600(
                                          color: isCtodTab.value
                                              ? AppColors.primary
                                              : const Color(0xFF64748B),
                                        )
                                      : AppTextStyle.style_13_600(
                                          color: isCtodTab.value
                                              ? AppColors.primary
                                              : const Color(0xFF64748B),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Card Content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          isTablet ? 24.w : 16.w,
                          isTablet ? 16.h : 12.h,
                          isTablet ? 24.w : 16.w,
                          isTablet ? 18.h : 14.h,
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
                                  !isCtodTab.value ? 'Handover Cash' : 'Cash C TO D',
                                  style: isTablet
                                      ? AppTextStyle.style_18_700(color: AppColors.primary)
                                      : AppTextStyle.style_15_700(color: AppColors.primary),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.of(dialogCtx).pop(),
                                  icon: Icon(
                                    Icons.close,
                                    size: isTablet ? 22.sp : 18.sp,
                                    color: AppColors.grey500,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            SizedBox(height: isTablet ? 14.h : 10.h),

                      // Handover To (Choose User) Dropdown
                      Obx(() {
                        final currentUsers = isCtodTab.value ? ctodUserList : handoverUserList;
                        return AppCommonMultiSelectDropdown<AssigneeModel>(
                          label: 'Handover To',
                          hint: 'Choose User',
                          height: isTablet ? 42.h : 34.h,
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
                                    ? AppTextStyle.style_14_400(color: AppColors.grey900)
                                    : AppTextStyle.style_12_400(color: AppColors.grey900),
                              ),
                            );
                          }).toList(),
                          onChanged: (values) {
                            selectedUser.value =
                                values.isNotEmpty ? values.first : null;
                          },
                        );
                      }),
                      SizedBox(height: isTablet ? 16.h : 12.h),

                      // Tab Specific Content
                      if (!isCtodTab.value) ...[
                        // Handover Cash Tab: Single Amount with Floating Label
                        AppCommonTextField(
                          controller: handoverAmountController,
                          labelText: 'Amount to Handover',
                          hintText: 'Enter amount',
                          useFloatingLabel: true,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'),
                            ),
                          ],
                          prefixIcon: Icon(
                            Icons.currency_rupee,
                            size: 16.sp,
                            color: AppColors.grey700,
                          ),
                          fillColor: AppColors.white,
                          onChanged: (val) => handoverAmount.value = val,
                        )
                      ] else ...[
                        // Cash C TO D Tab: Standalone Collection Dates field
                        GestureDetector(
                          onTap: () async {
                            final now = DateTime.now();
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: now.add(const Duration(days: 365)),
                              initialDateRange: selectedDateRange.value ??
                                  DateTimeRange(
                                    start: now.subtract(const Duration(days: 3)),
                                    end: now,
                                  ),
                            );
                            if (picked != null) {
                              selectedDateRange.value = picked;
                              final sStr =
                                  '${picked.start.year}-${picked.start.month.toString().padLeft(2, '0')}-${picked.start.day.toString().padLeft(2, '0')}';
                              final eStr =
                                  '${picked.end.year}-${picked.end.month.toString().padLeft(2, '0')}-${picked.end.day.toString().padLeft(2, '0')}';
                              dateRangeController.text =
                                  AppDateUtils.formatDateRangeOrdinal(picked.start, picked.end);
                              filterCtodEntries();

                              // Fetch fresh server entries for this date range
                              try {
                                final remoteDates = await bookingRepo.getCtodDates(
                                  unitId: unitNo,
                                  sessionId: cashierSessionId,
                                  fromDate: sStr,
                                  toDate: eStr,
                                );
                                if (remoteDates.isNotEmpty) {
                                  for (final r in remoteDates) {
                                    allCtodDateEntries.removeWhere((e) => e.date == r.date);
                                    allCtodDateEntries.add(r);
                                  }
                                  filterCtodEntries();
                                }
                              } catch (_) {}
                            }
                          },
                          child: AbsorbPointer(
                            child: AppCommonTextField(
                              controller: dateRangeController,
                              labelText: 'Collection Dates',
                              hintText: 'Select date range',
                              useFloatingLabel: true,
                              fillColor: AppColors.white,
                              suffixIcon: Icon(
                                Icons.calendar_today_outlined,
                                size: 16.sp,
                                color: AppColors.grey500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 6.h),

                        // Date entries cards
                        if (ctodDateEntries.isNotEmpty) ...[
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: ctodDateEntries.length,
                            separatorBuilder: (context, index) => Divider(
                              color: AppColors.grey200,
                              height: 16.h,
                              thickness: 0.8,
                            ),
                            itemBuilder: (context, index) {
                              final entry = ctodDateEntries[index];
                              final c = ctodAmountControllers[entry.date]!;
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.h),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        AppDateUtils.formatToShortOrdinalDate(entry.date).isNotEmpty
                                            ? AppDateUtils.formatToShortOrdinalDate(entry.date)
                                            : entry.date,
                                        style: AppTextStyle.style_12_700(
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    SizedBox(
                                      width: 130.w,
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
                                        fillColor: AppColors.white,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 2.h,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                      SizedBox(height: 14.h),

                      // Total Physical Cash Given Card (Alice Blue Container)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 18.w : 14.w,
                          vertical: isTablet ? 14.h : 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.aliceBlue,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            width: 0.8.w,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Physical Cash Given',
                              style: isTablet
                                  ? AppTextStyle.style_15_600(color: AppColors.primary)
                                  : AppTextStyle.style_12_500(color: AppColors.primary),
                            ),
                            Obx(() {
                              final total = !isCtodTab.value
                                  ? (double.tryParse(handoverAmount.value.trim()) ?? 0.0)
                                  : ctodTotalGiven.value;
                              return Text(
                                '₹${total.toStringAsFixed(2)}',
                                style: isTablet
                                    ? AppTextStyle.style_18_700(color: AppColors.primary)
                                    : AppTextStyle.style_14_700(color: AppColors.primary),
                              );
                            }),
                          ],
                        ),
                      ),
                      SizedBox(height: isTablet ? 22.h : 18.h),

                      // Action Buttons: Cancel | Continue Button
                      Row(
                        children: [
                          AppCommonButton(
                            text: 'Cancel',
                            height: isTablet ? 42.h : null,
                            textSize: isTablet ? 14.sp : null,
                            variant: ButtonVariant.outline,
                            onPressed: () => Navigator.of(dialogCtx).pop(),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: AppCommonButton(
                              text: isSubmitting.value
                                  ? 'Processing...'
                                  : (!isCtodTab.value
                                      ? 'Continue Handover'
                                      : 'Continue Cash C TO D'),
                              height: isTablet ? 42.h : null,
                              textSize: isTablet ? 14.sp : null,
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
                                        // Normal Cash Handover Validation
                                        final amt = double.tryParse(
                                              handoverAmountController.text
                                                  .trim(),
                                            ) ??
                                            0.0;
                                        if (amt <= 0) {
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
                                              await bookingRepo.createHandover(
                                            currentUnit: unitNo,
                                            sessionId: effectiveSessionId,
                                            nextCashier: selectedUser.value!.id,
                                            handoverAction: 'LOGOUT',
                                            amount: amt,
                                          );

                                          isSubmitting.value = false;
                                          if (createRes.status &&
                                              createRes.handoverId != null) {
                                            if (dialogCtx.mounted) {
                                              Navigator.of(dialogCtx).pop();
                                            }
                                            if (context.mounted) {
                                              _showReceiverOtpBottomSheet(
                                                context: context,
                                                handoverId:
                                                    createRes.handoverId!,
                                                receiverName:
                                                    selectedUser.value!.name,
                                                isCtod: false,
                                                onSuccess: onSuccess,
                                              );
                                            }
                                          } else {
                                            AppCommonToastMessage.show(
                                              message: createRes.message
                                                      .isNotEmpty
                                                  ? createRes.message
                                                  : 'Failed to initiate handover',
                                              type: ToastType.error,
                                            );
                                          }
                                        } catch (e) {
                                          isSubmitting.value = false;
                                          AppCommonToastMessage.show(
                                            message: 'Handover error: $e',
                                            type: ToastType.error,
                                          );
                                        }
                                      } else {
                                        // C-to-D Handover Validation
                                        final entries =
                                            <Map<String, dynamic>>[];
                                        for (var e in ctodDateEntries) {
                                          final c =
                                              ctodAmountControllers[e.date];
                                          final val = double.tryParse(
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
                                              await bookingRepo.createHandover(
                                            currentUnit: unitNo,
                                            sessionId: effectiveSessionId,
                                            nextCashier: selectedUser.value!.id,
                                            handoverAction: 'CASH_C_TO_D',
                                            collectionEntries: entries,
                                          );

                                          isSubmitting.value = false;
                                          if (createRes.status &&
                                              createRes.handoverId != null) {
                                            if (dialogCtx.mounted) {
                                              Navigator.of(dialogCtx).pop();
                                            }
                                            if (context.mounted) {
                                              _showReceiverOtpBottomSheet(
                                                context: context,
                                                handoverId:
                                                    createRes.handoverId!,
                                                receiverName:
                                                    selectedUser.value!.name,
                                                isCtod: true,
                                                onSuccess: onSuccess,
                                              );
                                            }
                                          } else {
                                            AppCommonToastMessage.show(
                                              message: createRes.message
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
                        ],
                      ),
                    ],
                  ),
                ),
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

  // region Receiver OTP Bottom Sheet
  static void _showReceiverOtpBottomSheet({
    required BuildContext context,
    required int handoverId,
    required String receiverName,
    required bool isCtod,
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
              Obx(() => Pinput(
                    length: 6,
                    controller: otpController,
                    readOnly: isVerifying.value,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    onCompleted: (pin) async {
                      if (isVerifying.value) return;
                      await _verifyOtp(
                        handoverId: handoverId,
                        otp: pin,
                        isCtod: isCtod,
                        isVerifying: isVerifying,
                        onSuccess: onSuccess,
                      );
                    },
                  )),
              SizedBox(height: 20.h),

              // Verify & Proceed Button
              Obx(() => AppCommonButton(
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
                              handoverId: handoverId,
                              otp: pin,
                              isCtod: isCtod,
                              isVerifying: isVerifying,
                              onSuccess: onSuccess,
                            );
                          },
                  )),
              SizedBox(height: 10.h),

              // Resend OTP Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive OTP? ",
                    style: AppTextStyle.style_12_400(color: AppColors.grey500),
                  ),
                  Obx(() => GestureDetector(
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
                      )),
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

  static Future<void> _verifyOtp({
    required int handoverId,
    required String otp,
    required bool isCtod,
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

      if (res.status && res.handoverCompleted) {
        Get.back(); // close bottomsheet
        AppCommonToastMessage.show(
          message: res.message.isNotEmpty
              ? res.message
              : (isCtod
                  ? 'C-to-D Handover completed successfully'
                  : 'Cash Handover completed successfully'),
          type: ToastType.success,
        );

        if (res.shortfall != null && res.shortfall! > 0) {
          AppCommonToastMessage.show(
            message:
                'Shortfall of ₹${res.shortfall!.toStringAsFixed(2)} detected. Alert sent.',
            type: ToastType.warning,
          );
        }

        onSuccess?.call();
      } else {
        AppCommonToastMessage.show(
          message: res.message.isNotEmpty ? res.message : 'Invalid OTP',
          type: ToastType.error,
        );
      }
    } catch (e) {
      isVerifying.value = false;
      AppCommonToastMessage.show(
        message: 'OTP Verification Error: $e',
        type: ToastType.error,
      );
    }
  }
  // endregion
}
// endregion

// region Handover Elevated Tab Card Painter
class _HandoverElevatedTabCardPainter extends CustomPainter {
  final int selectedIndex;
  final double tabHeight;
  final double cornerRadius;
  final double junctionRadius;
  final Color borderColor;
  final Color inactiveTabColor;
  final Color cardColor;

  _HandoverElevatedTabCardPainter({
    required this.selectedIndex,
    required this.tabHeight,
    this.cornerRadius = 16.0,
    this.junctionRadius = 14.0,
    this.borderColor = AppColors.borderColor,
    this.inactiveTabColor = const Color(0xFFF1F5F9),
    this.cardColor = AppColors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final th = tabHeight;
    final midX = w / 2;
    final rOut = cornerRadius;
    final rJ = junctionRadius;
    final rTop = 16.r;

    final paintBorder = Paint()
      ..color = borderColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final elevatedPath = Path();

    if (selectedIndex == 1) {
      // ── Tab 1 (Cash C TO D) is Active; Tab 0 (Handover Cash) is Inactive ──

      // 1. Inactive Tab in notch [0, midX] x [0, th]
      final notchPath = Path();
      notchPath.moveTo(0, rOut);
      notchPath.quadraticBezierTo(0, 0, rOut, 0);
      notchPath.lineTo(midX - rTop, 0);
      notchPath.quadraticBezierTo(midX, 0, midX, rTop);
      notchPath.lineTo(midX, th - rJ);
      notchPath.quadraticBezierTo(midX, th, midX - rJ, th);
      notchPath.lineTo(rOut, th);
      notchPath.quadraticBezierTo(0, th, 0, th + rOut);
      notchPath.lineTo(0, rOut);
      notchPath.close();

      canvas.drawPath(notchPath, Paint()..color = inactiveTabColor);

      final notchBorder = Path();
      notchBorder.moveTo(0, th + rOut);
      notchBorder.lineTo(0, rOut);
      notchBorder.quadraticBezierTo(0, 0, rOut, 0);
      notchBorder.lineTo(midX - rTop, 0);
      notchBorder.quadraticBezierTo(midX, 0, midX, rTop);
      canvas.drawPath(notchBorder, paintBorder);

      // 2. Elevated Active Shape (Active Tab + Card Body)
      elevatedPath.moveTo(midX + rTop, 0);
      elevatedPath.lineTo(w - rOut, 0);
      elevatedPath.quadraticBezierTo(w, 0, w, rOut);
      elevatedPath.lineTo(w, h - rOut);
      elevatedPath.quadraticBezierTo(w, h, w - rOut, h);
      elevatedPath.lineTo(rOut, h);
      elevatedPath.quadraticBezierTo(0, h, 0, h - rOut);
      elevatedPath.lineTo(0, th + rOut);
      elevatedPath.quadraticBezierTo(0, th, rOut, th);
      elevatedPath.lineTo(midX - rJ, th);
      elevatedPath.quadraticBezierTo(midX, th, midX, th - rJ);
      elevatedPath.lineTo(midX, rTop);
      elevatedPath.quadraticBezierTo(midX, 0, midX + rTop, 0);
      elevatedPath.close();
    } else {
      // ── Tab 0 (Handover Cash) is Active; Tab 1 (Cash C TO D) is Inactive ──

      // 1. Inactive Tab in notch [midX, w] x [0, th]
      final notchPath = Path();
      notchPath.moveTo(midX, rTop);
      notchPath.quadraticBezierTo(midX, 0, midX + rTop, 0);
      notchPath.lineTo(w - rOut, 0);
      notchPath.quadraticBezierTo(w, 0, w, rOut);
      notchPath.lineTo(w, th + rOut);
      notchPath.quadraticBezierTo(w, th, w - rOut, th);
      notchPath.lineTo(midX + rJ, th);
      notchPath.quadraticBezierTo(midX, th, midX, th - rJ);
      notchPath.close();

      canvas.drawPath(notchPath, Paint()..color = inactiveTabColor);

      final notchBorder = Path();
      notchBorder.moveTo(midX, rTop);
      notchBorder.quadraticBezierTo(midX, 0, midX + rTop, 0);
      notchBorder.lineTo(w - rOut, 0);
      notchBorder.quadraticBezierTo(w, 0, w, rOut);
      notchBorder.lineTo(w, th + rOut);
      canvas.drawPath(notchBorder, paintBorder);

      // 2. Elevated Active Shape (Active Tab + Card Body)
      elevatedPath.moveTo(0, rOut);
      elevatedPath.quadraticBezierTo(0, 0, rOut, 0);
      elevatedPath.lineTo(midX - rTop, 0);
      elevatedPath.quadraticBezierTo(midX, 0, midX, rTop);
      elevatedPath.lineTo(midX, th - rJ);
      elevatedPath.quadraticBezierTo(midX, th, midX + rJ, th);
      elevatedPath.lineTo(w - rOut, th);
      elevatedPath.quadraticBezierTo(w, th, w, th + rOut);
      elevatedPath.lineTo(w, h - rOut);
      elevatedPath.quadraticBezierTo(w, h, w - rOut, h);
      elevatedPath.lineTo(rOut, h);
      elevatedPath.quadraticBezierTo(0, h, 0, h - rOut);
      elevatedPath.lineTo(0, rOut);
      elevatedPath.close();
    }

    // 3. Ambient & Elevation Drop Shadows
    final shadowAmbient = Paint()
      ..color = AppColors.black.withValues(alpha: 0.06)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12.r);
    canvas.drawPath(elevatedPath, shadowAmbient);

    final shadowElevation = Paint()
      ..color = AppColors.black.withValues(alpha: 0.08)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20.r);
    canvas.drawPath(elevatedPath.shift(Offset(0, 6.h)), shadowElevation);

    // 4. Fill Elevated Active Shape Surface
    canvas.drawPath(elevatedPath, Paint()..color = cardColor);

    // 5. Draw Perimeter Border
    canvas.drawPath(elevatedPath, paintBorder);
  }

  @override
  bool shouldRepaint(covariant _HandoverElevatedTabCardPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.tabHeight != tabHeight ||
        oldDelegate.cornerRadius != cornerRadius ||
        oldDelegate.junctionRadius != junctionRadius ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.inactiveTabColor != inactiveTabColor ||
        oldDelegate.cardColor != cardColor;
  }
}
// endregion

