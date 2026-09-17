import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/data/models/inventory/inventory_order_receive_log_model.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_order_logs_controller.dart';

class OrderLogsTable extends StatefulWidget {
  const OrderLogsTable({super.key});

  @override
  State<OrderLogsTable> createState() => _OrderLogsTableState();
}

class _OrderLogsTableState extends State<OrderLogsTable> {
  final Set<int> _expandedRows = {};

  void _toggleRow(int logId) {
    setState(() {
      if (_expandedRows.contains(logId)) {
        _expandedRows.remove(logId);
      } else {
        _expandedRows.add(logId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InventoryOrderLogsController>();

    return Obx(() {
      final isLoading = controller.isLoading.value;
      final totalFiltered = controller.filteredLogs.length;
      final paginatedList = isLoading
          ? List.generate(
              10,
              (index) => InventoryOrderReceiveLogModel(
                slNo: index + 1,
                logId: index + 1,
                orderId: 10 + index,
                orderType: 'unit',
                itemId: 1,
                itemName: 'Loading Item Name',
                measurementUnit: 'ml',
                requestedQty: '100 ml',
                receivedQty: '100 ml',
                differenceQty: '0 ml',
                requestedOn: '2026-09-09',
                requestedOnDisplay: '09-09-2026',
                requestedOnDay: 'Wednesday',
                receivedOn: '2026-09-10',
                receivedOnDisplay: '10-09-2026',
                receivedOnDay: 'Thursday',
                fulfilledDays: 1,
                fulfilledDaysLabel: '1 Day',
                isDelayed: false,
                fulfillmentStatus: 'On Time',
                fulfillmentColor: 'normal',
                orderStatus: 2,
              ),
            )
          : controller.paginatedLogs;

      final startEntry = totalFiltered == 0 ? 0 : (controller.currentPage.value - 1) * controller.pageSize.value + 1;
      final endEntry = (controller.currentPage.value * controller.pageSize.value).clamp(0, totalFiltered);

      final columnWidths = {
        0: FixedColumnWidth(60.w),  // Sl No.
        1: FixedColumnWidth(75.w),  // Order ID
        2: FixedColumnWidth(150.w), // Item Name
        3: FixedColumnWidth(110.w), // Requested Qty
        4: FixedColumnWidth(110.w), // Received Qty
        5: FixedColumnWidth(105.w), // Difference
        6: FixedColumnWidth(110.w), // Requested On
        7: FixedColumnWidth(160.w), // Fulfilled On
        8: FixedColumnWidth(110.w), // Fulfilled Days
      };

      if (!isLoading && totalFiltered == 0) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 44.r,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 10.h),
                Text(
                  'No logs available',
                  style: AppTextStyle.style_14_500(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Per page count dropdown (aligned to the right)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 24.h,
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: controller.pageSize.value,
                      icon: Icon(Icons.arrow_drop_down, size: 14.r),
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
          SizedBox(height: 6.h),

          // Table Container with Sticky Header
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
                child: Skeletonizer(
                  enabled: isLoading,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sticky Header Row
                      Table(
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        border: TableBorder.symmetric(
                          inside: BorderSide(color: Colors.grey.shade300),
                        ),
                        columnWidths: columnWidths,
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(color: Color(0xFF1EA1D7)),
                            children: [
                              _buildHeaderCell('Sl No.', 'sl_no', controller),
                              _buildHeaderCell('Order ID', 'order_id', controller),
                              _buildHeaderCell('Item Name', 'item_name', controller),
                              _buildHeaderCell('Requested Qty', 'requested_qty', controller),
                              _buildHeaderCell('Received Qty', 'received_qty', controller),
                              _buildHeaderCell('Difference', 'difference_qty', controller),
                              _buildHeaderCell('Requested On', 'requested_on', controller),
                              _buildHeaderCell('Fulfilled On', 'received_on', controller),
                              _buildHeaderCell('Fulfilled Days', 'fulfilled_days', controller),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
                      // Data Rows
                      Table(
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          border: TableBorder.symmetric(
                            inside: BorderSide(color: Colors.grey.shade300),
                          ),
                          columnWidths: columnWidths,
                          children: paginatedList.map((log) {
                            final isExpanded = _expandedRows.contains(log.logId);
                            return TableRow(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              children: [
                                _buildDataCell('${log.slNo}', isExpanded, () => _toggleRow(log.logId)),
                                _buildDataCell(log.formattedOrderId, isExpanded, () => _toggleRow(log.logId)),
                                _buildDataCell(log.itemName, isExpanded, () => _toggleRow(log.logId)),
                                _buildDataCell(
                                  log.formattedRequestedQty,
                                  isExpanded,
                                  () => _toggleRow(log.logId),
                                  bgColor: const Color(0xFFFFF8E7),
                                ),
                                _buildDataCell(
                                  log.formattedReceivedQty,
                                  isExpanded,
                                  () => _toggleRow(log.logId),
                                  bgColor: const Color(0xFFFFF8E7),
                                ),
                                _buildDataCell(
                                  log.formattedDifferenceQty,
                                  isExpanded,
                                  () => _toggleRow(log.logId),
                                  textColor: const Color(0xFFE05252),
                                ),
                                _buildDataCell(log.formattedRequestedOn, isExpanded, () => _toggleRow(log.logId)),
                                _buildDataCell(log.formattedFulfilledOn, isExpanded, () => _toggleRow(log.logId)),
                                _buildFulfilledDaysCell(log, isExpanded, () => _toggleRow(log.logId)),
                              ],
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Pagination Bar matching Store & Unit Inventory Table
          if (!isLoading)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Showing $startEntry to $endEntry of $totalFiltered entries',
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
                          _buildPaginationButton('←', false, () {
                            if (controller.currentPage.value > 1) {
                              controller.goToPage(controller.currentPage.value - 1);
                            }
                          }),
                          ...List.generate(controller.totalPages, (index) {
                            final pageNumber = index + 1;
                            final isActive = pageNumber == controller.currentPage.value;
                            return _buildPaginationButton(
                              pageNumber.toString(),
                              isActive,
                              () => controller.goToPage(pageNumber),
                            );
                          }),
                          _buildPaginationButton('→', false, () {
                            if (controller.currentPage.value < controller.totalPages) {
                              controller.goToPage(controller.currentPage.value + 1);
                            }
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _buildHeaderCell(
    String label,
    String columnKey,
    InventoryOrderLogsController controller,
  ) {
    final isSorted = controller.sortColumn.value == columnKey;
    return InkWell(
      onTap: () => controller.sortBy(columnKey),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 5.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: AppTextStyle.style_11_700(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSorted) ...[
              SizedBox(width: 2.w),
              Icon(
                controller.sortAscending.value ? Icons.arrow_upward : Icons.arrow_downward,
                size: 11.r,
                color: Colors.white,
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
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.5.h),
        child: Text(
          text,
          style: AppTextStyle.style_10_400(color: textColor ?? AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildFulfilledDaysCell(
    InventoryOrderReceiveLogModel log,
    bool isExpanded,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(color: const Color(0xFFDCFCE7)),
          ),
          child: Text(
            log.fulfilledDaysLabel,
            style: AppTextStyle.style_10_600(color: const Color(0xFF15803D)),
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          ),
        ),
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
}
