import 'package:core/core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mfresh_ops/modules/dashboard/models/dashboard_data_model.dart';
import 'chart_full_screen_viewer.dart';

class DashboardDailyCountChart extends StatefulWidget {
  final String title;
  final List<DailyCountData> data;
  final Color color;
  final bool isFullScreen;

  const DashboardDailyCountChart({
    super.key,
    required this.title,
    required this.data,
    required this.color,
    this.isFullScreen = false,
  });

  @override
  State<DashboardDailyCountChart> createState() => _DashboardDailyCountChartState();
}

class _DashboardDailyCountChartState extends State<DashboardDailyCountChart> {
  int? touchedSpotIndex;

  @override
  void didUpdateWidget(DashboardDailyCountChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      touchedSpotIndex = null;
    }
  }

  String _formatDate(String value) {
    try {
      return DateFormat('dd-MMM').format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox.shrink();

    final values = widget.data.map((item) => item.count.toDouble()).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final safeMax = maxValue == 0 ? 1.0 : maxValue;
    final interval = safeMax / 5;
    final average = values.reduce((a, b) => a + b) / values.length;
    final spots = List.generate(
      values.length,
      (index) => FlSpot(index.toDouble(), values[index]),
    );
    final line = LineChartBarData(
      spots: spots,
      isCurved: true,
      color: widget.color,
      barWidth: 2,
      isStrokeCapRound: true,
      belowBarData: BarAreaData(show: true, color: widget.color.withAlpha(48)),
      dotData: FlDotData(
        show: true,
        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
          radius: 4,
          color: widget.color,
          strokeWidth: 0,
        ),
      ),
    );

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border(top: BorderSide(color: widget.color, width: 8.h)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4.r, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 24),
              Expanded(
                child: Text(widget.title, style: AppTextStyle.style_14_700(color: AppColors.primary), textAlign: TextAlign.center),
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
                        child: DashboardDailyCountChart(
                          title: widget.title,
                          data: widget.data,
                          color: widget.color,
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
          SizedBox(height: 20.h),
          SizedBox(
            height: 250.h,
            child: LineChart(
              LineChartData(
                minX: -0.2,
                maxX: widget.data.length - 1 + 0.2,
                minY: 0,
                maxY: safeMax * 1.2,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFF3F4F6)),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40.w,
                      interval: interval,
                      getTitlesWidget: (value, _) => Text(
                        NumberFormat.compact().format(value),
                        style: AppTextStyle.style_10_400(color: AppColors.grey500),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50.h,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (value != index || index < 0 || index >= widget.data.length) return const SizedBox.shrink();
                        return SideTitleWidget(
                          meta: meta,
                          angle: -0.8,
                          child: Text(
                            _formatDate(widget.data[index].date),
                            style: AppTextStyle.style_10_400(color: AppColors.grey500),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true, border: Border.all(color: const Color(0xFFE5E7EB))),
                extraLinesData: ExtraLinesData(horizontalLines: [
                  HorizontalLine(y: average, color: widget.color, strokeWidth: 1.5, dashArray: [4, 4]),
                ]),
                showingTooltipIndicators: touchedSpotIndex == null
                    ? []
                    : [ShowingTooltipIndicators([LineBarSpot(line, 0, spots[touchedSpotIndex!])])],
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: false,
                  touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                    if (response != null && response.lineBarSpots != null && response.lineBarSpots!.isNotEmpty) {
                      setState(() {
                        touchedSpotIndex = response.lineBarSpots!.first.spotIndex;
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
                    getTooltipItems: (spots) => spots.map((spot) => LineTooltipItem(
                      '${_formatDate(widget.data[spot.spotIndex].date)}\n${NumberFormat('#,##,###').format(spot.y)}',
                      AppTextStyle.style_12_700(color: Colors.white),
                    )).toList(),
                  ),
                ),
                lineBarsData: [line],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
