import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';

class StoreInventoryFilters extends StatelessWidget {
  const StoreInventoryFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InventoryController>();

    return Obx(() {
      final authRepo = Get.find<AuthRepository>();
      final userPermissions = authRepo.rxUserPermissions;

      final canFilterStateDistrict = userPermissions.contains('S_Inv_S_D_Store_Filter');
      final canFilterStore = userPermissions.contains('S_Inv_Multi_Store_Filter');
      final canFilterItem = userPermissions.contains('S_Inv_Multi_Item_Filter');

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
                    if (canFilterStateDistrict) ...[
                      Obx(
                        () => MultiSelectDropdownWidget<String>(
                          label: 'Select State',
                          isSingleSelect: true,
                          selectedValues: controller.selectedState.value != null ? {controller.selectedState.value!} : {},
                          items: controller.stateOptions
                              .map<DropdownMenuItem<String>>(
                                (opt) => DropdownMenuItem<String>(
                                  value: opt.value,
                                  child: Text(
                                    opt.label,
                                    style: AppTextStyle.style_12_400(color: AppColors.grey900),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (values) {
                            final newVal = values.isNotEmpty ? values.first : null;
                            if (controller.selectedState.value != newVal) {
                              controller.selectedState.value = newVal;
                              controller.selectedDistrict.value = null;
                              controller.selectedStoreRoom.value = null;
                              controller.selectedStore.value = null;
                              controller.districtOptions.clear();
                              controller.storeOptions.clear();
                              if (newVal != null) {
                                controller.fetchDistricts(newVal);
                              }
                              controller.applyFilters();
                            }
                          },
                        ),
                      ),
                      Obx(() {
                        return MultiSelectDropdownWidget<String>(
                          label: 'Select District',
                          isSingleSelect: true,
                          selectedValues: controller.selectedDistrict.value != null ? {controller.selectedDistrict.value!} : {},
                          items: controller.selectedState.value == null ? [] : controller.districtOptions
                              .map<DropdownMenuItem<String>>(
                                (opt) => DropdownMenuItem<String>(
                                  value: opt.value,
                                  child: Text(
                                    opt.label,
                                    style: AppTextStyle.style_12_400(color: AppColors.grey900),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (values) {
                            final newVal = values.isNotEmpty ? values.first : null;
                            if (controller.selectedDistrict.value != newVal) {
                              controller.selectedDistrict.value = newVal;
                              controller.selectedStoreRoom.value = null;
                              controller.selectedStore.value = null;
                              controller.storeOptions.clear();
                              if (newVal != null && controller.selectedState.value != null) {
                                controller.fetchStores(controller.selectedState.value!, newVal);
                              }
                              controller.applyFilters();
                            }
                          },
                        );
                      }),
                    ],
                    if (canFilterStore) ...[
                      Obx(() {
                        return MultiSelectDropdownWidget<String>(
                          label: 'Select Store Room',
                          isSingleSelect: true,
                          selectedValues: controller.selectedStoreRoom.value != null ? {controller.selectedStoreRoom.value!} : {},
                          items: controller.selectedState.value == null ? [] : controller.storeOptions
                              .map<DropdownMenuItem<String>>(
                                (opt) => DropdownMenuItem<String>(
                                  value: opt.value,
                                  child: Text(
                                    opt.label,
                                    style: AppTextStyle.style_12_400(color: AppColors.grey900),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (values) {
                            controller.selectedStoreRoom.value = values.isNotEmpty ? values.first : null;
                            controller.applyFilters();
                          },
                        );
                      }),
                      Obx(() {
                        return MultiSelectDropdownWidget<String>(
                          label: 'Select Store',
                          isSingleSelect: true,
                          selectedValues: controller.selectedStore.value != null ? {controller.selectedStore.value!} : {},
                          items: controller.selectedState.value == null ? [] : controller.storeOptions
                              .map<DropdownMenuItem<String>>(
                                (opt) => DropdownMenuItem<String>(
                                  value: opt.value,
                                  child: Text(
                                    opt.label,
                                    style: AppTextStyle.style_12_400(color: AppColors.grey900),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (values) {
                            controller.selectedStore.value = values.isNotEmpty ? values.first : null;
                            controller.applyFilters();
                          },
                        );
                      }),
                    ],
                    if (canFilterItem) ...[
                      Obx(
                        () => MultiSelectDropdownWidget<String>(
                          label: 'Select Category',
                          selectedValues: controller.selectedCategories.toSet(),
                          items: controller.categoryOptions
                              .map<DropdownMenuItem<String>>(
                                (opt) => DropdownMenuItem<String>(
                                  value: opt.value,
                                  child: Text(
                                    opt.label,
                                    style: AppTextStyle.style_12_400(color: AppColors.grey900),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (values) {
                            controller.selectedCategories.assignAll(values.toList());
                            controller.selectedItems.clear();
                            controller.applyFilters();
                          },
                        ),
                      ),
                      Obx(
                        () => MultiSelectDropdownWidget<String>(
                          label: 'Select Item(s)',
                          selectedValues: controller.selectedItems.toSet(),
                          items: controller.itemOptions
                              .map<DropdownMenuItem<String>>(
                                (opt) => DropdownMenuItem<String>(
                                  value: opt.value,
                                  child: Text(
                                    opt.label,
                                    style: AppTextStyle.style_12_400(color: AppColors.grey900),
                                  ),
                                ),
                              )
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
