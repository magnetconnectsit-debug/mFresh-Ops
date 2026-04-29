// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// endregion

// region AppCommonSearchBar Class
class AppCommonSearchBar extends StatelessWidget {
  // region Properties
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Color? borderColor;
  final Color? fillColor;

  // endregion

  // region Constructor
  const AppCommonSearchBar({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.borderColor,
    this.fillColor,
  });

  // endregion

  // region Build Method
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey50, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: AppColors.primary,
        onFieldSubmitted: onSubmitted,
        textAlignVertical: TextAlignVertical.center,
        style: AppTextStyle.style_14_400(color: AppColors.black),
        decoration: InputDecoration(
          hintText: hintText ?? 'Search...',
          hintStyle: AppTextStyle.style_14_400(color: AppColors.grey300),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.grey300,
            size: 20.r,
          ),
          isDense: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
        ),
      ),
    );
  }

  // endregion
}

// endregion










