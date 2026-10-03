import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_audit_controller.dart';
import 'package:mfresh_ops/modules/inventory/views/widgets/audit_table_widget.dart'
    show openFullScreenImageViewer;
import 'add_additional_item_dialog.dart';

class AdditionalAuditItemsWidget extends StatelessWidget {
  const AdditionalAuditItemsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InventoryAuditController>();

    return Obx(() {
      if (controller.selectedUnitIds.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: EdgeInsets.only(top: 16.h),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header bar with title and Add button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(3.r),
                  topRight: Radius.circular(3.r),
                ),
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.add_shopping_cart,
                          size: 16.r, color: const Color(0xFF009BD9)),
                      SizedBox(width: 6.w),
                      Text(
                        'Additional Items',
                        style: AppTextStyle.style_13_600(color: AppColors.black),
                      ),
                      if (controller.additionalAuditItems.isNotEmpty) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF009BD9).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            '${controller.additionalAuditItems.length}',
                            style: AppTextStyle.style_11_600(
                                color: const Color(0xFF009BD9)),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(
                    height: 24.h,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          showAddAdditionalItemDialog(context, controller),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009BD9),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        elevation: 0,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Icon(Icons.add, size: 13.r, color: Colors.white),
                      label: Text(
                        'Add Item',
                        style: AppTextStyle.style_10_600(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (controller.additionalAuditItems.isEmpty)
              Padding(
                padding:
                    EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
                child: Center(
                  child: Text(
                    'No additional items added yet. Click "+ Add Item" to include items not listed in unit inventory.',
                    style: AppTextStyle.style_11_400(color: AppColors.grey300),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: 490.w,
                  child: Column(
                    children: [
                      // Sub-header
                      Container(
                        height: 28.h,
                        color: const Color(0xFF009BD9),
                        child: Row(
                          children: [
                            _headerCell('Sl No.',
                                width: 50.w, alignment: Alignment.center),
                            _headerCell('Item Name',
                                width: 140.w, alignment: Alignment.centerLeft),
                            _headerCell('Measurement Unit',
                                width: 110.w, alignment: Alignment.centerLeft),
                            _headerCell('Actual Qty',
                                width: 75.w, alignment: Alignment.center),
                            _headerCell('Images',
                                width: 70.w, alignment: Alignment.center),
                            _headerCell('',
                                width: 45.w,
                                alignment: Alignment.center,
                                hasRightBorder: false),
                          ],
                        ),
                      ),
                      // List rows
                      Column(
                        children: List.generate(
                            controller.additionalAuditItems.length, (index) {
                          final item = controller.additionalAuditItems[index];
                          return Container(
                            constraints: BoxConstraints(minHeight: 32.h),
                            decoration: BoxDecoration(
                              color: index.isEven
                                  ? Colors.white
                                  : const Color(0xFFF9FAFB),
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey.shade200)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _dataCell('${index + 1}',
                                    width: 50.w, alignment: Alignment.center),
                                _dataCell(item.itemName,
                                    width: 140.w,
                                    alignment: Alignment.centerLeft,
                                    isBold: true),
                                _dataCell(item.measurementUnitName,
                                    width: 110.w,
                                    alignment: Alignment.centerLeft),
                                _dataCell('${item.actualQty}',
                                    width: 75.w, alignment: Alignment.center),
                                // Images cell
                                Container(
                                  width: 70.w,
                                  alignment: Alignment.center,
                                  padding:
                                      EdgeInsets.symmetric(vertical: 4.h),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        right: BorderSide(
                                            color: Colors.grey.shade200)),
                                  ),
                                  child: item.images.isEmpty
                                      ? Icon(Icons.image_not_supported_outlined,
                                          size: 14.r,
                                          color: Colors.grey.shade400)
                                      : GestureDetector(
                                          onTap: () =>
                                              openFullScreenImageViewer(
                                                  context,
                                                  item.images
                                                      .cast<dynamic>(),
                                                  0),
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        4.r),
                                                child: Image.file(
                                                  item.images.first,
                                                  width: 24.r,
                                                  height: 24.r,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              if (item.images.length > 1)
                                                Positioned(
                                                  right: -4,
                                                  top: -4,
                                                  child: Container(
                                                    padding: EdgeInsets
                                                        .symmetric(
                                                            horizontal: 3.w,
                                                            vertical: 1.h),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFF009BD9),
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(8.r),
                                                      border: Border.all(
                                                          color: Colors.white,
                                                          width: 1),
                                                    ),
                                                    child: Text(
                                                      '+${item.images.length - 1}',
                                                      style: TextStyle(
                                                        fontSize: 8.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                ),
                                // Delete button
                                Container(
                                  width: 45.w,
                                  alignment: Alignment.center,
                                  child: InkWell(
                                    onTap: () => controller
                                        .removeAdditionalItem(index),
                                    child: Icon(Icons.delete_outline,
                                        size: 16.r,
                                        color: Colors.red.shade400),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _headerCell(String text,
      {required double width,
      Alignment alignment = Alignment.centerLeft,
      bool hasRightBorder = true}) {
    return Container(
      width: width,
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        border: hasRightBorder
            ? const Border(right: BorderSide(color: Colors.white30))
            : null,
      ),
      child: Text(
        text,
        style: AppTextStyle.style_11_700(color: Colors.white),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _dataCell(String text,
      {required double width,
      Alignment alignment = Alignment.centerLeft,
      bool isBold = false}) {
    return Container(
      width: width,
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Text(
        text,
        style: isBold
            ? AppTextStyle.style_11_500(color: AppColors.black)
            : AppTextStyle.style_11_400(color: Colors.grey.shade700),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

