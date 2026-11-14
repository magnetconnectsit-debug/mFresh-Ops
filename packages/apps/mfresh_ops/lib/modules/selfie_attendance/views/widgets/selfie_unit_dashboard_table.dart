// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/selfie_attendance/selfie_attendance_report_model.dart';
import 'package:mfresh_ops/modules/selfie_attendance/controllers/selfie_attendance_controller.dart';
// endregion

// region View
class SelfieUnitDashboardTable extends StatefulWidget {
  const SelfieUnitDashboardTable({super.key});

  @override
  State<SelfieUnitDashboardTable> createState() => _SelfieUnitDashboardTableState();
}

class _SelfieUnitDashboardTableState extends State<SelfieUnitDashboardTable> {
  // region Observables & State Variables
  final _isExpanded = true.obs;
  final ScrollController _scrollController = ScrollController();
  // endregion

  // region Lifecycle Methods
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SelfieAttendanceController>();

    return Obx(() {
      final dashboard = controller.unitDashboard.value;
      if (dashboard == null || dashboard.rows.isEmpty) {
        return const SizedBox.shrink();
      }

      final rows = dashboard.rows;
      final totals = dashboard.totals;
      final totalCount = totals?.total ?? 0;
      final isExpanded = _isExpanded.value;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.borderColor,
            width: 1.r,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(totalCount, isExpanded),
            AnimatedCrossFade(
              firstChild: _buildStickyUnitTable(rows, totals),
              secondChild: const SizedBox.shrink(),
              crossFadeState: isExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      );
    });
  }
  // endregion

  // region Section Builders
  Widget _buildHeader(int totalCount, bool isExpanded) {
    return InkWell(
      onTap: () => _isExpanded.value = !_isExpanded.value,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
        child: Row(
          children: [
            Container(
              width: 20.r,
              height: 20.r,
              decoration: BoxDecoration(
                color: AppColors.yellow50,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Center(
                child: Icon(
                  Icons.apartment_rounded,
                  size: 13.sp,
                  color: AppColors.yellow700,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Unit Attendance',
                style: AppTextStyle.style_13_600(color: AppColors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.blue50,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: AppColors.blue500.withValues(alpha: 0.3),
                  width: 1.r,
                ),
              ),
              child: RichText(
                text: TextSpan(
                  text: 'Total ',
                  style: AppTextStyle.style_11_500(color: AppColors.blue800),
                  children: [
                    TextSpan(
                      text: '$totalCount',
                      style: AppTextStyle.style_12_700(color: AppColors.blue800),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 4.w),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20.sp,
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyUnitTable(
    List<SelfieUnitDashboardRow> rows,
    SelfieUnitDashboardTotals? totals,
  ) {
    final double fixedUnitColWidth = 56.w;
    final double fixedTotalColWidth = 54.w;
    final double colWidth = 52.w;
    final double rowHeight = 24.h;

    final roles = [
      {'key': 'cashier', 'title': 'Cashier', 'val': (SelfieUnitDashboardRow r) => r.cashier, 'total': totals?.cashier ?? 0},
      {'key': 'hk', 'title': 'HK', 'val': (SelfieUnitDashboardRow r) => r.housekeeping, 'total': totals?.housekeeping ?? 0},
      {'key': 'cleaner', 'title': 'Cleaner', 'val': (SelfieUnitDashboardRow r) => r.cleaner, 'total': totals?.cleaner ?? 0},
      {'key': 'sup', 'title': 'Sup.', 'val': (SelfieUnitDashboardRow r) => r.supervisor, 'total': totals?.supervisor ?? 0},
      {'key': 'sec', 'title': 'Sec.', 'val': (SelfieUnitDashboardRow r) => r.security, 'total': totals?.security ?? 0},
      {'key': 'other', 'title': 'Other', 'val': (SelfieUnitDashboardRow r) => r.other, 'total': totals?.other ?? 0},
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderColor, width: 1.r),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Fixed Left Column: "Unit" ──
          Container(
            width: fixedUnitColWidth,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: AppColors.borderColor, width: 1.r),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildCell(
                  width: fixedUnitColWidth,
                  height: rowHeight,
                  color: AppColors.blue50,
                  child: Text(
                    'Unit',
                    style: AppTextStyle.style_11_700(color: AppColors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Rows
                for (int i = 0; i < rows.length; i++)
                  _buildCell(
                    width: fixedUnitColWidth,
                    height: rowHeight,
                    color: i % 2 == 1 ? AppColors.boxColor2 : AppColors.white,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppColors.blue50,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        rows[i].unitName.toUpperCase(),
                        style: AppTextStyle.style_11_700(color: AppColors.blue800),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                // Total Row
                if (totals != null)
                  _buildCell(
                    width: fixedUnitColWidth,
                    height: rowHeight,
                    color: AppColors.boxColor2,
                    borderTop: BorderSide(color: AppColors.borderColor, width: 1.2.r),
                    child: Text(
                      'Total',
                      style: AppTextStyle.style_11_700(color: AppColors.blue800),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),

          // ── 2. Scrollable Middle Columns: Roles (Cashier, HK, Cleaner, Sup., Sec., Other) ──
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: Row(
                children: [
                  for (final role in roles)
                    Container(
                      width: colWidth,
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: AppColors.borderColor, width: 1.r),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          _buildCell(
                            width: colWidth,
                            height: rowHeight,
                            color: AppColors.blue50,
                            child: Text(
                              role['title'] as String,
                              style: AppTextStyle.style_11_700(color: AppColors.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          // Data Rows
                          for (int i = 0; i < rows.length; i++)
                            _buildCell(
                              width: colWidth,
                              height: rowHeight,
                              color: i % 2 == 1 ? AppColors.boxColor2 : AppColors.white,
                              child: _buildNumberText(
                                (role['val'] as int Function(SelfieUnitDashboardRow))(rows[i]),
                              ),
                            ),
                          // Total Row
                          if (totals != null)
                            _buildCell(
                              width: colWidth,
                              height: rowHeight,
                              color: AppColors.boxColor2,
                              borderTop: BorderSide(color: AppColors.borderColor, width: 1.2.r),
                              child: Text(
                                '${role['total']}',
                                style: AppTextStyle.style_11_700(color: AppColors.black),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── 3. Fixed Right Column: "Total" ──
          Container(
            width: fixedTotalColWidth,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColors.borderColor, width: 1.2.r),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildCell(
                  width: fixedTotalColWidth,
                  height: rowHeight,
                  color: AppColors.blue50,
                  child: Text(
                    'Total',
                    style: AppTextStyle.style_11_700(color: AppColors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Rows
                for (int i = 0; i < rows.length; i++)
                  _buildCell(
                    width: fixedTotalColWidth,
                    height: rowHeight,
                    color: i % 2 == 1 ? AppColors.boxColor2 : AppColors.white,
                    child: _buildRowTotalBadge(rows[i].total),
                  ),
                // Total Row
                if (totals != null)
                  _buildCell(
                    width: fixedTotalColWidth,
                    height: rowHeight,
                    color: AppColors.boxColor2,
                    borderTop: BorderSide(color: AppColors.borderColor, width: 1.2.r),
                    child: Text(
                      '${totals.total}',
                      style: AppTextStyle.style_11_700(color: AppColors.blue800),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell({
    required double width,
    required double height,
    required Color color,
    required Widget child,
    BorderSide? borderTop,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor, width: 0.8.r),
          top: borderTop ?? BorderSide.none,
        ),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget _buildNumberText(int count) {
    final isZero = count == 0;
    return Text(
      '$count',
      style: isZero
          ? AppTextStyle.style_11_400(color: AppColors.grey200)
          : AppTextStyle.style_11_700(color: AppColors.black),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRowTotalBadge(int total) {
    final isZero = total == 0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: isZero ? AppColors.boxColor2 : AppColors.primaryGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        '$total',
        style: AppTextStyle.style_11_700(
          color: isZero ? AppColors.grey200 : AppColors.primaryGreen,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  // endregion
}
// endregion
