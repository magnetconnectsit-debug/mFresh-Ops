import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/inventory/controllers/unit_inventory_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';

class UnitInventoryFilters extends StatelessWidget {
  const UnitInventoryFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UnitInventoryController>();

    return Obx(() {
      final authRepo = Get.find<AuthRepository>();
      final userPermissions = authRepo.rxUserPermissions;

      final canFilterUnit = userPermissions.contains('U_Inv_Multi_Unit_Filter');
      final canFilterItem = userPermissions.contains('U_Inv_Multi_Item_Filter');

      return Container(
        padding: EdgeInsets.all(6.r),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            int crossAxis = isMobile ? 2 : 4;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 4.w, top: 2.h, bottom: 8.h),
                  child: Text(
                    'Filters',
                    style: AppTextStyle.style_14_600(color: AppColors.black),
                  ),
                ),
                GridView(
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxis,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.h,
                    mainAxisExtent: 34.h,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    if (canFilterUnit) ...[
                      Obx(
                        () => MultiSelectDropdownWidget<String>(
                          label: 'Select Unit',
                          selectedValues: controller.selectedUnits.toList().toSet(),
                          items: controller.unitOptions
                              .map<DropdownMenuItem<String>>((e) => DropdownMenuItem<String>(
                                    value: e.value,
                                    child: Text(e.label, style: AppTextStyle.style_12_400(color: AppColors.grey900)),
                                  ))
                              .toList(),
                          onChanged: (values) {
                            controller.selectedUnits.assignAll(values.toList());
                            controller.applyFilters();
                          },
                        ),
                      ),
                    ],
                    if (canFilterItem) ...[
                      Obx(
                        () => MultiSelectDropdownWidget<String>(
                          label: 'Select Category',
                          selectedValues: controller.selectedCategories.toList().toSet(),
                          items: controller.categoryOptions
                              .map<DropdownMenuItem<String>>((e) => DropdownMenuItem<String>(
                                    value: e.value,
                                    child: Text(e.label, style: AppTextStyle.style_12_400(color: AppColors.grey900)),
                                  ))
                              .toList(),
                          onChanged: (values) {
                            controller.selectedCategories.assignAll(values.toList());
                            controller.applyFilters();
                          },
                        ),
                      ),
                      Obx(
                        () => MultiSelectDropdownWidget<String>(
                          label: 'Select Item',
                          selectedValues: controller.selectedItems.toList().toSet(),
                          items: controller.itemOptions
                              .map<DropdownMenuItem<String>>((e) => DropdownMenuItem<String>(
                                    value: e.value,
                                    child: Text(e.label, style: AppTextStyle.style_12_400(color: AppColors.grey900)),
                                  ))
                              .toList(),
                          onChanged: (values) {
                            controller.selectedItems.assignAll(values.toList());
                            controller.applyFilters();
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            );
          },
        ),
      );
    });
  }
}
