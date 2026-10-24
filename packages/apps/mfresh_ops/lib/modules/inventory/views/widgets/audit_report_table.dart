// region Imports
import 'dart:math';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_table.dart';
import 'package:core/widgets/app_table_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/inventory/audit_report_model.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../controllers/audit_report_controller.dart';
import '../audit_report_detail_screen.dart';
// endregion

// region View
class AuditReportTable extends StatelessWidget {
  const AuditReportTable({super.key});

  // region Main Build
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
  // endregion

  // region Section Builders
  Widget _buildTableCard(AuditReportController controller) {
    return Obx(() {
      final isTableLoading = controller.isLoading.value;
      final sortedList = controller.sortedAuditList;

      if (sortedList.isEmpty && !isTableLoading) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(color: AppColors.grey50),
          ),
          padding: EdgeInsets.all(24.r),
          child: Center(
            child: Text(
              'No inventory audit records found.',
              style: AppTextStyle.style_14_400(color: AppColors.grey400),
            ),
          ),
        );
      }

      final itemsToRender = isTableLoading
          ? List.generate(
              10,
              (index) => AuditReportEntry(
                id: index,
                representativeId: index,
                auditNumber: 'AUD-00000$index',
                auditDay: '2026-10-22',
                auditDateDisplay: '22-Oct-2026',
                dayName: 'Thursday',
                auditCount: 3,
                unitCount: 3,
                unitNames: 'm2, m3, m4',
                units: const [],
                unitId: 0,
                unitName: 'm2',
                districtName: '',
                imageUrl: '',
                auditorId: 0,
                auditorName: 'Auditor Name',
                auditDate: '2026-10-22',
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
        // AppTableColumn<AuditReportEntry>(
        //   key: 'Audit No',
        //   title: 'Audit No',
        //   width: 100.w,
        //   cellBuilder: (context, entry, index, isExpanded) {
        //     return GestureDetector(
        //       onTap: () => _navigateToDetail(controller, entry),
        //       child: Text(
        //         entry.auditNumber,
        //         style: AppTextStyle.style_12_500(
        //           color: AppColors.grey900,
        //         ),
        //         maxLines: isExpanded ? null : 1,
        //         overflow:
        //             isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        //       ),
        //     );
        //   },
        // ),
        AppTableColumn<AuditReportEntry>(
          key: 'Audit Date',
          title: 'Audit Date',
          width: 100.w,
          cellBuilder: (context, entry, index, isExpanded) {
            return GestureDetector(
                            onTap: () => _navigateToDetail(controller, entry),

              child: Text(
                entry.auditDateDisplay.isNotEmpty
                    ? entry.auditDateDisplay
                    : entry.auditDay,
                style: AppTextStyle.style_12_500(color: AppColors.blue500),
                maxLines: isExpanded ? null : 1,
                overflow:
                    isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
            );
          },
        ),
        AppTableColumn<AuditReportEntry>(
          key: 'Units',
          title: 'Units',
          width: 150.w,
          cellBuilder: (context, entry, index, isExpanded) {
            return Text(
              entry.unitNames,
              style: AppTextStyle.style_12_400(color: AppColors.grey900),
              maxLines: isExpanded ? null : 1,
              overflow:
                  isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            );
          },
        ),
        AppTableColumn<AuditReportEntry>(
          key: 'Total Units',
          title: 'Total Units',
          width: 85.w,
          alignment: Alignment.center,
          cellBuilder: (context, entry, index, isExpanded) {
            return Center(
              child: Text(
                '${entry.unitCount}',
                style: AppTextStyle.style_12_400(color: AppColors.grey900),
              ),
            );
          },
        ),
        AppTableColumn<AuditReportEntry>(
          key: 'Audit Records',
          title: 'Audit Records',
          width: 95.w,
          alignment: Alignment.center,
          cellBuilder: (context, entry, index, isExpanded) {
            return Center(
              child: Text(
                '${entry.auditCount}',
                style: AppTextStyle.style_12_400(color: AppColors.grey900),
              ),
            );
          },
        ),
      ];

      final currentSortKey = controller.sortColumn.value;
      final currentSortOrder = currentSortKey.isEmpty
          ? AppTableSortOrder.none
          : (controller.sortAscending.value
              ? AppTableSortOrder.ascending
              : AppTableSortOrder.descending);

      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: AppColors.grey50),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: Skeletonizer(
            enabled: isTableLoading,
            child: AppCommonTable<AuditReportEntry>(
              items: itemsToRender,
              columns: columns,
              currentSortColumn: currentSortKey,
              currentSortOrder: currentSortOrder,
              onSort: (columnKey, sortOrder) {
                controller.sortBy(columnKey);
              },
              onRowTap: (entry, index) => _navigateToDetail(controller, entry),
              expandedRowIndices: expandedIndices,
              onRowExpandToggle: (index, isExpanded) {
                if (index >= 0 && index < itemsToRender.length) {
                  controller.toggleRowExpansion(itemsToRender[index].id);
                }
              },
              headingRowColor: const Color(0xFF009BD9),
              headingTextStyle:
                  AppTextStyle.style_12_700(color: AppColors.white),
              headingBorderColor: AppColors.white,
              borderColor: AppColors.grey50,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPagination(AuditReportController controller) {
    return Obx(() {
      final totalItems = controller.totalCount.value;
      final totalPages = controller.totalPages.value;
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
    });
  }
  // endregion

  // region Dialogs & Action Handlers
  void _navigateToDetail(
    AuditReportController controller,
    AuditReportEntry entry,
  ) {
    controller.selectedAuditEntry.value = entry;
    final targetId =
        entry.representativeId != 0 ? entry.representativeId : entry.id;
    Get.to(
      () => AuditReportDetailScreen(auditId: targetId),
      arguments: {'auditId': targetId},
    );
  }
  // endregion
}
// endregion
