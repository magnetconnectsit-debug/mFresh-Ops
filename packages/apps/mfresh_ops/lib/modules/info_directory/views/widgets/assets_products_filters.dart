import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/assignee_model.dart';
import 'package:mfresh_ops/data/models/info_directory/asset_category_model.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/assets_products_controller.dart';

class AssetsProductsFilters extends StatelessWidget {
  final AssetsProductsController controller;

  const AssetsProductsFilters({super.key, required this.controller});

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600;

          final itemTypeDropdown = Obx(
            () => MultiSelectDropdownWidget<String>(
              label: 'Item Type',
              hint: 'Item Type',
              isSingleSelect: true,
              selectedValues: controller.selectedItemType.value.isNotEmpty
                  ? {controller.selectedItemType.value}
                  : {},
              items: controller.availableItemTypes
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(
                        t,
                        style: AppTextStyle.style_12_500(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (values) {
                controller.selectedItemType.value =
                    values.isNotEmpty ? values.first : '';
                controller.applyFilters();
              },
            ),
          );

          final categoryDropdown = Obx(
            () => MultiSelectDropdownWidget<AssetCategoryModel>(
              label: 'Category',
              hint: 'Category',
              isLoading: controller.isFiltersLoading.value,
              selectedValues: controller.selectedCategories.toSet(),
              items: controller.availableCategories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(
                        c.assetCatName,
                        style: AppTextStyle.style_12_500(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (values) {
                controller.selectedCategories.assignAll(values);
                controller.applyFilters();
              },
            ),
          );

          final assigneeDropdown = Obx(
            () => MultiSelectDropdownWidget<AssigneeModel>(
              label: 'Assignee',
              hint: 'Assignee',
              isLoading: controller.isFiltersLoading.value,
              selectedValues: controller.selectedAssignees.toSet(),
              items: controller.availableAssignees
                  .map(
                    (a) => DropdownMenuItem(
                      value: a,
                      child: Text(
                        a.name,
                        style: AppTextStyle.style_12_500(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (values) {
                controller.selectedAssignees.assignAll(values);
                controller.applyFilters();
              },
            ),
          );

          if (isTablet) {
            return Row(
              children: [
                Expanded(child: itemTypeDropdown),
                SizedBox(width: 8.w),
                Expanded(child: categoryDropdown),
                SizedBox(width: 8.w),
                Expanded(child: assigneeDropdown),
              ],
            );
          }

          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: itemTypeDropdown),
                  SizedBox(width: 8.w),
                  Expanded(child: categoryDropdown),
                ],
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Expanded(child: assigneeDropdown),
                  SizedBox(width: 8.w),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
