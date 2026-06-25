import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/constants/app_colors.dart';
import 'package:mfresh_ops/data/services/tracking/tracking_service.dart';

class DutyStatusCard extends StatelessWidget {
  const DutyStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isTracking = TrackingService.to.isTracking.value;
      final isSyncing = TrackingService.to.isSyncing.value;

      // Premium theme coloring using central AppColors definitions
      final Color activeColor = isTracking ? AppColors.primaryGreen : AppColors.red;
      final Color innerBgColor = isTracking ? AppColors.primaryGreen.withOpacity(0.08) : AppColors.red1;
      final Color cardGlowColor = isTracking ? AppColors.primaryGreen.withOpacity(0.06) : Colors.black.withOpacity(0.02);

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isTracking ? AppColors.primaryGreen.withOpacity(0.3) : AppColors.borderColor,
            width: 1.2.r,
          ),
          boxShadow: [
            BoxShadow(
              color: cardGlowColor,
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left icon placeholder
            Container(
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(
                color: innerBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  isTracking ? Icons.radar_rounded : Icons.power_settings_new_rounded,
                  color: activeColor,
                  size: 20.r,
                ),
              ),
            ),
            SizedBox(width: 16.w),

            // Middle state details
            Expanded(
              child: Row(
                children: [
                  Text(
                    isTracking ? 'Shift is Active' : 'Start Your Shift',
                    style: AppTextStyle.style_14_700(color: AppColors.black),
                  ),
                  if (isTracking && isSyncing) ...[
                    SizedBox(width: 8.w),
                    SizedBox(
                      width: 10.r,
                      height: 10.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.r,
                        valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Right adaptive switch toggle
            Transform.scale(
              scale: 0.85,
              child: Switch.adaptive(
                value: isTracking,
                activeColor: AppColors.primaryGreen,
                activeTrackColor: AppColors.primaryGreen.withOpacity(0.2),
                inactiveThumbColor: AppColors.grey200,
                inactiveTrackColor: AppColors.grey50,
                onChanged: (val) async {
                  await TrackingService.to.toggleTracking();
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
