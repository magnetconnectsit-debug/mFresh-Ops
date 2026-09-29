import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import '../../controllers/audit_report_controller.dart';
import '../audit_report_detail_screen.dart';

class AuditReportTable extends StatelessWidget {
  const AuditReportTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuditReportController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTableCard(controller),
        SizedBox(height: 12.h),
        _buildPagination(controller),
      ],
    );
  }

  // ── Main Audit Reports Data Table Card ─────────────────────────────────────

  Widget _buildTableCard(AuditReportController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Obx(() {
            final isTableLoading = controller.isLoading.value;
            final sortedList = controller.sortedAuditList;

            if (sortedList.isEmpty && !isTableLoading) {
              return Padding(
                padding: EdgeInsets.all(20.r),
                child: Center(
                  child: Text(
                    'No inventory audit records found.',
                    style: AppTextStyle.style_14_400(color: AppColors.grey300),
                  ),
                ),
              );
            }

            final itemsToRender = isTableLoading
                ? List.generate(
                    10,
                    (index) => AuditReportEntry(
                      id: index,
                      auditNumber: 'AUD-LOADING-$index',
                      unitId: 0,
                      unitName: 'Loading Unit',
                      districtName: '',
                      imageUrl: '',
                      auditorId: 0,
                      auditorName: 'Auditor Name',
                      auditDate: '2026-01-01 00:00:00',
                      auditDateDisplay: '01 Jan 2026',
                      auditDay: 'Thu',
                      createdAt: '',
                    ),
                  )
                : sortedList;

            final columnWidths = {
              0: FixedColumnWidth(90.w),
              1: FixedColumnWidth(70.w),
              2: FixedColumnWidth(90.w),
              3: FixedColumnWidth(85.w),
            };

            return Skeletonizer(
              enabled: isTableLoading,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sticky Header Row matching Store/Unit Inventory Table header
                  Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    border: TableBorder.symmetric(
                      inside: BorderSide(color: Colors.grey.shade300),
                    ),
                    columnWidths: columnWidths,
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F1F8),
                        ),
                        children: [
                          _buildHeaderCell(
                            controller,
                            'Audit No',
                            sortKey: 'Audit Number',
                          ),
                          _buildHeaderCell(controller, 'Unit', sortKey: 'Unit'),
                          _buildHeaderCell(
                            controller,
                            'Audit Date',
                            sortKey: 'Audit Date',
                          ),
                          _buildHeaderCell(
                            controller,
                            'Audited By',
                            sortKey: 'Audited By',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE0E0E0),
                  ),
                  // Table Data Rows
                  Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    border: TableBorder.symmetric(
                      inside: BorderSide(color: Colors.grey.shade300),
                    ),
                    columnWidths: columnWidths,
                    children: List.generate(itemsToRender.length, (index) {
                      final entry = itemsToRender[index];
                      final isExpanded = controller.expandedRowIds.contains(
                        entry.id,
                      );

                      return TableRow(
                        children: [
                          // Audit Number (Clickable Link)
                          GestureDetector(
                            onTap: () => _navigateToDetail(controller, entry),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 6.h,
                              ),
                              child: Text(
                                entry.auditNumber,
                                style: AppTextStyle.style_11_700(
                                  color: const Color(0xFF009BD9),
                                ),
                                maxLines: isExpanded ? null : 1,
                                overflow: isExpanded
                                    ? null
                                    : TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          // Unit
                          _buildDataCell(
                            entry.unitName,
                            isExpanded,
                            () => controller.toggleRowExpansion(entry.id),
                          ),
                          // Audit Date
                          _buildDataCell(
                            AppDateUtils.formatToShortOrdinalDate(
                              entry.auditDateDisplay.isNotEmpty
                                  ? entry.auditDateDisplay
                                  : entry.auditDate,
                            ),
                            isExpanded,
                            () => controller.toggleRowExpansion(entry.id),
                          ),
                          // Audited By
                          _buildDataCell(
                            entry.auditorName,
                            isExpanded,
                            () => controller.toggleRowExpansion(entry.id),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // Header Cell matching Store/Unit Inventory Table header cell & sorting logic
  Widget _buildHeaderCell(
    AuditReportController controller,
    String text, {
    String? sortKey,
  }) {
    final key = sortKey ?? text;
    final isSorted = controller.sortColumn.value == key;
    final isAsc = controller.sortAscending.value;

    return InkWell(
      onTap: () => controller.sortBy(key),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                text,
                style: AppTextStyle.style_11_700(color: AppColors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSorted) ...[
              SizedBox(width: 2.w),
              Icon(
                isAsc ? Icons.arrow_upward : Icons.arrow_downward,
                size: 11.r,
                color: AppColors.black,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataCell(
    String text,
    bool isExpanded,
    VoidCallback onTap, {
    Color? textColor,
    Color? bgColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: bgColor,
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
        child: Text(
          text,
          style: AppTextStyle.style_11_500(color: textColor ?? AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
    );
  }

  void _navigateToDetail(
    AuditReportController controller,
    AuditReportEntry entry,
  ) {
    controller.selectedAuditEntry.value = entry;
    Get.to(
      () => const AuditReportDetailScreen(),
      arguments: {'auditId': entry.id},
    );
  }

  // ── Pagination Controls matching Store/Unit Inventory Table ─────────────────────

  Widget _buildPagination(AuditReportController controller) {
    return Obx(() {
      if (controller.totalPages.value <= 1) return const SizedBox.shrink();

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPaginationButton('←', false, controller.prevPage),
            ...List.generate(controller.totalPages.value, (index) {
              final pageNumber = index + 1;
              return _buildPaginationButton(
                '$pageNumber',
                controller.currentPage.value == pageNumber,
                () => controller.fetchAuditReport(),
              );
            }),
            _buildPaginationButton('→', false, controller.nextPage),
          ],
        ),
      );
    });
  }

  Widget _buildPaginationButton(
    String text,
    bool isActive,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        margin: EdgeInsets.only(left: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade600 : const Color(0xFFF1F5F9),
          border: Border.all(
            color: isActive ? Colors.blue.shade600 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          text,
          style: AppTextStyle.style_12_500(
            color: isActive ? Colors.white : Colors.blue.shade600,
          ),
        ),
      ),
    );
  }
}
