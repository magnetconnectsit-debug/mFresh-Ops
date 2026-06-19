import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/collections/controllers/old_collections_controller.dart';

class OldCollectionsSummary extends StatelessWidget {
  const OldCollectionsSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OldCollectionsController>();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Obx(
        () => Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          alignment: WrapAlignment.spaceBetween,
          children: [
            _buildSummaryCard('Cash Collected', controller.cashCollected.value),
            _buildSummaryCard('Cash Deposited', controller.cashDeposited.value),
            _buildSummaryCard('Cash in Office', controller.cashInOffice.value),
            _buildSummaryCard('Cash In Units', controller.cashInUnits.value),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount) {
    return Container(
      width: (Get.width - 40.w) / 2, // Half width minus padding/spacing
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: AppTextStyle.style_10_600(color: AppColors.black),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            amount,
            style: AppTextStyle.style_14_700(color: AppColors.primary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
