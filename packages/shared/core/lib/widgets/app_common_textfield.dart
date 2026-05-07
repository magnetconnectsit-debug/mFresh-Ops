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
  });

  // endregion

  // region Build Method
  @override
  Widget build(BuildContext context) {
    // region build
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titleText != null)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text.rich(
              TextSpan(
                text: titleText!,
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
        SizedBox(
          width: width,
          child: TextFormField(
            controller: controller,
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
            style: style ?? AppTextStyle.style_15_400(color: AppColors.black1),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              counterText: '',
              hintStyle: AppTextStyle.style_14_400(color: AppColors.grey200),
              labelStyle: AppTextStyle.style_14_500(color: AppColors.black300),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              filled: true,
              fillColor: AppColors.background,
              border: _buildBorder(color: AppColors.borderColor),
              enabledBorder: _buildBorder(color: AppColors.borderColor),
              focusedBorder: _buildBorder(color: AppColors.primary, width: 1.5),
              errorBorder: _buildBorder(color: AppColors.red),
              focusedErrorBorder: _buildBorder(color: AppColors.red),
            ),
          ),
        ),
      ],
    );
    // endregion
  }

  // endregion

  // region Helpers
  OutlineInputBorder _buildBorder({
    Color color = AppColors.blue100,
    double width = 1.0,
  }) {
    // region _buildBorder
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: color, width: width),
    );
    // endregion
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
      titleText: 'Mobile Number',
      isRequired: true,
      hintText: hintText ?? 'Enter your mobile number',
      keyboardType: TextInputType.phone,
      maxLength: 10,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Mobile number is required';
            }
            // This regex checks for 10 digits AND a valid Indian mobile start digit
            if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
              return 'Please enter a valid 10-digit mobile number';
            }
            return null;
          },
      prefixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: Text(
              '+91',
              style: AppTextStyle.style_14_600(color: AppColors.primary),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Container(
              height: 24.h,
              width: 1,
              color: AppColors.grey100,
            ),
          ),
        ],
      ),
    );
  }
}

// endregion










