import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// region AppCommonBottomSheet
class AppCommonBottomSheet {
  AppCommonBottomSheet._();

  static Future<T?> showModal<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    bool isScrollControlled = true, // Default to true for better sizing
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Padding(
          // Handle keyboard and status bar
          padding: EdgeInsets.only(
            top: 12.h,
            left: 16.w,
            right: 16.w,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Important: shrink to fit
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Title
              if (title != null) ...[
                Text(
                  title,
                  style: AppTextStyle.style_18_600(color: AppColors.black),
                ),
                SizedBox(height: 16.h),
              ],
              Flexible(child: child),
            ],
          ),
        );
      },
    );
  }
}

// endregion










