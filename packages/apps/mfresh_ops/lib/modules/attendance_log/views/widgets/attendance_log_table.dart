import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:mfresh_ops/data/models/tracking/attendance_log_model.dart';
import 'package:mfresh_ops/modules/attendance_log/controllers/attendance_log_controller.dart';

// Sortable columns (label matches controller.sortBy key)

const List<(String, double)> _kColumns = [
  ('Date', 80),
  ('Day', 55),
  ('Employee Name', 120),
  ('Shift Start', 75),
  ('Shift End', 75),
  ('Duration', 80),
  ('Location', 110), // Shift Location
  ('Live In (First)', 85),
  ('Live Out (Last)', 85),
  ('Live (Total)', 85),
  ('Live (Shift)', 85),
  ('Duty Shortage', 85),
  ('Late For (Duration)', 100),
  ('Location ', 100), // Actual Location (trailing space = unique key)
  ('Location mismatch', 70),
  ('Action', 55),
];

class AttendanceLogTable extends GetView<AttendanceLogController> {
  const AttendanceLogTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingData.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final response = controller.responseData.value;
      if (response == null || response.rows.isEmpty) {
        return Center(
          child: Text(
            'No attendance data found.',
            style: AppTextStyle.style_14_500(color: AppColors.grey500),
          ),
        );
      }

      // Touch sort state so Obx re-renders on sort change
      controller.sortColumn.value;
      controller.sortAscending.value;
      final rows = controller.sortedRows;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: _kColumns.fold<double>(0.0, (sum, c) => sum + c.$2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderRow(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: controller.fetchAttendanceLog,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: rows.length,
                      itemBuilder: (context, index) {
                        return _buildDataRow(rows[index], index);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // Shift Schedule group = Shift Start(75) + Shift End(75) + Shift Dur.(80) + Shift Loc.(110) = 340
  // Actual group         = Late Dur.(80)   + Actual Loc.(110)                                  = 190

  Widget _buildHeaderRow() {
    const hBg = Color(0xFFD4E8D1); // sage green  – top row
    const sBg = Color(0xFFE6F3E4); // light sage  – sub-row
    final div = BorderSide(color: Colors.grey.shade400);
    final divL = BorderSide(color: Colors.grey.shade300); // lighter for sub

    // ── Top row cell ─────────────────────────────────────────────────────
    Widget topCell(
      String label,
      double width, {
      bool sortable = false,
      String? sortKey,
      bool isLast = false,
      bool hasBottom = false,
    }) {
      final key = sortKey ?? label;
      final sorted = controller.sortColumn.value == key;
      return GestureDetector(
        onTap: sortable ? () => controller.sortBy(key) : null,
        child: Container(
          width: width,
          constraints: const BoxConstraints(minHeight: 21),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: hBg,
            border: Border(
              right: isLast ? BorderSide.none : div,
              bottom: hasBottom ? div : BorderSide.none,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyle.style_10_700(color: AppColors.grey900),
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                ),
              ),
              if (sorted) ...[
                SizedBox(width: 2.w),
                Icon(
                  controller.sortAscending.value
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 10,
                  color: AppColors.grey900,
                ),
              ],
            ],
          ),
        ),
      );
    }

    // ── Group title (spans full group width, centered) ───────────────────
    Widget groupTitle(String label, double totalW) {
      return Container(
        width: totalW,
        height: 21,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: hBg,
          border: Border(right: div, bottom: div),
        ),
        child: Text(
          label,
          style: AppTextStyle.style_11_700(color: AppColors.grey900),
        ),
      );
    }

    // ── Sub-row cell (under group) ───────────────────────────────────────
    Widget subCell(
      String label,
      double width, {
      bool sortable = false,
      String? sortKey,
      bool isLast = false,
    }) {
      final key = sortKey ?? label;
      final sorted = controller.sortColumn.value == key;
      return GestureDetector(
        onTap: sortable ? () => controller.sortBy(key) : null,
        child: Container(
          width: width,
          height: 21,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: sBg,
            border: Border(right: isLast ? BorderSide.none : divL),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyle.style_10_600(color: AppColors.grey800),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (sorted) ...[
                SizedBox(width: 2.w),
                Icon(
                  controller.sortAscending.value
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 9,
                  color: AppColors.grey800,
                ),
              ],
            ],
          ),
        ),
      );
    }

    // ── Empty sub-row cell for standalone cols (keeps right border) ──────
    Widget emptySubCell(double width, {bool isLast = false}) {
      return Container(
        width: width,
        height: 21,
        decoration: BoxDecoration(
          color: hBg,
          border: Border(right: isLast ? BorderSide.none : div),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade400),
          bottom: BorderSide(color: Colors.grey.shade400),
        ),
      ),
      child: Column(
        children: [
          // ══ Row 1 – group titles only ═════════════════════════════════
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                topCell('Date', 80, sortable: true),
                topCell('Day', 55, sortable: true),
                topCell('Employee Name', 120, sortable: true),
                // Shift Schedule: Shift Start(75)+Shift End(75)+Duration(80)+Location(110) = 340
                groupTitle('Shift Schedule', 75 + 75 + 80.0 + 110),
                // Actual: Live In(85)+Live Out(85)+Live Total(85)+Live Shift(85)+Duty(85)+Late(100)+Loc(100) = 625
                groupTitle('Actual', 85 + 85 + 85 + 85 + 85 + 100.0 + 100),
                topCell('Location\nmismatch', 70, sortable: true),
                topCell('Action', 55, isLast: true),
              ],
            ),
          ),
          // ══ Row 2 – sub-column labels ════════════════════════════════
          Row(
            children: [
              emptySubCell(80), // Date
              emptySubCell(55), // Day
              emptySubCell(120), // Employee Name
              // Shift Schedule sub-cols
              subCell('Shift Start', 75, sortable: true),
              subCell('Shift End', 75, sortable: true),
              subCell('Duration', 80, sortable: true),
              subCell('Location', 110, sortable: true, sortKey: 'Shift Location'),
              // Actual sub-cols
              subCell('Live In (First)', 85, sortable: true),
              subCell('Live Out (Last)', 85, sortable: true),
              subCell('Live (Total)', 85, sortable: true),
              subCell('Live (Shift)', 85, sortable: true),
              subCell('Duty Shortage', 85, sortable: true),
              subCell('Late For (Duration)', 100, sortable: true),
              subCell('Location', 100, sortable: true, sortKey: 'Actual Location'),
              emptySubCell(70), // Location mismatch
              emptySubCell(55, isLast: true), // Action
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(AttendanceRow row, int index) {
    return Obx(() {
      final isExpanded = controller.expandedRows.contains(index);

      void toggleRow() {
        if (isExpanded) {
          controller.expandedRows.remove(index);
        } else {
          controller.expandedRows.add(index);
        }
      }

      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date: formatted via AppDateUtils
            _buildCell(
              AppDateUtils.formatToApiDate(
                row.rawDate.isNotEmpty ? row.rawDate : row.date,
              ),
              _kColumns[0].$2,
              isExpanded: isExpanded,
              onTap: toggleRow,
            ),
            // Day: abbreviated (Mon, Tue, Wed...)
            _buildCell(
              row.day.length >= 3 ? row.day.substring(0, 3) : row.day,
              _kColumns[1].$2,
              isExpanded: isExpanded,
              onTap: toggleRow,
            ),
            // Employee Name
            _buildCell(
              row.employeeName.isNotEmpty ? row.employeeName : '-',
              _kColumns[2].$2,
              isExpanded: isExpanded,
              onTap: toggleRow,
            ),
            _buildCell(
              row.shiftStart,
              _kColumns[3].$2,
              isExpanded: isExpanded,
              onTap: toggleRow,
            ),
            _buildCell(
              row.shiftEnd,
              _kColumns[4].$2,
              isExpanded: isExpanded,
              onTap: toggleRow,
            ),
            _buildCell(
              row.shiftDuration,
              _kColumns[5].$2,
              isExpanded: isExpanded,
              onTap: toggleRow,
            ),
            _buildCell(
              row.shiftLocation,
              _kColumns[6].$2,
              isExpanded: isExpanded,
              onTap: toggleRow,
            ),
            _buildCell(
              row.liveIn,
              _kColumns[7].$2,
              isExpanded: isExpanded,
              onTap: toggleRow,
            ),
            _buildCell(
              row.liveOut,
              _kColumns[8].$2,
              isExpanded: isExpanded,
              onTap: toggleRow,
            ),
            _buildCell(
              row.liveTotal,
              _kColumns[9].$2,
              isExpanded: isExpanded,
              onTap: toggleRow,
            ),
            _buildCell(
              row.liveShift,
              _kColumns[10].$2,
              isExpanded: isExpanded,
              onTap: toggleRow,
              bgColor: Colors.red.withValues(alpha: 0.1),
            ),
            _buildCell(
              row.dutyShortage,
              _kColumns[11].$2,
              isExpanded: isExpanded,
              onTap: toggleRow,
              color: Colors.red.shade700,
            ),
            _buildCell(
              row.lateDuration,
              _kColumns[12].$2,
              isExpanded: isExpanded,
              onTap: toggleRow,
              color: Colors.red.shade700,
            ),
            _buildCell(
              row.actualLocation,
              _kColumns[13].$2,
              isExpanded: isExpanded,
              onTap: toggleRow,
            ),
            _buildCell(
              row.locationMismatch,
              _kColumns[14].$2,
              isExpanded: isExpanded,
              onTap: toggleRow,
              bgColor: row.locationMismatch.toLowerCase() == 'no'
                  ? Colors.green.withValues(alpha: 0.1)
                  : row.locationMismatch.toLowerCase() == 'yes'
                  ? Colors.red.withValues(alpha: 0.1)
                  : null,
              color: row.locationMismatch.toLowerCase() == 'no'
                  ? Colors.green.shade700
                  : row.locationMismatch.toLowerCase() == 'yes'
                  ? Colors.red.shade700
                  : null,
            ),
            // Action column
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: _kColumns[15].$2,
                constraints: const BoxConstraints(minHeight: 28),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => controller.fetchAttendanceBreakdown(
                    row.employeeId,
                    row.rawDate,
                    row.employeeName,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'View',
                      style: AppTextStyle.style_10_500(color: Colors.blue),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    });
  }

  Widget _buildCell(
    String text,
    double width, {
    bool isLast = false,
    Color? color,
    Color? bgColor,
    bool isExpanded = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: width,
        constraints: const BoxConstraints(minHeight: 28),
        padding: EdgeInsets.symmetric(
          horizontal: 4.w,
          vertical: isExpanded ? 6.h : 4.h,
        ),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: bgColor,
          border: isLast
              ? null
              : Border(right: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Text(
          text,
          style: AppTextStyle.style_12_400(color: color ?? AppColors.grey900),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
