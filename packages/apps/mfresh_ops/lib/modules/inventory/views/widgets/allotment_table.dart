import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_table.dart';
import 'package:core/widgets/app_table_pagination.dart';
import 'package:mfresh_ops/data/models/inventory/allotment_item_model.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/inventory/controllers/allotment_controller.dart';

class AllotmentTable extends StatefulWidget {
  const AllotmentTable({super.key});

  @override
  State<AllotmentTable> createState() => _AllotmentTableState();
}

class _AllotmentTableState extends State<AllotmentTable> {
  final Set<int> _expandedRowIndices = {};

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AllotmentController>();

    return Obx(() {
      final items = controller.sortedItems;
      final hasReverse = Get.find<AuthRepository>().rxUserPermissions.contains(
        'allotment_reverse',
      );
      final isLoading = controller.isLoading.value;

      final sortColumn = controller.sortColumn.value;
      final isAsc = controller.sortAscending.value;
      final currentSortOrder = sortColumn.isEmpty
          ? AppTableSortOrder.none
          : (isAsc
                ? AppTableSortOrder.ascending
                : AppTableSortOrder.descending);

      final startItem = controller.totalEntries.value == 0
          ? 0
          : ((controller.currentPage.value - 1) * controller.perPage.value) + 1;
      final endItem = (controller.currentPage.value * controller.perPage.value)
          .clamp(0, controller.totalEntries.value);

      final List<AppTableColumn<AllotmentItemModel>> columns = [
        if (hasReverse)
          AppTableColumn<AllotmentItemModel>(
            key: 'action',
            title: 'Action',
            width: 87.w,
            sortable: false,
            cellBuilder: (context, item, index, isExpanded) {
              final isReversed = item.isReversed == 1;
              return AppCommonButton(
                text: isReversed ? 'Reversed' : 'Reverse',
                height: 20.h,
                buttonColor: isReversed ? AppColors.black200 : AppColors.red,
                onPressed: (isLoading || isReversed)
                    ? null
                    : () => _showReverseDialog(context, controller, item),
              );
            },
          ),
        AppTableColumn<AllotmentItemModel>(
          key: 'Transfer Date',
          title: 'Transfer Date',
          width: 110.w,
          valueGetter: (item) => item.dateOfAllotment,
        ),
        AppTableColumn<AllotmentItemModel>(
          key: 'Item Name',
          title: 'Item Name',
          width: 120.w,
          valueGetter: (item) => item.itemName,
        ),
        AppTableColumn<AllotmentItemModel>(
          key: 'Source',
          title: 'Source',
          width: 110.w,
          valueGetter: (item) => item.source,
        ),
        AppTableColumn<AllotmentItemModel>(
          key: 'Destination',
          title: 'Destination',
          width: 110.w,
          valueGetter: (item) => item.destination,
        ),
        AppTableColumn<AllotmentItemModel>(
          key: 'Quantity',
          title: 'Quantity',
          width: 85.w,
          cellColorGetter: (item) => AppColors.yellow50,
          valueGetter: (item) => item.quantity,
        ),
        AppTableColumn<AllotmentItemModel>(
          key: 'M_Unit',
          title: 'M_Unit',
          width: 70.w,
          valueGetter: (item) => item.unit,
        ),
        AppTableColumn<AllotmentItemModel>(
          key: 'Transferred By',
          title: 'Transferred By',
          width: 115.w,
          valueGetter: (item) => item.allotmentBy,
        ),
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Table
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: AppCommonTable<AllotmentItemModel>(
              items: items,
              columns: columns,
              currentSortColumn: sortColumn,
              currentSortOrder: currentSortOrder,
              onSort: (columnKey, sortOrder) => controller.sortBy(columnKey),
              expandedRowIndices: _expandedRowIndices,
              onRowExpandToggle: (index, isExpanded) {
                setState(() {
                  if (isExpanded) {
                    _expandedRowIndices.add(index);
                  } else {
                    _expandedRowIndices.remove(index);
                  }
                });
              },
              isLoading: isLoading,
              headingRowColor: AppColors.blue50,
              headingTextStyle: AppTextStyle.style_11_700(
                color: AppColors.black,
              ),
              dataTextStyle: AppTextStyle.style_11_500(color: AppColors.black),
              borderColor: AppColors.borderColor,
              headingRowHeight: 20.h,
              cellVerticalPadding: 1.h,
              cellHorizontalPadding: 4.w,
              emptyText: 'No transfer records found',
            ),
          ),
          SizedBox(height: 8.h),

          // Pagination Bar
          if (!isLoading && controller.totalEntries.value > 0)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: AppTablePagination(
                startItem: startItem,
                endItem: endItem,
                totalItems: controller.totalEntries.value,
                currentPage: controller.currentPage.value,
                totalPages: controller.totalPages.value,
                onPageChanged: (page) => controller.goToPage(page),
                onPreviousPage: controller.previousPage,
                onNextPage: controller.nextPage,
              ),
            ),
        ],
      );
    });
  }

  void _showReverseDialog(
    BuildContext context,
    AllotmentController controller,
    AllotmentItemModel item,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60.r,
                  height: 60.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.warning, width: 3.w),
                  ),
                  child: Center(
                    child: Text(
                      '!',
                      style: TextStyle(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Confirm Reverse',
                  style: AppTextStyle.style_16_700(color: AppColors.black),
                ),
                SizedBox(height: 8.h),
                Text(
                  'This will reverse the allotment and restore stock.',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.style_12_400(color: AppColors.grey500),
                ),
                SizedBox(height: 20.h),
                Obx(() {
                  final isReversing = controller.isReversing.value;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppCommonButton(
                        text: 'Yes, Reverse it!',
                        buttonColor: AppColors.red,
                        height: 26.h,
                        isLoading: isReversing,
                        onPressed: isReversing
                            ? null
                            : () async {
                                await controller.reverseAllotment(item);
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                      ),
                      SizedBox(width: 12.w),
                      AppCommonButton(
                        text: 'Cancel',
                        buttonColor: AppColors.black200,
                        height: 26.h,
                        onPressed: isReversing
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      );
    },
    );
  }
}
