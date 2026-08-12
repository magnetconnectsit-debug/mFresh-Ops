import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/modules/dashboard/models/dashboard_data_model.dart';

class DashboardMetricsCard extends StatelessWidget {
  final DashboardDataModel data;

  const DashboardMetricsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primary, width: 1.w),
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ---------------- TOTAL REVENUE SECTION ---------------- //
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: Text(
              'Total Revenue',
              textAlign: TextAlign.center,
              style: AppTextStyle.style_16_600(color: Colors.white).copyWith(fontSize: 14.sp),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Text(
              '₹ ${formatCurrency.format(data.totalRevenue).replaceAll('₹', '').trim()}',
              style: AppTextStyle.style_28_700(color: const Color(0xFF1F2937)).copyWith(fontSize: 18.sp),
            ),
          ),
          Container(
            color: AppColors.primary,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  _buildSubHeader('ON - Cust'),
                  Container(width: 1.w, color: Colors.white),
                  _buildSubHeader('ON - Ex_QR'),
                  Container(width: 1.w, color: Colors.white),
                  _buildSubHeader('ON - In_QR'),
                  Container(width: 1.w, color: Colors.white),
                  _buildSubHeader('Cash'),
                ],
              ),
            ),
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                _buildSubValue('₹${formatCurrency.format(data.customerPgRevenue).replaceAll('₹', '').trim()}'),
                Container(width: 1.w, color: AppColors.primary),
                _buildSubValue('₹${formatCurrency.format(data.externalQrRevenue).replaceAll('₹', '').trim()}'),
                Container(width: 1.w, color: AppColors.primary),
                _buildSubValue('₹${formatCurrency.format(data.kioskPgRevenue).replaceAll('₹', '').trim()}'),
                Container(width: 1.w, color: AppColors.primary),
                _buildSubValue('₹${formatCurrency.format(data.kioskCashRevenue).replaceAll('₹', '').trim()}'),
              ],
            ),
          ),

          // ---------------- BOOKING & SERVICES SECTION ---------------- //
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    color: AppColors.primary,
                    child: Text(
                      'Total Booking',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.style_16_600(color: Colors.white).copyWith(fontSize: 14.sp),
                    ),
                  ),
                ),
                Container(width: 1.w, color: Colors.white), // Divider
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    color: AppColors.primary,
                    child: Text(
                      'Total Services',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.style_16_600(color: Colors.white).copyWith(fontSize: 14.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // BOOKINGS COLUMN
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        child: Text(
                          '${data.totalBookings}',
                          style: AppTextStyle.style_16_600(color: const Color(0xFF1F2937)).copyWith(fontSize: 14.sp),
                        ),
                      ),
                      Container(
                        color: AppColors.primary,
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              _buildSubHeader('ON - Cust', fontSize: 8),
                              Container(width: 1.w, color: Colors.white),
                              _buildSubHeader('ON - Ex_QR', fontSize: 8),
                              Container(width: 1.w, color: Colors.white),
                              _buildSubHeader('ON - In_QR', fontSize: 8),
                              Container(width: 1.w, color: Colors.white),
                              _buildSubHeader('Cash', fontSize: 8),
                            ],
                          ),
                        ),
                      ),
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            _buildSubValue('${data.customerPg}', fontSize: 10),
                            Container(width: 1.w, color: AppColors.primary),
                            _buildSubValue('${data.externalQr}', fontSize: 10),
                            Container(width: 1.w, color: AppColors.primary),
                            _buildSubValue('${data.kioskPg}', fontSize: 10),
                            Container(width: 1.w, color: AppColors.primary),
                            _buildSubValue('${data.kioskCash}', fontSize: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1.w, color: AppColors.primary), // Vertical Divider
                // SERVICES COLUMN
                Expanded(
                  child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        child: Text(
                          '${data.totalServicesCount}',
                          style: AppTextStyle.style_16_600(color: const Color(0xFF1F2937)).copyWith(fontSize: 14.sp),
                        ),
                      ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeader(String text, {double fontSize = 11}) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 0.5.w),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: AppTextStyle.style_12_400(color: Colors.white).copyWith(fontSize: fontSize.sp),
          ),
        ),
      ),
    );
  }

  Widget _buildSubValue(String text, {double fontSize = 12}) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 0.5.w),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyle.style_12_600(color: const Color(0xFF059669)).copyWith(fontSize: fontSize.sp),
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
