import 'package:core/widgets/app_common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:services/services.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<StorageService>();
    final notifications = storage.getNotifications();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppCommonAppBar(
        title: const Text('Notifications'),
        showAppDrawer: false,
        hasBackButton: true,
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: EdgeInsets.all(20.r),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05), width: 1.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 20.r),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: AppTextStyle.style_14_600(color: AppColors.black),
                ),
                SizedBox(height: 4.h),
                Text(
                  notification.body,
                  style: AppTextStyle.style_12_400(color: AppColors.grey300),
                ),
                SizedBox(height: 8.h),
                Text(
                  notification.timestamp.toString().split('.').first,
                  style: AppTextStyle.style_10_400(color: AppColors.grey200),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 64.r, color: AppColors.grey200),
          SizedBox(height: 16.h),
          Text(
            'No Notifications',
            style: AppTextStyle.style_16_600(color: AppColors.grey300),
          ),
        ],
      ),
    );
  }
}
