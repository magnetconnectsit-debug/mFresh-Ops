// region Imports
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/info_directory_controller.dart';
// endregion

// region InfoDirectoryFilterCard Widget
class InfoDirectoryFilterCard extends StatelessWidget {
  // region Properties
  final InfoDirectoryController controller;
  // endregion

  // region Constructor
  const InfoDirectoryFilterCard({super.key, required this.controller});
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
                child: Obx(
                  () => AppCommonMultiSelectDropdown<String>(
                    label: 'Brand',
                    selectedValues: controller.selectedBrands.value,
                    items: controller.availableBrands
                        .map(
                          (brand) => DropdownMenuItem(
                            value: brand['id'].toString(),
                            child: Text(brand['name']?.toString() ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: (values) {
                      controller.selectedBrands.value = values.toSet();
                      controller.applyFilters();
                    },
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Obx(
                  () => AppCommonMultiSelectDropdown<String>(
                    label: 'Company',
                    selectedValues: controller.selectedCompanies.value,
                    items: controller.availableCompanies
                        .map(
                          (company) => DropdownMenuItem(
                            value: company['id'].toString(),
                            child: Text(company['name']?.toString() ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: (values) {
                      controller.selectedCompanies.value = values.toSet();
                      controller.applyFilters();
                    },
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
                  () => AppCommonMultiSelectDropdown<String>(
                    label: 'Contact Type',
                    isSingleSelect: true,
                    selectedValues: controller.contactType.value.isNotEmpty
                        ? {controller.contactType.value}
                        : {},
                    items: controller.availableContactTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: (values) {
                      if (values.isNotEmpty) {
                        controller.contactType.value = values.first;
                      } else {
                        controller.contactType.value = '';
                      }
                      controller.applyFilters();
                    },
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
  // endregion
}
// endregion
