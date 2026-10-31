import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_table.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import '../controllers/item_controller.dart';
import 'package:mfresh_ops/data/models/inventory/item_model.dart';
import '../../../widgets/common_sidebar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'widgets/inventory_item_dialog.dart';

class ItemScreen extends StatelessWidget {
  const ItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ItemController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        hasBackButton: false,
        showAppDrawer: true,
        topHeader: const CommonShortcutHeader(),
        toolbarHeight: 45.h,
        title: Row(
          children: [
            Text(
              'Items',
              style: AppTextStyle.style_18_700(color: AppColors.black),
            ),
            const Spacer(),
            AppCommonSearchBar(
              width: 140.w,
              controller: controller.searchController,
              onChanged: (v) => controller.applyFilters(),
              hintText: 'Search',
            ),
          ],
        ),
      ),
      drawer: const CommonSidebar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                AppCommonButton(
                  text: 'Add Items',
                  buttonColor: AppColors.primaryGreen,
                  height: 24.h,
                  width: 110.w,
                  textSize: 11.sp,
                  onPressed: () => showItemFormDialog(context, controller),
                ),
                SizedBox(width: 12.w),
                AppCommonExportButton(
                  onExportExcel: () => controller.exportToExcel(),
                ),
              ],
            ),
          ),
          Expanded(
            child: AppRefreshIndicator(
              onRefresh: () => controller.onRefresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Obx(() {
                  final isLoading = controller.isLoading.value;
                  final items = isLoading
                      ? List.generate(
                          10,
                          (index) => ItemModel(
                            id: 0,
                            itemName: 'Loading Item Name',
                            itemId: 'Loading ID',
                            measurementUnitId: '1',
                            categoryInv: '1',
                            lowQnty: '',
                            lowQntyUnit: '',
                          ),
                        )
                      : controller.paginatedItems;

                  final sortColumn = controller.sortColumn.value;
                  final isAsc = controller.sortAscending.value;
                  final currentSortOrder = sortColumn.isEmpty
                      ? AppTableSortOrder.none
                      : (isAsc
                          ? AppTableSortOrder.ascending
                          : AppTableSortOrder.descending);

                  final startItem = controller.totalEntries == 0
                      ? 0
                      : ((controller.currentPage.value - 1) *
                              controller.perPage.value) +
                          1;
                  final endItem =
                      (controller.currentPage.value * controller.perPage.value)
                          .clamp(0, controller.totalEntries);

                  final columns = [
                    AppTableColumn<ItemModel>(
                      key: 'Sl No',
                      title: 'Sl No',
                      width: 65.w,
                      sortable: false,
                      cellBuilder: (context, item, index, isExpanded) {
                        return Text(
                          '${startItem + index}',
                          style: AppTextStyle.style_11_500(
                            color: AppColors.black,
                          ),
                        );
                      },
                    ),
                    AppTableColumn<ItemModel>(
                      key: 'Item Name',
                      title: 'Item Name',
                      width: 150.w,
                      valueGetter: (item) => item.itemName,
                    ),
                    AppTableColumn<ItemModel>(
                      key: 'Item ID',
                      title: 'Item ID',
                      width: 100.w,
                      valueGetter: (item) => item.itemId,
                    ),
                    AppTableColumn<ItemModel>(
                      key: 'Measurement',
                      title: 'Measurement',
                      width: 120.w,
                      valueGetter: (item) => controller.getMeasurementName(
                        item.measurementUnitId,
                      ),
                    ),
                    AppTableColumn<ItemModel>(
                      key: 'Action',
                      title: 'Action',
                      width: 70.w,
                      sortable: false,
                      cellBuilder: (context, item, index, isExpanded) {
                        if (isLoading) return const SizedBox.shrink();
                        return Center(
                          child: InkWell(
                            onTap: () => showItemFormDialog(
                              context,
                              controller,
                              item: item,
                            ),
                            child: Icon(
                              Icons.edit_square,
                              color: AppColors.primary,
                              size: 16.r,
                            ),
                          ),
                        );
                      },
                    ),
                  ];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        child: AppCommonTable<ItemModel>(
                          items: items,
                          columns: columns,
                          currentSortColumn: sortColumn,
                          currentSortOrder: currentSortOrder,
                          onSort: (columnKey, sortOrder) =>
                              controller.sortBy(columnKey),
                          isLoading: isLoading,
                          headingRowColor: AppColors.blue50,
                          headingTextStyle: AppTextStyle.style_11_700(
                            color: AppColors.black,
                          ),
                          dataTextStyle: AppTextStyle.style_11_500(
                            color: AppColors.black,
                          ),
                          borderColor: AppColors.borderColor,
                          headingRowHeight: 20.h,
                          cellVerticalPadding: 1.h,
                          cellHorizontalPadding: 4.w,
                          emptyText: 'No items found',
                        ),
                      ),
                      SizedBox(height: 8.h),
                      if (!isLoading && controller.totalEntries > 0)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 4.h,
                          ),
                          child: AppTablePagination(
                            startItem: startItem,
                            endItem: endItem,
                            totalItems: controller.totalEntries,
                            currentPage: controller.currentPage.value,
                            totalPages: controller.totalPages,
                            onPageChanged: (page) => controller.goToPage(page),
                            onPreviousPage: controller.previousPage,
                            onNextPage: controller.nextPage,
                          ),
                        ),
                      SizedBox(height: 32.h),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

