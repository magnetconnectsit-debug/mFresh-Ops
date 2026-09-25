import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/data/models/revenue_report/dashboard_data_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardGrowthCard extends StatelessWidget {
  final GrowthData growthData;

  const DashboardGrowthCard({
    super.key,
    required this.growthData,
  });

  @override
  Widget build(BuildContext context) {
    bool isPositive = growthData.growthPercentage >= 0;
    Color badgeColor = isPositive ? Colors.green.withAlpha(30) : Colors.red.withAlpha(30);
    Color textColor = isPositive ? Colors.green : Colors.red;
    String symbol = isPositive ? '+' : '';

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blueGrey.withAlpha(30), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 12.r,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Previous',
                  style: AppTextStyle.style_12_400(color: Colors.black54),
                ),
                SizedBox(height: 4.h),
                Text(
                  growthData.previousLabel,
                  style: AppTextStyle.style_12_600(color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: growthData.previousValue.toDouble()),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Text(
                      '₹${NumberFormat('#,##,###').format(value.toInt())}',
                      style: AppTextStyle.style_14_700(color: Colors.black87),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Center Badge
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 70.r,
                  height: 70.r,
                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: growthData.growthPercentage.toDouble()),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Text(
                        '$symbol${value.toStringAsFixed(1)}%\nGrowth',
                        textAlign: TextAlign.center,
                        style: AppTextStyle.style_10_700(color: textColor),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // Current Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Current',
                  style: AppTextStyle.style_12_400(color: Colors.black54),
                ),
                SizedBox(height: 4.h),
                Text(
                  growthData.currentLabel,
                  style: AppTextStyle.style_12_600(color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: growthData.currentValue.toDouble()),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Text(
                      '₹${NumberFormat('#,##,###').format(value.toInt())}',
                      style: AppTextStyle.style_14_700(color: Colors.black87),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
