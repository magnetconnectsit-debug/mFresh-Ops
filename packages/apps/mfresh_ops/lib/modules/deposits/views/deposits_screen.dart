import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:mfresh_ops/modules/deposits/controllers/deposits_controller.dart';
import 'package:mfresh_ops/modules/deposits/views/widgets/deposits_filters.dart';
import 'package:mfresh_ops/modules/deposits/views/widgets/deposits_summary.dart';
import 'package:mfresh_ops/modules/deposits/views/widgets/deposits_table.dart';

class DepositsScreen extends StatelessWidget {
  const DepositsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DepositsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        showAppDrawer: true,
        hasBackButton: false,
        title: Text(
          'Deposits',
style: AppTextStyle.style_18_700(color: AppColors.black),
        ),
      ),
      drawer: const CommonSidebar(),
      body: AppRefreshIndicator(
        onRefresh: controller.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              const DepositsFilters(),
              
              SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 24.h,
                      child: ElevatedButton(
                        onPressed: () {
                          // Download excel action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF389D6A), // Greenish
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                          elevation: 1,
                        ),
                        child: Text('Export Excel', style: AppTextStyle.style_12_500(color: AppColors.white)),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    SizedBox(
                      height: 24.h,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.toNamed('/create-deposit');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF389D6A), // Greenish
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                          elevation: 1,
                        ),
                        child: Text('Deposite Cash', style: AppTextStyle.style_12_500(color: AppColors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 8.h),
              const DepositsSummary(),
              
              SizedBox(height: 16.h),
              const DepositsTable(),
              
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
