import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_controller.dart';
import '../../../../data/models/inventory/inventory_item_model.dart';
import 'store_inventory_dialogs.dart';

class StoreInventoryTable extends StatefulWidget {
  const StoreInventoryTable({super.key});

  @override
  State<StoreInventoryTable> createState() => _StoreInventoryTableState();
}

class _StoreInventoryTableState extends State<StoreInventoryTable> {
  final Set<String> _expandedRows = {};

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
    final controller = Get.find<InventoryController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
          child: Obx(() {
            if (controller.inventoryItems.isEmpty && !controller.isLoading.value) {
                            return Padding(
                              padding: EdgeInsets.all(20.r),
                              child: const Text('No inventory items found.'),
                            );
                          }

                          final itemsToRender = controller.isLoading.value
                              ? List.generate(
                                  10,
                                  (index) => InventoryItemModel(
                                    id: index,
                                    store: 'Store_Dummy',
                                    item: 'Loading Item',
                                    category: 'Category_Dummy',
                                    quantity: '0',
                                    unit: 'pcs',
                                  ),
                                )
                              : controller.paginatedItems;

                          return Skeletonizer(
                            enabled: controller.isLoading.value,
                            child: Table(
                              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                              border: TableBorder.symmetric(
                                inside: BorderSide(color: Colors.grey.shade300),
                              ),
                              columnWidths: {
                                0: FixedColumnWidth(150.w),
                                1: FixedColumnWidth(110.w),
                                2: FixedColumnWidth(120.w),
                                3: FixedColumnWidth(110.w),
                                4: FixedColumnWidth(60.w),
                                5: FixedColumnWidth(60.w),
                              },
                              children: [
                                TableRow(
                                  children: [
                                    _buildHeaderCell('Action'),
                                    _buildHeaderCell('Store'),
                                    _buildHeaderCell('Item'),
                                    _buildHeaderCell('Category'),
                                    _buildHeaderCell('Qty'),
                                    _buildHeaderCell('Unit'),
                                  ],
                                ),
                                ...itemsToRender.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final item = entry.value;
                                  final key = '${item.store}_${item.item}_${item.category}_$index';
                                  final isExpanded = _expandedRows.contains(key);

                                  return TableRow(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              height: 18.h,
                                              child: ElevatedButton(
                                                onPressed: () => StoreInventoryDialogs.showAllocateSheet(context, item),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue,
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                                                  elevation: 0,
                                                  minimumSize: Size.zero,
                                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                ),
                                                child: Text('Allocate', style: AppTextStyle.style_10_500(color: Colors.white)),
                                              ),
                                            ),
                                            SizedBox(width: 4.w),
                                            SizedBox(
                                              height: 18.h,
                                              child: ElevatedButton(
                                                onPressed: () => StoreInventoryDialogs.showConsumptionSheet(context, item),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFFE53935),
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                                                  elevation: 0,
                                                  minimumSize: Size.zero,
                                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                ),
                                                child: Text('Consume', style: AppTextStyle.style_10_500(color: Colors.white)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      _buildDataCell(item.store, isExpanded, () => _toggleRow(key)),
                                      _buildDataCell(item.item, isExpanded, () => _toggleRow(key)),
                                      _buildDataCell(item.category, isExpanded, () => _toggleRow(key)),
                                      _buildDataCell(item.quantity, isExpanded, () => _toggleRow(key), textColor: item.isQntyLow ? Colors.red : null),
                                      _buildDataCell(item.unit, isExpanded, () => _toggleRow(key), textColor: item.isUnitLow ? Colors.red : null),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
            SizedBox(height: 12.h),
            Obx(() {
              final totalItems = controller.inventoryItems.length;
              final startItem = totalItems == 0 ? 0 : ((controller.currentPage.value - 1) * controller.itemsPerPage.value) + 1;
              final endItem = (startItem + controller.itemsPerPage.value - 1).clamp(0, totalItems);

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                          _buildPaginationButton('←', false, controller.previousPage),
                          ...List.generate(controller.totalPages, (index) {
                            final pageNumber = index + 1;
                            return _buildPaginationButton(
                              pageNumber.toString(),
                              controller.currentPage.value == pageNumber,
                              () => controller.goToPage(pageNumber),
                            );
                          }),
                          _buildPaginationButton('→', false, controller.nextPage),
                        ],
                      ),
                    ),
                  ),
                ],
                ),
              );
            }),
          ],
        );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Text(
        text,
        style: AppTextStyle.style_12_700(color: AppColors.black),
      ),
    );
  }

  Widget _buildDataCell(String text, bool isExpanded, VoidCallback onTap, {Color? textColor}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: Text(
          text,
          style: AppTextStyle.style_12_400(color: textColor ?? AppColors.black),
          maxLines: isExpanded ? null : 1,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildPaginationButton(String text, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        margin: EdgeInsets.only(left: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade600 : const Color(0xFFF1F5F9),
          border: Border.all(color: isActive ? Colors.blue.shade600 : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          text,
          style: AppTextStyle.style_12_500(color: isActive ? Colors.white : Colors.blue.shade600),
        ),
      ),
    );
  }
}
