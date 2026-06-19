import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/collections/controllers/old_collections_controller.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';

class OldCollectionsFilters extends StatelessWidget {
  const OldCollectionsFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OldCollectionsController>();

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
          int crossAxis = isMobile ? 1 : 3;

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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Obx(
                      () => MultiSelectDropdownWidget<String>(
                        label: 'Select Unit',
                        isSingleSelect: true,
                        selectedValues: controller.selectedUnit.value != null ? {controller.selectedUnit.value!} : {},
                        items: controller.unitOptions
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
                          if (controller.selectedUnit.value != newVal) {
                            controller.selectedUnit.value = newVal;
                            controller.applyFilters();
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Obx(
                      () => MultiSelectDropdownWidget<String>(
                        label: 'Select Month & Year',
                        isSingleSelect: true,
                        selectedValues: controller.selectedMonthYear.value != null ? {controller.selectedMonthYear.value!} : {},
                        items: controller.monthYearOptions
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
                          if (controller.selectedMonthYear.value != newVal) {
                            controller.selectedMonthYear.value = newVal;
                            controller.applyFilters();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
