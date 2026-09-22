import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:intl/intl.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:mfresh_ops/data/models/payment_reminder/payment_reminder_model.dart';
import 'package:mfresh_ops/modules/payment_reminder/controllers/create_payment_reminder_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';

class EditReminderDateDialog extends StatelessWidget {
  final CreatePaymentReminderController controller;

  const EditReminderDateDialog({super.key, required this.controller});

  static Future<void> show(
    BuildContext context,
    CreatePaymentReminderController controller,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        backgroundColor: AppColors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Container(
          width: 440.w,
          padding: EdgeInsets.all(16.r),
          child: EditReminderDateDialog(controller: controller),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tempDate = Rxn<DateTime>(
      controller.selectedReminderSetupDate.value ??
          controller.selectedDueDate.value ??
          DateTime.now(),
    );
    final tempTime = Rxn<TimeOfDay>(
      controller.selectedReminderTime.value ?? TimeOfDay.now(),
    );
    final tempAssignee = Rxn<PaymentReminderUser>(
      controller.selectedAssignee.value,
    );
    final tempApplyChangeTo = RxString(
      controller.recurrenceScope.value.isNotEmpty
          ? controller.recurrenceScope.value
          : 'only_this',
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ────────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Edit Reminder Date',
              style: AppTextStyle.style_16_700(color: AppColors.grey800),
            ),
            InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(4.r),
              child: Padding(
                padding: EdgeInsets.all(4.r),
                child: Icon(
                  Icons.close_rounded,
                  size: 20.r,
                  color: AppColors.grey500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Divider(height: 1, color: AppColors.borderColor),
        SizedBox(height: 16.h),

        // ── Form Content ──────────────────────────────────────────────────
        Obx(() {
          final isOnlyThis = tempApplyChangeTo.value == 'only_this';

          final assigneeWidget = MultiSelectDropdownWidget<PaymentReminderUser>(
            label: 'Assignee Name',
            hint: 'Select Assignee',
            isSingleSelect: true,
            showSearch: true,
            selectedValues: tempAssignee.value == null
                ? <PaymentReminderUser>{}
                : {tempAssignee.value!},
            items: controller.users
                .map(
                  (e) => DropdownMenuItem<PaymentReminderUser>(
                    value: e,
                    child: Text(
                      e.name ?? '-',
                      style: AppTextStyle.style_12_400(
                        color: AppColors.grey900,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (values) => tempAssignee.value =
                values.isEmpty ? null : values.first,
            customChild: _buildDropdownField(
              label: 'Assignee Name',
              hint: 'Select Assignee',
              value: tempAssignee.value?.name,
            ),
          );

          final reminderTimeWidget = _buildDateTimeField(
            label: 'Reminder Time',
            hint: 'Select Time',
            icon: Icons.keyboard_arrow_down_rounded,
            value: _format12HourTime(tempTime.value),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: tempTime.value ?? TimeOfDay.now(),
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                tempTime.value = picked;
              }
            },
          );

          final reminderDateWidget = _buildDateTimeField(
            label: 'Reminder Date',
            hint: 'Select Date',
            icon: Icons.calendar_today_outlined,
            value: tempDate.value != null
                ? AppDateUtils.formatToShortOrdinalDate(tempDate.value!)
                : null,
            onTap: () async {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final rawInitial = tempDate.value ?? today;
              final initialDate = rawInitial.isBefore(today) ? today : rawInitial;
              final picked = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: today,
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                tempDate.value = picked;
              }
            },
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isOnlyThis) ...[
                Row(
                  children: [
                    Expanded(child: reminderDateWidget),
                    SizedBox(width: 10.w),
                    Expanded(child: reminderTimeWidget),
                  ],
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(child: assigneeWidget),
                    SizedBox(width: 10.w),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(child: assigneeWidget),
                    SizedBox(width: 10.w),
                    Expanded(child: reminderTimeWidget),
                  ],
                ),
              ],
              SizedBox(height: 14.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Apply Change To',
                    style: AppTextStyle.style_12_600(color: AppColors.grey800),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => tempApplyChangeTo.value = 'only_this',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<String>(
                              value: 'only_this',
                              groupValue: tempApplyChangeTo.value,
                              activeColor: AppColors.primary,
                              onChanged: (v) =>
                                  tempApplyChangeTo.value = v ?? 'only_this',
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Only this date',
                              style: AppTextStyle.style_12_600(
                                color: AppColors.grey800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20.w),
                      InkWell(
                        onTap: () => tempApplyChangeTo.value = 'entire_schedule',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<String>(
                              value: 'entire_schedule',
                              groupValue: tempApplyChangeTo.value,
                              activeColor: AppColors.primary,
                              onChanged: (v) =>
                                  tempApplyChangeTo.value = v ?? 'entire_schedule',
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Entire schedule',
                              style: AppTextStyle.style_12_600(
                                color: AppColors.grey800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        }),

        SizedBox(height: 20.h),
        Divider(height: 1, color: AppColors.borderColor),
        SizedBox(height: 16.h),

        // ── Action Buttons ────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppCommonButton(
              text: 'Cancel',
              variant: ButtonVariant.outline,
              isSmall: true,
              height: 34.h,
              width: 90.w,
              onPressed: () => Get.back(),
            ),
            SizedBox(width: 12.w),
            AppCommonButton(
              text: 'Save Change',
              variant: ButtonVariant.primary,
              isSmall: true,
              height: 34.h,
              width: 115.w,
              onPressed: () {
                controller.selectedReminderSetupDate.value = tempDate.value;
                if (tempApplyChangeTo.value == 'only_this') {
                  controller.selectedDueDate.value = tempDate.value;
                }
                if (tempTime.value != null) {
                  controller.selectedReminderTime.value = tempTime.value;
                }
                if (tempAssignee.value != null) {
                  controller.selectedAssignee.value = tempAssignee.value;
                }
                controller.recurrenceScope.value = tempApplyChangeTo.value;
                Get.back();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimeField({
    required String label,
    String? hint,
    IconData? icon,
    String? value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: AppTextStyle.style_12_400(color: AppColors.grey200),
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: BorderSide(color: AppColors.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: BorderSide(color: AppColors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          suffixIcon: icon != null
              ? Padding(
                  padding: EdgeInsets.only(right: 4.w),
                  child: Icon(icon, color: AppColors.grey300, size: 14.r),
                )
              : null,
          suffixIconConstraints: BoxConstraints(
            minWidth: 18.w,
            minHeight: 18.h,
          ),
        ),
        child: Text(
          value ?? hint ?? 'Select',
          style: value != null
              ? AppTextStyle.style_12_400(color: AppColors.grey900)
              : AppTextStyle.style_12_400(color: AppColors.grey300).copyWith(fontSize: 11.sp),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    String? hint,
    String? value,
    IconData icon = Icons.keyboard_arrow_down_rounded,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: AppTextStyle.style_12_400(color: AppColors.grey200),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        suffixIcon: Padding(
          padding: EdgeInsets.only(right: 4.w),
          child: Icon(icon, color: AppColors.grey300, size: 16.r),
        ),
        suffixIconConstraints: BoxConstraints(
          minWidth: 18.w,
          minHeight: 18.h,
        ),
      ),
      child: Text(
        (value != null && value.isNotEmpty) ? value : (hint ?? 'Select'),
        style: (value != null && value.isNotEmpty)
            ? AppTextStyle.style_12_400(color: AppColors.grey900)
            : AppTextStyle.style_12_400(color: AppColors.grey300).copyWith(fontSize: 11.sp),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String? _format12HourTime(TimeOfDay? time) {
    if (time == null) return null;
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }
}
