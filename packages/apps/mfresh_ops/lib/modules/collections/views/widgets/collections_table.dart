import 'package:core/widgets/custom_app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:intl/intl.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:mfresh_ops/modules/collections/controllers/collections_controller.dart';

class CollectionsTable extends StatelessWidget {
  const CollectionsTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CollectionsController>();
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Obx(() {
      if (controller.isLoading.value) {
        return SizedBox(
          height: 300.h,
          child: const Center(child: CustomAppLoader()),
        );
      }

      if (controller.collections.isEmpty) {
        return SizedBox(
          height: 300.h,
          child: const Center(child: Text('No data found for this month')),
        );
      }

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.borderColor),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            border: TableBorder.all(color: AppColors.borderColor, width: 1),
            children: [
              // Header Row
              TableRow(
                decoration: const BoxDecoration(
                  color: Color(0xFF1C3B65), // Dark blue from screenshot
                ),
                children: [
                  _buildHeaderCell('Month'),
                  _buildHeaderCell('Date'),
                  for (final unit in controller.units) _buildHeaderCell(unit),
                  _buildHeaderCell('Total Actual'),
                ],
              ),
              // Data Rows
              ...controller.collections.asMap().entries.map((entry) {
                final index = entry.key;
                final row = entry.value;
                final bool isEven = index % 2 == 0;
                final Color rowColor = isEven ? AppColors.white : const Color(0xFFF0F0F0); // subtle grey for zebra stripe

                return TableRow(
                  children: [
                    _buildDataCell('Jun-2026', color: AppColors.white), // Standard white bg for first two columns
                    _buildDataCell(AppDateUtils.formatToApiDate(row.date), color: AppColors.white),
                    for (final unit in controller.units)
                      _buildUnitCell(row.unitCollections[unit], currencyFormat, isEven),
                    _buildDataCell(
                      row.totalActual == 0 ? '₹0' : currencyFormat.format(row.totalActual),
                      color: const Color(0xFFF1D3E9), // Pinkish highlight for totals
                      isBold: true,
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: Center(
        child: Text(
          text,
          style: AppTextStyle.style_12_700(color: AppColors.white),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, {required Color color, bool isBold = false}) {
    return Container(
      color: color,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: Center(
        child: Text(
          text,
          style: isBold ? AppTextStyle.style_12_700(color: AppColors.black) : AppTextStyle.style_12_400(color: AppColors.black),
        ),
      ),
    );
  }

  Widget _buildUnitCell(double? value, NumberFormat currencyFormat, bool isEven) {
    // Determine background color
    Color bgColor;
    String text = '';
    if (value == null || value == 0) {
      bgColor = const Color(0xFFF1D3E9); // Pink for empty/inactive
    } else {
      bgColor = isEven ? AppColors.white : const Color(0xFFE8E8E8); // Zebra stripes
      text = currencyFormat.format(value);
    }

    return Container(
      color: bgColor,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: Center(
        child: Text(
          text,
          style: AppTextStyle.style_12_400(color: AppColors.black),
        ),
      ),
    );
  }
}
