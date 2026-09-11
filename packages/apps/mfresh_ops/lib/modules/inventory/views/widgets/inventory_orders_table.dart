import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import '../../controllers/inventory_orders_controller.dart';
import '../../../../data/models/inventory/inventory_order_model.dart';
import 'receive_store_order_dialog.dart';

class InventoryOrdersTable extends StatefulWidget {
  const InventoryOrdersTable({super.key});

  @override
  State<InventoryOrdersTable> createState() => _InventoryOrdersTableState();
}

class _InventoryOrdersTableState extends State<InventoryOrdersTable> {
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
    final controller = Get.find<InventoryOrdersController>();

    return Obx(() {
      final unitOrders = controller.filteredUnitOrders;
      final storeOrders = controller.filteredStoreOrders;
      final paginatedUnitOrders = controller.paginatedUnitOrders;
      final paginatedStoreOrders = controller.paginatedStoreOrders;
      final isLoading = controller.isLoading.value;

      if (!isLoading && unitOrders.isEmpty && storeOrders.isEmpty) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          alignment: Alignment.center,
          child: Text(
            'No inventory orders found.',
            style: AppTextStyle.style_14_400(color: AppColors.grey300),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unit Order Requests Section
          if (isLoading || unitOrders.isNotEmpty) ...[
            _buildSectionHeader(
              'Unit Order Requests',
              unitOrders.length,
              Icons.domain_rounded,
            ),
            SizedBox(height: 6.h),
            _buildOrderTable(
              controller: controller,
              orders: paginatedUnitOrders,
              locationHeaderName: 'Unit',
              isLoading: isLoading,
            ),
            if (!isLoading && unitOrders.isNotEmpty)
              _buildUnitPagination(controller, unitOrders.length),
            SizedBox(height: 16.h),
          ],

          // Store Order Requests Section
          if (isLoading || storeOrders.isNotEmpty) ...[
            _buildSectionHeader(
              'Store Order Requests',
              storeOrders.length,
              Icons.storefront_rounded,
            ),
            SizedBox(height: 6.h),
            _buildOrderTable(
              controller: controller,
              orders: paginatedStoreOrders,
              locationHeaderName: 'Store',
              isLoading: isLoading,
            ),
            if (!isLoading && storeOrders.isNotEmpty)
              _buildStorePagination(controller, storeOrders.length),
          ],
        ],
      );
    });
  }

  Widget _buildUnitPagination(
    InventoryOrdersController controller,
    int totalItems,
  ) {
    final startItem = totalItems == 0
        ? 0
        : ((controller.unitCurrentPage.value - 1) *
                  controller.unitItemsPerPage.value) +
              1;
    final endItem = (startItem + controller.unitItemsPerPage.value - 1).clamp(
      0,
      totalItems,
    );

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
                  _buildPaginationButton(
                    '←',
                    false,
                    controller.previousUnitPage,
                  ),
                  ...List.generate(controller.unitTotalPages, (index) {
                    final pageNumber = index + 1;
                    return _buildPaginationButton(
                      pageNumber.toString(),
                      controller.unitCurrentPage.value == pageNumber,
                      () => controller.setUnitPage(pageNumber),
                    );
                  }),
                  _buildPaginationButton('→', false, controller.nextUnitPage),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorePagination(
    InventoryOrdersController controller,
    int totalItems,
  ) {
    final startItem = totalItems == 0
        ? 0
        : ((controller.storeCurrentPage.value - 1) *
                  controller.storeItemsPerPage.value) +
              1;
    final endItem = (startItem + controller.storeItemsPerPage.value - 1).clamp(
      0,
      totalItems,
    );

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
                  _buildPaginationButton(
                    '←',
                    false,
                    controller.previousStorePage,
                  ),
                  ...List.generate(controller.storeTotalPages, (index) {
                    final pageNumber = index + 1;
                    return _buildPaginationButton(
                      pageNumber.toString(),
                      controller.storeCurrentPage.value == pageNumber,
                      () => controller.setStorePage(pageNumber),
                    );
                  }),
                  _buildPaginationButton('→', false, controller.nextStorePage),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildSectionHeader(String title, int count, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Icon(icon, size: 16.r, color: AppColors.primary),
          SizedBox(width: 6.w),
          Text(title, style: AppTextStyle.style_14_700(color: AppColors.black)),
          SizedBox(width: 6.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              '$count',
              style: AppTextStyle.style_11_600(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTable({
    required InventoryOrdersController controller,
    required List<InventoryOrderModel> orders,
    required String locationHeaderName,
    required bool isLoading,
  }) {
    final ordersToRender = isLoading
        ? List.generate(
            4,
            (index) => InventoryOrderModel(
              id: index,
              orderId: index,
              orderType: locationHeaderName.toLowerCase(),
              locationName: 'Loading',
              unitName: 'Loading',
              storeName: 'Loading',
              itemId: 1,
              itemName: 'Loading Item Name',
              measurementUnitId: 1,
              measurementUnit: 'pcs',
              requestedQty: 100,
              status: 0,
              statusName: 'Pending',
              canProcess: false,
              canReceive: false,
              createdAt: '2026-09-07 10:00:00',
              updatedAt: '2026-09-07 10:00:00',
            ),
          )
        : orders;

    return Container(
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
          child: Skeletonizer(
            enabled: isLoading,
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              border: TableBorder.symmetric(
                inside: BorderSide(color: Colors.grey.shade300),
              ),
              columnWidths: {
                0: FixedColumnWidth(70.w), // Order ID
                1: FixedColumnWidth(100.w), // Location (Unit/Store)
                2: FixedColumnWidth(140.w), // Item
                3: FixedColumnWidth(100.w), // Quantity
                4: FixedColumnWidth(120.w), // Requested By
                5: FixedColumnWidth(110.w), // Status
                6: FixedColumnWidth(120.w), // Processed By
                7: FixedColumnWidth(135.w), // Action
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFE8F1F8)),
                  children: [
                    _buildHeaderCell(controller, 'Order ID'),
                    _buildHeaderCell(
                      controller,
                      locationHeaderName,
                      sortKey: 'Location',
                    ),
                    _buildHeaderCell(controller, 'Item'),
                    _buildHeaderCell(controller, 'Quantity'),
                    _buildHeaderCell(controller, 'Requested By'),
                    _buildHeaderCell(controller, 'Status'),
                    _buildHeaderCell(controller, 'Processed By'),
                    _buildHeaderCell(controller, 'Action'),
                  ],
                ),
                ...ordersToRender.asMap().entries.map((entry) {
                  final index = entry.key;
                  final order = entry.value;
                  final key = 'order_${order.orderType}_${order.id}_$index';
                  final isExpanded = _expandedRows.contains(key);

                  return TableRow(
                    children: [
                      _buildDataCell(
                        '#${order.orderId}',
                        isExpanded,
                        () => _toggleRow(key),
                      ),
                      _buildDataCell(
                        order.displayName,
                        isExpanded,
                        () => _toggleRow(key),
                      ),
                      _buildDataCell(
                        order.itemName,
                        isExpanded,
                        () => _toggleRow(key),
                      ),
                      _buildDataCell(
                        order.formattedQty,
                        isExpanded,
                        () => _toggleRow(key),
                        bgColor: const Color(0xFFFFF8E7),
                      ),
                      _buildDataCell(
                        order.requestedBy?.name ?? '-',
                        isExpanded,
                        () => _toggleRow(key),
                      ),
                      _buildStatusCell(
                        order,
                        isExpanded,
                        () => _toggleRow(key),
                      ),
                      _buildDataCell(
                        order.processedBy?.name ?? '-',
                        isExpanded,
                        () => _toggleRow(key),
                      ),
                      _buildActionCell(order),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(
    InventoryOrdersController controller,
    String text, {
    String? sortKey,
  }) {
    final key = sortKey ?? text;
    final isSorted = controller.sortColumn.value == key;
    final isAsc = controller.sortAscending.value;

    return InkWell(
      onTap: key.isNotEmpty && key != 'Action'
          ? () => controller.sortBy(key)
          : null,
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

  Widget _buildStatusCell(
    InventoryOrderModel order,
    bool isExpanded,
    VoidCallback onTap,
  ) {
    Widget childWidget;

    if (order.status == 0) {
      // Pending
      childWidget = Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Text(
          'Pending',
          style: AppTextStyle.style_10_600(color: const Color(0xFFD97706)),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
      );
    } else if (order.status == 1) {
      // Waiting for Receive
      childWidget = Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F2FE),
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: const Color(0xFFBAE6FD)),
        ),
        child: Text(
          'Waiting for Receive',
          style: AppTextStyle.style_10_600(color: const Color(0xFF0284C7)),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
      );
    } else if (order.status == 2) {
      // Completed
      childWidget = Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: const Color(0xFFD1FAE5),
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: Text(
          'Completed',
          style: AppTextStyle.style_10_600(color: const Color(0xFF059669)),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
      );
    } else {
      childWidget = Text(
        order.statusName,
        style: AppTextStyle.style_10_400(color: AppColors.black),
        maxLines: isExpanded ? null : 1,
        overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: childWidget,
      ),
    );
  }

  Widget _buildActionCell(InventoryOrderModel order) {
    if (order.canProcess) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: SizedBox(
          height: 22.h,
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text(
                    'Confirm Action',
                    style: AppTextStyle.style_16_600(color: AppColors.black),
                  ),
                  content: Text(
                    'Are you sure you want to process this order?',
                    style: AppTextStyle.style_14_400(color: AppColors.grey700),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(
                        'Cancel',
                        style: AppTextStyle.style_14_500(color: AppColors.grey600),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Get.find<InventoryOrdersController>().completeOrder(order);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                      ),
                      child: Text(
                        'Confirm',
                        style: AppTextStyle.style_14_600(color: AppColors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFEF3C7),
              foregroundColor: const Color(0xFFD97706),
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
                side: const BorderSide(color: Color(0xFFFDE68A)),
              ),
              elevation: 0,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Complete Order',
              style: AppTextStyle.style_10_600(color: const Color(0xFFD97706)),
            ),
          ),
        ),
      );
    }

    if (order.status == 1 || order.statusName == 'Waiting for Receive') {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: SizedBox(
          height: 22.h,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE0F2FE),
              foregroundColor: const Color(0xFF0284C7),
              disabledBackgroundColor: const Color(0xFFE0F2FE),
              disabledForegroundColor: const Color(0xFF0284C7),
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
                side: const BorderSide(color: Color(0xFFBAE6FD)),
              ),
              elevation: 0,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Inventory Dispatched',
              style: AppTextStyle.style_10_600(color: const Color(0xFF0284C7)),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      child: Text(
        '-',
        style: AppTextStyle.style_12_400(color: AppColors.grey500),
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
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
        child: Text(
          text,
          style: AppTextStyle.style_10_400(color: textColor ?? AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
