import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/support_tickets/views/widgets/multi_select_dropdown.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_audit_controller.dart';
import 'package:skeletonizer/skeletonizer.dart';

class _AuditColumnWidths {
  static double get slNo => 55.w;
  static double get item => 170.w;
  static double get category => 140.w;
  static double get systemQty => 110.w;
  static double get actualQty => 135.w;
  static double get difference => 110.w;

  static double get totalWidth =>
      slNo + item + category + systemQty + actualQty + difference;
}

class AuditTableWidget extends StatelessWidget {
  const AuditTableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InventoryAuditController>();

    return Obx(() {
      if (controller.selectedUnitIds.isEmpty) {
        return _buildEmptyState();
      }
      if (controller.isLoadingItems.value) {
        return _buildSkeletonState(controller);
      }
      if (controller.auditItems.isEmpty) {
        return _buildNoItemsState();
      }
      return _buildMainAuditCard(context, controller);
    });
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 40.r,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 10.h),
              Text(
                'Select a unit above to begin actual inventory count',
                style: AppTextStyle.style_13_400(color: AppColors.grey300),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonState(InventoryAuditController controller) {
    final dummyItems = List.generate(
      6,
      (index) => AuditItem(
        itemId: index + 1,
        itemName: 'Loading Item Name Placeholder',
        categoryName: 'Category Name',
        systemQtyStr: '100 pcs',
        systemQtyNum: 100,
        unitSuffix: 'pcs',
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Skeletonizer(
        enabled: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFF009BD9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5.r),
                  topRight: Radius.circular(5.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_box_outlined,
                        color: Colors.white,
                        size: 16.r,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        'Inventory Audit Items',
                        style: AppTextStyle.style_12_500(color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      'Enter counted quantity in any tab',
                      style: AppTextStyle.style_11_400(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            _buildPillTabsBar(controller),
            Divider(height: 1, color: Colors.grey.shade300),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: _AuditColumnWidths.totalWidth,
                  child: Column(
                    children: [
                      _buildTableHeaderGrid(controller),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: List.generate(dummyItems.length, (index) {
                              final item = dummyItems[index];
                              return Column(
                                children: [
                                  if (index > 0)
                                    Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: Colors.grey.shade200,
                                    ),
                                  _AuditRowGridTile(
                                    index: index,
                                    item: item,
                                    controller: controller,
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoItemsState() {
    return Container(
      height: 160.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'No items found for the selected unit.',
            style: AppTextStyle.style_13_400(color: AppColors.grey300),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildMainAuditCard(
    BuildContext context,
    InventoryAuditController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Cyan Section Banner Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFF009BD9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5.r),
                topRight: Radius.circular(5.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_box_outlined,
                      color: Colors.white,
                      size: 16.r,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'Inventory Audit Items',
                      style: AppTextStyle.style_12_500(color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    'Enter counted quantity in any tab',
                    style: AppTextStyle.style_11_400(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          // 2. Category / Filter Pill Tabs
          _buildPillTabsBar(controller),

          Divider(height: 1, color: Colors.grey.shade300),

          // 3. Scrollable Audit Data Table
          Flexible(
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: _AuditColumnWidths.totalWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTableHeaderGrid(controller),
                    Flexible(
                      fit: FlexFit.loose,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Obx(() {
                          final items = controller.filteredTabAuditItems;
                          final editables = controller.editableAdditionalItems;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Editable additional items inserted at the TOP of the items list
                              ...editables.map((editItem) => Column(
                                    children: [
                                      _EditableRowGridTile(
                                        key: ValueKey(editItem.id),
                                        item: editItem,
                                        controller: controller,
                                      ),
                                      Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: Colors.grey.shade200,
                                      ),
                                    ],
                                  )),
                              if (items.isEmpty && editables.isEmpty)
                                Padding(
                                  padding: EdgeInsets.all(20.h),
                                  child: Center(
                                    child: Text(
                                      'No items in this tab category.',
                                      style: AppTextStyle.style_12_400(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ...List.generate(items.length, (index) {
                                  final item = items[index];
                                  return Column(
                                    children: [
                                      if (index > 0)
                                        Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: Colors.grey.shade200,
                                        ),
                                      _AuditRowGridTile(
                                        key: ValueKey(item.itemId),
                                        index: index,
                                        item: item,
                                        controller: controller,
                                      ),
                                    ],
                                  );
                                }),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillTabsBar(InventoryAuditController controller) {
    return Obx(() {
      final tabs = [
        {
          'title': 'Daily',
          'icon': Icons.calendar_today_outlined,
          'count': controller.countDaily,
        },
        {
          'title': 'Consumable',
          'icon': Icons.cleaning_services_outlined,
          'count': controller.countConsumable,
        },
        {
          'title': 'Non-Consumable',
          'icon': Icons.lock_outline,
          'count': controller.countNonConsumable,
        },
        {
          'title': 'All',
          'icon': Icons.list_alt_outlined,
          'count': controller.countAll,
        },
      ];

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        color: const Color(0xFFF8FAFC),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: tabs.map((tab) {
              final title = tab['title'] as String;
              final icon = tab['icon'] as IconData;
              final count = tab['count'] as int;
              final isSelected = controller.selectedTab.value == title;

              return Padding(
                padding: EdgeInsets.only(right: 5.w),
                child: InkWell(
                  onTap: () => controller.selectTab(title),
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF009BD9)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF009BD9)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 10.r,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade700,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          title,
                          style: AppTextStyle.style_10_500(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.25)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            '$count',
                            style: AppTextStyle.style_10_700(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  Widget _buildTableHeaderGrid(InventoryAuditController controller) {
    return Container(
      height: 32.h,
      color: const Color(0xFF009BD9),
      child: Obx(
        () => Row(
          children: [
            _headerCell(
              'Sl No.',
              controller,
              columnKey: 'slNo',
              width: _AuditColumnWidths.slNo,
              alignment: Alignment.center,
            ),
            _headerCell(
              'Item',
              controller,
              columnKey: 'item',
              width: _AuditColumnWidths.item,
              alignment: Alignment.centerLeft,
            ),
            _headerCell(
              'Category',
              controller,
              columnKey: 'category',
              width: _AuditColumnWidths.category,
              alignment: Alignment.centerLeft,
            ),
            _headerCell(
              'System Qty',
              controller,
              columnKey: 'systemQty',
              width: _AuditColumnWidths.systemQty,
              alignment: Alignment.center,
            ),
            _headerCell(
              'Actual Qty',
              controller,
              columnKey: 'actualQty',
              width: _AuditColumnWidths.actualQty,
              alignment: Alignment.center,
            ),
            _headerCell(
              'Difference',
              controller,
              columnKey: 'difference',
              width: _AuditColumnWidths.difference,
              alignment: Alignment.center,
              hasRightBorder: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(
    String title,
    InventoryAuditController controller, {
    required String columnKey,
    required double width,
    Alignment alignment = Alignment.centerLeft,
    bool hasRightBorder = true,
  }) {
    final isSorted = controller.sortColumn.value == columnKey;
    final isAsc = controller.sortAscending.value;

    return InkWell(
      onTap: () => controller.toggleSort(columnKey),
      child: Container(
        width: width,
        height: double.infinity,
        alignment: alignment,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          border: hasRightBorder
              ? const Border(right: BorderSide(color: Colors.white30))
              : null,
        ),
        child: Row(
          mainAxisAlignment: alignment == Alignment.center
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                title,
                style: AppTextStyle.style_11_700(color: Colors.white),
                overflow: TextOverflow.ellipsis,
                textAlign: alignment == Alignment.center
                    ? TextAlign.center
                    : TextAlign.left,
              ),
            ),
            if (isSorted) ...[
              SizedBox(width: 2.w),
              Icon(
                isAsc ? Icons.arrow_upward : Icons.arrow_downward,
                size: 11.sp,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EditableRowGridTile extends StatelessWidget {
  final EditableAdditionalItem item;
  final InventoryAuditController controller;

  const _EditableRowGridTile({
    super.key,
    required this.item,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38.h,
      color: const Color(0xFFEFF6FF),
      child: Row(
        children: [
          // 1. Sl No.
          Container(
            width: _AuditColumnWidths.slNo,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFF009BD9),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                'NEW',
                style: AppTextStyle.style_10_700(color: Colors.white),
              ),
            ),
          ),
          // 2. Item Name Input
          Container(
            width: _AuditColumnWidths.item,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: TextField(
              controller: item.nameController,
              style: AppTextStyle.style_11_500(color: AppColors.black),
              decoration: InputDecoration(
                hintText: 'Enter item name',
                hintStyle:
                    AppTextStyle.style_10_400(color: Colors.grey.shade400),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.r),
                  borderSide: const BorderSide(color: Color(0xFF009BD9)),
                ),
              ),
              onChanged: (_) => controller.editableAdditionalItems.refresh(),
            ),
          ),
          // 3. Category Badge
          Container(
            width: _AuditColumnWidths.category,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Text(
              'Additional',
              style: AppTextStyle.style_11_600(color: const Color(0xFF009BD9)),
            ),
          ),
          // 4. System Qty
          Container(
            width: _AuditColumnWidths.systemQty,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Text(
              '0',
              style: AppTextStyle.style_11_400(color: Colors.grey.shade500),
            ),
          ),
          // 5. Actual Qty Input
          Container(
            width: _AuditColumnWidths.actualQty,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Center(
              child: SizedBox(
                width: 105.w,
                height: 25.h,
                child: TextField(
                  controller: item.qtyController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: AppTextStyle.style_11_600(color: AppColors.black),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Qty',
                    hintStyle: AppTextStyle.style_10_400(
                        color: Colors.grey.shade400),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 5.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.r),
                      borderSide: const BorderSide(color: Color(0xFF009BD9)),
                    ),
                  ),
                  onChanged: (_) =>
                      controller.editableAdditionalItems.refresh(),
                ),
              ),
            ),
          ),
          // 6. Unit Dropdown & Delete Button
          Container(
            width: _AuditColumnWidths.difference,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            alignment: Alignment.center,
            child: Row(
              children: [
                Expanded(
                  child: Obx(() {
                    return MultiSelectDropdownWidget<String>(
                      isSingleSelect: true,
                      selectedValues: item.selectedUnitId.value.isNotEmpty
                          ? {item.selectedUnitId.value}
                          : {},
                      items: controller.measurementOptions
                          .map<DropdownMenuItem<String>>(
                            (e) => DropdownMenuItem<String>(
                              value: e.value,
                              child: Text(
                                e.label,
                                style: AppTextStyle.style_10_400(
                                    color: AppColors.black),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (set) {
                        if (set.isNotEmpty) {
                          item.selectedUnitId.value = set.first;
                          final opt = controller.measurementOptions
                              .firstWhereOrNull((o) => o.value == set.first);
                          item.selectedUnitName.value = opt?.label ?? '';
                        } else {
                          item.selectedUnitId.value = '';
                          item.selectedUnitName.value = '';
                        }
                        controller.editableAdditionalItems.refresh();
                      },
                      hint: 'Unit',
                    );
                  }),
                ),
                InkWell(
                  onTap: () => controller.removeAdditionalItemRow(item.id),
                  child: Padding(
                    padding: EdgeInsets.all(4.r),
                    child: Icon(
                      Icons.delete_outline,
                      size: 18.r,
                      color: Colors.red.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditRowGridTile extends StatefulWidget {
  final int index;
  final AuditItem item;
  final InventoryAuditController controller;

  const _AuditRowGridTile({
    super.key,
    required this.index,
    required this.item,
    required this.controller,
  });

  @override
  State<_AuditRowGridTile> createState() => _AuditRowGridTileState();
}

class _AuditRowGridTileState extends State<_AuditRowGridTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final textCtrl = widget.controller.qtyControllers[widget.item.itemId];

    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Container(
        color: widget.index.isEven ? Colors.white : const Color(0xFFF9FAFB),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Sl No.
              _cell(
                width: _AuditColumnWidths.slNo,
                alignment: Alignment.center,
                child: Text(
                  '${widget.index + 1}',
                  style: AppTextStyle.style_11_400(color: AppColors.black),
                ),
              ),
              // 2. Item Name
              _cell(
                width: _AuditColumnWidths.item,
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.item.itemName,
                  style: AppTextStyle.style_11_500(color: AppColors.black),
                  maxLines: _isExpanded ? null : 1,
                  overflow: _isExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
              ),
              // 3. Category Name
              _cell(
                width: _AuditColumnWidths.category,
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.item.categoryName,
                  style: AppTextStyle.style_11_400(color: Colors.grey.shade700),
                  maxLines: _isExpanded ? null : 1,
                  overflow: _isExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
              ),
              // 4. System Qty
              _cell(
                width: _AuditColumnWidths.systemQty,
                alignment: Alignment.center,
                child: Text(
                  widget.item.systemQtyStr,
                  style: AppTextStyle.style_11_700(color: AppColors.black),
                  textAlign: TextAlign.center,
                ),
              ),
              // 5. Actual Qty (Centered input box with hint "Enter Qty")
              _cell(
                width: _AuditColumnWidths.actualQty,
                alignment: Alignment.center,
                child: Center(
                  child: SizedBox(
                    width: 105.w,
                    height: 25.h,
                    child: TextField(
                      controller: textCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      style: AppTextStyle.style_11_600(color: AppColors.black),
                      decoration: InputDecoration(
                        hintText: 'Enter Qty',
                        hintStyle: AppTextStyle.style_10_400(
                          color: Colors.grey.shade400,
                        ),
                        isDense: true,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 5.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.r),
                          borderSide: const BorderSide(
                            color: Color(0xFF009BD9),
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        widget.controller.setQty(widget.item.itemId, val);
                      },
                    ),
                  ),
                ),
              ),
              // 6. Difference (Live calculated)
              _cell(
                width: _AuditColumnWidths.difference,
                alignment: Alignment.center,
                hasRightBorder: false,
                child: Obx(() {
                  final diffText = widget.controller.calculateDifferenceText(
                    widget.item,
                  );
                  return Text(
                    diffText,
                    style: AppTextStyle.style_11_500(
                      color:
                          diffText.startsWith('-') && !diffText.startsWith('- ')
                          ? Colors.grey.shade700
                          : (diffText.startsWith('+')
                                ? Colors.green.shade700
                                : AppColors.black),
                    ),
                    textAlign: TextAlign.center,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cell({
    required Widget child,
    required double width,
    Alignment alignment = Alignment.centerLeft,
    bool hasRightBorder = true,
  }) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      alignment: alignment,
      decoration: BoxDecoration(
        border: hasRightBorder
            ? Border(right: BorderSide(color: Colors.grey.shade300))
            : null,
      ),
      child: child,
    );
  }
}
