// region Imports
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/account_subscription_controller.dart';
// endregion

// region AccountSubscriptionFilters Widget
class AccountSubscriptionFilters extends StatelessWidget {
  // region Properties
  final AccountSubscriptionController controller;
  // endregion

  // region Constructor
  const AccountSubscriptionFilters({super.key, required this.controller});
  // endregion

  // region Main Build
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
                child: AppCommonTextField(
                  controller: controller.unitLocationCtrl,
                  labelText: 'Unit / Location',
                  hintText: 'Search',
                  height: 22.h,
                  onChanged: (v) => controller.applyFilters(debounce: true),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: AppCommonTextField(
                  controller: controller.companyBrandCtrl,
                  labelText: 'Company / Brand',
                  hintText: 'Search',
                  height: 22.h,
                  onChanged: (v) => controller.applyFilters(debounce: true),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => AppCommonMultiSelectDropdown<String>(
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
                  () => AppCommonMultiSelectDropdown<String>(
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
  // endregion
}
// endregion
