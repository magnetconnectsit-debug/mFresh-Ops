// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mfresh_ops/data/models/inventory/audit_report_model.dart';
// endregion

// region View
class AuditAdditionalItemsTable extends StatelessWidget {
  final AuditDetailData detail;

  const AuditAdditionalItemsTable({
    super.key,
    required this.detail,
  });

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.grey50),
      ),
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Header
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text(
              'Additional / Unlisted Items',
              style: AppTextStyle.style_14_700(
                color: const Color(0xFF1E293B),
              ),
            ),
          ),

          // Table Container
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: _buildTable(context),
          ),
        ],
      ),
    );
  }
  // endregion

  // region Section Builders
  Widget _buildTable(BuildContext context) {
    final columns = <AppTableColumn<AuditExtraItem>>[
      AppTableColumn<AuditExtraItem>(
        key: 'Item',
        title: 'Item',
        width: 170.w,
        cellBuilder: (context, item, index, isExpanded) {
          return Text(
            item.name,
            style: AppTextStyle.style_12_500(color: AppColors.grey900),
            maxLines: isExpanded ? null : 1,
            overflow:
                isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          );
        },
      ),
      AppTableColumn<AuditExtraItem>(
        key: 'Measurement Unit',
        title: 'Measurement Unit',
        width: 140.w,
        alignment: Alignment.center,
        cellBuilder: (context, item, index, isExpanded) {
          return Center(
            child: Text(
              item.unit,
              style: AppTextStyle.style_12_400(color: AppColors.grey900),
            ),
          );
        },
      ),
      // Dynamic Unit Actual Qty Columns
      ...detail.unitList.map((unit) {
        return AppTableColumn<AuditExtraItem>(
          key: '${unit.unitName} Actual Qty',
          title: '${unit.unitName} Actual Qty',
          width: 130.w,
          alignment: Alignment.center,
          cellBuilder: (context, item, index, isExpanded) {
            final rawDisplay =
                item.actualPerUnitDisplay[unit.auditId.toString()] ??
                    item.actualPerUnitDisplay[unit.id.toString()] ??
                    item.actualPerUnitDisplay[unit.unitId.toString()];
            final numVal = item.actualPerUnit[unit.auditId.toString()] ??
                item.actualPerUnit[unit.id.toString()] ??
                item.actualPerUnit[unit.unitId.toString()] ??
                0;
            final display = (rawDisplay != null && rawDisplay.isNotEmpty)
                ? rawDisplay
                : (numVal % 1 == 0
                    ? numVal.toInt().toString()
                    : numVal.toString());

            return Center(
              child: Text(
                display,
                style: AppTextStyle.style_12_400(color: AppColors.grey900),
              ),
            );
          },
        );
      }),
      // Total Actual Qty Column
      AppTableColumn<AuditExtraItem>(
        key: 'Total Actual Qty',
        title: 'Total Actual Qty',
        width: 140.w,
        alignment: Alignment.center,
        cellBuilder: (context, item, index, isExpanded) {
          final display = item.totalActualDisplay.isNotEmpty
              ? item.totalActualDisplay
              : (item.totalActual % 1 == 0
                  ? item.totalActual.toInt().toString()
                  : item.totalActual.toString());

          return Center(
            child: Text(
              display,
              style: AppTextStyle.style_12_600(color: AppColors.grey900),
            ),
          );
        },
      ),
    ];

    return AppCommonTable<AuditExtraItem>(
      items: detail.extra,
      columns: columns,
      headingRowHeight: 22.h,
      cellVerticalPadding: 1.5.h,
      cellHorizontalPadding: 6.w,
      headingRowColor: const Color(0xFFE5EEF8),
      headingTextStyle: AppTextStyle.style_11_600(
        color: const Color(0xFF1E293B),
      ),
      dataTextStyle: AppTextStyle.style_11_400(color: AppColors.grey900),
      headingBorderColor: const Color(0xFFCBD5E1),
      borderColor: const Color(0xFFE2E8F0),
      emptyWidget: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Center(
          child: Text(
            'No additional items found.',
            style: AppTextStyle.style_12_400(color: AppColors.grey500),
          ),
        ),
      ),
    );
  }
  // endregion
}
// endregion
