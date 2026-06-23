import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:intl/intl.dart';
import 'package:mfresh_ops/modules/collections/controllers/collections_controller.dart';
import 'package:core/widgets/custom_app_loader.dart';

class CollectionsTable extends StatelessWidget {
  const CollectionsTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CollectionsController>();

    final double monthWidth = 60.w;
    final double dateWidth = 80.w;
    final double unitWidth = 90.w;

    return Obx(() {
      if (controller.isLoading.value) {
        return SizedBox(
          width: double.infinity,
          height: 300.h,
          child: const Center(child: CustomAppLoader()),
        );
      }

      if (controller.filteredCollections.isEmpty) {
        return const Center(child: Text('No data found'));
      }

      final stores = controller.storeNames;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.black),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Area
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCell('Month', width: monthWidth),
                    _buildHeaderCell('Date', width: dateWidth),
                    ...stores.map((store) => _buildHeaderCell(store, width: unitWidth)),
                    _buildHeaderCell('Other', width: unitWidth),
                    _buildHeaderCell('Total Actual', width: unitWidth),
                  ],
                ),
                // Data Rows
                ...controller.filteredCollections.asMap().entries.map((entry) {
                  final index = entry.key;
                  final row = entry.value;
                  final bool isEven = index % 2 == 0;

                  return Row(
                    children: [
                      _buildDataCell(row.month, width: monthWidth),
                      _buildDataCell(row.date, width: dateWidth),
                      ...stores.map((store) {
                        final actualValue = row.storeMetrics[store]?.actualNum;
                        return _buildUnitCell(actualValue, width: unitWidth, isEven: isEven);
                      }),
                      // Other
                      _buildUnitCell(row.otherMetrics.actualNum, width: unitWidth, isEven: isEven),
                      // Total
                      _buildDataCell(
                        row.totalMetrics.actual,
                        width: unitWidth,
                        color: AppColors.collectionPink, // Pinkish highlight for totals
                        isBold: true,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeaderCell(String text, {required double width}) {
    return Container(
      width: width,
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.collectionHeader, // Dark blue header
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Center(
        child: Text(
          text,
          style: AppTextStyle.style_10_500(
            color: AppColors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDataCell(
    String text, {
    required double width,
    Color color = AppColors.white,
    bool isBold = false,
  }) {
    return Container(
      width: width,
      height: 24.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: AppColors.black),
      ),
      child: Center(
        child: Text(
          text,
          style: isBold
              ? AppTextStyle.style_10_500(color: AppColors.black)
              : AppTextStyle.style_10_400(color: AppColors.black),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildUnitCell(num? value, {required double width, required bool isEven}) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    
    Color bgColor;
    String text = '';
    
    if (value == null || value == 0) {
      bgColor = AppColors.collectionPink; // Pink for empty/inactive
    } else {
      bgColor = AppColors.grey50; // Solid grey for all data cells
      text = currencyFormat.format(value);
    }

    return Container(
      width: width,
      height: 24.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: AppColors.black),
      ),
      child: Center(
        child: Text(
          text,
          style: AppTextStyle.style_10_400(color: AppColors.black),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
