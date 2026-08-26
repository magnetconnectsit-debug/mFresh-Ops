import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/data/models/revenue_report/dashboard_data_model.dart';
import 'chart_full_screen_viewer.dart';

class DashboardServicePieChart extends StatefulWidget {
  final List<ServiceData> data;
  final bool isRevenue;

  final bool isFullScreen;

  const DashboardServicePieChart({
    super.key,
    required this.data,
    required this.isRevenue,
    this.isFullScreen = false,
  });

  @override
  State<DashboardServicePieChart> createState() =>
      _DashboardServicePieChartState();
}

class _DashboardServicePieChartState extends State<DashboardServicePieChart> {
  int touchedIndex = -1;
  Set<String> hiddenItems = {};

  final List<Color> _colors = const [
    Color(0xFF64B5F6), // Light Blue
    Color(0xFFE57373), // Red
    Color(0xFFFFD54F), // Yellow
    Color(0xFF81C784), // Light Green
    Color(0xFFBA68C8), // Purple
    Color(0xFFFF8A65), // Orange
    Color(0xFF4DB6AC), // Teal
    Color(0xFFF06292), // Pink
    Color(0xFF7986CB), // Indigo
    Color(0xFF4DD0E1), // Cyan
    Color(0xFFAED581), // Light Green 2
    Color(0xFFFFB74D), // Orange 2
    Color(0xFF9575CD), // Deep Purple
    Color(0xFF4FC3F7), // Light Blue 2
    Color(0xFF81D4FA),
    Color(0xFFF48FB1),
    Color(0xFFCE93D8),
    Color(0xFFBCAAA4),
    Color(0xFFEEEEEE),
    Color(0xFFB0BEC5),
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox.shrink();

    // Sort descending
    final sortedData = List<ServiceData>.from(widget.data)
      ..sort((a, b) {
        if (widget.isRevenue) {
          return b.totalRevenue.compareTo(a.totalRevenue);
        }
        return b.bookingCount.compareTo(a.bookingCount);
      });

    // If all are 0 or empty, return empty
    if (sortedData.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = sortedData.fold(0.0, (sum, item) {
      return sum + (widget.isRevenue ? item.totalRevenue : item.bookingCount);
    });

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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(height: 8.h, color: const Color(0xFF059669)),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 24),
              Expanded(
                child: Text(
                  widget.isRevenue
                      ? 'Service-wise Revenue Chart'
                      : 'Service-wise Booking Count Chart',
                  style: AppTextStyle.style_14_600(color: const Color(0xFFFF5722)),
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
                        title: widget.isRevenue ? 'Service-wise Revenue' : 'Service-wise Bookings',
                        child: DashboardServicePieChart(data: widget.data, isRevenue: widget.isRevenue, isFullScreen: true),
                      ),
                    );
                  },
                )
              else
                const SizedBox(width: 24),
            ],
          ),
          SizedBox(height: 30.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Chart
              SizedBox(
                height: 320.w, // Much larger container height
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: [
                      PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback:
                                (FlTouchEvent event, pieTouchResponse) {
                                  if (pieTouchResponse != null && pieTouchResponse.touchedSection != null) {
                                    final newIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                    if (touchedIndex != newIndex) {
                                      setState(() {
                                        touchedIndex = newIndex;
                                      });
                                    }
                                  } else {
                                    final eventType = event.runtimeType.toString();
                                    if (eventType == 'FlTapDownEvent' || eventType == 'FlPanDownEvent') {
                                      if (touchedIndex != -1) {
                                        setState(() {
                                          touchedIndex = -1;
                                        });
                                      }
                                    }
                                  }
                                },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 2,
                          centerSpaceRadius:
                              75.w, // Increased center hole for bigger chart
                          sections: sortedData.isEmpty
                              ? [
                                  PieChartSectionData(
                                    value: 1,
                                    color: AppColors.grey200,
                                    radius: 55.w,
                                    title: '',
                                  ),
                                ]
                              : sortedData
                                    .where(
                                      (e) =>
                                          !hiddenItems.contains(e.serviceName),
                                    )
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                      final index = entry.key;
                                      final item = entry.value;
                                      final originalIndex = sortedData.indexOf(
                                        item,
                                      );
                                      final isTouched = index == touchedIndex;
                                      final radius = isTouched
                                          ? 65.w
                                          : 55.w; // Increased section thickness
                                      final value = widget.isRevenue
                                          ? item.totalRevenue
                                          : item.bookingCount;
                                      final percent = total > 0
                                          ? (value / total * 100)
                                          : 0;

                                      // Enforce a minimum slice size so it doesn't get swallowed by sectionSpace
                                      final minValue =
                                          total * 0.015; // 1.5% min visual size
                                      final renderValue =
                                          (value > 0 && value < minValue)
                                          ? minValue
                                          : value.toDouble();

                                      return PieChartSectionData(
                                        color:
                                            _colors[originalIndex %
                                                _colors.length],
                                        value: renderValue,
                                        title: '',
                                        radius: radius,
                                        badgeWidget:
                                            (percent <
                                                3.0) // Hide badges for tiny slices
                                            ? const SizedBox.shrink()
                                            : Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 4.w,
                                                  vertical: 2.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        4.r,
                                                      ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 4,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Text(
                                                  '${percent.toStringAsFixed(1)}%',
                                                  style: AppTextStyle.style_8_600(
                                                    color:
                                                        _colors[originalIndex %
                                                            _colors.length],
                                                  ),
                                                ),
                                              ),
                                        badgePositionPercentageOffset:
                                            0.6, // Keep badges cleanly inside the thicker slices
                                      );
                                    })
                                    .toList(),
                        ),
                        swapAnimationDuration: const Duration(
                          milliseconds: 800,
                        ),
                        swapAnimationCurve: Curves.easeInOut,
                      ),
                      // Tooltip in Center Hole
                      if (touchedIndex != -1)
                        Builder(
                          builder: (context) {
                            final visibleData = sortedData
                                .where(
                                  (e) => !hiddenItems.contains(e.serviceName),
                                )
                                .toList();
                            if (touchedIndex < visibleData.length &&
                                visibleData.isNotEmpty) {
                              final touchedItem = visibleData[touchedIndex];
                              return Align(
                                alignment: Alignment.center,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        touchedItem.serviceName,
                                        style: AppTextStyle.style_10_600(
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        '${((widget.isRevenue ? touchedItem.totalRevenue : touchedItem.bookingCount) / total * 100).toStringAsFixed(1)}% (${widget.isRevenue ? '₹' : ''}${widget.isRevenue ? touchedItem.totalRevenue.toInt() : touchedItem.bookingCount})',
                                        style: AppTextStyle.style_10_600(
                                          color:
                                              _colors[sortedData.indexOf(
                                                    touchedItem,
                                                  ) %
                                                  _colors.length],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              // Legend
              Column(
                children: [
                  for (
                    int rowIndex = 0;
                    rowIndex < sortedData.length;
                    rowIndex += 2
                  )
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First item
                          Expanded(
                            flex: 10,
                            child: _buildLegendItem(
                              rowIndex,
                              sortedData[rowIndex],
                              total,
                              hiddenItems.contains(
                                sortedData[rowIndex].serviceName,
                              ),
                            ),
                          ),
                          const Spacer(flex: 7),
                          // Second item
                          if (rowIndex + 1 < sortedData.length)
                            Expanded(
                              flex: 10,
                              child: _buildLegendItem(
                                rowIndex + 1,
                                sortedData[rowIndex + 1],
                                total,
                                hiddenItems.contains(
                                  sortedData[rowIndex + 1].serviceName,
                                ),
                              ),
                            )
                          else
                            const Expanded(flex: 10, child: SizedBox.shrink()),
                        ],
                      ),
                    ),
                ],
              ),
              ],
            ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    int i,
    ServiceData item,
    double total,
    bool isHidden,
  ) {
    final value = widget.isRevenue ? item.totalRevenue : item.bookingCount;
    final percent = total > 0 ? (value / total * 100) : 0;
    final valStr = widget.isRevenue ? '₹$value' : '$value';

    final dot = Container(
      width: 10.w,
      height: 10.w,
      margin: EdgeInsets.only(top: 2.h),
      decoration: BoxDecoration(
        color: isHidden ? AppColors.grey400 : _colors[i % _colors.length],
        shape: BoxShape.circle,
        boxShadow: isHidden
            ? null
            : [
                BoxShadow(
                  color: _colors[i % _colors.length].withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          if (hiddenItems.contains(item.serviceName)) {
            hiddenItems.remove(item.serviceName);
          } else {
            hiddenItems.add(item.serviceName);
          }
          touchedIndex = -1; // reset touch when filtering
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: isHidden ? 0.4 : 1.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            dot,
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                '${item.serviceName}\n${percent.toStringAsFixed(1)}% ($valStr)',
                style:
                    AppTextStyle.style_10_400(
                      color: isHidden ? AppColors.grey500 : AppColors.grey700,
                    ).copyWith(
                      decoration: isHidden ? TextDecoration.lineThrough : null,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
