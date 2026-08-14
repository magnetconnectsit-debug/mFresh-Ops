import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/modules/dashboard/models/dashboard_data_model.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/dashboard/controllers/dashboard_controller.dart';
import 'dart:math';

import 'chart_full_screen_viewer.dart';

class DashboardServiceChart extends StatefulWidget {
  final String title;
  final List<ServiceData> data;
  final bool isRevenue;
  final bool isFullScreen;

  const DashboardServiceChart({
    super.key,
    required this.title,
    required this.data,
    required this.isRevenue,
    this.isFullScreen = false,
  });

  @override
  State<DashboardServiceChart> createState() => _DashboardServiceChartState();
}

class _DashboardServiceChartState extends State<DashboardServiceChart> {
  int? touchedGroupIndex;
  late List<ServiceData> sortedData;
  Worker? _worker;

  @override
  void initState() {
    super.initState();
    _sortData();
    if (Get.isRegistered<DashboardController>()) {
      _worker = ever(Get.find<DashboardController>().rxClearTooltipsTrigger, (_) {
        if (mounted && touchedGroupIndex != null) {
          setState(() {
            touchedGroupIndex = null;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _worker?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DashboardServiceChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data || oldWidget.isRevenue != widget.isRevenue) {
      _sortData();
      touchedGroupIndex = null;
    }
  }

  void _sortData() {
    sortedData = List.from(widget.data);
    if (widget.isRevenue) {
      sortedData.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
    } else {
      sortedData.sort((a, b) => b.bookingCount.compareTo(a.bookingCount));
    }
  }

  Color _getColor(String name) {
    name = name.toLowerCase();
    if (name.contains('shower') || name.contains('dress') || name.contains('combo') || name.contains('fee') || name.contains('dental')) {
      return const Color(0xFFD27D7D); // Brownish red
    }
    if (name.contains('female')) {
      return const Color(0xFFF8A5C2); // Pink
    }
    if (name.contains('male')) {
      return const Color(0xFF84C5F4); // Light blue
    }
    return const Color(0xFFB2BEC3); // Grey
  }

  @override
  Widget build(BuildContext context) {
    if (sortedData.isEmpty) {
      return const SizedBox.shrink();
    }

    double maxVal = 0;
    for (var d in sortedData) {
      double val = widget.isRevenue ? d.totalRevenue.toDouble() : d.bookingCount.toDouble();
      if (val > maxVal) maxVal = val;
    }
    if (maxVal == 0) maxVal = 100;

    double yInterval = maxVal / 5;
    if (yInterval == 0) yInterval = 1;
    double maxY = maxVal + (maxVal * 0.15);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 24),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    widget.title,
                    style: AppTextStyle.style_14_700(color: AppColors.primary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              if (!widget.isFullScreen)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.fullscreen, color: AppColors.grey500),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => ChartFullScreenViewer(
                        title: widget.title,
                        child: DashboardServiceChart(
                          title: widget.title,
                          data: widget.data,
                          isRevenue: widget.isRevenue,
                          isFullScreen: true,
                        ),
                      ),
                    );
                  },
                )
              else
                const SizedBox(width: 24),
            ],
          ),
          SizedBox(height: 24.h),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: SizedBox(
              height: 280.h,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  minY: 0,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: yInterval,
                    getDrawingHorizontalLine: (value) => const FlLine(color: Color(0xFFF3F4F6), strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50.w,
                        interval: yInterval,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox.shrink();
                          return Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: Text(
                              widget.isRevenue
                                  ? '₹${NumberFormat.compact().format(value)}'
                                  : NumberFormat.compact().format(value),
                              style: AppTextStyle.style_10_400(color: AppColors.grey500),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45.h,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= sortedData.length) return const SizedBox.shrink();
                          return Transform.translate(
                            offset: const Offset(-45, -10),
                            child: Transform.rotate(
                              angle: -pi / 3,
                              alignment: Alignment.centerRight,
                              child: Container(
                                width: 90,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  sortedData[index].serviceName,
                                  style: AppTextStyle.style_10_400(color: AppColors.grey500).copyWith(fontSize: 8.sp),
                                  softWrap: false,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: const Color(0xFFE5E7EB)),
                      left: BorderSide(color: const Color(0xFFE5E7EB)),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    handleBuiltInTouches: false,
                    touchCallback: (FlTouchEvent event, barTouchResponse) {
                      if (barTouchResponse != null && barTouchResponse.spot != null) {
                        setState(() {
                          touchedGroupIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                        });
                      } else {
                        final eventType = event.runtimeType.toString();
                        if (eventType == 'FlTapDownEvent' || eventType == 'FlPanDownEvent') {
                          setState(() {
                            touchedGroupIndex = null;
                          });
                        }
                      }
                    },
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => touchedGroupIndex == group.x ? const Color(0xFF1F2937) : Colors.transparent,
                      tooltipPadding: EdgeInsets.all(4.w),
                      tooltipMargin: 4.h,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        if (rod.toY == 0) return null;

                        String prefix = widget.isRevenue ? '₹' : '';
                        String formattedValue = NumberFormat('#,##,###').format(rod.toY);

                        if (touchedGroupIndex == groupIndex) {
                          String fullPrefix = widget.isRevenue ? 'Revenue: ₹' : 'Count: ';
                          return BarTooltipItem(
                            '${sortedData[groupIndex].serviceName}\n',
                            AppTextStyle.style_12_700(color: Colors.white),
                            children: [
                              TextSpan(
                                text: '$fullPrefix$formattedValue',
                                style: AppTextStyle.style_12_400(color: Colors.white.withValues(alpha: 0.9)),
                              ),
                            ],
                          );
                        } else {
                          return BarTooltipItem(
                            '$prefix$formattedValue',
                            AppTextStyle.style_10_600(color: Colors.black87).copyWith(fontSize: 8.sp),
                          );
                        }
                      },
                    ),
                  ),
                  barGroups: List.generate(
                    sortedData.length,
                    (index) {
                      double val = widget.isRevenue ? sortedData[index].totalRevenue.toDouble() : sortedData[index].bookingCount.toDouble();
                      return BarChartGroupData(
                        x: index,
                        showingTooltipIndicators: [0],
                        barRods: [
                          BarChartRodData(
                            toY: val,
                            color: _getColor(sortedData[index].serviceName),
                            width: 8.w, // Slightly thicker since there are max ~16 items
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(2.r),
                              topRight: Radius.circular(2.r),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
