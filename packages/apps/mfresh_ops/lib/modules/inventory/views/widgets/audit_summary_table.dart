// region Imports
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mfresh_ops/data/models/inventory/audit_report_model.dart';
// endregion

// region View
class AuditSummaryTable extends StatefulWidget {
  final List<AuditUnitSummary> unitList;
  final bool initiallyExpanded;

  const AuditSummaryTable({
    super.key,
    required this.unitList,
    this.initiallyExpanded = true,
  });

  @override
  State<AuditSummaryTable> createState() => _AuditSummaryTableState();
}
// endregion

// region State
class _AuditSummaryTableState extends State<AuditSummaryTable> {
  // region State Variables
  late bool _isExpanded;
  // endregion

  // region Lifecycle Methods
  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.grey50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Expandable Header Section
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(6.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          'Audit Summary',
                          style: AppTextStyle.style_14_700(
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        if (widget.unitList.isNotEmpty) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5EEF8),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              '${widget.unitList.length} Units',
                              style: AppTextStyle.style_10_600(
                                color: const Color(0xFF009BD9),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20.r,
                    color: AppColors.grey600,
                  ),
                ],
              ),
            ),
          ),

          // Collapsible Table Section
          if (_isExpanded) ...[
            const Divider(height: 1, thickness: 1, color: AppColors.grey50),
            Padding(
              padding: EdgeInsets.all(12.r),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: widget.unitList.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Center(
                          child: Text(
                            'No audit summary records found.',
                            style: AppTextStyle.style_12_400(
                              color: AppColors.grey400,
                            ),
                          ),
                        ),
                      )
                    : _buildTable(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
  // endregion

  // region Table Builders
  Widget _buildTable(BuildContext context) {
    final columns = [
      AppTableColumn<AuditUnitSummary>(
        key: 'Unit',
        title: 'Unit',
        width: 55.w,
        cellBuilder: (context, item, index, isExpanded) {
          return Text(
            item.unitName,
            style: AppTextStyle.style_11_500(color: AppColors.grey900),
            maxLines: isExpanded ? null : 1,
            overflow:
                isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          );
        },
      ),
      AppTableColumn<AuditUnitSummary>(
        key: 'Audit No',
        title: 'Audit No',
        width: 85.w,
        cellBuilder: (context, item, index, isExpanded) {
          return Text(
            item.auditNumber,
            style: AppTextStyle.style_11_400(color: AppColors.grey900),
            maxLines: isExpanded ? null : 1,
            overflow:
                isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          );
        },
      ),
      AppTableColumn<AuditUnitSummary>(
        key: 'Audit Date',
        title: 'Audit Date',
        width: 140.w,
        cellBuilder: (context, item, index, isExpanded) {
          return Text(
            item.auditDateDisplay.isNotEmpty
                ? item.auditDateDisplay
                : item.auditDate,
            style: AppTextStyle.style_11_400(color: AppColors.grey900),
            maxLines: isExpanded ? null : 1,
            overflow:
                isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          );
        },
      ),
      AppTableColumn<AuditUnitSummary>(
        key: 'Audited By',
        title: 'Audited By',
        width: 110.w,
        cellBuilder: (context, item, index, isExpanded) {
          return Text(
            item.auditorName,
            style: AppTextStyle.style_11_500(color: AppColors.grey900),
            maxLines: isExpanded ? null : 1,
            overflow:
                isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          );
        },
      ),
    ];

    return AppCommonTable<AuditUnitSummary>(
      items: widget.unitList,
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
    );
  }
  // endregion
}
// endregion
