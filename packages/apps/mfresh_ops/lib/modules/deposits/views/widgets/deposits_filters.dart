import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/deposits/controllers/deposits_controller.dart';

class DepositsFilters extends StatelessWidget {
  const DepositsFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DepositsController>();

    return Container(
      padding: EdgeInsets.all(12.r),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor, width: 1.0),
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
                  _buildDateField(
                    label: 'From Month',
                    hint: 'dd-mm-yyyy',
                    icon: Icons.calendar_today_outlined,
                  ),
                  _buildDateField(
                    label: 'To Month',
                    hint: 'dd-mm-yyyy',
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
