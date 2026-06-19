import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/collections/controllers/admin_collections_controller.dart';
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
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
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  mainAxisExtent: 34.h,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Obx(() => MultiSelectDropdownWidget<String>(
                    label: 'Select State',
                    isSingleSelect: true,
                    selectedValues: controller.selectedState.value != null ? {controller.selectedState.value!} : {},
                    items: controller.stateOptions.map((opt) => DropdownMenuItem(value: opt.value, child: Text(opt.label, style: AppTextStyle.style_12_400(color: AppColors.grey900)))).toList(),
                    onChanged: (v) {
                      controller.selectedState.value = v.isNotEmpty ? v.first : null;
                    },
                  )),
                  Obx(() => MultiSelectDropdownWidget<String>(
                    label: 'Select District',
                    isSingleSelect: true,
                    selectedValues: controller.selectedDistrict.value != null ? {controller.selectedDistrict.value!} : {},
                    items: controller.districtOptions.map((opt) => DropdownMenuItem(value: opt.value, child: Text(opt.label, style: AppTextStyle.style_12_400(color: AppColors.grey900)))).toList(),
                    onChanged: (v) {
                      controller.selectedDistrict.value = v.isNotEmpty ? v.first : null;
                    },
                  )),
                  _buildDateField(
                    label: 'Select Month',
                    hint: 'May-2026',
                    icon: Icons.calendar_month_outlined,
                  ),
                  _buildDateField(
                    label: 'Select Date',
                    hint: 'Enter Date',
                    icon: Icons.calendar_today_outlined,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateField({required String label, required String hint, required IconData icon}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: AppTextStyle.style_12_400(color: AppColors.grey200),
        hintText: hint,
        hintStyle: AppTextStyle.style_12_400(color: AppColors.grey300),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        suffixIcon: Icon(icon, size: 16.r, color: AppColors.grey300),
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
          borderSide: const BorderSide(color: Color(0xffF15A24), width: 1.5),
        ),
      ),
      style: AppTextStyle.style_12_400(color: AppColors.black),
    );
  }
}
