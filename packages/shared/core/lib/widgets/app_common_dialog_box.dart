// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// endregion

// region AppCommonDialogBox
class AppCommonDialogBox {
  // region Constructor
  AppCommonDialogBox._();
  // endregion

  // region Info Dialog
  /// Shows a standardized info dialog.
  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    Color? buttonColor,
    Color? textColor,
    IconData? icon,
    Color? iconColor,
    bool barrierDismissible = true,
  }) {
    final effectiveIconColor = iconColor ?? AppColors.primary;
    final effectiveButtonColor = buttonColor ?? AppColors.primary;

    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => Dialog(
        backgroundColor: AppColors.white,
        elevation: 6,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 380.w),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    if (icon != null) ...[
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: effectiveIconColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 18.r,
                          color: effectiveIconColor,
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyle.style_15_700(color: AppColors.black),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(2.r),
                        child: Icon(
                          Icons.close,
                          size: 18.r,
                          color: AppColors.grey500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Divider(
                  height: 1.h,
                  thickness: 1,
                  color: const Color(0xFFE9ECEF),
                ),
                SizedBox(height: 14.h),

                // Message Content
                Text(
                  message,
                  style: AppTextStyle.style_13_400(
                    color: const Color(0xFF495057),
                  ).copyWith(height: 1.45),
                ),
                SizedBox(height: 20.h),

                // Action Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppCommonButton(
                      text: buttonText,
                      height: 32.h,
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      useGradient: false,
                      buttonColor: effectiveButtonColor,
                      textColor: textColor ?? AppColors.white,
                      borderRadius: 6.r,
                      textSize: 12.sp,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // endregion

  // region Confirm Dialog
  /// Shows a standardized confirmation dialog.
  /// Returns `true` if confirmed, `false` if cancelled or dismissed.
  static Future<bool> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmButtonColor,
    Color? cancelButtonColor,
    Color? confirmTextColor,
    Color? cancelTextColor,
    IconData? icon,
    Color? iconColor,
    bool isDanger = false,
    bool barrierDismissible = true,
  }) async {
    final effectiveIconColor = iconColor ??
        (isDanger ? const Color(0xFFDC3545) : AppColors.primary);
    final effectiveConfirmColor = confirmButtonColor ??
        (isDanger ? const Color(0xFFDC3545) : AppColors.primary);

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => Dialog(
        backgroundColor: AppColors.white,
        elevation: 6,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 380.w),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    if (icon != null) ...[
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: effectiveIconColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 18.r,
                          color: effectiveIconColor,
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyle.style_15_700(color: AppColors.black),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(2.r),
                        child: Icon(
                          Icons.close,
                          size: 18.r,
                          color: AppColors.grey500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Divider(
                  height: 1.h,
                  thickness: 1,
                  color: const Color(0xFFE9ECEF),
                ),
                SizedBox(height: 14.h),

                // Message Content
                Text(
                  message,
                  style: AppTextStyle.style_13_400(
                    color: const Color(0xFF495057),
                  ).copyWith(height: 1.45),
                ),
                SizedBox(height: 20.h),

                // Action Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppCommonButton(
                      text: cancelText,
                      height: 32.h,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      useGradient: false,
                      buttonColor: cancelButtonColor ?? const Color(0xFFF1F3F5),
                      textColor: cancelTextColor ?? const Color(0xFF495057),
                      borderRadius: 6.r,
                      textSize: 12.sp,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    SizedBox(width: 10.w),
                    AppCommonButton(
                      text: confirmText,
                      height: 32.h,
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      useGradient: false,
                      buttonColor: effectiveConfirmColor,
                      textColor: confirmTextColor ?? AppColors.white,
                      borderRadius: 6.r,
                      textSize: 12.sp,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return result ?? false;
  }
  // endregion

  // region Custom Content Dialog
  /// Shows a standardized dialog wrapper with custom body content.
  static Future<T?> showCustom<T>(
    BuildContext context, {
    required String title,
    required Widget content,
    IconData? icon,
    Color? iconColor,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    final effectiveIconColor = iconColor ?? AppColors.primary;

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => Dialog(
        backgroundColor: AppColors.white,
        elevation: 6,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 380.w),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    if (icon != null) ...[
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: effectiveIconColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 18.r,
                          color: effectiveIconColor,
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyle.style_15_700(color: AppColors.black),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(2.r),
                        child: Icon(
                          Icons.close,
                          size: 18.r,
                          color: AppColors.grey500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Divider(
                  height: 1.h,
                  thickness: 1,
                  color: const Color(0xFFE9ECEF),
                ),
                SizedBox(height: 14.h),

                // Custom Body Content
                content,

                // Optional Actions
                if (actions != null && actions.isNotEmpty) ...[
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  // endregion
}
// endregion
