import 'package:core/utils/app_common_toast_message.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
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
  final Set<String> _expandedRows = {};

  void _toggleRow(String key) {
    setState(() {
      if (_expandedRows.contains(key)) {
        _expandedRows.remove(key);
      } else {
        _expandedRows.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InventoryController>();

    return Obx(() {
      final authRepo = Get.find<AuthRepository>();
      final userPermissions = authRepo.rxUserPermissions;

      final canAllocate = userPermissions.contains('S_Inv_Allot');
      final canConsume = userPermissions.contains('S_Inv_Consume');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
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
                  if (controller.inventoryItems.isEmpty && !controller.isLoading.value) {
                    return Padding(
                      padding: EdgeInsets.all(20.r),
                      child: const Text('No inventory items found.'),
                    );
                  }

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

                  return Skeletonizer(
                    enabled: controller.isLoading.value,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sticky Header Row
                        Table(
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          border: TableBorder.symmetric(
                            inside: BorderSide(color: Colors.grey.shade300),
                          ),
                          columnWidths: {
                            0: FixedColumnWidth(125.w),
                            1: FixedColumnWidth(80.w),
                            2: FixedColumnWidth(120.w),
                            3: FixedColumnWidth(110.w),
                            4: FixedColumnWidth(60.w),
                            5: FixedColumnWidth(110.w),
                            6: FixedColumnWidth(150.w),
                            7: FixedColumnWidth(110.w),
                          },
                          children: [
                            TableRow(
                              decoration: const BoxDecoration(color: Color(0xFFE8F1F8)),
                              children: [
                                _buildHeaderCell(controller, 'Action'),
                                _buildHeaderCell(controller, 'Store'),
                                _buildHeaderCell(controller, 'Item'),
                                _buildHeaderCell(controller, 'Category'),
                                _buildHeaderCell(controller, 'Quantity'),
                                _buildHeaderCell(controller, controller.consumptionSubtitle.value.isNotEmpty ? 'Usage ${controller.consumptionSubtitle.value}' : 'Usage', sortKey: 'Consumption'),
                                _buildHeaderCell(controller, controller.consumptionSubtitle.value.isNotEmpty ? 'Required Qty ${controller.consumptionSubtitle.value}' : 'Required Qty', sortKey: 'Required Qty'),
                                _buildHeaderCell(controller, 'Request Order', sortKey: 'Order'),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
                        // Scrollable Rows
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 340.h),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Table(
                              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                              border: TableBorder.symmetric(
                                inside: BorderSide(color: Colors.grey.shade300),
                              ),
                              columnWidths: {
                                0: FixedColumnWidth(125.w),
                                1: FixedColumnWidth(80.w),
                                2: FixedColumnWidth(120.w),
                                3: FixedColumnWidth(110.w),
                                4: FixedColumnWidth(60.w),
                                5: FixedColumnWidth(110.w),
                                6: FixedColumnWidth(150.w),
                                7: FixedColumnWidth(110.w),
                              },
                              children: [
                                ...List.generate(itemsToRender.length, (index) {
                                  final item = itemsToRender[index];
                                  final key = '${item.store}_${item.item}_${item.category}_$index';
                                  final isExpanded = _expandedRows.contains(key);

                                  return TableRow(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (canAllocate) ...[
                                                SizedBox(
                                                  height: 18.h,
                                                  width: 56.w,
                                                  child: ElevatedButton(
                                                    onPressed: () => StoreInventoryDialogs.showAllocateSheet(context, item),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.blue,
                                                      foregroundColor: Colors.white,
                                                      padding: EdgeInsets.zero,
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                                                      elevation: 0,
                                                      minimumSize: Size.zero,
                                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    ),
                                                    child: Center(child: Text('Transfer', style: AppTextStyle.style_10_500(color: Colors.white))),
                                                  ),
                                                ),
                                                SizedBox(width: 4.w),
                                              ],
                                              if (canConsume) ...[
                                                SizedBox(
                                                  height: 18.h,
                                                  width: 56.w,
                                                  child: ElevatedButton(
                                                    onPressed: () => StoreInventoryDialogs.showConsumptionSheet(context, item),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFFE53935),
                                                      foregroundColor: Colors.white,
                                                      padding: EdgeInsets.zero,
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                                                      elevation: 0,
                                                      minimumSize: Size.zero,
                                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    ),
                                                    child: Center(child: Text('Use', style: AppTextStyle.style_10_500(color: Colors.white))),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                      _buildDataCell(item.store, isExpanded, () => _toggleRow(key)),
                                      _buildDataCell(item.item, isExpanded, () => _toggleRow(key)),
                                      _buildDataCell(item.category, isExpanded, () => _toggleRow(key)),
                                      _buildDataCell(item.quantity, isExpanded, () => _toggleRow(key), textColor: (item.isLowStock || item.isQntyLow) ? Colors.red : null, bgColor: const Color(0xFFFFF8E7)),
                                      _buildDataCell(item.formattedConsumption, isExpanded, () => _toggleRow(key)),
                                      _buildDataCell(item.formattedRequiredQuantity, isExpanded, () => _toggleRow(key)),
                                      _buildOrderCell(item),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Obx(() {
            final totalItems = controller.inventoryItems.length;
            final startItem = totalItems == 0 ? 0 : ((controller.currentPage.value - 1) * controller.itemsPerPage.value) + 1;
            final endItem = (startItem + controller.itemsPerPage.value - 1).clamp(0, totalItems);

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Showing $startItem to $endItem of $totalItems entries',
                      style: AppTextStyle.style_12_400(color: AppColors.black),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    flex: 2,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildPaginationButton('←', false, controller.previousPage),
                          ...List.generate(controller.totalPages, (index) {
                            final pageNumber = index + 1;
                            return _buildPaginationButton(
                              pageNumber.toString(),
                              controller.currentPage.value == pageNumber,
                              () => controller.goToPage(pageNumber),
                            );
                          }),
                          _buildPaginationButton('→', false, controller.nextPage),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    });
  }

  Widget _buildHeaderCell(InventoryController controller, String text, {String? sortKey}) {
    final key = sortKey ?? text;
    final isSorted = controller.sortColumn.value == key;
    final isAsc = controller.sortAscending.value;

    return InkWell(
      onTap: key.isNotEmpty && key != 'Action' ? () => controller.sortBy(key) : null,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
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

  Widget _buildOrderCell(InventoryItemModel item) {
    if (item.canRequestOrder && !item.canReceiveOrder) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: SizedBox(
          height: 20.h,
          child: ElevatedButton(
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
              elevation: 1,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text('Request Order', style: AppTextStyle.style_10_600(color: Colors.white)),
          ),
        ),
      );
    }

    if (!item.canRequestOrder && !item.canReceiveOrder) {
      if (item.currentOrderId == null) {
        return const SizedBox.shrink();
      }
      final rawStatus = item.currentOrderStatusName?.trim();
      final statusDisplay = (rawStatus == null || rawStatus.isEmpty || rawStatus.toLowerCase() == 'pending')
          ? 'Order Pending'
          : rawStatus;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: Container(
          height: 20.h,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          decoration: BoxDecoration(
            color: const Color(0xFF9E9E9E),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            statusDisplay,
            style: AppTextStyle.style_10_500(color: Colors.white),
          ),
        ),
      );
    }

    if (!item.canRequestOrder && item.canReceiveOrder) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: SizedBox(
          height: 20.h,
          child: ElevatedButton(
            onPressed: () {
              final orderId = int.tryParse(item.currentOrderId?.toString() ?? '') ?? 0;
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00875A),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
              elevation: 1,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text('Order Receive', style: AppTextStyle.style_10_600(color: Colors.white)),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildDataCell(String text, bool isExpanded, VoidCallback onTap, {Color? textColor, Color? bgColor}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: bgColor,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
        child: Text(
          text,
          style: AppTextStyle.style_12_400(color: textColor ?? AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildPaginationButton(String text, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        margin: EdgeInsets.only(left: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade600 : const Color(0xFFF1F5F9),
          border: Border.all(color: isActive ? Colors.blue.shade600 : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          text,
          style: AppTextStyle.style_12_500(color: isActive ? Colors.white : Colors.blue.shade600),
        ),
      ),
    );
  }
}
