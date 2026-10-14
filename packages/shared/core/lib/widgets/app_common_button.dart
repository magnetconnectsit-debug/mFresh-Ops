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
  final List<Color>? gradientColors;
  final Color? borderColor;
  final Color? textColor;
  final double? textSize;
  final double? borderRadius;
  final double? elevation;
  final Widget? prefixWidget;
  final IconData? icon;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? suffixWidget;
  final double? iconSize;
  final ButtonVariant variant;
  final EdgeInsetsGeometry? padding;
  final bool useGradient;
  final double? loaderSize;

  const AppCommonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSmall = false,
    this.height,
    this.width,
    this.buttonColor,
    this.gradientColors,
    this.borderColor,
    this.textColor,
    this.textSize,
    this.borderRadius,
    this.elevation,
    this.prefixWidget,
    this.icon,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixWidget,
    this.iconSize,
    this.variant = ButtonVariant.primary,
    this.padding,
    this.useGradient = true,
    this.loaderSize,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;
    final effectiveBorderRadius = BorderRadius.circular(borderRadius ?? 6.r);
    final double effHeight = height ?? (isSmall ? 20.h : 24.h);
    final EdgeInsetsGeometry effPadding =
        padding ?? EdgeInsets.symmetric(horizontal: isSmall ? 8.w : 16.w);
    final double effLoaderSize = loaderSize ?? (isSmall ? 14.r : 20.r);

    if (variant == ButtonVariant.outline || variant == ButtonVariant.text) {
      final Color effTextColor = textColor ??
          (variant == ButtonVariant.outline
              ? AppColors.grey700
              : AppColors.primary);
      final Color effBorderColor = borderColor ?? AppColors.grey200;
      final Color effLoaderColor = borderColor ?? buttonColor ?? AppColors.primary;

      final Widget outlineWidget = Material(
        color: Colors.transparent,
        borderRadius: effectiveBorderRadius,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: effectiveBorderRadius,
          child: Container(
            width: width,
            height: effHeight,
            alignment: width != null ? Alignment.center : null,
            padding: effPadding,
            decoration: BoxDecoration(
              color: isLoading ? AppColors.white : (buttonColor ?? Colors.transparent),
              borderRadius: effectiveBorderRadius,
              border: variant == ButtonVariant.outline || isLoading
                  ? Border.all(color: effBorderColor)
                  : null,
            ),
            child: isLoading
                ? CustomAppLoader(
                    size: effLoaderSize,
                    strokeWidth: 2.5,
                    color: effLoaderColor,
                  )
                : _buildContent(effTextColor, isDisabled),
          ),
        ),
      );

      if (width == null) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [outlineWidget],
        );
      }
      return outlineWidget;
    }

    // Primary & Secondary Buttons with Gradient / Solid styling matching Create Ticket button
    final List<Color> effGradient = gradientColors ??
        (buttonColor != null
            ? [buttonColor!, buttonColor!]
            : (variant == ButtonVariant.secondary
                ? [AppColors.grey100, AppColors.grey200]
                : const [AppColors.secondaryBlue, AppColors.primaryBlue]));

    final Color effTextColor = textColor ??
        (variant == ButtonVariant.secondary
            ? AppColors.black
            : AppColors.white);

    final Color effLoaderColor = buttonColor ?? AppColors.primary;

    final Widget primaryWidget = Material(
      color: Colors.transparent,
      borderRadius: effectiveBorderRadius,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: effectiveBorderRadius,
        child: Ink(
          decoration: BoxDecoration(
            gradient: (useGradient && !isLoading)
                ? LinearGradient(
                    colors: (onPressed == null)
                        ? effGradient.map((c) => c.withValues(alpha: 0.4)).toList()
                        : effGradient,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
            color: isLoading
                ? AppColors.white
                : (!useGradient ? (buttonColor ?? AppColors.primary) : null),
            borderRadius: effectiveBorderRadius,
            border: isLoading
                ? Border.all(color: effLoaderColor, width: 1.0)
                : (borderColor != null ? Border.all(color: borderColor!) : null),
            boxShadow: [
              if (!isDisabled && (elevation == null || elevation! > 0) && !isLoading)
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.12),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
            ],
          ),
          child: Container(
            width: width,
            height: effHeight,
            alignment: width != null ? Alignment.center : null,
            padding: effPadding,
            child: isLoading
                ? CustomAppLoader(
                    size: effLoaderSize,
                    strokeWidth: 2.5,
                    color: effLoaderColor,
                  )
                : _buildContent(effTextColor, isDisabled),
          ),
        ),
      ),
    );

    if (width == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [primaryWidget],
      );
    }

    return primaryWidget;
  }

  Widget _buildContent(Color textCol, bool isDisabled) {
    final double effIconSize = iconSize ?? 14.r;
    final IconData? effPrefixIcon = prefixIcon ?? icon;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefixWidget != null) ...[
          prefixWidget!,
          SizedBox(width: 4.w),
        ] else if (effPrefixIcon != null) ...[
          Icon(
            effPrefixIcon,
            size: effIconSize,
            color: isDisabled ? textCol.withValues(alpha: 0.6) : textCol,
          ),
          SizedBox(width: 3.w),
        ],
        Text(
          text,
          style: AppTextStyle.style_11_600(color: textCol).copyWith(
            fontSize: textSize ?? 11.sp,
            color: isDisabled ? textCol.withValues(alpha: 0.6) : textCol,
          ),
        ),
        if (suffixWidget != null) ...[
          SizedBox(width: 4.w),
          suffixWidget!,
        ] else if (suffixIcon != null) ...[
          SizedBox(width: 4.w),
          Icon(
            suffixIcon,
            size: effIconSize,
            color: isDisabled ? textCol.withValues(alpha: 0.6) : textCol,
          ),
        ],
      ],
    );
  }
}