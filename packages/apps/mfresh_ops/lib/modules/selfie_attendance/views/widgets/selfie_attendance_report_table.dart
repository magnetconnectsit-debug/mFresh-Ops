// region Imports
import 'dart:math';

import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_table.dart';
import 'package:core/widgets/app_table_pagination.dart';
import 'package:core/widgets/custom_app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/selfie_attendance/selfie_attendance_report_model.dart';
import 'package:mfresh_ops/modules/selfie_attendance/controllers/selfie_attendance_controller.dart';
// endregion

// region View
class SelfieAttendanceReportTable extends StatelessWidget {
  const SelfieAttendanceReportTable({super.key});

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SelfieAttendanceController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return Container(
          height: 300.h,
          alignment: Alignment.center,
          child: const CustomAppLoader(),
        );
      }

      final items = controller.items;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTableCard(context, controller, items),
          SizedBox(height: 12.h),
          _buildPagination(controller),
        ],
      );
    });
  }
  // endregion

  // region Section Builders
  Widget _buildTableCard(
    BuildContext context,
    SelfieAttendanceController controller,
    List<SelfieAttendanceItem> items,
  ) {
    return AppCommonTable<SelfieAttendanceItem>(
      items: items,
      headingRowColor: AppColors.blue50,
      headingRowHeight: 24.h,
      cellVerticalPadding: 2.h,
      headingTextStyle: AppTextStyle.style_11_700(color: AppColors.black),
      dataTextStyle: AppTextStyle.style_11_400(color: AppColors.black87),
      borderColor: AppColors.borderColor,
      rowDecorationBuilder: (item, index) {
        final borderColor = _parseHexColor(item.rowBorderColor);
        if (borderColor != null) {
          return BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: borderColor, width: 1.5.r),
          );
        }
        return BoxDecoration(
          color: AppColors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.borderColor, width: 1.0.r),
          ),
        );
      },
      columns: _buildColumns(context, controller),
      onSort: (columnKey, sortOrder) {
        controller.sortBy(columnKey);
      },
      emptyWidget: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Center(
          child: Text(
            'No selfie attendance records found.',
            style: AppTextStyle.style_13_400(color: AppColors.grey500),
          ),
        ),
      ),
    );
  }

  Color? _parseHexColor(String? hexString) {
    if (hexString == null || hexString.trim().isEmpty) return null;
    var hex = hexString.replaceAll('#', '').trim();
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    if (hex.length == 8) {
      final val = int.tryParse(hex, radix: 16);
      if (val != null) return Color(val);
    }
    return null;
  }

  List<AppTableColumn<SelfieAttendanceItem>> _buildColumns(
    BuildContext context,
    SelfieAttendanceController controller,
  ) {
    return [
      AppTableColumn<SelfieAttendanceItem>(
        key: 'employee',
        title: 'Employee',
        width: 130.w,
        alignment: Alignment.centerLeft,
        sortable: true,
        cellBuilder: (context, item, index, isExpanded) {
          final displayName = item.userNameWithRole ?? item.userName;
          return GestureDetector(
            onTap: () => _navigateToDetail(controller, item),
            child: Text(
              displayName,
              style: AppTextStyle.style_11_500(color: AppColors.blue500),
              maxLines: isExpanded ? null : 1,
              overflow:
                  isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          );
        },
      ),
      AppTableColumn<SelfieAttendanceItem>(
        key: 'date',
        title: 'Date',
        width: 85.w,
        alignment: Alignment.centerLeft,
        sortable: true,
        cellBuilder: (context, item, index, isExpanded) {
          return Text(
            item.date,
            style: AppTextStyle.style_11_400(color: AppColors.black87),
            textAlign: TextAlign.left,
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          );
        },
      ),
      AppTableColumn<SelfieAttendanceItem>(
        key: 'unit',
        title: 'Unit(s)',
        width: 70.w,
        alignment: Alignment.centerLeft,
        sortable: true,
        cellBuilder: (context, item, index, isExpanded) {
          return Text(
            item.units,
            style: AppTextStyle.style_11_400(color: AppColors.black87),
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          );
        },
      ),
      AppTableColumn<SelfieAttendanceItem>(
        key: 'first_in',
        title: 'First In',
        width: 70.w,
        alignment: Alignment.center,
        sortable: true,
        cellBuilder: (context, item, index, isExpanded) {
          return Text(
            item.firstIn,
            style: AppTextStyle.style_11_400(color: AppColors.black87),
            textAlign: TextAlign.center,
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          );
        },
      ),
      AppTableColumn<SelfieAttendanceItem>(
        key: 'last_out',
        title: 'Last Out',
        width: 77.w,
        alignment: Alignment.center,
        sortable: true,
        cellBuilder: (context, item, index, isExpanded) {
          return Text(
            item.lastOut,
            style: AppTextStyle.style_11_400(color: AppColors.black87),
            textAlign: TextAlign.center,
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          );
        },
      ),
      AppTableColumn<SelfieAttendanceItem>(
        key: 'total_duration',
        title: 'Total Duration',
        width: 115.w,
        alignment: Alignment.center,
        sortable: true,
        cellBuilder: (context, item, index, isExpanded) {
          return Text(
            item.totalDuration,
            style: AppTextStyle.style_11_400(color: AppColors.black87),
            textAlign: TextAlign.center,
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          );
        },
      ),
      AppTableColumn<SelfieAttendanceItem>(
        key: 'break',
        title: 'Break',
        width: 65.w,
        alignment: Alignment.center,
        sortable: true,
        cellColorGetter: (_) => AppColors.yellow.withValues(alpha: 0.15),
        cellBuilder: (context, item, index, isExpanded) {
          return Text(
            item.breakDuration,
            style: AppTextStyle.style_11_500(color: AppColors.orange),
            textAlign: TextAlign.center,
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          );
        },
      ),
      AppTableColumn<SelfieAttendanceItem>(
        key: 'actual_duration',
        title: 'Actual Duration',
        width: 120.w,
        alignment: Alignment.center,
        sortable: true,
        cellBuilder: (context, item, index, isExpanded) {
          return Text(
            item.actualDuration,
            style: AppTextStyle.style_11_400(color: AppColors.black87),
            textAlign: TextAlign.center,
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          );
        },
      ),
      AppTableColumn<SelfieAttendanceItem>(
        key: 'sessions',
        title: 'Sessions',
        width: 67.w,
        alignment: Alignment.centerLeft,
        sortable: false,
        cellBuilder: (context, item, index, isExpanded) {
          return Text(
            '${item.totalSessions}',
            style: AppTextStyle.style_11_400(color: AppColors.black87),
            textAlign: TextAlign.center,
          );
        },
      ),
    ];
  }

  Widget _buildPagination(SelfieAttendanceController controller) {
    final totalItems = controller.totalRecords.value;
    final totalPages = controller.lastPage.value;
    final currentPage = controller.currentPage.value;
    final perPage = controller.perPage.value;

    if (totalItems <= 0 && totalPages <= 1) {
      return const SizedBox.shrink();
    }

    final startItem = totalItems == 0 ? 0 : ((currentPage - 1) * perPage) + 1;
    final endItem = min(currentPage * perPage, totalItems);

    return AppTablePagination(
      startItem: startItem,
      endItem: endItem,
      totalItems: totalItems,
      currentPage: currentPage,
      totalPages: totalPages,
      itemUnitName: 'records',
      onPageChanged: (page) => controller.goToPage(page),
      onPreviousPage: () => controller.prevPage(),
      onNextPage: () => controller.nextPage(),
    );
  }
  // endregion

  // region Dialogs & Action Handlers
  void _navigateToDetail(
    SelfieAttendanceController controller,
    SelfieAttendanceItem item,
  ) {
    controller.openDetail(item);
  }

  // endregion
}

// endregion
