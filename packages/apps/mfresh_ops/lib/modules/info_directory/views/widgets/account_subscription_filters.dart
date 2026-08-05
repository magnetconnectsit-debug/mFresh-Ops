import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/account_subscription_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';

class AccountSubscriptionFilters extends StatelessWidget {
  final AccountSubscriptionController controller;

  const AccountSubscriptionFilters({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSearchField(
                  'Unit / Location',
                  controller.unitLocationCtrl,
                  (v) => controller.applyFilters(debounce: true),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildSearchField(
                  'Company / Brand',
                  controller.companyBrandCtrl,
                  (v) => controller.applyFilters(debounce: true),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => MultiSelectDropdownWidget<String>(
                    label: 'Account(s)',
                    isSingleSelect: false,
                    selectedValues: controller.selectedAccount.toSet(),
                    items: controller.accountList
                        .map((acc) => DropdownMenuItem(
                              value: acc.id.toString(),
                              child: Text(acc.accountName),
                            ))
                        .toList(),
                    onChanged: (values) {
                      controller.selectedAccount.assignAll(values);
                      controller.applyFilters();
                    },
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Obx(
                  () => MultiSelectDropdownWidget<String>(
                    label: 'Payment',
                    isSingleSelect: true,
                    selectedValues: controller.selectedPayment.value.isNotEmpty
                        ? {controller.selectedPayment.value}
                        : {},
                    items: const [
                      DropdownMenuItem(value: '1', child: Text('Yes')),
                      DropdownMenuItem(value: '0', child: Text('No')),
                    ],
                    onChanged: (values) {
                      if (values.isNotEmpty) {
                        controller.selectedPayment.value = values.first;
                      } else {
                        controller.selectedPayment.value = '';
                      }
                      controller.applyFilters();
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(
    String hint,
    TextEditingController textController,
    Function(String) onChanged,
  ) {
    return TextField(
      controller: textController,
      onChanged: onChanged,
      style: AppTextStyle.style_12_400(color: AppColors.grey900),
      decoration: InputDecoration(
        labelText: hint,
        hintText: 'Search',
        hintStyle: AppTextStyle.style_12_400(color: AppColors.grey200),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: AppTextStyle.style_12_400(color: AppColors.grey200),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: const BorderSide(
            color: AppColors.borderColor,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: const BorderSide(
            color: AppColors.borderColor,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: const BorderSide(color: Color(0xffF15A24), width: 1.5),
        ),
      ),
    );
  }
}
