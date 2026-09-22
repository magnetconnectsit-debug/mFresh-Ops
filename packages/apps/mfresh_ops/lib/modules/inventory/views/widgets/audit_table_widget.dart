import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import '../../controllers/inventory_audit_controller.dart';

// ── Centralized Column Width Configuration ────────────────────────────
// Changing any column width here automatically updates both Header & Body cells!
class _AuditColumnWidths {
  static double get slNo => 50.w;
  static double get item => 140.w;
  static double get category => 130.w;
  static double get systemQty => 110.w;
  static double get actualQty => 120.w;
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
        return _buildLoadingState();
      }
      if (controller.auditItems.isEmpty) {
        return _buildNoItemsState();
      }
      return _buildTableGrid(context, controller);
    });
  }

  // ── States ─────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 40.r, color: Colors.grey.shade400),
            SizedBox(height: 10.h),
            Text(
              'Select a unit to begin audit',
              style: AppTextStyle.style_13_400(color: AppColors.grey300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildNoItemsState() {
    return Container(
      height: 160.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Text(
          'No items found for the selected unit.',
          style: AppTextStyle.style_13_400(color: AppColors.grey300),
        ),
      ),
    );
  }

  // ── Scrollable Grid Table with Centralized Column Widths ─────────────

  Widget _buildTableGrid(
      BuildContext context, InventoryAuditController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: _AuditColumnWidths.totalWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ocean blue header row
              _buildTableHeaderGrid(),
              // Scrollable data rows
              Expanded(
                child: Obx(() => ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: controller.auditItems.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
                      itemBuilder: (ctx, index) {
                        final item = controller.auditItems[index];
                        return _AuditRowGridTile(
                          index: index,
                          item: item,
                          controller: controller,
                        );
                      },
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeaderGrid() {
    return Container(
      height: 30.h,
      decoration: BoxDecoration(
        color: const Color(0xFF009BD9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(3.r),
          topRight: Radius.circular(3.r),
        ),
      ),
      child: Row(
        children: [
          _headerCell('Sl No.', width: _AuditColumnWidths.slNo, alignment: Alignment.center),
          _headerCell('Item', width: _AuditColumnWidths.item, alignment: Alignment.centerLeft),
          _headerCell('Category', width: _AuditColumnWidths.category, alignment: Alignment.centerLeft),
          _headerCell('System Qty', width: _AuditColumnWidths.systemQty, alignment: Alignment.center),
          _headerCell('Actual Qty', width: _AuditColumnWidths.actualQty, alignment: Alignment.center),
          _headerCell('Difference', width: _AuditColumnWidths.difference, alignment: Alignment.center, hasRightBorder: false),
        ],
      ),
    );
  }

  Widget _headerCell(
    String title, {
    required double width,
    Alignment alignment = Alignment.centerLeft,
    bool hasRightBorder = true,
  }) {
    return Container(
      width: width,
      height: double.infinity,
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        border: hasRightBorder
            ? const Border(right: BorderSide(color: Colors.white30))
            : null,
      ),
      child: Text(
        title,
        style: AppTextStyle.style_11_700(color: Colors.white),
        textAlign: alignment == Alignment.center
            ? TextAlign.center
            : TextAlign.left,
      ),
    );
  }
}


class _AuditRowGridTile extends StatefulWidget {
  final int index;
  final AuditItem item;
  final InventoryAuditController controller;

  const _AuditRowGridTile({
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
                  overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
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
                  overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
              ),
              // 4. System Qty (Shows EXACTLY what API response returns for allotment_qty)
              _cell(
                width: _AuditColumnWidths.systemQty,
                alignment: Alignment.center,
                child: Text(
                  widget.item.systemQtyStr,
                  style: AppTextStyle.style_11_700(color: AppColors.black),
                  textAlign: TextAlign.center,
                ),
              ),
              // 5. Actual Qty (Symmetrically centered input field)
              _cell(
                width: _AuditColumnWidths.actualQty,
                alignment: Alignment.center,
                child: Center(
                  child: SizedBox(
                    width: 95.w,
                    height: 24.h,
                    child: TextField(
                      controller: textCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      style: AppTextStyle.style_11_600(color: AppColors.black),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle:
                            AppTextStyle.style_10_400(color: Colors.grey.shade400),
                        isDense: true,
                        isCollapsed: true, // Eliminates hidden InputDecorator bottom margin!
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
                      onChanged: (val) {
                        widget.controller.setQty(widget.item.itemId, val);
                      },
                    ),
                  ),
                ),
              ),
              // 6. Difference (Calculated in real-time)
              _cell(
                width: _AuditColumnWidths.difference,
                alignment: Alignment.center,
                hasRightBorder: false,
                child: Obx(() {
                  final rawQty = widget.controller.auditQtys[widget.item.itemId] ?? '';
                  final unit = widget.item.unitSuffix;

                  if (rawQty.trim().isEmpty) {
                    return Text(
                      unit.isNotEmpty ? '- $unit' : '-',
                      style: AppTextStyle.style_11_400(color: AppColors.black),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    );
                  }
                  final actual = double.tryParse(rawQty.trim());
                  if (actual == null) {
                    return Text(
                      unit.isNotEmpty ? '- $unit' : '-',
                      style: AppTextStyle.style_11_400(color: AppColors.black),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    );
                  }
                  final diff = actual - widget.item.systemQtyNum;
                  final diffStr = diff == diff.toInt()
                      ? diff.toInt().toString()
                      : diff.toStringAsFixed(1);
                  final prefix = diff > 0 ? '+' : '';
                  final displayStr =
                      unit.isNotEmpty ? '$prefix$diffStr $unit' : '$prefix$diffStr';

                  Color diffColor = AppColors.black;
                  if (diff > 0) diffColor = const Color(0xFF389D6A);
                  if (diff < 0) diffColor = Colors.red.shade600;

                  return Text(
                    displayStr,
                    style: AppTextStyle.style_11_600(color: diffColor),
                    overflow: TextOverflow.ellipsis,
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
