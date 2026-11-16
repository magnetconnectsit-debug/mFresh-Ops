// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// endregion

// region AppCommonTextField
class AppCommonTextField extends StatelessWidget {
  // region Properties
  final TextEditingController controller;
  final String? titleText;
  final String hintText;
  final String? labelText;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final int? maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool isRequired;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;
  final TextStyle? style;
  final TextInputAction? textInputAction;
  final double? height;
  final double? width;
  final bool? enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final FloatingLabelBehavior floatingLabelBehavior;
  final double? borderRadius;
  final bool useFloatingLabel;
  final BoxConstraints? suffixIconConstraints;
  final BoxConstraints? prefixIconConstraints;

  // endregion

  // region Constructor
  const AppCommonTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.titleText,
    this.labelText,
    this.keyboardType,
    this.validator,
    this.textCapitalization = TextCapitalization.sentences,
    this.maxLength,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.isRequired = false,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.style,
    this.textInputAction,
    this.height,
    this.width,
    this.enabled,
    this.readOnly = false,
    this.onTap,
    this.fillColor,
    this.contentPadding,
    this.focusNode,
    this.onFieldSubmitted,
    this.onChanged,
    this.floatingLabelBehavior = FloatingLabelBehavior.always,
    this.borderRadius,
    this.useFloatingLabel = true,
    this.suffixIconConstraints,
    this.prefixIconConstraints,
  });

  // endregion

  // region Build Method
  @override
  Widget build(BuildContext context) {
    final rawLabel = labelText ?? (useFloatingLabel ? titleText : null);
    final isMandatoryLabel =
        isRequired || (rawLabel != null && rawLabel.contains('*'));
    final cleanLabel = rawLabel?.replaceAll('*', '').trim();
    final isMandatoryTitle =
        isRequired || (titleText != null && titleText!.contains('*'));
    final cleanTitle = titleText?.replaceAll('*', '').trim();
    final displayLabel = _capitalizeText(cleanLabel);
    final displayTitle = _capitalizeText(cleanTitle);
    final isFieldDisabled = (enabled == false) || (readOnly && onTap == null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (displayTitle != null && !useFloatingLabel)
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Text.rich(
              TextSpan(
                text: displayTitle,
                style: AppTextStyle.style_12_500(color: AppColors.black300),
                children: [
                  if (isMandatoryTitle)
                    TextSpan(
                      text: ' *',
                      style: AppTextStyle.style_12_500(color: AppColors.red),
                    ),
                ],
              ),
            ),
          ),
        SizedBox(
          width: width,
          height: height,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            validator: validator,
            textCapitalization: textCapitalization,
            maxLength: maxLength,
            maxLines: maxLines,
            obscureText: obscureText,
            enabled: enabled,
            readOnly: readOnly,
            inputFormatters: inputFormatters,
            textAlign: textAlign,
            onTap: onTap,
            onFieldSubmitted: onFieldSubmitted,
            onChanged: onChanged,
            textAlignVertical: TextAlignVertical.center,
            style: style ?? AppTextStyle.style_12_400(color: AppColors.grey900),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              prefixIcon: prefixIcon,
              prefixIconConstraints:
                  prefixIconConstraints ??
                  (prefixIcon != null && height != null
                      ? BoxConstraints(maxHeight: height!, minWidth: 28.w)
                      : prefixIconConstraints),
              suffixIcon: suffixIcon,
              suffixIconConstraints:
                  suffixIconConstraints ??
                  (suffixIcon != null && height != null
                      ? BoxConstraints(maxHeight: height!, minWidth: 28.w)
                      : suffixIconConstraints),
              counterText: '',
              hintStyle: AppTextStyle.style_12_400(
                color: AppColors.grey300,
              ).copyWith(fontSize: 11.sp),
              floatingLabelBehavior: floatingLabelBehavior,
              label: displayLabel != null
                  ? Text.rich(
                      TextSpan(
                        text: displayLabel,
                        style: AppTextStyle.style_11_500(
                          color: AppColors.grey300,
                        ),
                        children: [
                          if (isMandatoryLabel)
                            TextSpan(
                              text: ' *',
                              style: AppTextStyle.style_11_500(
                                color: AppColors.red,
                              ),
                            ),
                        ],
                      ),
                    )
                  : null,
              contentPadding:
                  contentPadding ??
                  EdgeInsets.symmetric(
                    horizontal: 10.w,
                    // increase value to increase container height and decrease to decrease container height
                    vertical: (maxLines != null && maxLines! > 1) ? 5.h : 3.h,
                  ),
              filled: true,
              fillColor:
                  fillColor ??
                  (isFieldDisabled
                      ? const Color(0xFFF1F3F5)
                      : AppColors.aliceBlue),
              border: _buildBorder(color: AppColors.fieldBorderColor),
              enabledBorder: _buildBorder(color: AppColors.fieldBorderColor),
              disabledBorder: _buildBorder(color: AppColors.fieldBorderColor),
              focusedBorder: _buildBorder(color: AppColors.primary, width: 1.5),
              errorBorder: _buildBorder(color: AppColors.red),
              focusedErrorBorder: _buildBorder(
                color: AppColors.red,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // endregion

  // region Helpers
  String? _capitalizeText(String? text) {
    if (text == null || text.trim().isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      if (word.contains('-')) {
        return word.split('-').map((part) {
          if (part.isEmpty) return part;
          return '${part[0].toUpperCase()}${part.substring(1)}';
        }).join('-');
      }
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
  }

  OutlineInputBorder _buildBorder({
    Color color = AppColors.fieldBorderColor,
    double width = 1.0,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  // endregion
}
// endregion

// region PhoneNoTextField
class PhoneNoTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final FormFieldValidator<String>? validator;

  const PhoneNoTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AppCommonTextField(
      controller: controller,
      labelText: 'Mobile Number',
      isRequired: true,
      hintText: hintText ?? 'Enter your mobile number',
      keyboardType: TextInputType.phone,
      maxLength: 10,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Mobile number is required';
            }
            if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
              return 'Please enter a valid 10-digit mobile number';
            }
            return null;
          },
      prefixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10.w),
            child: Text(
              '+91',
              style: AppTextStyle.style_12_600(color: AppColors.primary),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Container(height: 20.h, width: 1, color: AppColors.grey100),
          ),
        ],
      ),
    );
  }
}
// endregion

// region AppLoginTextField
class AppLoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final String? titleText;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool isRequired;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? style;
  final TextInputAction? textInputAction;
  final bool? enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final double? borderRadius;
  final Color? fillColor;
  final double? height;
  final List<BoxShadow>? boxShadow;

  const AppLoginTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.titleText,
    this.keyboardType,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.isRequired = false,
    this.inputFormatters,
    this.style,
    this.textInputAction,
    this.enabled,
    this.readOnly = false,
    this.onTap,
    this.focusNode,
    this.onFieldSubmitted,
    this.onChanged,
    this.borderRadius,
    this.fillColor,
    this.height,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final isFieldDisabled = readOnly || (enabled == false);
    final effRadius = borderRadius ?? 8.r;
    final effFillColor =
        fillColor ?? (isFieldDisabled ? AppColors.boxColor2 : AppColors.white);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (titleText != null) ...[
          Padding(
            padding: EdgeInsets.only(left: 2.w, bottom: 4.h),
            child: Text.rich(
              TextSpan(
                text: titleText,
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
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(effRadius),
            boxShadow:
                boxShadow ??
                [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.05),
                    blurRadius: 6.r,
                    offset: const Offset(0, 2),
                  ),
                ],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            validator: validator,
            textCapitalization: textCapitalization,
            maxLength: maxLength,
            obscureText: obscureText,
            enabled: enabled,
            readOnly: readOnly,
            inputFormatters: inputFormatters,
            onTap: onTap,
            onFieldSubmitted: onFieldSubmitted,
            onChanged: onChanged,
            textAlignVertical: TextAlignVertical.center,
            style: style ?? AppTextStyle.style_12_500(color: AppColors.black5),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              counterText: '',
              hintStyle: AppTextStyle.style_11_400(color: AppColors.black200),
              labelText: labelText,
              labelStyle: AppTextStyle.style_11_400(color: AppColors.black200),
              floatingLabelStyle: AppTextStyle.style_12_500(
                color: AppColors.primary,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
              filled: true,
              fillColor: effFillColor,
              border: _buildBorder(
                color: AppColors.borderColor,
                radius: effRadius,
              ),
              enabledBorder: _buildBorder(
                color: AppColors.borderColor,
                radius: effRadius,
              ),
              disabledBorder: _buildBorder(
                color: AppColors.borderColor,
                radius: effRadius,
              ),
              focusedBorder: _buildBorder(
                color: AppColors.primary,
                width: 1.5,
                radius: effRadius,
              ),
              errorBorder: _buildBorder(
                color: AppColors.red,
                radius: effRadius,
              ),
              focusedErrorBorder: _buildBorder(
                color: AppColors.red,
                width: 1.5,
                radius: effRadius,
              ),
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _buildBorder({
    required Color color,
    double width = 1.0,
    required double radius,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
// endregion