import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
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
  final Set<String> _expandedRows = {};
  bool _isOrderTableExpanded = true;
  bool _isRequiredOrdersExpanded = true;

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
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade200),
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
                      color: const Color(0xFFEBF3FA),
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
                              style: AppTextStyle.style_12_600(color: const Color(0xFF1E3A5F)),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade200),
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
                      color: const Color(0xFFEBF3FA),
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
                              style: AppTextStyle.style_12_600(color: const Color(0xFF1E3A5F)),
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
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(8.r),
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
          color: isSelected ? Colors.white : Colors.transparent,
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
                    : Colors.grey.shade300,
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

  Widget _buildSectionHeader(
    String title,
    int count,
    IconData icon,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, size: 16.r, color: AppColors.primary),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    title,
                    style: AppTextStyle.style_12_700(color: AppColors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
          ),
        ],
      ),
    );
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
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
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
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
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

    final Map<int, TableColumnWidth> colWidths = {
      0: FixedColumnWidth(70.w),  // Order ID
      1: FixedColumnWidth(110.w), // Item
    };

    int colIdx = 2;
    for (int i = 0; i < locationNames.length; i++) {
      colWidths[colIdx++] = FixedColumnWidth(75.w);
    }
    colWidths[colIdx++] = FixedColumnWidth(120.w); // Requested By
    colWidths[colIdx++] = FixedColumnWidth(110.w); // Status
    colWidths[colIdx++] = FixedColumnWidth(120.w); // Processed By
    colWidths[colIdx++] = FixedColumnWidth(135.w); // Action

    if (!isLoading && groupedRows.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 6.w),
        padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 40.r,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 8.h),
              Text(
                'No orders available',
                style: AppTextStyle.style_14_500(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w),
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
              columnWidths: colWidths,
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFE8F1F8)),
                  children: [
                    _buildHeaderCell(controller, 'Order ID', isUnit: isUnit),
                    _buildHeaderCell(controller, 'Item', isUnit: isUnit),
                    ...locationNames.map(
                      (locName) => _buildHeaderCell(
                        controller,
                        locName,
                        sortKey: locName,
                        isUnit: isUnit,
                      ),
                    ),
                    _buildHeaderCell(controller, 'Requested By', isUnit: isUnit),
                    _buildHeaderCell(controller, 'Status', isUnit: isUnit),
                    _buildHeaderCell(controller, 'Processed By', isUnit: isUnit),
                    _buildHeaderCell(controller, 'Action', isUnit: isUnit),
                  ],
                ),
                ...groupedRows.asMap().entries.map((entry) {
                  final index = entry.key;
                  final row = entry.value;
                  final key = 'order_${isUnit ? "unit" : "store"}_${row.orderId}_${row.itemId}_$index';
                  final isExpanded = _expandedRows.contains(key);

                  return TableRow(
                    children: [
                      _buildDataCell(
                        '#${row.orderId}',
                        isExpanded,
                        () => _toggleRow(key),
                      ),
                      _buildDataCell(
                        row.itemName,
                        isExpanded,
                        () => _toggleRow(key),
                      ),
                      ...locationNames.map((locName) {
                        final locOrder = row.locationOrders[locName];
                        if (locOrder != null) {
                          return _buildDataCell(
                            locOrder.formattedQty,
                            isExpanded,
                            () => _toggleRow(key),
                            bgColor: const Color(0xFFFFF8E7),
                          );
                        }
                        return _buildDataCell(
                          '-',
                          isExpanded,
                          () => _toggleRow(key),
                        );
                      }),
                      _buildDataCell(
                        row.requestedBy?.name ?? '-',
                        isExpanded,
                        () => _toggleRow(key),
                      ),
                      _buildStatusCell(
                        row.status,
                        row.statusName,
                        isExpanded,
                        () => _toggleRow(key),
                      ),
                      _buildDataCell(
                        row.processedBy?.name ?? '-',
                        isExpanded,
                        () => _toggleRow(key),
                      ),
                      _buildActionCellForGroupedRow(row),
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
    required bool isUnit,
  }) {
    final key = sortKey ?? text;
    final sortColumn = isUnit ? controller.unitSortColumn.value : controller.storeSortColumn.value;
    final isAsc = isUnit ? controller.unitSortAscending.value : controller.storeSortAscending.value;
    final isSorted = sortColumn == key;

    return InkWell(
      onTap: key.isNotEmpty && key != 'Action'
          ? () {
              if (isUnit) {
                controller.sortByUnit(key);
              } else {
                controller.sortByStore(key);
              }
            }
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
    int status,
    String statusName,
    bool isExpanded,
    VoidCallback onTap,
  ) {
    Widget childWidget;

    if (status == 0) {
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
    } else if (status == 1) {
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
    } else if (status == 2) {
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
        statusName,
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

  Widget _buildActionCellForGroupedRow(_GroupedOrderRow row) {
    final processableOrders =
        row.locationOrders.values.where((o) => o.canProcess).toList();

    if (processableOrders.isNotEmpty) {
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
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        for (var order in processableOrders) {
                          await Get.find<InventoryOrdersController>().completeOrder(order);
                        }
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

    if (row.status == 1 || row.statusName == 'Waiting for Receive') {
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
