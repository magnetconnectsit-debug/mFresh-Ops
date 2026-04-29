import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ButtonVariant { primary, secondary, outline, text }

class AppCommonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSmall;
  final double? height;
  final double? width;
  final Color? buttonColor;
  final Color? borderColor;
  final Color? textColor;
  final double? textSize;
  final double? borderRadius;
  final double? elevation;
  final Widget? prefixWidget;
  final IconData? icon;
  final ButtonVariant variant;

  const AppCommonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSmall = false,
    this.height,
    this.width,
    this.buttonColor,
    this.borderColor,
    this.textColor,
    this.textSize,
    this.borderRadius,
    this.elevation,
    this.prefixWidget,
    this.icon,
    this.variant = ButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    Color effectiveButtonColor;
    Color effectiveTextColor;
    Color? effectiveBorderColor = borderColor;
    double effectiveElevation = elevation ?? 0;

    switch (variant) {
      case ButtonVariant.secondary:
        effectiveButtonColor = buttonColor ?? AppColors.background;
        effectiveTextColor = textColor ?? AppColors.primary;
        break;
      case ButtonVariant.outline:
        effectiveButtonColor = buttonColor ?? Colors.transparent;
        effectiveTextColor = textColor ?? AppColors.grey700;
        effectiveBorderColor ??= AppColors.grey200;
        break;
      case ButtonVariant.text:
        effectiveButtonColor = Colors.transparent;
        effectiveTextColor = textColor ?? AppColors.primary;
        effectiveElevation = 0;
        break;
      case ButtonVariant.primary:
        effectiveButtonColor = buttonColor ?? AppColors.primary;
        effectiveTextColor = textColor ?? AppColors.white;
        break;
    }

    final style =
        ElevatedButton.styleFrom(
          elevation: effectiveElevation,
          backgroundColor: effectiveButtonColor,
          foregroundColor: effectiveTextColor,
          minimumSize: Size(
            width ?? (isSmall ? 60.w : double.infinity),
            height ?? (isSmall ? 32.h : 40.h),
          ),
          padding: EdgeInsets.symmetric(horizontal: isSmall ? 12.w : 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
            side: effectiveBorderColor != null
                ? BorderSide(color: effectiveBorderColor)
                : BorderSide.none,
          ),
        ).copyWith(
          overlayColor: variant == ButtonVariant.text
              ? WidgetStateProperty.all(
                  effectiveTextColor.withValues(alpha: 0.1),
                )
              : null,
        );

    if (isLoading) {
      return ElevatedButton(
        style: style,
        onPressed: null,
        child: CustomAppLoader(
          size: isSmall ? 16.r : 24.r,
          strokeWidth: 2,
          color: effectiveTextColor,
        ),
      );
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefixWidget != null) ...[
          prefixWidget!,
          SizedBox(width: 12.w),
        ] else if (icon != null) ...[
          Icon(icon, size: isSmall ? 16.sp : 20.sp),
          SizedBox(width: 8.w),
        ],
        Text(
          text,
          style: AppTextStyle.style_16_600(
            color: effectiveTextColor,
          ).copyWith(fontSize: textSize ?? (isSmall ? 12.sp : 16.sp)),
        ),
      ],
    );

    return ElevatedButton(style: style, onPressed: onPressed, child: content);
  }
}
