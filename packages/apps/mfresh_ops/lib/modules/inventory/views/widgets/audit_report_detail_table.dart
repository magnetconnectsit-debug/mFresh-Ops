import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_image_view.dart';
import 'package:core/widgets/app_common_table.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title Header
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 16.r,
                color: const Color(0xFF1E293B),
              ),
              SizedBox(width: 6.w),
              Text(
                'Existing Inventory Items',
                style: AppTextStyle.style_14_600(color: const Color(0xFF1E293B)),
              ),
            ],
          ),
        ),

        // Table Container
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
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

              final expandedIndices = <int>{};
              for (int i = 0; i < sortedItems.length; i++) {
                if (controller.expandedDetailRowIds.contains(sortedItems[i].id)) {
                  expandedIndices.add(i);
                }
              }

              final columns = [
                AppTableColumn<AuditItemDetail>(
                  key: 'item',
                  title: 'Item',
                  width: 110.w,
                  cellBuilder: (context, item, index, isExpanded) {
                    return Text(
                      item.itemName,
                      style: AppTextStyle.style_11_600(color: AppColors.black),
                      maxLines: isExpanded ? null : 1,
                      overflow: isExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    );
                  },
                ),
                AppTableColumn<AuditItemDetail>(
                  key: 'category',
                  title: 'Category',
                  width: 100.w,
                  valueGetter: (item) => item.categoryName,
                ),
                AppTableColumn<AuditItemDetail>(
                  key: 'image',
                  title: 'Image',
                  width: 60.w,
                  sortable: false,
                  cellBuilder: (context, item, index, isExpanded) {
                    return _buildImageCell(context, item.imageUrls);
                  },
                ),
                AppTableColumn<AuditItemDetail>(
                  key: 'systemqty',
                  title: 'System Qty',
                  width: 85.w,
                  valueGetter: (item) => item.systemQtyLabel,
                ),
                AppTableColumn<AuditItemDetail>(
                  key: 'actualqty',
                  title: 'Actual Qty',
                  width: 85.w,
                  cellBuilder: (context, item, index, isExpanded) {
                    return Text(
                      item.actualQtyLabel,
                      style: AppTextStyle.style_11_600(color: AppColors.black),
                      maxLines: isExpanded ? null : 1,
                      overflow: isExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    );
                  },
                ),
                AppTableColumn<AuditItemDetail>(
                  key: 'difference',
                  title: 'Difference',
                  width: 85.w,
                  cellColorGetter: (item) {
                    final isShortage = item.varianceColor == 'red' || item.differenceQty < 0;
                    return isShortage ? const Color(0xFFFFEBEE) : null;
                  },
                  cellBuilder: (context, item, index, isExpanded) {
                    return _buildDifferenceCell(item, isExpanded);
                  },
                ),
                AppTableColumn<AuditItemDetail>(
                  key: 'percentage',
                  title: 'Stock %',
                  width: 90.w,
                  cellColorGetter: (item) {
                    final isShortage = item.varianceColor == 'red' || item.differenceQty < 0;
                    return isShortage ? const Color(0xFFFFEBEE) : null;
                  },
                  cellBuilder: (context, item, index, isExpanded) {
                    return _buildPercentageCell(item, isExpanded);
                  },
                ),
                AppTableColumn<AuditItemDetail>(
                  key: 'result',
                  title: 'Result',
                  width: 85.w,
                  cellColorGetter: (item) {
                    final isShortage = item.varianceColor == 'red' || item.differenceQty < 0;
                    return isShortage ? const Color(0xFFFFEBEE) : null;
                  },
                  cellBuilder: (context, item, index, isExpanded) {
                    return _buildResultCell(item, isExpanded);
                  },
                ),
              ];

              return AppCommonTable<AuditItemDetail>(
                items: sortedItems,
                columns: columns,
                currentSortColumn: controller.detailSortColumn.value,
                currentSortOrder: controller.detailSortAscending.value
                    ? AppTableSortOrder.ascending
                    : AppTableSortOrder.descending,
                onSort: (columnKey, sortOrder) {
                  controller.sortByDetail(columnKey);
                },
                expandedRowIndices: expandedIndices,
                onRowExpandToggle: (index, isExpanded) {
                  if (index >= 0 && index < sortedItems.length) {
                    controller.toggleDetailRowExpansion(sortedItems[index].id);
                  }
                },
                headingRowColor: const Color(0xFFDCE5F8),
                headingBorderColor: Colors.white,
                borderColor: Colors.grey.shade300,
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCell(BuildContext context, List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
        child: Center(
          child: Text(
            'No Image',
            style: AppTextStyle.style_8_400(color: AppColors.grey300),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final firstUrl = imageUrls.first;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Center(
        child: GestureDetector(
          onTap: () => openFullScreenImageViewer(context, imageUrls, 0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(3.r),
                child: AppImageView(
                  imageUrl: firstUrl,
                  width: 20.r,
                  height: 20.r,
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

  Widget _buildDifferenceCell(
    AuditItemDetail item,
    bool isExpanded,
  ) {
    final isShortage = item.varianceColor == 'red' || item.differenceQty < 0;
    final isExcess = item.varianceColor == 'green' || item.differenceQty > 0;

    Color textColor = AppColors.black;
    String text = item.differenceQtyLabel;
    FontWeight fontWeight = FontWeight.w500;

    if (isShortage) {
      textColor = const Color(0xFFD32F2F);
      fontWeight = FontWeight.w700;
    } else if (isExcess) {
      text = '+${item.differenceQtyLabel}';
    }

    return Text(
      text,
      style: AppTextStyle.style_11_500(color: textColor).copyWith(
        fontWeight: fontWeight,
      ),
      maxLines: isExpanded ? null : 1,
      overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
    );
  }

  Widget _buildResultCell(
    AuditItemDetail item,
    bool isExpanded,
  ) {
    final isShortage = item.varianceColor == 'red' || item.differenceQty < 0;
    final isExcess = item.varianceColor == 'green' || item.differenceQty > 0;

    Color textColor = AppColors.black;
    String text = 'Matched';
    FontWeight fontWeight = FontWeight.w500;

    if (isShortage) {
      textColor = const Color(0xFFC62828);
      text = 'Shortage';
      fontWeight = FontWeight.w700;
    } else if (isExcess) {
      text = 'Excess';
    }

    return Text(
      text,
      style: AppTextStyle.style_11_500(color: textColor).copyWith(
        fontWeight: fontWeight,
      ),
      maxLines: isExpanded ? null : 1,
      overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
    );
  }

  Widget _buildPercentageCell(
    AuditItemDetail item,
    bool isExpanded,
  ) {
    final label = item.actualPercentageLabel;
    final colorStr = item.actualPercentageColor.toLowerCase();
    final isShortage = colorStr == 'red' || colorStr == 'danger' || item.varianceColor == 'red' || item.differenceQty < 0;

    Color textColor = AppColors.grey900;

    if (isShortage) {
      textColor = const Color(0xFFC62828);
    } else if (colorStr == 'green' || colorStr == 'success') {
      textColor = const Color(0xFF2E7D32);
    } else if (colorStr == 'orange' || colorStr == 'warning') {
      textColor = const Color(0xFFEF6C00);
    }

    if (!item.percentageAvailable || label == '-' || label.isEmpty) {
      return Text(
        '-',
        style: AppTextStyle.style_11_400(
          color: isShortage ? const Color(0xFFC62828) : AppColors.grey500,
        ),
      );
    }

    return Text(
      label,
      style: AppTextStyle.style_11_600(color: textColor).copyWith(
        fontWeight: isShortage ? FontWeight.w700 : FontWeight.w600,
      ),
      maxLines: isExpanded ? null : 1,
      overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
    );
  }
}
