import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/support_dashboard_controller.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';

class SupportDashboardScreen extends GetView<SupportDashboardController> {
  const SupportDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const AppCommonAppBar(
        title: Text('Support Ticket Dashboard'),
        showAppDrawer: true,
        hasBackButton: false,
        topHeader: CommonShortcutHeader(),
      ),
      drawer: const CommonSidebar(),
      body: Obx(() {
        // Show CustomAppLoader if it's the initial loading state without any data
        if (controller.isLoading.value && controller.unitsData.isEmpty) {
          return const Center(child: CustomAppLoader());
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.fetchDashboard();
            // Optional: wait a bit for animation
            await Future.delayed(const Duration(seconds: 1));
          },
          child: Skeletonizer(
            enabled: controller.isLoading.value,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFilterSection(),
                  const SizedBox(height: 12),
                  Text(
                    'Support Ticket Dashboard',
                    style: AppTextStyle.style_18_700(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryCards(),
                  const SizedBox(height: 12),
                  _buildStatusChart(),
                  const SizedBox(height: 12),
                  _buildUnitsChart(),
                  const SizedBox(height: 12),
                  _buildCategoryChart(),
                  const SizedBox(height: 12),
                  _buildAssigneeTable(),
                  const SizedBox(height: 12),
                  _buildTrendChart(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // --- 1. FILTER SECTION ---
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMultiSelectRow<String>(
                  label: 'Units :',
                  hint: 'Select unit(s)',
                  selectedValues: controller.selectedUnits.toSet(),
                  items: controller.unitsData.map((e) => DropdownMenuItem(value: e['label'] as String, child: Text(e['label'] as String))).toList(),
                  onChanged: (vals) => controller.selectedUnits.assignAll(vals.toList()),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 28,
                child: ElevatedButton.icon(
                  onPressed: controller.resetFilters,
                  icon: const Icon(Icons.refresh, size: 14),
                  label: Text('Reset', style: AppTextStyle.style_11_400(color: AppColors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.grey600,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date :', style: AppTextStyle.style_11_600(color: AppColors.primaryOrange)),
                    Text('Custom', style: AppTextStyle.style_11_600(color: AppColors.blue700)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _filterChip('Yesterday')),
                    const SizedBox(width: 8),
                    Expanded(child: _filterChip('Today')),
                    const SizedBox(width: 8),
                    Expanded(child: _filterChip('This Week')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _filterChip('Last Week')),
                    const SizedBox(width: 8),
                    Expanded(child: _filterChip('This Month')),
                    const SizedBox(width: 8),
                    Expanded(child: _filterChip('Last Month')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status :', style: AppTextStyle.style_11_600(color: AppColors.primaryOrange)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _filterChip('New')),
                    const SizedBox(width: 8),
                    Expanded(child: _filterChip('Wip')),
                    const SizedBox(width: 8),
                    Expanded(child: _filterChip('Hold')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _filterChip('Awaited')),
                    const SizedBox(width: 8),
                    Expanded(child: _filterChip('Resolved')),
                    const SizedBox(width: 8),
                    Expanded(child: _filterChip('Closed')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildMultiSelectRow<String>(
            label: 'Category :',
            hint: 'Select category(s)',
            selectedValues: controller.selectedCategories.toSet(),
            items: controller.categoryData.map((e) => DropdownMenuItem(value: e['label'] as String, child: Text(e['label'] as String))).toList(),
            onChanged: (vals) => controller.selectedCategories.assignAll(vals.toList()),
            showSearch: true,
          ),
          const SizedBox(height: 8),
          _buildMultiSelectRow<String>(
            label: 'Assignee :',
            hint: 'Select assignee(s)',
            selectedValues: controller.selectedAssignees.toSet(),
            items: controller.assigneeReport.map((e) => DropdownMenuItem(value: e['name'] as String, child: Text(e['name'] as String))).toList(),
            onChanged: (vals) => controller.selectedAssignees.assignAll(vals.toList()),
            showSearch: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectRow<T>({
    required String label,
    required String hint,
    required Set<T> selectedValues,
    required List<DropdownMenuItem<T>> items,
    required Function(Set<T>) onChanged,
    bool showSearch = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: AppTextStyle.style_11_600(color: AppColors.primaryOrange)),
          ),
          Expanded(
            child: DashboardMultiSelect<T>(
              hint: hint,
              selectedValues: selectedValues,
              items: items,
              onChanged: onChanged,
              showSearch: showSearch,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.orange200),
      ),
      alignment: Alignment.center,
      child: Text(label, style: AppTextStyle.style_11_400(color: AppColors.black87)),
    );
  }

  // --- 2. SUMMARY CARDS ---
  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(child: _summaryCard('Open', controller.openTickets.value.toString())),
        const SizedBox(width: 8),
        Expanded(child: _summaryCard('Hold', controller.holdTickets.value.toString())),
        const SizedBox(width: 8),
        Expanded(child: _summaryCard('Resolved', controller.resolvedTickets.value.toString())),
        const SizedBox(width: 8),
        Expanded(child: _summaryCard('Total', controller.totalTickets.value.toString())),
      ],
    );
  }

  Widget _summaryCard(String title, String count) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.orange200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyle.style_12_400(color: AppColors.grey600),
          ),
          Text(
            count,
            style: AppTextStyle.style_16_700(color: AppColors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            'View Report',
            style: AppTextStyle.style_10_700(color: AppColors.primaryBlue),
          ),
        ],
      ),
    );
  }

  // --- 3. STATUS CHART ---
  Widget _buildStatusChart() {
    double maxVal = 0;
    for (var item in controller.statusData) {
      final val = (item['value'] as int).toDouble();
      if (val > maxVal) maxVal = val;
    }
    final calculatedMaxY = maxVal == 0 ? 10.0 : (maxVal * 1.2 / 50).ceil() * 50.0;
    final yInterval = calculatedMaxY / 4;

    return _chartCard(
      title: 'Status',
      height: 200,
      child: BarChart(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: calculatedMaxY,
          barTouchData: BarTouchData(
            enabled: false,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => AppColors.transparent,
              tooltipPadding: EdgeInsets.zero,
              tooltipMargin: 4,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.round().toString(),
                  AppTextStyle.style_11_700(color: AppColors.black),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  if (value >= 0 && value < controller.statusData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        controller.statusData[value.toInt()]['label'] as String,
                        style: AppTextStyle.style_10_400(color: AppColors.black87),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: yInterval == 0 ? 10 : yInterval,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: AppTextStyle.style_10_400(color: AppColors.black87),
                ),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: yInterval == 0 ? 10 : yInterval,
            getDrawingHorizontalLine: (value) => FlLine(color: AppColors.grey200, strokeWidth: 1, dashArray: [4, 4]),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(color: AppColors.grey300, width: 1),
              left: BorderSide(color: AppColors.grey300, width: 1),
              right: BorderSide.none,
              top: BorderSide.none,
            ),
          ),
          barGroups: controller.statusData.asMap().entries.map((e) {
            final val = e.value['value'] as int;
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: val.toDouble(),
                  color: AppColors.primaryOrange,
                  width: 16,
                  borderRadius: BorderRadius.zero,
                ),
              ],
              showingTooltipIndicators: [0],
            );
          }).toList(),
        ),
      ),
    );
  }

  // --- 4. UNITS CHART ---
  Widget _buildUnitsChart() {
    double maxVal = 0;
    for (var item in controller.unitsData) {
      final val = (item['value'] as int).toDouble();
      if (val > maxVal) maxVal = val;
    }
    final calculatedMaxY = maxVal == 0 ? 10.0 : (maxVal * 1.2 / 50).ceil() * 50.0;
    final yInterval = calculatedMaxY / 4;

    return _chartCard(
      title: 'Units',
      height: 200,
      child: BarChart(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: calculatedMaxY,
          barTouchData: BarTouchData(
            enabled: false,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => AppColors.transparent,
              tooltipPadding: EdgeInsets.zero,
              tooltipMargin: 4,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.round().toString(),
                  AppTextStyle.style_11_700(color: AppColors.black),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  if (value >= 0 && value < controller.unitsData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Transform.rotate(
                        angle: -0.5,
                        child: Text(
                          controller.unitsData[value.toInt()]['label'] as String,
                          style: AppTextStyle.style_9_400(color: AppColors.black87),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: yInterval == 0 ? 10 : yInterval,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: AppTextStyle.style_10_400(color: AppColors.black87),
                ),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: yInterval == 0 ? 10 : yInterval,
            getDrawingHorizontalLine: (value) => FlLine(color: AppColors.grey200, strokeWidth: 1, dashArray: [4, 4]),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(color: AppColors.grey300, width: 1),
              left: BorderSide(color: AppColors.grey300, width: 1),
              right: BorderSide.none,
              top: BorderSide.none,
            ),
          ),
          barGroups: controller.unitsData.asMap().entries.map((e) {
            final val = e.value['value'] as int;
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: val.toDouble(),
                  color: AppColors.primaryOrange,
                  width: 14,
                  borderRadius: BorderRadius.zero,
                ),
              ],
              showingTooltipIndicators: [0],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryChart() {
    final colors = [
      AppColors.purple,
      AppColors.orange200,
      AppColors.info,
      AppColors.primaryVariant,
      AppColors.warning,
      AppColors.yellow,
      AppColors.grey300,
    ];
    
    double currentY = 0;
    final stackItems = <BarChartRodStackItem>[];
    for (int i = 0; i < controller.categoryData.length; i++) {
      final val = (controller.categoryData[i]['value'] as int).toDouble();
      stackItems.add(BarChartRodStackItem(currentY, currentY + val, colors[i % colors.length]));
      currentY += val;
    }
    final calculatedMaxY = currentY == 0 ? 10.0 : (currentY * 1.2 / 50).ceil() * 50.0;
    final yInterval = calculatedMaxY / 4;

    return _chartCard(
      title: 'Category',
      height: 250,
      child: Column(
        children: [
          // Legend
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: controller.categoryData.asMap().entries.map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 12, height: 12, color: colors[e.key % colors.length]),
                  const SizedBox(width: 4),
                  Text(
                    e.value['label'] as String,
                    style: AppTextStyle.style_10_400(color: AppColors.black87),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOutCubic,
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: calculatedMaxY,
                barTouchData: BarTouchData(
                  enabled: false,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => AppColors.transparent,
                    tooltipPadding: EdgeInsets.zero,
                    tooltipMargin: 6,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.round().toString(),
                        AppTextStyle.style_10_700(color: AppColors.black),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Transform.rotate(
                            angle: -0.5,
                            child: Text(
                              'IT',
                              style: AppTextStyle.style_10_400(color: AppColors.black87),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: yInterval == 0 ? 10 : yInterval,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: AppTextStyle.style_10_400(color: AppColors.black87),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: yInterval == 0 ? 10 : yInterval,
                  getDrawingHorizontalLine: (value) => FlLine(color: AppColors.grey200, strokeWidth: 1, dashArray: [4, 4]),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    bottom: BorderSide(color: AppColors.grey300, width: 1),
                    left: BorderSide(color: AppColors.grey300, width: 1),
                    right: BorderSide.none,
                    top: BorderSide.none,
                  ),
                ),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: currentY,
                        color: AppColors.transparent,
                        width: 40,
                        borderRadius: BorderRadius.zero,
                        rodStackItems: stackItems,
                      ),
                    ],
                    showingTooltipIndicators: [0],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 6. ASSIGNEE TABLE ---
  Widget _buildAssigneeTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.orange200),
      ),
      child: Column(
        children: [
          // Filter Header for table
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Filters -> None',
                  style: AppTextStyle.style_12_400(color: AppColors.grey500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'From',
                      style: AppTextStyle.style_12_700(color: AppColors.black87),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          border: Border.all(color: AppColors.blue200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'dd-mm-yyyy',
                          style: AppTextStyle.style_12_400(color: AppColors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'To',
                      style: AppTextStyle.style_12_700(color: AppColors.black87),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          border: Border.all(color: AppColors.blue200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'dd-mm-yyyy',
                          style: AppTextStyle.style_12_400(color: AppColors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: AppColors.white,
                        ),
                        child: Text(
                          'Apply Filters',
                          style: AppTextStyle.style_12_700(color: AppColors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.black87,
                        ),
                        child: Text(
                          'Reset',
                          style: AppTextStyle.style_12_400(color: AppColors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Table Header
          Container(
            color: AppColors.blue50,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Name',
                    style: AppTextStyle.style_11_700(color: AppColors.primaryBlue),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Total',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.style_10_700(color: AppColors.primaryBlue),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Open',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.style_10_700(color: AppColors.primaryBlue),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Hold',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.style_10_700(color: AppColors.primaryBlue),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Awaited',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.style_10_700(color: AppColors.primaryBlue),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Resolved',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.style_10_700(color: AppColors.primaryBlue),
                  ),
                ),
              ],
            ),
          ),
          // Table Rows
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.assigneeReport.length,
            itemBuilder: (context, index) {
              final row = controller.assigneeReport[index];
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                color: index.isEven ? AppColors.white : AppColors.blue50.withValues(alpha: 0.3),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        row['name'] as String,
                        style: AppTextStyle.style_12_400(color: AppColors.blue),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row['total'].toString(),
                        textAlign: TextAlign.center,
                        style: AppTextStyle.style_12_700(color: AppColors.black87),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row['open'].toString(),
                        textAlign: TextAlign.center,
                        style: AppTextStyle.style_12_700(color: AppColors.black87),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row['hold'].toString(),
                        textAlign: TextAlign.center,
                        style: AppTextStyle.style_12_700(color: AppColors.black87),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row['awaited'].toString(),
                        textAlign: TextAlign.center,
                        style: AppTextStyle.style_12_700(color: AppColors.black87),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row['resolved'].toString(),
                        textAlign: TextAlign.center,
                        style: AppTextStyle.style_12_700(color: AppColors.black87),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- 7. TREND CHART ---
  Widget _buildTrendChart() {
    return _chartCard(
      title: 'Total Completed Tickets Trend by User',
      height: 180,
      child: Column(
        children: [
          // Legend
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: controller.trendSeries.map((series) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    color: Color(int.parse((series['color'] as String).replaceAll('#', '0xFF'))),
                    child: Text(
                      '4',
                      style: AppTextStyle.style_10_700(color: AppColors.white),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    series['name'] as String,
                    style: AppTextStyle.style_10_400(color: AppColors.black87),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Chart
          Expanded(
            child: LineChart(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOutCubic,
              LineChartData(
                lineTouchData: const LineTouchData(enabled: true),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: AppColors.grey200, strokeWidth: 1, dashArray: [4, 4]),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value >= 0 && value < controller.trendDates.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Transform.rotate(
                              angle: -0.5,
                              child: Text(
                                controller.trendDates[value.toInt()],
                                style: AppTextStyle.style_9_400(color: AppColors.black87),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: AppTextStyle.style_10_400(color: AppColors.black87),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                lineBarsData: controller.trendSeries.map((series) {
                  final data = series['data'] as List<int>;
                  final color = Color(int.parse((series['color'] as String).replaceAll('#', '0xFF')));
                  return LineChartBarData(
                    spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList(),
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WRAPPER FOR CHARTS ---
  Widget _chartCard({required String title, required double height, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.orange300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title, 
                    style: AppTextStyle.style_16_700(color: AppColors.primaryBlue),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildOutlinedIconButton(Icons.share, () {}),
                    const SizedBox(width: 8),
                    _buildOutlinedIconButton(Icons.download, () {}),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: height,
            padding: const EdgeInsets.only(top: 16, right: 16, left: 4, bottom: 12),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinedIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.grey300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: AppColors.primaryBlue),
      ),
    );
  }
}

class DashboardMultiSelect<T> extends StatelessWidget {
  final String hint;
  final Set<T> selectedValues;
  final List<DropdownMenuItem<T>> items;
  final Function(Set<T>) onChanged;
  final bool showSearch;

  const DashboardMultiSelect({
    super.key,
    required this.hint,
    required this.selectedValues,
    required this.items,
    required this.onChanged,
    this.showSearch = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;
        final Offset offset = renderBox.localToGlobal(Offset.zero);
        final Size size = renderBox.size;
        final Rect buttonRect = offset & size;

        final searchController = TextEditingController();
        final scrollController = ScrollController();
        Set<T> tempSelected = Set<T>.from(selectedValues);

        await showMenu(
          context: context,
          color: AppColors.white,
          position: RelativeRect.fromRect(
            buttonRect,
            Offset.zero & MediaQuery.of(context).size,
          ),
          items: [
            PopupMenuItem(
              enabled: false,
              padding: EdgeInsets.zero,
              child: Container(
                constraints: BoxConstraints(
                  minWidth: size.width,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: 300,
                ),
                color: AppColors.white,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    List<DropdownMenuItem<T>> displayedItems = items;
                    if (showSearch && searchController.text.isNotEmpty) {
                      displayedItems = items.where((item) {
                        final text = item.child is Text ? (item.child as Text).data ?? '' : item.child.toString();
                        return text.toLowerCase().contains(searchController.text.toLowerCase());
                      }).toList();
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showSearch)
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: AppTextStyle.style_11_400(color: AppColors.grey500),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              onChanged: (query) => setState(() {}),
                            ),
                          ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: Scrollbar(
                            controller: scrollController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: displayedItems.map((item) {
                                  final value = item.value;
                                  return CheckboxListTile(
                                    title: item.child,
                                    value: tempSelected.contains(value),
                                    onChanged: (checked) {
                                      setState(() {
                                        if (checked == true) {
                                          tempSelected.add(value as T);
                                        } else {
                                          tempSelected.remove(value);
                                        }
                                      });
                                      onChanged(Set<T>.from(tempSelected));
                                    },
                                    dense: true,
                                    controlAffinity: ListTileControlAffinity.leading,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.orange200),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          selectedValues.isEmpty ? hint : _getSelectedText(),
          style: selectedValues.isEmpty 
              ? AppTextStyle.style_11_400(color: AppColors.black87)
              : AppTextStyle.style_11_600(color: AppColors.blue),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  String _getSelectedText() {
    if (selectedValues.length == 1) {
      final val = selectedValues.first;
      try {
        final match = items.firstWhere((item) => item.value == val);
        if (match.child is Text) {
          return (match.child as Text).data ?? '1 selected';
        }
      } catch (_) {}
    }
    return '${selectedValues.length} selected';
  }
}
