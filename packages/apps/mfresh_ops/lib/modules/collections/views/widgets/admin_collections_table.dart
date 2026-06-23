import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:intl/intl.dart';
import 'package:mfresh_ops/modules/collections/controllers/admin_collections_controller.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:mfresh_ops/data/models/collections/admin_collection_model.dart';

class AdminCollectionsTable extends StatelessWidget {
  const AdminCollectionsTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminCollectionsController>();

    final double monthWidth = 60.w;
    final double dateWidth = 80.w;
    final double subColWidth = 70.w;
    final double unitWidth = subColWidth * 3; // Actual, Dashboard, Difference

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
                    _buildHeaderCell('Month', width: monthWidth, height: 48.h),
                    _buildHeaderCell('Date', width: dateWidth, height: 48.h),
                    ...stores.map((store) => _buildStoreHeader(store, unitWidth, subColWidth)),
                    _buildStoreHeader('Other', unitWidth, subColWidth),
                    _buildStoreHeader('Total', unitWidth, subColWidth),
                  ],
                ),
                // Data Rows
                ...controller.filteredCollections.asMap().entries.map((entry) {
                  final index = entry.key;
                  final row = entry.value;

                  return Row(
                    children: [
                      _buildDataCell(row.month, width: monthWidth, color: AppColors.white),
                      _buildDataCell(row.date, width: dateWidth, color: AppColors.white),
                      ...stores.map((store) {
                        return _buildMetricCells(row.storeMetrics[store], subColWidth);
                      }),
                      // Other
                      _buildMetricCells(row.otherMetrics, subColWidth),
                      // Total
                      _buildMetricCells(row.totalMetrics, subColWidth, isTotal: true),
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

  Widget _buildStoreHeader(String title, double totalWidth, double subWidth) {
    return Column(
      children: [
        _buildHeaderCell(title, width: totalWidth, height: 24.h),
        Row(
          children: [
            _buildHeaderCell('Actual', width: subWidth, height: 24.h),
            _buildHeaderCell('Dashboard', width: subWidth, height: 24.h),
            _buildHeaderCell('Difference', width: subWidth, height: 24.h),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text, {required double width, required double height}) {
    return Container(
      width: width,
      height: height,
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

  Widget _buildMetricCells(AdminStoreMetricModel? metric, double width, {bool isTotal = false}) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    // Actual Cell
    Color actualBg = AppColors.collectionPink;
    if (!isTotal && metric != null && metric.actualNum != 0) {
      actualBg = AppColors.white;
    }
    String actualText = currencyFormat.format(metric?.actualNum ?? 0);

    // Dashboard Cell
    String dashText = currencyFormat.format(metric?.dashboardNum ?? 0);

    // Difference Cell
    Color diffBg = const Color(0xFFD6F0CD); // Light Green
    Color diffTextCol = AppColors.primaryGreen;
    String diffText = currencyFormat.format(0);

    if (metric != null) {
      if (metric.differenceNum < 0) {
        diffBg = const Color(0xFFFDE8E8); // Light Red
        diffTextCol = Colors.red;
      }
      diffText = currencyFormat.format(metric.differenceNum);
    }

    return Row(
      children: [
        _buildDataCell(actualText, width: width, color: actualBg),
        _buildDataCell(dashText, width: width, color: AppColors.white),
        _buildDataCell(diffText, width: width, color: diffBg, textColor: diffTextCol, isBold: true),
      ],
    );
  }

  Widget _buildDataCell(
    String text, {
    required double width,
    Color color = AppColors.white,
    Color? textColor,
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
              ? AppTextStyle.style_10_500(color: textColor ?? AppColors.black)
              : AppTextStyle.style_10_400(color: textColor ?? AppColors.black),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
