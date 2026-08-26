import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/create_account_subscription_controller.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';

class CreateAccountSubscriptionScreen extends StatelessWidget {
  const CreateAccountSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateAccountSubscriptionController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const AppCommonAppBar().preferredSize,
        child: AppCommonAppBar(
          title: Obx(
            () => Text(
              controller.isEdit.value ? 'Update Account' : 'Create Account',
              style: AppTextStyle.style_18_700(color: AppColors.black),
            ),
          ),
          hasBackButton: true,
          showAppDrawer: false,
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
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 32.h,
                          child: Obx(() => MultiSelectDropdownWidget<String>(
                                label: 'Account',
                                isSingleSelect: true,
                                selectedValues: controller.selectedAccount.value.isEmpty
                                    ? {}
                                    : {controller.selectedAccount.value},
                                items: controller.accountList.map((acc) {
                                  return DropdownMenuItem(
                                    value: acc.id.toString(),
                                    child: Text(
                                      acc.accountName,
                                      style: AppTextStyle.style_12_400(color: AppColors.grey900),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val.isNotEmpty) {
                                    controller.selectedAccount.value = val.first;
                                  } else {
                                    controller.selectedAccount.value = '';
                                  }
                                },
                              )),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildTextField(
                          ctrl: controller.companyCtrl,
                          label: 'Company',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          ctrl: controller.brandCtrl,
                          label: 'Brand',
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildTextField(
                          ctrl: controller.serviceCtrl,
                          label: 'Service',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          ctrl: controller.unitCtrl,
                          label: 'Unit',
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildTextField(
                          ctrl: controller.cityCtrl,
                          label: 'City',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          ctrl: controller.locationCtrl,
                          label: 'Location',
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildTextField(
                          ctrl: controller.customerIdCtrl,
                          label: 'Customer ID',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          ctrl: controller.mobileNoCtrl,
                          label: 'Mobile No',
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildTextField(
                          ctrl: controller.emailCtrl,
                          label: 'Email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          ctrl: controller.userNameCtrl,
                          label: 'User Name',
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildTextField(
                          ctrl: controller.passwordCtrl,
                          label: 'Password',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          ctrl: controller.urlsCtrl,
                          label: 'URLs',
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildTextField(
                          ctrl: controller.remarksCtrl,
                          label: 'Remarks',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          ctrl: controller.planNameCtrl,
                          label: 'Plan Name',
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: SizedBox(
                          height: 32.h,
                          child: Obx(() => MultiSelectDropdownWidget<String>(
                                label: 'Payment',
                                isSingleSelect: true,
                                selectedValues: controller.selectedPayment.value.isEmpty
                                    ? {}
                                    : {controller.selectedPayment.value},
                                items: [
                                  DropdownMenuItem(value: '1', child: Text('Yes', style: AppTextStyle.style_12_400(color: AppColors.grey900))),
                                  DropdownMenuItem(value: '0', child: Text('No', style: AppTextStyle.style_12_400(color: AppColors.grey900))),
                                ],
                                onChanged: (val) {
                                  if (val.isNotEmpty) {
                                    controller.selectedPayment.value = val.first;
                                  } else {
                                    controller.selectedPayment.value = '';
                                  }
                                },
                              )),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          ctrl: controller.billingCycleCtrl,
                          label: 'Billing cycle & Due',
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Obx(
                          () => _buildDateField(
                            label: 'Next Due On',
                            value: controller.selectedNextDue.value,
                            onTap: () => controller.selectDate(
                                context, controller.selectedNextDue),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => _buildDateField(
                            label: 'Last Payment',
                            value: controller.selectedLastPayment.value,
                            onTap: () => controller.selectDate(
                                context, controller.selectedLastPayment),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  _buildTextField(
                    ctrl: controller.paymentDetailsCtrl,
                    label: 'Payment Details',
                    maxLines: 2,
                  ),
                  SizedBox(height: 8.h),
                  _buildTextField(
                    ctrl: controller.commentsCtrl,
                    label: 'Comments',
                    maxLines: 1,
                  ),
                  SizedBox(height: 32.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 30.h,
                        width: 80.w,
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.borderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTextStyle.style_12_600(color: AppColors.black),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Obx(
                        () => SizedBox(
                          height: 30.h,
                          width: 80.w,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B35),
                              disabledBackgroundColor:
                                  const Color(0xFFFF6B35).withValues(alpha: 0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              padding: EdgeInsets.zero,
                              elevation: 0,
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
                                    style: AppTextStyle.style_12_600(
                                      color: AppColors.white,
                                    ),
                                  ),
                          ),
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
    required TextEditingController ctrl,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    TextStyle? style,
  }) {
    return SizedBox(
      height: maxLines == 1 ? 32.h : null,
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        textAlignVertical: TextAlignVertical.center,
        style: style ?? AppTextStyle.style_12_400(color: AppColors.grey900),
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          suffixIconConstraints: suffixIcon != null
              ? BoxConstraints(maxHeight: 32.h, minWidth: 32.w)
              : null,
          label: RichText(
            text: TextSpan(
              text: label.replaceAll('*', ''),
              style: AppTextStyle.style_12_400(color: AppColors.grey200),
              children: label.contains('*')
                  ? [
                      const TextSpan(
                        text: '*',
                        style: TextStyle(color: Colors.red),
                      ),
                    ]
                  : [],
            ),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          counterText: '',
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
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return SizedBox(
      height: 32.h,
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        style: AppTextStyle.style_12_400(color: AppColors.grey900),
        icon: Icon(Icons.keyboard_arrow_down, size: 20.r, color: Colors.grey),
        decoration: InputDecoration(
          label: RichText(
            text: TextSpan(
              text: label.replaceAll('*', ''),
              style: AppTextStyle.style_12_400(color: AppColors.grey200),
              children: label.contains('*')
                  ? [
                      const TextSpan(
                        text: '*',
                        style: TextStyle(color: Colors.red),
                      ),
                    ]
                  : [],
            ),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: const BorderSide(color: AppColors.borderColor, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: const BorderSide(color: AppColors.borderColor, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: const BorderSide(color: Color(0xffF15A24), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required String? value,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 32.h,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4.r),
        child: InputDecorator(
          decoration: InputDecoration(
            label: RichText(
              text: TextSpan(
                text: label.replaceAll('*', ''),
                style: AppTextStyle.style_12_400(color: AppColors.grey200),
                children: label.contains('*')
                    ? [
                        const TextSpan(
                          text: '*',
                          style: TextStyle(color: Colors.red),
                        ),
                      ]
                    : [],
              ),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: const BorderSide(color: AppColors.borderColor, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: const BorderSide(color: AppColors.borderColor, width: 1.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value == null ? 'Select Date' : AppDateUtils.formatToOrdinalDate(value),
                  style: value == null 
                      ? AppTextStyle.style_12_400(color: AppColors.grey300).copyWith(fontSize: 11.sp)
                      : AppTextStyle.style_12_400(color: AppColors.grey900).copyWith(fontSize: 11.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.calendar_today, size: 14.sp, color: AppColors.grey200),
            ],
          ),
        ),
      ),
    );
  }
}
