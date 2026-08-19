import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/data/models/revenue_report/dashboard_data_model.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/dashboard/controllers/dashboard_controller.dart';
import 'chart_full_screen_viewer.dart';

class DashboardUnitWiseChart extends StatefulWidget {
  final List<UnitWiseRevenueData> data;
  final bool isFullScreen;

  const DashboardUnitWiseChart({super.key, required this.data, this.isFullScreen = false});

  @override
  State<DashboardUnitWiseChart> createState() => _DashboardUnitWiseChartState();
}

class _DashboardUnitWiseChartState extends State<DashboardUnitWiseChart> {
  int? touchedGroupIndex;
  int? touchedSpotIndex;
  Set<String> hiddenUnits = {};
  Worker? _worker;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<DashboardController>()) {
      _worker = ever(Get.find<DashboardController>().rxClearTooltipsTrigger, (_) {
        if (mounted && (touchedSpotIndex != null || touchedGroupIndex != null)) {
          setState(() {
            touchedSpotIndex = null;
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
  void didUpdateWidget(DashboardUnitWiseChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      touchedSpotIndex = null;
      touchedGroupIndex = null;
    }
  }


  // Predefined palette matching screenshot
  final Map<String, Color> _unitColors = {
    'MM25003': Colors.blue,
    'MM25005': Colors.orange,
    'MM25002': Colors.green,
    'MM25004': Colors.redAccent,
    'MM2500DEV': Colors.deepPurpleAccent,
  };

  final List<Color> _fallbackPalette = [
    Colors.teal,
    Colors.brown,
    Colors.pink,
    Colors.cyan,
    Colors.amber,
  ];

  Color _getColorForUnit(String unitNo, int index) {
    if (_unitColors.containsKey(unitNo)) {
      return _unitColors[unitNo]!;
    }
    return _fallbackPalette[index % _fallbackPalette.length];
  }

  String _formatDate(String dateStr) {
    try {
      final d = DateFormat('yyyy-MM-dd').parse(dateStr);
      return DateFormat('dd/MM').format(d);
    } catch (_) {
      return dateStr;
    }
  }

  bool _isWeekend(String dateStr) {
    try {
      final d = DateFormat('yyyy-MM-dd').parse(dateStr);
      return d.weekday == DateTime.saturday || d.weekday == DateTime.sunday;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox.shrink();

    // We now use the raw data directly to support both daily and monthly views based on API response
    List<UnitWiseRevenueData> aggregatedData = widget.data;

    // 1. Extract distinct dates and units
    final distinctDatesSet = aggregatedData.map((e) => e.date).toSet().toList();
    distinctDatesSet.sort(); // Sort chronologically
    
    final distinctUnitsSet = aggregatedData.map((e) => e.unitNo).toSet().toList();
    
    if (distinctDatesSet.isEmpty || distinctUnitsSet.isEmpty) {
      return const SizedBox.shrink();
    }

    // 2. Determine Max Revenue for Y-axis scaling (only for visible units)
    double maxRevenue = 0;
    double totalCombinedRevenue = 0;
    for (var d in aggregatedData) {
      if (!hiddenUnits.contains(d.unitNo)) {
        if (d.revenue > maxRevenue) maxRevenue = d.revenue.toDouble();
        totalCombinedRevenue += d.revenue.toDouble();
      }
    }
    
    // Fallback if all units are hidden
    if (maxRevenue == 0) maxRevenue = 100;

    // Calculate dynamic interval for Y-axis
    double yInterval = maxRevenue / 5;
    if (yInterval == 0) yInterval = 1;
    
    // Average overall (only for visible units)
    int visibleUnitsCount = distinctUnitsSet.length - hiddenUnits.length;
    double averageRevenue = visibleUnitsCount > 0 ? (totalCombinedRevenue / distinctDatesSet.length) : 0;
    if (averageRevenue > maxRevenue) maxRevenue = averageRevenue;
    
    // Add headroom
    maxRevenue = maxRevenue * 1.2;
    if (maxRevenue == 0) maxRevenue = 100;

    // 3. Generate LineChartBarData for each unit
    List<LineChartBarData> lineBarsData = [];
    
    for (int i = 0; i < distinctUnitsSet.length; i++) {
      String unitNo = distinctUnitsSet[i];
      if (hiddenUnits.contains(unitNo)) continue;
      
      Color unitColor = _getColorForUnit(unitNo, i);

      // Extract spots for this unit, ensuring every date has a point
      List<FlSpot> spots = [];
      final unitData = aggregatedData.where((e) => e.unitNo == unitNo).toList();
      
      for (int dateIndex = 0; dateIndex < distinctDatesSet.length; dateIndex++) {
        String currentDate = distinctDatesSet[dateIndex];
        
        // Find if the unit has data for this specific date
        final matchingData = unitData.where((e) => e.date == currentDate).toList();
        
        if (matchingData.isNotEmpty) {
          spots.add(FlSpot(dateIndex.toDouble(), matchingData.first.revenue.toDouble()));
        } else {
          // No data for this month, default to 0
          spots.add(FlSpot(dateIndex.toDouble(), 0));
        }
      }

      // Sort spots by x-axis just in case
      spots.sort((a, b) => a.x.compareTo(b.x));

      lineBarsData.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: unitColor,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: unitColor,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: unitColor.withAlpha(50),
          ),
        ),
      );
    }

    final chartWidget = LineChart(
      LineChartData(
        minX: -0.5,
        maxX: distinctDatesSet.length - 0.5,
        minY: 0,
        maxY: maxRevenue,
        showingTooltipIndicators: () {
          List<ShowingTooltipIndicators> indicators = [];
          // Add non-touched spots first
          for (int xIndex = 0; xIndex < distinctDatesSet.length; xIndex++) {
            if (xIndex == touchedSpotIndex) continue;
            for (int barIndex = 0; barIndex < lineBarsData.length; barIndex++) {
              if (lineBarsData[barIndex].spots[xIndex].y != 0) {
                indicators.add(ShowingTooltipIndicators([
                  LineBarSpot(lineBarsData[barIndex], barIndex, lineBarsData[barIndex].spots[xIndex])
                ]));
              }
            }
          }
          
          // Add touched spot last so it paints on top
          if (touchedSpotIndex != null) {
            final xIndex = touchedSpotIndex!;
            List<LineBarSpot> spotsForThisX = [];
            for (int barIndex = 0; barIndex < lineBarsData.length; barIndex++) {
              if (lineBarsData[barIndex].spots[xIndex].y != 0) {
                spotsForThisX.add(LineBarSpot(lineBarsData[barIndex], barIndex, lineBarsData[barIndex].spots[xIndex]));
              }
            }
            if (spotsForThisX.isNotEmpty) {
              indicators.add(ShowingTooltipIndicators(spotsForThisX));
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
              if (touchedSpots.isEmpty) return [];
              
              int xIndex = touchedSpots.first.spotIndex;
              
              if (touchedSpotIndex == xIndex) {
                // Detailed sticky tooltip for touched vertical line
                final rawDate = distinctDatesSet[xIndex];
                final isWknd = _isWeekend(rawDate);
                
                List<String> visibleUnits = distinctUnitsSet.where((u) => !hiddenUnits.contains(u)).toList();
                
                bool isFirst = true;
                return touchedSpots.map((spot) {
                  int barIndex = spot.barIndex;
                  double yVal = spot.y;
                  
                  if (yVal == 0) return null;
                  
                  String uName = visibleUnits.length > barIndex ? visibleUnits[barIndex] : 'Unknown';
                  Color uColor = spot.y > 0 ? (lineBarsData.length > barIndex ? (lineBarsData[barIndex].color ?? Colors.blue) : Colors.blue) : Colors.blue;
                  
                  if (isFirst) {
                    isFirst = false;
                    return LineTooltipItem(
                      '${_formatDate(rawDate)}\n',
                      AppTextStyle.style_12_700(color: Colors.white),
                      children: [
                        TextSpan(
                          text: '$uName: ₹${NumberFormat('#,##,###').format(yVal)}',
                          style: AppTextStyle.style_12_400(color: isWknd ? Colors.red : uColor),
                        ),
                      ],
                    );
                  } else {
                    return LineTooltipItem(
                      '$uName: ₹${NumberFormat('#,##,###').format(yVal)}',
                      AppTextStyle.style_12_400(color: isWknd ? Colors.red : uColor),
                    );
                  }
                }).toList();
              } else {
                // Return permanent floating labels for non-touched
                return touchedSpots.map((spot) {
                  if (spot.y == 0) return null;
                  final rawDate = distinctDatesSet[spot.spotIndex];
                  final isWknd = _isWeekend(rawDate);
                  return LineTooltipItem(
                    NumberFormat.compact().format(spot.y),
                    AppTextStyle.style_10_600(color: isWknd ? Colors.red : Colors.black87).copyWith(fontSize: 8.sp),
                  );
                }).toList();
              }
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: maxRevenue / 5,
          getDrawingHorizontalLine: (value) => const FlLine(color: Color(0xFFF3F4F6), strokeWidth: 1),
          getDrawingVerticalLine: (value) => const FlLine(color: Color(0xFFF3F4F6), strokeWidth: 1),
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
                labelResolver: (line) => 'Avg: ₹${NumberFormat('#,##,###').format(averageRevenue)}',
              ),
            ),
          ],
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48.h,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= distinctDatesSet.length || value != value.toInt()) {
                  return const SizedBox.shrink();
                }
                final rawDate = distinctDatesSet[value.toInt()];
                final isWknd = _isWeekend(rawDate);
                return Padding(
                  padding: EdgeInsets.only(top: 16.h),
                  child: Transform.rotate(
                    angle: -0.8, // More tilt for dates
                    child: Text(
                      _formatDate(rawDate),
                      style: AppTextStyle.style_10_400(color: isWknd ? Colors.red : Colors.black54),
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50.w,
              interval: maxRevenue / 5,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  '₹${NumberFormat.compact().format(value)}',
                  style: AppTextStyle.style_10_400(color: Colors.black54),
                  textAlign: TextAlign.right,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.withAlpha(50), width: 1),
            left: BorderSide(color: Colors.grey.withAlpha(50), width: 1),
          ),
        ),
        lineBarsData: lineBarsData,
      ),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );

    Widget innerContent = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
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
                  'Unit-wise Revenues',
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
                        title: 'Unit-wise Revenues',
                        child: DashboardUnitWiseChart(data: widget.data, isFullScreen: true),
                      ),
                    );
                  },
                )
              else
                const SizedBox(width: 24),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Legends
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12.w,
            runSpacing: 8.h,
            children: List.generate(distinctUnitsSet.length, (index) {
              String unitNo = distinctUnitsSet[index];
              Color color = _getColorForUnit(unitNo, index);
              bool isHidden = hiddenUnits.contains(unitNo);
              
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isHidden) {
                      hiddenUnits.remove(unitNo);
                    } else {
                      hiddenUnits.add(unitNo);
                    }
                    // Reset sticky tooltip if data changes
                    touchedSpotIndex = null;
                  });
                },
                borderRadius: BorderRadius.circular(4.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: isHidden ? Colors.grey.withAlpha(50) : color.withAlpha(50),
                          border: Border.all(color: isHidden ? Colors.grey : color, width: 2),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        unitNo,
                        style: AppTextStyle.style_12_400(
                          color: isHidden ? Colors.grey : Colors.black87,
                        ).copyWith(
                          decoration: isHidden ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 16.h),
          Center(
            child: Text(
              'Average Revenue: ₹${NumberFormat('#,##,###').format(averageRevenue)}',
              style: AppTextStyle.style_12_700(color: Colors.red),
            ),
          ),
          SizedBox(height: 24.h),
          if (widget.isFullScreen)
            Expanded(child: chartWidget)
          else
            SizedBox(height: 300.h, child: chartWidget),
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
