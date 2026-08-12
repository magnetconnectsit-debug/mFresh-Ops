// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// endregion

// region ToastType Enum
enum ToastType { success, error, info, warning }
// endregion

class AppCommonToastMessage {
  static void show({required String message, required ToastType type}) {
  String cleanMessage = _cleanMessage(message);

  final config = _ToastConfig.fromType(type);

  try {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
  } catch (e) {
    debugPrint('Error closing snackbar: $e');
  }

  Get.showSnackbar(
    GetSnackBar(
      messageText: Text(
        cleanMessage,
        style: AppTextStyle.style_14_500(color: const Color(0xFF3F3F46)),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),

      backgroundColor: AppColors.white,
      borderRadius: 12.r,
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),

      borderColor: config.primaryColor.withValues(alpha: 0.15),
      borderWidth: 1.5,

      boxShadows: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
      ],

      icon: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: config.primaryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(config.icon, color: config.primaryColor, size: 20.sp),
      ),

      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.elasticOut,
      reverseAnimationCurve: Curves.easeOut,
      animationDuration: const Duration(milliseconds: 600),
    ),
  );
  }
}
// endregion

// region Helper: Configuration Class
class _ToastConfig {
  final Color primaryColor;
  final IconData icon;

  _ToastConfig({required this.primaryColor, required this.icon});

  factory _ToastConfig.fromType(ToastType type) {
    switch (type) {
      case ToastType.success:
        return _ToastConfig(
          primaryColor: AppColors.success,
          icon: Icons.check_circle_rounded,
        );
      case ToastType.error:
        return _ToastConfig(
          primaryColor: AppColors.error,
          icon: Icons.error_rounded,
        );
      case ToastType.warning:
        return _ToastConfig(
          primaryColor: AppColors.warning,
          icon: Icons.warning_rounded,
        );
      case ToastType.info:
        return _ToastConfig(
          primaryColor: AppColors.primary,
          icon: Icons.info_rounded,
        );
    }
  }
}
// endregion

// region Helper: Message Cleaner
String _cleanMessage(String message) {
  String cleanMessage = message
      .replaceAll(
        RegExp(
          r'^(Exception:|Error:|Structure:|argument:|FormatAuthException:|DioException|DioException \[.*?\]:)\s*',
          caseSensitive: false,
        ),
        '',
      )
      .trim();

  final lowerMsg = cleanMessage.toLowerCase();

  if (lowerMsg.contains('socketexception') ||
      lowerMsg.contains('connection failed') ||
      lowerMsg.contains('connection refused') ||
      lowerMsg.contains('network is unreachable') ||
      lowerMsg.contains('host lookup failed')) {
    return "No internet connection. Please check your network.";
  } else if (lowerMsg.contains('unauthorized') ||
      lowerMsg.contains('token expired')) {
    return "Your session has expired. Please log in again.";
  } else if (lowerMsg.contains('user not found')) {
    return "We couldn't find an account with those details.";
  } else if (lowerMsg.contains('internal server error') ||
      lowerMsg.contains('500')) {
    return "Our servers are having trouble. Please try again later.";
  }

  return cleanMessage;
}

// endregion










