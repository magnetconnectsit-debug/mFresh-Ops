import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/data/models/revenue_report/dashboard_data_model.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/dashboard/controllers/dashboard_controller.dart';
import 'dart:math';
import 'chart_full_screen_viewer.dart';

class DashboardUnitsChart extends StatefulWidget {
  final List<UnitData> data;
  final bool isFullScreen;

  const DashboardUnitsChart({super.key, required this.data, this.isFullScreen = false});

  @override
  State<DashboardUnitsChart> createState() => _DashboardUnitsChartState();
}

class _DashboardUnitsChartState extends State<DashboardUnitsChart> {
  int? tappedIndex;
  Worker? _worker;
  Set<String> hiddenUnits = {};

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
  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<DashboardController>()) {
      _worker = ever(Get.find<DashboardController>().rxClearTooltipsTrigger, (_) {
        if (mounted && tappedIndex != null) {
          setState(() {
            tappedIndex = null;
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
  void didUpdateWidget(DashboardUnitsChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      tappedIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleData = widget.data.where((e) => !hiddenUnits.contains(e.unitNo)).toList();
    if (visibleData.isEmpty) {
      return const SizedBox.shrink();
    }

    final formatCurrency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    final formatCompactCurrency = NumberFormat.compactCurrency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    // Calculate max values for Y axes
    double maxRevenue = 0;
    double maxServices = 0;

    for (var unit in visibleData) {
      if (unit.revenue > maxRevenue) maxRevenue = unit.revenue.toDouble();
      if (unit.servicesCount > maxServices) {
        maxServices = unit.servicesCount.toDouble();
      }
    }

    double rawMaxRevenue = maxRevenue;
    double rawMaxServices = maxServices;

    maxServices = maxServices * 1.5;

    double calculateNiceInterval(double maxValue, int desiredTicks) {
      if (maxValue <= 0) return 1.0;
      double tickSpacing = maxValue / desiredTicks;
      double magnitude = pow(10, (log(tickSpacing) / ln10).floor()).toDouble();
      double normalizedTickSpacing = tickSpacing / magnitude;

      double niceSpacing;
      if (normalizedTickSpacing < 1.5) {
        niceSpacing = 1.0;
      } else if (normalizedTickSpacing < 3.0) {
        niceSpacing = 2.0;
      } else if (normalizedTickSpacing < 7.0) {
        niceSpacing = 5.0;
      } else {
        niceSpacing = 10.0;
      }
      return niceSpacing * magnitude;
    }

    double niceRevenueInterval = calculateNiceInterval(
      maxRevenue == 0 ? 100 : maxRevenue,
      4,
    );
    maxRevenue = maxRevenue == 0
        ? 100
        : (maxRevenue / niceRevenueInterval).ceil() * niceRevenueInterval;
    if (maxRevenue == rawMaxRevenue) maxRevenue += niceRevenueInterval;

    double niceServicesInterval = calculateNiceInterval(
      maxServices == 0 ? 10 : maxServices,
      4,
    );
    maxServices = maxServices == 0
        ? 10
        : (maxServices / niceServicesInterval).ceil() * niceServicesInterval;
    if (maxServices == rawMaxServices) maxServices += niceServicesInterval;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top green thick border/banner  
          Container(height: 8.h, color: const Color(0xFF059669)),
          // Header
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48),
                Expanded(
                  child: Text(
                    'Units Revenue',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.style_16_700(color: AppColors.primary),
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
                          title: 'Units Revenue',
                          child: DashboardUnitsChart(data: widget.data, isFullScreen: true),
                        ),
                      );
                    },
                  )
                else
                  const SizedBox(width: 48),
              ],
            ),
          ),
          
          // Legends
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12.w,
            runSpacing: 8.h,
            children: List.generate(widget.data.length, (index) {
              String unitNo = widget.data[index].unitNo;
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
                    tappedIndex = null;
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
          
          // Chart Area
          SizedBox(
            height: widget.isFullScreen ? 350.w : 350.h,
            child: Padding(
              padding: EdgeInsets.only(
                left: 0,
                right: 0,
                top: 24.h,
                bottom: 24.h,
              ),
              child: Stack(
                children: [
                  // 1. Bottom Layer: Bar Chart (Revenue) with Left Y-Axis and X-Axis
                  BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxRevenue,
                      minY: 0,
                      barTouchData: BarTouchData(
                        enabled: false,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => Colors.transparent,
                          tooltipPadding: EdgeInsets.all(2.w),
                          tooltipMargin: 2.h,
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            if (rod.toY == 0) return null;
                            
                            // Get the unit color
                            String unitNo = visibleData[groupIndex].unitNo;
                            Color unitColor = _getColorForUnit(
                              unitNo,
                              widget.data.indexWhere((e) => e.unitNo == unitNo),
                            );

                            return BarTooltipItem(
                              '₹${NumberFormat.compact().format(rod.toY)}',
                              AppTextStyle.style_10_600(color: Colors.black87).copyWith(fontSize: 8.sp),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        // Bottom X-Axis
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value < 0 || value >= visibleData.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: EdgeInsets.only(
                                  top: 24.h,
                                ), // Space for rotation
                                child: Transform.rotate(
                                  angle: -45 * pi / 180,
                                  child: Container(
                                    width: 100.w,
                                    alignment: Alignment.center,
                                    child: Text(
                                      visibleData[value.toInt()].unitNo,
                                      style: AppTextStyle.style_10_400(
                                        color: AppColors.grey500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            reservedSize: 80.h,
                          ),
                        ),
                        // Left Y-Axis (Revenue)
                        leftTitles: AxisTitles(
                          axisNameWidget: Text(
                            'Revenue (₹)',
                            style: AppTextStyle.style_14_600(
                              color: Colors.blue[700],
                            ),
                          ),
                          axisNameSize: 30.w,
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 45.w,
                            interval: niceRevenueInterval,
                            getTitlesWidget: (value, meta) {
                              if (value == 0 && maxRevenue > 0) {
                                return const SizedBox.shrink(); // Optional, hide 0 if you want it very clean, but let's keep 0
                              }
                              return Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: Text(
                                  value == 0
                                      ? '₹0'
                                      : formatCompactCurrency.format(value),
                                  style: AppTextStyle.style_10_400(
                                    color: Colors.blue[700],
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              );
                            },
                          ),
                        ),
                        // Right Y-Axis Hidden on BarChart BUT reserved to match LineChart
                        rightTitles: AxisTitles(
                          axisNameWidget: const Text(''),
                          axisNameSize: 30.w,
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40.w,
                            getTitlesWidget: (value, meta) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          left: BorderSide(color: AppColors.grey400, width: 1),
                          bottom: BorderSide(
                            color: AppColors.grey400,
                            width: 1,
                          ),
                          right: BorderSide(color: AppColors.grey400, width: 1),
                          top: BorderSide.none,
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        horizontalInterval: niceRevenueInterval,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: AppColors.grey200,
                            strokeWidth: 1,
                            dashArray: [
                              4,
                              4,
                            ], // Bring back the clean dashed lines
                          );
                        },
                        drawVerticalLine: true,
                        verticalInterval: 1,
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: AppColors.grey200,
                            strokeWidth: 1,
                          );
                        },
                      ),

                      barGroups: visibleData.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.revenue.toDouble(),
                              color: _getColorForUnit(
                                entry.value.unitNo,
                                widget.data.indexWhere((e) => e.unitNo == entry.value.unitNo),
                              ).withAlpha(50),
                              width: 28.w,
                              borderSide: BorderSide(
                                color: _getColorForUnit(
                                  entry.value.unitNo,
                                  widget.data.indexWhere((e) => e.unitNo == entry.value.unitNo),
                                ),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4.r),
                                topRight: Radius.circular(4.r),
                              ),
                            ),
                          ],
                          showingTooltipIndicators: [
                            0
                          ],
                        );
                      }).toList(),
                    ),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                  ),

                  // 2. Top Layer: Line Chart (Services Count) with Right Y-Axis
                  IgnorePointer(
                    child: LineChart(
                    LineChartData(
                      minX: -0.5,
                      maxX: visibleData.length - 0.5,
                      minY: 0,
                      maxY: maxServices,
                      showingTooltipIndicators: List.generate(
                        visibleData.length,
                        (index) {
                          if (visibleData[index].servicesCount == 0) return const ShowingTooltipIndicators([]);
                          return ShowingTooltipIndicators([
                            LineBarSpot(
                              LineChartBarData(spots: [FlSpot(index.toDouble(), visibleData[index].servicesCount.toDouble())]),
                              0,
                              FlSpot(index.toDouble(), visibleData[index].servicesCount.toDouble()),
                            ),
                          ]);
                        },
                      ),
                      lineTouchData: LineTouchData(
                        enabled: false,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => Colors.transparent,
                          tooltipPadding: EdgeInsets.all(2.w),
                          tooltipMargin: 4.h,
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipItems: (spotsList) {
                            return spotsList.map((spot) {
                              if (spot.y == 0) return null;
                              return LineTooltipItem(
                                spot.y.toInt().toString(),
                                AppTextStyle.style_10_600(color: Colors.black87).copyWith(fontSize: 8.sp),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        // Bottom X-Axis Hidden on LineChart BUT reserved to match BarChart
                        // Bottom X-Axis matches BarChart
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 80.h,
                            getTitlesWidget: (value, meta) => const SizedBox.shrink(),
                          ),
                        ),
                        // Left Y-Axis matches BarChart
                        leftTitles: AxisTitles(
                          axisNameWidget: const Text(''),
                          axisNameSize: 30.w,
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 45.w,
                            getTitlesWidget: (value, meta) => const SizedBox.shrink(),
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        // Right Y-Axis (Services Count)
                        rightTitles: AxisTitles(
                          axisNameWidget: Text(
                            'Services Count',
                            style: AppTextStyle.style_14_600(
                              color: const Color(0xFF059669),
                            ),
                          ),
                          axisNameSize: 30.w,
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40.w,
                            interval: niceServicesInterval,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Text(
                                  value.toInt().toString(),
                                  style: AppTextStyle.style_10_400(
                                    color: const Color(0xFF059669),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ), // Close FlTitlesData
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(
                          left: BorderSide(color: Colors.transparent, width: 1),
                          bottom: BorderSide(
                            color: Colors.transparent,
                            width: 1,
                          ),
                          right: BorderSide(
                            color: Colors.transparent,
                            width: 1,
                          ),
                          top: BorderSide.none,
                        ),
                      ),
                      gridData: const FlGridData(
                        show: false,
                      ), // Grid already drawn by BarChart
                      lineBarsData: [
                        LineChartBarData(
                          spots: visibleData.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              entry.value.servicesCount.toDouble(),
                            );
                          }).toList(),
                          isCurved: false, // Straight lines in mockup
                          color: const Color(0xFF059669),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 3.r,
                                color: const Color(0xFF059669),
                                strokeWidth: 0,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                  ),
                  ),

                  // 3. Top Layer: Transparent Bar Chart for Touch & Sticky Tooltips
                  BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxRevenue,
                      minY: 0,
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 80.h,
                            getTitlesWidget: (value, meta) => const SizedBox.shrink(),
                          ),
                        ),
                        leftTitles: AxisTitles(
                          axisNameWidget: const Text(''),
                          axisNameSize: 30.w,
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 45.w,
                            getTitlesWidget: (value, meta) => const SizedBox.shrink(),
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          axisNameWidget: const Text(''),
                          axisNameSize: 30.w,
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40.w,
                            getTitlesWidget: (value, meta) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      barTouchData: BarTouchData(
                        enabled: true,
                        handleBuiltInTouches: false,
                        touchCallback: (FlTouchEvent event, barTouchResponse) {
                          if (barTouchResponse != null && barTouchResponse.spot != null) {
                            final newIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                            if (tappedIndex != newIndex) {
                              setState(() {
                                tappedIndex = newIndex;
                              });
                            }
                          } else {
                            final eventType = event.runtimeType.toString();
                            if (eventType == 'FlTapDownEvent' || eventType == 'FlPanDownEvent') {
                              if (tappedIndex != null) {
                                setState(() {
                                  tappedIndex = null;
                                });
                              }
                            }
                          }
                        },
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => const Color(0xFF1F2937),
                          tooltipPadding: EdgeInsets.all(8.w),
                          tooltipMargin: 8.h, // Anchored to top of the bar
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${visibleData[groupIndex].unitNo}\n',
                              AppTextStyle.style_12_600(color: Colors.white),
                              textAlign: TextAlign.left,
                              children: [
                                TextSpan(
                                  text: '🟩 Services: ${visibleData[groupIndex].servicesCount}\n',
                                  style: AppTextStyle.style_10_400(color: Colors.white),
                                ),
                                TextSpan(
                                  text: '🟨 Revenue: ₹${visibleData[groupIndex].revenue}',
                                  style: AppTextStyle.style_10_400(color: Colors.white),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      barGroups: widget.data.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          showingTooltipIndicators: tappedIndex == entry.key ? [0] : [],
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.revenue.toDouble(),
                              color: Colors.transparent, // Completely invisible
                              width: 32.w,
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    duration: Duration.zero,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
