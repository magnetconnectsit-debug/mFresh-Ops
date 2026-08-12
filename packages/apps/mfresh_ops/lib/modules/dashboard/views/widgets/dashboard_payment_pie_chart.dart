import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/modules/dashboard/models/dashboard_data_model.dart';
import 'chart_full_screen_viewer.dart';

class DashboardPaymentPieChart extends StatefulWidget {
  final DashboardDataModel data;
  final bool isFullScreen;

  const DashboardPaymentPieChart({super.key, required this.data, this.isFullScreen = false});

  @override
  State<DashboardPaymentPieChart> createState() => _DashboardPaymentPieChartState();
}

class _DashboardPaymentPieChartState extends State<DashboardPaymentPieChart> {
  int touchedIndex = -1;
  Set<String> hiddenItems = {};

  @override
  Widget build(BuildContext context) {
    // Map payment modes to data
    final items = [
      _PaymentItem('KIOSK: Cash', widget.data.kioskCash, const Color(0xFF059669)),
      _PaymentItem('KIOSK: PG', widget.data.kioskPg, const Color(0xFF3498DB)),
      _PaymentItem('Customer: PG', widget.data.customerPg, const Color(0xFFF39C12)),
      _PaymentItem('External QR', widget.data.externalQr, const Color(0xFF9B59B6)),
    ].where((e) => e.value > 0).toList(); // Only show > 0

    // If all are 0, return empty
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = items.fold(0.0, (sum, item) => sum + item.value);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF1976D2), // Blue top border like mockup
            width: 4.h,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                  'Payment Mode Percentage Chart',
                  style: AppTextStyle.style_14_600(color: const Color(0xFF1976D2)),
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
                        title: 'Payment Mode',
                        child: DashboardPaymentPieChart(data: widget.data, isFullScreen: true),
                      ),
                    );
                  },
                )
              else
                const SizedBox(width: 24),
            ],
          ),
          SizedBox(height: 16.h),
          Column(
            children: [
              // Chart
              SizedBox(
                height: 280.w, // Much larger container height
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: [
                      PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  touchedIndex = -1;
                                  return;
                                }
                                touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 2, // Standard separation
                          centerSpaceRadius: 65.w, // Thicker doughnut for better look
                          sections: items.isEmpty
                              ? [PieChartSectionData(value: 1, color: AppColors.grey200, radius: 55.w, title: '')]
                              : items.where((e) => !hiddenItems.contains(e.title)).toList().asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final item = entry.value;
                                  final isTouched = index == touchedIndex;
                                  final radius = isTouched ? 65.w : 55.w;
                                  // USE ABSOLUTE TOTAL so percentages don't change!
                                  final percent = total > 0 ? (item.value / total * 100) : 0;
                                  
                                  // Enforce a minimum slice size so it doesn't get swallowed by sectionSpace
                                  final minValue = total * 0.015; // 1.5% min visual size
                                  final renderValue = (item.value > 0 && item.value < minValue) ? minValue : item.value.toDouble();
                                  
                                  return PieChartSectionData(
                                    color: item.color,
                                    value: renderValue,
                                    title: '',
                                    radius: radius,
                                    badgeWidget: (percent < 2.0) // Hide badges for tiny slices
                                        ? null
                                        : Container(
                                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(4.r),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              '${percent.toStringAsFixed(0)}%',
                                              style: AppTextStyle.style_10_600(color: item.color),
                                            ),
                                          ),
                                    badgePositionPercentageOffset: 0.5, // Center of the slice
                                  );
                                }).toList(),
                        ),
                        swapAnimationDuration: const Duration(milliseconds: 800),
                        swapAnimationCurve: Curves.easeInOut,
                      ),
                      // Tooltip in Center Hole
                      if (touchedIndex != -1)
                        Builder(
                          builder: (context) {
                            final visibleItems = items.where((e) => !hiddenItems.contains(e.title)).toList();
                            if (touchedIndex < visibleItems.length && visibleItems.isNotEmpty) {
                              final touchedItem = visibleItems[touchedIndex];
                              return Align(
                                alignment: Alignment.center,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        touchedItem.title,
                                        style: AppTextStyle.style_10_600(color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        '${(touchedItem.value / total * 100).toStringAsFixed(1)}% (${touchedItem.value.toInt()})',
                                        style: AppTextStyle.style_10_600(color: touchedItem.color),
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
              SizedBox(height: 16.h),
              // Legend
              Column(
                children: [
                  for (int rowIndex = 0; rowIndex < items.length; rowIndex += 2)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 10,
                            child: _buildLegendItem(
                              items[rowIndex],
                              total,
                              hiddenItems.contains(items[rowIndex].title),
                            ),
                          ),
                          const Spacer(flex: 7),
                          if (rowIndex + 1 < items.length)
                            Expanded(
                              flex: 10,
                              child: _buildLegendItem(
                                items[rowIndex + 1],
                                total,
                                hiddenItems.contains(items[rowIndex + 1].title),
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
    );
  }

  Widget _buildLegendItem(_PaymentItem item, double total, bool isHidden) {
    final percent = total > 0 ? (item.value / total * 100) : 0;
    
    final dot = Container(
      width: 10.w,
      height: 10.w,
      margin: EdgeInsets.only(top: 2.h),
      decoration: BoxDecoration(
        color: isHidden ? AppColors.grey400 : item.color,
        shape: BoxShape.circle,
        boxShadow: isHidden
            ? null
            : [
                BoxShadow(
                  color: item.color.withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
    );
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (hiddenItems.contains(item.title)) {
            hiddenItems.remove(item.title);
          } else {
            hiddenItems.add(item.title);
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
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                '${item.title}: ${percent.toStringAsFixed(1)}%',
                style: AppTextStyle.style_10_400(color: isHidden ? AppColors.grey500 : AppColors.grey700).copyWith(
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

class _PaymentItem {
  final String title;
  final num value;
  final Color color;

  _PaymentItem(this.title, this.value, this.color);
}
