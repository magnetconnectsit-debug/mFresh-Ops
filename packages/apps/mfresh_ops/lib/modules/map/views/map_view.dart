import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mfresh_ops/data/services/tracking_service.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/modules/map/views/widgets/animated_live_map.dart';

import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';

class MapView extends GetView<TrackingService> {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppCommonAppBar(
        title: Text(
          'Live Tracking',
          style: AppTextStyle.style_18_700(color: AppColors.black),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        hasBackButton: true,
        iconColor: AppColors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.black),
            onPressed: () => Get.toNamed(AppRoutes.routeHistory),
            tooltip: 'View History',
          ),
        ],
      ),
      body: Stack(
        children: [
          const AnimatedLiveMap(),
          // Bottom Control Overlay
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: 24.h,
            child: Obx(() {
              final isTracking = controller.isTracking.value;
              return Container(
                padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 15.r,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isTracking ? const Color(0xFF10B981) : Colors.red,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isTracking ? 'Shift: Active' : 'Shift: Inactive',
                            style: AppTextStyle.style_14_700(
                              color: isTracking ? const Color(0xFF10B981) : Colors.red,
                            ),
                          ),
                          Text(
                            isTracking ? 'Tracking your live route' : 'Location sharing offline',
                            style: AppTextStyle.style_10_400(color: AppColors.grey500),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => controller.toggleTracking(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isTracking
                            ? Colors.red.withValues(alpha: 0.08)
                            : AppColors.primary.withValues(alpha: 0.08),
                        foregroundColor: isTracking ? Colors.red : AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      ),
                      child: Text(
                        isTracking ? 'Stop' : 'Start',
                        style: AppTextStyle.style_12_700(
                          color: isTracking ? Colors.red : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

