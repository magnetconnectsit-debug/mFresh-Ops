import 'dart:io';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/splash/controllers/location_permission_controller.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LocationPermissionController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final minHeight = constraints.hasBoundedHeight
                    ? (constraints.maxHeight - 24.h).clamp(0.0, double.infinity)
                    : 0.0;
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: minHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 12.h),
                              // Icon Container
                              Container(
                                width: 100.r,
                                height: 100.r,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.location_on_rounded,
                                    size: 50.r,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              // Title
                              Text(
                                'Background Location Required',
                                textAlign: TextAlign.center,
                                style: AppTextStyle.style_20_700(color: AppColors.black),
                              ),
                              SizedBox(height: 12.h),
                              // Description
                              Text(
                                'This app is for operations and logistics. To start using the app, you must allow background location permission ${Platform.isIOS ? '"Always"' : '"Allow all the time"'} so that your location can be tracked while tasks are active.',
                                textAlign: TextAlign.center,
                                style: AppTextStyle.style_12_400(color: const Color(0xFF6C757D)),
                              ),
                              SizedBox(height: 16.h),
                              // Bullet points/Guide
                              Container(
                                padding: EdgeInsets.all(14.r),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildGuideItem('1', 'Click the button below to request permission.'),
                                    SizedBox(height: 8.h),
                                    _buildGuideItem('2', 'Select ${Platform.isIOS ? '"Always"' : '"Allow all the time"'} or "Allow in Settings" to enable background location tracking.'),
                                    SizedBox(height: 8.h),
                                    _buildGuideItem('3', 'Without background location, the app cannot be opened.'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 16.h),
                              // Button
                              Obx(() => SizedBox(
                                    width: double.infinity,
                                    height: 48.h,
                                    child: ElevatedButton(
                                      onPressed: controller.isChecking.value
                                          ? null
                                          : () => controller.requestPermissions(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                      ),
                                      child: controller.isChecking.value
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              'Enable Location Permission',
                                              style: AppTextStyle.style_14_600(color: Colors.white),
                                            ),
                                    ),
                                  )),
                              SizedBox(height: 16.h),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ));
}

  Widget _buildGuideItem(String index, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 9.r,
          backgroundColor: AppColors.primary,
          child: Text(
            index,
            style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: AppTextStyle.style_11_500(color: const Color(0xFF495057)),
          ),
        ),
      ],
    );
  }
}
