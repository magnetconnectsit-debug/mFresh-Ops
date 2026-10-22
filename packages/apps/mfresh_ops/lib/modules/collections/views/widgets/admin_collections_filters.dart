// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/collections/controllers/admin_collections_controller.dart';
// endregion

// region AdminCollectionsFilters Widget
class AdminCollectionsFilters extends StatelessWidget {
  // region Constructor
  const AdminCollectionsFilters({super.key});
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminCollectionsController>();

    return Container(
      padding: EdgeInsets.all(4.r),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
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
          Obx(() {
            final dateSelected = controller.selectedDate.value != null;
            final monthSelected = controller.selectedMonth.value != null;

            DateTime? parsedDate;
            if (dateSelected) {
              try {
                parsedDate = DateFormat('dd-MMM-yyyy').parse(controller.selectedDate.value!);
              } catch (_) {}
            }

            return GridView(
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4.w,
                mainAxisSpacing: 4.h,
                mainAxisExtent: 28.h,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                AppCommonMultiSelectDropdown<String>(
                  label: 'Select State',
                  isSingleSelect: true,
                  selectedValues: controller.selectedState.value != null
                      ? {controller.selectedState.value!}
                      : {},
                  items: controller.stateOptions
                      .map((opt) => DropdownMenuItem(
                            value: opt.value,
                            child: Text(
                              opt.label,
                              style: AppTextStyle.style_12_400(
                                color: AppColors.grey900,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    controller.onStateSelected(v.isNotEmpty ? v.first : null);
                    controller.fetchCollections();
                  },
                ),
                AppCommonMultiSelectDropdown<String>(
                  label: 'Select District',
                  isSingleSelect: true,
                  selectedValues: controller.selectedDistrict.value != null
                      ? {controller.selectedDistrict.value!}
                      : {},
                  items: controller.districtOptions
                      .map((opt) => DropdownMenuItem(
                            value: opt.value,
                            child: Text(
                              opt.label,
                              style: AppTextStyle.style_12_400(
                                color: AppColors.grey900,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    controller.selectedDistrict.value =
                        v.isNotEmpty ? v.first : null;
                    controller.fetchCollections();
                  },
                ),
                if (!dateSelected)
                  MonthYearPickerField(
                    value: controller.selectedMonth.value,
                    label: 'Select Month',
                    onChanged: (v) {
                      controller.selectedMonth.value = v;
                      controller.fetchCollections();
                    },
                  ),
                if (!monthSelected)
                  AppCommonDateField(
                    labelText: 'Select Date',
                    hintText: 'Select Date',
                    selectedDate: parsedDate,
                    dateFormatter: (date) =>
                        DateFormat('dd-MMM-yyyy').format(date),
                    onDateSelected: (date) {
                      controller.selectedDate.value =
                          DateFormat('dd-MMM-yyyy').format(date);
                      controller.fetchCollections();
                    },
                    suffixIcon: dateSelected
                        ? GestureDetector(
                            onTap: () {
                              controller.selectedDate.value = null;
                              controller.fetchCollections();
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 6.w),
                              child: Icon(
                                Icons.close,
                                size: 14.r,
                                color: AppColors.grey300,
                              ),
                            ),
                          )
                        : null,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
  // endregion
}
// endregion
