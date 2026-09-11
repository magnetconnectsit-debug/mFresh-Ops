import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/deposits/controllers/deposits_controller.dart';
import 'package:intl/intl.dart';

class DepositsSummary extends StatelessWidget {
  const DepositsSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DepositsController>();
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Obx(() {
      final items = controller.monthlySummary.entries.toList();

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final monthlyEntry = entry.value;
                final isLast = index == items.length - 1;
                
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 100.w, // Fixed width for horizontal scrolling
                      height: 48.h, // Maintain smaller height
                      child: _buildSummaryCard(
                        title: monthlyEntry.key,
                        amount: currencyFormat.format(monthlyEntry.value),
                        isHighlighted: false,
                      ),
                    ),
                    if (!isLast)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Icon(Icons.add, size: 14.r, color: AppColors.black),
                      ),
                  ],
                );
              }),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text('=', style: AppTextStyle.style_16_600(color: AppColors.black)),
              ),
              SizedBox(
                width: 100.w,
                height: 48.h, // Using same 48.h height here to maintain horizontal row consistency
                child: _buildSummaryCard(
                  title: 'Total',
                  amount: currencyFormat.format(controller.totalDeposit),
                  isHighlighted: true,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required bool isHighlighted,
  }) {
    if (isHighlighted) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF00B4D8),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: AppTextStyle.style_10_400(color: AppColors.white),
            ),
            SizedBox(height: 2.h),
            Text(
              amount,
              style: AppTextStyle.style_12_600(color: AppColors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4.r),
                topRight: Radius.circular(4.r),
              ),
              border: Border(
                bottom: BorderSide(color: AppColors.borderColor),
              ),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyle.style_10_400(color: AppColors.black),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                amount,
                style: AppTextStyle.style_12_600(color: AppColors.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
