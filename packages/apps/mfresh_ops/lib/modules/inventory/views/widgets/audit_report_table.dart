import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:core/widgets/app_common_table.dart';
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
    return Obx(() {
      final isTableLoading = controller.isLoading.value;
      final sortedList = controller.sortedAuditList;

      if (sortedList.isEmpty && !isTableLoading) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
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

      final expandedIndices = <int>{};
      for (int i = 0; i < itemsToRender.length; i++) {
        if (controller.expandedRowIds.contains(itemsToRender[i].id)) {
          expandedIndices.add(i);
        }
      }

      final columns = [
        AppTableColumn<AuditReportEntry>(
          key: 'Audit Number',
          title: 'Audit No',
          width: 90.w,
          cellBuilder: (context, entry, index, isExpanded) {
            return GestureDetector(
              onTap: () => _navigateToDetail(controller, entry),
              child: Text(
                entry.auditNumber,
                style: AppTextStyle.style_11_700(
                  color: const Color(0xFF009BD9),
                ),
                maxLines: isExpanded ? null : 1,
                overflow:
                    isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
            );
          },
        ),
        AppTableColumn<AuditReportEntry>(
          key: 'Unit',
          title: 'Unit',
          width: 68.w,
          valueGetter: (entry) => entry.unitName,
        ),
        AppTableColumn<AuditReportEntry>(
          key: 'Audit Date',
          title: 'Audit Date',
          width: 95.w,
          valueGetter: (entry) => AppDateUtils.formatToShortOrdinalDate(
            entry.auditDateDisplay.isNotEmpty
                ? entry.auditDateDisplay
                : entry.auditDate,
          ),
        ),
        AppTableColumn<AuditReportEntry>(
          key: 'Audited By',
          title: 'Audited By',
          width: 100.w,
          valueGetter: (entry) => entry.auditorName,
        ),
      ];

      final currentSortKey = controller.sortColumn.value;
      final currentSortOrder = currentSortKey.isEmpty
          ? AppTableSortOrder.none
          : (controller.sortAscending.value
              ? AppTableSortOrder.ascending
              : AppTableSortOrder.descending);

      return Skeletonizer(
        enabled: isTableLoading,
        child: AppCommonTable<AuditReportEntry>(
          items: itemsToRender,
          columns: columns,
          currentSortColumn: currentSortKey,
          currentSortOrder: currentSortOrder,
          onSort: (columnKey, sortOrder) {
            controller.sortBy(columnKey);
          },
          expandedRowIndices: expandedIndices,
          onRowExpandToggle: (index, isExpanded) {
            if (index >= 0 && index < itemsToRender.length) {
              controller.toggleRowExpansion(itemsToRender[index].id);
            }
          },
          headingRowColor: const Color(0xFFDCE5F8),
          borderColor: Colors.grey.shade300,
        ),
      );
    });
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
