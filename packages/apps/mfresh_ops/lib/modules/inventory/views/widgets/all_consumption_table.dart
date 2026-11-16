import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_table.dart';
import 'package:core/widgets/app_table_pagination.dart';
import 'package:mfresh_ops/data/models/inventory/consumption_item_model.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/inventory/controllers/consumption_controller.dart';

class AllConsumptionTable extends StatefulWidget {
  const AllConsumptionTable({super.key});

  @override
  State<AllConsumptionTable> createState() => _AllConsumptionTableState();
}

class _AllConsumptionTableState extends State<AllConsumptionTable> {
  final Set<int> _expandedRowIndices = {};

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConsumptionController>();

    return Obx(() {
      final items = controller.sortedItems;
      final hasReverse = Get.find<AuthRepository>()
          .rxUserPermissions
          .contains('reverse_consumption');
      final isLoading = controller.isLoading.value;

      final sortColumn = controller.sortColumn.value;
      final isAsc = controller.sortAscending.value;
      final currentSortOrder = sortColumn.isEmpty
          ? AppTableSortOrder.none
          : (isAsc ? AppTableSortOrder.ascending : AppTableSortOrder.descending);

      final startItem = controller.totalEntries.value == 0
          ? 0
          : ((controller.currentPage.value - 1) * controller.perPage.value) + 1;
      final endItem = (controller.currentPage.value * controller.perPage.value)
          .clamp(0, controller.totalEntries.value);

      final List<AppTableColumn<ConsumptionItemModel>> columns = [
        if (hasReverse)
          AppTableColumn<ConsumptionItemModel>(
            key: 'action',
            title: 'Action',
            width: 85.w,
            sortable: false,
            cellBuilder: (context, item, index, isExpanded) {
              final isReversed = item.isReversed == 1;
              return AppCommonButton(
                text: isReversed ? 'Reversed' : 'Reverse',
                height: 20.h,
                buttonColor: isReversed ? AppColors.black200 : AppColors.red,
                onPressed: isReversed
                    ? null
                    : () => _showReverseDialog(context, controller, item),
              );
            },
          ),
        AppTableColumn<ConsumptionItemModel>(
          key: 'Consumed On',
          title: 'Used On',
          width: 85.w,
          valueGetter: (item) => item.consumedOn,
        ),
        AppTableColumn<ConsumptionItemModel>(
          key: 'State',
          title: 'State',
          width: 60.w,
          valueGetter: (item) => item.state,
        ),
        AppTableColumn<ConsumptionItemModel>(
          key: 'District',
          title: 'District',
          width: 70.w,
          valueGetter: (item) => item.district,
        ),
        AppTableColumn<ConsumptionItemModel>(
          key: 'Source Type',
          title: 'Source Type',
          width: 100.w,
          valueGetter: (item) => item.sourceType,
        ),
        AppTableColumn<ConsumptionItemModel>(
          key: 'Source',
          title: 'Source',
          width: 75.w,
          valueGetter: (item) => item.source,
        ),
        AppTableColumn<ConsumptionItemModel>(
          key: 'Category',
          title: 'Category',
          width: 110.w,
          valueGetter: (item) => item.category,
        ),
        AppTableColumn<ConsumptionItemModel>(
          key: 'Item',
          title: 'Item',
          width: 125.w,
          valueGetter: (item) => item.item,
        ),
        AppTableColumn<ConsumptionItemModel>(
          key: 'Consumed Qty',
          title: 'Used Qty',
          width: 85.w,
          cellColorGetter: (item) => AppColors.yellow50,
          valueGetter: (item) => item.consumedQty,
        ),
        AppTableColumn<ConsumptionItemModel>(
          key: 'M_Unit',
          title: 'M_Unit',
          width: 75.w,
          valueGetter: (item) => item.mUnit,
        ),
        AppTableColumn<ConsumptionItemModel>(
          key: 'Created By',
          title: 'Created By',
          width: 110.w,
          valueGetter: (item) => item.createdBy,
        ),
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Table
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: AppCommonTable<ConsumptionItemModel>(
              items: items,
              columns: columns,
              currentSortColumn: sortColumn,
              currentSortOrder: currentSortOrder,
              onSort: (columnKey, sortOrder) => controller.sortBy(columnKey),
              expandedRowIndices: _expandedRowIndices,
              onRowExpandToggle: (index, isExpanded) {
                setState(() {
                  if (isExpanded) {
                    _expandedRowIndices.add(index);
                  } else {
                    _expandedRowIndices.remove(index);
                  }
                });
              },
              isLoading: isLoading,
              headingRowColor: AppColors.blue50,
              headingTextStyle: AppTextStyle.style_11_700(color: AppColors.black),
              dataTextStyle: AppTextStyle.style_11_500(color: AppColors.black),
              borderColor: AppColors.borderColor,
              headingRowHeight: 20.h,
              cellVerticalPadding: 1.h,
              cellHorizontalPadding: 4.w,
              emptyText: 'No usage data found.',
            ),
          ),
          SizedBox(height: 8.h),

          // Pagination Bar
          if (!isLoading && controller.totalEntries.value > 0)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: AppTablePagination(
                startItem: startItem,
                endItem: endItem,
                totalItems: controller.totalEntries.value,
                currentPage: controller.currentPage.value,
                totalPages: controller.totalPages.value,
                onPageChanged: (page) => controller.goToPage(page),
                onPreviousPage: controller.previousPage,
                onNextPage: controller.nextPage,
              ),
            ),
        ],
      );
    });
  }

  void _showReverseDialog(
    BuildContext context,
    ConsumptionController controller,
    ConsumptionItemModel item,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60.r,
                    height: 60.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.warning,
                        width: 3.w,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '!',
                        style: TextStyle(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Confirm Reverse',
                    style: AppTextStyle.style_16_700(color: AppColors.black),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'This will reverse the consumption and restore stock.',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.style_12_400(color: AppColors.grey500),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppCommonButton(
                        text: 'Yes, Reverse it!',
                        buttonColor: AppColors.red,
                        height: 26.h,
                        onPressed: () {
                          controller.reverseConsumption(item);
                          Get.back();
                        },
                      ),
                      SizedBox(width: 12.w),
                      AppCommonButton(
                        text: 'Cancel',
                        buttonColor: AppColors.black200,
                        height: 26.h,
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
