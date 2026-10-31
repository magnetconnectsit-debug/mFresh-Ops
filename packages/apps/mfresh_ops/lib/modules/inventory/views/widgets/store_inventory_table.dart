import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_table.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_table_pagination.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_controller.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import '../../../../data/models/inventory/inventory_item_model.dart';
import 'receive_store_order_dialog.dart';
import 'request_store_order_dialog.dart';
import 'store_inventory_dialogs.dart';

class StoreInventoryTable extends StatefulWidget {
  const StoreInventoryTable({super.key});

  @override
  State<StoreInventoryTable> createState() => _StoreInventoryTableState();
}

class _StoreInventoryTableState extends State<StoreInventoryTable> {
  final Set<int> _expandedRowIndices = {};

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InventoryController>();

    return Obx(() {
      final authRepo = Get.find<AuthRepository>();
      final userPermissions = authRepo.rxUserPermissions;

      final canAllocate = userPermissions.contains('S_Inv_Allot');
      final canConsume = userPermissions.contains('S_Inv_Consume');

      final itemsToRender = controller.isLoading.value
          ? List.generate(
              10,
              (index) => InventoryItemModel(
                id: index,
                store: 'Store_Dummy',
                item: 'Loading Item',
                category: 'Category_Dummy',
                quantity: '0',
                unit: 'pcs',
              ),
            )
          : controller.paginatedItems;

      final columns = [
        AppTableColumn<InventoryItemModel>(
          key: 'Action',
          title: 'Action',
          width: 110.w,
          sortable: false,
          cellBuilder: (context, item, index, isExpanded) {
            return FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canAllocate) ...[
                    AppCommonButton(
                      text: 'Transfer',
                      height: 16.h,
                      width: 56.w,
                      textSize: 9.5.sp,
                      borderRadius: 4.r,
                      padding: EdgeInsets.zero,
                      buttonColor: AppColors.info,
                      useGradient: false,
                      onPressed: () => StoreInventoryDialogs.showAllocateSheet(
                        context,
                        item,
                      ),
                    ),
                    SizedBox(width: 4.w),
                  ],
                  if (canConsume) ...[
                    AppCommonButton(
                      text: 'Use',
                      height: 16.h,
                      width: 56.w,
                      textSize: 9.5.sp,
                      borderRadius: 4.r,
                      padding: EdgeInsets.zero,
                      buttonColor: AppColors.red,
                      useGradient: false,
                      onPressed: () => StoreInventoryDialogs.showConsumptionSheet(
                        context,
                        item,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        AppTableColumn<InventoryItemModel>(
          key: 'Store',
          title: 'Store',
          width: 70.w,
          valueGetter: (item) => item.store,
        ),
        AppTableColumn<InventoryItemModel>(
          key: 'Item',
          title: 'Item',
          width: 100.w,
          valueGetter: (item) => item.item,
        ),
        AppTableColumn<InventoryItemModel>(
          key: 'Category',
          title: 'Category',
          width: 90.w,
          valueGetter: (item) => item.category,
        ),
        AppTableColumn<InventoryItemModel>(
          key: 'Quantity',
          title: 'Quantity',
          width: 80.w,
          cellColorGetter: (item) => const Color(0xFFFFF8E7),
          cellBuilder: (context, item, index, isExpanded) {
            final isLow = item.isLowStock || item.isQntyLow;
            return Text(
              item.quantity,
              style: AppTextStyle.style_12_400(
                color: isLow ? AppColors.red : AppColors.black,
              ),
              maxLines: isExpanded ? null : 1,
              overflow: isExpanded ? null : TextOverflow.ellipsis,
            );
          },
        ),
        AppTableColumn<InventoryItemModel>(
          key: 'Consumption',
          title: controller.consumptionSubtitle.value.isNotEmpty
              ? 'Usage ${controller.consumptionSubtitle.value}'
              : 'Usage',
          width: 110.w,
          valueGetter: (item) => item.formattedConsumption,
        ),
        AppTableColumn<InventoryItemModel>(
          key: 'Required Qty',
          title: controller.consumptionSubtitle.value.isNotEmpty
              ? 'Required Qty ${controller.consumptionSubtitle.value}'
              : 'Required Qty',
          width: 150.w,
          valueGetter: (item) => item.formattedRequiredQuantity,
        ),
        AppTableColumn<InventoryItemModel>(
          key: 'Order',
          title: 'Request Order',
          width: 96.w,
          sortable: false,
          cellBuilder: (context, item, index, isExpanded) =>
              _buildOrderCell(item),
        ),
      ];

      final currentSortKey = controller.sortColumn.value;
      final currentSortOrder = currentSortKey.isEmpty
          ? AppTableSortOrder.none
          : (controller.sortAscending.value
                ? AppTableSortOrder.ascending
                : AppTableSortOrder.descending);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: AppCommonTable<InventoryItemModel>(
              items: itemsToRender,
              columns: columns,
              currentSortColumn: currentSortKey,
              currentSortOrder: currentSortOrder,
              onSort: (columnKey, sortOrder) {
                controller.sortBy(columnKey);
              },
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
              isLoading: controller.isLoading.value,
              headingRowColor: const Color(0xFFE8F1F8),
              headingTextStyle: AppTextStyle.style_11_700(color: AppColors.black),
              dataTextStyle: AppTextStyle.style_11_500(color: AppColors.black),
              borderColor: AppColors.borderColor,
              headingRowHeight: 20.h,
              cellVerticalPadding: 1.h,
              cellHorizontalPadding: 4.w,
              emptyText: 'No inventory items found.',
            ),
          ),
          SizedBox(height: 12.h),
          Obx(() {
            final totalItems = controller.inventoryItems.length;
            final startItem = totalItems == 0
                ? 0
                : ((controller.currentPage.value - 1) *
                          controller.itemsPerPage.value) +
                      1;
            final endItem = (startItem + controller.itemsPerPage.value - 1)
                .clamp(0, totalItems);

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: AppTablePagination(
                startItem: startItem,
                endItem: endItem,
                totalItems: totalItems,
                currentPage: controller.currentPage.value,
                totalPages: controller.totalPages,
                onPageChanged: (page) => controller.goToPage(page),
                onPreviousPage: controller.previousPage,
                onNextPage: controller.nextPage,
              ),
            );
          }),
        ],
      );
    });
  }

  Widget _buildOrderCell(InventoryItemModel item) {
    if (item.canRequestOrder && !item.canReceiveOrder) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: AppCommonButton(
          text: 'Request Order',
          height: 16.h,
          textSize: 9.5.sp,
          borderRadius: 4.r,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          buttonColor: AppColors.warning,
          useGradient: false,
          onPressed: () {
            final storeId = int.tryParse(item.sourceId) ?? 0;
            final itemId = int.tryParse(item.itemId) ?? 0;
            RequestStoreOrderDialog.show(
              context: context,
              storeId: storeId,
              itemId: itemId,
              storeName: item.store,
              itemName: item.item,
              orderQty: item.orderQty,
              displayUnit: item.unit,
            );
          },
        ),
      );
    }

    if (!item.canRequestOrder && !item.canReceiveOrder) {
      if (item.currentOrderId == null) {
        return const SizedBox.shrink();
      }
      final rawStatus = item.currentOrderStatusName?.trim();
      final statusDisplay =
          (rawStatus == null ||
              rawStatus.isEmpty ||
              rawStatus.toLowerCase() == 'pending')
          ? 'Order Pending'
          : rawStatus;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: AppCommonButton(
          text: statusDisplay,
          height: 16.h,
          textSize: 9.5.sp,
          borderRadius: 4.r,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          buttonColor: AppColors.black200,
          useGradient: false,
          onPressed: null,
        ),
      );
    }

    if (!item.canRequestOrder && item.canReceiveOrder) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: AppCommonButton(
          text: 'Order Receive',
          height: 16.h,
          textSize: 9.5.sp,
          borderRadius: 4.r,
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          buttonColor: AppColors.primaryGreen,
          useGradient: false,
          onPressed: () {
            final orderId =
                int.tryParse(item.currentOrderId?.toString() ?? '') ?? 0;
            ReceiveStoreOrderDialog.show(
              context: context,
              orderId: orderId,
              storeOrUnitName: item.store,
              itemName: item.item,
              requestedQty: item.currentOrderQty ?? item.orderQty.toString(),
              displayUnit: item.unit,
              isStoreOrder: true,
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
