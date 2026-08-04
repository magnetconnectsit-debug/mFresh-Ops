import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/assets_products_controller.dart';
import 'package:mfresh_ops/data/models/asset_product_model.dart';
import 'package:mfresh_ops/routes/app_pages.dart';
import 'package:core/widgets/app_image_view.dart';

const List<(String, double)> _kAssetColumns = [
  ('Action', 65),
  ('Item', 130),
  ('Item Type', 100),
  ('Brand', 100),
  ('Model', 100),
  ('Serial No', 120),
  ('Specification', 150),
  ('Qty', 55),
  ('Location', 100),
  ('Unit', 100),
  ('Warranty Expiry', 130),
  ('Warranty Status', 130),
  ('Vendor', 120),
  ('Attachments', 100),
  ('Project', 100),
];

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Text(
        text,
        style: AppTextStyle.style_11_600(color: AppColors.grey900),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  const _DataCell({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: Text(
        text,
        style: AppTextStyle.style_12_400(color: AppColors.grey900),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class AssetsProductsTable extends StatefulWidget {
  final AssetsProductsController controller;
  const AssetsProductsTable({super.key, required this.controller});

  @override
  State<AssetsProductsTable> createState() => _AssetsProductsTableState();
}

class _AssetsProductsTableState extends State<AssetsProductsTable> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _headerHorizontalController = ScrollController();
  final ScrollController _bodyHorizontalController = ScrollController();
  final ScrollController _bottomBarController = ScrollController();
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _headerHorizontalController.addListener(_syncFromHeader);
    _bodyHorizontalController.addListener(_syncFromBody);
    _bottomBarController.addListener(_syncFromBottomBar);
  }

  void _syncFromHeader() {
    if (_isSyncing) return;
    _isSyncing = true;
    if (_bodyHorizontalController.hasClients) {
      _bodyHorizontalController.jumpTo(_headerHorizontalController.offset);
    }
    if (_bottomBarController.hasClients) {
      _bottomBarController.jumpTo(_headerHorizontalController.offset);
    }
    _isSyncing = false;
  }

  void _syncFromBody() {
    if (_isSyncing) return;
    _isSyncing = true;
    if (_headerHorizontalController.hasClients) {
      _headerHorizontalController.jumpTo(_bodyHorizontalController.offset);
    }
    if (_bottomBarController.hasClients) {
      _bottomBarController.jumpTo(_bodyHorizontalController.offset);
    }
    _isSyncing = false;
  }

  void _syncFromBottomBar() {
    if (_isSyncing) return;
    _isSyncing = true;
    if (_bodyHorizontalController.hasClients) {
      _bodyHorizontalController.jumpTo(_bottomBarController.offset);
    }
    if (_headerHorizontalController.hasClients) {
      _headerHorizontalController.jumpTo(_bottomBarController.offset);
    }
    _isSyncing = false;
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _headerHorizontalController.dispose();
    _bodyHorizontalController.dispose();
    _bottomBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final columnWidths = <int, TableColumnWidth>{
        for (int i = 0; i < _kAssetColumns.length; i++)
          i: FixedColumnWidth(_kAssetColumns[i].$2.w),
      };
      final double totalTableWidth = _kAssetColumns.fold(
        0.0,
        (sum, col) => sum + col.$2.w,
      );

      final isLoadingInitial =
          widget.controller.isLoading.value && widget.controller.assets.isEmpty;
      final showEmpty = !isLoadingInitial && widget.controller.assets.isEmpty;

      if (showEmpty) {
        return RefreshIndicator(
          onRefresh: () async => widget.controller.resetFiltersAndRefresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: 400.h,
                child: Center(
                  child: Text(
                    'No assets found.',
                    style: AppTextStyle.style_14_400(color: AppColors.grey600),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          // ── Header ────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: SingleChildScrollView(
              controller: _headerHorizontalController,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder.symmetric(
                  inside: BorderSide(color: Colors.grey.shade300),
                ),
                columnWidths: columnWidths,
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFC5D5F0)),
                    children: _kAssetColumns
                        .map((c) => _HeaderCell(text: c.$1))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          // ── Body ────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => widget.controller.resetFiltersAndRefresh(),
              notificationPredicate: (n) => n.depth == 1,
              child: SingleChildScrollView(
                controller: _bodyHorizontalController,
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: totalTableWidth + 2.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      left: BorderSide(color: AppColors.borderColor),
                      right: BorderSide(color: AppColors.borderColor),
                      bottom: BorderSide(color: AppColors.borderColor),
                    ),
                  ),
                  child: Obx(() {
                    final loading =
                        widget.controller.isLoading.value &&
                        widget.controller.assets.isEmpty;
                    final count = loading
                        ? 20
                        : widget.controller.assets.length;

                    return Skeletonizer(
                      enabled: loading,
                      child: Scrollbar(
                        controller: _verticalController,
                        thumbVisibility: true,
                        interactive: true,
                        thickness: 8.0,
                        radius: const Radius.circular(4),
                        child: ListView.builder(
                          controller: _verticalController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: count,
                          itemBuilder: (context, index) {
                            final asset = loading
                                ? AssetProductModel.dummy('loading')
                                : widget.controller.assets[index];
                            return _buildRow(asset);
                          },
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),

          // ── Bottom scrollbar strip ────
          Scrollbar(
            controller: _bottomBarController,
            thumbVisibility: true,
            interactive: true,
            thickness: 8.0,
            radius: const Radius.circular(4),
            child: SingleChildScrollView(
              controller: _bottomBarController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(width: totalTableWidth, height: 16),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildRow(AssetProductModel asset) {
    Widget buildCell(Widget child, double width) {
      return Container(
        width: width,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade300)),
        ),
        child: child,
      );
    }

    return Container(
      height: 25.h,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildCell(
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        final result = await Get.toNamed(
                          '/create-asset',
                          arguments: asset,
                        );
                        if (result == true) {
                          widget.controller.fetchAssets();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.edit, size: 16),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    InkWell(
                      onTap: () {
                        Get.dialog(
                          AlertDialog(
                            backgroundColor: Colors.white,
                            surfaceTintColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            title: Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red,
                                  size: 28,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Delete Asset',
                                  style: AppTextStyle.style_16_700(
                                    color: AppColors.black,
                                  ),
                                ),
                              ],
                            ),
                            content: Text(
                              'Are you sure you want to delete this asset? This action cannot be undone.',
                              style: AppTextStyle.style_14_400(
                                color: AppColors.grey900,
                              ),
                            ),
                            actionsPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: Text(
                                  'Cancel',
                                  style: AppTextStyle.style_14_600(
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                  widget.controller.deleteAsset(asset.id);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Delete',
                                  style: AppTextStyle.style_14_600(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.delete, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _kAssetColumns[0].$2.w,
          ),
          buildCell(_DataCell(text: asset.item), _kAssetColumns[1].$2.w),
          buildCell(
            _DataCell(text: asset.itemTypeLabel),
            _kAssetColumns[2].$2.w,
          ),
          buildCell(_DataCell(text: asset.brand), _kAssetColumns[3].$2.w),
          buildCell(_DataCell(text: asset.model), _kAssetColumns[4].$2.w),
          buildCell(_DataCell(text: asset.serialNo), _kAssetColumns[5].$2.w),
          buildCell(
            _DataCell(text: asset.specification),
            _kAssetColumns[6].$2.w,
          ),
          buildCell(_DataCell(text: asset.qty), _kAssetColumns[7].$2.w),
          buildCell(_DataCell(text: asset.location), _kAssetColumns[8].$2.w),
          buildCell(_DataCell(text: asset.unit), _kAssetColumns[9].$2.w),
          buildCell(
            _DataCell(text: asset.warrantyDate),
            _kAssetColumns[10].$2.w,
          ),
          buildCell(
            _DataCell(text: asset.warrantyType),
            _kAssetColumns[11].$2.w,
          ),
          buildCell(_DataCell(text: asset.vendor), _kAssetColumns[12].$2.w),
          buildCell(
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              child: Builder(
                builder: (context) {
                  final allImages = [
                    ...asset.invoice,
                    ...asset.warrantyImg,
                    ...asset.othersImg,
                  ];
                  if (allImages.isEmpty) {
                    return Text(
                      'No Files',
                      style: AppTextStyle.style_12_400(
                        color: AppColors.grey500,
                      ),
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
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    child: InteractiveViewer(
                                      child: AppImageView(imageUrl: url),
                                    ),
                                  ),
                                );
                              },
                              child: AppImageView(
                                imageUrl: url,
                                width: 20,
                                height: 20,
                                borderRadius: 4,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
            _kAssetColumns[13].$2.w,
          ),
          buildCell(_DataCell(text: asset.project), _kAssetColumns[14].$2.w),
        ],
      ),
    );
  }
}
