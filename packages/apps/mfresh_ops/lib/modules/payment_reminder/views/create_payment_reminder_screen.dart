import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';

import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/modules/payment_reminder/controllers/create_payment_reminder_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';
import 'package:mfresh_ops/data/models/payment_reminder/payment_reminder_model.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:mfresh_ops/modules/payment_reminder/views/widgets/reminder_setup_dialog.dart';
import 'package:mfresh_ops/modules/payment_reminder/views/widgets/edit_reminder_date_dialog.dart';

class CreatePaymentReminderScreen extends StatelessWidget {
  final PaymentReminderItem? reminderItem;

  const CreatePaymentReminderScreen({super.key, this.reminderItem});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<CreatePaymentReminderController>()) {
      Get.delete<CreatePaymentReminderController>();
    }
    final controller = Get.put(CreatePaymentReminderController(reminderItem: reminderItem));

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CommonSidebar(),
      appBar: PreferredSize(
        preferredSize: const AppCommonAppBar().preferredSize,
        child: Obx(
          () => AppCommonAppBar(
            title: Text(controller.isEditing.value ? 'Edit Payment Reminder' : 'Add Payment Reminder'),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 24.h),
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Reminder Form',
                    style: AppTextStyle.style_16_700(color: AppColors.black),
                  ),
                  SizedBox(height: 12.h),

                  // ── Assignee Field ─────────────────────────────────────────
                  Obx(
                    () {
                      final assigneeName = controller.selectedAssignee.value?.name;
                      return MultiSelectDropdownWidget<PaymentReminderUser>(
                        label: 'Assignee *',
                        hint: 'Select User',
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
                        onChanged: (values) => controller.selectedAssignee.value =
                            values.isEmpty ? null : values.first,
                        customChild: _buildDropdownField(
                          label: 'Assignee *',
                          hint: 'Select User',
                          value: assigneeName,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 14.h),

                  // ── Basic Details + Expense Details ────────────────────────
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final basicDetails = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Basic Details',
                            style: AppTextStyle.style_14_700(color: AppColors.black),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: controller.forCtrl,
                                  label: 'For *',
                                  hint: 'Enter For',
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: _buildTextField(
                                  controller: controller.brandCtrl,
                                  label: 'Brand',
                                  hint: 'Enter Brand',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: controller.customerIdCtrl,
                                  label: 'Customer ID',
                                  hint: 'Enter Customer ID',
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: _buildTextField(
                                  controller: controller.locationCtrl,
                                  label: 'Location',
                                  hint: 'Enter Location',
                                ),
                              ),
                            ],
                          ),
                        ],
                      );

                      final expenseDetails = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Expense Details',
                            style: AppTextStyle.style_14_700(color: AppColors.black),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: controller.expenseHeadCtrl,
                                  label: 'Expense Head',
                                  hint: 'Enter Expense Head',
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Obx(
                                  () {
                                    final expType = controller.selectedExpenseType.value;
                                    return MultiSelectDropdownWidget<String>(
                                      label: 'CAPEX/OPEX',
                                      hint: 'Select',
                                      isSingleSelect: true,
                                      showSearch: false,
                                      selectedValues: expType == null ? <String>{} : {expType},
                                      items: controller.expenseTypes
                                          .map((e) => DropdownMenuItem<String>(
                                                value: e,
                                                child: Text(
                                                  e,
                                                  style: AppTextStyle.style_12_400(color: AppColors.grey900),
                                                ),
                                              ))
                                          .toList(),
                                      onChanged: (values) => controller.selectedExpenseType.value =
                                          values.isEmpty ? null : values.first,
                                      customChild: _buildDropdownField(
                                        label: 'CAPEX/OPEX',
                                        hint: 'Select',
                                        value: expType,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: controller.subHeadCtrl,
                                  label: 'Sub Head',
                                  hint: 'Enter Sub Head',
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: _buildTextField(
                                  controller: controller.costCenterCtrl,
                                  label: 'Cost Centre',
                                  hint: 'Enter Cost Centre',
                                ),
                              ),
                            ],
                          ),
                        ],
                      );

                      if (constraints.maxWidth > 700) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: basicDetails),
                            SizedBox(width: 16.w),
                            Expanded(child: expenseDetails),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          basicDetails,
                          SizedBox(height: 14.h),
                          expenseDetails,
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 14.h),

                  // ── Reminder Details ───────────────────────────────────────
                  Text(
                    'Reminder Details',
                    style: AppTextStyle.style_14_700(color: AppColors.black),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => _buildDateTimeField(
                            label: 'Due Date',
                            hint: 'Select Date',
                            icon: Icons.calendar_today_outlined,
                            value: controller.selectedDueDate.value != null
                                ? AppDateUtils.formatToShortOrdinalDate(
                                    controller.selectedDueDate.value!,
                                  )
                                : null,
                            onTap: () async {
                              final now = DateTime.now();
                              final today = DateTime(now.year, now.month, now.day);
                              final rawInitial = controller.selectedDueDate.value ?? today;
                              final initialDate = rawInitial.isBefore(today) ? today : rawInitial;
                              final date = await showDatePicker(
                                context: context,
                                initialDate: initialDate,
                                firstDate: today,
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                controller.selectedDueDate.value = date;
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _buildTextField(
                          controller: controller.remindBeforeCtrl,
                          label: 'Reminder Before',
                          hint: '0',
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => _buildDateTimeField(
                            label: 'Reminder Setup *',
                            hint: 'Set Reminder',
                            icon: Icons.keyboard_arrow_down_rounded,
                            value: _getReminderSetupDisplayText(controller, context),
                            onTap: () {
                              if (controller.isEditing.value) {
                                EditReminderDateDialog.show(context, controller);
                              } else {
                                ReminderSetupDialog.show(context, controller);
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _buildTextField(
                          controller: controller.additionalNumberCtrl,
                          label: 'Alternative Number',
                          hint: 'Enter Alternative Number',
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // ── Action Buttons ──────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppCommonButton(
                        text: 'Cancel',
                        variant: ButtonVariant.outline,
                        isSmall: true,
                        height: 32.h,
                        width: 90.w,
                        onPressed: () => Get.back(),
                      ),
                      SizedBox(width: 12.w),
                      Obx(
                        () => AppCommonButton(
                          text: 'Submit',
                          variant: ButtonVariant.primary,
                          isSmall: true,
                          isLoading: controller.isLoading.value,
                          height: 32.h,
                          width: 110.w,
                          onPressed: controller.submit,
                        ),
                      ),
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
    String? hint,
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
        hintText: hint ?? 'Enter $label',
        hintStyle: AppTextStyle.style_12_400(color: AppColors.grey300).copyWith(fontSize: 11.sp),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: AppTextStyle.style_12_400(color: AppColors.grey200),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: maxLines > 1 ? 6.h : 4.h,
        ),
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
        isDense: true,
      ),
      style: AppTextStyle.style_12_400(color: AppColors.grey900),
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

  String? _getReminderSetupDisplayText(
    CreatePaymentReminderController controller,
    BuildContext context,
  ) {
    final date = controller.selectedReminderSetupDate.value;
    final time = controller.selectedReminderTime.value;
    final isRecurring = controller.isRecurring.value;

    if (date == null && time == null && !isRecurring) return null;

    final List<String> parts = [];
    if (isRecurring && date != null) {
      parts.add(AppDateUtils.formatToShortOrdinalDate(date));
    }
    if (time != null) {
      parts.add(time.format(context));
    }
    if (isRecurring) {
      parts.add('(Recurring)');
    }

    return parts.isEmpty ? null : parts.join(' ');
  }
}
