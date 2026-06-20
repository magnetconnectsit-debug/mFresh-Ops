import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/deposits/controllers/deposits_controller.dart';
import 'package:intl/intl.dart';

class DepositsTable extends StatelessWidget {
  const DepositsTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DepositsController>();
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '');

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.borderColor, width: 1.0),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() {
          if (controller.deposits.isEmpty) {
            return Padding(
              padding: EdgeInsets.all(16.r),
              child: Text('No deposits found', style: AppTextStyle.style_14_400(color: AppColors.grey500)),
            );
          }

          return Table(
            columnWidths: const {
              0: FixedColumnWidth(80),
              1: FixedColumnWidth(100),
              2: FixedColumnWidth(80),
              3: FixedColumnWidth(80),
              4: FixedColumnWidth(250),
              5: FixedColumnWidth(80),
            },
            border: TableBorder(
              horizontalInside: BorderSide(color: AppColors.borderColor, width: 1.0),
              verticalInside: BorderSide(color: AppColors.borderColor, width: 1.0),
            ),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFF8F9FA)), // Light gray header
                children: [
                  _buildHeaderCell('Date'),
                  _buildHeaderCell('Deposit'),
                  _buildHeaderCell('Month'),
                  _buildHeaderCell('File'),
                  _buildHeaderCell('Remark'),
                  _buildHeaderCell('Action'),
                ],
              ),
              ...controller.deposits.map((item) {
                return TableRow(
                  children: [
                    _buildDataCell(item.date),
                    _buildDataCell(currencyFormat.format(item.deposit)),
                    _buildDataCell(item.month),
                    _buildImageCell(),
                    _buildDataCell(item.remark),
                    _buildActionCell(),
                  ],
                );
              }),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Text(
        text,
        style: AppTextStyle.style_12_600(color: AppColors.black),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Text(
        text,
        style: AppTextStyle.style_12_400(color: AppColors.black),
      ),
    );
  }

  Widget _buildImageCell() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Container(
        height: 40.r,
        width: 40.r,
        decoration: BoxDecoration(
          color: AppColors.grey200,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: AppColors.grey300),
        ),
        child: Icon(Icons.image, size: 20.r, color: AppColors.grey500),
      ),
    );
  }

  Widget _buildActionCell() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.edit_outlined, size: 20.r, color: AppColors.grey500),
          Icon(Icons.delete_outline, size: 20.r, color: AppColors.grey500),
        ],
      ),
    );
  }
}
