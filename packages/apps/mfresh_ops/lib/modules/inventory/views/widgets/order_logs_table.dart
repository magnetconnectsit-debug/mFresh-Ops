import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_table.dart';
import 'package:core/widgets/app_table_pagination.dart';
import 'package:mfresh_ops/data/models/inventory/inventory_order_receive_log_model.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_order_logs_controller.dart';

class OrderLogsTable extends StatefulWidget {
  const OrderLogsTable({super.key});

  @override
  State<OrderLogsTable> createState() => _OrderLogsTableState();
}

class _OrderLogsTableState extends State<OrderLogsTable> {
  final Set<int> _expandedRowIndices = {};

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InventoryOrderLogsController>();

    return Obx(() {
      final isLoading = controller.isLoading.value;
      final totalFiltered = controller.filteredLogs.length;
      final paginatedList = controller.paginatedLogs;

      final sortColumn = controller.sortColumn.value;
      final isAsc = controller.sortAscending.value;
      final currentSortOrder = sortColumn.isEmpty
          ? AppTableSortOrder.none
          : (isAsc ? AppTableSortOrder.ascending : AppTableSortOrder.descending);

      final startItem = totalFiltered == 0
          ? 0
          : ((controller.currentPage.value - 1) * controller.pageSize.value) + 1;
      final endItem = (startItem + controller.pageSize.value - 1).clamp(0, totalFiltered);

      final columns = [
        AppTableColumn<InventoryOrderReceiveLogModel>(
          key: 'sl_no',
          title: 'Sl No.',
          width: 55.w,
          valueGetter: (item) => '${item.slNo}',
        ),
        AppTableColumn<InventoryOrderReceiveLogModel>(
          key: 'order_id',
          title: 'Order ID',
          width: 75.w,
          valueGetter: (item) => item.formattedOrderId,
        ),
        AppTableColumn<InventoryOrderReceiveLogModel>(
          key: 'item_name',
          title: 'Item Name',
          width: 140.w,
          valueGetter: (item) => item.itemName,
        ),
        AppTableColumn<InventoryOrderReceiveLogModel>(
          key: 'requested_qty',
          title: 'Requested Qty',
          width: 110.w,
          cellColorGetter: (item) => AppColors.yellow50,
          valueGetter: (item) => item.formattedRequestedQty,
        ),
        AppTableColumn<InventoryOrderReceiveLogModel>(
          key: 'received_qty',
          title: 'Received Qty',
          width: 110.w,
          cellColorGetter: (item) => AppColors.yellow50,
          valueGetter: (item) => item.formattedReceivedQty,
        ),
        AppTableColumn<InventoryOrderReceiveLogModel>(
          key: 'difference_qty',
          title: 'Difference',
          width: 100.w,
          cellBuilder: (context, item, index, isExpanded) => Text(
            item.formattedDifferenceQty,
            style: AppTextStyle.style_11_500(color: AppColors.red),
          ),
          valueGetter: (item) => item.formattedDifferenceQty,
        ),
        AppTableColumn<InventoryOrderReceiveLogModel>(
          key: 'requested_on',
          title: 'Requested On',
          width: 110.w,
          valueGetter: (item) => item.formattedRequestedOn,
        ),
        AppTableColumn<InventoryOrderReceiveLogModel>(
          key: 'received_on',
          title: 'Fulfilled On',
          width: 160.w,
          valueGetter: (item) => item.formattedFulfilledOn,
        ),
        AppTableColumn<InventoryOrderReceiveLogModel>(
          key: 'fulfilled_days',
          title: 'Fulfilled Days',
          width: 110.w,
          cellBuilder: (context, item, index, isExpanded) => Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
            ),
            child: Text(
              item.fulfilledDaysLabel,
              style: AppTextStyle.style_10_600(color: AppColors.primaryGreen),
            ),
          ),
          valueGetter: (item) => item.fulfilledDaysLabel,
        ),
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Per page count dropdown
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 24.h,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: AppColors.borderColor),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: controller.pageSize.value,
                      icon: Icon(Icons.arrow_drop_down, size: 14.r, color: AppColors.black),
                      isDense: true,
                      padding: EdgeInsets.zero,
                      style: AppTextStyle.style_10_500(color: AppColors.black),
                      items: controller.pageSizeOptions.map((int val) {
                        return DropdownMenuItem<int>(
                          value: val,
                          child: Text('$val / page'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          controller.setPageSize(val);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),

          // Main Table using AppCommonTable
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: AppCommonTable<InventoryOrderReceiveLogModel>(
              items: paginatedList,
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
              emptyText: 'No logs available',
            ),
          ),
          SizedBox(height: 8.h),

          // Standardized Table Pagination
          if (!isLoading && totalFiltered > 0)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: AppTablePagination(
                startItem: startItem,
                endItem: endItem,
                totalItems: totalFiltered,
                currentPage: controller.currentPage.value,
                totalPages: controller.totalPages,
                onPageChanged: (page) => controller.goToPage(page),
                onPreviousPage: () {
                  if (controller.currentPage.value > 1) {
                    controller.goToPage(controller.currentPage.value - 1);
                  }
                },
                onNextPage: () {
                  if (controller.currentPage.value < controller.totalPages) {
                    controller.goToPage(controller.currentPage.value + 1);
                  }
                },
              ),
            ),
        ],
      );
    });
  }
}
