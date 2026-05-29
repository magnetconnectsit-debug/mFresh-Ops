import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/modules/inventory/controllers/unit_inventory_controller.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mfresh_ops/modules/inventory/views/widgets/store_inventory_dialogs.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';

class UnitInventoryTable extends StatefulWidget {
  const UnitInventoryTable({super.key});

  @override
  State<UnitInventoryTable> createState() => _UnitInventoryTableState();
}

class _UnitInventoryTableState extends State<UnitInventoryTable> {
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
    final controller = Get.find<UnitInventoryController>();

    return Obx(() {
      final authRepo = Get.find<AuthRepository>();
      final userPermissions = authRepo.rxUserPermissions;

      final canAllocate = userPermissions.contains('U_Inv_Allot');
      final canConsume = userPermissions.contains('U_Inv_Consume');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
              child: Obx(() {
                final isTableLoading = controller.isLoading.value;
                final items = isTableLoading
                    ? List.generate(
                        10,
                        (index) => UnitInventoryModel(
                          id: index,
                          unitName: 'Unit_Dummy',
                          itemName: 'Loading Item',
                          categoryName: 'Category_Dummy',
                          quantity: '0',
                          lowQntyUnit: '0',
                          mUnit: 'pcs',
                        ),
                      )
                    : controller.paginatedItems;

                if (items.isEmpty && !controller.isSearching.value) {
                  return Padding(
                    padding: EdgeInsets.all(32.r),
                    child: Center(
                      child: Text('No inventory stock found', style: AppTextStyle.style_14_400(color: AppColors.grey300)),
                    ),
                  );
                }

                return Skeletonizer(
                  enabled: isTableLoading,
                  child: Table(
                  columnWidths: const {
                    0: IntrinsicColumnWidth(), // Action
                    1: IntrinsicColumnWidth(), // Unit
                    2: IntrinsicColumnWidth(), // Item
                    3: IntrinsicColumnWidth(), // Category
                    4: IntrinsicColumnWidth(), // Quantity
                    5: IntrinsicColumnWidth(), // M_Unit
                  },
                  border: TableBorder(
                    horizontalInside: BorderSide(color: AppColors.grey50, width: 1),
                    verticalInside: BorderSide(color: AppColors.grey50, width: 1),
                  ),
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(color: AppColors.white),
                      children: [
                        _buildHeaderCell('Action'),
                        _buildHeaderCell('Unit'),
                        _buildHeaderCell('Item'),
                        _buildHeaderCell('Category'),
                        _buildHeaderCell('Quantity'),
                        _buildHeaderCell('M_Unit'),
                      ],
                    ),
                    ...List.generate(items.length, (index) {
                      final item = items[index];
                      final key = '${item.unitName}_${item.itemName}_${item.categoryName}_$index';
                      final isExpanded = _expandedRows.contains(key);

                      return TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                            child: Row(
                              children: [
                                if (canAllocate) ...[
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
                                ],
                                if (canConsume) ...[
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
                              ],
                            ),
                          ),
                          _buildDataCell(item.unitName, isExpanded, () => _toggleRow(key)),
                          _buildDataCell(item.itemName, isExpanded, () => _toggleRow(key)),
                          _buildDataCell(item.categoryName, isExpanded, () => _toggleRow(key)),
                          _buildDataCell(item.quantity, isExpanded, () => _toggleRow(key)),
                          _buildDataCell(item.mUnit, isExpanded, () => _toggleRow(key), textColor: item.isQntyLow ? Colors.red : null),
                        ],
                      );
                    }),
                  ],
                ));
              }),
            ),
          ),
        ),
        SizedBox(height: 12.h),
          Obx(() {
            final totalItems = controller.unitInventoryItems.length;
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
    });
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
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
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
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
