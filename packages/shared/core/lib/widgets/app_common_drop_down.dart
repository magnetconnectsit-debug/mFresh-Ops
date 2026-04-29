// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// endregion

// region AppCommonDropdown
class AppCommonDropdown<T> extends StatelessWidget {
  // region Properties
  final String? title;
  final String hintText;
  final T? value;
  final List<DropdownMenuItem<T>>? items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final bool isRequired;
  final EdgeInsetsGeometry? contentPadding;
  final double? height;
  final TextStyle? style;
  final TextStyle? hintStyle;
  
  // Multi-select properties
  final bool isMultiSelect;
  final List<T>? selectedValues;
  final List<DropdownOption<T>>? options;
  final Function(List<T>)? onMultiSelectChanged;

  // endregion

  // region Constructor
  const AppCommonDropdown({
    super.key,
    this.title,
    required this.hintText,
    this.value,
    this.items,
    this.onChanged,
    this.validator,
    this.isRequired = false,
    this.contentPadding,
    this.height,
    this.style,
    this.hintStyle,
    this.isMultiSelect = false,
    this.selectedValues,
    this.options,
    this.onMultiSelectChanged,
  });

  // endregion

  // region Build Method
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text.rich(
              TextSpan(
                text: title!,
                style: AppTextStyle.style_12_500(color: AppColors.black300),
                children: [
                  if (isRequired)
                    TextSpan(
                      text: ' *',
                      style: AppTextStyle.style_12_500(color: AppColors.red),
                    ),
                ],
              ),
            ),
          ),
        
        isMultiSelect ? _buildMultiSelect(context) : _buildSingleSelect(),
      ],
    );
  }

  Widget _buildSingleSelect() {
    return SizedBox(
      height: height ?? 44.h,
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        validator: validator,
        isExpanded: true,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.grey300,
          size: 20.r,
        ),
        style: style ?? AppTextStyle.style_14_400(color: AppColors.black1),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: hintStyle ?? AppTextStyle.style_12_400(color: AppColors.grey100),
          contentPadding: contentPadding ??
              EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 6.h,
              ),
          filled: true,
          fillColor: AppColors.white,
          border: _buildBorder(color: AppColors.grey100),
          enabledBorder: _buildBorder(color: AppColors.grey100),
          focusedBorder: _buildBorder(color: AppColors.primary),
          errorBorder: _buildBorder(color: AppColors.red),
          focusedErrorBorder: _buildBorder(color: AppColors.red),
        ),
      ),
    );
  }

  Widget _buildMultiSelect(BuildContext context) {
    final String displayValue = (selectedValues == null || selectedValues!.isEmpty)
        ? hintText
        : selectedValues!.length == 1 
            ? options?.firstWhere((opt) => opt.value == selectedValues!.first).label ?? hintText
            : '${selectedValues!.length} items selected';

    return GestureDetector(
      onTap: () async {
        if (options == null) return;
        
        final result = await AppCommonDropdownPage.show<T>(
          context,
          title: title ?? hintText,
          options: options!,
          isMultiSelect: true,
          initialSelection: options!.where((opt) => selectedValues?.contains(opt.value) ?? false).toList(),
        );

        if (result != null && onMultiSelectChanged != null) {
          onMultiSelectChanged!(result.map((e) => e.value).toList());
        }
      },
      child: Container(
        height: height ?? 44.h,
        padding: contentPadding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.grey100, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                displayValue,
                style: (selectedValues == null || selectedValues!.isEmpty)
                    ? (hintStyle ?? AppTextStyle.style_12_400(color: AppColors.grey100))
                    : (style ?? AppTextStyle.style_14_400(color: AppColors.black1)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.grey300,
              size: 20.r,
            ),
          ],
        ),
      ),
    );
  }

  // endregion

  // region Helpers
  OutlineInputBorder _buildBorder({Color color = AppColors.primary}) {
    // region _buildBorder
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: BorderSide(color: color, width: 1.5),
    );
    // endregion
  }

  // endregion
}

// endregion










