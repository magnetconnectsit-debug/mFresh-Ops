import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_image_view.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_audit_controller.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AuditTableWidget extends StatelessWidget {
  static double get itemColWidth => 105.w;
  static double get categoryColWidth => 85.w;
  static double get actualQtyColWidth => 80.w;
  static double get imagesColWidth => 65.w;
  static double get totalTableWidth =>
      itemColWidth + categoryColWidth + actualQtyColWidth + imagesColWidth;

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
                  width: totalTableWidth,
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

          // 3. Audit Data Table
          Flexible(
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: totalTableWidth,
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
                          final additionals = controller.additionalAuditItems;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Additional items added via dialog
                              ...additionals.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final add = entry.value;
                                return Column(
                                  children: [
                                    _AdditionalAuditItemRowTile(
                                      key: ValueKey('add_$idx'),
                                      index: idx,
                                      item: add,
                                      controller: controller,
                                    ),
                                    Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: Colors.grey.shade200,
                                    ),
                                  ],
                                );
                              }),
                              if (items.isEmpty && additionals.isEmpty)
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
                                      if (index > 0 || additionals.isNotEmpty)
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
            SizedBox(
              width: itemColWidth,
              child: _headerCell(
                'Item',
                controller,
                columnKey: 'item',
                alignment: Alignment.centerLeft,
              ),
            ),
            SizedBox(
              width: categoryColWidth,
              child: _headerCell(
                'Category',
                controller,
                columnKey: 'category',
                alignment: Alignment.centerLeft,
              ),
            ),
            SizedBox(
              width: actualQtyColWidth,
              child: _headerCell(
                'Actual Qty',
                controller,
                columnKey: 'actualQty',
                alignment: Alignment.center,
                hasRightBorder: true,
                enableSort: false,
              ),
            ),
            SizedBox(
              width: imagesColWidth,
              child: _headerCell(
                'Images',
                controller,
                columnKey: 'image',
                alignment: Alignment.center,
                hasRightBorder: false,
                enableSort: false,
              ),
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
    Alignment alignment = Alignment.centerLeft,
    bool hasRightBorder = true,
    bool enableSort = true,
  }) {
    final isSorted = enableSort && controller.sortColumn.value == columnKey;
    final isAsc = controller.sortAscending.value;

    return InkWell(
      onTap: enableSort ? () => controller.toggleSort(columnKey) : null,
      child: Container(
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

class _AdditionalAuditItemRowTile extends StatelessWidget {
  final int index;
  final AdditionalAuditItem item;
  final InventoryAuditController controller;

  const _AdditionalAuditItemRowTile({
    super.key,
    required this.index,
    required this.item,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final qtyStr = item.actualQty % 1 == 0
        ? item.actualQty.toInt().toString()
        : item.actualQty.toStringAsFixed(2);
    final displayQty = '${qtyStr} ${item.measurementUnitName}';

    return Container(
      color: const Color(0xFFEFF6FF),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Item Name
            SizedBox(
              width: AuditTableWidget.itemColWidth,
              child: _cell(
                alignment: Alignment.centerLeft,
                child: Text(
                  item.itemName,
                  style: AppTextStyle.style_11_600(color: AppColors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Category Badge
            SizedBox(
              width: AuditTableWidget.categoryColWidth,
              child: _cell(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF009BD9).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'Additional',
                    style: AppTextStyle.style_10_600(color: const Color(0xFF009BD9)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            // Actual Qty with Unit Name
            SizedBox(
              width: AuditTableWidget.actualQtyColWidth,
              child: _cell(
                alignment: Alignment.center,
                hasRightBorder: true,
                child: Text(
                  displayQty,
                  style: AppTextStyle.style_11_600(color: const Color(0xFF009BD9)),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Item Image + Delete Action
            SizedBox(
              width: AuditTableWidget.imagesColWidth,
              child: _cell(
                alignment: Alignment.center,
                hasRightBorder: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.images.isNotEmpty) ...[
                      GestureDetector(
                        onTap: () => openFullScreenImageViewer(context, item.images, 0),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4.r),
                              child: Image.file(
                                item.images.first,
                                width: 22.r,
                                height: 22.r,
                                fit: BoxFit.cover,
                              ),
                            ),
                            if (item.images.length > 1)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF009BD9),
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(color: Colors.white, width: 1),
                                  ),
                                  child: Text(
                                    '+${item.images.length - 1}',
                                    style: TextStyle(
                                      fontSize: 8.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(width: 4.w),
                    ],
                    InkWell(
                      onTap: () => controller.removeAdditionalItem(index),
                      child: Padding(
                        padding: EdgeInsets.all(2.r),
                        child: Icon(
                          Icons.delete_outline,
                          size: 16.r,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell({
    required Widget child,
    Alignment alignment = Alignment.centerLeft,
    bool hasRightBorder = true,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
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
              // Item Name
              SizedBox(
                width: AuditTableWidget.itemColWidth,
                child: _cell(
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
              ),
              // Category Name
              SizedBox(
                width: AuditTableWidget.categoryColWidth,
                child: _cell(
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
              ),
              // Actual Qty
              SizedBox(
                width: AuditTableWidget.actualQtyColWidth,
                child: _cell(
                  alignment: Alignment.center,
                  hasRightBorder: true,
                  child: Center(
                    child: SizedBox(
                      width: AuditTableWidget.actualQtyColWidth > 20.w
                          ? AuditTableWidget.actualQtyColWidth - 10.w
                          : AuditTableWidget.actualQtyColWidth,
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
              ),
              // Item Images
              SizedBox(
                width: AuditTableWidget.imagesColWidth,
                child: _cell(
                  alignment: Alignment.center,
                  hasRightBorder: false,
                  child: Obx(() {
                    final qtyStr = widget.controller.auditQtys[widget.item.itemId]?.trim() ?? '';
                    final qtyNum = double.tryParse(qtyStr) ?? 0.0;
                    final isRequired = qtyNum > 0;

                    final imageFiles =
                        widget.controller.itemImages[widget.item.itemId] ?? [];
                    return _buildImageCell(
                      context,
                      imageFiles,
                      () {
                        _showImageSourceSheet(
                          context: context,
                          hasExistingImage: imageFiles.isNotEmpty,
                          imageFiles: imageFiles,
                          onSelectSource: (source) {
                            widget.controller.pickImageForAuditItem(
                              widget.item.itemId,
                              source,
                            );
                          },
                          onRemoveImageAt: (idx) {
                            widget.controller.removeImageForAuditItemAt(
                              widget.item.itemId,
                              idx,
                            );
                          },
                          onRemoveImage: () {
                            widget.controller.removeImageForAuditItem(
                              widget.item.itemId,
                            );
                          },
                        );
                      },
                      isRequired: isRequired,
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cell({
    required Widget child,
    Alignment alignment = Alignment.centerLeft,
    bool hasRightBorder = true,
  }) {
    return Container(
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

void _showImageSourceSheet({
  required BuildContext context,
  required Function(ImageSource source) onSelectSource,
  VoidCallback? onRemoveImage,
  Function(int index)? onRemoveImageAt,
  List<File> imageFiles = const [],
  bool hasExistingImage = false,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Select Image Source',
            style: AppTextStyle.style_15_700(color: AppColors.black),
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              _buildSourceTile(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                color: const Color(0xFF009BD9),
                onTap: () {
                  Navigator.pop(ctx);
                  onSelectSource(ImageSource.camera);
                },
              ),
              SizedBox(width: 12.w),
              _buildSourceTile(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                color: const Color(0xFF10B981),
                onTap: () {
                  Navigator.pop(ctx);
                  onSelectSource(ImageSource.gallery);
                },
              ),
            ],
          ),
          if (imageFiles.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Attached Images (${imageFiles.length})',
                  style: AppTextStyle.style_12_600(color: AppColors.black),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    openFullScreenImageViewer(context, imageFiles, 0);
                  },
                  child: Text(
                    'View Full Screen',
                    style: AppTextStyle.style_11_600(
                      color: const Color(0xFF009BD9),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: imageFiles.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final img = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            openFullScreenImageViewer(context, imageFiles, idx);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.r),
                            child: Image.file(
                              img,
                              width: 44.r,
                              height: 44.r,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -4,
                          top: -4,
                          child: GestureDetector(
                            onTap: () {
                              onRemoveImageAt?.call(idx);
                              Navigator.pop(ctx);
                            },
                            child: Container(
                              padding: EdgeInsets.all(1.r),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.cancel,
                                size: 16.r,
                                color: Colors.red.shade500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          if (hasExistingImage && onRemoveImage != null) ...[
            SizedBox(height: 14.h),
            InkWell(
              onTap: () {
                Navigator.pop(ctx);
                onRemoveImage();
              },
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline, size: 16.r, color: Colors.red.shade600),
                    SizedBox(width: 6.w),
                    Text(
                      'Remove All Images',
                      style: AppTextStyle.style_12_600(color: Colors.red.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(height: 10.h),
        ],
      ),
    ),
  );
}

Widget _buildSourceTile({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28.r),
            SizedBox(height: 6.h),
            Text(
              label,
              style: AppTextStyle.style_13_600(color: AppColors.black),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildImageCell(
  BuildContext context,
  List<File> imageFiles,
  VoidCallback onTap, {
  bool isRequired = false,
}) {
  if (imageFiles.isEmpty) {
    final isError = isRequired;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: isError ? Colors.red.shade50 : const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(
            color: isError ? Colors.red.shade300 : const Color(0xFFBAE6FD),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 12.r,
              color: isError ? Colors.red.shade600 : const Color(0xFF009BD9),
            ),
            SizedBox(width: 3.w),
            Text(
              isError ? 'Add *' : 'Add',
              style: AppTextStyle.style_10_600(
                color: isError ? Colors.red.shade600 : const Color(0xFF009BD9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 3.w),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Thumbnail left aligned with +N badge over image if more than 1
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: Image.file(
                  imageFiles.first,
                  width: 24.r,
                  height: 24.r,
                  fit: BoxFit.cover,
                ),
              ),
              if (imageFiles.length > 1)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF009BD9),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Text(
                      '+${imageFiles.length - 1}',
                      style: TextStyle(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // '+' icon button on the right side to add more images
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            padding: EdgeInsets.all(2.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Icon(
              Icons.add,
              size: 13.r,
              color: const Color(0xFF009BD9),
            ),
          ),
        ),
      ],
    ),
  );
}

void openFullScreenImageViewer(
  BuildContext context,
  List<dynamic> images, [
  int initialIndex = 0,
]) {
  if (images.isEmpty) return;

  showDialog(
    context: context,
    builder: (dialogCtx) {
      int currentIndex = initialIndex;
      final pageController = PageController(initialPage: initialIndex);

      return StatefulBuilder(
        builder: (ctx, setModalState) {
          return Dialog(
            backgroundColor: Colors.black.withValues(alpha: 0.92),
            insetPadding: EdgeInsets.zero,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: pageController,
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setModalState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final img = images[index];
                    Widget childWidget;
                    if (img is File) {
                      childWidget = Image.file(img, fit: BoxFit.contain);
                    } else if (img is String &&
                        (img.startsWith('http://') ||
                            img.startsWith('https://'))) {
                      childWidget = AppImageView(
                        imageUrl: img,
                        fit: BoxFit.contain,
                      );
                    } else if (img is String) {
                      final f = File(img);
                      if (f.existsSync()) {
                        childWidget = Image.file(f, fit: BoxFit.contain);
                      } else {
                        childWidget = AppImageView(
                          imageUrl: img,
                          fit: BoxFit.contain,
                        );
                      }
                    } else {
                      childWidget = const SizedBox.shrink();
                    }

                    return InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Center(child: childWidget),
                    );
                  },
                ),
                if (currentIndex > 0)
                  Positioned(
                    left: 16.w,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      radius: 20.r,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 18.r),
                        onPressed: () {
                          pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ),
                if (currentIndex < images.length - 1)
                  Positioned(
                    right: 16.w,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      radius: 20.r,
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios,
                            color: Colors.white, size: 18.r),
                        onPressed: () {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ),
                Positioned(
                  top: 40.h,
                  left: 20.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      '${currentIndex + 1} / ${images.length}',
                      style: AppTextStyle.style_12_600(color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  top: 40.h,
                  right: 20.w,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    radius: 20.r,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 20.r),
                      onPressed: () => Navigator.pop(dialogCtx),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
