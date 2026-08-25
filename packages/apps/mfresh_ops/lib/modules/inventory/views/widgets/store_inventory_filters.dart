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
        padding: EdgeInsets.all(4.r),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
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
                  padding: EdgeInsets.only(left: 4.w, top: 2.h, bottom: 4.h),
                  child: Text(
                    'Filters',
                    style: AppTextStyle.style_14_600(color: AppColors.black),
                  ),
                ),
                GridView(
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxis,
                    crossAxisSpacing: 4.w,
                    mainAxisSpacing: 4.h,
                    mainAxisExtent: 28.h,
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
                              controller.selectedStoreRoom.clear();
                              controller.selectedStore.clear();
                              controller.districtOptions.clear();
                              if (newVal != null) {
                                controller.fetchDistricts(newVal);
                                controller.fetchStoreRooms(newVal, '');
                              } else {
                                controller.fetchStoreRooms('', '');
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
                              controller.selectedStoreRoom.clear();
                              controller.selectedStore.clear();
                              if (newVal != null) {
                                controller.fetchStoreRooms(controller.selectedState.value ?? '', newVal);
                              } else {
                                controller.fetchStoreRooms(controller.selectedState.value ?? '', '');
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
                          selectedValues: controller.selectedStoreRoom.toSet(),
                          items: controller.storeRoomOptions
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
                            controller.selectedStoreRoom.assignAll(values.toList());
                            controller.applyFilters();
                          },
                        );
                      }),
                      Obx(() {
                        return MultiSelectDropdownWidget<String>(
                          label: 'Select Store',
                          selectedValues: controller.selectedStore.toSet(),
                          items: controller.storeOptions
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
                            controller.selectedStore.assignAll(values.toList());
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
                          onChanged: (values) async {
                            controller.selectedCategories.assignAll(values.toList());
                            controller.selectedItems.clear();
                            await controller.fetchItemsForSelectedCategories();
                            controller.applyFilters();
                          },
                        ),
                      ),
                      Obx(
                        () => MultiSelectDropdownWidget<String>(
                          label: 'Select Item',
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
