import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/data/models/revenue_report/dashboard_data_model.dart';
import 'chart_full_screen_viewer.dart';

class DashboardTopUnitsRadialChart extends StatefulWidget {
  final List<UnitData> data;
  final bool isFullScreen;

  const DashboardTopUnitsRadialChart({super.key, required this.data, this.isFullScreen = false});

  @override
  State<DashboardTopUnitsRadialChart> createState() => _DashboardTopUnitsRadialChartState();
}

class _DashboardTopUnitsRadialChartState extends State<DashboardTopUnitsRadialChart> {
  Set<String> hiddenItems = {};

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox.shrink();

    // Sort descending by revenue
    final sortedData = List<UnitData>.from(widget.data)
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    // Calculate total for percentages
    final top3 = sortedData.take(3).toList();
    
    // Calculate total revenue of top 3 for percentage
    final totalRevenue = top3.fold(0.0, (sum, item) => sum + item.revenue);

    final colors = [
      const Color(0xFFFF5722), // Orange
      const Color(0xFF2196F3), // Blue
      const Color(0xFFFFC107), // Yellow
    ];

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
                  'Top 3 Unit Wise Revenue Graph',
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
                        title: 'Top 3 Unit Wise Revenue Graph',
                        child: DashboardTopUnitsRadialChart(data: widget.data, isFullScreen: true),
                      ),
                    );
                  },
                )
              else
                const SizedBox(width: 24),
            ],
          ),
          SizedBox(height: 30.h),
          SizedBox(
            height: 180.w,
            width: 180.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Center Text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Top 3',
                      style: AppTextStyle.style_12_400(color: AppColors.grey500),
                    ),
                    Text(
                      'Units',
                      style: AppTextStyle.style_16_600(color: AppColors.grey800),
                    ),
                  ],
                ),
                // Concentric Rings
                ...top3.where((e) => !hiddenItems.contains(e.unitNo)).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  // Keep original color index to match legend
                  final originalIndex = top3.indexOf(item);
                  
                  // Calculate size decreasing towards center based on current visible index
                  final size = 180.w - (index * 40.w); 
                  final percent = totalRevenue > 0 ? (item.revenue / totalRevenue) : 0.0;
                  
                  return SizedBox(
                    width: size,
                    height: size,
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: percent),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (context, double value, child) {
                        return CircularProgressIndicator(
                          value: value,
                          strokeWidth: 12.w,
                          color: colors[originalIndex % colors.length],
                          backgroundColor: AppColors.grey100,
                          strokeCap: StrokeCap.round,
                        );
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          SizedBox(height: 30.h),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(top3.length, (index) {
              final item = top3[index];
              final isHidden = hiddenItems.contains(item.unitNo);
              final percent = totalRevenue > 0 ? (item.revenue / totalRevenue) : 0.0;
              final percentStr = (percent * 100).toStringAsFixed(1);
              
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (hiddenItems.contains(item.unitNo)) {
                        hiddenItems.remove(item.unitNo);
                      } else {
                        hiddenItems.add(item.unitNo);
                      }
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Opacity(
                    opacity: isHidden ? 0.4 : 1.0,
                    child: Column(
                      children: [
                        Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: BoxDecoration(
                            color: isHidden ? AppColors.grey400 : colors[index % colors.length],
                            shape: BoxShape.circle,
                            boxShadow: isHidden ? null : [
                              BoxShadow(
                                color: colors[index % colors.length].withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '${item.unitNo}',
                          style: AppTextStyle.style_12_600(color: isHidden ? AppColors.grey500 : AppColors.grey800).copyWith(
                            decoration: isHidden ? TextDecoration.lineThrough : null,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '₹${item.revenue}',
                          style: AppTextStyle.style_10_600(color: isHidden ? AppColors.grey500 : AppColors.primary),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 2.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: isHidden ? AppColors.grey300 : colors[index % colors.length].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            '$percentStr%',
                            style: AppTextStyle.style_10_600(color: isHidden ? AppColors.grey600 : colors[index % colors.length]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    ),
        ],
      ),
    );
  }
}
