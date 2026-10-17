import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_table.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_table_pagination.dart';
import 'package:mfresh_ops/modules/inventory/controllers/unit_inventory_controller.dart';
import 'receive_store_order_dialog.dart';
import 'request_unit_order_dialog.dart';
import 'package:mfresh_ops/data/models/inventory/unit_inventory_model.dart';
import 'package:mfresh_ops/modules/inventory/views/widgets/store_inventory_dialogs.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';

class UnitInventoryTable extends StatefulWidget {
  const UnitInventoryTable({super.key});

  @override
  State<UnitInventoryTable> createState() => _UnitInventoryTableState();
}

class _UnitInventoryTableState extends State<UnitInventoryTable> {
  final Set<int> _expandedRowIndices = {};

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UnitInventoryController>();

    return Obx(() {
      final authRepo = Get.find<AuthRepository>();
      final userPermissions = authRepo.rxUserPermissions;

      final canAllocate = userPermissions.contains('U_Inv_Allot');
      final canConsume = userPermissions.contains('U_Inv_Consume');
      final canShowAdminColumns = userPermissions.contains('unit_admin_column');

      final isTableLoading = controller.isLoading.value;
      final items = isTableLoading
          ? List.generate(
              10,
              (index) => UnitInventoryModel(
                id: index,
                unitName: 'Unit_Dummy',
                itemName: 'Loading Item',
                categoryName: 'Category_Dummy',
                quantity: '0',
                lowQntyUnit: '0',
                mUnit: 'pcs',
              ),
            )
          : controller.paginatedItems;

      final columns = [
        AppTableColumn<UnitInventoryModel>(
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
                      width: 40.w,
                      textSize: 9.5.sp,
                      borderRadius: 4.r,
                      padding: EdgeInsets.zero,
                      buttonColor: AppColors.red,
                      useGradient: false,
                      onPressed: () =>
                          StoreInventoryDialogs.showConsumptionSheet(
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
        AppTableColumn<UnitInventoryModel>(
          key: 'Unit',
          title: 'Unit',
          width: 66.w,
          valueGetter: (item) => item.unitName,
        ),
        AppTableColumn<UnitInventoryModel>(
          key: 'Item',
          title: 'Item',
          width: 105.w,
          valueGetter: (item) => item.itemName,
        ),
        AppTableColumn<UnitInventoryModel>(
          key: 'Category',
          title: 'Category',
          width: 110.w,
          valueGetter: (item) => item.categoryName,
        ),
        AppTableColumn<UnitInventoryModel>(
          key: 'Quantity',
          title: 'Qty',
          width: 60.w,
          cellColorGetter: (item) => AppColors.yellow50,
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
        if (canShowAdminColumns) ...[
          AppTableColumn<UnitInventoryModel>(
            key: 'Actual Qty',
            title: 'Actual Qty',
            width: 85.w,
            valueGetter: (item) => item.actualQty,
          ),
          AppTableColumn<UnitInventoryModel>(
            key: 'Diff Qty',
            title: 'Diff Qty',
            width: 70.w,
            cellBuilder: (context, item, index, isExpanded) {
              final diffColor = _getDiffTextColor(item);
              return Text(
                item.differenceQty,
                style: AppTextStyle.style_12_500(
                  color: diffColor ?? AppColors.black,
                ),
                maxLines: isExpanded ? null : 1,
                overflow: isExpanded ? null : TextOverflow.ellipsis,
              );
            },
          ),
        ],
        AppTableColumn<UnitInventoryModel>(
          key: 'Consumption',
          title: controller.consumptionSubtitle.value.isNotEmpty
              ? 'Usage ${controller.consumptionSubtitle.value}'
              : 'Usage',
          width: 110.w,
          valueGetter: (item) => item.formattedConsumption,
        ),
        AppTableColumn<UnitInventoryModel>(
          key: 'Required Qty',
          title: controller.consumptionSubtitle.value.isNotEmpty
              ? 'Required Qty ${controller.consumptionSubtitle.value}'
              : 'Required Qty',
          width: 150.w,
          valueGetter: (item) => item.formattedRequiredQuantity,
        ),
        AppTableColumn<UnitInventoryModel>(
          key: 'Order',
          title: 'Request Order',
          width: 100.w,
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
            child: AppCommonTable<UnitInventoryModel>(
              items: items,
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
              isLoading: isTableLoading,
              headingRowColor: AppColors.blue50,
              headingTextStyle: AppTextStyle.style_11_700(
                color: AppColors.black,
              ),
              dataTextStyle: AppTextStyle.style_11_500(color: AppColors.black),
              borderColor: AppColors.borderColor,
              headingRowHeight: 20.h,
              cellVerticalPadding: 1.h,
              cellHorizontalPadding: 4.w,
              emptyText: 'No inventory stock found',
            ),
          ),
          SizedBox(height: 12.h),
          Obx(() {
            final totalItems = controller.unitInventoryItems.length;
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

  Widget _buildOrderCell(UnitInventoryModel item) {
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
            final unitId = int.tryParse(item.unitId) ?? 0;
            final itemId = int.tryParse(item.itemId) ?? 0;
            RequestUnitOrderDialog.show(
              context: context,
              unitId: unitId,
              itemId: itemId,
              unitName: item.unitName,
              itemName: item.itemName,
              orderQty: item.orderQty,
              displayUnit: item.displayUnit,
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
              storeOrUnitName: item.unitName,
              itemName: item.itemName,
              requestedQty: item.currentOrderQty ?? item.orderQty.toString(),
              displayUnit: item.displayUnit,
              isStoreOrder: false,
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Color? _getDiffTextColor(UnitInventoryModel item) {
    if (item.differenceQtyColor.isNotEmpty) {
      try {
        final hex = item.differenceQtyColor.replaceAll('#', '');
        if (hex.length == 6) {
          return Color(int.parse('0xFF$hex'));
        }
      } catch (_) {}
    }
    if (item.differenceQty.startsWith('-') ||
        item.auditStatus.toLowerCase() == 'shortage') {
      return AppColors.red;
    } else if (item.differenceQty.startsWith('+') ||
        item.auditStatus.toLowerCase() == 'excess') {
      return AppColors.green;
    }
    return null;
  }
}
