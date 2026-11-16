// region Imports
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/core/constants/app_permissions.dart';
import 'package:mfresh_ops/data/models/info_directory/asset_category_model.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/asset_category_controller.dart';
import 'package:mfresh_ops/modules/info_directory/views/widgets/asset_category_dialog.dart';
// endregion

// region AssetCategoryTable Widget
class AssetCategoryTable extends StatelessWidget {
  // region Properties
  final AssetCategoryController controller;
  // endregion

  // region Constructor
  const AssetCategoryTable({super.key, required this.controller});
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return AppRefreshIndicator(
      onRefresh: () => controller.onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Obx(() {
          final isLoading = controller.isLoading.value;
          final items = isLoading
              ? List.generate(
                  6,
                  (index) => AssetCategoryModel(
                    id: index,
                    assetCatName: 'Loading Category...',
                  ),
                )
              : controller.paginatedCategories;

          final startItem = controller.totalEntries == 0
              ? 0
              : ((controller.currentPage.value - 1) *
                      controller.perPage.value) +
                  1;
          final endItem = (controller.currentPage.value * controller.perPage.value)
              .clamp(0, controller.totalEntries);

          final permissions = Get.find<AuthRepository>().rxUserPermissions;
          final canManage = permissions.contains(AppPermissions.assetCategoryPanel);

          final columns = _buildColumns(context, canManage, isLoading, startItem);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCommonTable<AssetCategoryModel>(
                items: items,
                columns: columns,
                currentSortColumn: controller.sortColumn.value,
                currentSortOrder: controller.currentSortOrder,
                onSort: (columnKey, sortOrder) =>
                    controller.sortBy(columnKey, sortOrder),
                isLoading: isLoading,
                headingRowColor: AppColors.aliceBlue,
                headingTextStyle: AppTextStyle.style_12_700(
                  color: AppColors.black,
                ),
                dataTextStyle: AppTextStyle.style_12_500(
                  color: AppColors.black,
                ),
                borderColor: AppColors.borderColor,
                headingRowHeight: 28.h,
                cellVerticalPadding: 4.h,
                cellHorizontalPadding: 6.w,
                emptyText: 'No asset categories found.',
              ),
              SizedBox(height: 10.h),
              if (!isLoading && controller.totalEntries > 0)
                AppTablePagination(
                  startItem: startItem,
                  endItem: endItem,
                  totalItems: controller.totalEntries,
                  currentPage: controller.currentPage.value,
                  totalPages: controller.totalPages,
                  onPageChanged: (page) => controller.goToPage(page),
                  onPreviousPage: controller.previousPage,
                  onNextPage: controller.nextPage,
                ),
              SizedBox(height: 24.h),
            ],
          );
        }),
      ),
    );
  }
  // endregion

  // region Columns Definition
  List<AppTableColumn<AssetCategoryModel>> _buildColumns(
    BuildContext context,
    bool canManage,
    bool isLoading,
    int startItem,
  ) {
    final sortColumn = controller.sortColumn.value;
    final isAsc = controller.sortAscending.value;

    return [
      AppTableColumn<AssetCategoryModel>(
        key: 'Sl No',
        title: 'Sl No.',
        width: 55.w,
        sortable: true,
        cellBuilder: (context, item, index, isExpanded) {
          final isSlNoDescending =
              (sortColumn == 'Sl No' || sortColumn == 'Sl No.') &&
                  !isAsc;
          final slNoDisplay = isSlNoDescending
              ? controller.totalEntries - (startItem + index - 1)
              : (startItem + index);
          return Center(
            child: Text(
              '$slNoDisplay',
              style: AppTextStyle.style_12_500(
                color: AppColors.grey900,
              ),
            ),
          );
        },
      ),
      AppTableColumn<AssetCategoryModel>(
        key: 'Asset Category',
        title: 'Asset Category',
        width: 180.w,
        sortable: true,
        valueGetter: (item) => item.assetCatName,
        cellBuilder: (context, item, index, isExpanded) {
          return Text(
            item.assetCatName,
            style: AppTextStyle.style_12_500(
              color: AppColors.black,
            ),
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          );
        },
      ),
      if (canManage)
        AppTableColumn<AssetCategoryModel>(
          key: 'Action',
          title: 'Action',
          width: 55.w,
          sortable: false,
          cellBuilder: (context, item, index, isExpanded) {
            if (isLoading) return const SizedBox.shrink();
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    if (!Get.find<AuthRepository>().rxUserPermissions.contains(AppPermissions.assetCategoryPanel)) {
                      AppCommonToastMessage.show(
                        message: 'You do not have permission to perform this action.',
                        type: ToastType.warning,
                      );
                      return;
                    }
                    showAssetCategoryDialog(
                      context,
                      controller,
                      category: item,
                    );
                  },
                  borderRadius: BorderRadius.circular(4.r),
                  child: Padding(
                    padding: EdgeInsets.all(2.r),
                    child: Icon(
                      Icons.edit_square,
                      size: 17.r,
                      color: AppColors.warning,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (!Get.find<AuthRepository>().rxUserPermissions.contains(AppPermissions.assetCategoryPanel)) {
                      AppCommonToastMessage.show(
                        message: 'You do not have permission to perform this action.',
                        type: ToastType.warning,
                      );
                      return;
                    }
                    showDeleteCategoryDialog(
                      context,
                      controller,
                      item,
                    );
                  },
                  borderRadius: BorderRadius.circular(4.r),
                  child: Padding(
                    padding: EdgeInsets.all(2.r),
                    child: Icon(
                      Icons.delete,
                      size: 17.r,
                      color: AppColors.red,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
    ];
  }
  // endregion
}
// endregion
