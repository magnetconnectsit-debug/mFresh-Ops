import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/collections/controllers/admin_collections_controller.dart';
import 'package:mfresh_ops/data/models/collections/admin_collection_model.dart';
import 'package:core/widgets/custom_app_loader.dart';

class AdminCollectionsTable extends StatelessWidget {
  const AdminCollectionsTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminCollectionsController>();

    final double monthWidth = 80.w;
    final double dateWidth = 100.w;
    final double actualWidth = 60.w;
    final double dashboardWidth = 70.w;
    final double diffWidth = 70.w;
    final double groupWidth = actualWidth + dashboardWidth + diffWidth;

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
      final allGroups = [...stores, 'Other', 'Total'];

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderColor),
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
                    Column(
                      children: [
                        // Top Header Row for Groups
                        Row(
                          children: allGroups
                              .map(
                                (group) => _buildHeaderCell(
                                  group,
                                  width: groupWidth,
                                  height: 24.h,
                                ),
                              )
                              .toList(),
                        ),
                        // Sub Header Row for Metrics
                        Row(
                          children: allGroups
                              .expand(
                                (_) => [
                                  _buildHeaderCell(
                                    'Actual',
                                    width: actualWidth,
                                    height: 24.h,
                                  ),
                                  _buildHeaderCell(
                                    'Dashboard',
                                    width: dashboardWidth,
                                    height: 24.h,
                                  ),
                                  _buildHeaderCell(
                                    'Difference',
                                    width: diffWidth,
                                    height: 24.h,
                                  ),
                                ],
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ],
                ),
                // Data Rows
                ...controller.filteredCollections.map((row) {
                  return Row(
                    children: [
                      _buildDataCell(row.month, width: monthWidth),
                      _buildDataCell(row.date, width: dateWidth),
                      ...stores.expand((store) {
                        final metric =
                            row.storeMetrics[store] ??
                            StoreMetricModel(
                              actual: '0',
                              dashboard: '0',
                              difference: '0',
                            );
                        return [
                          _buildColorCell(
                            metric.actual,
                            width: actualWidth,
                            color: const Color(0xFFF2D1ED),
                          ),
                          _buildColorCell(
                            metric.dashboard,
                            width: dashboardWidth,
                            color: AppColors.white,
                          ),
                          _buildColorCell(
                            metric.difference,
                            width: diffWidth,
                            color: const Color(0xFFD6F0CD),
                            isDiff: true,
                          ),
                        ];
                      }),
                      // Other
                      _buildColorCell(
                        row.otherMetrics.actual,
                        width: actualWidth,
                        color: const Color(0xFFF2D1ED),
                      ),
                      _buildColorCell(
                        row.otherMetrics.dashboard,
                        width: dashboardWidth,
                        color: AppColors.white,
                      ),
                      _buildColorCell(
                        row.otherMetrics.difference,
                        width: diffWidth,
                        color: const Color(0xFFD6F0CD),
                        isDiff: true,
                      ),
                      // Total
                      _buildColorCell(
                        row.totalMetrics.actual,
                        width: actualWidth,
                        color: const Color(0xFFF2D1ED),
                      ),
                      _buildColorCell(
                        row.totalMetrics.dashboard,
                        width: dashboardWidth,
                        color: AppColors.white,
                      ),
                      _buildColorCell(
                        row.totalMetrics.difference,
                        width: diffWidth,
                        color: const Color(0xFFD6F0CD),
                        isDiff: true,
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

  Widget _buildHeaderCell(
    String text, {
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF1B3B5C), // Dark blue header from screenshot
        border: Border.all(color: AppColors.white, width: 0.5),
      ),
      child: Text(
        text,
        style: AppTextStyle.style_10_600(color: AppColors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell(String text, {required double width}) {
    return Container(
      width: width,
      height: 32.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.borderColor, width: 0.5),
      ),
      child: Text(
        text,
        style: AppTextStyle.style_10_400(color: AppColors.black),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildColorCell(
    String text, {
    required double width,
    required Color color,
    bool isDiff = false,
  }) {
    return Container(
      width: width,
      height: 32.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: AppColors.borderColor, width: 0.5),
      ),
      child: Text(
        text,
        style: AppTextStyle.style_10_500(
          color: isDiff && text == '0'
              ? AppColors.primaryGreen
              : AppColors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
