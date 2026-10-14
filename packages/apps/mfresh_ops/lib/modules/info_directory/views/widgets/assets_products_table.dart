import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_table.dart';
import 'package:core/widgets/app_image_view.dart';
import 'package:core/widgets/app_table_pagination.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'package:mfresh_ops/data/models/info_directory/asset_product_model.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/assets_products_controller.dart';
import 'package:mfresh_ops/routes/app_routes.dart';

class AssetsProductsTable extends StatelessWidget {
  final AssetsProductsController controller;

  const AssetsProductsTable({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final userPermissions = Get.find<AuthRepository>().rxUserPermissions;
      final bool canEdit = userPermissions.contains('Product&Asset_Edit');
      final bool canDelete = userPermissions.contains('Product&Asset_Delete');
      final bool showAction = canEdit || canDelete;

      final isLoading = controller.isLoading.value && controller.assets.isEmpty;
      final items = isLoading
          ? List.generate(6, (i) => AssetProductModel.dummy('loading_$i'))
          : controller.assets;

      final startItem = controller.totalRecords.value == 0
          ? 0
          : ((controller.currentPage.value - 1) * controller.perPage.value) + 1;
      final endItem = (controller.currentPage.value * controller.perPage.value)
          .clamp(0, controller.totalRecords.value);

      final columns = <AppTableColumn<AssetProductModel>>[
        if (showAction)
          AppTableColumn<AssetProductModel>(
            key: 'Action',
            title: 'Action',
            width: 60.w,
            sortable: false,
            cellBuilder: (context, asset, index, isExpanded) {
              if (isLoading) return const SizedBox.shrink();
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canEdit)
                    InkWell(
                      onTap: () async {
                        final result = await Get.toNamed(
                          AppRoutes.createAsset,
                          arguments: asset,
                        );
                        if (result == true) {
                          controller.fetchAssets();
                        }
                      },
                      borderRadius: BorderRadius.circular(4.r),
                      child: Padding(
                        padding: EdgeInsets.all(3.r),
                        child: Icon(
                          Icons.edit_square,
                          size: 16.r,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  // if (canEdit && canDelete) SizedBox(width: 1.w),
                  if (canDelete)
                    InkWell(
                      onTap: () => _showDeleteDialog(context, asset),
                      borderRadius: BorderRadius.circular(4.r),
                      child: Padding(
                        padding: EdgeInsets.all(3.r),
                        child: Icon(
                          Icons.delete,
                          size: 16.r,
                          color: AppColors.red,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        AppTableColumn<AssetProductModel>(
          key: 'Item',
          title: 'Item',
          width: 85.w,
          sortable: true,
          valueGetter: (asset) => asset.item,
          cellBuilder: (context, asset, index, isExpanded) => Text(
            asset.item,
            style: AppTextStyle.style_12_500(color: AppColors.black),
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          ),
        ),
        AppTableColumn<AssetProductModel>(
          key: 'Item Type',
          title: 'Item Type',
          width: 95.w,
          sortable: true,
          valueGetter: (asset) => asset.itemTypeLabel,
          cellBuilder: (context, asset, index, isExpanded) => Text(
            asset.itemTypeLabel,
            style: AppTextStyle.style_12_500(color: AppColors.black),
          ),
        ),
        AppTableColumn<AssetProductModel>(
          key: 'Brand',
          title: 'Brand',
          width: 80.w,
          sortable: true,
          valueGetter: (asset) => asset.brand,
          cellBuilder: (context, asset, index, isExpanded) => Text(
            asset.brand,
            style: AppTextStyle.style_12_500(color: AppColors.black),
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          ),
        ),
        // Category added after Brand
        AppTableColumn<AssetProductModel>(
          key: 'Category',
          title: 'Category',
          width: 90.w,
          sortable: true,
          valueGetter: (asset) => asset.assetCategoryName,
          cellBuilder: (context, asset, index, isExpanded) => Text(
            asset.assetCategoryName.isNotEmpty ? asset.assetCategoryName : 'NA',
            style: AppTextStyle.style_12_500(color: AppColors.black),
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          ),
        ),
        // Owned By added after Brand / Category
        AppTableColumn<AssetProductModel>(
          key: 'Owned By',
          title: 'Owned By',
          width: 100.w,
          sortable: true,
          valueGetter: (asset) => asset.productOwnerName,
          cellBuilder: (context, asset, index, isExpanded) => Text(
            asset.productOwnerName.isNotEmpty ? asset.productOwnerName : 'NA',
            style: AppTextStyle.style_12_500(color: AppColors.black),
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          ),
        ),
        AppTableColumn<AssetProductModel>(
          key: 'Model',
          title: 'Model',
          width: 90.w,
          sortable: true,
          valueGetter: (asset) => asset.model,
          cellBuilder: (context, asset, index, isExpanded) => Text(
            asset.model,
            style: AppTextStyle.style_12_500(color: AppColors.black),
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          ),
        ),
        AppTableColumn<AssetProductModel>(
          key: 'Serial No',
          title: 'Serial No',
          width: 100.w,
          sortable: true,
          valueGetter: (asset) => asset.serialNo,
          cellBuilder: (context, asset, index, isExpanded) => Text(
            asset.serialNo,
            style: AppTextStyle.style_12_500(color: AppColors.black),
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          ),
        ),
        AppTableColumn<AssetProductModel>(
          key: 'Specification',
          title: 'Specification',
          width: 115.w,
          sortable: true,
          valueGetter: (asset) => asset.specification,
          cellBuilder: (context, asset, index, isExpanded) => Text(
            asset.specification,
            style: AppTextStyle.style_12_500(color: AppColors.black),
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          ),
        ),
        AppTableColumn<AssetProductModel>(
          key: 'Qty',
          title: 'Qty',
          width: 55.w,
          sortable: true,
          valueGetter: (asset) => asset.qty,
          cellBuilder: (context, asset, index, isExpanded) => Text(
            asset.qty,
            style: AppTextStyle.style_12_500(color: AppColors.black),
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          ),
        ),
        AppTableColumn<AssetProductModel>(
          key: 'Location',
          title: 'Location',
          width: 90.w,
          sortable: true,
          valueGetter: (asset) => asset.location,
          cellBuilder: (context, asset, index, isExpanded) => Text(
            asset.location,
            style: AppTextStyle.style_12_500(color: AppColors.black),
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          ),
        ),
        AppTableColumn<AssetProductModel>(
          key: 'Unit',
          title: 'Unit',
          width: 80.w,
          sortable: true,
          valueGetter: (asset) => asset.unit,
          cellBuilder: (context, asset, index, isExpanded) => Text(
            asset.unit,
            style: AppTextStyle.style_12_500(color: AppColors.black),
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          ),
        ),
        AppTableColumn<AssetProductModel>(
          key: 'Warranty Expiry',
          title: 'Warranty Expiry',
          width: 135.w,
          sortable: true,
          valueGetter: (asset) => asset.warrantyDate,
          cellBuilder: (context, asset, index, isExpanded) => Text(
            AppDateUtils.formatToOrdinalDate(asset.warrantyDate),
            style: AppTextStyle.style_12_500(color: AppColors.black),
          ),
        ),
        AppTableColumn<AssetProductModel>(
          key: 'Warranty Status',
          title: 'Warranty Status',
          width: 135.w,
          sortable: true,
          valueGetter: (asset) => asset.formattedWarrantyType,
          cellBuilder: (context, asset, index, isExpanded) => Text(
            asset.formattedWarrantyType,
            style: AppTextStyle.style_12_500(color: AppColors.black),
          ),
        ),
        AppTableColumn<AssetProductModel>(
          key: 'Vendor',
          title: 'Vendor',
          width: 75.w,
          sortable: true,
          valueGetter: (asset) => asset.vendor,
          cellBuilder: (context, asset, index, isExpanded) => Text(
            asset.vendor,
            style: AppTextStyle.style_12_500(color: AppColors.black),
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          ),
        ),
        AppTableColumn<AssetProductModel>(
          key: 'Attachments',
          title: 'Attachments',
          width: 100.w,
          sortable: false,
          cellBuilder: (context, asset, index, isExpanded) {
            final allImages = [
              ...asset.invoice,
              ...asset.warrantyImg,
              ...asset.othersImg,
            ];
            if (allImages.isEmpty) {
              return Text(
                'No Files',
                style: AppTextStyle.style_11_400(color: AppColors.grey500),
              );
            }
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: allImages
                  .take(3)
                  .map(
                    (url) => Padding(
                      padding: EdgeInsets.only(right: 4.w),
                      child: GestureDetector(
                        onTap: () => _showImageDialog(context, url),
                        child: AppImageView(
                          imageUrl: url,
                          width: 22.r,
                          height: 22.r,
                          borderRadius: 4.r,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        AppTableColumn<AssetProductModel>(
          key: 'Project',
          title: 'Project',
          width: 80.w,
          sortable: true,
          valueGetter: (asset) => asset.project,
          cellBuilder: (context, asset, index, isExpanded) => Text(
            asset.project,
            style: AppTextStyle.style_12_500(color: AppColors.black),
            maxLines: isExpanded ? null : 1,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          ),
        ),
      ];

      return RefreshIndicator(
        onRefresh: () => controller.resetFiltersAndRefresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCommonTable<AssetProductModel>(
                items: items,
                columns: columns,
                currentSortColumn: controller.sortColumn.value,
                currentSortOrder: controller.currentSortOrder,
                onSort: (columnKey, sortOrder) =>
                    controller.sortBy(columnKey, sortOrder),
                isLoading: isLoading,
                headingRowColor: const Color(0xFFC5D5F0),
                headingTextStyle: AppTextStyle.style_12_700(
                  color: AppColors.black,
                ),
                dataTextStyle: AppTextStyle.style_12_500(
                  color: AppColors.black,
                ),
                borderColor: AppColors.borderColor,
                headingRowHeight: 28.h,
                cellVerticalPadding: 4.h,
                cellHorizontalPadding: 8.w,
                enableColumnResizing: false,
                emptyText: 'No assets or products found.',
              ),
              if (!isLoading && controller.totalRecords.value > 0) ...[
                SizedBox(height: 10.h),
                AppTablePagination(
                  startItem: startItem,
                  endItem: endItem,
                  totalItems: controller.totalRecords.value,
                  currentPage: controller.currentPage.value,
                  totalPages: controller.lastPage.value,
                  onPageChanged: (page) => controller.goToPage(page),
                  onPreviousPage: () =>
                      controller.goToPage(controller.currentPage.value - 1),
                  onNextPage: () =>
                      controller.goToPage(controller.currentPage.value + 1),
                ),
                SizedBox(height: 20.h),
              ],
            ],
          ),
        ),
      );
    });
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: AppImageView(imageUrl: imageUrl, fit: BoxFit.contain),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AssetProductModel asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        title: Text(
          'Delete Asset/Product',
          style: AppTextStyle.style_16_700(color: AppColors.black),
        ),
        content: Text(
          'Are you sure you want to delete "${asset.item}"?',
          style: AppTextStyle.style_13_400(color: AppColors.grey700),
        ),
        actions: [
          AppCommonButton(
            text: 'Cancel',
            buttonColor: AppColors.grey200,
            textColor: AppColors.black,
            height: 32.h,
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppCommonButton(
            text: 'Delete',
            buttonColor: AppColors.red,
            textColor: AppColors.white,
            height: 32.h,
            onPressed: () {
              Navigator.of(context).pop();
              controller.deleteAsset(asset.id);
            },
          ),
        ],
      ),
    );
  }
}
