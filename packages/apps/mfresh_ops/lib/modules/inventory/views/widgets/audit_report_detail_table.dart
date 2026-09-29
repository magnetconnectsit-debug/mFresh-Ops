import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_image_view.dart';
import '../../controllers/audit_report_controller.dart';
import 'audit_table_widget.dart' show openFullScreenImageViewer;

class AuditReportDetailTable extends StatelessWidget {
  final AuditDetailData detail;

  const AuditReportDetailTable({
    super.key,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuditReportController>();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Table Section Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: const BoxDecoration(
                color: Color(0xFF009BD9),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.white,
                    size: 16.r,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Existing Inventory Items',
                    style: AppTextStyle.style_13_600(color: Colors.white),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '${detail.existingItemsCount} items',
                      style: AppTextStyle.style_11_500(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Table Body
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() {
                final sortedItems = controller.sortedDetailItems;

                if (sortedItems.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(20.r),
                    child: Center(
                      child: Text(
                        'No existing inventory items found.',
                        style: AppTextStyle.style_14_400(
                          color: AppColors.grey300,
                        ),
                      ),
                    ),
                  );
                }

                final columnWidths = {
                  0: FixedColumnWidth(110.w), // Item
                  1: FixedColumnWidth(100.w), // Category
                  2: FixedColumnWidth(65.w),  // Image
                  3: FixedColumnWidth(85.w),  // System Qty
                  4: FixedColumnWidth(85.w),  // Actual Qty
                  5: FixedColumnWidth(85.w),  // Difference
                  6: FixedColumnWidth(85.w),  // Result
                };

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Table(
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      border: TableBorder.symmetric(
                        inside: BorderSide(color: Colors.grey.shade300),
                      ),
                      columnWidths: columnWidths,
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F1F8),
                          ),
                          children: [
                            _buildDetailHeaderCell(controller, 'Item', sortKey: 'item'),
                            _buildDetailHeaderCell(controller, 'Category', sortKey: 'category'),
                            _buildDetailHeaderCell(controller, 'Image', isSortable: false),
                            _buildDetailHeaderCell(controller, 'System Qty', sortKey: 'systemqty'),
                            _buildDetailHeaderCell(controller, 'Actual Qty', sortKey: 'actualqty'),
                            _buildDetailHeaderCell(controller, 'Difference', sortKey: 'difference'),
                            _buildDetailHeaderCell(controller, 'Result', sortKey: 'result'),
                          ],
                        ),
                      ],
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFE0E0E0),
                    ),
                    Table(
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      border: TableBorder.symmetric(
                        inside: BorderSide(color: Colors.grey.shade300),
                      ),
                      columnWidths: columnWidths,
                      children: List.generate(sortedItems.length, (index) {
                        final item = sortedItems[index];
                        final isExpanded = controller.expandedDetailRowIds
                            .contains(item.id);

                        return TableRow(
                          children: [
                            // Item
                            _buildDataCell(
                              item.itemName,
                              isExpanded,
                              () => controller.toggleDetailRowExpansion(item.id),
                              textStyle: AppTextStyle.style_11_600(
                                  color: AppColors.black),
                            ),
                            // Category
                            _buildDataCell(
                              item.categoryName,
                              isExpanded,
                              () => controller.toggleDetailRowExpansion(item.id),
                            ),
                            // Image
                            _buildImageCell(context, item.imageUrls),
                            // System Qty
                            _buildDataCell(
                              item.systemQtyLabel,
                              isExpanded,
                              () => controller.toggleDetailRowExpansion(item.id),
                            ),
                            // Actual Qty
                            _buildDataCell(
                              item.actualQtyLabel,
                              isExpanded,
                              () => controller.toggleDetailRowExpansion(item.id),
                              textStyle: AppTextStyle.style_11_600(
                                  color: AppColors.black),
                            ),
                            // Difference
                            _buildDifferenceCell(
                              item,
                              isExpanded,
                              () => controller.toggleDetailRowExpansion(item.id),
                            ),
                            // Result
                            _buildResultCell(
                              item,
                              isExpanded,
                              () => controller.toggleDetailRowExpansion(item.id),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCell(BuildContext context, List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
        child: Center(
          child: Text(
            'No Image',
            style: AppTextStyle.style_10_400(color: AppColors.grey300),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final firstUrl = imageUrls.first;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Center(
        child: GestureDetector(
          onTap: () => openFullScreenImageViewer(context, imageUrls, 0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: AppImageView(
                  imageUrl: firstUrl,
                  width: 26.r,
                  height: 26.r,
                  fit: BoxFit.cover,
                ),
              ),
              if (imageUrls.length > 1)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Text(
                      '+${imageUrls.length - 1}',
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
      ),
    );
  }

  Widget _buildDetailHeaderCell(
    AuditReportController controller,
    String text, {
    String? sortKey,
    bool isSortable = true,
  }) {
    final key = (sortKey ?? text).toLowerCase();
    final isSorted = isSortable && (controller.detailSortColumn.value.toLowerCase() == key);
    final isAsc = controller.detailSortAscending.value;

    return InkWell(
      onTap: isSortable ? () => controller.sortByDetail(key) : null,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
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

  Widget _buildDataCell(
    String text,
    bool isExpanded,
    VoidCallback onTap, {
    Color? textColor,
    Color? bgColor,
    TextStyle? textStyle,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: bgColor,
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
        child: Text(
          text,
          style: textStyle ??
              AppTextStyle.style_11_500(color: textColor ?? AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildDifferenceCell(
    AuditItemDetail item,
    bool isExpanded,
    VoidCallback onTap,
  ) {
    final isShortage = item.varianceColor == 'red' || item.differenceQty < 0;
    final isExcess = item.varianceColor == 'green' || item.differenceQty > 0;

    Color? cellBgColor;
    Color textColor = AppColors.black;
    String text = item.differenceQtyLabel;
    FontWeight fontWeight = FontWeight.w500;

    if (isShortage) {
      cellBgColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFD32F2F);
      fontWeight = FontWeight.w700;
    } else if (isExcess) {
      text = '+${item.differenceQtyLabel}';
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: cellBgColor,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
        child: Text(
          text,
          style: AppTextStyle.style_11_500(color: textColor).copyWith(
            fontWeight: fontWeight,
          ),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildResultCell(
    AuditItemDetail item,
    bool isExpanded,
    VoidCallback onTap,
  ) {
    final isShortage = item.varianceColor == 'red' || item.differenceQty < 0;
    final isExcess = item.varianceColor == 'green' || item.differenceQty > 0;

    Color? cellBgColor;
    Color textColor = AppColors.black;
    String text = 'Matched';
    FontWeight fontWeight = FontWeight.w500;

    if (isShortage) {
      cellBgColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFC62828);
      text = 'Shortage';
      fontWeight = FontWeight.w700;
    } else if (isExcess) {
      text = 'Excess';
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: cellBgColor,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
        child: Text(
          text,
          style: AppTextStyle.style_11_500(color: textColor).copyWith(
            fontWeight: fontWeight,
          ),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
