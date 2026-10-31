import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_table.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_table_pagination.dart';
import '../../controllers/inventory_orders_controller.dart';
import 'package:mfresh_ops/data/models/inventory/inventory_order_model.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'unit_required_orders_dialog.dart';
import 'store_required_orders_dialog.dart';

class _GroupedOrderRow {
  final int orderId;
  final int itemId;
  final String itemName;
  final InventoryOrderUser? requestedBy;
  final InventoryOrderUser? processedBy;
  final int status;
  final String statusName;
  final bool canProcess;
  final bool canReceive;
  final Map<String, InventoryOrderModel> locationOrders;

  _GroupedOrderRow({
    required this.orderId,
    required this.itemId,
    required this.itemName,
    this.requestedBy,
    this.processedBy,
    required this.status,
    required this.statusName,
    required this.canProcess,
    required this.canReceive,
    required this.locationOrders,
  });
}

class InventoryOrdersTable extends StatefulWidget {
  const InventoryOrdersTable({super.key});

  @override
  State<InventoryOrdersTable> createState() => _InventoryOrdersTableState();
}

class _InventoryOrdersTableState extends State<InventoryOrdersTable> {
  final Set<int> _expandedRowIndices = {};
  bool _isOrderTableExpanded = true;
  bool _isRequiredOrdersExpanded = true;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InventoryOrdersController>();

    return Obx(() {
      final userPermissions = Get.find<AuthRepository>().rxUserPermissions;
      final canUnitOrder = userPermissions.contains('Inv_Unit_Order');
      final canStoreOrder = userPermissions.contains('Inv_Store_Order');

      if (!canUnitOrder && !canStoreOrder) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Center(
            child: Text(
              'You do not have permission to view Unit or Store orders.',
              style: AppTextStyle.style_12_400(color: AppColors.grey500),
            ),
          ),
        );
      }

      if (canUnitOrder && !canStoreOrder) {
        if (controller.selectedTab.value != InventoryOrderTab.unit) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.setTab(InventoryOrderTab.unit);
          });
        }
      } else if (canStoreOrder && !canUnitOrder) {
        if (controller.selectedTab.value != InventoryOrderTab.store) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.setTab(InventoryOrderTab.store);
          });
        }
      }

      final unitOrders = controller.filteredUnitOrders;
      final storeOrders = controller.filteredStoreOrders;
      final paginatedUnitOrders = controller.paginatedUnitOrders;
      final paginatedStoreOrders = controller.paginatedStoreOrders;
      final isLoading = controller.isLoading.value;

      final bulkPreview = controller.bulkPreview.value;

      final unitColumnNames = controller.unitColumnNames;
      final storeColumnNames = controller.storeColumnNames;

      final currentTab = controller.selectedTab.value;
      final isUnitTab = currentTab == InventoryOrderTab.unit;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab Switcher (Unit / Store) - show only if user has access to BOTH
          if (canUnitOrder && canStoreOrder) ...[
            _buildTabSwitcher(controller),
            SizedBox(height: 8.h),
          ],

          // ── Order Requests Expandable Card ──
          if ((isUnitTab && canUnitOrder) || (!isUnitTab && canStoreOrder))
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expandable header
                  InkWell(
                    onTap: () => setState(() => _isOrderTableExpanded = !_isOrderTableExpanded),
                    child: Container(
                      color: AppColors.blue50,
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      child: Row(
                        children: [
                          Icon(
                            isUnitTab ? Icons.domain_rounded : Icons.storefront_rounded,
                            size: 15.r,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              isUnitTab ? 'Unit Order Requests' : 'Store Order Requests',
                              style: AppTextStyle.style_12_600(color: AppColors.black),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              '${isUnitTab ? unitOrders.length : storeOrders.length}',
                              style: AppTextStyle.style_10_600(color: AppColors.primary),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          AnimatedRotation(
                            turns: _isOrderTableExpanded ? 0 : -0.25,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(Icons.keyboard_arrow_down_rounded,
                                size: 18.r, color: AppColors.grey600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Animated content
                  AnimatedCrossFade(
                    firstChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8.h),
                        _buildOrderTable(
                          controller: controller,
                          orders: isUnitTab ? paginatedUnitOrders : paginatedStoreOrders,
                          locationNames: isUnitTab ? unitColumnNames : storeColumnNames,
                          isLoading: isLoading,
                          isUnit: isUnitTab,
                        ),
                        if (!isLoading &&
                            (isUnitTab ? unitOrders.isNotEmpty : storeOrders.isNotEmpty))
                          isUnitTab
                              ? _buildUnitPagination(controller, unitOrders.length)
                              : _buildStorePagination(controller, storeOrders.length),
                        SizedBox(height: 8.h),
                      ],
                    ),
                    secondChild: const SizedBox.shrink(),
                    crossFadeState: _isOrderTableExpanded
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 250),
                    sizeCurve: Curves.easeInOut,
                  ),
                ],
              ),
            ),

          SizedBox(height: 10.h),

          // ── Required Orders Expandable Card ──
          if ((isUnitTab && canUnitOrder) || (!isUnitTab && canStoreOrder))
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expandable header
                  InkWell(
                    onTap: () => setState(() => _isRequiredOrdersExpanded = !_isRequiredOrdersExpanded),
                    child: Container(
                      color: AppColors.blue50,
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 15.r,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              isUnitTab ? 'Unit Required Orders' : 'Store Required Orders',
                              style: AppTextStyle.style_12_600(color: AppColors.black),
                            ),
                          ),
                          AnimatedRotation(
                            turns: _isRequiredOrdersExpanded ? 0 : -0.25,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(Icons.keyboard_arrow_down_rounded,
                                size: 18.r, color: AppColors.grey600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Animated content
                  AnimatedCrossFade(
                    firstChild: isUnitTab
                        ? UnitRequiredOrdersDialog(
                            bulkPreviewSection: bulkPreview.unitOrders,
                          )
                        : StoreRequiredOrdersDialog(
                            bulkPreviewSection: bulkPreview.storeOrders,
                          ),
                    secondChild: const SizedBox.shrink(),
                    crossFadeState: _isRequiredOrdersExpanded
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 250),
                    sizeCurve: Curves.easeInOut,
                  ),
                ],
              ),
            ),
          SizedBox(height: 16.h),
        ],
      );
    });
  }

  Widget _buildTabSwitcher(InventoryOrdersController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              title: 'Unit Orders',
              count: controller.filteredUnitOrders.length,
              icon: Icons.domain_rounded,
              isSelected: controller.selectedTab.value == InventoryOrderTab.unit,
              onTap: () => controller.setTab(InventoryOrderTab.unit),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: _buildTabItem(
              title: 'Store Orders',
              count: controller.filteredStoreOrders.length,
              icon: Icons.storefront_rounded,
              isSelected: controller.selectedTab.value == InventoryOrderTab.store,
              onTap: () => controller.setTab(InventoryOrderTab.store),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required int count,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : AppColors.transparent,
          borderRadius: BorderRadius.circular(6.r),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.black.withValues(alpha: 0.05)
                  : Colors.transparent,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16.r,
              color: isSelected ? AppColors.primary : AppColors.grey600,
            ),
            SizedBox(width: 6.w),
            Text(
              title,
              style: isSelected
                  ? AppTextStyle.style_12_700(color: AppColors.primary)
                  : AppTextStyle.style_12_500(color: AppColors.grey600),
            ),
            SizedBox(width: 6.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.borderColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '$count',
                style: AppTextStyle.style_10_600(
                  color: isSelected ? AppColors.primary : AppColors.grey700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_GroupedOrderRow> _groupOrders(List<InventoryOrderModel> rawOrders) {
    final Map<String, _GroupedOrderRow> groupedMap = {};

    for (var order in rawOrders) {
      final key = '${order.orderId}_${order.itemId}';
      final locName = order.displayName;

      if (!groupedMap.containsKey(key)) {
        groupedMap[key] = _GroupedOrderRow(
          orderId: order.orderId,
          itemId: order.itemId,
          itemName: order.itemName,
          requestedBy: order.requestedBy,
          processedBy: order.processedBy,
          status: order.status,
          statusName: order.statusName,
          canProcess: order.canProcess,
          canReceive: order.canReceive,
          locationOrders: {locName: order},
        );
      } else {
        final existing = groupedMap[key]!;
        existing.locationOrders[locName] = order;
      }
    }

    return groupedMap.values.toList();
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
      child: AppTablePagination(
        startItem: startItem,
        endItem: endItem,
        totalItems: totalItems,
        currentPage: controller.unitCurrentPage.value,
        totalPages: controller.unitTotalPages,
        onPageChanged: (page) => controller.setUnitPage(page),
        onPreviousPage: controller.previousUnitPage,
        onNextPage: controller.nextUnitPage,
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
      child: AppTablePagination(
        startItem: startItem,
        endItem: endItem,
        totalItems: totalItems,
        currentPage: controller.storeCurrentPage.value,
        totalPages: controller.storeTotalPages,
        onPageChanged: (page) => controller.setStorePage(page),
        onPreviousPage: controller.previousStorePage,
        onNextPage: controller.nextStorePage,
      ),
    );
  }

  Widget _buildOrderTable({
    required InventoryOrdersController controller,
    required List<InventoryOrderModel> orders,
    required List<String> locationNames,
    required bool isLoading,
    required bool isUnit,
  }) {
    final ordersToRender = isLoading
        ? List.generate(
            4,
            (index) => InventoryOrderModel(
              id: index,
              orderId: index,
              orderType: isUnit ? 'unit' : 'store',
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

    final groupedRows = _groupOrders(ordersToRender);

    final sortColumn = isUnit
        ? controller.unitSortColumn.value
        : controller.storeSortColumn.value;
    final isAsc = isUnit
        ? controller.unitSortAscending.value
        : controller.storeSortAscending.value;
    final currentSortOrder = sortColumn.isEmpty
        ? AppTableSortOrder.none
        : (isAsc ? AppTableSortOrder.ascending : AppTableSortOrder.descending);

    if (!isLoading) {
      groupedRows.sort((a, b) {
        if (sortColumn.isEmpty || sortColumn == 'ID' || sortColumn == 'Order ID') {
          final asc = sortColumn.isEmpty ? false : isAsc;
          return asc
              ? a.orderId.compareTo(b.orderId)
              : b.orderId.compareTo(a.orderId);
        } else if (sortColumn == 'Item') {
          return isAsc
              ? a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase())
              : b.itemName.toLowerCase().compareTo(a.itemName.toLowerCase());
        } else if (sortColumn == 'Requested By') {
          final aReq = a.requestedBy?.name ?? '';
          final bReq = b.requestedBy?.name ?? '';
          return isAsc
              ? aReq.toLowerCase().compareTo(bReq.toLowerCase())
              : bReq.toLowerCase().compareTo(aReq.toLowerCase());
        } else if (sortColumn == 'Status') {
          return isAsc
              ? a.status.compareTo(b.status)
              : b.status.compareTo(a.status);
        } else if (sortColumn == 'Processed By') {
          final aProc = a.processedBy?.name ?? '';
          final bProc = b.processedBy?.name ?? '';
          return isAsc
              ? aProc.toLowerCase().compareTo(bProc.toLowerCase())
              : bProc.toLowerCase().compareTo(aProc.toLowerCase());
        }
        return 0;
      });
    }

    final List<AppTableColumn<_GroupedOrderRow>> columns = [
      AppTableColumn<_GroupedOrderRow>(
        key: 'ID',
        title: 'ID',
        width: 45.w,
        valueGetter: (item) => '#${item.orderId}',
      ),
      AppTableColumn<_GroupedOrderRow>(
        key: 'Item',
        title: 'Item',
        width: 110.w,
        valueGetter: (item) => item.itemName,
      ),
      ...locationNames.map(
        (locName) => AppTableColumn<_GroupedOrderRow>(
          key: locName,
          title: locName,
          width: 95.w,
          cellColorGetter: (item) => item.locationOrders.containsKey(locName)
              ? AppColors.yellow50
              : null,
          valueGetter: (item) =>
              item.locationOrders[locName]?.formattedQty ?? '-',
        ),
      ),
      AppTableColumn<_GroupedOrderRow>(
        key: 'Requested By',
        title: 'Requested By',
        width: 106.w,
        valueGetter: (item) => item.requestedBy?.name ?? '-',
      ),
      AppTableColumn<_GroupedOrderRow>(
        key: 'Status',
        title: 'Status',
        width: 66.w,
        cellBuilder: (context, item, index, isExpanded) =>
            _buildStatusCell(item.status, item.statusName, isExpanded),
      ),
      AppTableColumn<_GroupedOrderRow>(
        key: 'Processed By',
        title: 'Processed By',
        width: 106.w,
        valueGetter: (item) => item.processedBy?.name ?? '-',
      ),
      AppTableColumn<_GroupedOrderRow>(
        key: 'Action',
        title: 'Action',
        width: 102.w,
        sortable: false,
        cellBuilder: (context, item, index, isExpanded) =>
            _buildActionCellForGroupedRow(item),
      ),
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      child: AppCommonTable<_GroupedOrderRow>(
        items: groupedRows,
        columns: columns,
        currentSortColumn: sortColumn,
        currentSortOrder: currentSortOrder,
        onSort: (columnKey, sortOrder) {
          if (isUnit) {
            controller.sortByUnit(columnKey);
          } else {
            controller.sortByStore(columnKey);
          }
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
        isLoading: isLoading,
        headingRowColor: AppColors.blue50,
        headingTextStyle: AppTextStyle.style_11_700(color: AppColors.black),
        dataTextStyle: AppTextStyle.style_11_500(color: AppColors.black),
        borderColor: AppColors.borderColor,
        headingRowHeight: 20.h,
        cellVerticalPadding: 1.h,
        cellHorizontalPadding: 4.w,
        emptyText: 'No orders available',
      ),
    );
  }

  Widget _buildStatusCell(
    int status,
    String statusName,
    bool isExpanded,
  ) {
    if (status == 0) {
      // Pending
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.yellow50,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: AppColors.yellow100),
        ),
        child: Text(
          'Pending',
          style: AppTextStyle.style_10_600(color: AppColors.warning),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
      );
    } else if (status == 1) {
      // Waiting for Receive
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.blue50,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: AppColors.blue100),
        ),
        child: Text(
          'Waiting for Receive',
          style: AppTextStyle.style_10_600(color: AppColors.info),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
      );
    } else if (status == 2) {
      // Completed
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.orange50,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: AppColors.orange100),
        ),
        child: Text(
          'Completed',
          style: AppTextStyle.style_10_600(color: AppColors.primaryGreen),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
      );
    } else {
      return Text(
        statusName,
        style: AppTextStyle.style_10_400(color: AppColors.black),
        maxLines: isExpanded ? null : 1,
        overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
      );
    }
  }

  Widget _buildActionCellForGroupedRow(_GroupedOrderRow row) {
    final processableOrders =
        row.locationOrders.values.where((o) => o.canProcess).toList();

    if (processableOrders.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: AppCommonButton(
          text: 'Complete Order',
          height: 16.h,
          textSize: 9.5.sp,
          borderRadius: 4.r,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          buttonColor: AppColors.warning,
          useGradient: false,
          onPressed: () {
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                backgroundColor: AppColors.white,
                title: Text(
                  'Confirm Action',
                  style: AppTextStyle.style_16_600(color: AppColors.black),
                ),
                content: Text(
                  'Are you sure you want to process this order?',
                  style: AppTextStyle.style_14_400(color: AppColors.grey700),
                ),
                actions: [
                  AppCommonButton(
                    text: 'Cancel',
                    width: 70.w,
                    height: 28.h,
                    variant: ButtonVariant.outline,
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                  SizedBox(width: 8.w),
                  AppCommonButton(
                    text: 'Confirm',
                    width: 70.w,
                    height: 28.h,
                    buttonColor: AppColors.primary,
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      for (var order in processableOrders) {
                        await Get.find<InventoryOrdersController>().completeOrder(order);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    if (row.status == 1 || row.statusName == 'Waiting for Receive') {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: AppCommonButton(
          text: 'Inventory Dispatched',
          height: 16.h,
          textSize: 9.5.sp,
          borderRadius: 4.r,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          buttonColor: AppColors.info,
          useGradient: false,
          onPressed: null,
        ),
      );
    }

    return Text(
      '-',
      style: AppTextStyle.style_12_400(color: AppColors.grey500),
    );
  }
}
