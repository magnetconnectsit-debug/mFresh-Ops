import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_image_view.dart';
import 'package:core/widgets/app_common_table.dart';
import '../../controllers/audit_report_controller.dart';
import 'audit_table_widget.dart' show openFullScreenImageViewer;

class AuditAdditionalItemsTable extends StatelessWidget {
  final AuditDetailData detail;

  const AuditAdditionalItemsTable({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final items = detail.additionalItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title Header
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 16.r,
                color: const Color(0xFF1E293B),
              ),
              SizedBox(width: 6.w),
              Text(
                'Additional / Unlisted Items',
                style: AppTextStyle.style_14_600(
                  color: const Color(0xFF1E293B),
                ),
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
            child: items.isEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Center(
                      child: Text(
                        'No additional audit items found.',
                        style: AppTextStyle.style_12_400(
                          color: AppColors.grey600,
                        ),
                      ),
                    ),
                  )
                : Builder(
                    builder: (context) {
                      final columns = [
                        AppTableColumn<AdditionalAuditItemDetail>(
                          key: 'item',
                          title: 'Item',
                          width: 120.w,
                          cellBuilder: (context, item, index, isExpanded) {
                            return Text(
                              item.itemName,
                              style: AppTextStyle.style_11_600(
                                color: AppColors.black,
                              ),
                              maxLines: isExpanded ? null : 1,
                              overflow: isExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                            );
                          },
                        ),
                        AppTableColumn<AdditionalAuditItemDetail>(
                          key: 'image',
                          title: 'Image',
                          width: 60.w,
                          sortable: false,
                          cellBuilder: (context, item, index, isExpanded) {
                            return _buildImageCell(context, item.imageUrls);
                          },
                        ),
                        AppTableColumn<AdditionalAuditItemDetail>(
                          key: 'actualqty',
                          title: 'Actual Qty',
                          width: 85.w,
                          valueGetter: (item) => '${item.actualQty}',
                        ),
                        AppTableColumn<AdditionalAuditItemDetail>(
                          key: 'unit',
                          title: 'Measurement Unit',
                          width: 110.w,
                          valueGetter: (item) => item.measurementUnit,
                        ),

                        AppTableColumn<AdditionalAuditItemDetail>(
                          key: 'type',
                          title: 'Type',
                          width: 100.w,
                          cellBuilder: (context, item, index, isExpanded) {
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  item.type,
                                  style: AppTextStyle.style_10_500(
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ];

                      return AppCommonTable<AdditionalAuditItemDetail>(
                        items: items,
                        columns: columns,
                        headingRowColor: const Color(0xFFDCE5F8),
                        headingBorderColor: Colors.white,
                        borderColor: Colors.grey.shade300,
                      );
                    },
                  ),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
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
}
