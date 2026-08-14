import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:mfresh_ops/modules/dashboard/models/dashboard_data_model.dart';
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
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:mfresh_ops/modules/dashboard/views/widgets/dashboard_filters.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:core/core.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: const CommonSidebar(),
      appBar: AppCommonAppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
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
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
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
                    'yesterday': 'Yesterday',
                    'today': 'Today',
                    'this_week': 'This Week',
                    'last_week': 'Last Week',
                    'this_month': 'This Month',
                    'last_month': 'Last Month',
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
        showAppDrawer: true,
        hasBackButton: false,
        iconColor: AppColors.black,
        topHeader: const CommonShortcutHeader(),
      ),
      body: Obx(() {
        final bool isLoading = controller.rxIsLoading.value;
        final data = controller.rxDashboardData.value;
        
        final dummyData = DashboardDataModel(
          totalRevenue: 100000,
          totalBookings: 100,
          totalServicesCount: 50,
          customerPg: 2000,
          kioskCash: 1000,
          kioskPg: 1000,
          externalQr: 1000,
          customerPgRevenue: 2000,
          kioskCashRevenue: 1000,
          kioskPgRevenue: 1000,
          externalQrRevenue: 1000,
          revenueData: [],
          dailyRevenue: [],
          dailyBookings: [],
          dailyServiceBookings: [],
          unitWiseRevenueGraph: [],
          monthWiseBookings: [],
          monthWiseServiceBookings: [],
          timeRevenueData: [],
          timeBookingData: [],
          topUnits: [],
          serviceWiseData: [],
          allUnits: [
            UnitData(unitNo: 'MM25002', revenue: 5170, servicesCount: 77),
            UnitData(unitNo: 'MM25003', revenue: 8680, servicesCount: 141),
            UnitData(unitNo: 'MM25004', revenue: 1830, servicesCount: 23),
            UnitData(unitNo: 'MM25005', revenue: 1860, servicesCount: 27),
          ],
        );
        
        final displayData = data ?? dummyData;
        final hasDateFilter = controller.rxDateFilter.value != null ||
            (controller.rxStartDate.value != null && controller.rxEndDate.value != null);
        final hasMonthFilter = controller.rxMonthFilter.value != null ||
            controller.rxFromMonth.value != null ||
            controller.rxGrowthFilter.value != null;

        return RefreshIndicator(
          onRefresh: controller.pullToRefresh,
          child: GestureDetector(
            onTap: () {
              controller.rxClearTooltipsTrigger.value++;
            },
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
                        DashboardMetricsCard(data: displayData),
                        SizedBox(height: 24.h),
                        if (displayData.growthData != null && displayData.growthData!.filterUsed.isNotEmpty)
                          DashboardGrowthCard(growthData: displayData.growthData!),
                        DashboardUnitsChart(
                          key: const GlobalObjectKey('dashboard_units_chart'),
                          data: displayData.allUnits,
                        ),
                        SizedBox(height: 24.h),
                        DashboardUnitWiseChart(
                          key: const GlobalObjectKey('dashboard_unit_wise_chart'),
                          data: displayData.unitWiseRevenueGraph,
                        ),
                        SizedBox(height: 24.h),
                        if (!hasMonthFilter && displayData.dailyRevenue.isNotEmpty) ...[
                          DashboardMonthWiseChart(
                            data: displayData.dailyRevenue,
                            title: 'Revenue by Day',
                            showDays: true,
                          ),
                          SizedBox(height: 24.h),
                        ],
                        if (!hasDateFilter && displayData.revenueData.isNotEmpty) ...[
                          DashboardMonthWiseChart(data: displayData.revenueData),
                          SizedBox(height: 24.h),
                        ],
                        if (!hasMonthFilter && displayData.dailyBookings.isNotEmpty) ...[
                          DashboardDailyCountChart(
                            title: 'Booking Count by Day',
                            data: displayData.dailyBookings,
                            color: const Color(0xFF34A853),
                          ),
                          SizedBox(height: 24.h),
                        ],
                        if (!hasDateFilter && (displayData.monthWiseBookings.isNotEmpty || displayData.monthWiseServiceBookings.isNotEmpty)) ...[
                          DashboardBookingsChart(
                            bookingsData: displayData.monthWiseBookings,
                            serviceBookingsData: displayData.monthWiseServiceBookings,
                          ),
                          SizedBox(height: 24.h),
                        ],
                        if (!hasMonthFilter && displayData.dailyServiceBookings.isNotEmpty) ...[
                          DashboardDailyCountChart(
                            title: 'Services Booking Counts',
                            data: displayData.dailyServiceBookings,
                            color: const Color(0xFF1677FF),
                          ),
                          SizedBox(height: 24.h),
                        ],
                        if (displayData.timeRevenueData.isNotEmpty)
                          DashboardHourlyChart(
                            title: 'Revenue by Hour',
                            data: displayData.timeRevenueData,
                            barColor: const Color(0xFFFCA5A5), // Pink-ish red
                            isRevenue: true,
                          ),
                        SizedBox(height: 24.h),
                        if (displayData.timeBookingData.isNotEmpty)
                          DashboardHourlyChart(
                            title: 'Booking by Hour',
                            data: displayData.timeBookingData,
                            barColor: const Color(0xFF86EFAC), // Light green
                            isRevenue: false,
                          ),
                        SizedBox(height: 24.h),
                        if (displayData.serviceWiseData.isNotEmpty) ...[
                          DashboardServiceChart(
                            title: 'Service Wise Revenue',
                            data: displayData.serviceWiseData,
                            isRevenue: true,
                          ),
                          SizedBox(height: 24.h),
                          DashboardServiceChart(
                            title: 'Service Wise Booking Count',
                            data: displayData.serviceWiseData,
                            isRevenue: false,
                          ),
                          SizedBox(height: 24.h),
                        ],
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 600;
                            final childWidth = isWide ? (constraints.maxWidth / 2) - 12.w : constraints.maxWidth;
                            
                            return Wrap(
                              spacing: 24.w,
                              runSpacing: 24.h,
                              children: [
                                if (displayData.topUnits.isNotEmpty)
                                  SizedBox(
                                    width: childWidth,
                                    child: DashboardTopUnitsRadialChart(data: displayData.topUnits),
                                  ),
                                SizedBox(
                                  width: childWidth,
                                  child: DashboardPaymentPieChart(data: displayData),
                                ),
                                if (displayData.serviceWiseData.isNotEmpty)
                                  SizedBox(
                                    width: childWidth,
                                    child: DashboardServicePieChart(
                                      data: displayData.serviceWiseData,
                                      isRevenue: true,
                                    ),
                                  ),
                                if (displayData.serviceWiseData.isNotEmpty)
                                  SizedBox(
                                    width: childWidth,
                                    child: DashboardServicePieChart(
                                      data: displayData.serviceWiseData,
                                      isRevenue: false,
                                    ),
                                  ),
                              ],
                            );
                          }
                        ),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ));
      }),
    );
  }
}
