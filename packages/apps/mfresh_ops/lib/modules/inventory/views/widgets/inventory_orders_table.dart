import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/utils/app_common_toast_message.dart';
import '../../controllers/inventory_orders_controller.dart';
import '../../../../data/models/inventory/inventory_order_model.dart';

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

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return const Color(0xFFF59E0B); // Pending (Amber)
      case 1:
        return Colors.purple.shade600; // Waiting for Receive
      case 2:
        return const Color(0xFF10B981); // Completed (Green)
      default:
        return AppColors.grey500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InventoryOrdersController>();

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
                if (controller.filteredOrders.isEmpty && !controller.isLoading.value) {
                  return Padding(
                    padding: EdgeInsets.all(20.r),
                    child: const Text('No inventory orders found.'),
                  );
                }

                final ordersToRender = controller.isLoading.value
                    ? List.generate(
                        5,
                        (index) => InventoryOrderModel(
                          id: index,
                          orderId: index,
                          orderType: 'unit',
                          locationName: 'MM25000',
                          unitName: 'MM25000',
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
                    : controller.paginatedOrders;

                return Skeletonizer(
                  enabled: controller.isLoading.value,
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    border: TableBorder.symmetric(
                      inside: BorderSide(color: Colors.grey.shade300),
                    ),
                    columnWidths: {
                      0: FixedColumnWidth(70.w),  // Order ID
                      1: FixedColumnWidth(100.w), // Unit
                      2: FixedColumnWidth(140.w), // Item
                      3: FixedColumnWidth(100.w), // Quantity
                      4: FixedColumnWidth(120.w), // Requested By
                      5: FixedColumnWidth(130.w), // Status
                      6: FixedColumnWidth(120.w), // Processed By
                      7: FixedColumnWidth(130.w), // Action
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: Color(0xFFE8F1F8)),
                        children: [
                          _buildHeaderCell('Order ID'),
                          _buildHeaderCell('Unit'),
                          _buildHeaderCell('Item'),
                          _buildHeaderCell('Quantity'),
                          _buildHeaderCell('Requested By'),
                          _buildHeaderCell('Status'),
                          _buildHeaderCell('Processed By'),
                          _buildHeaderCell('Action'),
                        ],
                      ),
                      ...ordersToRender.asMap().entries.map((entry) {
                        final index = entry.key;
                        final order = entry.value;
                        final key = 'order_${order.id}_$index';
                        final isExpanded = _expandedRows.contains(key);

                        return TableRow(
                          children: [
                            _buildDataCell('#${order.orderId}', isExpanded, () => _toggleRow(key)),
                            _buildDataCell(order.displayName, isExpanded, () => _toggleRow(key)),
                            _buildDataCell(order.itemName, isExpanded, () => _toggleRow(key)),
                            _buildDataCell(order.formattedQty, isExpanded, () => _toggleRow(key), bgColor: const Color(0xFFFFF8E7)),
                            _buildDataCell(order.requestedBy?.name ?? '-', isExpanded, () => _toggleRow(key)),
                            _buildStatusCell(order),
                            _buildDataCell(order.processedBy?.name ?? '-', isExpanded, () => _toggleRow(key)),
                            _buildActionCell(order),
                          ],
                        );
                      }),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Obx(() {
          final totalItems = controller.filteredOrders.length;
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
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
      child: Text(
        text,
        style: AppTextStyle.style_11_700(color: AppColors.black),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStatusCell(InventoryOrderModel order) {
    if (order.status == 0) {
      // Pending
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Text(
            'Pending',
            style: AppTextStyle.style_11_600(color: const Color(0xFFD97706)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    } else if (order.status == 1) {
      // Waiting for Receive
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(color: const Color(0xFFBAE6FD)),
          ),
          child: Text(
            'Waiting for Receive',
            style: AppTextStyle.style_11_600(color: const Color(0xFF0284C7)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    } else if (order.status == 2) {
      // Completed
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: Text(
            'Completed',
            style: AppTextStyle.style_11_600(color: const Color(0xFF059669)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      child: Text(order.statusName, style: AppTextStyle.style_11_400(color: AppColors.black)),
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
              AppCommonToastMessage.show(
                message: 'Process Order #${order.orderId}',
                type: ToastType.info,
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
            child: Text('Complete Order', style: AppTextStyle.style_10_600(color: const Color(0xFFD97706))),
          ),
        ),
      );
    }

    if (order.canReceive) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: SizedBox(
          height: 22.h,
          child: ElevatedButton(
            onPressed: () {
              AppCommonToastMessage.show(
                message: 'Receive Order #${order.orderId}',
                type: ToastType.info,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE0F2FE),
              foregroundColor: const Color(0xFF0284C7),
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
                side: const BorderSide(color: Color(0xFFBAE6FD)),
              ),
              elevation: 0,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text('Waiting for Receive', style: AppTextStyle.style_10_600(color: const Color(0xFF0284C7))),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      child: Text('-', style: AppTextStyle.style_12_400(color: AppColors.grey500)),
    );
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
