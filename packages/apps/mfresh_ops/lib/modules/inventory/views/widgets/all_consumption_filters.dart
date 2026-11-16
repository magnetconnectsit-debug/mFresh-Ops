import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/inventory/controllers/consumption_controller.dart';

class AllConsumptionFilters extends StatelessWidget {
  const AllConsumptionFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConsumptionController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Cards Container
        Container(
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
              final int crossAxis = isMobile ? 2 : 4;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 8.h),
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
                      // 1. Single Date Range Field
                      _buildDateRangeField(context, controller),

                      // 2. Unit Dropdown
                      Obx(
                        () => MultiSelectDropdownWidget<String>(
                          label: 'Select Unit',
                          selectedValues: controller.selectedUnits.toSet(),
                          items: controller.unitOptions
                              .map<DropdownMenuItem<String>>(
                                (opt) => DropdownMenuItem<String>(
                                  value: opt.value,
                                  child: Text(
                                    opt.label,
                                    style: AppTextStyle.style_12_400(
                                      color: AppColors.grey900,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (values) {
                            controller.selectedUnits.assignAll(values.toList());
                            controller.applyFilters();
                          },
                        ),
                      ),

                      // 3. Item Dropdown
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
                                    style: AppTextStyle.style_12_400(
                                      color: AppColors.grey900,
                                    ),
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

                      // 4. Store Dropdown
                      Obx(
                        () => MultiSelectDropdownWidget<String>(
                          label: 'Select Store',
                          selectedValues: controller.selectedStores.toSet(),
                          items: controller.storeOptions
                              .map<DropdownMenuItem<String>>(
                                (opt) => DropdownMenuItem<String>(
                                  value: opt.value,
                                  child: Text(
                                    opt.label,
                                    style: AppTextStyle.style_12_400(
                                      color: AppColors.grey900,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (values) {
                            controller.selectedStores.assignAll(values.toList());
                            controller.applyFilters();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),

        // Action Row: Export & Per Page Count
        _buildActionButtons(controller),
      ],
    );
  }

  Widget _buildDateRangeField(
    BuildContext context,
    ConsumptionController controller,
  ) {
    return InkWell(
      onTap: () => controller.selectDateRange(context),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller.fromDateController,
        builder: (context, fromVal, child) {
          return ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller.toDateController,
            builder: (context, toVal, child) {
              final hasDates = fromVal.text.isNotEmpty && toVal.text.isNotEmpty;
              final displayText = hasDates
                  ? '${fromVal.text} - ${toVal.text}'
                  : '';

              return InputDecorator(
                decoration: InputDecoration(
                  label: RichText(
                    text: TextSpan(
                      text: 'Select Date Range',
                      style: AppTextStyle.style_11_400(
                        color: AppColors.grey200,
                      ),
                    ),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 3.0.h,
                  ),
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
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        displayText.isEmpty ? 'Select Date Range' : displayText,
                        style: displayText.isEmpty
                            ? AppTextStyle.style_12_400(
                                color: AppColors.grey300,
                              ).copyWith(fontSize: 11.sp)
                            : AppTextStyle.style_12_400(
                                color: AppColors.grey900,
                              ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.grey300,
                      size: 14.r,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(ConsumptionController controller) {
    final authRepo = Get.find<AuthRepository>();
    final hasExport = authRepo.rxUserPermissions.contains('Consumption_export');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        children: [
          if (hasExport)
            AppCommonExportButton(
              onExportExcel: () => controller.exportToExcel(),
            ),
          const Spacer(),
          Obx(
            () => Container(
              height: 28.h,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.borderColor),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: controller.perPage.value,
                  dropdownColor: AppColors.white,
                  style: AppTextStyle.style_12_500(color: AppColors.black),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    size: 16.r,
                    color: AppColors.black,
                  ),
                  items: [10, 20, 50, 100, 500, 1000].map((int val) {
                    return DropdownMenuItem<int>(
                      value: val,
                      child: Text('$val per page'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      controller.perPage.value = val;
                      controller.applyFilters();
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
