import 'package:core/constants/app_colors.dart';
import 'package:core/constants/app_images.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:services/storage_service.dart';

import 'widgets/home_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _lastPressed;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final now = DateTime.now();
        if (_lastPressed == null ||
            now.difference(_lastPressed!) > const Duration(seconds: 2)) {
          _lastPressed = now;
          AppCommonToastMessage.show(
            message: "Please press back again to close",
            type: ToastType.info,
          );
          return;
        }

        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppCommonAppBar(
          title: Text(
            'mFresh Ops',
            style: AppTextStyle.style_14_700(color: AppColors.black),
          ),
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: () => Get.toNamed(AppRoutes.notifications),
              icon: Icon(
                Icons.notifications_none_rounded,
                color: AppColors.primary,
                size: 22.r,
              ),
            ),
          ],
          showAppDrawer: true,
          hasBackButton: false,
          elevation: 0,
        ),
        drawer: const CommonSidebar(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(),
              _buildStatsSection(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Management Hub',
                      style: AppTextStyle.style_14_700(color: AppColors.black),
                    ),
                    SizedBox(height: 8.h),
                    const HomeGrid(),
                    SizedBox(height: 16.h),
                    _buildQuickActions(),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${Get.find<StorageService>().getUser()?.name ?? "Ops Manager"}!',
                      style: AppTextStyle.style_18_600(color: AppColors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Here\'s what\'s happening today',
                      style: AppTextStyle.style_10_400(
                        color: AppColors.grey300,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  AppImages.appLogo,
                  width: 24.r,
                  height: 24.r,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Active Tasks',
              '12',
              Icons.task_alt_rounded,
              Colors.blue,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: _buildStatCard(
              'New Tickets',
              '05',
              Icons.confirmation_number_outlined,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 1.r,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: AppTextStyle.style_16_700(color: AppColors.black),
                ),
                Text(
                  label,
                  style: AppTextStyle.style_10_400(color: AppColors.grey300),
                ),
              ],
            ),
          ),
          Icon(icon, color: color.withValues(alpha: 0.5), size: 18.r),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyle.style_14_700(color: AppColors.black),
        ),
        SizedBox(height: 8.h),
        _buildActionTile(
          Icons.add_task_rounded,
          'Create New Task',
          'Assign work to field team',
          Colors.blue,
        ),
        _buildActionTile(
          Icons.add_moderator_outlined,
          'Raise Ticket',
          'Report operational issues',
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    String sub,
    Color color,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 1.r,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 24.r),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.style_12_600(color: AppColors.black),
                ),
                Text(
                  sub,
                  style: AppTextStyle.style_10_400(color: AppColors.grey300),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.grey200,
            size: 16.r,
          ),
        ],
      ),
    );
  }
}
