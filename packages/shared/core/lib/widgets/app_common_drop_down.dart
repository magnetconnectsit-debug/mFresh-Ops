// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
  final TextAlign textAlign;
  
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
    this.textAlign = TextAlign.center,
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
            padding: EdgeInsets.only(bottom: 6.h),
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
        
        if (isMultiSelect && selectedValues != null && selectedValues!.isNotEmpty && options != null)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: selectedValues!.map((val) {
                final label = options!.firstWhereOrNull((opt) => opt.value == val)?.label ?? '';
                if (label.isEmpty) return const SizedBox.shrink();
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          style: AppTextStyle.style_10_600(color: AppColors.primary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      GestureDetector(
                        onTap: () {
                          final newList = List<T>.from(selectedValues!)..remove(val);
                          if (onMultiSelectChanged != null) {
                            onMultiSelectChanged!(newList);
                          }
                        },
                        child: Icon(Icons.close, size: 12.r, color: AppColors.primary),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        
        options != null ? _buildPageSelect(context) : _buildSingleSelect(),
      ],
    );
  }

  Widget _buildSingleSelect() {
    return SizedBox(
      height: height ?? 32.h,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        items: items,
        onChanged: onChanged,
        validator: validator,
        isExpanded: true,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.grey300,
          size: 16.r,
        ),
        style: style ?? AppTextStyle.style_11_600(color: AppColors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: hintStyle ?? AppTextStyle.style_11_600(color: AppColors.black),
          contentPadding: contentPadding ??
              EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 0,
              ),
          filled: true,
          fillColor: AppColors.white,
          border: _buildBorder(color: AppColors.borderColor),
          enabledBorder: _buildBorder(color: AppColors.borderColor),
          focusedBorder: _buildBorder(color: AppColors.primary),
          errorBorder: _buildBorder(color: AppColors.red),
          focusedErrorBorder: _buildBorder(color: AppColors.red),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildPageSelect(BuildContext context) {
    final String displayValue;
    if (isMultiSelect) {
      displayValue = (selectedValues == null || selectedValues!.isEmpty)
          ? hintText
          : selectedValues!.length == 1 
              ? options?.firstWhere((opt) => opt.value == selectedValues!.first).label ?? hintText
              : '${selectedValues!.length} selected';
    } else {
      displayValue = (value == null)
          ? hintText
          : options?.firstWhere((opt) => opt.value == value).label ?? hintText;
    }

    return GestureDetector(
      onTap: () async {
        if (options == null) return;
        
        final result = await AppCommonDropdownPage.show<T>(
          context,
          title: title ?? hintText,
          options: options!,
          isMultiSelect: isMultiSelect,
          initialSelection: isMultiSelect 
            ? options!.where((opt) => selectedValues?.contains(opt.value) ?? false).toList()
            : value != null ? [options!.firstWhere((opt) => opt.value == value)] : null,
        );

        if (result != null) {
          if (isMultiSelect) {
            if (onMultiSelectChanged != null) {
              onMultiSelectChanged!(result.map((e) => e.value).toList());
            }
          } else {
            if (onChanged != null) {
              onChanged!(result.first.value);
            }
          }
        }
      },
      child: Container(
        constraints: BoxConstraints(minHeight: height ?? 32.h),
        padding: contentPadding ?? EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: AppColors.borderColor, width: 1.0),
        ),
        child: Row(
          children: [
            Expanded(
              child: isMultiSelect && selectedValues != null && selectedValues!.isNotEmpty
                  ? Wrap(
                      spacing: 4.w,
                      runSpacing: 4.h,
                      children: selectedValues!.map((val) {
                        final label = options?.firstWhereOrNull((opt) => opt.value == val)?.label ?? '';
                        if (label.isEmpty) return const SizedBox.shrink();
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                label,
                                style: AppTextStyle.style_10_600(color: AppColors.primary),
                              ),
                              SizedBox(width: 2.w),
                              GestureDetector(
                                onTap: () {
                                  final newList = List<T>.from(selectedValues!)..remove(val);
                                  if (onMultiSelectChanged != null) {
                                    onMultiSelectChanged!(newList);
                                  }
                                },
                                child: Icon(Icons.close, size: 10.r, color: AppColors.primary),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  : Text(
                      displayValue,
                      style: style ?? AppTextStyle.style_11_600(color: AppColors.black),
                      overflow: TextOverflow.ellipsis,
                      textAlign: textAlign,
                    ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.grey300,
              size: 16.r,
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
      borderRadius: BorderRadius.circular(4.r),
      borderSide: BorderSide(color: color, width: 1.0),
    );
    // endregion
  }

  // endregion
}

// endregion
