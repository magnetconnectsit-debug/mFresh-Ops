import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/data/models/revenue_report/dashboard_data_model.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/dashboard/controllers/dashboard_controller.dart';
import 'chart_full_screen_viewer.dart';

class DashboardMonthWiseChart extends StatefulWidget {
  final List<RevenueData> data;
  final String title;
  final bool showDays;
  final bool isFullScreen;

  const DashboardMonthWiseChart({
    super.key,
    required this.data,
    this.title = 'All Units Revenue By Month',
    this.showDays = false,
    this.isFullScreen = false,
  });

  @override
  State<DashboardMonthWiseChart> createState() => _DashboardMonthWiseChartState();
}

class _DashboardMonthWiseChartState extends State<DashboardMonthWiseChart> {
  int? touchedSpotIndex;
  Worker? _worker;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<DashboardController>()) {
      _worker = ever(Get.find<DashboardController>().rxClearTooltipsTrigger, (_) {
        if (mounted && touchedSpotIndex != null) {
          setState(() {
            touchedSpotIndex = null;
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
  void didUpdateWidget(DashboardMonthWiseChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      touchedSpotIndex = null;
    }
  }

  String _formatDate(String dateStr) {
    try {
      if (dateStr.length == 7) {
        // yyyy-MM
        final parsed = DateFormat('yyyy-MM').parse(dateStr);
        return DateFormat("MMM ''yy").format(parsed);
      } else {
        final date = DateTime.parse(dateStr);
        return widget.showDays ? DateFormat('dd-MMM').format(date) : DateFormat("MMM ''yy").format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const SizedBox.shrink();
    }

    double maxRevenue = 0;
    double totalRevenue = 0;
    for (var d in widget.data) {
      if (d.revenue > maxRevenue) maxRevenue = d.revenue.toDouble();
      totalRevenue += d.revenue.toDouble();
    }

    double averageRevenue = totalRevenue / widget.data.length;
    if (maxRevenue == 0) maxRevenue = 100;
    
    // Calculate dynamic interval for Y-axis
    double yInterval = maxRevenue / 5;
    if (yInterval == 0) yInterval = 1;
    
    // Add headroom
    double maxY = maxRevenue + (maxRevenue * 0.2);

    List<FlSpot> spots = [];
    for (int i = 0; i < widget.data.length; i++) {
      spots.add(FlSpot(i.toDouble(), widget.data[i].revenue.toDouble()));
    }

    final barData = LineChartBarData(
      spots: spots,
      isCurved: true,
      color: Colors.blue,
      barWidth: 2,
      isStrokeCapRound: true,
      belowBarData: BarAreaData(
        show: true,
        color: Colors.blue.withAlpha(30),
      ),
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: 3,
          color: Colors.black,
          strokeWidth: 0,
        ),
      ),
    );

    final chartWidget = LineChart(
      LineChartData(
        minX: -0.2,
        maxX: widget.data.length - 1 + 0.2,
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: yInterval,
          getDrawingHorizontalLine: (value) => const FlLine(color: Color(0xFFF3F4F6), strokeWidth: 1),
          getDrawingVerticalLine: (value) => const FlLine(color: Color(0xFFF3F4F6), strokeWidth: 1),
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
                    '₹${NumberFormat.compact().format(value)}',
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
              reservedSize: 50.h,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= widget.data.length || value != index.toDouble()) {
                  return const SizedBox.shrink();
                }
                
                bool isWeekend = false;
                if (widget.showDays) {
                  final dt = DateTime.tryParse(widget.data[index].date);
                  isWeekend = dt != null && (dt.weekday == DateTime.saturday || dt.weekday == DateTime.sunday);
                }
                
                return SideTitleWidget(
                  meta: meta,
                  angle: -0.8,
                  child: Text(
                    _formatDate(widget.data[index].date),
                    style: AppTextStyle.style_8_400(color: isWeekend ? Colors.red : AppColors.grey500),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        extraLinesData: ExtraLinesData(
          extraLinesOnTop: false,
          horizontalLines: [
            HorizontalLine(
              y: averageRevenue,
              color: Colors.red,
              strokeWidth: 1.5,
              dashArray: [4, 4],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(bottom: 4.h, left: 4.w),
                style: AppTextStyle.style_10_700(color: Colors.red),
                labelResolver: (line) => 'Avg Revenue: ₹${NumberFormat('#,##,###').format(averageRevenue)}',
              ),
            ),
          ],
        ),
        showingTooltipIndicators: () {
          final indicators = <ShowingTooltipIndicators>[];
          // Add non-touched spots first
          for (int i = 0; i < spots.length; i++) {
            if (spots[i].y == 0 || i == touchedSpotIndex) continue;
            indicators.add(ShowingTooltipIndicators([LineBarSpot(barData, 0, spots[i])]));
          }
          // Add touched spot last so it paints over others
          if (touchedSpotIndex != null && touchedSpotIndex! >= 0 && touchedSpotIndex! < spots.length) {
            if (spots[touchedSpotIndex!].y != 0) {
              indicators.add(ShowingTooltipIndicators([LineBarSpot(barData, 0, spots[touchedSpotIndex!])]));
            }
          }
          return indicators;
        }(),
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: false,
          touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
            if (response != null && response.lineBarSpots != null && response.lineBarSpots!.isNotEmpty) {
              final newIndex = response.lineBarSpots![0].spotIndex;
              if (touchedSpotIndex != newIndex) {
                setState(() {
                  touchedSpotIndex = newIndex;
                });
              }
            } else {
              final eventType = event.runtimeType.toString();
              if (eventType == 'FlTapDownEvent' || eventType == 'FlPanDownEvent') {
                if (touchedSpotIndex != null) {
                  setState(() {
                    touchedSpotIndex = null;
                  });
                }
              }
            }
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => touchedSpotIndex == spot.spotIndex ? const Color(0xFF1F2937) : Colors.transparent,
            tooltipPadding: EdgeInsets.all(4.w),
            tooltipMargin: 8.h,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                if (spot.y == 0) return null;
                
                bool isWknd = false;
                if (widget.showDays) {
                  final dt = DateTime.tryParse(widget.data[spot.spotIndex].date);
                  isWknd = dt != null && (dt.weekday == DateTime.saturday || dt.weekday == DateTime.sunday);
                }
                
                if (touchedSpotIndex == spot.spotIndex) {
                  return LineTooltipItem(
                    '${_formatDate(widget.data[spot.spotIndex].date)}\n',
                    AppTextStyle.style_12_700(color: Colors.white),
                    children: [
                      TextSpan(
                        text: 'Revenue: ₹${NumberFormat('#,##,###').format(spot.y)}',
                        style: AppTextStyle.style_12_400(color: isWknd ? Colors.red : Colors.white70),
                      ),
                    ],
                  );
                } else {
                  return LineTooltipItem(
                    '₹${NumberFormat.compact().format(spot.y)}',
                    AppTextStyle.style_10_600(color: isWknd ? Colors.red : Colors.black87).copyWith(fontSize: 8.sp),
                  );
                }
              }).toList();
            },
          ),
        ),
        lineBarsData: [barData],
      ),
    );

    Widget innerContent = Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 24),
              Expanded(
                child: Text(
                  widget.title,
                  style: AppTextStyle.style_14_700(color: AppColors.primary),
                  textAlign: TextAlign.center,
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
                        child: DashboardMonthWiseChart(
                          data: widget.data,
                          title: widget.title,
                          showDays: widget.showDays,
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
          if (widget.isFullScreen)
            Expanded(child: chartWidget)
          else
            SizedBox(height: 250.h, child: chartWidget),
        ],
      ),
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 8.h, color: const Color(0xFF059669)),
          if (widget.isFullScreen)
            Expanded(child: innerContent)
          else
            innerContent,
        ],
      ),
    );
  }
}
