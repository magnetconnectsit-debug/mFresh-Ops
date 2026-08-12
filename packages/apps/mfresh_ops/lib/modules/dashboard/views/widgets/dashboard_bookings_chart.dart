import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/modules/dashboard/models/dashboard_data_model.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/dashboard/controllers/dashboard_controller.dart';
import 'chart_full_screen_viewer.dart';

class DashboardBookingsChart extends StatefulWidget {
  final List<MonthCountData> bookingsData;
  final List<MonthCountData> serviceBookingsData;
  final bool isFullScreen;

  const DashboardBookingsChart({
    super.key,
    required this.bookingsData,
    required this.serviceBookingsData,
    this.isFullScreen = false,
  });

  @override
  State<DashboardBookingsChart> createState() => _DashboardBookingsChartState();
}

class _DashboardBookingsChartState extends State<DashboardBookingsChart> {
  int? touchedSpotIndex;
  bool showBookings = true;
  bool showServiceBookings = true;
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
  void didUpdateWidget(DashboardBookingsChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookingsData != widget.bookingsData ||
        oldWidget.serviceBookingsData != widget.serviceBookingsData) {
      touchedSpotIndex = null;
    }
  }

  String _formatDate(String dateStr) {
    try {
      if (dateStr.length == 7) {
        final parsed = DateFormat('yyyy-MM').parse(dateStr);
        return DateFormat("MMM ''yy").format(parsed);
      } else {
        final date = DateTime.parse(dateStr);
        return DateFormat("MMM ''yy").format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bookingsData.isEmpty && widget.serviceBookingsData.isEmpty) {
      return const SizedBox.shrink();
    }

    double maxCount = 0;
    double totalBookings = 0;
    double totalServices = 0;

    List<FlSpot> bookingsSpots = [];
    List<FlSpot> serviceSpots = [];

    // Bookings Data
    for (int i = 0; i < widget.bookingsData.length; i++) {
      double val = widget.bookingsData[i].count.toDouble();
      if (showBookings) {
        if (val > maxCount) maxCount = val;
        totalBookings += val;
      }
      bookingsSpots.add(FlSpot(i.toDouble(), val));
    }

    // Service Bookings Data
    for (int i = 0; i < widget.serviceBookingsData.length; i++) {
      double val = widget.serviceBookingsData[i].count.toDouble();
      if (showServiceBookings) {
        if (val > maxCount) maxCount = val;
        totalServices += val;
      }
      serviceSpots.add(FlSpot(i.toDouble(), val));
    }

    double avgBookings = widget.bookingsData.isNotEmpty ? totalBookings / widget.bookingsData.length : 0;
    double avgServices = widget.serviceBookingsData.isNotEmpty ? totalServices / widget.serviceBookingsData.length : 0;

    if (maxCount == 0) maxCount = 100;
    double yInterval = maxCount / 5;
    if (yInterval == 0) yInterval = 1;
    double maxY = maxCount + (maxCount * 0.2);
    
    // Fallback data length for X-axis
    int dataLength = widget.bookingsData.isNotEmpty ? widget.bookingsData.length : widget.serviceBookingsData.length;

    final bookingsBar = LineChartBarData(
      show: showBookings,
      spots: bookingsSpots,
      isCurved: true,
      color: Colors.green,
      barWidth: 2,
      isStrokeCapRound: true,
      belowBarData: BarAreaData(
        show: true,
        color: Colors.green.withAlpha(30),
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

    final servicesBar = LineChartBarData(
      show: showServiceBookings,
      spots: serviceSpots,
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

    // Build Tooltip Indicators
    List<ShowingTooltipIndicators> tooltips = [];
    if (touchedSpotIndex != null) {
      List<LineBarSpot> spotsToShow = [];
      if (showBookings && touchedSpotIndex! < bookingsSpots.length) {
        spotsToShow.add(LineBarSpot(bookingsBar, 0, bookingsSpots[touchedSpotIndex!]));
      }
      if (showServiceBookings && touchedSpotIndex! < serviceSpots.length) {
        spotsToShow.add(LineBarSpot(servicesBar, 1, serviceSpots[touchedSpotIndex!]));
      }
      if (spotsToShow.isNotEmpty) {
        tooltips.add(ShowingTooltipIndicators(spotsToShow));
      }
    }

    // Build extra lines for averages
    List<HorizontalLine> extraLines = [];
    if (showBookings) {
      extraLines.add(
        HorizontalLine(
          y: avgBookings,
          color: Colors.green,
          strokeWidth: 1.5,
          dashArray: [4, 4],
        ),
      );
    }
    if (showServiceBookings) {
      extraLines.add(
        HorizontalLine(
          y: avgServices,
          color: Colors.blue,
          strokeWidth: 1.5,
          dashArray: [4, 4],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16.w),
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
                child: Text(
                  'All Units Bookings & Service Count By Month',
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
                        title: 'All Units Bookings',
                        child: DashboardBookingsChart(
                          bookingsData: widget.bookingsData,
                          serviceBookingsData: widget.serviceBookingsData,
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
          SizedBox(height: 12.h),

          if (showBookings || showServiceBookings)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showBookings)
                  Text(
                    'Avg Bookings: ${NumberFormat('#,##,###').format(avgBookings)}',
                    style: AppTextStyle.style_12_700(color: Colors.green),
                  ),
                if (showBookings && showServiceBookings) SizedBox(width: 16.w),
                if (showServiceBookings)
                  Text(
                    'Avg Services: ${NumberFormat('#,##,###').format(avgServices)}',
                    style: AppTextStyle.style_12_700(color: Colors.blue),
                  ),
              ],
            ),
          if (showBookings || showServiceBookings) SizedBox(height: 12.h),
          
          // Legends
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend('Bookings', Colors.green, showBookings, () {
                setState(() {
                  showBookings = !showBookings;
                  touchedSpotIndex = null;
                });
              }),
              SizedBox(width: 16.w),
              _buildLegend('Service Bookings', Colors.blue, showServiceBookings, () {
                setState(() {
                  showServiceBookings = !showServiceBookings;
                  touchedSpotIndex = null;
                });
              }),
            ],
          ),
          SizedBox(height: 24.h),
          
          // Chart
          SizedBox(
            height: 300.h,
            child: LineChart(
              LineChartData(
                minX: -0.2,
                maxX: dataLength - 1 + 0.2,
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
                      reservedSize: 45.w,
                      interval: yInterval,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: Text(
                            NumberFormat.compact().format(value),
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
                      reservedSize: 30.h,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= dataLength || value != index.toDouble()) {
                          return const SizedBox.shrink();
                        }
                        
                        String monthStr = "";
                        if (widget.bookingsData.isNotEmpty && index < widget.bookingsData.length) {
                          monthStr = widget.bookingsData[index].month;
                        } else if (widget.serviceBookingsData.isNotEmpty && index < widget.serviceBookingsData.length) {
                          monthStr = widget.serviceBookingsData[index].month;
                        }
                        
                        return Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            _formatDate(monthStr),
                            style: AppTextStyle.style_10_400(color: AppColors.grey500),
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
                  horizontalLines: extraLines,
                ),
                showingTooltipIndicators: tooltips,
                lineTouchData: LineTouchData(
                  enabled: true,
                  handleBuiltInTouches: false,
                  touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                    if (response != null && response.lineBarSpots != null && response.lineBarSpots!.isNotEmpty) {
                      setState(() {
                        touchedSpotIndex = response.lineBarSpots![0].spotIndex;
                      });
                    } else {
                      final eventType = event.runtimeType.toString();
                      if (eventType == 'FlTapDownEvent' || eventType == 'FlPanDownEvent') {
                        setState(() {
                          touchedSpotIndex = null;
                        });
                      }
                    }
                  },
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF1F2937),
                    tooltipPadding: EdgeInsets.all(8.w),
                    tooltipMargin: 8.h,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (touchedSpots) {
                      // Custom multi-line tooltip
                      if (touchedSpots.isEmpty) return [];
                      
                      int index = touchedSpots.first.spotIndex;
                      String monthStr = "";
                      if (widget.bookingsData.isNotEmpty && index < widget.bookingsData.length) {
                        monthStr = widget.bookingsData[index].month;
                      } else if (widget.serviceBookingsData.isNotEmpty && index < widget.serviceBookingsData.length) {
                        monthStr = widget.serviceBookingsData[index].month;
                      }

                      List<LineTooltipItem> items = [];
                      for (int i = 0; i < touchedSpots.length; i++) {
                        final spot = touchedSpots[i];
                        
                        // First item holds the header
                        if (i == 0) {
                          items.add(LineTooltipItem(
                            '${_formatDate(monthStr)}\n',
                            AppTextStyle.style_12_700(color: Colors.white),
                            children: [
                              TextSpan(
                                text: '${spot.barIndex == 0 ? 'Bookings' : 'Services'}: ${NumberFormat('#,##,###').format(spot.y)}',
                                style: AppTextStyle.style_12_400(color: spot.barIndex == 0 ? Colors.greenAccent : Colors.lightBlueAccent),
                              ),
                            ],
                          ));
                        } else {
                          items.add(LineTooltipItem(
                            '${spot.barIndex == 0 ? 'Bookings' : 'Services'}: ${NumberFormat('#,##,###').format(spot.y)}',
                            AppTextStyle.style_12_400(color: spot.barIndex == 0 ? Colors.greenAccent : Colors.lightBlueAccent),
                          ));
                        }
                      }
                      return items;
                    },
                  ),
                ),
                lineBarsData: [bookingsBar, servicesBar],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String title, Color color, bool isVisible, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: isVisible ? color.withAlpha(30) : Colors.grey.withAlpha(50),
                border: Border.all(color: isVisible ? color : Colors.grey, width: 2),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: AppTextStyle.style_12_400(
                color: isVisible ? Colors.black87 : Colors.grey,
              ).copyWith(
                decoration: isVisible ? null : TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
