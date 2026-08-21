import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/dashboard/controllers/dashboard_controller.dart';

import 'package:mfresh_ops/modules/dashboard/views/widgets/dashboard_metrics_card.dart';
import 'package:mfresh_ops/modules/dashboard/views/widgets/dashboard_units_chart.dart';
import 'package:mfresh_ops/modules/dashboard/views/widgets/dashboard_unit_wise_chart.dart';
import 'package:mfresh_ops/modules/dashboard/views/widgets/dashboard_growth_card.dart';
import 'package:mfresh_ops/modules/dashboard/views/widgets/dashboard_month_wise_chart.dart';
import 'package:mfresh_ops/modules/dashboard/views/widgets/dashboard_bookings_chart.dart';
import 'package:mfresh_ops/modules/dashboard/views/widgets/dashboard_daily_count_chart.dart';
import 'package:mfresh_ops/modules/dashboard/views/widgets/dashboard_hourly_chart.dart';
import 'package:mfresh_ops/modules/dashboard/views/widgets/dashboard_service_chart.dart';
import 'package:mfresh_ops/modules/dashboard/views/widgets/dashboard_top_units_radial_chart.dart';
import 'package:mfresh_ops/modules/dashboard/views/widgets/dashboard_payment_pie_chart.dart';
import 'package:mfresh_ops/modules/dashboard/views/widgets/dashboard_service_pie_chart.dart';
import 'package:mfresh_ops/modules/dashboard/views/widgets/comparison_view.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:mfresh_ops/modules/dashboard/views/widgets/dashboard_filters.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:core/core.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:skeletonizer/skeletonizer.dart';


class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final DashboardController controller = Get.find<DashboardController>();
  late final PageController _pageController;
  late final Worker _tabWorker;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: controller.rxDashboardTab.value);
    _tabWorker = ever(controller.rxDashboardTab, (int tabIndex) {
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          tabIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabWorker.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: const CommonSidebar(),
      appBar: AppCommonAppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Obx(() => Container(
          height: 36.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              _TabItem(
                label: 'Revenue',
                selected: controller.rxDashboardTab.value == 0,
                onTap: () => controller.rxDashboardTab.value = 0,
              ),
              _TabItem(
                label: 'Comparison',
                selected: controller.rxDashboardTab.value == 1,
                onTap: () => controller.rxDashboardTab.value = 1,
              ),
            ],
          ),
        )),
        showAppDrawer: true,
        hasBackButton: false,
        iconColor: AppColors.black,
        topHeader: const CommonShortcutHeader(),
      ),
      body: Column(
        children: [

          // ── Tab content ──────────────────────────────────────────
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // ── Revenue tab ──
                _KeepAliveWrapper(
                  child: Column(
                    children: [
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                        child: Row(
                          children: [
                            Text(
                              'Revenue Report',
                              style: AppTextStyle.style_18_600(color: AppColors.black),
                            ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Obx(() {
                              final List<Widget> chips = [];
                              
                              Widget buildChip(String label, VoidCallback onRemove) {
                                return GestureDetector(
                                  onTap: onRemove,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 6.w),
                                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(label, style: AppTextStyle.style_10_500(color: AppColors.primary)),
                                        SizedBox(width: 4.w),
                                        Icon(Icons.close, size: 10.sp, color: AppColors.primary),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              // Date Filter
                              if (controller.rxDateFilter.value != null) {
                                final labels = {
                                  'today': 'Today',
                                  'yesterday': 'Yesterday',
                                  'this_week': 'This Week',
                                  'last_week': 'Last Week',
                                  'this_month': 'This Month',
                                  'last_month': 'Last Month',
                                  'custom': 'Custom',
                                };
                                final label = labels[controller.rxDateFilter.value] ?? controller.rxDateFilter.value!;
                                chips.add(buildChip(label, () => controller.setDateFilter(null)));
                              }

                              // Custom Date Range
                              if (controller.rxStartDate.value != null && controller.rxEndDate.value != null) {
                                final startDt = DateTime.tryParse(controller.rxStartDate.value!);
                                final endDt = DateTime.tryParse(controller.rxEndDate.value!);
                                
                                bool isDefaultTime = false;
                                if (startDt != null && endDt != null) {
                                  isDefaultTime = startDt.hour == 0 && startDt.minute == 0 && endDt.hour == 23 && endDt.minute == 59;
                                }

                                final start = isDefaultTime
                                    ? AppDateUtils.formatToDateDayMonth(controller.rxStartDate.value)
                                    : AppDateUtils.formatToDateTimeAmPm(controller.rxStartDate.value);
                                final end = isDefaultTime
                                    ? AppDateUtils.formatToDateDayMonth(controller.rxEndDate.value)
                                    : AppDateUtils.formatToDateTimeAmPm(controller.rxEndDate.value);
                                    
                                chips.add(buildChip('$start - $end', () => controller.clearCustomDateFilter()));
                              }

                              // Month Filter
                              if (controller.rxMonthFilter.value != null) {
                                final labels = {
                                  'threemonth': 'Last 3 Months',
                                  'sixmonth': 'Last 6 Months',
                                };
                                final label = labels[controller.rxMonthFilter.value] ?? controller.rxMonthFilter.value!;
                                chips.add(buildChip(label, () => controller.setMonthFilter(null)));
                              }

                              if (controller.rxFromMonth.value != null && controller.rxToMonth.value != null) {
                                chips.add(
                                  buildChip(
                                    '${controller.rxFromMonth.value} - ${controller.rxToMonth.value}',
                                    () => controller.setMonthFilter(null),
                                  ),
                                );
                              }

                              // Growth Filter
                              if (controller.rxGrowthFilter.value != null) {
                                final labels = {
                                  'monthly': 'Monthly',
                                  'quarterly': 'Quarterly',
                                  'halfyearly': 'Half Yearly',
                                };
                                final label = labels[controller.rxGrowthFilter.value] ?? controller.rxGrowthFilter.value!;
                                chips.add(buildChip(label, () => controller.setGrowthFilter(null)));
                              }

                              // Payment Mode Filter
                              if (controller.rxPaymentMode.value != null) {
                                final labels = {
                                  '0': 'ON - Cust',
                                  '3': 'ON - Ex_QR',
                                  '2': 'ON - In_QR',
                                  '1': 'Cash',
                                };
                                final label = labels[controller.rxPaymentMode.value] ?? controller.rxPaymentMode.value!;
                                chips.add(buildChip(label, () => controller.clearPaymentMode()));
                              }

                              // Units Filter
                              if (controller.rxSelectedUnitIds.isNotEmpty) {
                                final label = controller.rxSelectedUnitIds.length == 1 
                                    ? controller.rxSelectedUnitIds.first 
                                    : '${controller.rxSelectedUnitIds.length} Units';
                                chips.add(buildChip(label, () => controller.setUnitFilters({})));
                              }

                              if (chips.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                reverse: true, // align to right
                                child: Row(
                                  children: chips,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Obx(() {
                        final bool isLoading = controller.rxIsLoading.value;
                    final data = controller.rxDashboardData.value;

              final displayData = data;
              final hasDateFilter = controller.rxDateFilter.value != null ||
                  (controller.rxStartDate.value != null && controller.rxEndDate.value != null);
              final hasMonthFilter = controller.rxMonthFilter.value != null ||
                  controller.rxFromMonth.value != null ||
                  controller.rxGrowthFilter.value != null;

              return RefreshIndicator(
                key: const ValueKey('revenue_tab'),
                onRefresh: controller.pullToRefresh,
                child: GestureDetector(
                  onTap: () => controller.rxClearTooltipsTrigger.value++,
                  behavior: HitTestBehavior.translucent,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DashboardFilters(),
                        SizedBox(height: 16.h),
                        if (data == null && isLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Center(child: CustomAppLoader(size: 40)),
                          )
                        else if (data == null && !isLoading)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 40.h),
                              child: Text(
                                'No data available.',
                                style: AppTextStyle.style_16_600(color: AppColors.grey500),
                              ),
                            ),
                          )
                        else
                          Skeletonizer(
                            enabled: isLoading,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DashboardMetricsCard(data: data!),
                                SizedBox(height: 8.h),
                                if (data!.growthData != null && data!.growthData!.filterUsed.isNotEmpty)
                                  DashboardGrowthCard(growthData: data!.growthData!),
                                DashboardUnitsChart(
                                  key: const GlobalObjectKey('dashboard_units_chart'),
                                  data: data!.allUnits,
                                ),
                                SizedBox(height: 8.h),
                                DashboardUnitWiseChart(
                                  key: const GlobalObjectKey('dashboard_unit_wise_chart'),
                                  data: data!.unitWiseRevenueGraph,
                                ),
                                SizedBox(height: 8.h),
                                if (!hasMonthFilter && data!.dailyRevenue.isNotEmpty) ...[
                                  DashboardMonthWiseChart(
                                    data: data!.dailyRevenue,
                                    title: 'Revenue by Day',
                                    showDays: true,
                                  ),
                                  SizedBox(height: 8.h),
                                ],
                                if (!hasDateFilter && data!.revenueData.isNotEmpty) ...[
                                  DashboardMonthWiseChart(data: data!.revenueData),
                                  SizedBox(height: 8.h),
                                ],
                                if (!hasMonthFilter && data!.dailyBookings.isNotEmpty) ...[
                                  DashboardDailyCountChart(
                                    title: 'Booking Count by Day',
                                    data: data!.dailyBookings,
                                    color: const Color(0xFF34A853),
                                  ),
                                  SizedBox(height: 8.h),
                                ],
                                if (!hasDateFilter && (data!.monthWiseBookings.isNotEmpty || data!.monthWiseServiceBookings.isNotEmpty)) ...[
                                  DashboardBookingsChart(
                                    bookingsData: data!.monthWiseBookings,
                                    serviceBookingsData: data!.monthWiseServiceBookings,
                                  ),
                                  SizedBox(height: 8.h),
                                ],
                                if (!hasMonthFilter && data!.dailyServiceBookings.isNotEmpty) ...[
                                  DashboardDailyCountChart(
                                    title: 'Services Booking Counts',
                                    data: data!.dailyServiceBookings,
                                    color: const Color(0xFF1677FF),
                                  ),
                                  SizedBox(height: 8.h),
                                ],
                                if (data!.timeRevenueData.isNotEmpty)
                                  DashboardHourlyChart(
                                    title: 'Revenue by Hour',
                                    data: data!.timeRevenueData,
                                    barColor: const Color(0xFFFCA5A5),
                                    isRevenue: true,
                                  ),
                                SizedBox(height: 8.h),
                                if (data!.timeBookingData.isNotEmpty)
                                  DashboardHourlyChart(
                                    title: 'Booking by Hour',
                                    data: data!.timeBookingData,
                                    barColor: const Color(0xFF86EFAC),
                                    isRevenue: false,
                                  ),
                                SizedBox(height: 8.h),
                                if (data!.serviceWiseData.isNotEmpty) ...[
                                  DashboardServiceChart(
                                    title: 'Service Wise Revenue',
                                    data: data!.serviceWiseData,
                                    isRevenue: true,
                                  ),
                                  SizedBox(height: 8.h),
                                  DashboardServiceChart(
                                    title: 'Service Wise Booking Count',
                                    data: data!.serviceWiseData,
                                    isRevenue: false,
                                  ),
                                  SizedBox(height: 8.h),
                                ],
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isWide = constraints.maxWidth > 600;
                                    final childWidth = isWide ? (constraints.maxWidth / 2) - 12.w : constraints.maxWidth;

                                    return Wrap(
                                      spacing: 24.w,
                                      runSpacing: 8.h,
                                      children: [
                                        if (data!.topUnits.isNotEmpty)
                                          SizedBox(
                                            width: childWidth,
                                            child: DashboardTopUnitsRadialChart(data: data!.topUnits),
                                          ),
                                        SizedBox(
                                          width: childWidth,
                                          child: DashboardPaymentPieChart(data: data!),
                                        ),
                                        if (data!.serviceWiseData.isNotEmpty)
                                          SizedBox(
                                            width: childWidth,
                                            child: DashboardServicePieChart(
                                              data: data!.serviceWiseData,
                                              isRevenue: true,
                                            ),
                                          ),
                                        if (data!.serviceWiseData.isNotEmpty)
                                          SizedBox(
                                            width: childWidth,
                                            child: DashboardServicePieChart(
                                              data: data!.serviceWiseData,
                                              isRevenue: false,
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                                SizedBox(height: 40.h),
                              ],
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

                // ── Comparison tab ──
                const _KeepAliveWrapper(
                  child: ComparisonView(key: ValueKey('comparison_view')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const _KeepAliveWrapper({required this.child});

  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

// ── Pill tab item ─────────────────────────────────────────────────────────────
class _TabItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.all(3.r),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AppColors.primary : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }
}
