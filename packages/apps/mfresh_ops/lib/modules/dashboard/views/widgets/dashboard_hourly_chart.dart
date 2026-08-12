import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/modules/dashboard/models/dashboard_data_model.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/dashboard/controllers/dashboard_controller.dart';
import 'chart_full_screen_viewer.dart';
import 'dart:math';

class DashboardHourlyChart extends StatefulWidget {
  final String title;
  final List<TimeRangeData> data;
  final Color barColor;
  final bool isRevenue;
  final bool isFullScreen;

  const DashboardHourlyChart({
    super.key,
    required this.title,
    required this.data,
    required this.barColor,
    this.isRevenue = false,
    this.isFullScreen = false,
  });

  @override
  State<DashboardHourlyChart> createState() => _DashboardHourlyChartState();
}

class _DashboardHourlyChartState extends State<DashboardHourlyChart> {
  int? touchedGroupIndex;
  Worker? _worker;

  @override
  void initState() {
    super.initState();
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
  void didUpdateWidget(DashboardHourlyChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      touchedGroupIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const SizedBox.shrink();
    }

    double maxVal = 0;
    for (var d in widget.data) {
      if (d.value > maxVal) maxVal = d.value.toDouble();
    }
    if (maxVal == 0) maxVal = 100;

    double yInterval = maxVal / 5;
    if (yInterval == 0) yInterval = 1;
    double maxY = maxVal + (maxVal * 0.15);

    double chartWidth = max(
      MediaQuery.of(context).size.width - 64.w, // Available width minus padding
      widget.data.length * 40.w, // Minimum width per bar
    );

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
                        child: DashboardHourlyChart(
                          title: widget.title,
                          data: widget.data,
                          barColor: widget.barColor,
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
              height: 250.h,
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
                          reservedSize: 20.h,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= widget.data.length) return const SizedBox.shrink();
                            return Transform.translate(
                              offset: const Offset(-25, -10),
                              child: Transform.rotate(
                                angle: -pi / 3,
                                alignment: Alignment.centerRight,
                                child: Container(
                                  width: 50,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    widget.data[index].timeRange,
                                    style: AppTextStyle.style_10_400(color: AppColors.grey500).copyWith(fontSize: 9.sp),
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
                        getTooltipColor: (_) => const Color(0xFF1F2937),
                        tooltipPadding: EdgeInsets.all(8.w),
                        tooltipMargin: 8.h,
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          String prefix = widget.isRevenue ? 'Revenue: ₹' : 'Bookings: ';
                          return BarTooltipItem(
                            '${widget.data[groupIndex].timeRange}\n',
                            AppTextStyle.style_12_700(color: Colors.white),
                            children: [
                              TextSpan(
                                text: '$prefix${NumberFormat('#,##,###').format(rod.toY)}',
                                style: AppTextStyle.style_12_400(color: widget.barColor.withOpacity(0.9)),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    barGroups: List.generate(
                      widget.data.length,
                      (index) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: widget.data[index].value.toDouble(),
                            color: widget.barColor,
                            width: 6.w, // Thin bars to fit all 24 on mobile screen without scrolling
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(2.r),
                              topRight: Radius.circular(2.r),
                            ),
                          ),
                        ],
                        showingTooltipIndicators: touchedGroupIndex == index ? [0] : [],
                      ),
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
