import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/info_directory_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';

class InfoDirectoryFilterCard extends StatelessWidget {
  final InfoDirectoryController controller;

  const InfoDirectoryFilterCard({super.key, required this.controller});

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
                  () => MultiSelectDropdownWidget<String>(
                    label: 'Brand',
                    selectedValues: controller.selectedBrands.value,
                    items: controller.availableBrands
                        .map((brand) => DropdownMenuItem(
                              value: brand['id'].toString(),
                              child: Text(brand['name']?.toString() ?? ''),
                            ))
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
                  () => MultiSelectDropdownWidget<String>(
                    label: 'Company',
                    selectedValues: controller.selectedCompanies.value,
                    items: controller.availableCompanies
                        .map((company) => DropdownMenuItem(
                              value: company['id'].toString(),
                              child: Text(company['name']?.toString() ?? ''),
                            ))
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
                  () => MultiSelectDropdownWidget<String>(
                    label: 'Contact Type',
                    isSingleSelect: true,
                    selectedValues: controller.contactType.value.isNotEmpty
                        ? {controller.contactType.value}
                        : {},
                    items: controller.availableContactTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
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
              const Expanded(
                child: SizedBox(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(String hint, TextEditingController textController, Function(String) onChanged) {
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
