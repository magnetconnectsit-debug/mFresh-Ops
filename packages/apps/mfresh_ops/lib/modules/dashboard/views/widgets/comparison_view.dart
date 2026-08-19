import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:intl/intl.dart';
import 'package:mfresh_ops/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:mfresh_ops/data/models/revenue_report/comparison_model.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:mfresh_ops/modules/dashboard/views/widgets/chart_full_screen_viewer.dart';
import 'package:mfresh_ops/modules/dashboard/views/widgets/dashboard_metrics_card.dart';

const _kSeriesColors = [
  Color(0xFF3B82F6), // blue   — Data A
  Color(0xFFEF4444), // red    — Data B
  Color(0xFF22C55E), // green  — Data C
];
const _kSeriesLabels = ['Data A', 'Data B', 'Data C'];

// ─────────────────────────────────────────────────────────────────────────────
class ComparisonView extends StatefulWidget {
  const ComparisonView({super.key});

  @override
  State<ComparisonView> createState() => _ComparisonViewState();
}

class _ComparisonViewState extends State<ComparisonView> {
  final ScrollController _scrollController = ScrollController();
  DashboardController get controller => Get.find<DashboardController>();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onCompareClicked() async {
    await controller.fetchComparisonData();
    // Scroll to bottom after data is fetched to show the chart
    if (_scrollController.hasClients) {
      // Add a small delay to allow the UI to build the new chart
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.rxClearTooltipsTrigger.value++,
      behavior: HitTestBehavior.translucent,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Metrics Card ──────────────────────────────────────────────
            Obx(() {
              final data = controller.rxDashboardData.value;
              if (data == null) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: DashboardMetricsCard(data: data),
              );
            }),

            // ── Input card ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(8.r),
                      ),
                      border: const Border(
                        bottom: BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    child: Text(
                      'Revenue Comparison',
                      style: AppTextStyle.style_14_600(color: AppColors.black),
                    ),
                  ),
                  // Body
                  Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...List.generate(
                          DashboardController.maxComparisonSlots,
                          (i) => _SlotRow(index: i),
                        ),
                        SizedBox(height: 8.h),
                        // Buttons
                        Obx(() {
                          final loading =
                              controller.rxComparisonIsLoading.value;
                          return Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _primaryBtn(
                                  label: 'Compare',
                                  loading: loading,
                                  onTap: loading ? null : _onCompareClicked,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                flex: 1,
                                child: _outlineBtn(
                                  label: 'Reset',
                                  onTap: loading ? null : _reset,
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Results ─────────────────────────────────────────────────
            Obx(() {
              final result = controller.rxComparisonResult.value;
              if (result == null || result.comparisons.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  SizedBox(height: 14.h),
                  _ChartCard(comparisons: result.comparisons),
                  SizedBox(height: 14.h),
                  _SummaryCards(comparisons: result.comparisons),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void _reset() {
    for (final slot in controller.comparisonSlots) {
      slot.clear();
    }
    controller.rxComparisonResult.value = null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────
Widget _card({required Widget child}) => Container(
  width: double.infinity,
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8.r),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.07),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  padding: EdgeInsets.all(14.w),
  child: child,
);

Widget _primaryBtn({
  required String label,
  required VoidCallback? onTap,
  bool loading = false,
}) => GestureDetector(
  onTap: onTap,
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 150),
    height: 30.h,
    decoration: BoxDecoration(
      color: onTap == null
          ? AppColors.primary.withValues(alpha: 0.5)
          : AppColors.primary,
      borderRadius: BorderRadius.circular(8.r),
    ),
    alignment: Alignment.center,
    child: loading
        ? SizedBox(
            width: 18.r,
            height: 18.r,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Text(label, style: AppTextStyle.style_13_600(color: Colors.white)),
  ),
);

Widget _outlineBtn({required String label, VoidCallback? onTap}) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyle.style_13_500(color: AppColors.grey500),
        ),
      ),
    );

// ─────────────────────────────────────────────────────────────────────────────
// _SlotRow — one Data A/B/C/D row (badge + From | To | Unit)
// ─────────────────────────────────────────────────────────────────────────────
class _SlotRow extends StatefulWidget {
  final int index;
  const _SlotRow({required this.index});

  @override
  State<_SlotRow> createState() => _SlotRowState();
}

class _SlotRowState extends State<_SlotRow> {
  DashboardController get _c => Get.find<DashboardController>();
  ComparisonSlot get slot => _c.comparisonSlots[widget.index];

  String _fmt(DateTime? d) {
    if (d == null) return 'dd-mm-yyyy';
    return DateFormat('dd-MM-yyyy').format(d);
  }

  Future<void> _pick(bool isFrom) async {
    final initial = (isFrom ? slot.fromDate : slot.toDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          slot.fromDate = picked;
        } else {
          slot.toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: slot,
      builder: (context, _) {
        final color = _kSeriesColors[widget.index];
        final label = _kSeriesLabels[widget.index];

        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Badge + Line ──
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: color.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 7.r, color: color),
                        SizedBox(width: 5.w),
                        Text(
                          label,
                          style: AppTextStyle.style_12_600(color: color),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Divider(
                      color: const Color(0xFFE5E7EB),
                      thickness: 1.h,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),

              // ── Three fields in a Card ──
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  children: [
                    _FieldRow(
                      label: 'From Date',
                      value: _fmt(slot.fromDate),
                      hasValue: slot.fromDate != null,
                      onTap: () => _pick(true),
                    ),
                    SizedBox(height: 4.h),
                    _FieldRow(
                      label: 'To Date',
                      value: _fmt(slot.toDate),
                      hasValue: slot.toDate != null,
                      onTap: () => _pick(false),
                    ),
                    SizedBox(height: 4.h),
                    Obx(() {
                      final units = _c.units;
                      return _UnitRow(
                        units: units.map((u) => u.unitName).toList(),
                        selected: slot.unitName,
                        onChanged: (v) => setState(() {
                          slot.unitName = v;
                          slot.unitId = v;
                        }),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final String value;
  final bool hasValue;
  final VoidCallback onTap;
  const _FieldRow({
    required this.label,
    required this.value,
    required this.hasValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            label,
            style: AppTextStyle.style_12_500(color: AppColors.grey500),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 24.h,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                value,
                style: AppTextStyle.style_12_400(
                  color: hasValue ? AppColors.black : const Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UnitRow extends StatelessWidget {
  final List<String> units;
  final String? selected;
  final ValueChanged<String> onChanged;
  const _UnitRow({
    required this.units,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            'Unit',
            style: AppTextStyle.style_12_500(color: AppColors.grey500),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: MultiSelectDropdownWidget<String>(
            isSingleSelect: true,
            hint: 'Select Unit',
            selectedValues: selected != null ? {selected!} : {},
            height: 24.h,
            items: units
                .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                .toList(),
            onChanged: (vals) {
              if (vals.isNotEmpty) {
                onChanged(vals.first);
              }
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ChartCard — legend + multi-series line chart
// ─────────────────────────────────────────────────────────────────────────────
class _ChartCard extends StatefulWidget {
  final List<ComparisonEntry> comparisons;
  final bool isFullScreen;
  const _ChartCard({required this.comparisons, this.isFullScreen = false});

  @override
  State<_ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<_ChartCard> {
  Set<int> hiddenSeries = {};
  DashboardController get controller => Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.rxClearTooltipsTrigger.value++,
      behavior: HitTestBehavior.translucent,
      child: _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 24),
                Expanded(
                  child: Text(
                    'Comparison Chart',
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
                          title: 'Comparison Chart',
                          child: _ChartCard(
                            comparisons: widget.comparisons,
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
            // Legend
            Center(
              child: Wrap(
                spacing: 12.w,
                runSpacing: 6.h,
                alignment: WrapAlignment.center,
                children: widget.comparisons.map((e) {
                  final idx = (e.comparison - 1).clamp(
                    0,
                    _kSeriesColors.length - 1,
                  );
                  final color = _kSeriesColors[idx];
                  final lbl = _kSeriesLabels[idx];
                  final isHidden = hiddenSeries.contains(idx);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isHidden) {
                          hiddenSeries.remove(idx);
                        } else {
                          hiddenSeries.add(idx);
                        }
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 4.h,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 32.w,
                            height: 12.h,
                            decoration: BoxDecoration(
                              color: isHidden
                                  ? Colors.grey[300]
                                  : color.withValues(alpha: 0.2),
                              border: Border.all(
                                color: isHidden ? Colors.grey : color,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '$lbl (${AppDateUtils.formatToDateDayMonth(e.fromDate)} to ${AppDateUtils.formatToDateDayMonth(e.toDate)})',
                            style:
                                AppTextStyle.style_12_400(
                                  color: isHidden
                                      ? Colors.grey
                                      : AppColors.grey800,
                                ).copyWith(
                                  decoration: isHidden
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 14.h),
            SizedBox(
              height: widget.isFullScreen ? 350.h : 210.h,
              child: _LineChart(
                comparisons: widget.comparisons,
                hiddenSeries: hiddenSeries,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineChart extends StatefulWidget {
  final List<ComparisonEntry> comparisons;
  final Set<int> hiddenSeries;
  const _LineChart({required this.comparisons, required this.hiddenSeries});

  @override
  State<_LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<_LineChart> {
  int? touchedSpotIndex;
  late final Worker _tooltipWorker;

  @override
  void initState() {
    super.initState();
    final ctrl = Get.find<DashboardController>();
    _tooltipWorker = ever(ctrl.rxClearTooltipsTrigger, (_) {
      if (mounted && touchedSpotIndex != null) {
        setState(() => touchedSpotIndex = null);
      }
    });
  }

  @override
  void dispose() {
    _tooltipWorker.dispose();
    super.dispose();
  }

  bool _isWeekend(String dateStr) {
    try {
      final d = DateFormat('yyyy-MM-dd').parse(dateStr);
      return d.weekday == DateTime.saturday || d.weekday == DateTime.sunday;
    } catch (_) {
      return false;
    }
  }

  List<LineChartBarData> _buildLines() {
    List<LineChartBarData> lines = [];
    for (int i = 0; i < widget.comparisons.length; i++) {
      final entry = widget.comparisons[i];
      final colorIdx = (entry.comparison - 1).clamp(
        0,
        _kSeriesColors.length - 1,
      );
      if (widget.hiddenSeries.contains(colorIdx)) continue;
      final color = _kSeriesColors[colorIdx];

      lines.add(
        LineChartBarData(
          spots: entry.data.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), e.value.revenue);
          }).toList(),
          isCurved: true,
          color: color,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: Colors.black,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: color.withValues(alpha: 0.15),
          ),
        ),
      );
    }
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.comparisons.isEmpty) return const SizedBox.shrink();

    double maxY = 0;
    int maxX = 0;
    List<String> dates = [];

    for (var c in widget.comparisons) {
      if (c.data.length > maxX) {
        maxX = c.data.length;
        dates = c.data.map((e) => e.date).toList();
      }
      for (var d in c.data) {
        if (d.revenue > maxY) maxY = d.revenue;
      }
    }

    if (maxY == 0) maxY = 100;
    maxY = maxY * 1.2;

    final fmt = NumberFormat.compact(locale: 'en_IN');

    // Build date label function
    String dayLabel(String date) {
      try {
        final d = DateFormat('yyyy-MM-dd').parse(date);
        return DateFormat('EEE').format(d); // Mon, Tue …
      } catch (_) {
        return date;
      }
    }

    final lines = _buildLines();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        minX: 0,
        maxX: (maxX - 1).toDouble().clamp(0, double.infinity),
        lineBarsData: lines,
        showingTooltipIndicators: () {
          List<ShowingTooltipIndicators> indicators = [];
          // Add non-touched spots first
          for (int xIndex = 0; xIndex < maxX; xIndex++) {
            if (xIndex == touchedSpotIndex) continue;
            for (int barIndex = 0; barIndex < lines.length; barIndex++) {
              if (xIndex < lines[barIndex].spots.length) {
                indicators.add(
                  ShowingTooltipIndicators([
                    LineBarSpot(
                      lines[barIndex],
                      barIndex,
                      lines[barIndex].spots[xIndex],
                    ),
                  ]),
                );
              }
            }
          }

          // Add touched spot last so it paints on top
          if (touchedSpotIndex != null) {
            final xIndex = touchedSpotIndex!;
            List<LineBarSpot> spotsForThisX = [];
            for (int barIndex = 0; barIndex < lines.length; barIndex++) {
              if (xIndex < lines[barIndex].spots.length) {
                spotsForThisX.add(
                  LineBarSpot(
                    lines[barIndex],
                    barIndex,
                    lines[barIndex].spots[xIndex],
                  ),
                );
              }
            }
            if (spotsForThisX.isNotEmpty) {
              indicators.add(ShowingTooltipIndicators(spotsForThisX));
            }
          }
          return indicators;
        }(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Color(0xFFF1F3F5), strokeWidth: 1),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
            left: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Text(
                'Day',
                style: AppTextStyle.style_9_400(color: AppColors.grey700),
              ),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= dates.length || value != i.toDouble()) {
                  return const SizedBox.shrink();
                }
                final dateStr = dates[i];
                final isWknd = _isWeekend(dateStr);
                return SideTitleWidget(
                  meta: meta,
                  space: 4.h,
                  child: Text(
                    dayLabel(dateStr),
                    style: TextStyle(
                      fontSize: 8,
                      color: isWknd ? Colors.red : const Color(0xFF4B5563),
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: const Text(
              'Revenue (₹)',
              style: TextStyle(fontSize: 10, color: Color(0xFF4B5563)),
            ),
            axisNameSize: 20,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, _) => Text(
                '₹${fmt.format(value)}',
                style: const TextStyle(fontSize: 8, color: Color(0xFF4B5563)),
              ),
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: false,
          touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
            if (response != null &&
                response.lineBarSpots != null &&
                response.lineBarSpots!.isNotEmpty) {
              final newIndex = response.lineBarSpots![0].spotIndex;
              if (touchedSpotIndex != newIndex) {
                setState(() {
                  touchedSpotIndex = newIndex;
                });
              }
            } else {
              final eventType = event.runtimeType.toString();
              if (eventType == 'FlTapDownEvent' ||
                  eventType == 'FlPanDownEvent') {
                if (touchedSpotIndex != null) {
                  setState(() {
                    touchedSpotIndex = null;
                  });
                }
              }
            }
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) =>
                touchedSpotIndex == touchedSpot.spotIndex
                ? const Color(0xFF1F2937)
                : Colors.transparent,
            tooltipPadding: EdgeInsets.all(8.w),
            tooltipMargin: 6,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (touchedSpots) {
              bool isFirst = true;
              return touchedSpots.map((ts) {
                final idx = ts.barIndex.clamp(0, widget.comparisons.length - 1);
                final entry = widget.comparisons[idx];
                final lbl = _kSeriesLabels[idx];
                final color = _kSeriesColors[idx];

                String rawDate = '';
                String dateStr = '';
                bool isWknd = false;
                if (ts.spotIndex < entry.data.length) {
                  rawDate = entry.data[ts.spotIndex].date;
                  dateStr = AppDateUtils.formatToDateDayMonth(rawDate);
                  isWknd = _isWeekend(rawDate);
                }

                if (touchedSpotIndex == ts.spotIndex) {
                  String titleStr = '';
                  if (isFirst) {
                    titleStr = '${dayLabel(rawDate)}\n';
                    isFirst = false;
                  }
                  final formattedAmt = NumberFormat.currency(
                    locale: 'en_IN',
                    symbol: '₹',
                    decimalDigits: 0,
                  ).format(ts.y);

                  return LineTooltipItem(
                    '$titleStr$lbl (${AppDateUtils.formatToDateDayMonth(entry.fromDate)} to ${AppDateUtils.formatToDateDayMonth(entry.toDate)}): ',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: '$formattedAmt ($dateStr)',
                        style: TextStyle(color: isWknd ? Colors.red : color),
                      ),
                    ],
                  );
                } else {
                  return LineTooltipItem(
                    '₹${NumberFormat('#,##,###').format(ts.y)} ($dateStr)',
                    TextStyle(
                      color: isWknd ? Colors.red : const Color(0xFF4B5563),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SummaryCards — one card per comparison entry with delta comparisons
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryCards extends StatelessWidget {
  final List<ComparisonEntry> comparisons;
  const _SummaryCards({required this.comparisons});

  @override
  Widget build(BuildContext context) {
    if (comparisons.isEmpty) return const SizedBox.shrink();

    // Find best performer
    final maxRevenue = comparisons
        .map((e) => e.totalRevenue)
        .reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: comparisons.length == 1
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: comparisons.map((entry) {
        final idx = (entry.comparison - 1).clamp(0, _kSeriesColors.length - 1);
        final isBest = entry.totalRevenue == maxRevenue;
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: _SummaryCard(
            entry: entry,
            idx: idx,
            isBest: isBest,
            others: comparisons.where((e) => e != entry).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final ComparisonEntry entry;
  final int idx;
  final bool isBest;
  final List<ComparisonEntry> others;

  const _SummaryCard({
    required this.entry,
    required this.idx,
    required this.isBest,
    required this.others,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0);
    final compactFmt = NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0);

    String formatDate(String rawDate) {
      try {
        final d = DateFormat('yyyy-MM-dd').parse(rawDate);
        return DateFormat('dd MMM yyyy').format(d);
      } catch (_) {
        return rawDate;
      }
    }

    final fromDateStr = formatDate(entry.fromDate);
    final toDateStr = formatDate(entry.toDate);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──
          Text(
            'Unit ${entry.unit}',
            style: AppTextStyle.style_12_500(color: AppColors.grey500),
          ),
          SizedBox(height: 8.h),

          // ── Revenue ──
          Text(
            '₹${fmt.format(entry.totalRevenue)}',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '$fromDateStr → $toDateStr',
            style: AppTextStyle.style_11_400(color: const Color(0xFF9CA3AF)),
          ),

          if (others.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Divider(height: 1.h, color: const Color(0xFFF3F4F6)),
            SizedBox(height: 10.h),

            // ── Delta comparisons ──
            ...others.map((other) {
              final otherIdx = (other.comparison - 1).clamp(
                0,
                _kSeriesColors.length - 1,
              );
              final otherColor = _kSeriesColors[otherIdx];
              final delta = entry.totalRevenue - other.totalRevenue;
              final isMore = delta >= 0;
              final absDelta = delta.abs();
              final pct = other.totalRevenue == 0
                  ? 0.0
                  : (absDelta / other.totalRevenue) * 100;

              return Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  children: [
                    Icon(
                      isMore
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 13.r,
                      color: isMore
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFEF4444),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyle.style_11_400(
                            color: AppColors.grey500,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  '₹${compactFmt.format(absDelta)} ${isMore ? 'more' : 'less'}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isMore
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFDC2626),
                                fontSize: 11.sp,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '  ${pct.toStringAsFixed(2)}% ${isMore ? 'higher' : 'lower'} than ',
                            ),
                            TextSpan(
                              text: 'Unit ${other.unit}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: otherColor,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          if (isBest) ...[
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Best Performing',
                    style: AppTextStyle.style_10_500(color: AppColors.grey500),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text('🏆', style: TextStyle(fontSize: 14.sp)),
                      SizedBox(width: 4.w),
                      Text(
                        'Unit ${entry.unit}',
                        style: AppTextStyle.style_12_600(color: AppColors.black),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Highest revenue in the selected period',
                    style: AppTextStyle.style_10_400(color: AppColors.grey500),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
