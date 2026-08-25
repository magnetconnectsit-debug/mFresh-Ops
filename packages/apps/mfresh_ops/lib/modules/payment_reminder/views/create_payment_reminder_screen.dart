import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';

import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/modules/payment_reminder/controllers/create_payment_reminder_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';
import 'package:mfresh_ops/data/models/payment_reminder_model.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/appointment_recurrence_dialog.dart';

class CreatePaymentReminderScreen extends StatelessWidget {
  const CreatePaymentReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreatePaymentReminderController());

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CommonSidebar(),
      appBar: PreferredSize(
        preferredSize: const AppCommonAppBar().preferredSize,
        child: const AppCommonAppBar(
          title: Text('Add Payment Reminder'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Reminder Form',
                    style: AppTextStyle.style_14_700(color: AppColors.black),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => MultiSelectDropdownWidget<PaymentReminderUser>(
                            label: 'Assignee Name *',
                            isSingleSelect: true,
                            showSearch: true,
                            selectedValues: controller.selectedAssignee.value == null
                                ? <PaymentReminderUser>{}
                                : {controller.selectedAssignee.value!},
                            items: controller.users
                                .map((e) => DropdownMenuItem<PaymentReminderUser>(
                                      value: e,
                                      child: Text(
                                        e.name ?? '-',
                                        style: AppTextStyle.style_12_400(color: AppColors.grey900),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (values) => controller.selectedAssignee.value = values.isEmpty ? null : values.first,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildTextField(controller: controller.forCtrl, label: 'For'),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(controller: controller.brandCtrl, label: 'Brand'),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Obx(
                          () => MultiSelectDropdownWidget<String>(
                            label: 'Expense Type',
                            isSingleSelect: true,
                            showSearch: false,
                            selectedValues: controller.selectedExpenseType.value == null
                                ? <String>{}
                                : {controller.selectedExpenseType.value!},
                            items: controller.expenseTypes
                                .map((e) => DropdownMenuItem<String>(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: AppTextStyle.style_12_400(color: AppColors.grey900),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (values) => controller.selectedExpenseType.value = values.isEmpty ? null : values.first,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(controller: controller.expenseHeadCtrl, label: 'Expense Head'),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildTextField(controller: controller.subHeadCtrl, label: 'Sub-Head'),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(controller: controller.costCenterCtrl, label: 'Cost Center'),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildTextField(controller: controller.locationCtrl, label: 'Location *'),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(controller: controller.customerIdCtrl, label: 'Customer ID'),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Obx(
                          () => _buildDateTimeField(
                            label: 'Due Date',
                            icon: Icons.calendar_today_outlined,
                            value: controller.selectedDueDate.value != null
                                ? AppDateUtils.formatToOrdinalDate(controller.selectedDueDate.value!.toIso8601String())
                                : null,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                controller.selectedDueDate.value = date;
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => _buildDateTimeField(
                            label: 'Reminder Setup *',
                            icon: Icons.calendar_today_outlined,
                            value: controller.selectedReminderSetupDate.value != null
                                ? AppDateUtils.formatToOrdinalDate(controller.selectedReminderSetupDate.value!.toIso8601String())
                                : 'Set Reminder',
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                controller.selectedReminderSetupDate.value = date;
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildTextField(controller: controller.remindBeforeCtrl, label: 'Remind Before', isNumber: true),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(controller: controller.additionalNumberCtrl, label: 'Additional Number', isNumber: true),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRecurringTask(context, controller),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),
                  
                  // Submit Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 100.w,
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.grey100),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTextStyle.style_14_600(color: AppColors.black),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Obx(() => SizedBox(
                        width: 130.w,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value ? null : controller.submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D6EFD),
                            disabledBackgroundColor: const Color(0xFF0D6EFD).withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            elevation: 0,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Submit',
                                  style: AppTextStyle.style_14_600(color: AppColors.white),
                                ),
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: AppTextStyle.style_12_400(color: AppColors.grey200),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: maxLines > 1 ? 6.h : 4.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: const BorderSide(color: Color(0xffF15A24), width: 1.5),
        ),
        isDense: true,
      ),
      style: AppTextStyle.style_12_400(color: AppColors.grey900),
    );
  }

  Widget _buildDateTimeField({
    required String label,
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
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: const BorderSide(color: AppColors.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: const BorderSide(color: AppColors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: const BorderSide(color: Color(0xffF15A24), width: 1.5),
          ),
          suffixIcon: icon != null
              ? Padding(
                  padding: EdgeInsets.only(right: 4.w),
                  child: Icon(icon, color: AppColors.grey200, size: 16.r),
                )
              : null,
          suffixIconConstraints: BoxConstraints(
            minWidth: 20.w,
            minHeight: 20.h,
          ),
        ),
        child: Text(
          value ?? 'Select',
          style: AppTextStyle.style_12_400(color: AppColors.grey900),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildSwitch(bool value, Function(bool) onChanged) {
    return SizedBox(
      width: 44.w,
      height: 28.h,
      child: Transform.scale(
        scale: 0.7,
        alignment: Alignment.centerRight,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.white,
          activeTrackColor: AppColors.primary,
          inactiveTrackColor: AppColors.grey100,
          inactiveThumbColor: AppColors.white,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  Widget _buildRecurringTask(BuildContext context, CreatePaymentReminderController controller) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Recurring Setup',
            style: AppTextStyle.style_12_400(color: AppColors.black),
          ),
        ),
        SizedBox(width: 6.w),
        Obx(
          () => _buildSwitch(controller.isRecurring.value, (val) async {
            if (val) {
              // Open Recurrence Dialog
              final result = await Get.dialog<RecurrenceData>(
                AppointmentRecurrenceDialog(
                  initialData: controller.recurrenceData.value,
                  defaultStartDate: controller.selectedReminderSetupDate.value,
                ),
              );
              if (result != null) {
                controller.recurrenceData.value = result;
                controller.selectedReminderSetupDate.value = result.startDate;
                controller.selectedReminderTime.value = controller.parseTimeOfDay(
                  result.startTime,
                );
                controller.isRecurring.value = true;
              } else {
                controller.isRecurring.value = false;
              }
            } else {
              controller.isRecurring.value = false;
              controller.recurrenceData.value = null;
            }
          }),
        ),
      ],
    );
  }
}
