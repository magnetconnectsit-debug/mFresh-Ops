import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/collections/controllers/admin_collections_controller.dart';
import 'package:mfresh_ops/modules/collections/views/widgets/month_year_picker_field.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';

class AdminCollectionsFilters extends StatelessWidget {
  const AdminCollectionsFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminCollectionsController>();

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
      child: Column(
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
              Obx(() {
                final dateSelected = controller.selectedDate.value != null;
                final monthSelected = controller.selectedMonth.value != null;

                return GridView(
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    mainAxisExtent: 34.h,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    MultiSelectDropdownWidget<String>(
                      label: 'Select State',
                      isSingleSelect: true,
                      selectedValues: controller.selectedState.value != null ? {controller.selectedState.value!} : {},
                      items: controller.stateOptions.map((opt) => DropdownMenuItem(value: opt.value, child: Text(opt.label, style: AppTextStyle.style_12_400(color: AppColors.grey900)))).toList(),
                      onChanged: (v) {
                        controller.onStateSelected(v.isNotEmpty ? v.first : null);
                        controller.fetchCollections();
                      },
                    ),
                    MultiSelectDropdownWidget<String>(
                      label: 'Select District',
                      isSingleSelect: true,
                      selectedValues: controller.selectedDistrict.value != null ? {controller.selectedDistrict.value!} : {},
                      items: controller.districtOptions.map((opt) => DropdownMenuItem(value: opt.value, child: Text(opt.label, style: AppTextStyle.style_12_400(color: AppColors.grey900)))).toList(),
                      onChanged: (v) {
                        controller.selectedDistrict.value = v.isNotEmpty ? v.first : null;
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
                      Builder(
                        builder: (context) {
                          DateTime initialDate = DateTime.now();
                          DateTime firstDate = DateTime(2020);
                          DateTime lastDate = DateTime(2101);

                          return _buildDateField(
                            label: 'Select Date',
                            hint: 'Select Date',
                            icon: Icons.calendar_today_outlined,
                            value: controller.selectedDate.value,
                            onClear: () {
                              controller.selectedDate.value = null;
                              controller.fetchCollections();
                            },
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: initialDate,
                                firstDate: firstDate,
                                lastDate: lastDate,
                              );
                              if (picked != null) {
                                controller.selectedDate.value = DateFormat('dd-MMM-yyyy').format(picked);
                                controller.fetchCollections();
                              }
                            },
                          );
                        }
                      ),
                  ],
                );
              }),
            ],
      ),
    );
  }

  Widget _buildDateField({
    required String label, 
    required String hint, 
    required IconData icon,
    String? value,
    VoidCallback? onTap,
    VoidCallback? onClear,
  }) {
    return TextFormField(
      key: ValueKey(value),
      initialValue: value,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: AppTextStyle.style_12_400(color: AppColors.grey200),
        hintText: hint,
        hintStyle: AppTextStyle.style_12_400(color: AppColors.grey300),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        suffixIcon: value != null && onClear != null 
          ? GestureDetector(
              onTap: onClear,
              child: Icon(Icons.close, size: 14.r, color: AppColors.grey300),
            )
          : Icon(icon, size: 16.r, color: AppColors.grey300),
        suffixIconConstraints: BoxConstraints(minWidth: 32.w, minHeight: 16.r),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(color: AppColors.borderColor, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(color: AppColors.borderColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(color: AppColors.borderColor, width: 1.0),
        ),
      ),
      style: AppTextStyle.style_12_400(color: AppColors.black),
    );
  }
}
