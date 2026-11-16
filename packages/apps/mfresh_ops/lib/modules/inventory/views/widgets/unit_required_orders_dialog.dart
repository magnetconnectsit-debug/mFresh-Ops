// region Imports
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/widgets/app_common_table.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_controller.dart';
import 'package:mfresh_ops/modules/inventory/controllers/unit_inventory_controller.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_orders_controller.dart';
import 'package:mfresh_ops/data/models/inventory/inventory_order_model.dart';
// endregion

// region Models & Helper Classes
class _UnitRequestOrderItemData {
  // region Properties
  final String itemName;
  final String displayUnit;
  final Map<String, num> unitQtyMap;
  final Map<String, String> unitQtyDisplayMap;
  final String? totalQtyDisplay;
  // endregion

  // region Constructor
  _UnitRequestOrderItemData({
    required this.itemName,
    required this.displayUnit,
    required this.unitQtyMap,
    this.unitQtyDisplayMap = const {},
    this.totalQtyDisplay,
  });
  // endregion

  // region Getters
  num get totalQty {
    return unitQtyMap.values.fold(0, (sum, q) => sum + q);
  }
  // endregion
}
// endregion

// region View Definition
class UnitRequiredOrdersDialog extends StatefulWidget {
  // region Properties
  final BulkPreviewSection? bulkPreviewSection;
  // endregion

  // region Constructor
  const UnitRequiredOrdersDialog({super.key, this.bulkPreviewSection});
  // endregion

  // region Dialogs & Action Handlers
  static Future<void> show({
    required BuildContext context,
    BulkPreviewSection? bulkPreviewSection,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 24.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: double.infinity,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 800.w,
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: UnitRequiredOrdersDialog(
                bulkPreviewSection: bulkPreviewSection,
              ),
            ),
          ),
        );
      },
    );
  }
  // endregion

  @override
  State<UnitRequiredOrdersDialog> createState() =>
      _UnitRequiredOrdersDialogState();
}

class _UnitRequiredOrdersDialogState extends State<UnitRequiredOrdersDialog> {
  // region State & Lifecycle Hooks
  final GlobalKey _tableRepaintKey = GlobalKey();
  bool _isSubmitting = false;
  bool _isLoadingPreview = false;
  BulkPreviewSection? _fetchedPreviewSection;

  @override
  void initState() {
    super.initState();
    if (widget.bulkPreviewSection == null) {
      _fetchBulkPreview();
    }
  }
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final bulkSection = widget.bulkPreviewSection ?? _fetchedPreviewSection;
    final List<String> units;
    final List<_UnitRequestOrderItemData> itemsData;
    final String dialogTitle;

    if (_isLoadingPreview) {
      dialogTitle = 'Unit Required Orders';
      units = ['Unit 1', 'Unit 2'];
      itemsData = List.generate(
        6,
        (index) => _UnitRequestOrderItemData(
          itemName: 'Loading Item Name ${index + 1}',
          displayUnit: 'pcs',
          unitQtyMap: {'Unit 1': 100, 'Unit 2': 200},
          unitQtyDisplayMap: {'Unit 1': '100 pcs', 'Unit 2': '200 pcs'},
        ),
      );
    } else if (bulkSection != null) {
      dialogTitle = bulkSection.title.isNotEmpty
          ? bulkSection.title
          : 'Unit Required Orders';
      units = bulkSection.columns.map((c) => c.name).toList();

      final Map<String, _UnitRequestOrderItemData> itemMap = {};
      for (var row in bulkSection.rows) {
        final itemName = row.itemName;
        final unitDisplay = row.measurementUnit;
        if (!itemMap.containsKey(itemName)) {
          itemMap[itemName] = _UnitRequestOrderItemData(
            itemName: itemName,
            displayUnit: unitDisplay,
            unitQtyMap: {},
            unitQtyDisplayMap: {},
            totalQtyDisplay: row.totalQtyDisplay,
          );
        }
        for (var q in row.quantities) {
          itemMap[itemName]!.unitQtyMap[q.locationName] = q.orderQty;
          itemMap[itemName]!.unitQtyDisplayMap[q.locationName] = q.orderQtyDisplay;
        }
      }
      itemsData = itemMap.values.toList()
        ..sort((a, b) => a.itemName.compareTo(b.itemName));
    } else {
      final unitController = Get.isRegistered<UnitInventoryController>()
          ? Get.find<UnitInventoryController>()
          : null;
      final days = unitController?.consumptionDays.value.isNotEmpty == true
          ? unitController!.consumptionDays.value
          : '8';
      final rawDate = unitController?.consumptionToDate.value ?? '';
      String dateStr;
      if (rawDate.isNotEmpty) {
        try {
          dateStr = DateFormat('dd-MMM-yyyy').format(DateTime.parse(rawDate));
        } catch (_) {
          dateStr = DateFormat('dd-MMM-yyyy').format(DateTime.now());
        }
      } else {
        dateStr = DateFormat('dd-MMM-yyyy').format(DateTime.now());
      }
      dialogTitle = 'Unit Required Orders (for next $days days from $dateStr)';

      final filteredItems = (unitController?.unitInventoryItems ?? [])
          .where((i) => i.canRequestOrder && !i.canReceiveOrder)
          .toList();

      final Set<String> unitSet = {};
      for (var i in filteredItems) {
        if (i.unitName.isNotEmpty) unitSet.add(i.unitName);
      }
      units = unitSet.toList()..sort();

      final Map<String, _UnitRequestOrderItemData> itemMap = {};
      for (var i in filteredItems) {
        final itemName = i.itemName;
        final unitDisplay = i.displayUnit.isNotEmpty ? i.displayUnit : i.mUnit;
        if (!itemMap.containsKey(itemName)) {
          itemMap[itemName] = _UnitRequestOrderItemData(
            itemName: itemName,
            displayUnit: unitDisplay,
            unitQtyMap: {},
            unitQtyDisplayMap: {},
          );
        }
        itemMap[itemName]!.unitQtyMap[i.unitName] = i.orderQty;
        itemMap[itemName]!.unitQtyDisplayMap[i.unitName] =
            i.orderQty > 0 ? '${_formatQty(i.orderQty)} $unitDisplay' : '';
      }

      itemsData = itemMap.values.toList()
        ..sort((a, b) => a.itemName.compareTo(b.itemName));
    }

    final hasOrderPermission =
        Get.find<AuthRepository>().rxUserPermissions.contains('Inv_Unit_Order');
    final bool canOrder =
        hasOrderPermission && (bulkSection?.canCreateOrders ?? true);

    return Stack(
      children: [
        // Offscreen full table container for image sharing
        _buildOffscreenShareTable(
          dialogTitle: dialogTitle,
          units: units,
          itemsData: itemsData,
        ),

        // Visible Dialog Body
        _buildVisibleDialog(
          context: context,
          dialogTitle: dialogTitle,
          units: units,
          itemsData: itemsData,
          canOrder: canOrder,
        ),
      ],
    );
  }
  // endregion

  // region Header & App Bar
  Widget _buildHeader(BuildContext context, String dialogTitle) {
    return Container(
      color: AppColors.blue50,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              dialogTitle,
              style: AppTextStyle.style_12_700(
                color: AppColors.black,
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(Icons.close, size: 18.sp, color: AppColors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
  // endregion

  // region Section Builders
  Widget _buildVisibleDialog({
    required BuildContext context,
    required String dialogTitle,
    required List<String> units,
    required List<_UnitRequestOrderItemData> itemsData,
    required bool canOrder,
  }) {
    return Container(
      color: AppColors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, dialogTitle),
          Flexible(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildNoticeBanner(),
                  SizedBox(height: 10.h),
                  _buildTableSection(itemsData, units),
                  SizedBox(height: 12.h),
                  _buildActionButtons(context, canOrder),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeBanner() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.blue50,
        border: Border.all(color: AppColors.blue100),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        'Required quantities for all Units. Zero-quantity items are not included.',
        style: AppTextStyle.style_11_500(color: AppColors.info),
      ),
    );
  }

  Widget _buildTableSection(
    List<_UnitRequestOrderItemData> itemsData,
    List<String> units,
  ) {
    if (!_isLoadingPreview && itemsData.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Center(
          child: Text(
            'No required unit orders found.',
            style: AppTextStyle.style_12_400(
              color: AppColors.grey500,
            ),
          ),
        ),
      );
    }

    return Flexible(
      child: AppCommonTable<_UnitRequestOrderItemData>(
        items: itemsData,
        columns: [
          AppTableColumn<_UnitRequestOrderItemData>(
            key: 'Item',
            title: 'Item',
            width: 140.w,
            valueGetter: (item) => item.itemName,
          ),
          ...units.map(
            (uName) => AppTableColumn<_UnitRequestOrderItemData>(
              key: uName,
              title: uName,
              width: 95.w,
              valueGetter: (item) {
                final qtyDisplay = item.unitQtyDisplayMap[uName]?.trim();
                if (qtyDisplay != null) {
                  return qtyDisplay;
                }
                final qty = item.unitQtyMap[uName] ?? 0;
                return qty > 0
                    ? '${_formatQty(qty)} ${item.displayUnit}'
                    : '';
              },
            ),
          ),
          AppTableColumn<_UnitRequestOrderItemData>(
            key: 'Total',
            title: 'Total',
            width: 90.w,
            cellColorGetter: (item) => AppColors.yellow50,
            valueGetter: (item) {
              if (item.totalQtyDisplay != null &&
                  item.totalQtyDisplay!.trim().isNotEmpty) {
                return item.totalQtyDisplay!.trim();
              }
              return item.totalQty > 0
                  ? '${_formatQty(item.totalQty)} ${item.displayUnit}'
                  : '';
            },
          ),
        ],
        headingRowColor: AppColors.blue50,
        headingTextStyle: AppTextStyle.style_11_700(
          color: AppColors.black,
        ),
        dataTextStyle: AppTextStyle.style_11_500(
          color: AppColors.black,
        ),
        borderColor: AppColors.borderColor,
        headingRowHeight: 24.h,
        cellVerticalPadding: 2.h,
        cellHorizontalPadding: 4.w,
        emptyText: 'No required unit orders found.',
        isLoading: _isLoadingPreview,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool canOrder) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Builder(
          builder: (btnContext) => AppCommonButton(
            text: 'Share',
            height: 24.h,
            borderRadius: 4.r,
            textSize: 11.sp,
            buttonColor: AppColors.primaryGreen,
            icon: Icons.share,
            onPressed: _isSubmitting ? null : () => _shareTableImage(btnContext),
          ),
        ),
        if (canOrder) ...[
          SizedBox(width: 8.w),
          AppCommonButton(
            text: 'Order',
            height: 24.h,
            borderRadius: 4.r,
            textSize: 11.sp,
            buttonColor: AppColors.primary,
            isLoading: _isSubmitting,
            icon: Icons.check,
            onPressed: _isSubmitting ? null : _submitBulkOrder,
          ),
        ],
      ],
    );
  }

  Widget _buildOffscreenShareTable({
    required String dialogTitle,
    required List<String> units,
    required List<_UnitRequestOrderItemData> itemsData,
  }) {
    return Positioned(
      left: -9999,
      top: -9999,
      child: RepaintBoundary(
        key: _tableRepaintKey,
        child: Container(
          color: AppColors.white,
          padding: EdgeInsets.all(12.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dialogTitle,
                style: AppTextStyle.style_14_700(
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 12.h),
              Table(
                defaultColumnWidth: const IntrinsicColumnWidth(),
                border: TableBorder.all(
                  color: AppColors.borderColor,
                  width: 1.r,
                ),
                children: [
                  // Table Header Row
                  TableRow(
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 2.h,
                        ),
                        child: Text(
                          'Item',
                          textAlign: TextAlign.center,
                          style: AppTextStyle.style_11_700(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      ...units.map(
                        (uName) => Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 2.h,
                          ),
                          child: Text(
                            uName,
                            textAlign: TextAlign.center,
                            style: AppTextStyle.style_11_700(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 2.h,
                        ),
                        child: Text(
                          'Total',
                          textAlign: TextAlign.center,
                          style: AppTextStyle.style_11_700(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Table Data Rows
                  ...itemsData.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final itemData = entry.value;
                    final rowBgColor =
                        idx % 2 == 0 ? AppColors.white : AppColors.grey50;

                    return TableRow(
                      decoration: BoxDecoration(color: rowBgColor),
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 2.h,
                          ),
                          child: Text(
                            itemData.itemName,
                            style: AppTextStyle.style_11_500(
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        ...units.map((uName) {
                          final qtyDisplay =
                              itemData.unitQtyDisplayMap[uName]?.trim();
                          final String textToShow;
                          if (qtyDisplay != null) {
                            textToShow = qtyDisplay;
                          } else {
                            final qty = itemData.unitQtyMap[uName] ?? 0;
                            textToShow = qty > 0
                                ? '${_formatQty(qty)} ${itemData.displayUnit}'
                                : '';
                          }
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 2.h,
                            ),
                            child: Text(
                              textToShow,
                              textAlign: TextAlign.center,
                              style: AppTextStyle.style_11_400(
                                color: AppColors.black,
                              ),
                            ),
                          );
                        }),
                        Container(
                          color: AppColors.yellow50,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 2.h,
                          ),
                          child: Text(
                            (itemData.totalQtyDisplay != null &&
                                    itemData.totalQtyDisplay!.trim().isNotEmpty)
                                ? itemData.totalQtyDisplay!.trim()
                                : (itemData.totalQty > 0
                                    ? '${_formatQty(itemData.totalQty)} ${itemData.displayUnit}'
                                    : ''),
                            textAlign: TextAlign.center,
                            style: AppTextStyle.style_11_500(
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  // endregion

  // region Dialogs & Action Handlers
  Future<void> _fetchBulkPreview() async {
    setState(() {
      _isLoadingPreview = true;
    });
    try {
      final repository = Get.find<InventoryRepository>();
      final response = await repository.getInventoryOrders();
      if (response != null &&
          response['status'] == true &&
          response['data'] != null) {
        final bulkData = response['data']['bulk_preview'];
        if (bulkData != null && bulkData['unit_orders'] != null) {
          _fetchedPreviewSection = BulkPreviewSection.fromJson(
            bulkData['unit_orders'],
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching bulk preview for unit orders: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPreview = false;
        });
      }
    }
  }

  Future<void> _submitBulkOrder() async {
    // RBAC Tap Guard
    if (!Get.find<AuthRepository>().rxUserPermissions.contains('Inv_Unit_Order')) {
      AppCommonToastMessage.show(
        message: 'You do not have permission to perform this action.',
        type: ToastType.warning,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = Get.find<InventoryRepository>();
      final response = await repository.createBulkUnitOrder();

      if (response != null &&
          (response['status'] == true || response['status'] == 'success')) {
        final message =
            response['message']?.toString() ??
            'Unit order(s) created successfully.';

        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }

        AppCommonToastMessage.show(message: message, type: ToastType.success);

        if (Get.isRegistered<UnitInventoryController>()) {
          Get.find<UnitInventoryController>().fetchUnitInventory();
        }
        if (Get.isRegistered<InventoryController>()) {
          Get.find<InventoryController>().fetchInventoryStock();
        }
        if (Get.isRegistered<InventoryOrdersController>()) {
          Get.find<InventoryOrdersController>().fetchOrders();
        }
      } else {
        final errorMessage =
            response?['message']?.toString() ?? 'Failed to create unit orders.';
        AppCommonToastMessage.show(
          message: errorMessage,
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to create unit orders: $e',
        type: ToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _formatQty(num qty) {
    final formatter = NumberFormat('#,##0');
    return formatter.format(qty);
  }

  Future<void> _shareTableImage(BuildContext btnContext) async {
    try {
      final boundary =
          _tableRepaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        AppCommonToastMessage.show(
          message: 'Unable to capture table image.',
          type: ToastType.error,
        );
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/unit_required_orders_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes);
      if (!btnContext.mounted) return;

      final box = btnContext.findRenderObject() as RenderBox?;
      final rect = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : Rect.fromLTWH(
              0,
              0,
              MediaQuery.of(btnContext).size.width,
              MediaQuery.of(btnContext).size.height / 2,
            );

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Unit Required Orders',
        sharePositionOrigin: rect,
      );
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to share image: $e',
        type: ToastType.error,
      );
    }
  }
  // endregion
}
// endregion
